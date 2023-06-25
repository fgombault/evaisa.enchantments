dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

local projectile_comps = EntityGetComponent(projectile_entity, "ProjectileComponent") or {}
for k, projectile_comp in ipairs(projectile_comps)do
	local projectile_damage = ComponentGetValue2(projectile_comp, "damage") * 0.8
	ComponentSetValue2(projectile_comp, "damage", projectile_damage)

	local explosion_damage = ComponentObjectGetValue2(projectile_comp, "config_explosion", "damage") * 0.8
	ComponentObjectSetValue2(projectile_comp, "config_explosion", "damage", explosion_damage)
	
	local special_damage = ComponentObjectGetMembers( projectile_comp, "damage_by_type" )
	for k, v in pairs(special_damage)do
		local damage = tonumber(v) * 0.8
		ComponentObjectSetValue2( projectile_comp, "damage_by_type", k, damage )
	end
end