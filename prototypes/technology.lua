data:extend(
{
  {
    type = "technology",
    name = "assemblybots-bot-recharge1",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
	researched = true,
    prerequisites =
    {
      "automation"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembly-bot-recharge1"
      },
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-a"
  },
    {
    type = "technology",
    name = "assemblybots-bot-recharge2",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    prerequisites =
    {
      "automation"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembly-bot-recharge2"
      },
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-b"
  },
    {
    type = "technology",
    name = "assemblybots-bot-recharge3",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    prerequisites =
    {
      "automation"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembly-bot-recharge3"
      },
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-c"
  },
    {
    type = "technology",
    name = "assemblybots-bot-production",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    prerequisites =
    {
      "automation"
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-a"
  },
    {
    type = "technology",
    name = "assemblybots-bot-replication",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    prerequisites =
    {
      "automation"
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-b"
  },
{
    type = "technology",
    name = "assemblybots-bot-overdrive",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    prerequisites =
    {
      "automation"
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-c"
  },
 {
    type = "technology",
    name = "assemblybots-bot-normal",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
	enabled = false,
    prerequisites =
    {
      "automation"
    },
    unit =
    {
      count = 5,
      ingredients = 
      {
        {"science-pack-1", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-a"
  },
}
)