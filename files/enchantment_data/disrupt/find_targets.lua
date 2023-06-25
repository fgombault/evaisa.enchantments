dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
dofile("data/scripts/lib/utilities.lua")
local pretty_print = dofile("mods/evaisa.enchantments/files/scripts/pretty_print.lua")
local child = GetUpdatedEntityID()
local entity = EntityGetParent(child)
local x, y = EntityGetTransform( entity )

local valid_herds = {
	robot = true
}

local hit = PredictProjectileTarget(entity, function(hitinfo)
	if(valid_herds[HerdIdToString(EntityGetHerdID( hitinfo.target ))])then
		--pretty_print.table(hitinfo)
		local col_x, col_y = hitinfo.collision.x, hitinfo.collision.y
		if(not GameHasEntityFlagRun(child, "disrupt_damage_boosted"))then
			adjust_all_entity_damage(entity, function(damage)
				return damage * 1.5
			end)
			GameAddEntityFlagRun(child, "disrupt_damage_boosted")
		end
	end
end)

if(not hit)then
	if(GameHasEntityFlagRun(child, "disrupt_damage_boosted"))then
		adjust_all_entity_damage(entity, function(damage)
			return damage / 1.5
		end)
		GameRemoveEntityFlagRun(child, "disrupt_damage_boosted")
	end
end