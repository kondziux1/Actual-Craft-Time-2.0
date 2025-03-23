data:extend({
	{
		type = "string-setting",
		name = "ACT2-Gui-Location",
		setting_type = "runtime-per-user",
		default_value = "top",
		allowed_values = { "top", "left" }
	},
	{
		type = "bool-setting",
		name = "ACT2-simple-text",
		setting_type = "runtime-per-user",
		default_value = false
	},
	{
		type = "int-setting",
		name = "ACT2-max-slider-value",
		setting_type = "runtime-per-user",
		minimum_value = 25,
		default_value = 200
	},
	{
		type = "int-setting",
		name = "ACT2-slider-sensitivity",
		setting_type = "runtime-per-user",
		minimum_value = 1,
		default_value = 5,
		maximum_value = 10
	}
})
