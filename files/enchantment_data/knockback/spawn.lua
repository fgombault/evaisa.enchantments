dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

local projectile_comp = EntityGetFirstComponentIncludingDisabled( projectile_entity, "ProjectileComponent" )
if projectile_comp ~= nil then
	local knockback = ComponentGetValue2( projectile_comp, "knockback_force" )
	ComponentSetValue2( projectile_comp, "knockback_force", knockback + 100 )
	-- add 50k to physics impulse force on projectile component
	local physics_impulse_coeff = ComponentGetValue2( projectile_comp, "physics_impulse_coeff" )
	ComponentSetValue2( projectile_comp, "physics_impulse_coeff", physics_impulse_coeff + 10000 )

	local ragdoll_force_multiplier = ComponentGetValue2( projectile_comp, "ragdoll_force_multiplier" )
	ComponentSetValue2( projectile_comp, "ragdoll_force_multiplier", ragdoll_force_multiplier + 10 )

end


EntityAddComponent2(projectile_entity, "HitEffectComponent", {
	effect_hit="LOAD_CHILD_ENTITY",
	value_string="mods/evaisa.enchantments/files/enchantment_data/knockback/oiled.xml"
})