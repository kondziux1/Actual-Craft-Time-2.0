local ACTMath = {}

function ACTMath.truncateNumber(nu, digit)
	if not nu then return 0 end
	digit = digit or 0
	local mult = 10 ^ digit
	return (nu * mult - (nu * mult % 1)) / mult
end

function ACTMath.conditionalDecimalIncrease(input, x)
	input = input or 0
	x = x or 0
	return x + (input < 0.25 and 1 or 0) + (input < 0.025 and 1 or 0)
end

function ACTMath.amountFromPumpjack(entity)
	if entity and entity.valid and entity.name and entity.name:find("pumpjack") then
		if entity.mining_target and entity.mining_target.valid then
			return (entity.mining_target.amount / 30000)
		end
	end
	return nil
end

function ACTMath.amountMaxMinAverage(product)
	if not product then return nil end
	local max = product.amount_max
	local min = product.amount_min
	return (max and min) and (max + min) * 0.5 or nil
end

function ACTMath.determineMinOrSec(ACT2_time_second)
	if ACT2_time_second and ACT2_time_second.valid and ACT2_time_second.state then
		return { value = 1, time = { 'captions.perSec' }, captions = 'captions.seconds' }
	else
		return { value = 60, time = { 'captions.perMin' }, captions = 'captions.minutes' }
	end
end

return ACTMath
