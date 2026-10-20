local ACTLocalisation = {}

function ACTLocalisation.getLocalisedName(name)
	if not name then return "" end
	if prototypes.recipe[name] then
		return prototypes.recipe[name].localised_name
	end
	if prototypes.entity[name] then
		return prototypes.entity[name].localised_name
	end
	if prototypes.fluid[name] then
		return prototypes.fluid[name].localised_name
	end
	if prototypes.item[name] then
		return prototypes.item[name].localised_name
	end
	return name
end

return ACTLocalisation
