local ACTMath = require("utils.math")
local ACTStorage = require("utils.storage")

local ACTBelts = {}

local KNOWN_BELT_COLORS = {
	["basic-transport-belt"] = { r = 0.15, g = 0.15, b = 0.15 },
	["transport-belt"] = { r = 0.98, g = 0.73, b = 0.0 },
	["fast-transport-belt"] = { r = 0.98, g = 0.27, b = 0.06 },
	["express-transport-belt"] = { r = 0.15, g = 0.67, b = 0.71 },
	["turbo-transport-belt"] = { r = 0.35, g = 0.76, b = 0.16 },
	["5d-mk4-transport-belt"] = { r = 0.08, g = 0.66, b = 0.14 },
	["kr-advanced-transport-belt"] = { r = 0.13, g = 0.92, b = 0.09 },
	["5d-mk5-transport-belt"] = { r = 0.89, g = 0.91, b = 0.96 },
	["ultimate-transport-belt"] = { r = 0.07, g = 1.0, b = 0.62 },
	["kr-superior-transport-belt"] = { r = 0.82, g = 0.00, b = 0.97 },
	["BetterBelts_ultra-transport-belt"] = { r = 0.22, g = 0.84, b = 0.11 },
}

-- Module-level cache for belt throughput data
local cachedBelts = nil
local beltMap = {}

local function initBelts()
	if cachedBelts then return end
	cachedBelts = {}
	beltMap = {}

	for name, proto in pairs(prototypes.entity) do
		if name:find("transport%-belt") and not name:find("ground") and proto.belt_speed then
			local speed = proto.belt_speed
			local throughput = (60 * speed) / (1 / 8) -- 8 items per tile * 60 ticks * belt_speed
			local color = KNOWN_BELT_COLORS[name] or { r = 0.8, g = 0.8, b = 0.8 }
			local entry = {
				name = name,
				throughput = throughput,
				color = color,
				proto = proto,
			}
			table.insert(cachedBelts, entry)
			beltMap[name] = throughput
		end
	end

	-- Sort belts by throughput ascending
	table.sort(cachedBelts, function(a, b)
		return a.throughput < b.throughput
	end)
end

function ACTBelts.findPrototypeData(playerName)
	initBelts()
end

function ACTBelts.getForceBeltStackSize(playerName)
	if not playerName then return 1 end
	local player = game.players[playerName]
	if player and player.valid and player.force and player.force.belt_stack_size_bonus then
		return 1 + player.force.belt_stack_size_bonus
	end
	return 1
end

local function getBeltLocalisedName(beltName)
	if prototypes.item[beltName] then
		return prototypes.item[beltName].localised_name
	elseif prototypes.entity[beltName] then
		return prototypes.entity[beltName].localised_name
	end
	return beltName
end

local function findBeltForThroughput(rate, stack)
	stack = stack or 1
	for _, beltData in ipairs(cachedBelts) do
		local capacity = beltData.throughput * stack
		if rate <= capacity then
			return beltData.name, beltData.color, (rate / capacity), true
		end
	end
	local maxBelt = cachedBelts[#cachedBelts]
	return maxBelt.name, { r = 1, g = 1, b = 1 }, (rate / (maxBelt.throughput * stack)), false
end

local function formatBeltUsage(beltName, val, fits, stack)
	local stackSuffix = ""
	if stack and stack > 1 then
		stackSuffix = " (x" .. tostring(stack) .. " stack)"
	end
	if fits then
		local pct = tostring(ACTMath.truncateNumber(val * 100, 1)) .. "%"
		return { "", pct, " of ", getBeltLocalisedName(beltName), stackSuffix }
	else
		local count = tostring(ACTMath.truncateNumber(val, 2)) .. "x "
		return { "", count, getBeltLocalisedName(beltName), stackSuffix }
	end
end

function ACTBelts.pbarTraits(IPS, playerName, stackOverride)
	IPS = tonumber(IPS) or 0
	initBelts()

	if #cachedBelts == 0 then
		return {
			belt = "transport-belt",
			color = { r = 1, g = 1, b = 1 },
			value = 0,
			tool = "",
			caption = "0%",
			font_color = { 1, 1, 1 },
			stack_size = 1,
			max_stack_size = 1
		}
	end

	local maxStack = ACTBelts.getForceBeltStackSize(playerName)
	local activeStack = 1

	if stackOverride and stackOverride > 1 then
		activeStack = stackOverride
	elseif maxStack > 1 then
		activeStack = ACTStorage.getBeltStackValue(playerName, maxStack)
	end

	local activeBelt, activeColor, activeVal, activeFits = findBeltForThroughput(IPS, activeStack)

	local primaryLine = nil
	if activeStack == 1 then
		if activeFits then
			primaryLine = { "tooltips.percent-of", tostring(ACTMath.truncateNumber(activeVal * 100, 2)), getBeltLocalisedName(activeBelt) }
		else
			primaryLine = { '', tostring(ACTMath.truncateNumber(activeVal, 2)), " ", getBeltLocalisedName(activeBelt) }
		end
	else
		primaryLine = formatBeltUsage(activeBelt, activeVal, activeFits, activeStack)
	end

	local fullTooltip = primaryLine
	if maxStack > 1 then
		fullTooltip = { "", primaryLine }
		if activeStack ~= 1 then
			local unstackedBelt, _, unstackedVal, unstackedFits = findBeltForThroughput(IPS, 1)
			table.insert(fullTooltip, "\n• Unstacked (1x): ")
			table.insert(fullTooltip, formatBeltUsage(unstackedBelt, unstackedVal, unstackedFits, 1))
		end
		if activeStack ~= maxStack then
			local maxBelt, _, maxVal, maxFits = findBeltForThroughput(IPS, maxStack)
			table.insert(fullTooltip, "\n• Max Stack (x" .. tostring(maxStack) .. "): ")
			table.insert(fullTooltip, formatBeltUsage(maxBelt, maxVal, maxFits, maxStack))
		end
	end

	local barCaption = ""
	local fontColor = { 1, 1, 1 }

	if activeFits then
		local pct = activeVal * 100
		local pctStr = ""
		if pct >= 10 then
			pctStr = tostring(ACTMath.truncateNumber(pct, 1)) .. "%"
		elseif pct >= 1 then
			pctStr = tostring(ACTMath.truncateNumber(pct, 1)) .. "%"
		elseif pct > 0 then
			pctStr = tostring(ACTMath.truncateNumber(pct, 2)) .. "%"
		else
			pctStr = "0%"
		end

		if activeStack > 1 then
			barCaption = pctStr .. " (x" .. tostring(activeStack) .. ")"
		elseif maxStack > 1 then
			barCaption = pctStr .. " (x1)"
		else
			barCaption = pctStr
		end
		fontColor = { 1, 1, 1 }
	else
		local valStr = tostring(ACTMath.truncateNumber(activeVal, 2)) .. " belts"
		if activeStack > 1 then
			barCaption = valStr .. " (x" .. tostring(activeStack) .. ")"
		elseif maxStack > 1 then
			barCaption = valStr .. " (x1)"
		else
			barCaption = valStr
		end
		fontColor = { 0.1, 0.1, 0.1 }
	end

	return {
		belt = activeBelt,
		color = activeColor,
		value = math.min(1, activeVal),
		tool = fullTooltip,
		caption = barCaption,
		font_color = fontColor,
		stack_size = activeStack,
		max_stack_size = maxStack
	}
end

return ACTBelts
