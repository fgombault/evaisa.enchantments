dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
local entity = GetUpdatedEntityID()
local parent = EntityGetRootEntity( entity )
local x, y = EntityGetTransform( entity )
AddStatusIcon(entity, "Wither", "data/ui_gfx/status_indicators/wither.png")

AdjustEntityDamageMultipliers(parent, function(damage_table) 
	for k, v in pairs(damage_table)do
		damage_table[k] = v + 0.2
	end
	return damage_table
end)