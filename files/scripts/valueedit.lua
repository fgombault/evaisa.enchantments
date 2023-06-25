dofile( "data/scripts/lib/utilities.lua" )

local theEntity = GetUpdatedEntityID()

local the_component = GetUpdatedComponentID()

local x, y, r = EntityGetTransform(theEntity)

local projectileComponent = EntityGetFirstComponent(theEntity, "ProjectileComponent")

local velocityComponent = EntityGetFirstComponent(theEntity, "VelocityComponent")

local components = EntityGetComponent(theEntity, "VariableStorageComponent")

local already_ran = false

local priority_list = {}

local priority_component_list = {}

local count = 0


function modify_components(component, field, subcomponent, var_name, comp_id)
    local var_name = ComponentGetValue( comp_id, "name" )
    --0print(var_name)
    local word_array = {}

    for word in string.gmatch(var_name, '([^,]+)') do
        table.insert(word_array, word)
    end

    local component = word_array[1]
    local field = word_array[2]
    local subcomponent = word_array[3]

    if(field ~= nil)then
        var_name = field
    end
    

    if(projectileComponent ~= nil)then

        if( var_name == "max_lifetime") then
            local value =  ComponentGetValue( comp_id, "value_string" ) 
            local current_lifetime = ComponentGetValue(projectileComponent, "lifetime")
            if(tonumber(current_lifetime) > tonumber(value))then
            --  print("lowered lifetime")
                ComponentSetValue(projectileComponent, "lifetime", value)
                EntityRemoveComponent(theEntity,comp_id)
            elseif(tonumber(current_lifetime) == -1)then
                ComponentSetValue(projectileComponent, "lifetime", 120)
                EntityRemoveComponent(theEntity,comp_id)
            end
            return
        end

        if( var_name == "max_speed") then
            local value =  ComponentGetValue( comp_id, "value_string" ) 
            local current_speed = ComponentGetValue(projectileComponent, "speed_max")
            if(tonumber(current_speed) > tonumber(value))then
                ComponentSetValue(projectileComponent, "speed_max", value)
                ComponentSetValue(projectileComponent, "speed_min", value)
                EntityRemoveComponent(theEntity,comp_id)
            end
            return
        end


        if( var_name == "min_explosion_radius") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local current_radius = tonumber(ComponentObjectGetValue(projectileComponent, "config_explosion", "explosion_radius"))
            if(tonumber(current_radius) < tonumber(value))then
                ComponentObjectSetValue(projectileComponent, "config_explosion", "explosion_radius", value)   
                EntityRemoveComponent(theEntity,comp_id)
            end
            return
        end

        if( var_name == "min_max_durability_to_destroy") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local current_radius = tonumber(ComponentObjectGetValue(projectileComponent, "config_explosion", "max_durability_to_destroy"))
            if(tonumber(current_radius) < tonumber(value))then
                ComponentObjectSetValue(projectileComponent, "config_explosion", "max_durability_to_destroy", value)   
                EntityRemoveComponent(theEntity,comp_id)
            end
            return
        end

        if( var_name == "max_durability_to_destroy_multiplier") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local current_radius = tonumber(ComponentObjectGetValue(projectileComponent, "config_explosion", "max_durability_to_destroy"))
            ComponentObjectSetValue(projectileComponent, "config_explosion", "max_durability_to_destroy", tostring(current_radius * value))   
            EntityRemoveComponent(theEntity,comp_id)
            return
        end 

        if( var_name == "min_explosion_damage") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local current_damage = tonumber(ComponentObjectGetValue(projectileComponent, "config_explosion", "damage"))
            if(tonumber(current_damage) < tonumber(value))then
                ComponentObjectSetValue(projectileComponent, "config_explosion", "damage", value)   
                EntityRemoveComponent(theEntity,comp_id)
            end
            return
        end                

        if( var_name == "damage_multiplier") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local current_damage = tonumber(ComponentGetValue(projectileComponent, "damage"))
            local current_explosion_damage = tonumber(ComponentObjectGetValue(projectileComponent, "config_explosion", "damage"))
            if(current_damage ~= nil and current_damage ~= 0)then
                ComponentSetValue(projectileComponent, "damage", tostring(current_damage * value))
            end
            if(current_explosion_damage ~= nil and current_explosion_damage ~= 0)then
                ComponentObjectSetValue(projectileComponent, "config_explosion", "damage", tostring(current_explosion_damage * value))      
            end
            EntityRemoveComponent(theEntity,comp_id)
            return
        end 
        
        if( var_name == "lifetime_multiplier") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local lifetime = tonumber(ComponentGetValue(projectileComponent, "lifetime"))
            local final_lifetime = lifetime * value
        -- print(tostring(final_lifetime))
            local action_id = ComponentObjectGetValue2(projectileComponent, "config", "action_id")
            if(action_id ~= "MEGALASER")then
                ComponentSetValue(projectileComponent, "lifetime", final_lifetime)
            end
            EntityRemoveComponent(theEntity,comp_id)
            return
        end       

        if( var_name == "explosion_radius_multiplier") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local current_radius = tonumber(ComponentObjectGetValue(projectileComponent, "config_explosion", "explosion_radius"))
            ComponentObjectSetValue(projectileComponent, "config_explosion", "explosion_radius", tostring(current_radius * value))   
            EntityRemoveComponent(theEntity,comp_id)
            return
        end       

        if( var_name == "speed_multiplier") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local min_speed = tonumber(ComponentGetValue(projectileComponent, "speed_min"))
            local max_speed = tonumber(ComponentGetValue(projectileComponent, "speed_max"))
            ComponentSetValue(projectileComponent, "speed_min", tostring(min_speed * value))
            ComponentSetValue(projectileComponent, "speed_max", tostring(max_speed * value))
            EntityRemoveComponent(theEntity,comp_id)
            return
            --GamePrint("modified.")
        end      
        
        if( var_name == "knockback_multiplier") then
            local value =  tonumber(ComponentGetValue( comp_id, "value_string" )) 
            local knockback_force = tonumber(ComponentGetValue(projectileComponent, "knockback_force"))
            local physics_impulse_coeff = tonumber(ComponentGetValue(projectileComponent, "physics_impulse_coeff"))
            ComponentSetValue(projectileComponent, "knockback_force", tostring(knockback_force * value))
            ComponentSetValue(projectileComponent, "physics_impulse_coeff", tostring(physics_impulse_coeff * value))
            EntityRemoveComponent(theEntity,comp_id)
            return
        end                        

        
    end
    if(velocityComponent ~= nil)then
        if( var_name == "friction_multiplier") then
            local value = tonumber(ComponentGetValue( comp_id, "value_string" ))
            local current_friction = tonumber(ComponentGetValue(velocityComponent, "air_friction"))
            if(tonumber(current_friction) > 0)then
                ComponentSetValue(velocityComponent, "air_friction", tostring(current_friction / value))
            elseif(tonumber(current_friction) < 0)then
                ComponentSetValue(velocityComponent, "air_friction", tostring(current_friction * value))
            end
            EntityRemoveComponent(theEntity,comp_id)
            return
        end 
    end      

    if(field ~= nil)then
        local our_component = EntityGetFirstComponent(theEntity, component)

        if(our_component ~= nil)then
            if(subcomponent == nil)then
                local value =  ComponentGetValue( comp_id, "value_string" )

                if(field == "projectile_type")then
                    ComponentSetValue2(our_component, field, value)
                else
                    ComponentSetValue(our_component, field, value)
                end
            else
                local value =  ComponentGetValue( comp_id, "value_string" )    

                ComponentObjectSetValue(our_component, subcomponent, field, value)
            end
        else
            --print("[ERROR] Component '"..component.."' does not exist on entity.")
        end
        EntityRemoveComponent(theEntity,comp_id)
    end

