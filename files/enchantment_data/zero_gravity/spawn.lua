dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

local velocity = EntityGetFirstComponentIncludingDisabled( projectile_entity, "VelocityComponent" );
if velocity ~= nil then
	ComponentAdjustValues( velocity, { 
		gravity_y = function(value) 
			return 0; 
		end,
		air_friction = function(value) 
			return value / 2; 
		end,
	});
end