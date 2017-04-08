data:extend({
 {
    type = "recipe",
    name = "assembly-bot-recharge1",
    enabled = "true",
	energy = assemblybots.config.recharge_time,
    ingredients = 
    {
      {"used-assembly-bot",1}
    },
    result = "assembly-bot"
  },
   {
    type = "recipe",
    name = "assembly-bot-recharge2",
    enabled = "false",
	energy = assemblybots.config.recharge_time,
    ingredients = 
    {
      {"used-assembly-bot",2},
	  {"iron-plate",1}
    },
    result = "assembly-bot",
	result_count = 2
  },
   {
    type = "recipe",
    name = "assembly-bot-recharge3",
    enabled = "false",
	energy = assemblybots.config.recharge_time,
    ingredients = 
    {
      {"used-assembly-bot",8},
	  {"electronic-circuit",1}
    },
    result = "assembly-bot",
	result_count = 8
  },
  {
    type = "recipe",
    name = "assembly-bot-repair",
    enabled = "false",
	energy = 30,
    ingredients = 
    {
      {"broken-assembly-bot",1},
	  {"advanced-circuit",1}
    },
    result = "assembly-bot",
	result_count = 1
  }
})