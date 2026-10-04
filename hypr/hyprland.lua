dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

require("default.hypr.omarchy")

require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

require("hypr.split-monitor-workspaces")

require("default.hypr.toggles")

o.window("qemu", { workspace = "5" })

o.window("^(telegram-desktop)$", { focus_on_activate = false })

o.window({ class = "^(org-kse-KSE)$", title = "KeyStore Explorer" }, { maximize = true })
o.window({ class = "^(org-kse-KSE)$", title = ".+" }, { float = true, center = true })
o.window({ class = "^(org-kse-KSE)$", title = "^$" }, { float = true })

o.window(".*", { opacity = "1 1" })
