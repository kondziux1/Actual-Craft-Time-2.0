local ACTMath = require("utils.math")
local ACTLocalisation = require("utils.localisation")
local ACTBelts = require("utils.belts")
local ACTStorage = require("utils.storage")

local ACTProduct = {}

local function getProductProbability(product)
	if not product then return 1 end
	local prob = 1
	local hasProbability = false

	-- Factorio 2.1+: independent_probability replaces probability
	if product.independent_probability ~= nil then
		prob = prob * product.independent_probability
		hasProbability = true
	end

	-- Factorio 2.1+: shared_probability defines range [min, max)
	if product.shared_probability ~= nil then
		hasProbability = true
		if type(product.shared_probability) == "table" then
			local sMin = product.shared_probability.min or 0
			local sMax = product.shared_probability.max or 1
			prob = prob * math.max(0, sMax - sMin)
		elseif type(product.shared_probability) == "number" then
			prob = prob * product.shared_probability
		end
	end

	-- Factorio 2.0 fallback
	if not hasProbability then
		local ok, p = pcall(function() return product.probability end)
		if ok and p ~= nil then
			prob = p
		end
	end

	return prob
end

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

	local qualityBonus = 0
	if effects and effects.quality and effects.quality.bonus then
		qualityBonus = effects.quality.bonus
	end

	local craftTime = math.max(sec, 1 / 60)

	for k, product in pairs(products) do
		local amount = product.amount or ACTMath.amountMaxMinAverage(product) or 1
		local probability = getProductProbability(product)
		local expectedAmount = probability * amount

		local IPS_main = expectedAmount / craftTime
		local IPS_productivity = (expectedAmount * prodBonus) / sec
		local IPS = IPS_main + IPS_productivity

		local itemEntry = {
			name = product.name,
			type = product.type or "item",
			amount = amount,
			probability = probability,
			localised_name = ACTLocalisation.getLocalisedName(product.name),
			ips = IPS,
			pbar = ACTBelts.pbarTraits(IPS * sliderValue, playerName),
			quality_chance = qualityBonus,
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
			quality_chance = qualityBonus,
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

	local qualityBonus = 0
	if effects and effects.quality and effects.quality.bonus then
		qualityBonus = effects.quality.bonus
	end

	local craftTime = math.max(sec, 1 / 60)

	for k, product in pairs(products) do
		local amount = ACTMath.amountFromPumpjack(entity) or product.amount or ACTMath.amountMaxMinAverage(product) or 1
		local probability = getProductProbability(product)
		local expectedAmount = probability * amount

		local IPS_main = expectedAmount / craftTime
		local IPS_productivity = (expectedAmount * prodBonus) / sec
		local IPS = IPS_main + IPS_productivity

		local itemEntry = {
			name = product.name,
			type = product.type or "item",
			amount = amount,
			probability = probability,
			localised_name = ACTLocalisation.getLocalisedName(product.name),
			ips = IPS,
			pbar = ACTBelts.pbarTraits(IPS * sliderValue, playerName),
			quality_chance = qualityBonus,
		}
		productTable[k] = itemEntry
	end

	return productTable
end

return ACTProduct
