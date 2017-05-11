if not assemblybots then assemblybots = {} end
if not assemblybots.config then assemblybots.config = {} end

require("config")
require("chest-recipes")

function assemblybots.chestKey(chest)
	return string.gsub(chest.position.x.."A"..chest.position.y, "-", "_")
end

function assemblybots.checkChestRecipes(force)
	for key, recipe in pairs(assemblybots.chestRecipies) do
		if not recipe.enabled then
			local keyRecipe = force.recipes[key]
			local resultRecipe = force.recipes[recipe.result]
			if keyRecipe and keyRecipe.enabled and resultRecipe and resultRecipe.enabled then
				recipe.enabled = true
			end
		end
	end
end

function assemblybots.spillBotStack(config, surface, position, botType, count)
	local botStacks = math.floor(count / 10)
	local bots_on_ground = config.bots_on_ground
	for s = 1, botStacks, 1 do 
		local pos = surface.find_non_colliding_position("item-on-ground", position,8, 1)
		local stack = surface.create_entity{name="item-on-ground",position=pos,stack={name=botType, count=10}}
		table.insert(bots_on_ground, {entity=stack,closest_chest=nil,steps=0})
	end
	local remaining  = count - (10 * botStacks)
	if remaining > 0 then
		local pos = surface.find_non_colliding_position("item-on-ground", position,8, 1)			
		local stack = surface.create_entity{name="item-on-ground",position=pos,stack={name=botType, count=10}}
		table.insert(bots_on_ground, {entity=stack,closest_chest=nil,steps=0})
	end
end

function assemblybots.findChests(force)
    local chests = {}
    local surface = game.surfaces[1]

    for coord in surface.get_chunks() do
        local X,Y = coord.x, coord.y

        if surface.is_chunk_generated{X,Y} then
            local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
			for type,_ in pairs(global.chestTypes) do
				for _,chest in pairs(surface.find_entities_filtered{area=area, type=type, force=force.name}) do
					local key = assemblybots.chestKey(chest)
					chests[key] = chest
				end
			end
        end
    end
    global.config[force.name].chests = chests
end

function assemblybots.findClosestChest(chests, item)
	local closestChest = nil
	local closestDistance = 1000000
	local botStack = item.entity
	for i, chest in pairs(chests) do
		if math.abs(chest.position.x - botStack.position.x) < assemblybots.config.dropped_item_step_size and math.abs(chest.position.y - botStack.position.y) < assemblybots.config.dropped_item_step_size then
			-- try to put stack in chest
			local inventory = chest.get_inventory(defines.inventory.chest)
			if chest.type == "car" then inventory = chest.get_inventory(defines.inventory.car_trunk) end
			if inventory.can_insert({name=botStack.stack.name, count=botCount}) then
				inventory.insert(botStack.stack)
				botStack.destroy()
				return
			end
		else
			local distance = math.abs(chest.position.x - botStack.position.x) + math.abs(chest.position.y - botStack.position.y)
			if distance < closestDistance then
				closestDistance = distance
				closestChest = chest
			end
		end
	end
	if not closestChest then
		-- if no valid chests, create one
		local newpos = surface.find_non_colliding_position("iron-chest", botStack.position,5, 1)
		closestChest = surface.create_entity{name="iron-chest",position=newpos,force=botStack.force}
		local key = assemblybots.chestKey(closestChest)
		chests[key] = closestChest
	end
	item.closest_chest = closestChest
	item.steps = 0
end
							
function assemblybots.findBotsOnGround(force, chests)
    local bots_on_ground = {}
    local surface = game.surfaces[1]
    for coord in surface.get_chunks() do
        local X,Y = coord.x, coord.y
        if surface.is_chunk_generated{X,Y} then
            local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
			for _,entity in pairs(surface.find_entities_filtered{area=area, name="item-on-ground", force=force}) do
				if entity.stack.name == "assembly-bot" or entity.stack.name == "used-assembly-bot" or entity.stack.name == "broken-assembly-bot" then
					local item = {entity=entity,closest_chest=nil,steps=0}
					assemblybots.findClosestChest(chests, item)
					if item.entity and item.entity.valid then
						table.insert(bots_on_ground, item)
					end
				end
			end
		end
	end
