dofile("data/scripts/lib/mod_settings.lua")



local mod_id = "enchantments" -- This should match the name of your mod's folder.
mod_settings_version = 1      -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.
mod_settings =
{
	{
		category_id = "default_settings",
		ui_name = "",
		ui_description = "",
		settings = {
			{
				id = "Version",
				ui_name = "Version: 1.2.0",
				not_setting = true,
			},
			{
				id = "enable_alt_altar_placement",
				ui_name = "Alternative Altar Placement",
				ui_description = "Place the altar on the left side of the water.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "disable_altar",
				ui_name = "Disable Altar",
				ui_description =
				"Disable the altar altogether, enchantments can still spawn with items if Loot Enchantments is enabled.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "enable_random_enchantments",
				ui_name = "Enable Loot Enchantments",
				ui_description = "Allow spells found in the world to have enchantments applied to them.",
				value_default = true,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "random_enchantment_chance",
				ui_name = "Loot Enchantment Chance",
				ui_description = "Chance that found spells will have enchantments.",
				value_default = 10,
				value_min = 0,
				value_max = 100,
				value_display_multiplier = 1,
				value_display_formatting = " $0%",
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "max_random_enchantments",
				ui_name = "Max Loot Enchantments",
				ui_description = "How many enchantments can a found spell have.",
				value_default = 2,
				value_min = 0,
				value_max = 5,
				value_display_multiplier = 1,
				value_display_formatting = " $0",
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			--[[{
				id = "enable_miniboss_beasts",
				ui_name = "Enable Minibosses",
				ui_description = "Enable minibosses, these get multiple special abilities.",
				value_default = true,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "always_blessed",
				ui_name = "Always Blessed",
				ui_description = "Enemies are always blessed.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "multiple_blesses",
				ui_name = "Multiple Blessings",
				ui_description = "Enemies can spawn with multiple blessings.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "bless_chance",
				ui_name = "Bless Chance",
				ui_description = "Chance that enemies will be blessed.",
				value_default = 20,
				value_min = 0,
				value_max = 100,
				value_display_multiplier = 1,
				value_display_formatting = " $0%",
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "miniboss_chance",
				ui_name = "Miniboss Chance",
				ui_description = "Chance that a enemy will become a miniboss.",
				value_default = 10,
				value_min = 0,
				value_max = 100,
				value_display_multiplier = 1,
				value_display_formatting = " $0%",
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "miniboss_threshold",
				ui_name = "Miniboss Threshold",
				ui_description = "Amount of enemies that must be killed before a miniboss can spawn.",
				value_default = 50,
				value_min = 0,
				value_max = 250,
				value_display_multiplier = 1,
				value_display_formatting = " $0",
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "miniboss_healthbar",
				ui_name = "Enable Miniboss Healthbars",
				ui_description = "Give healthbars to minibosses, disable if you are using another healthbar mod.",
				value_default = true,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "miniboss_buff_enabled",
				ui_name = "Enable Miniboss Health Buff",
				ui_description = "Minibosses get a special health buff.",
				value_default = true,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},
			{
				id = "reward_enabled",
				ui_name = "Enable Miniboss Reward",
				ui_description = "Minibosses drop a reward when killed.",
				value_default = true,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
			},]]
		},
	},
}

function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id)
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	-- print("IS THIS RUNNING??")

	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)

	screen_width, screen_height = GuiGetScreenDimensions(gui)

	local id = 2512432
	local function new_id()
		id = id + 1; return id
	end

	GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)

	--GuiLayoutBeginVertical( gui, 0, 0, false, 0, 3 )
	GuiColorSetForNextWidget(gui, 0.8, 0.8, 0.8, 1)
	if (not in_main_menu) then
		dofile("mods/evaisa.enchantments/files/scripts/enchantment_list.lua")
		GuiText(gui, -2, 8, "----- Enchantments ( " .. tostring(#enchantments) .. " Loaded ) -----")
	else
		GuiText(gui, -2, 8, "----- Enchantments -----")
	end
	if (not in_main_menu) then
		dofile("mods/evaisa.enchantments/files/scripts/enchantment_list.lua")
		dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
		dofile("data/scripts/lib/utilities.lua")

		GuiText(gui, 0, 0, " ")

		GuiLayoutBeginHorizontal(gui, 0, 0, false, 15, 10)
		if GuiButton(gui, new_id(), 0, 0, "Enable All") then
			for k, v in ipairs(enchantments) do
				RemoveSettingFlag("enchantments_" .. v.id .. "_disabled")
			end
		end
		if GuiButton(gui, new_id(), 0, 0, "Disable All") then
			for k, v in ipairs(enchantments) do
				AddSettingFlag("enchantments_" .. v.id .. "_disabled")
			end
		end
		GuiLayoutEnd(gui)


		--	GuiBeginScrollContainer( gui, new_id(), 0, 0, 200, 150, true, 2, 2 )
		--GuiLayoutBeginVertical( gui, 0, 0, false, 2, 2 )

		function CustomImageButton(gui, id, x, y, image, scale, alpha)
			hover_index = hover_index or {}
			if (hover_index[id] == nil) then
				hover_index[id] = false
			end
			local old_scale = scale
			if hover_index[id] then
				scale = scale * 1.05
			end
			local w, h = GuiGetImageDimensions(gui, image, scale)
			local old_w, old_h = GuiGetImageDimensions(gui, image, old_scale)
			local x_offset = (w - old_w) / 2
			local y_offset = (h - old_h) / 2
			GuiImage(gui, id, x - x_offset, y - y_offset, image, alpha, scale)
			local clicked, right_clicked, hovered, e_x, e_y, e_width, e_height, draw_x, draw_y, draw_width, draw_height =
			GuiGetPreviousWidgetInfo(gui)
			hover_index[id] = hovered
			return clicked
		end

		crossed_index = 1
		for k, v in ipairs(enchantments) do
			--print("Enchantment: "..v.id)
			GuiLayoutBeginHorizontal(gui, 0, 0, false, 2, 2)

			local w, h = GuiGetImageDimensions(gui, v.icon, 1)
			local scale = 1

			if (h > 9) then
				scale = (9 / h)
			elseif (h < 9) then
				scale = (h / 9)
			end

			if CustomImageButton(gui, new_id(), 0, 0, v.icon, scale, 1) then
				if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
					RemoveSettingFlag("enchantments_" .. v.id .. "_disabled")
				else
					AddSettingFlag("enchantments_" .. v.id .. "_disabled")
				end
			end

			if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
				GuiTooltip(gui, GameTextGetTranslatedOrNot(v.description), "by " .. v.author .. " \n[ Click to enable ]");
			else
				GuiTooltip(gui, GameTextGetTranslatedOrNot(v.description), "by " .. v.author .. " \n[ Click to disable] ");
			end


			if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
				GuiZSetForNextWidget(gui, -1100)
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
				GuiImage(gui, new_id(), -11.5, -1.5, "mods/evaisa.enchantments/files/gfx/ui/overlay.png", 1, 1, 1, 0)
				--GuiImage( )
				GuiZSetForNextWidget(gui, -1120)
				GuiImage(gui, new_id(), -13, 0, "mods/evaisa.enchantments/files/gfx/ui/crossed" .. crossed_index .. ".png", 1, 1,
					0)
			end

			if (crossed_index < 4) then
				crossed_index = crossed_index + 1
			else
				crossed_index = 1
			end


			if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
				if (GuiButton(gui, new_id(), -1.5, -0.5, GameTextGetTranslatedOrNot(v.name))) then
					if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
						RemoveSettingFlag("enchantments_" .. v.id .. "_disabled")
					else
						AddSettingFlag("enchantments_" .. v.id .. "_disabled")
					end
				end
			else
				if (GuiButton(gui, new_id(), 0, -0.5, GameTextGetTranslatedOrNot(v.name))) then
					if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
						RemoveSettingFlag("enchantments_" .. v.id .. "_disabled")
					else
						AddSettingFlag("enchantments_" .. v.id .. "_disabled")
					end
				end
			end

			if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
				GuiTooltip(gui, GameTextGetTranslatedOrNot(v.description), "by " .. v.author .. " \n[ Click to enable ]");
			else
				GuiTooltip(gui, GameTextGetTranslatedOrNot(v.description), "by " .. v.author .. " \n[ Click to disable] ");
			end

			GuiLayoutEnd(gui)
			--print("Finished adding.")
		end

		--GuiLayoutEnd(gui)
		--	GuiEndScrollContainer(gui)
	else
		GuiText(gui, 0, 0,
			"Due to Noita limitations, \nyou can only toggle individual enchantments \nonce you are in a game.")
	end
	--GuiLayoutEnd(gui)
end
