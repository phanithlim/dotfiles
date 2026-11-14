-- Cuphead: a calm red border, light dimming on the windows you are not using.
local active_border_color = "rgba(c8302ccc)"
local inactive_border_color = "rgba(cdbb98aa)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    dim_inactive = true,
    dim_strength = 0.08,
  },
})
