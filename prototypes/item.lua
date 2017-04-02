data:extend(
{
  {
    type = "item",
    name = "assembly-bot",
    icon = "__assemblybots__/graphics/icons/assembly-bot.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "production-machine",
    order = "d[assembly-bot]",
    stack_size = 100
  },
  {
    type = "item",
    name = "used-assembly-bot",
    icon = "__assemblybots__/graphics/icons/assembly-bot-used.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "production-machine",
    order = "d[assembly-bot]-a[assembling-bot-used]",
    stack_size = 100
  }
})