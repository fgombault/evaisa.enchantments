dofile("mods/evaisa.enchantments/files/scripts/enchantment_utils.lua")
dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
dofile("mods/evaisa.enchantments/files/scripts/flags.lua")

local t = GameGetRealWorldTimeSinceStarted();
local now = GameGetFrameNum();

local player_entity = GetUpdatedEntityID();
local x, y = EntityGetTransform( player_entity );

if now % 10 == 0 then
	local entities = EntityGetInRadiusWithTag( x, y, 500, "card_action" )
	for k, v in ipairs(entities)do
		if(not EntityHasTag(v, "has_enchantments"))then
			local action_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemActionComponent")
			if(action_comp ~= nil)then
				local cost = EntityGetFirstComponentIncludingDisabled(v, "ItemCostComponent")
				if(cost == nil)then

					local action_id = ComponentGetValue2(action_comp, "action_id")
					local enchantments_added = AssignEnchantment(v, "heavy", Random(1, 3))
					EntityAddTag(v, "has_enchantments")

				end
			end
		end
	end
end
