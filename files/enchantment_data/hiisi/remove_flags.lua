dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
local child = GetUpdatedEntityID()
local entity = EntityGetParent(child)
GameRemoveEntityFlagRun(child, "hiisi_damage_boosted")