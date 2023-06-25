dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

if(EntityHasTag(projectile_entity, "frost_aspect"))then
	local comps = EntityGetComponent(projectile_entity, "MagicConvertMaterialComponent", "frost_aspect") or {}
	for k, v in ipairs(comps)do
		local radius = ComponentGetValue2(v, "radius") * 1.5
		ComponentSetValue2(v, "radius", radius)
	end
end

if(not EntityHasTag(projectile_entity, "frost_aspect"))then
	EntityLoadToEntity( "mods/evaisa.enchantments/files/enchantment_data/frost/transform_ice.xml", projectile_entity )
	EntityAddTag(projectile_entity, "frost_aspect")
end