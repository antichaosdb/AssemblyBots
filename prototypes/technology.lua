data:extend(
{
  {
    type = "technology",
    name = "assemblybots-bot-recharge1",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    prerequisites =
    {
      "automation"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assemblybot-recharge1"
      },
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = 30
    },
    order = "e-c-c-a"
  },
}
)