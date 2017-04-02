-- Add extra input to all assemblers
data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 3
data.raw["assembling-machine"]["assembling-machine-2"].ingredient_count = 4
data.raw["assembling-machine"]["assembling-machine-3"].ingredient_count = 7
data.raw["assembling-machine"]["chemical-plant"].ingredient_count = 5

-- Add Assembly bots as inout and output to all recipies (except smelting)
for k, recipe in pairs(data.raw.recipe) do
if recipe.category ~= "smelting" and not string.match(recipe.name,"assembly-bot") then
	if not recipe.name then 
		recipe.name = recipe[1]
		recipe.amount = recipe[2]
		recipe[1] = nil
		recipe[2] = nil
	end
	log("Updating " .. recipe.name) 
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
		table.insert(recipe.results,{type = "item", name = "assembly-bot", amount=1, probability=assemblybots.config.replicationfactor})
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
		table.insert(recipe.results,{type = "item", name = "assembly-bot", amount=1, probability=assemblybots.config.replicationfactor})
	end
end
end