end

local intiDone = false

function assemblybots.init(force)
	if initDone then return end
	if not force or force == game.forces.enemy or force == "biterbots" then return end
	global.config = global.config or {}
	local forcename = force.name
	if not forcename then 
		forcename = force 
		force = game.forces[forcename]
	end
	assemblybots.checkChestRecipes(force)
	--game.print("init")
	global.config[forcename] = global.config[forcename] or {}
	local config = global.config[forcename]
	config.bots_spilled = config.bots_spilled or 0
	config.spill_warning_level = config.spill_warning_level or 0
	config.inserter_help_given = config.inserter_help_given or 0
	config.biter_appology = config.biter_apology or 0
	config.botmode = config.botmode or "normal"
	config.rechargemode = config.rechargemode or "assemblybots-bot-recharge1"
	global.chestTypes = {}
	global.chestTypes["container"] = true
	global.chestTypes["smart-container"] = true
	global.chestTypes["logistic-container"] = true
	global.chestTypes["cargo-wagon"] = true
	global.chestTypes["car"] = true
	config.chests = {}
	assemblybots.findChests(force)
	config.bots_on_ground = {}
	assemblybots.findBotsOnGround(force)
	
	--disable normal mode recipes after an update that has reset recipies
	local mode = config.botmode
	if mode ~= "normal" and force.recipes["iron-gear-wheel"].enabled then
		local toChange = {}
		for k, recipe in pairs(force.recipes) do
			if recipe.category ~= "smelting" and not string.match(recipe.name,"assembly%-bot") and not string.match(recipe.name,"%-"..mode) and recipe.enabled then
				local new_recipename= recipe.name.."-"..mode
				toChange[recipe.name] = new_recipename
			end
		end
		assemblybots.changeRecipes(force, toChange)
	end
	
	initDone = true
end

function assemblybots.entityDied(event, entity)
	if entity.force == game.forces.enemy then return end
	local config = global.config[entity.force.name]
	if not config then return end
	local bots = entity.get_item_count("assembly-bot")
	local ubots = entity.get_item_count("used-assembly-bot")
	local bbots = entity.get_item_count("broken-assembly-bot")
	config.bots_spilled = config.bots_spilled + bots + ubots + bbots
	local surface = game.surfaces[1]
	if bots > 0 then assemblybots.spillBotStack(config, surface, entity.position, "assembly-bot", bots) end
	if ubots > 0 then assemblybots.spillBotStack(config, surface, entity.position, "used-assembly-bot", ubots) end
	if bbots > 0 then assemblybots.spillBotStack(config, surface, entity.position, "broken-assembly-bot", bbots) end

	-- if config.bots_spilled > 1000 and config.spill_warning_level <= 2 then
		-- game.print("Seriously, that's a bad idea.  They notice.")
		-- config.spill_warning_level = 3
	-- elseif 	config.bots_spilled > 100 and config.spill_warning_level <= 1 then
		-- game.print("I wouldn't keep doing that if I were you.")
		-- config.spill_warning_level = 2
	if config.bots_spilled > 10 and config.spill_warning_level <= 0 then
		game.print("You can't get rid of them that easily ")
		config.spill_warning_level = 1
	end
	-- remove chest from list
	if global.chestTypes[entity.type] then
		local chests = config.chests
		local key = assemblybots.chestKey(entity)
		if chests[key] then chests[key] = nil end
	end
end

-- Add chests to tracking list
function assemblybots.entityBuilt(event, entity)
--game.print("Built " .. entity.name .. " of type " .. entity.type)
	local config = global.config[entity.force.name]
	if global.chestTypes[entity.type] then
		local chests = config.chests
		local key = assemblybots.chestKey(entity)
		if not chests[key] then chests[key] = entity end
	elseif entity.name == "filter-inserter" and config.inserter_help_given == 0 then
		game.print("You can press N with the cursor over a filter insert to cyle through the bot filter options")
		config.inserter_help_given = 1		
	end
