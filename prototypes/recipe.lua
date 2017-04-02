data:extend({
 {
    type = "recipe",
    name = "assembly-bot",
    enabled = "true",
    ingredients = 
    {
      {"used-assembly-bot",1}
    },
    result = "assembly-bot"
  },
  {
    type = "recipe",
    name = "used-assembly-bot",
    enabled = "true",
    ingredients = 
    {
      {"assembly-bot",1}
    },
    result = "used-assembly-bot"
  }
})