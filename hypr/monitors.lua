local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@60",
	position = "auto",
	scale = (omarchy_monitor_scale == 1.0) and omarchy_monitor_scale or (omarchy_monitor_scale - 0.25),
})
