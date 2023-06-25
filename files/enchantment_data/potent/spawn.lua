dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

local projectile_comps = EntityGetComponentIncludingDisabled(projectile_entity, "ProjectileComponent") or {}
for k, v in pairs(projectile_comps)do
	local explosion_radius = ComponentObjectGetValue2(v, "config_explosion", "explosion_radius")
	ComponentObjectSetValue2(v, "config_explosion", "explosion_radius", explosion_radius * 1.5)
	local on_death_emit_particle_count = ComponentGetValue2(v, "on_death_emit_particle_count")
	ComponentSetValue2(v, "on_death_emit_particle_count", on_death_emit_particle_count * 2)
end

local particle_emitter_components = EntityGetComponentIncludingDisabled(projectile_entity, "ParticleEmitterComponent") or {}
for k, v in pairs(particle_emitter_components)do
	local count_min = ComponentGetValue2(v, "count_min")
	local count_max = ComponentGetValue2(v, "count_max")
	ComponentSetValue2(v, "count_min", count_min * 1.5)
	ComponentSetValue2(v, "count_max", count_max * 1.5)
	local image_animation_speed = ComponentGetValue2(v, "image_animation_speed")
	ComponentSetValue2(v, "image_animation_speed", image_animation_speed * 1.5)
end

local magic_convert_material_components = EntityGetComponentIncludingDisabled(projectile_entity, "MagicConvertMaterialComponent") or {}
for k, v in pairs(magic_convert_material_components)do
	local radius = ComponentGetValue2(v, "radius")
	ComponentSetValue2(v, "radius", radius * 1.5)
end

local material_sea_spawner_component = EntityGetFirstComponent(projectile_entity, "MaterialSeaSpawnerComponent")
if(material_sea_spawner_component ~= nil)then
	local size_x, size_y = ComponentGetValue2(material_sea_spawner_component, "size")
	ComponentSetValue2(material_sea_spawner_component, "size", size_x * 1.5, size_y * 1.5)
	ComponentSetValue2(material_sea_spawner_component, "offset", (size_x * 1.5) / 2, 0)
end