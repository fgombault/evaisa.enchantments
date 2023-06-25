function table.dump(o)
    if type(o) == 'table' then
        local s = '{ '..string.char(10)
        for k,v in pairs(o) do
           if type(k) ~= 'number' then k = '"'..k..'"' end
           s = s .. '['..k..'] = ' .. table.dump(v) .. ',' ..string.char(10)
        end
        return s .. '} '..string.char(10)
     else
        if(type(o) == "string")then
            return '"'..o..'"'
        else
            return tostring(o)
        end
     end
end

oldModSettingGet = ModSettingGet
function ModFlagGet(setting)
	if(oldModSettingGet(setting) ~= nil)then
		return oldModSettingGet(setting)
	else
		return false
	end
end

function EntityGetAllDecendants(entity, table_previous)
    local table_previous = table_previous or {}
    local entities = EntityGetAllChildren(entity) or {}
    for k,v in pairs(entities) do
        table.insert(table_previous, v)
        table.insert(table_previous, EntityGetAllDecendants(v, table_previous))
    end
    return table_previous
end

function evaLerp(pos1, pos2, perc)
    return perc*pos1 + (1-perc)*pos2 -- Linear Interpolation
end

function literalize(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
end

function Split (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

function HasSettingFlag(setting)
	if(setting ~= nil)then
		if(oldModSettingGet(setting) ~= nil)then
			return oldModSettingGet(setting)
		else
			return false
		end
	else
		print("HasSettingFlag: setting is nil")
	end
end

function AddSettingFlag(name)
    ModSettingSet(name, true)
  --  ModSettingSetNextValue(name, true)
end

function RemoveSettingFlag(name)
    ModSettingRemove(name)
end

function EntityGetVariable(entity, name, type)
	value = nil
	variable_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	if(variable_storages ~= nil)then
		for k, v in ipairs(variable_storages)do
			name_out = ComponentGetValue2(v, "name")
			if(name_out == name)then
				value = ComponentGetValue2(v, "value_"..type)
			end
		end
	end
	return value
end

function EntitySetVariable(entity, name, type, value)
	variable_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	has_been_set = false
	if(variable_storages ~= nil)then
		for k, v in ipairs(variable_storages)do
			name_out = ComponentGetValue2(v, "name")
			if(name_out == name)then
				ComponentSetValue2(v, "value_"..type, value)
				has_been_set = true
			end
		end
	end
	if(has_been_set == false)then
		comp = {}
		comp.name = name
		comp["value_"..type] = value
		EntityAddComponent2(entity, "VariableStorageComponent", comp)
	end
end

function is_using_gamepad(player)
    local platform_shooter_player = EntityGetFirstComponentIncludingDisabled(player, "PlatformShooterPlayerComponent")
    if platform_shooter_player then
      return ComponentGetValue2(platform_shooter_player, "mHasGamepadControlsPrev")
    end
    return false
end

function MultiplyEntityLifetime(entity, multiplier, max_lifetime, dont_adjust_over_max)
    local max_lifetime = max_lifetime or 999999999
    dont_adjust_over_max = dont_adjust_over_max or false
    local LifetimeComponent = EntityGetFirstComponentIncludingDisabled(entity, "LifetimeComponent")
    if LifetimeComponent then
        local lifetime = ComponentGetValue2(LifetimeComponent, "lifetime")
        if(lifetime * multiplier > max_lifetime)then
            if(not dont_adjust_over_max)then
                lifetime = max_lifetime
            end
        else
            lifetime = lifetime * multiplier
        end
        ComponentSetValue2(LifetimeComponent, "lifetime", lifetime)
        ComponentSetValue2(LifetimeComponent, "kill_frame", GameGetFrameNum() + (lifetime))
    end

    local ProjectileComponent = EntityGetFirstComponentIncludingDisabled(entity, "ProjectileComponent")
    if ProjectileComponent then
        local lifetime = ComponentGetValue2(ProjectileComponent, "lifetime")
        if(lifetime * multiplier > max_lifetime)then
            if(not dont_adjust_over_max)then
                lifetime = max_lifetime
            end
        else
            lifetime = lifetime * multiplier
        end
        ComponentSetValue2(ProjectileComponent, "lifetime", lifetime)
    end
end

function AddStatusIcon( game_effect_entity, name, icon_file )
    local root = EntityGetRootEntity(game_effect_entity)
    if(not EntityHasChildWithRunFlag(root, "status_icon_"..name))then
        if game_effect_entity ~= nil then
            EntityAddComponent2( game_effect_entity, "UIIconComponent",
            {
                name = name,
                icon_sprite_file = icon_file,
                display_above_head = true,
                display_in_hud = true,
                is_perk = false,
            })
            GameAddEntityFlagRun(game_effect_entity, "status_icon_"..name)
        end
    end
end

function SetEntityLifetime(entity, lifetime)
    local LifetimeComponent = EntityGetFirstComponentIncludingDisabled(entity, "LifetimeComponent")
    if LifetimeComponent then
        ComponentSetValue2(LifetimeComponent, "lifetime", lifetime)
        ComponentSetValue2(LifetimeComponent, "kill_frame", GameGetFrameNum() + (lifetime))
    end

    local ProjectileComponent = EntityGetFirstComponentIncludingDisabled(entity, "ProjectileComponent")
    if ProjectileComponent then
        ComponentSetValue2(ProjectileComponent, "lifetime", lifetime)
    end
end

function EntityRemoveVariable(entity, name)
    local comp = nil
	variable_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	if(variable_storages ~= nil)then
		for k, v in ipairs(variable_storages)do
			name_out = ComponentGetValue2(v, "name")
			if(name_out == name)then
				comp = v
			end
		end
	end
	if(comp ~= nil)then
        EntityRemoveComponent(entity, comp)
    end
end

function EntityAdjustVariable( entity, name, type, default, callback )
    local new_value = callback( EntityGetVariable( entity, name, type ) or default );
    EntitySetVariable( entity, name, type, new_value );
    return new_value;
end

function ComponentAdjustValue( component, member, callback )
    local new_value = callback( ComponentGetValue2( component, member ) );
    ComponentSetValue2( component, member, new_value );
    return new_value;
end

function ComponentSetValues( component, member_value_table )
    for member,new_value in pairs(member_value_table) do
        ComponentSetValue2( component, member, new_value );
    end
end

function ComponentAdjustValues( component, member_callback_table )
    for member,callback in pairs( member_callback_table ) do
        ComponentSetValue2( component, member, callback( ComponentGetValue2( component, member ) ) );
    end
end

function ComponentObjectSetValues( component, object, member_value_table )
    for member,new_value in pairs(member_value_table) do
        ComponentObjectSetValue2( component, object, member, new_value );
    end
end

function ComponentObjectAdjustValues( component, object, member_callback_table )
    for member,callback in pairs(member_callback_table) do
        ComponentObjectSetValue2( component, object, member, callback( ComponentObjectGetValue2( component, object, member ) ) );
    end
end

function ComponentSetValues( component, member_value_table )
    for member,new_value in pairs(member_value_table) do
        ComponentSetValue2( component, member, new_value );
    end
end

function ComponentAdjustMetaCustoms( component, member_callback_table )
    for member,callback in pairs(member_callback_table) do
        local current_value = ComponentGetValue2( component, member );
        local new_value = callback( current_value );
        ComponentSetValue2( component, member, new_value );
    end
end

function EntityHasFlag(entity, name)
	value = false
	variable_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	if(variable_storages ~= nil)then
		for k, v in ipairs(variable_storages)do
			name_out = ComponentGetValue2(v, "name")
			if(name_out == name)then
				value = ComponentGetValue2(v, "value_bool")
			end
		end
	end
	return value
end

function EntityHasChildWithFlag(entity, name)
    value = false
    children = EntityGetAllChildren(entity)
    if(children ~= nil)then
        for k, v in ipairs(children)do
            if(EntityHasFlag(v, name))then
                value = true
            end
        end
    end
    return value
end


function GameHasEntityFlagRun(entity, flag)
	return GameHasFlagRun(tostring(entity)..flag)
end

function GameAddEntityFlagRun(entity, flag)
	GameAddFlagRun(tostring(entity)..flag)
end

function GameRemoveEntityFlagRun(entity, flag)
	GameRemoveFlagRun(tostring(entity)..flag)
end

function EntityHasChildWithRunFlag(entity, flag)
    value = false
    children = EntityGetAllChildren(entity)
    if(children ~= nil)then
        for k, v in ipairs(children)do
            if(GameHasFlagRun(tostring(v)..flag))then
                value = true
            end
        end
    end
    return value
end

function EntityAddFlag(entity, name)
	variable_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	has_been_set = false
	if(variable_storages ~= nil)then
		for k, v in ipairs(variable_storages)do
			name_out = ComponentGetValue2(v, "name")
			if(name_out == name)then
				ComponentSetValue2(v, "value_bool", true)
				has_been_set = true
			end
		end
	end
	if(has_been_set == false)then
		comp = {}
		comp.name = name
		comp["value_bool"] = true
		EntityAddComponent2(entity, "VariableStorageComponent", comp)
	end
end

function EntityRemoveFlag(entity, name)
	variable_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
	if(variable_storages ~= nil)then
		for k, v in ipairs(variable_storages)do
			name_out = ComponentGetValue2(v, "name")
			if(name_out == name)then
				EntityRemoveComponent(entity, v)
			end
		end
	end
end

function GuiGetMousePosition(gui)
	screen_width, screen_height = GuiGetScreenDimensions( gui );
	local x, y = DEBUG_GetMouseWorld()
	local virt_x = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X")
	local virt_y = MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y")
	local scale_x = virt_x / screen_width
	local scale_y = virt_y / screen_height
	local cx, cy = GameGetCameraPos()
	local sx, sy = (x - cx) / scale_x + screen_width / 2 + 1.5, (y - cy) / scale_y + screen_height / 2

	return sx, sy
end

function add_entity_mini_health_bar( entity )
    EntityAddComponent( entity, "HealthBarComponent" );
    EntityAddComponent( entity, "SpriteComponent", { 
        _tags="health_bar,ui,no_hitbox",
        alpha="1",
        has_special_scale="1",
        image_file="mods/blessed_beasts/files/gfx/health_bar.png",
        never_ragdollify_on_death="1",
        is_text_sprite="0",
        next_rect_animation="",
        offset_x="11",
        offset_y="-8",
        rect_animation="",
        special_scale_x="0.2",
        special_scale_y="0.6",
        ui_is_parent="0",
        update_transform="1",
        update_transform_rotation="0",
        visible="1",
        z_index="-9000",
    } );
end

function TryAdjustMaxHealth( entity, callback )
    local damage_models = EntityGetComponent( entity, "DamageModelComponent" );
    if damage_models ~= nil then
        for index,damage_model in ipairs( damage_models ) do
            local current_hp = ComponentGetValue2( damage_model, "hp" );
            local max_hp = ComponentGetValue2( damage_model, "max_hp" );
            local new_max = callback( max_hp, current_hp );
            local regained = new_max - current_hp;
            ComponentSetValue2( damage_model, "max_hp", new_max );
            ComponentSetValue2( damage_model, "hp", current_hp + regained );
        end
    end
end

function limit_to_every_n_frames( entity, variable_name, n, callback )
    local now = GameGetFrameNum();
	if now - (EntityGetVariable( entity, variable_name, "int" ) or 0) >= n then
        EntitySetVariable( entity, variable_name, "int", now );
        callback();
    end
end

function ShootProjectile( who_shot, entity_file, x, y, vx, vy, send_message )
    local entity = EntityLoad( entity_file, x, y );
    local genome = EntityGetFirstComponent( who_shot, "GenomeDataComponent" );
    -- this is the herd id string
    --local herd_id = ComponentGetValue2( genome, "herd_id" );
    local herd_id = ComponentGetValue2( genome, "herd_id" );
    if send_message == nil then send_message = true end

	GameShootProjectile( who_shot, x, y, x+vx, y+vy, entity, send_message );

    local projectile = EntityGetFirstComponent( entity, "ProjectileComponent" );
    if projectile ~= nil then
        ComponentSetValue2( projectile, "mWhoShot", who_shot );
        -- NOTE the returned herd id actually breaks the herd logic, so don't bother
        --ComponentSetValue2( projectile, "mShooterHerdId", herd_id );
    end

    local velocity = EntityGetFirstComponent( entity, "VelocityComponent" );
    if velocity ~= nil then
	    ComponentSetValue2( velocity, "mVelocity", vx, vy )
    end

	return entity;
end

function EntityGetFirstHitboxSize( entity, fallbackWidth, fallbackHeight )
    local hitbox = EntityGetFirstComponent( entity, "HitboxComponent" );

    local width = fallbackWidth or 0;
    local height = fallbackHeight or 0;
    if hitbox ~= nil then
        width =  ComponentGetValue2( hitbox, "aabb_max_x" ) - ComponentGetValue2( hitbox, "aabb_min_x" );
        height =  ComponentGetValue2( hitbox, "aabb_max_y" ) - ComponentGetValue2( hitbox, "aabb_min_y" );
    end
    return width, height;
end

function TryAdjustDamageMultipliers( entity, resistances )
    local damage_models = EntityGetComponent( entity, "DamageModelComponent" );
    if damage_models ~= nil then
        for index,damage_model in ipairs( damage_models ) do
            for damage_type,multiplier in pairs( resistances ) do
                local resistance = ComponentObjectGetValue2( damage_model, "damage_multipliers", damage_type );
                resistance = resistance * multiplier;
                ComponentObjectSetValue2( damage_model, "damage_multipliers", damage_type, resistance );
            end
        end
    end
end

function AdjustEntityDamageMultipliers( entity, callback)
    if callback ~= nil then
        local damage_models = EntityGetComponent( entity, "DamageModelComponent" );
        if damage_models ~= nil then
            for index,damage_model in ipairs( damage_models ) do
                local damage_by_types = ComponentObjectGetMembers( damage_model, "damage_multipliers" ) or {}
                local damage_by_types_fixed = {};
                for type,_ in pairs( damage_by_types ) do
                    damage_by_types_fixed[type] = ComponentObjectGetValue2( damage_model, "damage_multipliers", type );
                end
                local damage_by_types_adjusted = callback( damage_by_types_fixed );
                for type,amount in pairs( damage_by_types_adjusted ) do
                    if amount ~= nil then
                        ComponentObjectSetValue2( damage_model, "damage_multipliers", type, amount or damage_by_types_fixed[type] or 0 );
                    end
                end
            end
        end
    end
end


function ray_aabb(ray, aabb)
    local dirfract = {
        x = 1 / ray.dir.x,
        y = 1 / ray.dir.y,
    }

    local t1 = (aabb.min.x - ray.x) * dirfract.x
    local t2 = (aabb.max.x - ray.x) * dirfract.x
    local t3 = (aabb.min.y - ray.y) * dirfract.y
    local t4 = (aabb.max.y - ray.y) * dirfract.y
    
    local tmin = math.max(math.min(t1, t2), math.min(t3, t4))
    local tmax = math.min(math.max(t1, t2), math.max(t3, t4))

    if tmax < 0 then
        return false
    end

    if tmin > tmax then
        return false
    end

    local collision = {
        x = ray.x + ray.dir.x * tmin,
        y = ray.y + ray.dir.y * tmin
    }

    local distance = tmin

    return true, collision, distance
end
    

function PredictProjectileTarget(projectile, callback)
    callback = callback or function(hitinfo) end
    local projectile_component = EntityGetFirstComponent(projectile, "ProjectileComponent");
    local velocity_component = EntityGetFirstComponent(projectile, "VelocityComponent");
    if(projectile_component ~= nil and velocity_component ~= nil)then
        local vel_x, vel_y = ComponentGetValue2(velocity_component, "mVelocity");
        local x, y = EntityGetTransform(projectile);
        local len = math.sqrt(vel_x*vel_x + vel_y*vel_y);
        local dir_x, dir_y = vel_x/len, vel_y/len;
        local nearby_targets = EntityGetInRadiusWithTag(x, y, 80, "mortal")
        for k, v in ipairs(nearby_targets)do
            hitbox_component = EntityGetFirstComponent(v, "HitboxComponent")
            if(hitbox_component ~= nil)then
                local target_x, target_y = EntityGetTransform(v)
                local offset_x, offset_y = ComponentGetValue2(hitbox_component, "offset")
                local hitbox_min_x, hitbox_min_y = ComponentGetValue2(hitbox_component, "aabb_min_x") + offset_x, ComponentGetValue2(hitbox_component, "aabb_min_y") + offset_y
                local hitbox_max_x, hitbox_max_y = ComponentGetValue2(hitbox_component, "aabb_max_x") + offset_x, ComponentGetValue2(hitbox_component, "aabb_max_y") + offset_y

                local hitbox_pos_min_x, hitbox_pos_min_y = hitbox_min_x + target_x, hitbox_min_y + target_y
                local hitbox_pos_max_x, hitbox_pos_max_y = hitbox_max_x + target_x, hitbox_max_y + target_y

                -- check ray-box intersection using ray_aabb( ray, aabb )
                local hit, collision, distance = ray_aabb( 
                    {
                        x=x, 
                        y=y, 
                        dir={
                            x=dir_x,
                            y=dir_y
                        }
                    }, 
                    {
                        min={
                            x=hitbox_pos_min_x, 
                            y=hitbox_pos_min_y
                        }, 
                        max={
                            x=hitbox_pos_max_x,
                            y=hitbox_pos_max_y
                        }
                    })
                if(hit)then
                    if(callback ~= nil)then
                        callback({
                            target = v,
                            distance = distance,
                            collision = collision,
                            dir = {
                                x = dir_x,
                                y = dir_y
                            }
                        })
                    end
                    return v
                end
            end
        end
    end
    return false
end

function EntityGetHerdID(entity)
    local herd_id = nil;
    local herd_component = EntityGetFirstComponent(entity, "GenomeDataComponent");
    if herd_component ~= nil then
        herd_id = ComponentGetValue2(herd_component, "herd_id");
    end
    return herd_id;
end

function change_materials_that_damage( entity, data )
    for material,damage in pairs( data ) do
        EntitySetDamageFromMaterial( entity, material, damage );
    end
end

function GetChildWithTag(entity, tag)
	local children = EntityGetAllChildren(entity);
	if children ~= nil then
		for i,child in ipairs(children) do
			if EntityHasTag(child, tag) then
				return child;
			end
		end
	end
	return nil;
end

function adjust_entity_damage( entity, projectile_damage_callback, typed_damage_callback, explosive_damage_callback, lightning_damage_callback, area_damage_callback )
    local projectile = EntityGetFirstComponent( entity, "ProjectileComponent" );
    local lightning = EntityGetFirstComponent( entity, "LightningComponent" );

    if projectile ~= nil then
        if projectile_damage_callback ~= nil then
            local current_damage = ComponentGetValue2( projectile, "damage" );
            local new_damage = projectile_damage_callback( current_damage );
            if current_damage ~= new_damage then
                ComponentSetValue2( projectile, "damage", new_damage );
            end
            if typed_damage_callback ~= nil then
                local damage_by_types = ComponentObjectGetMembers( projectile, "damage_by_type" ) or {};
                local damage_by_types_fixed = {};
                for type,_ in pairs( damage_by_types ) do
                    damage_by_types_fixed[type] = ComponentObjectGetValue2( projectile, "damage_by_type", type );
                end
                local damage_by_types_adjusted = typed_damage_callback( damage_by_types_fixed );
                for type,amount in pairs( damage_by_types_adjusted ) do
                    if amount ~= nil then
                        ComponentObjectSetValue2( projectile, "damage_by_type", type, amount or damage_by_types_fixed[type] or 0 );
                    end
                end
            end
            if explosive_damage_callback ~= nil then
                local current_damage = ComponentObjectGetValue2( projectile, "config_explosion", "damage" );
                local new_damage = explosive_damage_callback( current_damage );
                if current_damage ~= new_damage then
                    ComponentObjectSetValue2( projectile, "config_explosion", "damage", new_damage );
                end
            end
        end
        if lightning_damage_callback ~= nil then
            local lightning = EntityGetFirstComponent( entity, "LightningComponent" );
            if lightning ~= nil then
                local current_damage = tonumber( ComponentObjectGetValue2( lightning, "config_explosion", "damage" ) );
                local new_damage = lightning_damage_callback( current_damage );
                if current_damage ~= new_damage then
                    ComponentObjectSetValue2( lightning, "config_explosion", "damage", new_damage );
                end
            end
        end
        if area_damage_callback ~= nil then
            local area_damage = EntityGetFirstComponent( entity, "AreaDamageComponent" );
            if area_damage ~= nil then
                local current_damage = ComponentGetValue2( area_damage, "damage_per_frame" );
                local new_damage = area_damage_callback( current_damage );
                if current_damage ~= new_damage then
                    ComponentSetValue2( area_damage, "damage_per_frame", new_damage );
                end
            end
        end
    end
end

function adjust_all_entity_damage( entity, callback )
    adjust_entity_damage( entity,
        function( current_damage ) return callback( current_damage ); end,
        function( current_damages )
            for type,current_damage in pairs( current_damages ) do
                if current_damage ~= 0 then
                    current_damages[type] = callback( current_damage );
                end
            end
            return current_damages;
        end,
        function( current_damage ) return callback( current_damage ); end,
        function( current_damage ) return callback( current_damage ); end,
        function( current_damage ) return callback( current_damage ); end
    );
end

function get_protagonist_bonus( entity )
    local multiplier = 1.0;
    local health_ratio = 1;
    local damage_models = EntityGetComponent( entity, "DamageModelComponent" );
    if damage_models ~= nil then
        for i,damage_model in ipairs( damage_models ) do
            local current_hp = ComponentGetValue2( damage_model, "hp" );
            local max_hp = ComponentGetValue2( damage_model, "max_hp" );
            local ratio = current_hp / max_hp;
            if ratio < health_ratio then
                health_ratio = ratio;
            end
        end
    end
    if entity ~= nil then
        local current_protagonist_bonus = EntityGetVariable( entity, "blessed_beasts_low_health_damage_bonus", "float" ) or 0.0;
        local adjuted_ratio = ( 1 - health_ratio ) ^ 1.5;
        multiplier = 1.0 + current_protagonist_bonus * adjuted_ratio;
    end
    return multiplier;
end
