-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Any monitor: use its preferred mode, place it automatically, pick scale automatically.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Laptop panel
hl.monitor({ output = "eDP-2", mode = "preferred", position = "auto", scale = 1.25 })

-- LG TV: 4K60 at scale 2 (needs LG Game Optimizer on for 4K60 and no overscan).
-- Matched by description so other monitors on HDMI-A-1 stay on auto.
hl.monitor({ output = "desc:LG Electronics LG TV SSCR2 0x01010101", mode = "3840x2160@60", position = "auto", scale = 2 })

-- Dell S2421HN: 1080p at its max 75Hz (preferred mode is 60Hz).
hl.monitor({ output = "desc:Dell Inc. DELL S2421HN FY056H3", mode = "1920x1080@74.97", position = "auto", scale = "auto" })