end

-- remove chests from tracking list
function assemblybots.entityMined(event, entity)
	if global.chestTypes[entity.type] then
		local chests = global.config[entity.force.name].chests
		local key = assemblybots.chestKey(entity)
		if chests[key] then chests[key] = nil end
	end
end

function assemblybots.changeRecipes(force, toChange)
	for old, new in pairs(toChange) do
		force.recipes[old].enabled = false
		force.recipes[new].enabled = true
	end
	local surface = game.surfaces[1]
    for coord in surface.get_chunks() do
        local X,Y = coord.x, coord.y

        if surface.is_chunk_generated{X,Y} then
            local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
            for _,assm in pairs(surface.find_entities_filtered{area=area, type="assembling-machine", force=force.name}) do
				if assm.recipe and toChange[assm.recipe.name] then
					assm.recipe = force.recipes[toChange[assm.recipe.name]]
				end
            end
        end
    end
end

function assemblybots.setModeRecipies(force, research)
	local mode = string.match(research, "%-([a-z]+)%-[1-7]")
	local oldMode = global.config[force.name].botmode
	if oldMode == "" then oldMode = "normal" end
	local level = tonumber(string.sub(research, -1))
	local toChange = {}
	for k, recipe in pairs(force.recipes) do
		if recipe.category ~= "smelting" and not string.match(recipe.name,"assembly%-bot") and recipe.enabled then
			local new_recipename= recipe.name
			if oldMode ~= "normal" then new_recipename = string.gsub(new_recipename, "%-"..oldMode, "") end
			if mode ~= "normal" then new_recipename = new_recipename .."-"..mode end
			toChange[recipe.name] = new_recipename
		end
	end
	global.config[force.name].botmode = mode
	-- Update recipes used in assemblers
	assemblybots.changeRecipes(force, toChange)
	
	if level == 6 then game.print("You only have one more chance to switch modes.  The next bot mode research you do will be permanent") end
	
	local curTech = "assemblybots-bot-"..oldMode
	local newTech = "assemblybots-bot-"..mode
	local techs = {"assemblybots-bot-normal", "assemblybots-bot-production", "assemblybots-bot-overdrive","assemblybots-bot-replication","assemblybots-bot-suppression"}
	for _, tech in pairs(techs) do
		local techname = tech.."-"..level
		--disable technologies at same level
		if not string.match(techname, curTech) then 
			force.technologies[techname].enabled = false 	
		end
		--enable technologies at next level
		if level < 7 then
			local next_techname = tech.."-"..(level + 1)
			if not string.match(next_techname, newTech) then 
				force.technologies[next_techname].enabled = true	
			end
		end
	end
end

function assemblybots.setRechargeRecipies(force, research)
	local level = tonumber(string.sub(research, -1))
	local techbase = string.sub(research, 1, string.len(research)-2)
	local recipename = "assembly-bot-" .. string.sub(techbase, 18)
	local toChange = {}
	local config = global.config[force.name]
	config.rechargemode = techbase
	local techs = {"assemblybots-bot-recharge1", "assemblybots-bot-recharge2", "assemblybots-bot-recharge3"}
	for _, tech in pairs(techs) do
		local techmatch = string.gsub(tech,"%-", "%%-")
		--game.print(techbase.. "  " .. techmatch)
		if not string.match(techbase,techmatch)  then
			force.technologies[tech.."-"..level].enabled = false
			force.technologies[tech.."-"..(level+1)].enabled = true
			local oldrecipename = "assembly-bot-" .. string.sub(tech, 18)
			--game.print("changing " .. oldrecipename.." to "..recipename)
			toChange[oldrecipename] = recipename
		end
	end
	if level == 6 then game.print("You only have one more chance to switch recharge research.  The next recharge research you do will be permanent") end
	assemblybots.changeRecipes(force, toChange)
end

