local omarchy_gdk_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.monitor({ output = "eDP-2", mode = "preferred", position = "auto", scale = 1.25 })

hl.monitor({ output = "desc:LG Electronics LG TV SSCR2 0x01010101", mode = "3840x2160@60", position = "auto", scale = 2 })

hl.monitor({ output = "desc:Dell Inc. DELL S2421HN FY056H3", mode = "1920x1080@74.97", position = "auto", scale = "auto" })
