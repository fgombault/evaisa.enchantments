function literalize(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
end

local spell_eater_content = ModTextFileGetContent("mods/noita-together/files/scripts/spell_eater.lua")

local spell_eater_content = spell_eater_content:gsub(literalize("local item_component = EntityGetFirstComponent(spell_id, \"ItemActionComponent\")"), [[
	local item_component = EntityGetFirstComponent(spell_id, "ItemActionComponent")
	dofile_once("mods/evaisa.enchantments/files/scripts/utils.lua")
	local enchantment_string = EntityGetVariable(spell_id, "enchantments", "string") or ""
]])

local spell_eater_content = spell_eater_content:gsub(literalize("local item_component = EntityGetFirstComponentIncludingDisabled(child, \"ItemActionComponent\")"), [[
	local item_component = EntityGetFirstComponentIncludingDisabled(child, "ItemActionComponent")
	dofile_once("mods/evaisa.enchantments/files/scripts/utils.lua")
	local enchantment_string = EntityGetVariable(child, "enchantments", "string") or ""
]])

-- replace "id=action_id, usesRemaining=-1" with "id=action_id, usesRemaining=-1, enchantments = enchantment_string"
local spell_eater_content = spell_eater_content:gsub(literalize("id=action_id, usesRemaining=-1"), [[id=action_id..";"..enchantment_string, usesRemaining=-1]])
local spell_eater_content = spell_eater_content:gsub(literalize("id=action_id, usesRemaining=uses_remaining"), [[id=action_id..";"..enchantment_string, usesRemaining=uses_remaining]])

ModTextFileSetContent("mods/noita-together/files/scripts/spell_eater.lua", spell_eater_content)

local spell_spitter_content = ModTextFileGetContent("mods/noita-together/files/scripts/spell_spitter.lua")

local spell_spitter_content = spell_spitter_content:gsub(literalize([[local action_entity_id = CreateItemActionEntity( action_id )]]), 
[[
	local spell_data = {}
	for token in string.gmatch(action_id, "[^;]+") do
		table.insert(spell_data, token)
	end
	
	local action_entity_id = CreateItemActionEntity( spell_data[1] )
]])

local spell_spitter_content = spell_spitter_content:gsub(literalize([[local action_entity_id = CreateItemActionEntity(item.gameId, x, y)]]), 
[[
	local spell_data = {}
	for token in string.gmatch(item.gameId, "[^;]+") do
		table.insert(spell_data, token)
	end
	
	local action_entity_id = CreateItemActionEntity(spell_data[1], x, y)
]])

local spell_spitter_content = spell_spitter_content:gsub(literalize("local item_comp = EntityGetFirstComponentIncludingDisabled(action_entity_id, \"ItemComponent\")"), [[
	local item_comp = EntityGetFirstComponentIncludingDisabled(action_entity_id, "ItemComponent")
	if(spell_data[2])then
		dofile_once("mods/evaisa.enchantments/files/scripts/utils.lua")
		dofile_once("mods/evaisa.enchantments/files/scripts/enchantment_utils.lua")
		EntitySetVariable(action_entity_id, "enchantments", "string", spell_data[2] )
		AppendEnchantmentString(action_entity_id)
	end
	EntityAddTag(action_entity_id, "has_enchantments")
]])

local spell_spitter_content = spell_spitter_content:gsub(literalize(
[[
	if action_entity_id ~= 0 then
		EntityAddChild( entity_id, action_entity_id )
		EntitySetComponentsWithTagEnabled( action_entity_id, "enabled_in_world", false )
	end
]]), 
[[
	if action_entity_id ~= 0 then
		EntityAddChild( entity_id, action_entity_id )
		EntitySetComponentsWithTagEnabled( action_entity_id, "enabled_in_world", false )
		return action_entity_id
	end
]])


local spell_spitter_content = spell_spitter_content:gsub(literalize("AddGunActionPermanent(wand_entity, spell.gameId)"), [[
	local spell_data = {}
	for token in string.gmatch(spell.gameId, "[^;]+") do
		table.insert(spell_data, token)
	end

	AddGunActionPermanent(wand_entity, spell_data[1])
]])

local spell_spitter_content = spell_spitter_content:gsub(literalize("AddGunActionWithUses(wand_entity, spell.gameId, spell.usesRemaining)"), [[
	local spell_data = {}
	for token in string.gmatch(spell.gameId, "[^;]+") do
		table.insert(spell_data, token)
	end
	
	local loaded_action = AddGunActionWithUses(wand_entity, spell_data[1], spell.usesRemaining)
	if(spell_data[2])then
		dofile_once("mods/evaisa.enchantments/files/scripts/utils.lua")
		dofile_once("mods/evaisa.enchantments/files/scripts/enchantment_utils.lua")
		EntitySetVariable(loaded_action, "enchantments", "string", spell_data[2] )
		AppendEnchantmentString(loaded_action)
		
	end
	EntityAddTag(loaded_action, "has_enchantments")
]])

local spell_spitter_content = spell_spitter_content:gsub(literalize([[AddGunActionWithUses(wand_entity, spell.gameId, spell.usesRemaining)]]),
[[
	local spell_data = {}
	for token in string.gmatch(item.gameId, "[^;]+") do
		table.insert(spell_data, token)
	end
	AddGunActionWithUses(wand_entity, spell_data[1], spell.usesRemaining)
]]
)

--print(spell_spitter_content)

ModTextFileSetContent("mods/noita-together/files/scripts/spell_spitter.lua", spell_spitter_content)

local ui_content = ModTextFileGetContent("mods/noita-together/files/scripts/ui.lua")



local ui_content = ui_content:gsub(literalize([[item.gameId]]),"spell_data[1]")

local ui_content = ui_content:gsub(literalize([[value.gameId]]),"spell_data[1]")

local ui_content = ui_content:gsub(literalize([[b.gameId]]),"spell_data_a[1]")

local ui_content = ui_content:gsub(literalize([[b.gameId]]),"spell_data_b[1]")


local ui_content = ui_content:gsub(literalize([[for _, item in ipairs(BankItems) do]]),[[
	for _, item in ipairs(BankItems) do
		local spell_data = {}
		if(item.gameId ~= nil)then
			for token in string.gmatch(item.gameId, "[^;]+") do
				table.insert(spell_data, token)
			end
		end
]])

local ui_content = ui_content:gsub(literalize([[for _, item in ipairs(idk) do]]),[[
	for _, item in ipairs(idk) do
		local spell_data = {}
		if(item.gameId ~= nil)then
			for token in string.gmatch(item.gameId, "[^;]+") do
				table.insert(spell_data, token)
			end
		end
]])

local ui_content = ui_content:gsub(literalize([[local function draw_item_sprite(item, x,y)]]),[[
	local function draw_item_sprite(item, x,y)
		local spell_data = {}
		if(item.gameId ~= nil)then
			for token in string.gmatch(item.gameId, "[^;]+") do
				table.insert(spell_data, token)
			end
		end
]])


local ui_content = ui_content:gsub(literalize([[GuiTooltip(gui, spell.name, spell_description)]]),[[
	local spell_name = spell.name
	if(spell_data[2] ~= nil)then
		dofile_once("mods/evaisa.enchantments/files/scripts/utils.lua")
		dofile_once("mods/evaisa.enchantments/files/scripts/enchantment_utils.lua")
		local enchantment_string = GetEnchantmentString(spell_data[2])
		spell_name = enchantment_string..spell_name
	end
	GuiTooltip(gui, spell_name, spell_description)
]])


local ui_content = ui_content:gsub(literalize([[table.sort(BankItems, function (a, b)]]),[[
	table.sort(BankItems, function (a, b)
		local spell_data_a = {}
		for token in string.gmatch(a.gameId, "[^;]+") do
			table.insert(spell_data, token)
		end
		local spell_data_b = {}
		for token in string.gmatch(b.gameId, "[^;]+") do
			table.insert(spell_data, token)
		end
]])

local ui_content = ui_content:gsub(literalize([[for index, value in ipairs(deck) do]]),[[
	for index, value in ipairs(deck) do
		local spell_data = {}
		if(value.gameId ~= nil)then
			for token in string.gmatch(value.gameId, "[^;]+") do
				table.insert(spell_data, token)
			end
		end
]])

local ui_content = ui_content:gsub(literalize([[for index, value in ipairs(always_casts) do]]),[[
	for index, value in ipairs(always_casts) do
		local spell_data = {}
		if(value.gameId ~= nil)then
			for token in string.gmatch(value.gameId, "[^;]+") do
				table.insert(spell_data, token)
			end
		end
]])

ModTextFileSetContent("mods/noita-together/files/scripts/ui.lua", ui_content)