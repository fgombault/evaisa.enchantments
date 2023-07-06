dofile_once("mods/evaisa.enchantments/files/scripts/coroutines.lua")
dofile_once( "mods/evaisa.enchantments/files/scripts/utils.lua" )
dofile_once( "mods/evaisa.enchantments/files/scripts/gui_utils.lua" )
dofile_once( "mods/evaisa.enchantments/files/scripts/enchantment_utils.lua" )
dofile_once( "data/scripts/gun/gun_actions.lua" )

local card = GetUpdatedEntityID()

gui = gui or GuiCreate()

GuiStartFrame( gui )
local mx, my = GuiGetMousePosition(gui)

current_id = 6436

local this = GetUpdatedComponentID()

function new_id()
    current_id = current_id + 1
    return current_id
end

local function get_inventory_position(entity)
	local item_component = EntityGetFirstComponentIncludingDisabled(entity, "ItemComponent")
	return ComponentGetValue2(item_component, "inventory_slot")
end

local function get_wand_sprite_size(gui, entity)
	local ability_component = EntityGetFirstComponentIncludingDisabled(entity, "AbilityComponent")
	local sprite = ComponentGetValue2(ability_component, "sprite_file")

	return GuiGetImageDimensions( gui, sprite )
end


local function is_inventory_open()
	local player = EntityGetWithTag("player_unit")[1]
	if player then
		local inventory_gui_component = EntityGetFirstComponentIncludingDisabled(player, "InventoryGuiComponent")
		if inventory_gui_component then
			return ComponentGetValue2(inventory_gui_component, "mActive")
		end
	end
	return false
end

local function inventory_ui_position()
	local player = EntityGetWithTag("player_unit")[1]
	if player then
		local inventory_component = EntityGetFirstComponentIncludingDisabled(player, "InventoryComponent")
		if inventory_component then
			return ComponentGetValue2(inventory_component, "ui_position_on_screen")
		end
	end
	return nil
end

local function entity_is_wand(entity_id)
    local ability_component = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
    return ComponentGetValue2(ability_component, "use_gun_script") == true
end

local function entity_is_player(entity_id)
	return EntityHasTag(entity_id, "player_unit")
end

if(is_inventory_open())then
	local parent = EntityGetParent( card )
	
	if(parent ~= nil and parent ~= 0 and entity_is_player(EntityGetRootEntity(parent)))then
		local slot_side = 20

		local slot_x, slot_y = get_inventory_position(card)
		if(EntityGetName(parent) == "inventory_full")then
			-- Is in the spell inventory
			
			local inv_full_offset_x = 190
			local inv_full_offset_y = 20

			local x = inv_full_offset_x + (slot_x * slot_side)
			local y = inv_full_offset_y + (slot_y * slot_side)

			GuiImage( gui, new_id(), x, y, "data/ui_gfx/debug_marker.png", 1,1,1)


		elseif(entity_is_wand(parent))then

			local parent_slot_x, parent_slot_y = get_inventory_position(parent)

			local wands = EntityGetAllChildren( EntityGetParent(parent) ) or {}

			if(parent_slot_x ~= nil)then

				local inv_quick_offset_x = 25
				local inv_quick_offset_y = 77
				local inv_quick_wand_gap_y_base = 39 -- base if wand sprite y is <= 6pixels...

				local extra_offset = 0

				
				for k, v in pairs(wands)do
					local wand_x, wand_y = get_inventory_position(v)

					local im_x, im_y = get_wand_sprite_size(gui, v)

					if(wand_x <= parent_slot_x)then
						if(im_y > 6)then
							extra_offset = extra_offset + ((im_y - 6) * 2)
						end
					end
				end


				local x = inv_quick_offset_x + (slot_x * slot_side)
				local y = inv_quick_offset_y + (parent_slot_x * (inv_quick_wand_gap_y_base + slot_side)) +
				extra_offset

				GuiImage( gui, new_id(), x, y, "data/ui_gfx/debug_marker.png", 1,1,1)

	
			end
			-- Is in a wand
		end
	end
end