function assemblybots.onResearchFinished(event)
	local research = event.research
	local force = research.force
	local tech
	if string.match(research.name,"assemblybots%-bot%-recharge") then
		assemblybots.setRechargeRecipies(force, research.name)
	elseif string.match(research.name,"assemblybots%-bot%-replication") then
		assemblybots.setModeRecipies(force, research.name)
	elseif string.match(research.name,"assemblybots%-bot%-overdrive.*") then	
		assemblybots.setModeRecipies(force, research.name)
	elseif string.match(research.name,"assemblybots%-bot%-production.*") then	
		assemblybots.setModeRecipies(force, research.name)
	elseif string.match(research.name,"assemblybots%-bot%-normal.*") then	
		assemblybots.setModeRecipies(force, research.name)
	elseif string.match(research.name,"assemblybots%-bot%-suppression.*") then	
		assemblybots.setModeRecipies(force, research.name)
	else
		-- see if we need to enable any chest recipes
		assemblybots.checkChestRecipes(force)
	
		-- Unlock correct version of newly unlocked recipes
		local botmode = global.config[force.name].botmode
		for ek = #research.effects, 1, -1 do
			if research.effects[ek].type == "unlock-recipe" then
				local recipe = research.effects[ek].recipe
				if botmode ~= "normal" and not string.match(recipe,"assembly%-bot") then
					force.recipes[recipe].enabled = false
					force.recipes[recipe.."-"..botmode].enabled = true
				end
			end
		end
	end
end

	
function getNewBots(bots, repfactor)
	local botStacks = math.floor(bots / 10)
	local newBots = 0
	repfactor = repfactor * 10
	for s = 1, botStacks, 1 do
		local r = math.random(10)
		if r <= repfactor then
			newBots = newBots + 1
		end
	end
	return newBots
end

function assemblybots.addBots(inventory, addType, newBots)
	local inserted = inventory.insert({name=addType, count=newBots})
	local remaining = newBots - inserted
	if remaining > 0 then
		local bins = inventory.insert({name="broken-assembly-bot", count=remaining})
		if bins < remaining then
			-- remove stack of used-bots and add broken bots
			local remo = inventory.remove({name=addType, count=10})
			inventory.insert({name="broken-assembly-bot", count=remaining - bins})
		end
	end	
end
				
