local opts = {
    slideshow_duration = 5,

    drag_to_pan_margin = 50,
    drag_to_pan_move_if_full_view = false,
}

-- automatically advance to the next image after a fixed duration;
-- works for static images and animated formats
local options = require 'mp.options'

options.read_options(opts, nil, function() end)

local enabled = false
local timer = nil

local animated_formats = {
    gif  = true,
    webp = true,
    apng = true,
    mng  = true,
    avif = true,
    jxl  = true,
}

local function in_image_mode()
    if mp.get_property_bool("current-tracks/video/image") then
        return not mp.get_property_bool("current-tracks/video/albumart")
    end
    return animated_formats[mp.get_property("file-format")] == true
end

local function stop()
    if timer then
        timer:kill()
        timer = nil
    end
end

local function start()
    stop()
    timer = mp.add_timeout(opts.slideshow_duration, function()
        timer = nil
        if in_image_mode() then
            mp.command("playlist-next")
        else
            start()
        end
    end)
end

local function toggle()
    enabled = not enabled
    if enabled then
        start()
        mp.osd_message("Slideshow: " .. opts.slideshow_duration .. "s")
    else
        stop()
        mp.osd_message("Slideshow: off")
    end
end

local function adjust(delta)
    opts.slideshow_duration = math.max(1, opts.slideshow_duration + delta)
    if enabled then start() end
    mp.osd_message("Slideshow: " .. opts.slideshow_duration .. "s")
end

mp.add_forced_key_binding(nil, "slideshow-toggle", toggle)
mp.add_forced_key_binding(nil, "slideshow-duration-inc", function() adjust(1) end)
mp.add_forced_key_binding(nil, "slideshow-duration-dec", function() adjust(-1) end)

mp.register_event("file-loaded", function()
    if enabled then start() end
end)

mp.register_event("shutdown", stop)

-- hold the left mouse button and drag to pan around a zoomed image;
-- adapted from https://github.com/occivink/mpv-image-viewer;
-- uses the mouse-pos property (delivered to all scripts) instead of the
-- mouse_move key binding, which uosc captures
options.read_options(opts, nil, function() end)

local function clamp(value, low, high)
    if value <= low then
        return low
    elseif value >= high then
        return high
    else
        return value
    end
end

local dragging = false
local mouse_pos_origin = {}
local video_pan_origin = {}
local video_size = nil
local dim = nil
local move_up = false
local move_lateral = false

local function update_pan(mX, mY)
    if not dragging or not video_size then return end
    local pX = video_pan_origin[1]
    local pY = video_pan_origin[2]
    local margin = opts.drag_to_pan_margin
    if move_lateral then
        pX = video_pan_origin[1] + (mX - mouse_pos_origin[1]) / video_size[1]
        if 2 * margin > dim.ml + dim.mr then
            pX = clamp(pX,
                (-margin + dim.w / 2) / video_size[1] - 0.5,
                (margin - dim.w / 2) / video_size[1] + 0.5)
        else
            pX = clamp(pX,
                (margin - dim.w / 2) / video_size[1] + 0.5,
                (-margin + dim.w / 2) / video_size[1] - 0.5)
        end
    end
    if move_up then
        pY = video_pan_origin[2] + (mY - mouse_pos_origin[2]) / video_size[2]
        if 2 * margin > dim.mt + dim.mb then
            pY = clamp(pY,
                (-margin + dim.h / 2) / video_size[2] - 0.5,
                (margin - dim.h / 2) / video_size[2] + 0.5)
        else
            pY = clamp(pY,
                (margin - dim.h / 2) / video_size[2] + 0.5,
                (-margin + dim.h / 2) / video_size[2] - 0.5)
        end
    end
    mp.command("no-osd set video-pan-x " .. clamp(pX, -3, 3) ..
               "; no-osd set video-pan-y " .. clamp(pY, -3, 3))
end

mp.add_key_binding(nil, "drag-to-pan", function(table)
    if table["event"] == "down" then
        local d = mp.get_property_native("osd-dimensions")
        if not d then return end
        dim = d
        video_size = { d.w - d.ml - d.mr, d.h - d.mt - d.mb }
        move_up = true
        move_lateral = true
        if not opts.drag_to_pan_move_if_full_view then
            if dim.ml >= 0 and dim.mr >= 0 then
                move_lateral = false
            end
            if dim.mt >= 0 and dim.mb >= 0 then
                move_up = false
            end
        end
        if not move_up and not move_lateral then return end
        mouse_pos_origin[1], mouse_pos_origin[2] = mp.get_mouse_pos()
        video_pan_origin[1] = mp.get_property_number("video-pan-x")
        video_pan_origin[2] = mp.get_property_number("video-pan-y")
        dragging = true
        update_pan(mouse_pos_origin[1], mouse_pos_origin[2])
    elseif table["event"] == "up" then
        dragging = false
        dim = nil
        video_size = nil
    end
end, {complex = true})

mp.observe_property("mouse-pos", "native", function(_, val)
    if dragging and val then
        update_pan(val.x, val.y)
    end
end)

-- put current and previous image side to side;
-- adapted from https://github.com/guidocella/mpv-image-config/
local is_intial_callback
local function undo_lavfi_complex()
    if is_intial_callback then
        is_intial_callback = false
        return
    end
    mp.set_property('lavfi-complex', '')
    mp.set_property('vid', 1)
    mp.command('video-remove 2')
    mp.unobserve_property(undo_lavfi_complex)
end

mp.register_script_message('double-page-mode', function()
    if mp.get_property_native('lavfi-complex') ~= '' then
        undo_lavfi_complex()
        return
    end

    local previous = mp.get_property('playlist/' .. mp.get_property('playlist-pos') - 1 .. '/filename')

    if not previous then
        local error = 'double-page-mode only works if there is a previous playlist entry.'
        mp.msg.error(error)
        mp.osd_message(error)
        return
    end

    mp.commandv('video-add', previous, 'auto')
    local track_list = mp.get_property_native('track-list')

    local graph = '[vid1] [vid2] hstack [vo]'
    if track_list[1]['demux-w'] ~= track_list[2]['demux-w'] or track_list[1]['demux-h'] ~= track_list[2]['demux-h'] then
        graph = '[vid2] scale=' .. track_list[1]['demux-w'] .. ':' .. track_list[1]['demux-h'] .. ' [vid2-scaled]; [vid1] [vid2-scaled] hstack [vo]'
    end

    mp.set_property('lavfi-complex', graph)

    is_intial_callback = true
    mp.observe_property('playlist-pos', nil, undo_lavfi_complex)
end)

