local ACTMath = require("utils.math")
local ACTLocalisation = require("utils.localisation")
local ACTBelts = require("utils.belts")
local ACTStorage = require("utils.storage")

local ACTProduct = {}

function ACTProduct.expandProducts(products, sec, playerName, effects, recipeName, recipeBonus)
	if not playerName or not products then return {} end
	local productTable = {}

	local sliderValue = 1
	if storage.ACT2_slider and storage.ACT2_slider[playerName] and storage.ACT2_slider[playerName][recipeName] then
		sliderValue = storage.ACT2_slider[playerName][recipeName].value or 1
	end

	local prodBonus = 0
	if effects and effects.productivity and effects.productivity.bonus then
		prodBonus = effects.productivity.bonus
	end
	if recipeBonus then
		prodBonus = prodBonus + recipeBonus
	end

	local craftTime = math.max(sec, 1 / 60)

	for k, product in pairs(products) do
		local amount = product.amount or ACTMath.amountMaxMinAverage(product) or 1
		local probability = product.probability or 1
		local expectedAmount = probability * amount

		local IPS_main = expectedAmount / craftTime
		local IPS_productivity = (expectedAmount * prodBonus) / sec
		local IPS = IPS_main + IPS_productivity

		local itemEntry = {
			name = product.name,
			type = product.type or "item",
			amount = amount,
			probability = product.probability,
			localised_name = ACTLocalisation.getLocalisedName(product.name),
			ips = IPS,
			pbar = ACTBelts.pbarTraits(IPS * sliderValue, playerName),
		}
		productTable[k] = itemEntry
	end

	-- Vanilla Factorio without Space Age generates space science packs on rocket launch
	if recipeName == "rocket-part" and not script.active_mods["space-age"] then
		local expectedAmount = 10
		local IPS_main = expectedAmount / craftTime
		local IPS_productivity = (expectedAmount * prodBonus) / sec
		local IPS = IPS_main + IPS_productivity

		table.insert(productTable, {
			amount = 10,
			name = "space-science-pack",
			type = "item",
			localised_name = ACTLocalisation.getLocalisedName("space-science-pack"),
			ips = IPS,
			pbar = ACTBelts.pbarTraits(IPS * sliderValue, playerName),
		})
	end

	return productTable
end

function ACTProduct.expandProductsMines(products, sec, playerName, effects, recipeName, entity)
	if not playerName or not products then return {} end
	local player = game.players[playerName]
	if not player or not player.valid then return {} end

	local productTable = {}
	local playerForce = player.force

	local sliderValue = 1
	if storage.ACT2_slider and storage.ACT2_slider[playerName] and storage.ACT2_slider[playerName][recipeName] then
		sliderValue = storage.ACT2_slider[playerName][recipeName].value or 1
	end

	local prodBonus = 0
	if effects and effects.productivity and effects.productivity.bonus then
		prodBonus = effects.productivity.bonus
	end
	if playerForce and playerForce.mining_drill_productivity_bonus then
		prodBonus = prodBonus + playerForce.mining_drill_productivity_bonus
	end

	local craftTime = math.max(sec, 1 / 60)

	for k, product in pairs(products) do
		local amount = ACTMath.amountFromPumpjack(entity) or product.amount or ACTMath.amountMaxMinAverage(product) or 1
		local probability = product.probability or 1
		local expectedAmount = probability * amount

		local IPS_main = expectedAmount / craftTime
		local IPS_productivity = (expectedAmount * prodBonus) / sec
		local IPS = IPS_main + IPS_productivity

		local itemEntry = {
			name = product.name,
			type = product.type or "item",
			amount = amount,
			probability = product.probability,
			localised_name = ACTLocalisation.getLocalisedName(product.name),
			ips = IPS,
			pbar = ACTBelts.pbarTraits(IPS * sliderValue, playerName),
		}
		productTable[k] = itemEntry
	end

	return productTable
end

return ACTProduct