function assemblybots.processChest(chest)
	local inventory = chest.get_inventory(defines.inventory.chest)
	if chest.type == "car" then inventory = chest.get_inventory(defines.inventory.car_trunk) end
	local counts = inventory.get_contents()
	local assmBots = counts["assembly-bot"]
	local usedBots = counts["used-assembly-bot"]
	local brokenBots = counts["broken-assembly-bot"]
	-- game.print("Checking " .. chest.name .. " at " .. serpent.block(chest.position, {comment=false}))
	if not assmBots and not usedBots and not brokenBots then return end

	--game.print("Found " .. bots .." " .. botType.. " in " .. chest.name .. " at " .. serpent.block(chest.position, {comment=false}) .. ".  Creating " .. newBots)
	local config = global.config[chest.force.name]
	-- broken bots.  Create bots but make biters if chest is full
	if brokenBots then
		local newBots = getNewBots(brokenBots,assemblybots.config.chest_replication_factor)
		if newBots > 0 then
			local inserted = inventory.insert({name="assembly-bot", count=newBots})
			if inserted < newBots then
				newBots = newBots - inserted
				-- no space, spawn biter
				if config.biter_apology == 0 then
					game.print("You might want to avoid letting chests fill up.  Imagine the biters are angry bots.  There will be custom graphics eventually")
					config.biter_apology = 1
				end
				local surface = chest.surface
				if not game.forces["botbiters"] then game.create_force("botbiters") end
				local newForce = "botbiters"
				-- feed them fish to make them spawn friendly
				if counts["raw-fish"] and counts["raw-fish"] > newBots then newForce = chest.force.name end
				local group = surface.create_unit_group{position=chest.position,force=newForce}
				for e = 1, newBots, 1 do
					local pos = surface.find_non_colliding_position("small-biter", chest.position,8, 1)
					if pos then				
						local biter = surface.create_entity{name="small-biter", position=pos,force=newForce}
						group.add_member(biter)
					end
				end
				if newForce == "botbiters" then
					group.set_command({type=defines.command.attack_area, destination=chest.position, radius=32})
				else
					inventory.remove("raw-fish", newBots)
					-- not sure what to command friendlies
				end
			end
		end
	end
	-- used bots.  Passive recharge, otherwise replicate.  Break if chest full
	if usedBots then
		local newBots = getNewBots(usedBots,assemblybots.config.chest_replication_factor)
		if newBots > 0 then
			local iron = counts["iron-plate"]
			local circuits = counts["electronic-circuit"]
			-- allow passive recharging
			if iron and config.rechargemode == "assemblybots-bot-recharge2" then
				local botsToRecharge = math.min(iron, newBots)
				inventory.remove({name="iron-plate", count=botsToRecharge})
				inventory.remove({name="used-assembly-bot", count=botsToRecharge*2})
				inventory.insert({name="assembly-bot", count=botsToRecharge*2})
				newBots = newBots - (botsToRecharge*2)
			elseif circuits and config.rechargemode == "assemblybots-bot-recharge3" then
				local botsToRecharge = math.min(circuits, newBots)
				inventory.remove({name="electronic-circuit", count=botsToRecharge})
				inventory.remove({name="used-assembly-bot", count=botsToRecharge*8})
				inventory.insert({name="assembly-bot", count=botsToRecharge*8})
				newBots = newBots - (botsToRecharge*8)
			end
			if newBots > 0 then
				assemblybots.addBots(inventory, "used-assembly-bot", newBots)		
			end
		end
	end
	-- assembly bots.  Passive crafting, or produce used bots
	if assmBots then
		local newBots = getNewBots(assmBots,assemblybots.config.chest_replication_factor)
		if newBots > 0 then
			if chest.force.technologies["assemblybots-bot-management"].researched then
				local toCraft = {}
				local totalOut = 0
				for key, recipe in pairs(assemblybots.chestRecipies) do
					-- check for key
					if recipe.enabled and counts[key] then
						local output = newBots
						-- check for ingredients
						for _, ingredient in pairs(recipe.ingredients) do
							if counts[ingredient.name] and counts[ingredient.name] >= ingredient.amount then
								output = math.min(output, math.floor(counts[ingredient.name]/ingredient.amount))
							else
								output = 0
							end
						end
						-- add to list of things we can craft
						if output > 0 then toCraft[key] = output end
						totalOut = totalOut + output
					end
				end
				for key, output in pairs(toCraft) do
					if newBots > 0 then
						local recipe = assemblybots.chestRecipies[key]
						-- rebalance output
						local newItems = output
						if totalOut > newBots then newItems = math.floor((output * newBots) / totalOut) end
						if newItems == 0 then newItems = 1 end
							
						--game.print("passive crafting " .. newItems .. " " .. recipe.result)
						for _, ingredient in pairs(recipe.ingredients) do
							-- remove ingredients
							inventory.remove({name=ingredient.name, count=(ingredient.amount*newItems)})
						end
						-- reduce health on key item
						local keyStack = inventory.find_item_stack(key)
						local usage = 1 / (recipe.uses * keyStack.count)
						if keyStack.health <=usage then
							keyStack.count = 0
						else
							keyStack.health = keyStack.health - usage
						end
						-- add result
						local inserted = inventory.insert({name=recipe.result, count=recipe.amount*newItems})
						local remaining = (recipe.amount*newItems) - inserted
						if remaining > 0 then
							local bins = inventory.insert({name="broken-assembly-bot", count=remaining})
							if bins < remaining then
								-- remove stack of bots and add broken bots
								local remo = inventory.remove({name="assembly-bot", count=10})
								inventory.insert({name="broken-assembly-bot", count=remaining - bins})
							end
						else					
							--replace bots with used bots
							inventory.remove({name="assembly-bot", count=newItems})
							inventory.insert({name="used-assembly-bot", count=newItems})
						end
						newBots = newBots - newItems
					end
				end
			end
			if newBots > 0 then 			
				assemblybots.addBots(inventory, "assembly-bot", newBots)
			end
		end
	end
