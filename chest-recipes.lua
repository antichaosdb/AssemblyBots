assemblybots.chestRecipies = {}
-- The key ingredient is the one that will be used slowly.  The recipe will be enabled when the key and result are both unlocked
-- balanced around 2 bots per use
assemblybots.chestRecipies["assembling-machine-1"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=1}
	}, 
	result="iron-gear-wheel", amount=1
}
assemblybots.chestRecipies["electric-mining-drill"] = {
	enabled=false,
	uses=13,
	ingredients={
		{name="copper-plate",amount=1}
	}, 
	result="copper-cable", amount=4
}
-- 44 plates
assemblybots.chestRecipies["assembling-machine-2"] = {
	enabled=false,
	uses=8,
	ingredients={
		{name="iron-plate",amount=1},
		{name="copper-plate", amount=1}
	}, 
	result="electronic-circuit", amount=2
}
-- 300 plates 40 plastic
assemblybots.chestRecipies["assembling-machine-3"] = {
	enabled=false,
	uses=30,
	ingredients={
		{name="iron-plate",amount=1},
		{name="copper-plate", amount=1},
		{name="plastic-bar", amount=1}
	}, 
	result="advanced-circuit", amount=1
}
-- 8 plates
assemblybots.chestRecipies["offshore-pump"] = {
	enabled=false,
	uses=5,
	ingredients={
		{name="iron-plate",amount=1}
	}, 
	result="pipe", amount=2
}
-- 12 plates
assemblybots.chestRecipies["fast-transport-belt"] = {
	enabled=false,
	uses=6,
	ingredients={
		{name="iron-plate",amount=1}
	}, 
	result="transport-belt", amount=2
}
-- 23 plates
assemblybots.chestRecipies["filter-inserter"] = {
	enabled=false,
	uses=6,
	ingredients={
		{name="iron-plate",amount=1},
		{name="electronic-circuit",amount=1}
	}, 
	result="inserter", amount=1
}
-- 31 plates
assemblybots.chestRecipies["steam-engine"] = {
	enabled=false,
	uses=15,
	ingredients={
		{name="copper-plate",amount=1}
	}, 
	result="small-electric-pole", amount=2
}
-- 35 plates
assemblybots.chestRecipies["submachine-gun"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=2}
	}, 
	result="firearm-magazine", amount=1
}
-- 68 plates, 1 + 20 = 2, 250 oil pb 
assemblybots.chestRecipies["pumpjack"] = {
	enabled=false,
	uses=20,
	ingredients={
		{name="oil-barrel",amount=1},
		{name="coal",amount=8}
	}, 
	result="plastic-bar", amount=20
}
-- 53 plates + 10, 1 + 5s + 100 = 50 sa, 1 + 1+ 20 = 1b
assemblybots.chestRecipies["chemical-plant"] = {
	enabled=false,
	uses=8,
	ingredients={
		{name="sulphur",amount=10},
		{name="water-barrel",amount=1},
		{name="iron-plate",amount=1},
		{name="copper-plate", amount=1},
	}, 
	result="battery", amount=5
}
-- 109 plate, 8 p per engine
assemblybots.chestRecipies["car"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=2}
	}, 
	result="engine-unit", amount=1
}
-- 335 plate, 13p 15 lube per engine
assemblybots.chestRecipies["locomotive"] = {
	enabled=false,
	uses=5,
	ingredients={
		{name="iron-plate",amount=160},
		{name="heavy-oil-barrel",amount=1}
	}, 
	result="electric-engine-unit", amount=15
}