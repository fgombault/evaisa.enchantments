local old_spawn_hp = spawn_hp
function spawn_hp( x, y )
    old_spawn_hp(x, y)

	dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
	dofile("mods/evaisa.enchantments/files/scripts/flags.lua")

	--print("Spawning enchantment table")
	if(HasSettingFlag(FLAGS.enable_alt_altar_placement))then
		EntityLoad("mods/evaisa.enchantments/files/entities/enchantment_table/entity_temple.xml", x - 100, y + 41)
	--end
	else
		EntityLoad("mods/evaisa.enchantments/files/entities/enchantment_table/entity_temple.xml", x + 100, y + 41)
	end
	
end