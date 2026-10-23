local ACTMath = require("utils.math")
local ACTStorage = require("utils.storage")
local ACTIngredient = require("scripts.ingredients.ingredient")
local ACTProduct = require("scripts.products.product")

local ACTRecipe = {}

local function copyProductsForWriteControl(recipe)
	local products = {}
	if not recipe or not recipe.products then return products end

	for p, o in pairs(recipe.products) do
		products[p] = {}
		for l, k in pairs(o) do
			products[p][l] = k
		end
	end

	if recipe.ingredients then
		for _, recipeIngredient in pairs(recipe.ingredients) do
			for _, recipeProduct in pairs(products) do
				local productAmount = recipeProduct.amount or ACTMath.amountMaxMinAverage(recipeProduct) or 1
				local ingredientAmount = recipeIngredient.amount or ACTMath.amountMaxMinAverage(recipeIngredient) or 1
				if recipeProduct.name == recipeIngredient.name and productAmount >= ingredientAmount then
					if recipeProduct.amount then
						recipeProduct.amount = productAmount - ingredientAmount
					elseif recipeProduct.amount_max and recipeProduct.amount_min and recipeIngredient.amount_max and recipeIngredient.amount_min then
						recipeProduct.amount_max = recipeProduct.amount_max - recipeIngredient.amount_max
						recipeProduct.amount_min = recipeProduct.amount_min - recipeIngredient.amount_min
					end
				end
			end
		end
	end
	return products
end

ACTRecipe.copyProductsForWriteControl = copyProductsForWriteControl

function ACTRecipe.desiredEntity(entity)
	if not entity or not entity.valid then return false end
	local entityType = entity.type
	if entityType:find("assembling%-machine") or
		(entityType:find("furnace") and not entity.name:find("reverse")) or
		entityType:find("rocket%-silo") or
		entityType:find("lab") or
		entityType:find("mining%-drill") then
		return true
	end
	return false
end

local function getEffects(entity)
	local effects = {
		consumption = { bonus = 0.0 },
		speed = { bonus = 0.0 },
		productivity = { bonus = 0.0 },
		pollution = { bonus = 0.0 },
		quality = { bonus = 0.0 }
	}
	if entity and entity.valid and entity.effects then
		if entity.effects.speed then
			effects.speed.bonus = entity.effects.speed
		end
		if entity.effects.productivity and entity.effects.productivity > 0 then
			effects.productivity.bonus = entity.effects.productivity
		end
		if entity.effects.consumption then
			effects.consumption.bonus = entity.effects.consumption
		end
		if entity.effects.pollution then
			effects.pollution.bonus = entity.effects.pollution
		end
		if entity.effects.quality and entity.effects.quality > 0 then
			effects.quality.bonus = entity.effects.quality
		end
	end
	return effects
end

local function getRecipeProductivityBonus(recipe, force)
	if not recipe then return 0 end
	if recipe.object_name == "LuaRecipe" then
		return recipe.productivity_bonus or 0
	end
	if force and force.valid and force.recipes and recipe.name then
		local ok, forceRecipe = pcall(function() return force.recipes[recipe.name] end)
		if ok and forceRecipe and forceRecipe.valid and forceRecipe.object_name == "LuaRecipe" then
			return forceRecipe.productivity_bonus or 0
		end
	end
	return 0
end

local function getRecipeFromEntity(entity, playerName)
	if entity.type:find("assembling%-machine") or entity.type:find("rocket%-silo") then
		local recipe = entity.get_recipe()
		if recipe then
			local recipeBonus = getRecipeProductivityBonus(recipe, entity.force)
			local recipeProducts = copyProductsForWriteControl(recipe)
			ACTStorage.globalSliderStorage(playerName, recipe.name)
			local effects = getEffects(entity)
			local sec = recipe.energy / entity.crafting_speed
			local isCapped = (sec < (1 / 60))

			return {
				name = recipe.name,
				localised_name = recipe.localised_name,
				ingredients = ACTIngredient.expandIngredients(recipe.ingredients, sec, playerName, recipe.name),
				products = ACTProduct.expandProducts(recipeProducts, sec, playerName, effects, recipe.name, recipeBonus),
				seconds = sec,
				effects = effects,
				is_capped = isCapped
			}
		end
	end
	return nil
end

local function getRecipeFromFurnace(entity, playerName)
	if entity.type:find("furnace") then
		local recipe = entity.get_recipe()

		-- Fallback to previous recipe if idle or between items
		if not recipe and entity.previous_recipe then
			local prev = entity.previous_recipe
			local prevName = (type(prev) == "table" and (prev.name or prev.recipe)) or (type(prev) == "string" and prev) or nil
			if type(prevName) == "string" then
				if entity.force and entity.force.recipes[prevName] then
					recipe = entity.force.recipes[prevName]
				elseif prototypes.recipe[prevName] then
					recipe = prototypes.recipe[prevName]
				end
			end
		end

		-- Check input slot (furnace_source / crafter_input) for items waiting to be processed (e.g. in recyclers)
		if not recipe then
			local invId = defines.inventory.crafter_input or defines.inventory.furnace_source
			local sourceInv = invId and entity.get_inventory(invId)
			if sourceInv and sourceInv.valid and not sourceInv.is_empty() then
				local contents = sourceInv.get_contents()
				if contents then
					for _, itemInfo in pairs(contents) do
						local itemName = (type(itemInfo) == "table" and itemInfo.name) or itemInfo
						if itemName then
							local rName = itemName
							if entity.name:find("recycler") then
								rName = itemName .. "-recycling"
							end
							if entity.force and entity.force.recipes and entity.force.recipes[rName] then
								recipe = entity.force.recipes[rName]
								break
							elseif prototypes.recipe[rName] then
								recipe = prototypes.recipe[rName]
								break
							end
						end
					end
				end
			end
		end

		if recipe then
			if recipe.object_name ~= "LuaRecipe" and entity.force and entity.force.recipes and recipe.name then
				local ok, forceRecipe = pcall(function() return entity.force.recipes[recipe.name] end)
				if ok and forceRecipe and forceRecipe.valid then
					recipe = forceRecipe
				end
			end
			local recipeBonus = getRecipeProductivityBonus(recipe, entity.force)
			ACTStorage.globalSliderStorage(playerName, recipe.name)
			local effects = getEffects(entity)
			local sec = recipe.energy / entity.crafting_speed
			local isCapped = (sec < (1 / 60))
			local recipeProducts = copyProductsForWriteControl(recipe)

			return {
				name = recipe.name,
				localised_name = recipe.localised_name,
				ingredients = ACTIngredient.expandIngredients(recipe.ingredients, sec, playerName, recipe.name),
				products = ACTProduct.expandProducts(recipeProducts, sec, playerName, effects, recipe.name, recipeBonus),
				seconds = sec,
				effects = effects,
				is_capped = isCapped
			}
		end
	end
	return nil
