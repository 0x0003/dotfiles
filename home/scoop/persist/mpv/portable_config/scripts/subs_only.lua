-- Makes the background transparent, puts subtitles in the center,
-- resizes and moves the window so that it occupies 100% width
-- and 10% height at the top of the screen

local enabled = false
local original_background = mp.get_property("background-color")
local original_geometry = mp.get_property("geometry")

local function toggle_sub_only()
    enabled = not enabled

    if enabled then
        mp.set_property("sub-pos", 50)
        mp.set_property("background-color", "#00000000")
        mp.set_property("sub-scale", 8.0)
        mp.set_property("geometry", "100%x10%+0%+0%")
    else
        mp.set_property("sub-pos", 100)
        mp.set_property("background-color", original_background)
        mp.set_property("sub-scale", 1.0)
        mp.set_property("geometry", original_geometry)
    end
end

mp.add_key_binding("Ctrl+Shift+s", "toggle-sub-only", toggle_sub_only)