end

if( components ~= nil ) then 


        for key,comp_id in ipairs(components) do 
            count = count + 1
            local var_name = ComponentGetValue( comp_id, "name" )

            
            
           -- print("count ran: "..tostring(count))

            if(var_name == "store_value")then
                local value =  ComponentGetValue( comp_id, "value_string" ) 

                local word_array = {}

                for word in string.gmatch(value, '([^,]+)') do
                    table.insert(word_array, word)
                end

                local component = word_array[1]
                local field = word_array[2]
                local subcomponent = word_array[3]

                local our_component = EntityGetFirstComponent(theEntity, component)

                if(subcomponent == "false")then
                    
                    local original_value = ComponentGetValue(our_component, field)

                    local storage_name = "original_"..component.."_"..field

                    local storage_index = 0

                    for key,comp_id in ipairs(components) do 
                        local var_name = ComponentGetValue( comp_id, "name" )
            
                        if(string.match(var_name, storage_name))then
                            storage_index = storage_index + 1
                        end
                    end

                    
                    
                    if(storage_index ~= 0)then
                        storage_name = storage_name..tostring(storage_index)
                    end

                
                    --print(storage_name)
                    EntityAddComponent( theEntity, "VariableStorageComponent", 
                    { 
                        name = storage_name,
                        value_string = original_value,
                    } )
                else
                    local original_value = ComponentObjectGetValue(our_component, subcomponent, field)
                    local storage_name = "original_"..component.."_"..subcomponent.."_"..field

                    local storage_index = 0
                    for key,comp_id in ipairs(components) do 
                        local var_name = ComponentGetValue( comp_id, "name" )
            
                        if(string.match(var_name, storage_name))then
                            storage_index = storage_index + 1
                        end
                    end

                    if(storage_index ~= 0)then
                        storage_name = storage_name..tostring(storage_index)
                    end

                    EntityAddComponent( theEntity, "VariableStorageComponent", 
                    { 
                        name = storage_name,
                        value_string = original_value,
                    } )                  
                end
                EntityRemoveComponent(theEntity,comp_id)
            end

            local word_array = {}

            for word in string.gmatch(var_name, '([^,]+)') do
                table.insert(word_array, word)
            end

            local component = word_array[1]
            local field = word_array[2]
            local subcomponent = word_array[3]

            if(field ~= nil)then
                var_name = field
            end
            modify_components(component, field, subcomponent, var_name, comp_id)
        end

end
