dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

local projectile_comps = EntityGetComponentIncludingDisabled(projectile_entity, "ProjectileComponent")
for k, projectile_comp in ipairs(projectile_comps)do
	local projectile_damage = ComponentGetValue2(projectile_comp, "damage") * 0.5
	ComponentSetValue2(projectile_comp, "damage", projectile_damage)

	local explosion_damage = ComponentObjectGetValue2(projectile_comp, "config_explosion", "damage") * 0.5
	ComponentObjectSetValue2(projectile_comp, "config_explosion", "damage", explosion_damage)
	
	local special_damage = ComponentObjectGetMembers( projectile_comp, "damage_by_type" )
	for k, v in pairs(special_damage)do
		local damage = tonumber(v) * 0.5
		ComponentObjectSetValue2( projectile_comp, "damage_by_type", k, damage )
	end
end

local x, y, r, sx, sy = EntityGetTransform( projectile_entity )
local scale = 0.1
EntityApplyTransform( projectile_entity, x, y, r, sx * scale, sy * scale )

local sprite_components = EntityGetComponentIncludingDisabled( projectile_entity, "SpriteComponent" ) or {}

for k, v in ipairs( sprite_components ) do
	if(ComponentGetValue2(v, "has_special_scale"))then
		local special_scale_x = ComponentGetValue2(v, "special_scale_x")
		local special_scale_y = ComponentGetValue2(v, "special_scale_y")

		ComponentSetValue2(v, "special_scale_x", special_scale_x * scale)
		ComponentSetValue2(v, "special_scale_y", special_scale_y * scale)
	end
end

local particle_emitters = EntityGetComponentIncludingDisabled( projectile_entity, "ParticleEmitterComponent" ) or {}

for k, v in ipairs( particle_emitters ) do
	local x_vel_min = ComponentGetValue2(v, "x_vel_min")
	local x_vel_max = ComponentGetValue2(v, "x_vel_max")
	local y_vel_min = ComponentGetValue2(v, "y_vel_min")
	local y_vel_max = ComponentGetValue2(v, "y_vel_max")

	local x_pos_offset_min = ComponentGetValue2(v, "x_pos_offset_min")
	local x_pos_offset_max = ComponentGetValue2(v, "x_pos_offset_max")
	local y_pos_offset_min = ComponentGetValue2(v, "y_pos_offset_min")
	local y_pos_offset_max = ComponentGetValue2(v, "y_pos_offset_max")

	local area_circle_radius_a, area_circle_radius_b = ComponentGetValue2(v, "area_circle_radius")

	local lifetime_min = ComponentGetValue2(v, "lifetime_min")
	local lifetime_max = ComponentGetValue2(v, "lifetime_max")

	local emission_interval_min_frames = ComponentGetValue2(v, "emission_interval_min_frames")
	local emission_interval_max_frames = ComponentGetValue2(v, "emission_interval_max_frames")
	
	ComponentSetValue2(v, "x_vel_min", x_vel_min * scale)
	ComponentSetValue2(v, "x_vel_max", x_vel_max * scale)
	ComponentSetValue2(v, "y_vel_min", y_vel_min * scale)
	ComponentSetValue2(v, "y_vel_max", y_vel_max * scale)

	ComponentSetValue2(v, "x_pos_offset_min", x_pos_offset_min * scale)
	ComponentSetValue2(v, "x_pos_offset_max", x_pos_offset_max * scale)
	ComponentSetValue2(v, "y_pos_offset_min", y_pos_offset_min * scale)
	ComponentSetValue2(v, "y_pos_offset_max", y_pos_offset_max * scale)

	ComponentSetValue2(v, "area_circle_radius", area_circle_radius_a * scale, area_circle_radius_b * scale)

	ComponentSetValue2(v, "lifetime_min", lifetime_min * scale)
	ComponentSetValue2(v, "lifetime_max", lifetime_max * scale)

	ComponentSetValue2(v, "emission_interval_min_frames", emission_interval_min_frames * scale)
	ComponentSetValue2(v, "emission_interval_max_frames", emission_interval_max_frames * scale)
end

local sprite_particle_emitters = EntityGetComponentIncludingDisabled( projectile_entity, "SpriteParticleEmitterComponent" ) or {}

for k, v in ipairs(sprite_particle_emitters)do
	local lifetime = ComponentGetValue2(v, "lifetime")

	local count_min = ComponentGetValue2(v, "count_min")
	local count_max = ComponentGetValue2(v, "count_max")

	local scale = ComponentGetValue2(v, "scale")

	local randomize_lifetime = ComponentGetValue2(v, "randomize_lifetime")
	local randomize_position = ComponentGetValue2(v, "randomize_position")
	local randomize_velocity = ComponentGetValue2(v, "randomize_velocity")
	local randomize_scale = ComponentGetValue2(v, "randomize_scale")

	ComponentSetValue2(v, "lifetime", lifetime * scale)

	ComponentSetValue2(v, "count_min", count_min * scale)
	ComponentSetValue2(v, "count_max", count_max * scale)

	ComponentSetValue2(v, "scale", scale * scale)

	ComponentSetValue2(v, "randomize_lifetime", randomize_lifetime * scale)
	ComponentSetValue2(v, "randomize_position", randomize_position * scale)
	ComponentSetValue2(v, "randomize_velocity", randomize_velocity * scale)
	ComponentSetValue2(v, "randomize_scale", randomize_scale * scale)
end