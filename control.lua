if not assemblybots then assemblybots = {} end
if not assemblybots.config then assemblybots.config = {} end

require("config")

function assemblybots.chestKey(chest)
	return string.gsub(chest.position.x.."A"..chest.position.y, "-", "_")
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

function assemblybots.init(force)
	if not force or force == game.forces.enemy or force == "biterbots" then return end
	global.config = global.config or {}
	local forcename = force.name
	if not forcename then 
		forcename = force 
		force = game.forces[forcename]
	end
	if global.config[forcename] then return end
	--game.print("init")
	global.config[forcename] = global.config[forcename] or {}
	local config = global.config[forcename]
	config.bots_spilled = config.bots_spilled or 0
	config.spill_warning_level = config.spill_warning_level or 0
	config.inserter_help_given = config.inserter_help_given or 0
	config.biter_appology = config.biter_apology or 0
	config.botmode = config.botmode or "normal"
	global.chestTypes = {}
	global.chestTypes["container"] = true
	global.chestTypes["smart-container"] = true
	global.chestTypes["logistic-container"] = true
	global.chestTypes["cargo-wagon"] = true
	global.chestTypes["car"] = true
	if not config.chests then 
		config.chests = {}
		assemblybots.findChests(force)
	end
end

function assemblybots.entityDied(event, entity)
	if entity.force == game.forces.enemy then return end
	local config = global.config[entity.force.name]
	local bots = entity.get_item_count("assembly-bot")
	local ubots = entity.get_item_count("used-assembly-bot")
	local bbots = entity.get_item_count("broken-assembly-bot")
	config.bots_spilled = config.bots_spilled + bots + ubots + bbots
	if bots > 0 then entity.surface.spill_item_stack(entity.position, {name="assembly-bot", count=bots}, true) end
	if ubots > 0 then entity.surface.spill_item_stack(entity.position, {name="used-assembly-bot", count=ubots}, true) end
	if bbots > 0 then entity.surface.spill_item_stack(entity.position, {name="broken-assembly-bot", count=bbots}, true) end

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
		game.print("You can press B with the cursor over a filter insert to cyle through the bot filter options")
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
	local techs = {"assemblybots-bot-recharge1", "assemblybots-bot-recharge2", "assemblybots-bot-recharge3"}
	for _, tech in pairs(techs) do
		local techmatch = string.gsub(tech,"%-", "%%-")
		game.print(techbase.. "  " .. techmatch)
		if not string.match(techbase,techmatch)  then
			force.technologies[tech.."-"..level].enabled = false
			force.technologies[tech.."-"..(level+1)].enabled = true
			local oldrecipename = "assembly-bot-" .. string.sub(tech, 18)
			game.print("changing " .. oldrecipename.." to "..recipename)
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

function assemblybots.addBotsToChest(chest, botType)
	local bots = chest.get_item_count(botType)
	if bots == 0 then return end
	local botStacks = math.floor(bots / 10)
	local newBots = 0
	for s = 1, botStacks, 1 do
		local r = math.random()
		if r < 0.1 then
			newBots = newBots + 1
		end
	end
	--game.print("Found " .. bots .." " .. botType.. " in " .. chest.name .. " at " .. serpent.block(chest.position, {comment=false}) .. ".  Creating " .. newBots)
	if newBots > 0 then
		local inserted = 0
		local inventory = chest.get_inventory(defines.inventory.chest)
		if chest.type == "car" then inventory = chest.get_inventory(defines.inventory.car_trunk) end
		if inventory.can_insert({name=botType, count=newBots}) then
			inserted = inventory.insert({name=botType, count=newBots})
		end
		local remaining = newBots - inserted
		--game.print("Put " .. inserted .. " " .. botType.. " " .. remaining .. " overflow")
		if remaining > 0 then
			if botType == "broken-assembly-bot" then
				-- no space, spawn biter
				local config = global.config[chest.force.name]
				if config.biter_apology == 0 then
					game.print("You might want to avoid letting chests fill up.  Imagine the biters are angry bots.  There will be custom graphics eventually")
					config.biter_apology = 1
				end
				local surface = chest.surface
				if not game.forces["botbiters"] then game.create_force("botbiters") end
				local group = surface.create_unit_group{position=chest.position,force="botbiters"}
				for e = 1, remaining, 1 do
					local pos = surface.find_non_colliding_position("small-biter", chest.position,8, 1)
					if pos then				
						local biter = surface.create_entity{name="small-biter", position=pos,force="botbiters"}
						group.add_member(biter)
					end
				end
				group.set_command({type=defines.command.attack_area, destination=chest.position, radius=32})
			elseif botType == "used-assembly-bot" then
				-- no space, remove a stack of used bots and add broken bots
				inventory.remove({name=botType, count=10})
				inventory.insert({name="broken-assembly-bot", count=remaining})	
			elseif botType == "assembly-bot" then
				-- no space, remove a stack of bots and add used bots
				inventory.remove({name=botType, count=10})
				inventory.insert({name="used-assembly-bot", count=remaining})	
			end
		end
	end
end

function assemblybots.checkChests()
	for index, force in pairs(game.forces) do
		assemblybots.init(force)
		local config = global.config[force.name]
		if config then
		local chests = config.chests
			if chests then
				for key, chest in pairs(chests) do
					if chest and chest.valid and chest.name ~= nil and type ~= nil then
						--game.print("Checking " .. chest.name .. " at " .. serpent.block(chest.position, {comment=false}))
						assemblybots.addBotsToChest(chest, "broken-assembly-bot")
						assemblybots.addBotsToChest(chest, "used-assembly-bot")
						assemblybots.addBotsToChest(chest, "assembly-bot")
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
  if entity and entity.name == "filter-inserter" and player.can_reach_entity(entity) then
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
  end
end

function assemblybots.onTick(event)
	if event.tick % assemblybots.config.chest_replication_ticks == 0  then
		assemblybots.checkChests()
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

script.on_event(defines.events.on_research_finished, assemblybots.onResearchFinished)

script.on_event(defines.events.on_tick, assemblybots.onTick)

script.on_event("assemblybots-setfilter", assemblybots.setFilter)