end

function assemblybots.checkChests()
	for index, force in pairs(game.forces) do
		assemblybots.init(force)
		local config = global.config[force.name]
		if config then
		if config.botmode == "suppression" then return end
		local chests = config.chests
			if chests then
				for key, chest in pairs(chests) do
					if chest and chest.valid and chest.name ~= nil and type ~= nil then
						assemblybots.processChest(chest)
					else 
						chests[key] = nil
					end
				end
			end
		end
	end
end

-- Loop through filter settings for the 3 types of bots
function assemblybots.setFilter(event)
	local player = game.players[event.player_index]
	local entity = player.selected
	if entity and player.can_reach_entity(entity) and entity.filter_slot_count and (entity.type == "inserter" or entity.type == "loader") then
		if entity.filter_slot_count > 1 then
			local filter1 = entity.get_filter(1)
			local filter2 = entity.get_filter(2)
			local filter3 = entity.get_filter(3)
			if not filter1 and not filter2 and not filter3 then
				entity.set_filter(1, "assembly-bot")
				entity.set_filter(2, "used-assembly-bot")
				entity.set_filter(3, "broken-assembly-bot")
			elseif filter1 == "assembly-bot" and filter2 == "used-assembly-bot" and filter3 == "broken-assembly-bot" then
				entity.set_filter(3, nil)
			elseif filter1 == "assembly-bot" and filter2 == "used-assembly-bot" and not filter3 then
				entity.set_filter(2, nil)
			elseif filter1 == "assembly-bot" and not filter2 and not filter3 then
				entity.set_filter(1, nil)
				entity.set_filter(2, "used-assembly-bot")
			elseif not filter1 and filter2 == "used-assembly-bot" and not filter3 then		
				entity.set_filter(2, nil)
				entity.set_filter(3, "broken-assembly-bot")
			elseif not filter1 and not filter2 and filter3 == "broken-assembly-bot" then
				entity.set_filter(1, "assembly-bot")
			elseif filter1 == "assembly-bot" and not filter2 and filter3 == "broken-assembly-bot" then
				entity.set_filter(1, nil)
				entity.set_filter(2, "used-assembly-bot")
			elseif not filter1 and filter2 == "used-assembly-bot" and filter3 == "broken-assembly-bot" then
				entity.set_filter(2, nil)
				entity.set_filter(3, nil)
			end
		elseif entity.filter_slot_count == 1 then
			local filter1 = entity.get_filter(1)
			if not filter1 then
				entity.set_filter(1, "assembly-bot")
			elseif filter1 == "assembly-bot" then
				entity.set_filter(1, "used-assembly-bot")
			elseif filter1 == "used-assembly-bot" then
				entity.set_filter(1, "broken-assembly-bot")
			elseif filter1 == "broken-assembly-bot" then
				entity.set_filter(1, nil)
			end
		end
	end
end

