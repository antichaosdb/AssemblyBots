-- RELOAD TO SEE CHANGES
-- Number of ticks between doing bot replication in chests. 60 is once per second
assemblybots.config.chest_replication_ticks = 300

-- How often dropped or spilled bots are moved towards a new chest. nil to disable
assemblybots.config.dropped_item_migration_ticks = 60

-- Movement of dropped items
assemblybots.config.dropped_item_step_size = 2
assemblybots.config.dropped_item_search_area = 5

--- START NEW MAP TO SEE CHANGES
-- Probability of new bot being created on each craft
assemblybots.config.replication_factor = 0.1

-- Probability of new bot being created on each craft in replication mode
assemblybots.config.replication_mode_factor = 0.5

-- Probability of broken bot being created on each craft in overdrive mode
assemblybots.config.overdrive_mode_factor = 0.05

-- Probability of producing output in supression mode
assemblybots.config.suppression_mode_factor = 0.75

-- Time for the recharge crafting recipies
assemblybots.config.recharge_time = 0.5

-- Research time for bot related techs
assemblybots.config.techtime = 30
