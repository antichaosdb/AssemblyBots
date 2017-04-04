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
		table.insert(recipe.results,{type = "item", name = "assembly-bot", amount=1, probability=0.1})
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
		table.insert(recipe.results,{type = "item", name = "assembly-bot", amount=1, probability=0.1})
	end

	local production_recipe = util.table.deepcopy(recipe)
	log("Creating recipe " .. production_recipe.name)
	production_recipe.localised_name = recipe.name
	production_recipe.enabled = false
	for ok, output in pairs(production_recipe.results) do
		if output.name ~= "assembly-bot" and output.name ~= "used-assembly-bot"	then
			output.amount = output.amount * 2
		end
	end
	for ik, input in pairs(production_recipe.ingredients) do
		if input.name == "assembly-bot" then input.amount = 2 end
	end
	table.insert(toAdd,production_recipe)

	local replication_recipe = util.table.deepcopy(recipe)
	replication_recipe.name = recipe.name .. "-replication"
	replication_recipe.localised_name = recipe.name
	replication_recipe.enabled = false;
	for ok, output in pairs(replication_recipe.results) do
		if output.name == "assembly-bot" then
			output.probability = 0.5
		end
	end
	table.insert(toAdd,replication_recipe)

	local overdrive_recipe = util.table.deepcopy(recipe)
	overdrive_recipe.name = recipe.name .. "-overdrive"
	overdrive_recipe.localised_name = recipe.name
	overdrive_recipe.enabled = false
	for ok, output in pairs(overdrive_recipe.results) do
		if output.name == "assembly-bot" then 
			output.probability = 1
		elseif output.name == "used-assembly-bot" then
			output.probability = 0.05
			output.name = "broken-assembly-bot"
		end
	end
	table.insert(toAdd,overdrive_recipe)
end
end

for k = #toAdd, 1, -1 do
	data:extend({toAdd[k]})
end