local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

require("ui").apply_to_config(config)
require("remote").apply_to_config(config)
require("tmux").apply_to_config(config)

return config