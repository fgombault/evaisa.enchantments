dofile("mods/evaisa.enchantments/files/scripts/enchantment_list.lua")
dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
local pretty = dofile("mods/evaisa.enchantments/files/scripts/pretty_print.lua")

for k, action in ipairs(actions)do
	--[[
	if(not reading_name)then
		name_lookup_table[action.id] = action.name
		action.name = ""
	end
	]]
	local old_action_func = action.action
	action.action = function(recursion_level, iteration)

		local register_gunshoteffects = function( effects ) 
			ConfigGunShotEffects_PassToGame( effects )
		end

		if(reflecting or disable_enchantments or current_action.permanently_attached)then
			old_action_func(recursion_level, iteration)
			return
		end

		function getPlayerEntity()
			local players = EntityGetWithTag("player_unit")
			if #players == 0 then return end
		
			return players[1]
		end

		function getCurrentlyEquippedWandId()
			local i2c_id = EntityGetFirstComponentIncludingDisabled(getPlayerEntity(), "Inventory2Component")
			local wand_id = ComponentGetValue2( i2c_id, "mActiveItem" )
			
			if(EntityHasTag(wand_id, "wand")) then
				return wand_id
			else
				return -1
			end
		end
		

		local current_projectiles = {}

		--EntitySave(getCurrentlyEquippedWandId(), "alwayscastwand.xml")

		if(current_action ~= nil and current_action.deck_index ~= nil)then

			local id = current_action.deck_index + 1

			local wand = getCurrentlyEquippedWandId()

			local wand_children = EntityGetAllChildren( wand )
			local spells = {}

			for _, child in ipairs(wand_children) do
				if(EntityHasTag(child, "card_action"))then
					local item_comp = EntityGetFirstComponentIncludingDisabled(child, "ItemComponent")
					if(item_comp ~= nil and ComponentGetValue2(item_comp, "permanently_attached") == false)then
						table.insert(spells, child)
					end
				end
			end
			

			
			local card = spells[id]

			local stored_enchantments = EntityGetVariable(card, "enchantments", "string") or ""

			local found_enchantments = {}

			local orig_action_func = old_action_func
			


			for enchantment_id in string.gmatch(stored_enchantments, '([^,]+)') do
				table.insert(found_enchantments, enchantment_id)
			end

			for _, enchantment_id in ipairs(found_enchantments)do
				for k, enchantment in ipairs(enchantments)do
					if(enchantment.id == enchantment_id)then
						if(enchantment.hook ~= nil)then
							local orig_func = orig_action_func
							local new_action_func = function(recursion_level, iteration)
								enchantment.hook(orig_func, recursion_level, iteration)
							end
							orig_action_func = new_action_func
						end
					end
				end
			end
			

			if(#found_enchantments == 0 or (current_action.type == ACTION_TYPE_MODIFIER or current_action.type == ACTION_TYPE_PASSIVE or current_action.type == ACTION_TYPE_DRAW_MANY or current_action.type == ACTION_TYPE_OTHER) )then
				old_action_func(recursion_level, iteration)
			else
				local sandbox_cast_delay = 0
				local old_c = c;
				local old_shot_effects = shot_effects;
				BeginProjectile( "mods/evaisa.enchantments/files/entities/trigger_projectile.xml" );
					BeginTriggerDeath();
						shot_effects = {}
						c = {};

						for k,v in pairs(old_c) do
							c[k] = v;
						end
						for k,v in pairs(old_shot_effects) do
							shot_effects[k] = v;
						end

						local default_firerate = c.fire_rate_wait
						orig_action_func(recursion_level, iteration)
						sandbox_cast_delay = (c.fire_rate_wait - default_firerate)

						register_action( c );
						register_gunshoteffects( shot_effects )
						SetProjectileConfigs();
					EndTrigger();
				EndProjectile();
				c = old_c;
				shot_effects = old_shot_effects;
				c.fire_rate_wait = c.fire_rate_wait + sandbox_cast_delay
				register_gunshoteffects = function( effects ) end
			end
		end

	end
end