end

local function getRecipeFromFurnaceOutput(entity, playerName)
	if entity.type:find("furnace") and not entity.name:find("recycler") then
		local invId = defines.inventory.crafter_output or defines.inventory.furnace_result
		local outputInv = (entity.get_output_inventory and entity.get_output_inventory()) or (invId and entity.get_inventory(invId))
		if outputInv and outputInv.valid then
			local contents = outputInv.get_contents()
			if contents then
				for _, itemInfo in pairs(contents) do
					local itemName = (type(itemInfo) == "table" and itemInfo.name) or itemInfo
					if itemName then
						local recipe = nil
						if entity.force and entity.force.recipes and entity.force.recipes[itemName] then
							recipe = entity.force.recipes[itemName]
						elseif prototypes.recipe[itemName] then
							recipe = prototypes.recipe[itemName]
						end
						if recipe then
							local recipeBonus = getRecipeProductivityBonus(recipe, entity.force)
							ACTStorage.globalSliderStorage(playerName, recipe.name)
							local effects = getEffects(entity)
							local sec = recipe.energy / entity.crafting_speed
							local isCapped = (sec < (1 / 60))
							local recipeProducts = copyProductsForWriteControl(recipe)

							return {
								name = recipe.name,
								localised_name = recipe.localised_name,
								ingredients = ACTIngredient.expandIngredients(recipe.ingredients, sec, playerName, recipe.name),
								products = ACTProduct.expandProducts(recipeProducts, sec, playerName, effects, recipe.name, recipeBonus),
								seconds = sec,
								effects = effects,
								is_capped = isCapped
							}
						end
					end
				end
			end
		end
	end
	return nil
end

local function getRecipeFromLab(entity, playerName)
	if entity.type:find("lab") then
		local research = entity.force.current_research
		if research then
			ACTStorage.globalSliderStorage(playerName, research.name)
			local effects = getEffects(entity)

			local baseSpeed = 1
			if entity.prototype.get_researching_speed then
				baseSpeed = entity.prototype.get_researching_speed(entity.quality) or 1
			end
			local forceModifier = (entity.force.laboratory_speed_modifier or 0) + 1
			local speedEffect = (effects.speed.bonus or 0) + 1
			local totalSpeed = baseSpeed * forceModifier * speedEffect

			local sec = (research.research_unit_energy / 60) / totalSpeed
			local isCapped = (sec < (1 / 60))

			return {
				name = research.name,
				localised_name = research.localised_name,
				ingredients = ACTIngredient.expandIngredients(research.research_unit_ingredients, sec, playerName, research.name),
				seconds = sec,
				effects = effects,
				is_capped = isCapped
			}
		end
	end
	return nil
end

local function getRecipeFromMiningTarget(entity, playerName)
	if entity.type:find("mining%-drill") then
		local miningTarget = entity.mining_target
		if miningTarget and miningTarget.valid then
			ACTStorage.globalSliderStorage(playerName, miningTarget.name)
			local effects = getEffects(entity)
			local mineable = miningTarget.prototype.mineable_properties
			local miningTime = mineable and mineable.mining_time or 1
			local miningSpeed = entity.prototype.mining_speed or 1
			local speedMultiplier = (effects.speed.bonus or 0) + 1
			local sec = miningTime / (miningSpeed * speedMultiplier)
			local isCapped = (sec < (1 / 60))

			local recipe = {
				name = miningTarget.name,
				localised_name = miningTarget.localised_name,
				products = ACTProduct.expandProductsMines(mineable.products, sec, playerName, effects, miningTarget.name, entity),
				seconds = sec,
				effects = effects,
				is_capped = isCapped
			}

			if mineable.fluid_amount and mineable.required_fluid then
				recipe.ingredients = ACTIngredient.expandIngredients(
					{ {
						name = mineable.required_fluid,
						amount = mineable.fluid_amount / 10,
						type = "fluid"
					} },
					sec, playerName, miningTarget.name
				)
			end
			return recipe
		end
	end
	return nil
end

function ACTRecipe.getRecipe(entity, playerName)
	if not entity or not entity.valid then return nil end
	return getRecipeFromEntity(entity, playerName) or
		getRecipeFromFurnace(entity, playerName) or
		getRecipeFromFurnaceOutput(entity, playerName) or
		getRecipeFromLab(entity, playerName) or
		getRecipeFromMiningTarget(entity, playerName) or
		nil
end

return ACTRecipe
