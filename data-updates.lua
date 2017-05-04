function update_recipe(recipeVersion)
	table.insert(recipeVersion.ingredients,{type = "item", name = "assembly-bot", amount=1})
	if recipeVersion.results then
		recipeVersion.main_product = recipeVersion.results[1].name
		-- if not recipeVersion.icon and not recipeVersion.icons then
			-- local product = recipeVersion.results[1]
			-- local thing
			-- if product.type == "item" then
				-- thing = data.raw.item[product.name]
			-- elseif product.type == "fluid" then
				-- thing = data.raw.fluid[product.name]
			-- end
			-- if thing.icon then
				-- recipeVersion.icon = thing.icon
				-- log("No icon found for " .. product.name)
			-- end
		-- end
		table.insert(recipeVersion.results,{type = "item", name = "used-assembly-bot", amount=1})
		table.insert(recipeVersion.results,{type = "item", name = "assembly-bot", amount=1, probability=assemblybots.config.replication_factor})
	elseif recipeVersion.result then
	-- transition from one output to multiple
		recipeVersion.main_product = recipeVersion.result
		local amount = 1
		if recipeVersion.result_count ~= nil then
			amount = recipeVersion.result_count
		end
		recipeVersion.results = { { name = recipeVersion.result, type = "item", amount = amount } }
		recipeVersion.result = nil
		recipeVersion.result_count = nil
		table.insert(recipeVersion.results,{type = "item", name = "used-assembly-bot", amount=1})
		table.insert(recipeVersion.results,{type = "item", name = "assembly-bot", amount=1, probability=assemblybots.config.replication_factor})
	end
end

function update_production_recipe(production_recipeVersion)
	production_recipeVersion.enabled = false
	for ok, output in pairs(production_recipeVersion.results) do
		if output.name ~= "assembly-bot" and output.name ~= "used-assembly-bot"	then
			output.amount_max = output.amount * 2
			output.amount_min = output.amount
			output.amount = nil
		end
	end
	for ik, input in pairs(production_recipeVersion.ingredients) do
		if input.name == "assembly-bot" then input.amount = 2 end
	end
end

function update_replication_recipe(replication_recipe)
	replication_recipe.enabled = false;
	for ok, output in pairs(replication_recipe.results) do
		if output.name == "assembly-bot" then
			output.probability = assemblybots.config.replication_mode_factor
		end
	end
end

function update_overdrive_recipe(overdrive_recipe)
	overdrive_recipe.enabled = false
	for ok, output in pairs(overdrive_recipe.results) do
		if output.name == "assembly-bot" then 
			output.probability = 1
		elseif output.name == "used-assembly-bot" then
			output.probability = assemblybots.config.overdrive_mode_factor
			output.name = "broken-assembly-bot"
		end
	end
end

function update_suppression_recipe(suppression_recipe)
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
end

-- Add extra input to all assemblers
for k, assm in pairs(data.raw["assembling-machine"]) do
	assm.ingredient_count = assm.ingredient_count + 1
end

-- Unlock long-handed-filter-inserter with electronics
table.insert(data.raw.technology["electronics"].effects, {type="unlock-recipe", recipe="long-filter-inserter"})

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
		if recipe.normal then
			update_recipe(recipe.normal)
			recipe.main_product = recipe.normal.main_product
		else
			update_recipe(recipe)
		end
		if recipe.expensive then
			update_recipe(recipe.expensive)
			recipe.main_product = recipe.expensive.main_product
		end
		if not recipe.main_product and not recipe.subgroup then
			recipe.subgroup = "fluid-recipes"
		end
		
		local production_recipe = util.table.deepcopy(recipe)
		production_recipe.name = recipe.name .. "-production"
		production_recipe.localised_name = recipe.localised_name	
		if production_recipe.normal then
			update_production_recipe(production_recipe.normal)
		else
			update_production_recipe(production_recipe)
		end
		if production_recipe.expensive then
			update_production_recipe(production_recipe.expensive)
		end
		table.insert(toAdd,production_recipe)

		local replication_recipe = util.table.deepcopy(recipe)
		replication_recipe.name = recipe.name .. "-replication"
		replication_recipe.localised_name = recipe.localised_name
		if replication_recipe.normal then
			update_replication_recipe(replication_recipe.normal)
		else
			update_replication_recipe(replication_recipe)
		end
		if replication_recipe.expensive then
			update_replication_recipe(replication_recipe.expensive)
		end
		table.insert(toAdd,replication_recipe)

		local overdrive_recipe = util.table.deepcopy(recipe)
		overdrive_recipe.name = recipe.name .. "-overdrive"
		overdrive_recipe.localised_name = recipe.localised_name
		if overdrive_recipe.normal then
			update_overdrive_recipe(overdrive_recipe.normal)
		else
			update_overdrive_recipe(overdrive_recipe)
		end
		if overdrive_recipe.expensive then
			update_overdrive_recipe(overdrive_recipe.expensive)
		end
		table.insert(toAdd,overdrive_recipe)
		
		local suppression_recipe = util.table.deepcopy(recipe)
		suppression_recipe.name = recipe.name .. "-suppression"
		suppression_recipe.localised_name = recipe.localised_name
		if suppression_recipe.normal then
			update_suppression_recipe(suppression_recipe.normal)
		else
			update_suppression_recipe(suppression_recipe)
		end
		if suppression_recipe.expensive then
			update_suppression_recipe(suppression_recipe.expensive)
		end
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
local packs = {"science-pack-2","science-pack-3","military-science-pack","production-science-pack","high-tech-science-pack","space-science-pack"}
for tk, tech in pairs(techs) do
	local newTech = util.table.deepcopy(tech)
	for idx,pack in pairs(packs) do	
		newTech.name = tk.."-"..(idx + 1)
		newTech.enabled = false
		table.insert(newTech.unit.ingredients, {pack, 1})
		data:extend({newTech})
		newTech = util.table.deepcopy(newTech)
	end
end
