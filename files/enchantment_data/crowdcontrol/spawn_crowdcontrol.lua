dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
dofile( "data/scripts/lib/utilities.lua" )
function damage_received( damage, message, entity_thats_responsible, is_fatal  )
	local target = GetUpdatedEntityID()
	local x, y = EntityGetTransform(target)

	if(is_fatal)then
		EntityLoad("mods/evaisa.enchantments/files/enchantment_data/crowdcontrol/spawn_gas.xml", x, y)
	end
end