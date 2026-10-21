local ACTMath = require("utils.math")
local ACTLocalisation = require("utils.localisation")
local ACTBelts = require("utils.belts")
local ACTStorage = require("utils.storage")

local ACTIngredient = {}

function ACTIngredient.expandIngredients(ingredients, sec, playerName, recipeName)
	if not playerName or not ingredients then return {} end
	local ingredientTable = {}
	local sliderValue = 1
	if storage.ACT2_slider and storage.ACT2_slider[playerName] and storage.ACT2_slider[playerName][recipeName] then
		sliderValue = storage.ACT2_slider[playerName][recipeName].value or 1
	end

	local craftTime = math.max(sec, 1 / 60)

	for k, ingredient in pairs(ingredients) do
		local amount = ingredient.amount or ACTMath.amountMaxMinAverage(ingredient) or 1
		local IPS = amount / craftTime
		local itemEntry = {
			name = ingredient.name,
			type = ingredient.type or "item",
			amount = amount,
			localised_name = ACTLocalisation.getLocalisedName(ingredient.name),
			ips = IPS,
			pbar = ACTBelts.pbarTraits(IPS * sliderValue, playerName),
		}
		ingredientTable[k] = itemEntry
	end
	return ingredientTable
end

return ACTIngredient
