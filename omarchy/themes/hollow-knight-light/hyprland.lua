-- Hollow Knight Light: a calm soul-blue border, light dimming on the windows you are not using.
local active_border_color = "rgba(3f6f9ecc)"
local inactive_border_color = "rgba(c5cfdcaa)"

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

  -- Light themes need less dimming; 0.15 here looks muddy.
  decoration = {
    dim_inactive = true,
    dim_strength = 0.08,
  },
})
