local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
    config.ssh_domains = wezterm.default_ssh_domains()

    config.launch_menu = {
        {
            label = "SSH to kodama.local",
            args = {"wezterm", "connect", "kodama.local"},
        },
        {
            label = "SSH to kodama.remote",
            args = {"wezterm", "connect", "kodama.remote"},
        }
    }
end


return module