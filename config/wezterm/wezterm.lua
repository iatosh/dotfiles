local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

require("colors").apply_to_config(config, "spectrum")  -- Available variants: "pro", "octagon", "machine", "ristretto", "spectrum", "classic", "light"
require("ui").apply_to_config(config)
require("remote").apply_to_config(config)
return config
