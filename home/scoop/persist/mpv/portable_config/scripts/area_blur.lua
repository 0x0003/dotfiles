-- Blur / pixelate rectangular areas of the video.
--
-- Controls:
--   alt + drag         select a new area
--   alt + drag edge    resize area
--   alt + drag center  move area
--   alt + right click  remove the area under the cursor
--   alt + wheel        adjust strength
--   alt + z            increase strength
--   alt + shift + z    decrease strength
--   alt + c            toggle blur <-> pixelate
--   alt + v            toggle blur visibility
--   alt + b            toggle hide borders when inactive
--   alt + x            remove all areas
--
-- Areas are stored normalised to the video frame, so they survive window
-- resizes, aspect changes, zoom/pan and playlist switches.

local msg = require 'mp.msg'
local options = require 'mp.options'
local utils = require 'mp.utils'
local assdraw = require 'mp.assdraw'

local o = {
    -- 'shader': one generated GLSL pass on the GPU
    -- 'ffmpeg': crop+blur+overlay graph on the CPU
    backend = 'shader',
    -- 'blur' or 'pixelate'
    effect = 'blur',
    -- blur radius in pixels, used by both backends
    radius = 12,
    -- ffmpeg backend only: 'boxblur' or 'gblur'
    ffmpeg_blur = 'boxblur',
    -- ffmpeg backend only: gaussian sigma, used when ffmpeg_blur=gblur
    sigma = 8,
    -- mosaic block size in pixels
    pixel_size = 16,
    -- blur radius step for wheel/key adjustments
    radius_step = 10,
    max_areas = 24,
    -- areas thinner than this (fraction of the frame) are discarded
    min_size = 0.004,
    -- draw selection outline and corner handles
    outline = true,
    handles = true,
    -- persist areas per file to disk
    persist = false,
    -- hide borders when not dragging
    hide_borders_when_inactive = false,
    -- show OSD debug messages (area add/move/resize/remove, restore, effect toggle)
    debug = false,
}
options.read_options(o, 'area_blur')

local FILTER_LABEL = 'area-blur'
local SHADER_PREFIX = 'area_blur_'

-- area: {x0, y0, x1, y1}, normalised to the frame, x0 <= x1 and y0 <= y1
local areas = {}
local drag = nil

local mouse = {x = 0, y = 0}
local last_in_video = nil
local hover = nil
local blur_visible = true

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function round(n) return math.floor(n + 0.5) end

local function osd(msg)
    if o.debug then mp.osd_message(msg) end
end

local function osd_always(msg)
    mp.osd_message(msg)
end

-- coords
-- video rectangle inside the window, in window pixels
local function video_rect()
    local d = mp.get_property_native('osd-dimensions')
    if not d or not d.w or d.h == nil then return nil end
    local w = d.w - (d.ml or 0) - (d.mr or 0)
    local h = d.h - (d.mt or 0) - (d.mb or 0)
    if w <= 1 or h <= 1 then return nil end
    return {x = d.x or (d.ml or 0), y = d.y or (d.mt or 0), w = w, h = h}
end

-- window pixels -> normalised frame coords (nil when outside video)
local function to_norm(mx, my)
    local v = video_rect()
    if not v then return nil end
    local u = (mx - v.x) / v.w
    local t = (my - v.y) / v.h
    if u < 0 or u > 1 or t < 0 or t > 1 then return nil end
    return u, t
end

-- normalised frame coords -> window pixels, rounded for assdraw
local function to_window(x0, y0, x1, y1)
    local v = video_rect()
    if not v then return nil end
    return math.floor(v.x + x0 * v.w + 0.5), math.floor(v.y + y0 * v.h + 0.5),
           math.floor(v.x + x1 * v.w + 0.5), math.floor(v.y + y1 * v.h + 0.5)
end

-- persistence
local persist_file = nil
local persist_dirty = false
local persist_path_key = nil

