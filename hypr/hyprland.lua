-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Independent workspaces per monitor (must load after the defaults it rebinds).
require("hypr.split-monitor-workspaces")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
o.window("qemu", { workspace = "5" })

-- Telegram's other class (org.telegram.desktop is handled by Omarchy defaults).
o.window("^(telegram-desktop)$", { focus_on_activate = false })

-- KeyStore Explorer: maximize the main window, float everything else.
o.window({ class = "^(org-kse-KSE)$", title = "KeyStore Explorer" }, { maximize = true })
o.window({ class = "^(org-kse-KSE)$", title = ".+" }, { float = true, center = true })
o.window({ class = "^(org-kse-KSE)$", title = "^$" }, { float = true })

-- Make all windows fully opaque (overrides Omarchy's default 0.985/0.96 opacity).
o.window(".*", { opacity = "1 1" })
