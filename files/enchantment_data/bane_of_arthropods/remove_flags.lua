dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
local child = GetUpdatedEntityID()
local entity = EntityGetParent(child)
GameRemoveEntityFlagRun(child, "bane_of_arthropods_damage_boosted")