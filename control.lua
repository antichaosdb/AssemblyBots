script.on_event(defines.events.on_player_created, function(event)
local iteminsert = game.players[event.player_index].insert
iteminsert{name="assembly-bot", count=10}

for index, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()
end
end)

function on_build_bot_inserter(inserter)
	inserter.set_filter(1, "assembly-bot")
	inserter.set_filter(2, "used-assembly-bot")
	inserter.operable = false
end
