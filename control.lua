if not assemblybots then assemblybots = {} end

function assemblybots.chestKey(chest)
	return string.gsub(chest.position.x.."A"..chest.position.y, "-", "_")
end

function assemblybots.findChests(force)
    local types = {"container", "smart-container", "logistic-container"}
    local chests = {}
    local surface = game.surfaces[1]

    for coord in surface.get_chunks() do
        local X,Y = coord.x, coord.y

        if surface.is_chunk_generated{X,Y} then
            local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
			for _,type in pairs(types) do
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
	if force == game.forces.enemy then return end
	global.config = global.config or {}
	local forcename = force.name
	if not forcename then 
		forcename = force 
		force = game.forces[forcename]
	end
	if global.config[forcename] then return end
	game.print("init")
	global.config[forcename] = global.config[forcename] or {}
	local config = global.config[forcename]
	config.bots_spilled = config.bots_spilled or 0
	config.spill_warning_level = config.spill_warning_level or 0
	config.botmode = config.botmode or ""
	global.chestTypes = {}
	global.chestTypes["container"] = true
	global.chestTypes["smart-container"] = true
	global.chestTypes["logistic-container"] = true
	if not config.chests then 
		config.chests = {}
		assemblybots.findChests(force)
	end
	initDone = true
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

	if config.bots_spilled > 1000 and config.spill_warning_level <= 2 then
		game.print("Seriously, that's a bad idea.  They notice.")
		config.spill_warning_level = 3
	elseif 	config.bots_spilled > 100 and config.spill_warning_level <= 1 then
		game.print("I wouldn't keep doing that if I were you.")
		config.spill_warning_level = 2
	elseif config.bots_spilled > 10 and config.spill_warning_level <= 0 then
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
	if global.chestTypes[entity.type] then
		local chests = global.config[entity.force.name].chests
		local key = assemblybots.chestKey(entity)
		if not chests[key] then chests[key] = entity end
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
				if toChange[assm.recipe.name] then
					assm.recipe = force.recipes[toChange[assm.recipe.name]]
				end
            end
        end
    end
end

function assemblybots.setRecipies(force, mode)
	local oldMode = global.config[force.name].botmode
	local toChange = {}
	for k, recipe in pairs(force.recipes) do
		if recipe.category ~= "smelting" and not string.match(recipe.name,"assembly%-bot") and recipe.enabled then
			local new_recipename= recipe.name .. "-" .. mode
			if oldMode ~= "" then new_recipename = string.gsub(new_recipename, "%-"..oldMode, "") end
			toChange[recipe.name] = new_recipename
		end
	end
	global.config[force.name].botmode = mode
	-- Update recipes used in assemblers
	assemblybots.changeRecipes(force, toChange)
end

function assemblybots.onResearchFinished(event)
	local research = event.research
	local force = research.force
	local tech
	if research.name == "assemblybots-bot-recharge1" then
		local toChange = {}
		toChange["assembly-bot-recharge2"] = "assemblybots-bot-recharge1"
		toChange["assembly-bot-recharge3"] = "assemblybots-bot-recharge1"
		assemblybots.changeRecipes(force, toChange)
		tech = force.technologies["assemblybots-bot-recharge2"]
		tech.researched = false
		tech = force.technologies["assemblybots-bot-recharge3"]
		tech.researched = false
	elseif research.name == "assemblybots-bot-recharge2" then
		local toChange = {}
		toChange["assembly-bot-recharge1"] = "assemblybots-bot-recharge2"
		toChange["assembly-bot-recharge3"] = "assemblybots-bot-recharge2"
		assemblybots.changeRecipes(force, toChange)
		tech = force.technologies["assemblybots-bot-recharge1"]
		tech.researched = false
		tech = force.technologies["assemblybots-bot-recharge3"]
		tech.researched = false
	elseif research.name == "assemblybots-bot-recharge3" then
		local toChange = {}
		toChange["assembly-bot-recharge1"] = "assemblybots-bot-recharge3"
		toChange["assembly-bot-recharge2"] = "assemblybots-bot-recharge3"
		assemblybots.changeRecipes(force, toChange)
		tech = force.technologies["assemblybots-bot-recharge1"]
		tech.researched = false
		tech = force.technologies["assemblybots-bot-recharge2"]
		tech.researched = false
	elseif research.name == "assemblybots-bot-replication" then
		assemblybots.setRecipies(force, "replication")
		force.technologies["assemblybots-bot-normal"].enabled = true
	elseif research.name == "assemblybots-bot-overdrive" then	
		assemblybots.setRecipies(force, "overdrive")
		force.technologies["assemblybots-bot-normal"].enabled = true
	elseif research.name == "assemblybots-bot-production" then	
		assemblybots.setRecipies(force, "production")
		force.technologies["assemblybots-bot-normal"].enabled = true
	elseif research.name == "assemblybots-bot-normal" then	
		assemblybots.setRecipies(force, "")
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
		local inventory = chest.get_inventory(1)
		if inventory.can_insert({name=botType, count=newBots}) then
			inserted = inventory.insert({name=botType, count=newBots})
		end
		local remaining = newBots - inserted
		--game.print("Put " .. inserted .. " " .. botType.. " " .. remaining .. " overflow")
		if remaining > 0 then
			if botType == "broken-assembly-bot" then
				-- no space, spawn biter
				local surface = chest.surface
				local group = surface.create_unit_group{position=chest.position}
				for e = 1, remaining, 1 do
					local pos = surface.find_non_colliding_position("small-biter", chest.position,8, 1)
					if pos then
						local biter = surface.create_entity{name="small-biter", position=pos,force=game.forces.enemy}
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

function assemblybots.setFilter(event)

end

function assemblybots.onTick(event)
	if event.tick % 60 == 0  then
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