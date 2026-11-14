-- Hollow Knight: a calm soul-blue border. No glow, no motion, so the eye stays on the window content.
local active_border_color = "rgba(8fb8deb3)"
local inactive_border_color = "rgba(1c2230aa)"

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

  -- Darken the windows you are not using, so the focused one stands out.
  -- 0 = no dim, 1 = black. Raise it for a stronger effect.
  decoration = {
    dim_inactive = true,
    dim_strength = 0.15,
  },
})
