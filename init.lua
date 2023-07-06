local pretty_print = dofile("mods/evaisa.enchantments/files/scripts/pretty_print.lua")



function OnPlayerSpawned(player)
	if GameHasFlagRun("enchantments_init") then
		return
	end
	GameAddFlagRun("enchantments_init")

	EntityAddComponent(player, "LuaComponent", {
		execute_every_n_frame = "1",
		execute_on_added = "1",
		script_source_file = "mods/evaisa.enchantments/files/scripts/player_update.lua",
	});

	-- local x, y = EntityGetTransform(player)
	--
	-- EntityLoad("mods/evaisa.enchantments/files/entities/enchantment_table/entity.xml", x + 420, y)

	--[[
	local wallet_component = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
	ComponentSetValue2(wallet_component, "money", 5000)
	]]

	dofile("data/scripts/gun/gun.lua")
end

function OnMagicNumbersAndWorldSeedInitialized()
	if (ModIsEnabled("noita-together")) then
		dofile("mods/evaisa.enchantments/files/scripts/noita_together.lua")
	end
	ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/evaisa.enchantments/files/scripts/actions.lua")
end

ModLuaFileAppend("data/scripts/biomes/temple_altar.lua", "mods/evaisa.enchantments/files/scripts/spawn_holy_mountain.lua")
ModLuaFileAppend("data/scripts/biomes/boss_arena.lua", "mods/evaisa.enchantments/files/scripts/spawn_holy_mountain.lua")
ModLuaFileAppend("data/scripts/items/drop_money.lua",
	"mods/evaisa.enchantments/files/enchantment_data/looting/gold_drop.lua")
ModMaterialsFileAdd("mods/evaisa.enchantments/files/scripts/materials.xml")
