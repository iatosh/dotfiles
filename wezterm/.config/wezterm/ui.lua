local wezterm = require("wezterm")
local module = {}

local function window_settings(config)
    config.window_padding = {
        left = 16,
        right = 10,
        top = 12,
        bottom = 10,
    }
    config.hide_tab_bar_if_only_one_tab = true
    config.window_background_opacity = 0.75
    config.macos_window_background_blur = 28
    -- config.window_decorations = 'RESIZE'
end

local function cursor_settings(config)
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_rate = 500
    config.cursor_blink_ease_in = "Constant"
    config.cursor_blink_ease_out = "Constant"
    config.cursor_thickness = "1"
end

local function font_settings(config)
    config.font = wezterm.font_with_fallback({
        {
            family = "Fira Code",
            weight = "Regular",
            italic = false,
            stretch = "Normal",
        },
        {
            family = "UDEV Gothic 35NFLG",
            weight = "Regular",
            italic = false,
            stretch = "Normal",
        }
    })
    config.font_size = 14.0
end

local function color_scheme_settings(config)
    config.color_scheme = "Monokai Remastered"
end

function module.apply_to_config(config)
    config.max_fps = 120
    window_settings(config)
    font_settings(config)
    color_scheme_settings(config)
    cursor_settings(config)
end

return module