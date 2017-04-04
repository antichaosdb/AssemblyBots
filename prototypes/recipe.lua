data:extend({
 {
    type = "recipe",
    name = "assembly-bot-recharge1",
    enabled = "true",
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
    ingredients = 
    {
      {"used-assembly-bot",5},
	  {"electronic-circuit",1}
    },
    result = "assembly-bot",
	result_count = 5
  }
})