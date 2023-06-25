dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

local x, y = EntityGetTransform(projectile_entity)
local entity = EntityLoad("mods/evaisa.enchantments/files/enchantment_data/smite/entity.xml", x, y)
EntityAddChild(projectile_entity, entity)