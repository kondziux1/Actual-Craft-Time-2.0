local default_style = data.raw["gui-style"].default

-- Button style for slider navigation (-5, -1, +1, +5)
default_style.ACT2_buttons = {
  type = "button_style",
  parent = "slot_button",

  scalable = true,

  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  height = 20,
  width = 20,
}

-- Slot style for ingredient and product item icons (40x40, scalable)
default_style.ACT2_item_slot = {
  type = "button_style",
  parent = "slot_button",

  scalable = true,

  top_padding = 1,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 1,

  height = 40,
  width = 40,
}

-- Slot style for main recipe icon (40x40, scalable)
default_style.ACT2_recipe_slot = {
  type = "button_style",
  parent = "slot_button",

  scalable = true,

  top_padding = 1,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 1,

  height = 40,
  width = 40,
}

default_style.ACT2_vertical_flow = {
  type = "vertical_flow_style",
  vertical_spacing = 10,
  top_padding = 6,
}
-- Progress bar style with embedded text and thicker bar for belt throughput
default_style.ACT2_progressbar = {
  type = "progressbar_style",
  parent = "progressbar",

  height = 20,
  bar_width = 20,
  embed_text_in_bar = true,

  font = "default-bold",
  font_color = {1, 1, 1},
  filled_font_color = {0, 0, 0},

  horizontal_align = "center",
  vertical_align = "center",
}
-- Time mode cycle button style (Seconds / Minutes / Ticks)
default_style.ACT2_time_button = {
  type = "button_style",
  parent = "button",

  font = "default-bold",
  height = 24,
  left_padding = 8,
  right_padding = 8,
  top_padding = 0,
  bottom_padding = 0,
}
