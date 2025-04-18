local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font_with_fallback({
	"MonoLisa Nerd Font Mono",
	"UDEV Gothic 35NFLG",
})
config.font_size = 14
config.line_height = 1.1

-- Colors
config.colors = {
	background = "14161B",
	cursor_bg = "white",
	cursor_border = "white",
}

-- Appearance
config.window_background_opacity = 0.75
config.macos_window_background_blur = 25
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 16,
	right = 12,
	top = 16,
	bottom = 8,
}

-- Miscellaneous
config.max_fps = 120
config.prefer_egl = true

return config
