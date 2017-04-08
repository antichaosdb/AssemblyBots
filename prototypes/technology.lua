data:extend(
{
  {
    type = "technology",
    name = "assemblybots-bot-recharge1-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-recharge1.png",
	icon_size = 128,
	enabled = false,
    prerequisites =
    {
      "electronics"
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
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-a"
  },
    {
    type = "technology",
    name = "assemblybots-bot-recharge2-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-recharge2.png",
	icon_size = 128,
    prerequisites =
    {
      "electronics"
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
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-b"
  },
    {
    type = "technology",
    name = "assemblybots-bot-recharge3-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-recharge3.png",
	icon_size = 128,
    prerequisites =
    {
      "electronics"
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
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-c"
  },
    {
    type = "technology",
    name = "assemblybots-bot-production-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-production.png",
	icon_size = 128,
    prerequisites =
    {
      "electronics"
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-d"
  },
    {
    type = "technology",
    name = "assemblybots-bot-replication-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-replication.png",
	icon_size = 128,
    prerequisites = {"electronics" },
    unit = {
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-b"
  },
{
    type = "technology",
    name = "assemblybots-bot-overdrive-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-overdrive.png",
	icon_size = 128,
    prerequisites =
    {
      "electronics"
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-c"
  },
 {
    type = "technology",
    name = "assemblybots-bot-normal-1",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
	icon_size = 128,
	enabled = false,
    prerequisites =
    {
      "electronics"
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-a"
  },
   {
    type = "technology",
    name = "assemblybots-bot-suppression-1",
    icon = "__assemblybots__/graphics/technology/assemblybots-bot-suppression.png",
	icon_size = 128,
    prerequisites =
    {
      "electronics"
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-d-a"
  },
  {
    type = "technology",
    name = "assemblybots-bot-repair",
    icon = "__assemblybots__/graphics/icons/broken-assembly-bot.png",
	icon_size = 128,
	researched = true,
    prerequisites =
    {
      "advanced-electronics"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembly-bot-repair"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"science-pack-1", 1},
		{"science-pack-2", 1}
      },
      time = assemblybots.config.techtime
    },
    order = "e-c-c-d"
  },
}
)