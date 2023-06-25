dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
dofile( "data/scripts/lib/utilities.lua" )
function damage_received( damage, message, entity_thats_responsible, is_fatal  )
	local target = GetUpdatedEntityID()
	local x, y = EntityGetTransform(target)

	local mWhoShot = EntityGetVariable(target, "mWhoShot", "int")

	if(mWhoShot == nil or mWhoShot == 0 or EntityGetIsAlive(mWhoShot) == false)then
		return
	end

	local who_shot_x, who_shot_y = EntityGetTransform(mWhoShot)
	
	EntityLoad("mods/evaisa.enchantments/files/enchantment_data/leech/heal.xml", who_shot_x, who_shot_y)
	EntityInflictDamage(mWhoShot, -0.05, "DAMAGE_HEALING", "leech", "NONE", 0, 0, mWhoShot, who_shot_x, who_shot_y, 0)
end