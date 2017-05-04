assemblybots.chestRecipies = {}
-- The key ingredient is the one that will be used slowly.  The recipe will be enabled when the key and result are both unlocked
assemblybots.chestRecipies["assembling-machine-1"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=2}
	}, 
	result="iron-gear-wheel", amount=1
}
assemblybots.chestRecipies["electric-mining-drill"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="copper-plate",amount=1}
	}, 
	result="copper-cable", amount=2
}
assemblybots.chestRecipies["assembling-machine-2"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=2},
		{name="copper-plate", amount=3}
	}, 
	result="electronic-circuit", amount=2
}
assemblybots.chestRecipies["offshore-pump"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=1}
	}, 
	result="pipe", amount=1
}
assemblybots.chestRecipies["fast-transport-belt"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=3}
	}, 
	result="transport-belt", amount=2
}
assemblybots.chestRecipies["filter-inserter"] = {
	enabled=false,
	uses=10,
	ingredients={
		{name="iron-plate",amount=3},
		{name="electronic-circuit",amount=1}
	}, 
	result="inserter", amount=1
}