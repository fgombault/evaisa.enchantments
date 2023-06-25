local pretty_print = dofile_once("mods/evaisa.enchantments/files/scripts/pretty_print.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/evaisa.enchantments/files/scripts/coroutines.lua")
dofile_once("mods/evaisa.enchantments/files/scripts/gui_utils.lua")
dofile_once("mods/evaisa.enchantments/files/scripts/enchantment_utils.lua")
local ease = dofile_once("mods/evaisa.enchantments/files/scripts/ease.lua")

local entity = GetUpdatedEntityID()
local pedestal_x, pedestal_y = EntityGetTransform(entity)

-------------- Adjustable Variables --------------

local max_enchantments_per_card = 4
local max_combined_enchantment_levels = 12
local base_cost = 150
local start_level = 0

--------------------------------------------------

local enchantment_count = start_level + tonumber( GlobalsGetValue( "TEMPLE_ENCHANTMENT_COUNT", "0" ) )
local max_enchantment_level = math.min(5, math.floor(2 + (enchantment_count / 3)))
--local max_button_levels = math.floor(4 + (enchantment_count / 3))
local max_individual_cards = math.min(3, math.floor(1 + (enchantment_count / 3)))


local is_temple_altar = EntityHasFlag( entity, "is_temple_altar" )

gui = gui or GuiCreate()

gui_open = gui_open or false

local current_id = 21512352

altar_enchantments = altar_enchantments or {}

altar_enchantments[entity] = altar_enchantments[entity] or {}

GuiStartFrame(gui)

player = player or (EntityGetWithTag("player_unit") ~= nil and EntityGetWithTag("player_unit")[1] or nil)

local screen_width, screen_height = GuiGetScreenDimensions( gui );
GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )

function new_id()
    current_id = current_id + 1
    return current_id
end

local no_spell = false

local spell_card = nil

if(EntityGetAllChildren(entity) ~= nil)then
	spell_card = EntityGetAllChildren(entity)[1]
	if(spell_card == nil)then
		no_spell = true
	end
else
	no_spell = true
end

if(no_spell)then
	EntitySetComponentsWithTagEnabled(entity, "no_spell", true)
	EntitySetComponentsWithTagEnabled(entity, "requires_spell", false)
end

local player_money = 0
local player_wallet = EntityGetFirstComponent(player, "WalletComponent")
if(player_wallet ~= nil)then
	local player_wallet_money = tonumber(ComponentGetValue(player_wallet, "money"))
	if(player_wallet_money ~= nil)then
		player_money = player_wallet_money
	end
end

--[[
local not_enough_money = false

if(no_spell == false)then
	local player_wallet = EntityGetFirstComponent(player, "WalletComponent")
	if(player_wallet ~= nil)then
		local player_wallet_money = tonumber(ComponentGetValue(player_wallet, "money"))
		if(player_wallet_money < cost)then
			EntitySetComponentsWithTagEnabled(entity, "too_expensive", true)
			EntitySetComponentsWithTagEnabled(entity, "disable_when_too_expensive", false)
			
			not_enough_money = true
		end
	else
		not_enough_money = true
	end
end
]]

--[[
local cost_comp = EntityGetFirstComponentIncludingDisabled(entity, "SpriteComponent", "cost")
if(cost_comp ~= nil)then
	ComponentSetValue(cost_comp, "text", " $"..tostring(cost).." ")
	ComponentSetValue2(cost_comp, "offset_x", string.len(" $"..tostring(cost).." ")*2.3)
	EntityRefreshSprite( entity, cost_comp )
end
]]

if(no_spell)then
	return
end