local function persist_path()
    if not persist_file then
        -- mp.find_config_file('.') returns the config directory
        local config = mp.find_config_file('.')
        if config and config ~= '' then
            -- strip trailing . or ./
            config = config:gsub('[./]+$', '')
            persist_file = utils.join_path(config, 'area_blur_persist.json')
        else
            -- Windows fallback: %APPDATA%\mpv
            local appdata = os.getenv('APPDATA') or os.getenv('LOCALAPPDATA')
            if appdata then
                persist_file = utils.join_path(appdata, 'mpv', 'area_blur_persist.json')
            else
                persist_file = utils.join_path(os.getenv('HOME') or '/tmp', 'area_blur_persist.json')
            end
        end
    end
    return persist_file
end

local function normalize_path(p)
    return p:gsub('\\', '/'):gsub('//+', '/')
end

local function persist_save()
    if not o.persist or not persist_dirty then return end
    if not persist_path_key then msg.error('area_blur: no cached path for save') return end
    local path = persist_path()
    msg.info(('area_blur: saving to %s'):format(path))
    local data = {}
    local f2 = io.open(path, 'r')
    if f2 then
        local ok, decoded = pcall(utils.parse_json, f2:read('*a'))
        if ok and type(decoded) == 'table' then data = decoded end
        f2:close()
        msg.info(('area_blur: loaded %d existing entries'):format(#data))
    else
        msg.info('area_blur: no existing file, starting fresh')
    end
    local key = normalize_path(persist_path_key)
    if #areas > 0 then data[key] = areas else data[key] = nil end
    local json_str
    local ok = pcall(function() json_str = utils.format_json(data) end)
    if not ok or not json_str then
        msg.error('area_blur: JSON encode failed')
        return
    end
    msg.info(('area_blur: JSON length %d'):format(#json_str))
    local f, err = io.open(path, 'w')
    if not f then msg.error('area_blur: cannot open ' .. path .. ' - ' .. (err or 'unknown')) return end
    local written = f:write(json_str)
    if not written then msg.error('area_blur: write failed')
    else msg.info('area_blur: write succeeded') end
    f:close()
    persist_dirty = false
end

local function persist_mark_dirty()
    persist_dirty = true
    persist_save()
end

-- smallest area containing the point (overlaps resolve to smallest)
local function area_at(u, t)
    local best, best_size = nil, nil
    for i, a in ipairs(areas) do
        if u >= a.x0 and u <= a.x1 and t >= a.y0 and t <= a.y1 then
            local size = (a.x1 - a.x0) * (a.y1 - a.y0)
            if best == nil or size < best_size then
                best, best_size = i, size
            end
        end
    end
    return best
end

local function rect_too_small(a)
    return (a.x1 - a.x0) < o.min_size or (a.y1 - a.y0) < o.min_size
end

-- the rectangle the current drag describes, anchored at drag.ax/ay
local function drag_rect()
    local u, t = to_norm(mouse.x, mouse.y)
    if u then last_in_video = {u, t} end
    if not last_in_video then return nil end
    u, t = last_in_video[1], last_in_video[2]

    if drag.mode == 'move' then
        local a = drag.orig
        local w = a.x1 - a.x0
        local h = a.y1 - a.y0
        local cx = u - drag.ox
        local cy = t - drag.oy
        return {
            x0 = cx - w / 2,
            y0 = cy - h / 2,
            x1 = cx + w / 2,
            y1 = cy + h / 2,
        }
    end

    return {
        x0 = math.min(drag.ax, u),
        y0 = math.min(drag.ay, t),
        x1 = math.max(drag.ax, u),
        y1 = math.max(drag.ay, t),
    }
end

-- selection overlay
local overlay = mp.create_osd_overlay('ass-events')
overlay.z = 100

local COLOR_AREA = 'AAAAAA'
local COLOR_HOVER = '00D7FF'
local COLOR_DRAG = '00D7FF'

local function begin_shape(ass, color, alpha)
    ass:new_event()
    ass:append(('{\\blur0\\bord0\\shad0\\1c&H%s\\1a&H%s}'):format(color, alpha))
    ass:pos(0, 0)
    ass:draw_start()
end

-- hollow rectangle: outer ring clockwise, inner hole counter-clockwise
local function draw_outline(ass, x1, y1, x2, y2, t)
    ass:rect_cw(x1, y1, x2, y2)
    if x2 - x1 > 2 * t + 1 and y2 - y1 > 2 * t + 1 then
        ass:move_to(x1 + t, y1 + t)
        ass:line_to(x1 + t, y2 - t)
        ass:line_to(x2 - t, y2 - t)
        ass:line_to(x2 - t, y1 + t)
        ass:line_to(x1 + t, y1 + t)
    end
end

local function draw_handles(ass, x1, y1, x2, y2)
    local h = 3
    -- assdraw formats with %d, midpoints of odd-length rects are .5
    local mx, my = math.floor((x1 + x2) / 2), math.floor((y1 + y2) / 2)
    ass:rect_cw(x1 - h, y1 - h, x1 + h, y1 + h)
    ass:rect_cw(mx - h, y1 - h, mx + h, y1 + h)
    ass:rect_cw(x2 - h, y1 - h, x2 + h, y1 + h)
    ass:rect_cw(x1 - h, my - h, x1 + h, my + h)
    ass:rect_cw(x2 - h, my - h, x2 + h, my + h)
    ass:rect_cw(x1 - h, y2 - h, x1 + h, y2 + h)
    ass:rect_cw(mx - h, y2 - h, mx + h, y2 + h)
    ass:rect_cw(x2 - h, y2 - h, x2 + h, y2 + h)
end

function render_overlay()
    if not osd then return end
    local d = mp.get_property_native('osd-dimensions')
    if not d or not d.w or d.h == nil then return end

    local show_outline
    if o.hide_borders_when_inactive then
        show_outline = drag
    else
        show_outline = (blur_visible and o.outline and #areas > 0) or drag
    end
    if not show_outline then
        if overlay.data ~= '' then
            overlay.data = ''
            overlay:update()
        end
        return
    end

    local ass = assdraw.ass_new()

    if o.outline then
        for i, a in ipairs(areas) do
            local x1, y1, x2, y2 = to_window(a.x0, a.y0, a.x1, a.y1)
            if x1 then
                local color = (i == hover) and COLOR_HOVER or COLOR_AREA
                begin_shape(ass, color, '40')
                draw_outline(ass, x1, y1, x2, y2, 1)
                ass:draw_stop()
                if o.handles and (i == hover or not drag) then
                    begin_shape(ass, color, '00')
                    draw_handles(ass, x1, y1, x2, y2)
                    ass:draw_stop()
                end
            end
        end
    end

    if drag then
        local r = drag_rect()
        local v = video_rect()
        if r and v then
            local x1, y1, x2, y2 = to_window(r.x0, r.y0, r.x1, r.y1)
            begin_shape(ass, COLOR_DRAG, '00')
            draw_outline(ass, x1, y1, x2, y2, 1)
            draw_handles(ass, x1, y1, x2, y2)
            ass:draw_stop()

            local function pct(v2)
                return ('%d%%'):format(math.floor((v2 + 0.5) * 100))
            end
            ass:new_event()
            ass:append(('{\\blur0\\bord0\\shad0\\1c&H%s\\1a&H60\\fs13}'):format(COLOR_DRAG))
            ass:pos(math.floor(clamp(x2, 30, v.w)), math.floor(clamp(y1 - 4, 12, v.h)))
            ass:an(2)
            ass:append(pct(r.x1 - r.x0) .. ' x ' .. pct(r.y1 - r.y0))
        end
    end

    overlay.res_x = math.floor(d.w)
    overlay.res_y = math.floor(d.h)
    overlay.data = ass.text
    overlay:update()
end

-- backend: generated GLSL shader
local shader_seq = 0
local shader_dir = nil
local shader_files = {}
local last_sources = {}

-- Dense 1D Gaussian kernel at 1px spacing: taps from -radius to +radius.
-- Recomputed per commit because the tap count depends on the current radius.
local function build_blur_taps(radius)
    local taps = {}
    local function gauss(x, s) return math.exp(-0.5 * (x / s) ^ 2) end
    -- sigma = radius / 3 gives ~99% mass within +-radius
    local sigma = radius / 3.0
    local sum = 0
    for i = -radius, radius do
        sum = sum + gauss(i, sigma)
    end
    for i = -radius, radius do
        table.insert(taps, {i, gauss(i, sigma) / sum})
    end
    return taps
end

-- One pixel in normalised units. HOOKED_pt preferred at runtime,
-- but falls back to CPU-measured frame size if driver doesn't supply sane value.
local function fallback_pt()
    local v = mp.get_property_native('video-out-params')
        or mp.get_property_native('video-params')
    local w = (v and v.w) or 1920
    local h = (v and v.h) or 1080
    if w < 1 then w = 1920 end
    if h < 1 then h = 1080 end
    return 1 / w, 1 / h
end

-- Returns a table: {pixelate = src} or {blur_h = src_h, blur_v = src_v}
local function build_shaders()
    local n = #areas
    if n == 0 then return {} end

    local fpx, fpy = fallback_pt()

    -- common header with rect definitions
    local function header()
        local lines = {}
        local function add(s) lines[#lines + 1] = s end
        add('//!HOOK MAIN')
        add('//!BIND HOOKED')
        add(('//!DESC area_blur: %s over %d area(s)'):format(o.effect, n))
        add('')
        add(('#define AREA_COUNT %d'):format(n))
        add(('#define IS_PIXELATE %d'):format(o.effect == 'pixelate' and 1 or 0))
        add(('#define RADIUS %s'):format(('%.4f'):format(math.max(1, o.radius))))
        add(('#define BLOCK %s'):format(('%.4f'):format(math.max(2, o.pixel_size))))
        add(('#define FALLBACK_PT vec2(%s, %s)'):format(('%.8f'):format(fpx),
            ('%.8f'):format(fpy)))
        add('')
        for i, a in ipairs(areas) do
            add(('#define RECT_%d vec4(%s, %s, %s, %s)'):format(i,
                ('%.6f'):format(a.x0), ('%.6f'):format(a.y0),
                ('%.6f'):format(a.x1), ('%.6f'):format(a.y1)))
        end
        add('')
        add([[
bool in_rect(vec2 p, vec4 r) {
    return p.x >= r.x && p.x <= r.z && p.y >= r.y && p.y <= r.w;
}

float rect_size(vec4 r) {
    return max(r.z - r.x, 0.0) * max(r.w - r.y, 0.0);
}

vec4 hook() {
    vec2 p = HOOKED_pos;

    // One pixel in normalised units. A missing, NaN or nonsensical value makes
    // every tap land on the same texel, which looks like a solid colour block
    // rather than an error, so fall back to the CPU-measured frame size.
    vec2 pt = HOOKED_pt;
    if (!(pt.x > 0.0 && pt.x < 0.5 && pt.y > 0.0 && pt.y < 0.5))
        pt = FALLBACK_PT;

    // smallest matching area wins
    vec4 rect = vec4(0.0);
    bool found = false;
    float found_size = 0.0;
]])
        for i = 1, n do
            add(('    { vec4 r = RECT_%d; if (in_rect(p, r)) { float s = rect_size(r); '
                .. 'if (!found || s < found_size) { found = true; found_size = s; rect = r; } } }')
                :format(i))
        end
        add([[    if (!found) return HOOKED_tex(p);

    vec2 span = rect.zw - rect.xy;
    vec2 rad = RADIUS * pt;
]])
        return lines
    end

    local sources = {}

    if o.effect == 'pixelate' then
        local lines = header()
        local function add(s) lines[#lines + 1] = s end
        add([[
    // one flat colour per block, grid aligned to the rectangle edges
    vec2 blocks = max(vec2(1.0), floor(span / (BLOCK * pt)));
    vec2 bs = max(span / blocks, pt);
    vec2 idx = clamp(floor((p - rect.xy) / bs), vec2(0.0), blocks - vec2(1.0));
    return HOOKED_tex(rect.xy + (idx + vec2(0.5)) * bs);
}
]])
        sources.pixelate = table.concat(lines, '\n') .. '\n'
    else
        -- two-pass separable blur: horizontal then vertical
        local taps = build_blur_taps(math.max(1, math.floor(o.radius + 0.5)))

        -- horizontal pass
        local lines_h = header()
        local function add_h(s) lines_h[#lines_h + 1] = s end
        add_h([[
    // horizontal pass: dense Gaussian, 1px spacing
    vec4 acc = vec4(0.0);
    float wsum = 0.0;
]])
        for _, t in ipairs(taps) do
            add_h(('    { float x = clamp(p.x + %s * pt.x, rect.x, rect.z - pt.x); '
                .. 'vec2 sp = vec2(x, p.y); acc += HOOKED_tex(sp) * %s; wsum += %s; }')
                :format(t[1], ('%.6f'):format(t[2]), ('%.6f'):format(t[2])))
        end
        add_h('    return acc / wsum;')
        add_h('}')
        sources.blur_h = table.concat(lines_h, '\n') .. '\n'

        -- vertical pass
        local lines_v = header()
        local function add_v(s) lines_v[#lines_v + 1] = s end
        add_v([[
    // vertical pass: dense Gaussian, 1px spacing
    vec4 acc = vec4(0.0);
    float wsum = 0.0;
]])
        for _, t in ipairs(taps) do
            add_v(('    { float y = clamp(p.y + %s * pt.y, rect.y, rect.w - pt.y); '
                .. 'vec2 sp = vec2(p.x, y); acc += HOOKED_tex(sp) * %s; wsum += %s; }')
                :format(t[1], ('%.6f'):format(t[2]), ('%.6f'):format(t[2])))
        end
        add_v('    return acc / wsum;')
        add_v('}')
        sources.blur_v = table.concat(lines_v, '\n') .. '\n'
    end

    return sources
end

local function is_our_shader(entry)
    return type(entry) == 'string' and entry:find(SHADER_PREFIX, 1, true) ~= nil
end

local function set_shader_list(keep_ours)
    local list = {}
    for _, entry in ipairs(mp.get_property_native('glsl-shaders') or {}) do
        if not is_our_shader(entry) then list[#list + 1] = entry end
    end
    if keep_ours then
        -- insert in order: horizontal then vertical for blur, just pixelate for pixelate
        for _, f in ipairs(shader_files) do list[#list + 1] = f end
    end
    mp.set_property_native('glsl-shaders', list)
end

local function candidate_dirs()
    local dirs = {}
    local config_dir = mp.get_property('config-dir')
    if config_dir and config_dir ~= '' then
        dirs[#dirs + 1] = utils.join_path(config_dir, 'cache')
        dirs[#dirs + 1] = config_dir
    end
    local tmp = os.getenv('TMPDIR') or os.getenv('TEMP')
    if tmp and tmp ~= '' then dirs[#dirs + 1] = tmp end
    dirs[#dirs + 1] = '/tmp'
    return dirs
end

local function apply_shader()
    if #areas == 0 then
        for _, old in ipairs(shader_files) do
            mp.add_timeout(2, function() os.remove(old) end)
        end
        if #shader_files > 0 then set_shader_list(false) end
        shader_files, last_sources = {}, {}
        return
    end

    local sources = build_shaders()
    if not next(sources) then return end

    -- deterministic order: horizontal must run before vertical for blur
    local ordered_kinds = sources.pixelate and {'pixelate'} or {'blur_h', 'blur_v'}

    -- nothing to do if the same shaders are already installed and in place
    local same = #shader_files > 0
    if same then
        for _, k in ipairs(ordered_kinds) do
            if sources[k] ~= last_sources[k] then same = false break end
        end
    end
    if same then
        set_shader_list(true)
        return
    end

    local new_files = {}
    for _, kind in ipairs(ordered_kinds) do
        local path, handle
        if shader_dir then
            shader_seq = shader_seq + 1
            local suffix = (kind == 'pixelate') and '' or ('_' .. kind)
            path = utils.join_path(shader_dir, ('%s%d%s.glsl'):format(SHADER_PREFIX, shader_seq, suffix))
            handle = io.open(path, 'wb')
        end
        if not handle then
            for _, dir in ipairs(candidate_dirs()) do
                shader_seq = shader_seq + 1
                local suffix = (kind == 'pixelate') and '' or ('_' .. kind)
                path = utils.join_path(dir, ('%s%d%s.glsl'):format(SHADER_PREFIX, shader_seq, suffix))
                handle = io.open(path, 'wb')
                if handle then shader_dir = dir break end
            end
        end
        if not handle then
            msg.error('area_blur: no writable directory for the generated shader')
            for _, f in ipairs(new_files) do os.remove(f) end
            return
        end
        handle:write(sources[kind])
        handle:close()
        new_files[#new_files + 1] = path
    end

    -- schedule deletion of old files
    for _, old in ipairs(shader_files) do
        mp.add_timeout(2, function() os.remove(old) end)
    end

    shader_files, last_sources = new_files, sources
    set_shader_list(true)
end

-- backend: ffmpeg crop + blur + overlay graph
-- The size the filter sees. video-out-params describes the frame after every
-- filter, and our graph preserves dimensions, so it is also the input size.
local function frame_size()
    local p = mp.get_property_native('video-out-params')
    if p and p.w and p.h and p.w > 0 and p.h > 0 then return p.w, p.h end
    p = mp.get_property_native('video-params')
    if p and p.w and p.h and p.w > 0 and p.h > 0 then return p.w, p.h end
    local v = video_rect()
    if v then return v.w, v.h end
    return nil
end

-- keep crop and overlay chroma-friendly by rounding to even pixels
local function even(n) return n - (n % 2) end

local function build_graph()
    local fw, fh = frame_size()
    if not fw or not fh then return nil end

    local blur = {}
    if o.effect == 'pixelate' then
    elseif o.ffmpeg_blur == 'gblur' then
        blur = {('gblur=sigma=%.2f:steps=2'):format(o.sigma)}
    else
        -- luma_power=2 runs box filter twice (closer to gaussian); chroma radius halved to match luma visually
        blur = {('boxblur=luma_radius=%d:luma_power=2:chroma_radius=%d:chroma_power=2')
            :format(math.max(1, round(o.radius)),
                    math.max(1, round(o.radius / 2)))}
    end

    local parts = {}
    local labels = {'[base]'}
    for i = 1, #areas do labels[#labels + 1] = ('[s%d]'):format(i) end
    parts[#parts + 1] = ('[0]split=%d%s'):format(#areas + 1, table.concat(labels))

    local prev = '[base]'
    for i, a in ipairs(areas) do
        local x = even(clamp(math.floor(a.x0 * fw + 0.5), 0, fw - 2))
        local y = even(clamp(math.floor(a.y0 * fh + 0.5), 0, fh - 2))
        local w = even(clamp(math.ceil(a.x1 * fw), x + 2, fw) - x)
        local h = even(clamp(math.ceil(a.y1 * fh), y + 2, fh) - y)
        w = math.min(w, fw - x)
        h = math.min(h, fh - y)

        local out = ('[b%d]'):format(i)
        local steps = {('crop=%d:%d:%d:%d'):format(w, h, x, y)}
        if o.effect == 'pixelate' then
            -- o.pixel_size is on-screen block edge, block count from area size
            -- neighbour sampling keeps hard edges, up-scale restores crop size for overlay
            local block = math.max(2, o.pixel_size)
            local dw = math.max(2, even(math.floor(w / block + 0.5)))
            local dh = math.max(2, even(math.floor(h / block + 0.5)))
            steps[#steps + 1] = ('scale=%d:%d:flags=neighbor'):format(dw, dh)
            steps[#steps + 1] = ('scale=%d:%d:flags=neighbor'):format(w, h)
        else
            for _, s in ipairs(blur) do steps[#steps + 1] = s end
        end
        parts[#parts + 1] = ('%s%s%s'):format(('[s%d]'):format(i),
            table.concat(steps, ','), out)

        local merged = ('[o%d]'):format(i)
        parts[#parts + 1] = ('%s%s overlay=%d:%d%s'):format(prev, out, x, y, merged)
        prev = merged
    end

    return table.concat(parts, ';')
end

local last_graph = nil

local function apply_ffmpeg()
    local graph = nil
    if #areas > 0 then
        graph = build_graph()
        if not graph then
            msg.warn('area_blur: ffmpeg backend, unknown frame size, skipping')
            return
        end
    end

    local list = {}
    for _, entry in ipairs(mp.get_property_native('vf') or {}) do
        if entry.label ~= FILTER_LABEL then list[#list + 1] = entry end
    end
    if graph then
        list[#list + 1] = {name = 'lavfi', label = FILTER_LABEL, params = {graph = graph}}
    end
    mp.set_property_native('vf', list)
    last_graph = graph
end

function apply()
    if not blur_visible then
        if o.backend == 'ffmpeg' then
            if last_graph == nil then return end
            local list = {}
            for _, entry in ipairs(mp.get_property_native('vf') or {}) do
                if entry.label ~= FILTER_LABEL then list[#list + 1] = entry end
            end
            mp.set_property_native('vf', list)
            last_graph = nil
        else
            if #shader_files == 0 then return end
            for _, old in ipairs(shader_files) do
                mp.add_timeout(2, function() os.remove(old) end)
            end
            set_shader_list(false)
            shader_files, last_sources = {}, {}
        end
        return
    end
    if o.backend == 'ffmpeg' then
        if #areas == 0 and last_graph == nil then return end
        apply_ffmpeg()
    else
        apply_shader()
    end
end

-- mouse
-- Use mouse-pos rather than mouse_move key binding, because
-- uosc force-binds the latter
mp.observe_property('mouse-pos', 'native', function(_, val)
    if not val then return end
    mouse.x, mouse.y = val.x, val.y

    local u, t = to_norm(val.x, val.y)
    if u then
        last_in_video = {u, t}
        hover = area_at(u, t)
    else
        hover = nil
    end

    if drag then
        -- drag survives pointer leaving video, but not video going away (playlist switch mid-drag)
        if not video_rect() then drag = nil end
    end

    if o.outline and (#areas > 0 or drag) then render_overlay() end
end)

local drag_commit

local function drag_start()
    if drag then
        drag = nil
        render_overlay()
        osd('area_blur: aborted an unfinished selection')
    end

    if #areas >= o.max_areas then
        osd(('area_blur: area limit reached (%d)'):format(o.max_areas))
        return
    end
    local u, t = to_norm(mouse.x, mouse.y)
    if not u then return end
    last_in_video = {u, t}

    local idx = area_at(u, t)
    if idx then
        local a = areas[idx]
        local cx = (a.x0 + a.x1) / 2
        local cy = (a.y0 + a.y1) / 2
        local hw = (a.x1 - a.x0) / 2
        local hh = (a.y1 - a.y0) / 2
        local hotspot = 0.15

        local near_left = (u - a.x0) < hw * hotspot
        local near_right = (a.x1 - u) < hw * hotspot
        local near_top = (t - a.y0) < hh * hotspot
        local near_bottom = (a.y1 - t) < hh * hotspot

        local on_edge = near_left or near_right or near_top or near_bottom

        if on_edge then
            drag = {
                index = idx,
                mode = 'resize',
                ax = (u < cx) and a.x1 or a.x0,
                ay = (t < cy) and a.y1 or a.y0,
            }
        else
            drag = {
                index = idx,
                mode = 'move',
                ox = u - cx,
                oy = t - cy,
                orig = {x0 = a.x0, y0 = a.y0, x1 = a.x1, y1 = a.y1},
            }
        end
    else
        drag = {ax = u, ay = t, mode = 'new'}
    end
    render_overlay()
end

drag_commit = function()
    if not drag then return end
    local d = drag
    local r = drag_rect()
    drag = nil
    if not r or rect_too_small(r) then
        render_overlay()
        osd('area_blur: area too small, discarded')
        return
    end
    if d.index then
        if d.mode == 'move' then
            areas[d.index] = r
            osd(('area_blur: area %d moved (%d total)'):format(d.index, #areas))
        else
            areas[d.index] = r
            osd(('area_blur: area %d resized (%d total)'):format(d.index, #areas))
        end
    else
        areas[#areas + 1] = r
        osd(('area_blur: area %d added (%d total)'):format(#areas, #areas))
    end
    apply()
    render_overlay()
    persist_mark_dirty()
end

-- One complex binding for Alt+MBTN_LEFT (uosc force-binds mbtn_left, swallowing release);
-- complex mode delivers down and up to one handler
mp.add_key_binding('Alt+MBTN_LEFT', 'area-blur-select', function(ev)
    if ev.event == 'down' then
        drag_start()
    elseif ev.event == 'up' then
        drag_commit()
    end
end, {complex = true})

mp.add_key_binding('Alt+MBTN_RIGHT', 'area-blur-remove', function()
    local u, t = to_norm(mouse.x, mouse.y)
    if not u then return end
    local idx = area_at(u, t)
    if not idx then
        osd('area_blur: no area here')
        return
    end
    table.remove(areas, idx)
    hover = nil
    apply()
    render_overlay()
    persist_mark_dirty()
    osd(('area_blur: area removed (%d left)'):format(#areas))
end)

-- keys
local function adjust(delta)
    if o.effect == 'pixelate' then
        o.pixel_size = clamp(o.pixel_size + delta * 2, 2, 256)
        osd_always(('area_blur: mosaic block %dpx'):format(o.pixel_size))
    else
        o.radius = clamp(o.radius + delta * o.radius_step, 1, 256)
        osd_always(('area_blur: radius %dpx'):format(o.radius))
    end
    apply()
end

local function toggle_visibility()
    blur_visible = not blur_visible
    apply()
    render_overlay()
    osd(('area_blur: blur %s'):format(blur_visible and 'visible' or 'hidden'))
end

local function toggle_hide_borders()
    o.hide_borders_when_inactive = not o.hide_borders_when_inactive
    render_overlay()
    osd(('area_blur: hide borders when inactive = %s'):format(o.hide_borders_when_inactive and 'yes' or 'no'))
end

mp.add_key_binding('Alt+v', 'area-blur-toggle-visibility', toggle_visibility)
mp.add_key_binding('Alt+b', 'area-blur-toggle-hide-borders', toggle_hide_borders)

mp.add_key_binding('Alt+WHEEL_UP', 'area-blur-stronger', function() adjust(1) end, 'repeatable')
mp.add_key_binding('Alt+WHEEL_DOWN', 'area-blur-weaker', function() adjust(-1) end, 'repeatable')
mp.add_key_binding('Alt+z', 'area-blur-stronger', function() adjust(1) end, 'repeatable')
mp.add_key_binding('Alt+Shift+z', 'area-blur-weaker', function() adjust(-1) end, 'repeatable')

mp.add_key_binding('Alt+c', 'area-blur-effect', function()
    o.effect = (o.effect == 'blur') and 'pixelate' or 'blur'
    apply()
    osd('area_blur: effect = ' .. o.effect)
end)

mp.add_key_binding('Alt+x', 'area-blur-clear', function()
    if #areas == 0 then
        osd_always('area_blur: no areas')
        return
    end
    areas = {}
    hover = nil
    apply()
    render_overlay()
    persist_mark_dirty()
    osd_always('area_blur: cleared all areas')
end)

-- keep effect across playlist switches, self-heal if glsl-shaders rewritten
mp.register_event('video-reconfig', function()
    apply()
    render_overlay()
end)

mp.register_event('file-loaded', function()
    local new_path = mp.get_property('path')
    if not new_path then return end
    persist_path_key = new_path
    local path = persist_path()
    local f = io.open(path, 'r')
    local loaded = nil
    if f then
        local ok, data = pcall(utils.parse_json, f:read('*a'))
        f:close()
        if ok and type(data) == 'table' then
            local key = normalize_path(new_path)
            loaded = data[key]
        end
    end
    if loaded and type(loaded) == 'table' and #loaded > 0 then
        areas = loaded
        persist_dirty = false
        apply()
        render_overlay()
        osd(('area_blur: restored %d area(s)'):format(#areas))
    else
        -- no persisted data: keep current areas (carry over) and save to this file's entry
        if #areas > 0 then
            persist_dirty = true
            persist_save()
        end
    end
end)

if o.backend == 'shader' then
    mp.observe_property('glsl-shaders', 'native', function(_, val)
        if #areas == 0 or #shader_files == 0 then return end
        local have_all = true
        for _, f in ipairs(shader_files) do
            local found = false
            for _, entry in ipairs(val or {}) do
                if entry == f then found = true break end
            end
            if not found then have_all = false break end
        end
        if have_all then return end
        mp.add_timeout(0, function()
            if #areas > 0 and #shader_files > 0 then set_shader_list(true) end
        end)
    end)
end

mp.register_event('shutdown', function()
    persist_save()
    areas = {}
    drag = nil
    for _, old in ipairs(shader_files) do os.remove(old) end
    shader_files = {}
    if overlay then
        overlay.data = ''
        overlay:update()
    end
end)

msg.info(('area_blur loaded: backend=%s effect=%s'):format(o.backend, o.effect))
