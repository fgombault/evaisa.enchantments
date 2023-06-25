local entity = EntityGetRootEntity(GetUpdatedEntityID())
local entity_center_x, entity_center_y = EntityGetFirstHitboxCenter( entity )
dofile("data/scripts/lib/utilities.lua")

SetRandomSeed(entity_center_x + GameGetFrameNum(), entity_center_y + GameGetFrameNum())

local damage_model_component = EntityGetFirstComponent( entity, "DamageModelComponent" )
if damage_model_component ~= nil then
	
	if(Random(1, 100) <= 10)then
		EntityKill(GetUpdatedEntityID())
	end

	EntityLoad("mods/evaisa.enchantments/files/enchantment_data/bleed/bleed_projectile.xml", entity_center_x, entity_center_y )
	EntityInflictDamage( entity, 0.025, "DAMAGE_SLICE", "bleed", "NONE", 0, 0, entity, entity_center_x, entity_center_y, 0 )
end