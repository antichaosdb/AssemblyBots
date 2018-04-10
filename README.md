# AssemblyBots

This mod is for those looking for a new layout challenge, without having to learn loads of new recipes.  It also does some things with technology that I hope are rather innovative.  Plus, surprises!

- Every (non-smelting) recipe require an assembly bot.  This depletes the bot, which then has to be recharged.  
- Assemblybots cannot be crafted directly, but with every craft they have a chance to replicate.  More bots is better, right?  However, they can't be destroyed, or even stored - at least not safely.  
- If you put them in chests, they will replicate on their own, or start to break.  If the chest fills up, bad things happen.
- If you drop them on the ground, they will move across the ground to the nearest chest.
- Assemblers all have an extra input slot to accommodate the new recipes.
- There are technology options which control how the bots are used and how they are recharged.  These technologies are mutually exclusive.  When you research one, the others are replaced with more expensive versions.  So you can switch between them, but the costs increase, and there is a limit to the number of times you can switch.  Also, these technologies change every recipe and automatically update the recipe in every assembling machine.
- Added long filter inserters. To succeed at this you'll have to learn to love filter inserters.  
- Press N while over a filter inserter to cycle bot filter settings.
- AssemblyBot Management research will allow you to keep bots in chests more safely by giving them things to do.  You'll have to experiment to find the recipes (or cheat and read chest-recipes.lua).  The efficiency of these recipies depends on how many bots you have in the chest.  An iron chest needs to be at least half full of bots to be worth it.  The 2x and 8x Recharge techs also allow bots to recharge in chests.

Current version
---------------
0.2.2  Released 10 April 2018  
[Mod Portal Link](https://mods.factorio.com/mods/antichaos/assemblybots)  
[Forum Thread](https://forums.factorio.com/viewtopic.php?f=97&t=43933)
For contributions and bugs use https://github.com/antichaosdb/AssemblyBots

Known Issues
------------
- This won't work with large, recipe changing mods like Bobs or Angels.  It could probably be made to, but that's a whole extra level of crazy.  If there are things that break with non-game changing mods, let me know.  DON'T use an auto-research mod with this.
- My homemade tech icons are particularly rubbish.  Any assistance would be appreciated.
- It's meant to be awkward, but the balance may be way off.  config.lua has a load of values that control various balance factors.  Most of these require starting a new map.   

Credits (Mods I studied while working on this)
-------
- Angels Refining
- Advanced Logistics System
- Picker Extended