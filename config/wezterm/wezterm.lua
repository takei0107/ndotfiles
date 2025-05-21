local wezterm = require("wezterm")

wezterm.on("update-right-status", function(window, pane)
  local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")

  window:set_right_status(wezterm.format({
    { Attribute = { Underline = "Single" } },
    { Attribute = { Italic = true } },
    { Text = date .. " " },
  }))
end)

return {
  use_ime = true,
  audible_bell = "Disabled",

  initial_cols = 120,
  initial_rows = 40,
  window_background_opacity = 0.7,

  font_size = 17,
  font = wezterm.font_with_fallback({
    {
      family = "Inconsolata",
      weight = "Regular",
      stretch = "Normal",
      style = "Normal",
    },
  }),
}