function assemblybots.moveBotsOnGround()
	local surface = game.surfaces[1]
	for index, force in pairs(game.forces) do
		if not force or force == game.forces.enemy or force == "biterbots" then return end
		local config = global.config[force.name]
		local bots_on_ground = config.bots_on_ground
		if config then
			local chests = config.chests
			for idx, item in pairs(bots_on_ground) do
				local botStack = item.entity
				if botStack and botStack.valid and not item.closest_chest then 
					assemblybots.findClosestChest(chests, item)
				elseif botStack and botStack.valid and item.steps > 10 then
					assemblybots.findClosestChest(chests, item)
				end
				if botStack and botStack.valid then
					local botType = botStack.stack.name
					local botCount = botStack.stack.count									
					local closestChest = item.closest_chest
					if closestChest then
						if math.abs(closestChest.position.x - botStack.position.x) < assemblybots.config.dropped_item_step_size and math.abs(closestChest.position.y - botStack.position.y) < assemblybots.config.dropped_item_step_size then
							-- try to put stack in chest
							local inventory = closestChest.get_inventory(defines.inventory.chest)
							if closestChest.type == "car" then inventory = closestChest.get_inventory(defines.inventory.car_trunk) end
							if inventory.can_insert({name=botType, count=botCount}) then
								inventory.insert(botStack.stack)
								botStack.destroy()
								table.remove(bots_on_ground,idx)
							else
								-- can't insert to nearest chest.  Force search for new chest
								item.steps = 11
							end
						else
							-- move closer to chest
							local newX = botStack.position.x
							if closestChest.position.x > botStack.position.x + assemblybots.config.dropped_item_step_size then 
								newX = newX + assemblybots.config.dropped_item_step_size
							elseif closestChest.position.x < botStack.position.x - assemblybots.config.dropped_item_step_size then 	
								newX = newX - assemblybots.config.dropped_item_step_size
							end
							local newY = botStack.position.y
							if closestChest.position.y > botStack.position.y + assemblybots.config.dropped_item_step_size then 
								newY = newY + assemblybots.config.dropped_item_step_size
							elseif closestChest.position.y < botStack.position.y - assemblybots.config.dropped_item_step_size then 	
								newY = newY - assemblybots.config.dropped_item_step_size
							end
							local newpos = surface.find_non_colliding_position("item-on-ground", {newX,newY},assemblybots.config.dropped_item_search_area, 1)
							item.steps = item.steps + 1
							botStack.teleport(newpos)
						end
					end
				else
					-- botstack invalid
					table.remove(bots_on_ground,idx)
				end
			end
		end
	end
end

function assemblybots.onTick(event)
	if event.tick % assemblybots.config.chest_replication_ticks == 0  then
		assemblybots.checkChests()
	end
	if assemblybots.config.dropped_item_migration_ticks and event.tick % assemblybots.config.dropped_item_migration_ticks == 0 then
		assemblybots.moveBotsOnGround()
	end
end

function assemblybots.itemDropped(event, player_index, entity)
	if entity.stack.name == "assembly-bot" or entity.stack.name == "used-assembly-bot" or entity.stack.name == "broken-assembly-bot" then
		local bots_on_ground = global.config[game.players[player_index].force.name].bots_on_ground
		table.insert(bots_on_ground, {entity=entity,closest_chest=nil,steps=0})
	end
	
end

-- Event Hooks
script.on_init(function()
for index, force in pairs(game.forces) do
	force.reset_recipes()
	force.reset_technologies()
	assemblybots.init(force)
end
end)

script.on_event(defines.events.on_force_created, function(event)
    assemblybots.init(force)
end)

script.on_configuration_changed(function(event)
for _, force in pairs(game.forces) do
        assemblybots.init(force)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
	local iteminsert = game.players[event.player_index].insert
	iteminsert{name="assembly-bot", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	local iteminsert = game.players[event.player_index].insert
	iteminsert{name="assembly-bot", count=10}
end)

script.on_event(defines.events.on_entity_died, function(event)
    assemblybots.entityDied(event, event.entity)
end)

script.on_event(defines.events.on_built_entity, function(event)
	assemblybots.entityBuilt(event, event.created_entity)
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
    assemblybots.entityBuilt(event, event.created_entity)
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
    assemblybots.entityMined(event, event.entity)
end)
script.on_event(defines.events.on_robot_pre_mined, function(event)
    assemblybots.entityMined(event, event.entity)
end)

script.on_event(defines.events.on_player_dropped_item, function(event)
    assemblybots.itemDropped(event, event.player_index, event.entity)
end)

script.on_event(defines.events.on_research_finished, assemblybots.onResearchFinished)

script.on_event(defines.events.on_tick, assemblybots.onTick)

script.on_event("assemblybots-setfilter", assemblybots.setFilter)