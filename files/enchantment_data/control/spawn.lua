dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

MultiplyEntityLifetime(projectile_entity, 4, 120, true)