function interacting(entity_who_interacted, entity_interacted, interactable_name)
	SetRandomSeed(pedestal_x + GameGetFrameNum() + StatsGetValue("world_seed"), pedestal_y + GameGetFrameNum() + StatsGetValue("world_seed"))
	if(not_enough_money)then
		EntitySetComponentsWithTagEnabled(entity, "no_spell", true)
		EntitySetComponentsWithTagEnabled(entity, "requires_spell", false)
		EntitySetComponentsWithTagEnabled(entity, "too_expensive", false)
		EntityAddTag(spell_card, "was_just_enchanted")
		
		EntityRemoveTag(entity, "is_enchanting")
		EntityRemoveFromParent(spell_card)
		local item_component = EntityGetFirstComponentIncludingDisabled(spell_card, "ItemComponent")
		ComponentSetValue2(item_component, "is_pickable", true)
		local simple_physics_component = EntityGetFirstComponentIncludingDisabled(spell_card, "SimplePhysicsComponent")
		EntitySetComponentIsEnabled(spell_card, simple_physics_component, true)

		edit_component( spell_card, "VelocityComponent", function(comp,vars)
			local time  = GameGetFrameNum() / 60.0
			local angle = math.sin(time * 5)
			local vel_x = math.cos(angle) * 30
			local vel_y = -80
			
			ComponentSetValue2( comp, "mVelocity", vel_x, vel_y)
		end)

		spell_card = nil

		gui_open = false
		GuiDestroy( gui )
		gui = nil
		return
	end
	if(EntityHasTag(entity, "is_enchanting"))then
		player = entity_who_interacted
		EntitySetComponentsWithTagEnabled(entity, "disable_while_enchanting", false)
		gui_open = true
	else
		gui_open = false
	end
end

local random_strings = {
    "air",
	"animal",
	"baguette",
	"ball",
	"beast",
	"berata",
	"bless",
	"cold",
	"creature",
	"cthulhu",
	"cube",
	"curse",
	"darkness",
	"demon",
	"destroy",
	"dry",
	"earth",
	"elder",
	"elemental",
	"embiggen",
	"enchant",
	"fhtagn",
	"fiddle",
	"fire",
	"free",
	"fresh",
	"galvanize",
	"grow",
	"hot",
	"humanoid",
	"ignite",
	"imbue",
	"inside",
	"klaatu",
	"light",
	"limited",
	"mental",
	"mglwnafh",
	"niktu",
	"of",
	"other",
	"phnglui",
	"physical",
	"range",
	"rlyeh",
	"scrolls",
	"self",
	"shorten",
	"shrink",
	"snuff",
	"sphere",
	"spirit",
	"stale",
	"stretch",
	"the",
	"towards",
	"twist",
	"undead",
	"water",
	"wet",
	"wgahnagl",
	"xyzzy",
	"noita",
	"wizard",
	"orb",
	"konna",
	"rotta",
}

--print(tostring(gui_open))

transparency_list = transparency_list or {}

