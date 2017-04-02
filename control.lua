script.on_init(function()
for index, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()
end
end)

script.on_event(defines.events.on_player_created, function(event)
	local iteminsert = game.players[event.player_index].insert
	iteminsert{name="assembly-bot", count=10}
end)

script.on_event(defines.events.on_entity_died, function(event)
    entityDied(event, event.entity)
end)

function entityDied(event, entity)
	local bots = entity.get_item_count("assembly-bot")
	local ubots = entity.get_item_count("used-assembly-bot")
	--game.print("found " .. bots .. " bots and " .. ubots .. " spent bots")
	if bots > 0 then entity.surface.spill_item_stack(entity.position, {name="assembly-bot", count=bots}, true) end
	if ubots > 0 then entity.surface.spill_item_stack(entity.position, {name="used-assembly-bot", count=ubots}, true) end
	if bots + ubots > 0 then game.print("You can't get rid of them that easily ") end
end

function onResearchFinished(event)
	local research = event.research
	if research.name == "assemblybots-bot-recharge1" then
		research.force.recipes["assembly-bot"].enabled = false
	end
end

script.on_event(defines.events.on_research_finished, onResearchFinished)