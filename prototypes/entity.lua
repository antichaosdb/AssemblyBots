local inserter = util.table.deepcopy(data.raw["inserter"]["filter-inserter"])
inserter.name = "long-filter-inserter"
inserter.pickup_position = {0, -2}
inserter.insert_position = {0, 2.2}
inserter.minable.result = "long-filter-inserter"
inserter.energy_per_movement = 8000
inserter.energy_per_rotation = 8000
inserter.rotation_speed = 0.03
inserter.extension_speed = 0.06
inserter.fast_replaceable_group = "long-handed-inserter"
inserter.hand_base_picture.filename = "__assemblybots__/graphics/entity/long-filter-inserter/long-filter-inserter-hand-base.png"
inserter.hand_closed_picture.filename = "__assemblybots__/graphics/entity/long-filter-inserter/long-filter-inserter-hand-closed.png"
inserter.hand_open_picture.filename = "__assemblybots__/graphics/entity/long-filter-inserter/long-filter-inserter-hand-open.png"
inserter.platform_picture.sheet.filename = "__assemblybots__/graphics/entity/long-filter-inserter/long-filter-inserter-platform.png"
data:extend({inserter})
