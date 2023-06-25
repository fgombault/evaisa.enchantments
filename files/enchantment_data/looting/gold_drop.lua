dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
local old_do_money_drop = do_money_drop
do_money_drop = function( amount_multiplier, trick_kill )
	local ench_multiplier = EntityGetVariable( GetUpdatedEntityID(), "enchantment_loot_multiplier", "int" )
	if ench_multiplier ~= nil then
		amount_multiplier = amount_multiplier + ench_multiplier
	end
	old_do_money_drop( amount_multiplier, trick_kill )
end