dofile("mods/evaisa.enchantments/files/scripts/enchantment_utils.lua")
dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
dofile("mods/evaisa.enchantments/files/scripts/flags.lua")

local t = GameGetRealWorldTimeSinceStarted();
local now = GameGetFrameNum();

local player_entity = GetUpdatedEntityID();
local x, y = EntityGetTransform( player_entity );

if now % 10 == 0 then
	SetRandomSeed(x + GameGetFrameNum() + StatsGetValue("world_seed"), y + GameGetFrameNum() + StatsGetValue("world_seed"))
	local card_entities = EntityGetInRadiusWithTag( x, y, 500, "card_action" )
	for k, v in ipairs(card_entities)do
		if(not EntityHasTag(v, "has_enchantments"))then
			local action_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemActionComponent")
			if(action_comp ~= nil)then
				local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
				if(item_comp ~= nil and ComponentGetValue2(item_comp, "permanently_attached") == false)then
				
					if(HasSettingFlag(FLAGS.enable_random_enchantments))then
						if(Random(1, 100) < (ModSettingGet(FLAGS.random_enchantment_chance) or 10))then
							local enchantments_added = AssignRandomEnchantments(v, Random(1, (ModSettingGet(FLAGS.max_random_enchantments) or 2)))
							EntityAddTag(v, "has_enchantments")
						else
							AppendEnchantmentString(v)
							EntityAddTag(v, "has_enchantments")
						end
					else
						AppendEnchantmentString(v)
						EntityAddTag(v, "has_enchantments")
					end
				end
			end
		end
	end
	local wand_entities = EntityGetInRadiusWithTag( x, y, 500, "wand" )
	for k, wand in ipairs(wand_entities)do
		local cards = EntityGetAllChildren(wand) or {}
		for k, v in ipairs(cards)do
			if(not EntityHasTag(v, "has_enchantments") and EntityHasTag(v, "card_action"))then
				local action_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemActionComponent")
				if(action_comp ~= nil)then
					local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
					if(item_comp ~= nil and ComponentGetValue2(item_comp, "permanently_attached") == false)then
						
						if(HasSettingFlag(FLAGS.enable_random_enchantments))then
							if(Random(1, 100) < (ModSettingGet(FLAGS.random_enchantment_chance) or 10))then
								local enchantments_added = AssignRandomEnchantments(v, Random(1, (ModSettingGet(FLAGS.max_random_enchantments) or 2)))
								EntityAddTag(v, "has_enchantments")
							else
								AppendEnchantmentString(v)
								EntityAddTag(v, "has_enchantments")
							end
						else
							AppendEnchantmentString(v)
							EntityAddTag(v, "has_enchantments")
						end
					end
				end
			end
		end
	end
end