-- Draw button on screen for a random enchantment
DrawEnchantmentButton = function(index, x, y, z)

	if(transparency_list[index] == nil)then
		transparency_list[index] = 1
	end

	local enchantments_in_button = altar_enchantments[entity][spell_card][index]

	local button_image = is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/enchantment_button_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/enchantment_button.png"

	if(index == 1)then
		button_image = is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/enchantment_button2_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/enchantment_button2.png"
	elseif(index == 3)then
		button_image = is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/enchantment_button3_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/enchantment_button3.png"
	end
	

	local seed = 0

	for k, v in pairs(enchantments_in_button)do
		for i = 1, #(v[1].id) do
			seed = seed + string.byte(v[1].id, i)
		end	
	end

	--print(tostring(seed))

	SetRandomSeed(seed, seed)

	local enchantments_in_card = GetEnchantmentMap(spell_card)

	local total_card_levels = 0
	local total_card_enchantments = 0

	for k, v in pairs(enchantments_in_card)do
		total_card_enchantments = total_card_enchantments + 1
		total_card_levels = total_card_levels + v[1]
	end

	local total_button_levels = 0
	local total_button_enchantments = 0
	local unique_button_enchantments = 0

	for k, v in pairs(enchantments_in_button)do
		total_button_enchantments = total_button_enchantments + 1
		total_button_levels = total_button_levels + v[2]
		local is_in_card = false
		for k2, v2 in pairs(enchantments_in_card)do
			--pretty_print.table(v2)
			--pretty_print.table(v)
			if(v2[2].id  == v[1].id )then
				is_in_card = true
			end
		end	
		if(not is_in_card)then
			unique_button_enchantments = unique_button_enchantments + 1
		end
	end

	local button_price = base_cost + ((base_cost / 2) * (total_button_enchantments))
	button_price = math.floor(button_price + ((button_price / 2) * (total_button_levels)))


	local too_expensive = false

	local reason = ""

	if(total_card_enchantments + unique_button_enchantments > max_enchantments_per_card)then
		too_expensive = true
		reason = "Too many enchantments"
	end
	
	if(total_card_levels + total_button_levels > max_combined_enchantment_levels)then
		too_expensive = true
		reason = "Too many combined levels"
	end

	if(button_price > player_money)then
		too_expensive = true
		reason = "Not enough money"
	end


	

	local width, height = GuiGetImageDimensions( gui, button_image, 1)

	GuiZSetForNextWidget( gui, z)
	if(GuiImageButton( gui, new_id(), x-(width / 2), y, "", button_image ))then
		if(too_expensive)then
			GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_denied", 0, 0)
			return
		end

		GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)

		-- Apply enchantments
		gui_open = false
		GuiDestroy( gui )
		gui = nil
		local card_x, card_y = EntityGetTransform(spell_card)

		--local particle_emitter = EntityGetFirstComponentIncludingDisabled(entity, "ParticleEmitterComponent")
		--ComponentSetValue2(particle_emitter, "gravity", 0, -20)
		EntitySetComponentsWithTagEnabled(entity, "enable_on_enchant", true)
		EntitySetComponentsWithTagEnabled(entity, "disable_on_enchant", false)

		local sprite_offset_animators = EntityGetComponent(spell_card, "SpriteOffsetAnimatorComponent")

		for k, v in ipairs(sprite_offset_animators)do
			EntitySetComponentIsEnabled(spell_card, v, false)
		end

		local player_wallet = EntityGetFirstComponent(player, "WalletComponent")
		if(player_wallet ~= nil)then
			local player_wallet_money = ComponentGetValue2(player_wallet, "money")
			player_wallet_money = player_wallet_money - button_price
			if(player_wallet_money < 0)then
				player_wallet_money = 0
			end
			ComponentSetValue2(player_wallet, "money", player_wallet_money)
		end

		async(function()

			local lerp_entity = function(ent, end_x, end_y, frames, func)
				local start_x, start_y = EntityGetTransform(ent)
				local start_frames = GameGetFrameNum()
				local end_frames = start_frames + frames
				local current_frame = start_frames

				while(current_frame < end_frames)do
					--local percent = (current_frame - start_frames) / frames
					--local new_x = start_x + (end_x - start_x) * percent
					--local new_y = start_y + (end_y - start_y) * percent

					func(current_frame)

					local percent = (current_frame - start_frames) / frames

					percent = ease.elastic(percent, 5, 6)

					local new_x = evaLerp(end_x, start_x, percent)
					local new_y = evaLerp(end_y, start_y, percent)
					EntityApplyTransform(ent, new_x, new_y)
					current_frame = GameGetFrameNum()
					wait(1)
				end
			end

			local effect = EntityLoad("mods/evaisa.enchantments/files/entities/enchantment_table/enchanting.xml", card_x, card_y)
			EntityAddChild(spell_card, effect)
			local effect_comp = EntityGetFirstComponent(effect, "ParticleEmitterComponent")

			local count = 0
			local count2 = 0

			local frame = 0

			lerp_entity(spell_card, pedestal_x, pedestal_y - 40, 100, function(steps)


				count = count + 1
				count2 = count2 + 1
				frame = frame + 1

				local t = frame / 100

				local count_needed = evaLerp(0, 25, t)

				--GamePrint(count_needed)

				local count_max = ComponentGetValue2(effect_comp, "count_max")
				if(count2 > count_needed)then
					ComponentSetValue2(effect_comp, "count_max", count_max + 1)
					count2 = 0
				end	

				
				local area_circle_radius_min, area_circle_radius_max = ComponentGetValue2(effect_comp, "area_circle_radius")
				if(count > 2)then
					ComponentSetValue2(effect_comp, "area_circle_radius", area_circle_radius_min + 1, area_circle_radius_max + 3)
					local attractor_force = ComponentGetValue2(effect_comp, "attractor_force")
					ComponentSetValue2(effect_comp, "attractor_force", attractor_force + 0.1)
					count = 0
				end

				--local emission_interval_max_frames = ComponentGetValue2(effect_comp, "emission_interval_max_frames")
				--ComponentSetValue2(effect_comp, "emission_interval_max_frames", ((emission_interval_max_frames - 1) < 1) and 1 or (emission_interval_max_frames - 1))
				--wait(10)

			end)



			--wait(60)

			card_x, card_y = EntityGetTransform(spell_card)
			GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/rune/create", card_x, card_y)
			EntityLoad("mods/evaisa.enchantments/files/entities/enchantment_table/enchanted_effect.xml", card_x, card_y - 8)

			EntityKill(effect)

			
			for k, v in ipairs(sprite_offset_animators)do
				EntitySetComponentIsEnabled(spell_card, v, true)
			end
			EntityRemoveFromParent(spell_card)

			AssignEnchantments(spell_card, enchantments_in_button)
			EntitySetComponentsWithTagEnabled(entity, "enable_on_enchant", false)
			EntitySetComponentsWithTagEnabled(entity, "disable_on_enchant", true)
			EntitySetComponentsWithTagEnabled(entity, "disable_while_enchanting", true)
			EntitySetComponentsWithTagEnabled(entity, "no_spell", true)
			EntitySetComponentsWithTagEnabled(entity, "requires_spell", false)
			EntityAddTag(spell_card, "was_just_enchanted")
			
			EntityRemoveTag(entity, "is_enchanting")

			local item_component = EntityGetFirstComponentIncludingDisabled(spell_card, "ItemComponent")
			ComponentSetValue2(item_component, "is_pickable", true)
			local simple_physics_component = EntityGetFirstComponentIncludingDisabled(spell_card, "SimplePhysicsComponent")
			EntitySetComponentIsEnabled(spell_card, simple_physics_component, true)

			edit_component( spell_card, "VelocityComponent", function(comp,vars)
				local time  = GameGetFrameNum() / 60.0
				local angle = math.sin(time * 5)
				local vel_x = math.cos(angle) * 30
				local vel_y = -80
				
				ComponentSetValue2( comp, "mVelocity", vel_x, vel_y)
			end)

			GlobalsSetValue( "TEMPLE_ENCHANTMENT_COUNT", tostring(enchantment_count + 1) )

			spell_card = nil
			gui = nil
			gui_open = nil
			altar_enchantments = nil
			player = nil
			transparency_list = nil
			

		end)
		return
	end

	local level_strings = {
		"I",
		"II",
		"III",
		"IV",
		"V",
		"VI",
		"VII",
		"VIII",
		"IX",
		"X",
		"XI",
		"XII",
		"XIII",
		"XIV",
		"XV",
		"XVI",
		"XVII",
		"XVIII",
		"XIX",
		"XX",
		"XXI",
		"XXII",
		"XXIII",
		"XXIV",
		"XXV",
		"XXVI",
		"XXVII",
		"XXVIII",
		"XXIX",
		"XXX",
	}
	
	local enchantments_strings = {}

	local count_to_show = Random(1, #enchantments_in_button > 1 and #enchantments_in_button - 1 or 1)
	
	local count = #enchantments_in_button * 2
	
	for k, v in ipairs(enchantments_in_button)do

		--pretty_print.table(v)

		if(k > count_to_show)then
			table.insert(enchantments_strings, "???")
		else
			table.insert(enchantments_strings, GameTextGetTranslatedOrNot(v[1].name) .. " " .. level_strings[v[2]])
		end
	end


	--local enchantments_string = actual_enchantments_to_add[1][1].name .. " " .. level_strings[actual_enchantments_to_add[1][2]] .. " ... ?"

	local clicked, right_clicked, hovered, e_x, e_y, e_width, e_height, draw_x, draw_y, draw_width, draw_height = GuiGetPreviousWidgetInfo( gui )

	if(too_expensive)then
		do_custom_tooltip(
			function()
				GuiColorSetForNextWidget( gui, 0, 0, 0, 0.5)
				local text_width, text_height = GuiGetTextDimensions(gui, "Reason: " .. reason, 1, 2)
				GuiText(gui, -text_width, -(text_height / 2), "Too Expensive")
				GuiLayoutBeginHorizontal( gui, 0, 0)
				GuiColorSetForNextWidget( gui, 0, 0, 0, 0.5)
				GuiText(gui, -text_width, 0, "Reason:" )
				GuiColorSetForNextWidget( gui, 0.4, 0, 0, 0.5)
				GuiText(gui, 0, 0, reason )
				GuiLayoutEnd(gui)
			end, -10003, x - 108, y + 16, is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray.png", true, {
				clicked,
				right_clicked,
				hovered,
				e_x,
				e_y,
				e_width,
				e_height,
				draw_x,
				draw_y,
				draw_width,
				draw_height
			}
		)
	end

	local desc_offset_y = 0
	for k, v in ipairs(enchantments_in_button)do
		if(k <= count_to_show)then
			local ench = v[1]
			local name_width, name_height = GuiGetTextDimensions(gui, ench.name, 1, 2)
			local desc_width, desc_height = GuiGetTextDimensions(gui, ench.description, 1, 2)
			desc_offset_y = (name_height + desc_height)/ 2
		end
	end

	do_custom_tooltip(
		function()
			for k, v in ipairs(enchantments_in_button)do
				if(k <= count_to_show)then
					local ench = v[1]
					GuiColorSetForNextWidget(gui, 1, 1, 1, 0.8)
					GuiText(gui, 0, 0, ench.name )
					GuiColorSetForNextWidget(gui, 0.8, 0.8, 0.8, 0.8)
					GuiText(gui, 0, 0, ench.description )
				end
			end
		end, -10003, x + 108, (y + 15) - desc_offset_y, is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray.png", true, {
			clicked,
			right_clicked,
			hovered,
			e_x,
			e_y,
			e_width,
			e_height,
			draw_x,
			draw_y,
			draw_width,
			draw_height
		}
	)


	local lines = 1

	local display_string = ""
	for i = 1, count do
		display_string = display_string .. random_strings[Random(1, #random_strings)]
		if(i % 2 == 0 and i ~= count)then
			display_string = display_string .. "\n"
			lines = lines + 1
		end
	end

	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )

	local colors = {
		{
			(is_temple_altar and 0.23921 or 0.20784), 
			(is_temple_altar and 0.21568 or 0.21568), 
			(is_temple_altar and 0.17254 or 0.27843)
		},
		{
			0.72941, 
			0.46274, 
			1
		},
	}
	

	if(too_expensive)then
		colors = {
			{
				(is_temple_altar and 0.23921 or 0.20784), 
				(is_temple_altar and 0.21568 or 0.21568), 
				(is_temple_altar and 0.17254 or 0.27843)
			},
			{
				0.4, 
				0.0, 
				0.0
			},
		}
	end

	if(hovered)then
		if(transparency_list[index] > 0)then
			transparency_list[index] = transparency_list[index] - 0.02
		end
		if(transparency_list[index] <= 0 )then
			transparency_list[index] = 0.001
		end
		local r, g, b = evaLerp(colors[1][1], colors[2][1], transparency_list[index]), evaLerp(colors[1][2], colors[2][2], transparency_list[index]), evaLerp(colors[1][3], colors[2][3], transparency_list[index])
	
		DrawText(gui, "mods/evaisa.enchantments/files/gfx/fonts/keen", (x-(width / 2)) - 7, (y + (height / 2)) - (lines * (10.35 / 2)), 1.15, z - 1, display_string, string.format("%x", transparency_list[index] * 255)..string.format("%x", r * 255)..string.format("%x", g * 255)..string.format("%x", b * 255), -2)
		--GuiColorSetForNextWidget( gui, 0, 0, 0, 1 - transparency_list[index])
		--GuiText(gui, x, y, tostring(1 - transparency_list[index]))
	
		for k, v in pairs(enchantments_strings)do
			
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiZSetForNextWidget( gui, z - 2)
			GuiColorSetForNextWidget( gui, r, g, b, (1 - transparency_list[index]) > 0 and (1 - transparency_list[index]) or 0.001)
			local w, h = GuiGetTextDimensions( gui, v, 1, 2)
			GuiText(gui, (x-(width / 2)), (y + (height / 2) + ((k - 1) * h)) - (#enchantments_strings * (h / 2)), v)
		end
		---GuiLayoutBeginLayer(gui)
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiColorSetForNextWidget( gui, r, g, b, 1)
		GuiZSetForNextWidget( gui, z - 3)
		local w, h = GuiGetTextDimensions( gui, " $"..tostring(button_price), 1, 2)
		GuiText(gui, ((draw_x + width) - w) + 21, (y + (height - h)) - (h / 2), " $"..tostring(button_price))
		--GuiLayoutEndLayer(gui)
	else
		if(transparency_list[index] < 1)then
			transparency_list[index] = transparency_list[index] + 0.02
		end
		if(transparency_list[index] > 1 )then
			transparency_list[index] = 1
		end
		local r, g, b = evaLerp(colors[1][1], colors[2][1], transparency_list[index]), evaLerp(colors[1][2], colors[2][2], transparency_list[index]), evaLerp(colors[1][3], colors[2][3], transparency_list[index])
	
		DrawText(gui, "mods/evaisa.enchantments/files/gfx/fonts/keen", (x-(width / 2)) + 5, (y + (height / 2)) - (lines * (9 / 2)), 1, z - 1, display_string, string.format("%x", transparency_list[index] * 255)..string.format("%x", r * 255)..string.format("%x", g * 255)..string.format("%x", b * 255), -2)
		--GuiColorSetForNextWidget( gui, 0, 0, 0, 1 - transparency_list[index])
		--GuiText(gui, x, y, tostring(1 - transparency_list[index]))
	
		for k, v in pairs(enchantments_strings)do
			
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiZSetForNextWidget( gui, z - 2)
			GuiColorSetForNextWidget( gui, r, g, b, (1 - transparency_list[index]) > 0 and (1 - transparency_list[index]) or 0.001)
			local w, h = GuiGetTextDimensions( gui, v, 1, 2)
			h = h - 2
			GuiText(gui, (x-(width / 2)) + 11, (y + (height / 2) + ((k - 1) * h)) - (#enchantments_strings * (h / 2)), v)
		end


		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiColorSetForNextWidget( gui, r, g, b, 1)
		GuiZSetForNextWidget( gui, z - 3)
		local w, h = GuiGetTextDimensions( gui, " $"..tostring(button_price), 1, 2)
		GuiText(gui, ((draw_x + width) - w) - 4, ((y + (height - h)) - (h / 2)) - 2, " $"..tostring(button_price))

		-- Simplify the following line as much as possible
		-- local y_position = (y + (height / 2) + ((k - 1) * h)) - (#enchantments_strings * (h / 2))
		
	end



end

if(gui_open)then
	if(player ~= nil and EntityGetIsAlive(player))then
		if(altar_enchantments[entity][spell_card] == nil)then
			altar_enchantments[entity][spell_card] = {}
		end
		if(#altar_enchantments[entity][spell_card] == 0) then
			for i = 1, 3 do
				if(altar_enchantments[entity][spell_card][i] == nil) then
					altar_enchantments[entity][spell_card][i] = {}
				end
				local enchantments_to_add = GetRandomEnchantments(spell_card, Random(1, 3))
				local unique_enchantments = 0
				for k, v in ipairs(enchantments_to_add) do
					--[[if(k > max_button_levels)then
						break
					end]]
					local has_duplicate = false
					for k2, v2 in pairs(altar_enchantments[entity][spell_card][i])do
						if(v.id == v2[1].id)then
							if(v.is_stackable)then
								v2[2] = v2[2] + 1
							end
							has_duplicate = true
						end
					end
					if(not has_duplicate)then
						unique_enchantments = unique_enchantments + 1
						if(unique_enchantments > max_individual_cards)then
							break
						end
						table.insert(altar_enchantments[entity][spell_card][i], {v, v.is_stackable and Random(1, max_enchantment_level) or 1})
					end
				end
			end
		end

		local distance_to_player = 0
		local ply_x, ply_y = EntityGetTransform(player)
		
		distance_to_player = get_distance( pedestal_x, pedestal_y, ply_x, ply_y )

		if(distance_to_player > 40)then
			gui_open = false
			EntitySetComponentsWithTagEnabled(entity, "disable_while_enchanting", true)
			return
		end

	else
		gui_open = false
		GuiDestroy( gui )
		gui = nil
		EntitySetComponentsWithTagEnabled(entity, "disable_while_enchanting", true)
		return
	end

	GuiZSetForNextWidget( gui, -10000)

	GuiImage( gui, new_id(), 0, 0, "mods/evaisa.enchantments/files/entities/enchantment_table/darken.png", 0.8, 10 )

	for i = 1, 3 do
		DrawEnchantmentButton(i, screen_width / 2, ((screen_height / 2) + (i * 50)) - 125 - 20, -10001)
	end
	
		
	local width, height = GuiGetImageDimensions( gui, is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/back_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/back.png", 1)

	GuiZSetForNextWidget( gui, -10001)
	if(GuiImageButton( gui, new_id(), (screen_width / 2)-(width / 2) - 71.8, (screen_height / 2) + 75 - 20, "", is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/back_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/back.png" ))then
		gui_open = false
		EntitySetComponentsWithTagEnabled(entity, "disable_while_enchanting", true)
		GuiDestroy( gui )
		gui = nil
	end

	do_custom_tooltip(
		function()
			GuiColorSetForNextWidget( gui, 0, 0, 0, 0.5)
			GuiText(gui, 0, 0, "Close")
		end, -10003, -60, 6.5, is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray.png"
	) -- -75, 32
	--GuiTooltip(gui, "Close", "")

	GuiZSetForNextWidget( gui, -10001)
	if(GuiImageButton( gui, new_id(), (screen_width / 2)-(width / 2) - 41.8, (screen_height / 2) + 75 - 20, "", is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/retrieve_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/retrieve.png" ))then

		EntitySetComponentsWithTagEnabled(entity, "no_spell", true)
		EntitySetComponentsWithTagEnabled(entity, "requires_spell", false)
		
		EntityAddTag(spell_card, "was_just_enchanted")
		
		EntityRemoveTag(entity, "is_enchanting")
		EntityRemoveFromParent(spell_card)
		local item_component = EntityGetFirstComponentIncludingDisabled(spell_card, "ItemComponent")
		ComponentSetValue2(item_component, "is_pickable", true)
		local simple_physics_component = EntityGetFirstComponentIncludingDisabled(spell_card, "SimplePhysicsComponent")
		EntitySetComponentIsEnabled(spell_card, simple_physics_component, true)

		edit_component( spell_card, "VelocityComponent", function(comp,vars)
			local time  = GameGetFrameNum() / 60.0
			local angle = math.sin(time * 5)
			local vel_x = math.cos(angle) * 30
			local vel_y = -80
			
			ComponentSetValue2( comp, "mVelocity", vel_x, vel_y)
		end)

		EntitySetComponentsWithTagEnabled(entity, "disable_while_enchanting", true)

		spell_card = nil
		gui_open = false
		GuiDestroy( gui )
		gui = nil
		
	end

	do_custom_tooltip(
		function()
			GuiColorSetForNextWidget( gui, 0, 0, 0, 0.5)
			GuiText(gui, 0, 0, "Retrieve Spell")
		end, -10003, 13, 6.5, is_temple_altar and "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray_temple.png" or "mods/evaisa.enchantments/files/entities/enchantment_table/9piece0_gray.png"
	)

	--GuiTooltip(gui, "Retrieve Spell", "")
end