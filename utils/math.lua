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
	return x + (input < 0.25 and 1 or 0) + (input < 0.025 and 1 or 0) + (input < 0.0025 and 1 or 0)
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

function ACTMath.getTimeModeTraits(mode)
	if mode == "minute" then
		return {
			mode = "minute",
			value = 60,
			time = { 'captions.perMin' },
			captions = 'captions.minutes',
			timeSuffix = "/min",
			nextMode = "tick",
			nextCaption = "Ticks (/tick)",
			buttonCaption = "Minutes (/min)"
		}
	elseif mode == "tick" then
		return {
			mode = "tick",
			value = 1 / 60,
			time = { 'captions.perTick' },
			captions = 'captions.ticks',
			timeSuffix = "/tick",
			nextMode = "second",
			nextCaption = "Seconds (/sec)",
			buttonCaption = "Ticks (/tick)"
		}
	else
		return {
			mode = "second",
			value = 1,
			time = { 'captions.perSec' },
			captions = 'captions.seconds',
			timeSuffix = "/sec",
			nextMode = "minute",
			nextCaption = "Minutes (/min)",
			buttonCaption = "Seconds (/sec)"
		}
	end
end

function ACTMath.determineMinOrSec(ACT2_time_second)
	if type(ACT2_time_second) == "string" then
		return ACTMath.getTimeModeTraits(ACT2_time_second)
	end
	if ACT2_time_second and ACT2_time_second.valid and ACT2_time_second.state then
		return ACTMath.getTimeModeTraits("second")
	else
		return ACTMath.getTimeModeTraits("minute")
	end
end

return ACTMath
