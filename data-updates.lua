-- Add extra input to all assemblers
for k, assm in pairs(data.raw["assembling-machine"]) do
	assm.ingredient_count = assm.ingredient_count + 1
end
-- data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 3
-- data.raw["assembling-machine"]["assembling-machine-2"].ingredient_count = 4
-- data.raw["assembling-machine"]["assembling-machine-3"].ingredient_count = 7
-- data.raw["assembling-machine"]["chemical-plant"].ingredient_count = 5
-- data.raw["assembling-machine"]["oil-refinery"].ingredient_count = 5

-- Add Assembly bots as input and output to all recipies (except smelting)
local toAdd = {}
for k, recipe in pairs(data.raw.recipe) do
if recipe.category ~= "smelting" and not string.match(recipe.name,"assembly%-bot") then
	if not recipe.name then 
		recipe.name = recipe[1]
		recipe.amount = recipe[2]
		recipe[1] = nil
		recipe[2] = nil
	end
	table.insert(recipe.ingredients,{type = "item", name = "assembly-bot", amount=1})
	if recipe.results then
		if not recipe.icon then
			local product = recipe.results[1]
			local thing
			if product.type == "item" then
				thing = data.raw.item[product.name]
			elseif product.type == "fluid" then
				thing = data.raw.fluid[product.name]
			end
			if thing.icon then
				recipe.icon = thing.icon
			else
				log("No icon found for for " .. product.name)
			end
		end
		if not recipe.subgroup then
			recipe.subgroup = "fluid-recipes"
		end
		table.insert(recipe.results,{type = "item", name = "used-assembly-bot", amount=1})
		table.insert(recipe.results,{type = "item", name = "assembly-bot", amount=1, probability=assemblybots.config.replication_factor})
	elseif recipe.result then
	-- transition from one output to multiple
		recipe.main_product = recipe.result
		local amount = 1
		if recipe.result_count ~= nil then
			amount = recipe.result_count
		end
		recipe.results = { { name = recipe.result, type = "item", amount = amount } }
		recipe.result = nil
		recipe.result_count = nil
		table.insert(recipe.results,{type = "item", name = "used-assembly-bot", amount=1})
		table.insert(recipe.results,{type = "item", name = "assembly-bot", amount=1, probability=assemblybots.config.replication_factor})
	end

	local production_recipe = util.table.deepcopy(recipe)
	production_recipe.name = recipe.name .. "-production"
	production_recipe.localised_name = recipe.localised_name
	production_recipe.enabled = false
	for ok, output in pairs(production_recipe.results) do
		if output.name ~= "assembly-bot" and output.name ~= "used-assembly-bot"	then
			output.amount_max = output.amount * 2
			output.amount_min = output.amount
			output.amount = nil
		end
	end
	for ik, input in pairs(production_recipe.ingredients) do
		if input.name == "assembly-bot" then input.amount = 2 end
	end
	table.insert(toAdd,production_recipe)

	local replication_recipe = util.table.deepcopy(recipe)
	replication_recipe.name = recipe.name .. "-replication"
	replication_recipe.localised_name = recipe.localised_name
	replication_recipe.enabled = false;
	for ok, output in pairs(replication_recipe.results) do
		if output.name == "assembly-bot" then
			output.probability = assemblybots.config.replication_mode_factor
		end
	end
	table.insert(toAdd,replication_recipe)

	local overdrive_recipe = util.table.deepcopy(recipe)
	overdrive_recipe.name = recipe.name .. "-overdrive"
	overdrive_recipe.localised_name = recipe.localised_name
	overdrive_recipe.enabled = false
	for ok, output in pairs(overdrive_recipe.results) do
		if output.name == "assembly-bot" then 
			output.probability = 1
		elseif output.name == "used-assembly-bot" then
			output.probability = assemblybots.config.overdrive_mode_factor
			output.name = "broken-assembly-bot"
		end
	end
	table.insert(toAdd,overdrive_recipe)
	
	local suppression_recipe = util.table.deepcopy(recipe)
	suppression_recipe.name = recipe.name .. "-suppression"
	suppression_recipe.localised_name = recipe.localised_name
	suppression_recipe.enabled = false
	local usedKey
	for ok, output in pairs(suppression_recipe.results) do
		if output.name == "assembly-bot" then 
			output.probability = 1
		elseif output.name ~= "used-assembly-bot" then
			output.probability = assemblybots.config.suppression_mode_factor
		elseif output.name == "used-assembly-bot" then
			usedKey = ok
		end
	end
	table.remove(suppression_recipe.results, ok)
	table.insert(toAdd,suppression_recipe)
end
end

for k = #toAdd, 1, -1 do
	data:extend({toAdd[k]})
end

-- Create copies of BotMode technologies with increasing costs
local techs = {}
techs["assemblybots-bot-normal"] = data.raw.technology["assemblybots-bot-normal-1"]
techs["assemblybots-bot-production"] = data.raw.technology["assemblybots-bot-production-1"]
techs["assemblybots-bot-overdrive"] = data.raw.technology["assemblybots-bot-overdrive-1"]
techs["assemblybots-bot-replication"] = data.raw.technology["assemblybots-bot-replication-1"]
techs["assemblybots-bot-suppression"] = data.raw.technology["assemblybots-bot-suppression-1"]
techs["assemblybots-bot-recharge1"] = data.raw.technology["assemblybots-bot-recharge1-1"]
techs["assemblybots-bot-recharge2"] = data.raw.technology["assemblybots-bot-recharge2-1"]
techs["assemblybots-bot-recharge3"] = data.raw.technology["assemblybots-bot-recharge3-1"]
for tk, tech in pairs(techs) do
-- base 50R 50G
--100R 100G
--200R 200G
--100R 100G 100B
--200R 200G 200B
--100R 100G 100B 100P
--200R 200G 200B 200P
	local packnum = 50
	for lvl = 2,7,1 do
		local newTech = util.table.deepcopy(tech)
		newTech.name = tk.."-"..lvl
		newTech.enabled = false
		if packnum < 200 then
			packnum = packnum * 2
		else
			packnum = 100
		end
		if lvl > 3 then	table.insert(newTech.unit.ingredients, {"science-pack-3", 1}) end
		if lvl > 5 then	table.insert(newTech.unit.ingredients, {"alien-science-pack", 1}) end
		newTech.unit.count = packnum
		data:extend({newTech})
	end
end
