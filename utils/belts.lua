local ACTMath = require("utils.math")

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

local function getBeltLocalisedName(beltName)
	if prototypes.item[beltName] then
		return prototypes.item[beltName].localised_name
	elseif prototypes.entity[beltName] then
		return prototypes.entity[beltName].localised_name
	end
	return beltName
end

function ACTBelts.pbarTraits(IPS, playerName)
	IPS = tonumber(IPS) or 0
	initBelts()

	if #cachedBelts == 0 then
		return {
			belt = "transport-belt",
			color = { r = 1, g = 1, b = 1 },
			value = 0,
			tool = ""
		}
	end

	-- Find the first belt that can handle this IPS
	for _, beltData in ipairs(cachedBelts) do
		if IPS <= beltData.throughput then
			local belt = beltData.name
			local color = beltData.color
			local value = IPS / beltData.throughput
			local tool = {
				"tooltips.percent-of",
				tostring(ACTMath.truncateNumber(value * 100, 2)),
				getBeltLocalisedName(belt)
			}
			return { belt = belt, color = color, value = value, tool = tool }
		end
	end

	-- If IPS exceeds all belt speeds, use the fastest belt available (or express belt) as multiple
	local maxBelt = cachedBelts[#cachedBelts]
	local belt = maxBelt.name
	local color = { r = 1, g = 1, b = 1 } -- white for overflow
	local value = IPS / maxBelt.throughput
	local tool = {
		'',
		tostring(ACTMath.truncateNumber(value, 2)),
		" ",
		getBeltLocalisedName(belt)
	}
	return { belt = belt, color = color, value = value, tool = tool }
end

return ACTBelts
