dofile("data/scripts/gun/gun_enums.lua")
dofile_once( "mods/evaisa.enchantments/files/scripts/utils.lua" );
enchantments = {
--[[ 
	-- Template
	{
		id = "example", -- Unique identifier
		name = "Example", -- Name of the enchantment
		description = "This is a example enchantment.", -- Description of the enchantment
		icon = "", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		valid_spell_types = {ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE}, -- Spell types that this enchantment can applied to
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		xp = 0, -- Experience required
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		pre_action_hook = function( local_data, recursion_level, iteration ) -- called before the action function
			-- anything available in action function is available here, like the c table.

		end,
		post_action_hook = function( local_data, recursion_level, iteration ) -- called after the action function
			-- anything available in action function is available here, like the c table.

		end,
		projectile_spawn = function(projectile_entity) -- Runs when the projectile spawns
			
		end
	},

]]

	{
		id = "volley", -- Unique identifier
		name = "Volley", -- Name of the enchantment
		description = "Cast a volley of projectiles", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/volley/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function

			c.spread_degrees = c.spread_degrees + 25

			--GamePrint(tostring(c.damage_projectile_add))

			c.explosion_radius = c.explosion_radius * 0.9
			if (c.explosion_radius < 0) then
				c.explosion_radius = 0
			end

			c.speed_multiplier = c.speed_multiplier * 0.75
			c.fire_rate_wait    = c.fire_rate_wait + 10
			shot_effects.recoil_knockback = shot_effects.recoil_knockback + 30.0

			
			local volley_old_add_projectile = add_projectile
			
			local volley_old_add_projectile_trigger_timer = add_projectile_trigger_timer

			local volley_old_add_projectile_trigger_hit_world = add_projectile_trigger_hit_world

			local volley_old_add_projectile_trigger_death = add_projectile_trigger_death


			local volley_extra_projectiles = {
				regular = {},
				timer = {},
				hit_world = {},
				death = {}
			}

			add_projectile = function( entity_filename )
				volley_old_add_projectile( entity_filename )

				table.insert(volley_extra_projectiles.regular, {
					filename = entity_filename
				})
			end
			
			add_projectile_trigger_timer = function( entity_filename, delay_frames, action_draw_count )
				volley_old_add_projectile_trigger_timer( entity_filename, delay_frames, action_draw_count )

				table.insert(volley_extra_projectiles.timer, {
					filename = entity_filename,
					delay_frames = delay_frames,
					action_draw_count = action_draw_count
				})
			end
			
			add_projectile_trigger_hit_world = function( entity_filename, action_draw_count )
				volley_old_add_projectile_trigger_hit_world( entity_filename, action_draw_count )

				table.insert(volley_extra_projectiles.hit_world, {
					filename = entity_filename,
					action_draw_count = action_draw_count
				})
			end
			
			add_projectile_trigger_death = function( entity_filename, action_draw_count )
				volley_old_add_projectile_trigger_death( entity_filename, action_draw_count )

				table.insert(volley_extra_projectiles.death, {
					filename = entity_filename,
					action_draw_count = action_draw_count
				})
			end
			
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/volley/spawn.xml,"

			orig(recursion_level, iteration)

			add_projectile = volley_old_add_projectile

			add_projectile_trigger_timer = volley_old_add_projectile_trigger_timer

			add_projectile_trigger_hit_world = volley_old_add_projectile_trigger_hit_world

			add_projectile_trigger_death = volley_old_add_projectile_trigger_death

			for k, v in ipairs(volley_extra_projectiles.regular)do
				add_projectile( v.filename, nil, nil, nil, is_volley )
			end

			for k, v in ipairs(volley_extra_projectiles.timer)do
				add_projectile_trigger_timer( v.filename, v.delay_frames, v.action_draw_count, nil, nil, nil, is_volley )
			end

			for k, v in ipairs(volley_extra_projectiles.hit_world)do
				add_projectile_trigger_hit_world( v.filename, v.action_draw_count, nil, nil, nil, is_volley )
			end

			for k, v in ipairs(volley_extra_projectiles.death)do
				add_projectile_trigger_death( v.filename, v.action_draw_count, nil, nil, nil, is_volley )
			end

		end,
	},
	{
		id = "cluster", -- Unique identifier
		name = "Draw & Multicast",                                                                                   -- Name of the enchantment
		description = "Draw an additional spell. Increases the multicast number and turns modifiers into multicasts.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/cluster/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE },                               -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			local old_draw_actions = draw_actions

			draw_actions = function( num_of_cards_to_draw, instant_reload_if_empty )
				num_of_cards_to_draw = num_of_cards_to_draw + 1
				old_draw_actions( num_of_cards_to_draw, instant_reload_if_empty )
			end

			orig(recursion_level, iteration)

			draw_actions = old_draw_actions
		end,
	},
	{
		id = "flow", -- Unique identifier
		description = "Cast another spell.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/flow/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = false, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		name = "Cast another",                                                       -- Name of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			orig(recursion_level, iteration)
			draw_actions( 1, true )
		end,
	},
	{
		id = "smol", -- Unique identifier
		description = "Cast a shrunken projectile.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/smol/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = false, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		name = "Small",                                                              -- Name of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.explosion_radius = c.explosion_radius * 0.25
			if (c.explosion_radius < 0) then
				c.explosion_radius = 0
			end

			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/smol/spawn.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "flame", -- Unique identifier
		name = "Fire Aspect", -- Name of the enchantment
		description = "Spells gain the aspect of fire.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/flame/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {"mods/evaisa.enchantments/files/enchantment_data/flame/torch.xml"}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE },             -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.game_effect_entities = c.game_effect_entities .. "data/entities/misc/effect_apply_on_fire.xml,"
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/flame/burn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "frost", -- Unique identifier
		name = "Frost Aspect", -- Name of the enchantment
		description = "Spells gain the aspect of frost.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/frost/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {"mods/evaisa.enchantments/files/enchantment_data/frost/torch.xml"}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE },             -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/frost/burn.xml,"
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/frost/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "chaotic", -- Unique identifier
		name = "Chaotic", -- Name of the enchantment
		description = "Spells move chaotically do random damage.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/chaotic/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "data/entities/misc/chaotic_arc.xml,"

			SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() + 253 )
			local multiplier = 0
			multiplier = Random( -3, 4 ) * Random( 0, 2 )
			local result = 0
			result = c.damage_projectile_add + 0.4 * multiplier
			c.damage_projectile_add = result
			c.gore_particles    = c.gore_particles + 5 * multiplier
			c.fire_rate_wait    = c.fire_rate_wait + 5
			shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0 * multiplier

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "knockback", -- Unique identifier
		name = "Knockback", -- Name of the enchantment
		description = "Spells gain extra knockback.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/knockback/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/knockback/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "power", -- Unique identifier
		description = "Spells do extra damage.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/power/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		name = "Damaging",                                                           -- Name of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.damage_projectile_add = c.damage_projectile_add + 0.4
			c.gore_particles    = c.gore_particles + 5
			c.extra_entities    = c.extra_entities .. "data/entities/particles/tinyspark_yellow.xml,"
			shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "homing", -- Unique identifier
		name = "Homing", -- Name of the enchantment
		description = "Spells home in on enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/homing/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "data/entities/misc/homing.xml,data/entities/particles/tinyspark_white.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "expensive", -- Unique identifier
		description = "Spells cost money but do more damage.", -- Description of the enchantment
		name = "Quality",                                                            -- Name of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/expensive/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			local entity_id = GetUpdatedEntityID()
			
			local dcomp = EntityGetFirstComponent( entity_id, "WalletComponent" )
			
			if ( dcomp ~= nil ) then
				local money = ComponentGetValue2( dcomp, "money" )
				local moneyspent = ComponentGetValue2( dcomp, "money_spent" )
				local damage = math.min( math.floor( money * 0.05 ), 24000 )
				
				if ( damage > 1 ) and ( money >= 10 ) then
					damage = math.max( damage, 10 )
					
					c.extra_entities = c.extra_entities .. "data/entities/particles/gold_sparks.xml,"
					
					money = money - damage
					moneyspent = moneyspent + damage
					ComponentSetValue2( dcomp, "money", money )
					ComponentSetValue2( dcomp, "money_spent", moneyspent )
					
					if ( damage < 120 ) then
						c.damage_projectile_add = c.damage_projectile_add + ( damage / 25 )
					elseif ( damage < 300 ) then
						c.damage_projectile_add = c.damage_projectile_add + ( damage / 35 )
					elseif ( damage < 500 ) then
						c.damage_projectile_add = c.damage_projectile_add + ( damage / 45 )
					else
						c.damage_projectile_add = c.damage_projectile_add + ( damage / 55 )
					end
				end
			end

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "quickdraw", -- Unique identifier
		name = "Quickdraw", -- Name of the enchantment
		description = "Lower recharge time.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/quickdraw/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.fire_rate_wait    = c.fire_rate_wait - 10
			current_reload_time = current_reload_time - 20

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "lifetime", -- Unique identifier
		name = "Longlived", -- Name of the enchantment
		description = "Extend lifetime", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/lifetime/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.lifetime_add 		= c.lifetime_add + 75

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "shortlived", -- Unique identifier
		name = "Shortlived", -- Name of the enchantment
		description = "Reduce lifetime", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/shortlived/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.lifetime_add 		= c.lifetime_add - 42

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "duck", -- Unique identifier
		name = "Duck", -- Name of the enchantment
		description = "Transform projectile into a duck.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/duck/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = false, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.sprite = "data/enemies_gfx/duck.xml"
			c.action_mana_drain = c.action_mana_drain - 10

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "heatwave", -- Unique identifier
		name = "Heatwave", -- Name of the enchantment
		description = "Projectiles cause a wave of hot air", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/heatwave/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = false, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		weight = 0.5,                                                                -- Rarity of the enchantment
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/heatwave/heat_wave.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "energetic", -- Unique identifier
		description = "Projectiles have enhanced explosive properties.", -- Description of the enchantment
		name = "Explosive",                                                          -- Name of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/energetic/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/energetic/energetic_projectiles.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "rebound", -- Unique identifier
		description = "Projectiles bounce more.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/rebound/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		name = "Bouncy",                                                             -- Name of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			if(c.bounces < 1)then
				c.bounces = 1
			else
				c.bounces = c.bounces * 2
			end

			c.lifetime_add = c.lifetime_add + 30

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "heavy", -- Unique identifier
		description = "Projectiles weigh more.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/heavy/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		name = "Heavy",                                                              -- Name of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.gravity = c.gravity + 600.0
			c.damage_projectile_add = c.damage_projectile_add + (30 / 25)

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "potent", -- Unique identifier
		name = "Potent", -- Name of the enchantment
		description = "Increases potency of material spells", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/potent/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		valid_spell_types = {ACTION_TYPE_MATERIAL}, -- Spell types that this enchantment can applied to
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/potent/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "modular", -- Unique identifier
		name = "Modular", -- Name of the enchantment
		description = "Turns the spell into a modifier.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/modular/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = false, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		weight = 5.0,                                                                -- Rarity of the enchantment
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			local modular_old_add_projectile = add_projectile
			
			local modular_old_add_projectile_trigger_timer = add_projectile_trigger_timer

			local modular_old_add_projectile_trigger_hit_world = add_projectile_trigger_hit_world

			local modular_old_add_projectile_trigger_death = add_projectile_trigger_death


			local modular_extra_entities = {}

			add_projectile = function( entity_filename, a, b, c, is_volley )
				--modular_old_add_projectile( entity_filename )
				if(is_volley == nil)then
					table.insert(modular_extra_entities, entity_filename)
				end
				
			end
			
			add_projectile_trigger_timer = function( entity_filename, delay_frames, action_draw_count, a, b, c, is_volley )
				--modular_old_add_projectile_trigger_timer( entity_filename, delay_frames, action_draw_count )

				if(is_volley == nil)then
					for i = 1, action_draw_count or 1 do
						table.insert(modular_extra_entities, entity_filename)
					end
				end
			end
			
			add_projectile_trigger_hit_world = function( entity_filename, action_draw_count, a, b, c, is_volley )
				--modular_old_add_projectile_trigger_hit_world( entity_filename, action_draw_count )
				if(is_volley == nil)then
					for i = 1, action_draw_count or 1 do
						table.insert(modular_extra_entities, entity_filename)
					end
				end
			end
			
			add_projectile_trigger_death = function( entity_filename, action_draw_count, a, b, c, is_volley )
				--modular_old_add_projectile_trigger_death( entity_filename, action_draw_count )
				if(is_volley == nil)then
					for i = 1, action_draw_count or 1 do
						table.insert(modular_extra_entities, entity_filename)
					end
				end
			end
			orig(recursion_level, iteration)
			add_projectile = modular_old_add_projectile

			add_projectile_trigger_timer = modular_old_add_projectile_trigger_timer

			add_projectile_trigger_hit_world = modular_old_add_projectile_trigger_hit_world

			add_projectile_trigger_death = modular_old_add_projectile_trigger_death

			for k, v in pairs(modular_extra_entities)do
				c.extra_entities = c.extra_entities .. v .. ","
			end

			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/modular/spawn.xml,"

			draw_actions(1, true)
		end,
	},
	{
		id = "leech", -- Unique identifier
		name = "Leech", -- Name of the enchantment
		description = "Leech health from enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/leech/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities ..  "mods/evaisa.enchantments/files/enchantment_data/leech/leech_projectile.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "crowdcontrol", -- Unique identifier
		name = "Crowd Control", -- Name of the enchantment
		description = "Creates an area damage cloud on enemy impact.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/crowdcontrol/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/crowdcontrol/projectile.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "bleed", -- Unique identifier
		name = "Bleed", -- Name of the enchantment
		description = "Causes the enemy to bleed on hit.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/bleed/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/bleed/hitfx.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "looting", -- Unique identifier
		name = "Looting", -- Name of the enchantment
		description = "Enemies drop extra gold.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/looting/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/looting/projectile.xml,"

			orig(recursion_level, iteration)
		end,
	},
	{
		id = "control", -- Unique identifier
		name = "Control", -- Name of the enchantment
		description = "Projectiles are controlled by the player.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/control/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function

			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/control/control.xml,"
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/control/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "poison", -- Unique identifier
		name = "Poison", -- Name of the enchantment
		description = "Projectiles poison targets.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/poison/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/poison/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "wither", -- Unique identifier
		name = "Wither", -- Name of the enchantment
		description = "Weakens the target.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/wither/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/wither/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "stun", -- Unique identifier
		name = "Stun", -- Name of the enchantment
		description = "Spells gain the power of electicity.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/stun/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {"mods/evaisa.enchantments/files/enchantment_data/frost/torch.xml"}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE },             -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.lightning_count = c.lightning_count + 1
			c.damage_electricity_add = c.damage_electricity_add + 0.1
			c.extra_entities = c.extra_entities .. "data/entities/particles/electricity.xml,"
			orig(recursion_level, iteration)
		end,
	},
	{
		id = "smite", -- Unique identifier
		name = "Smite", -- Name of the enchantment
		description = "Deal more damage to undead enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/smite/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		weight = 0.5,                                                                -- Rarity of the enchantment
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/smite/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},	
	{
		id = "bane_of_arthropods", -- Unique identifier
		name = "Bane of Arthropods", -- Name of the enchantment
		description = "Deal more damage to arthropod enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/bane_of_arthropods/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE },      -- Spell types that this enchantment can applied to
		weight = 0.5,
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/bane_of_arthropods/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},	
	{
		id = "disrupt", -- Unique identifier
		description = "Deal more damage to robot enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/disrupt/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		name = "Bane of Robots",                                                     -- Name of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		weight = 0.5,
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/disrupt/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},		
	{
		id = "hiisi", -- Unique identifier
		name = "Bane Of Hiisi", -- Name of the enchantment
		description = "Deal more damage to hiisi enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/hiisi/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		weight = 0.5,
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/hiisi/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},	
	{
		id = "fungicide", -- Unique identifier
		name = "Fungicide", -- Name of the enchantment
		description = "Deal more damage to fungi enemies.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/fungicide/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		weight = 0.5,
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/fungicide/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},		
	{
		id = "zero_gravity", -- Unique identifier
		name = "Zero Gravity", -- Name of the enchantment
		description = "Projectile is not affected by gravity.", -- Description of the enchantment
		icon = "mods/evaisa.enchantments/files/enchantment_data/zero_gravity/icon.png", -- Settings icon
		author = "evaisa", -- The author of the enchantment
		is_stackable = true, -- Can the enchantment be stacked?
		card_extra_entities = {}; -- Entities added to the spell card
		weight = 1.0, -- Rarity of the enchantment
		valid_spell_types = { ACTION_TYPE_PROJECTILE, ACTION_TYPE_STATIC_PROJECTILE }, -- Spell types that this enchantment can applied to
		xp = 10,
		check = function(action) -- Function to check if the enchantment can be applied to the action
			return true
		end, 
		hook = function(orig, recursion_level, iteration) -- Make sure to call orig, it calls the original action function
			c.extra_entities = c.extra_entities .. "mods/evaisa.enchantments/files/enchantment_data/zero_gravity/spawn.xml,"
			orig(recursion_level, iteration)
		end,
	},
	
}