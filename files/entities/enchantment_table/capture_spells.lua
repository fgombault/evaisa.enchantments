local entity = GetUpdatedEntityID()

if(EntityHasTag(entity, "is_enchanting"))then
	return
end

local x, y = EntityGetTransform(entity)

local entities = EntityGetInRadiusWithTag( x, y, 30, "card_action" )

local card_to_enchant = nil

for k, v in ipairs(entities)do
	if(EntityGetRootEntity(v) == v)then
		local action_comp = EntityGetFirstComponent(v, "ItemActionComponent")
		if(action_comp ~= nil and not EntityHasTag(v, "was_just_enchanted"))then
			local cost = EntityGetFirstComponent(v, "ItemCostComponent")
			if(cost == nil)then
				if(EntityGetRootEntity(v) == v)then
					card_to_enchant = v
					break
				end
			end
		end
	end
end

if(card_to_enchant ~= nil)then
	-- Load Swirly
	EntityLoad("data/entities/particles/particle_explosion/main_swirly_purple.xml", x, y - 33)

	-- Make player unable to pick up spell card
	local item_component = EntityGetFirstComponentIncludingDisabled(card_to_enchant, "ItemComponent")
	ComponentSetValue2(item_component, "is_pickable", false)

	-- Disable card physics
	local simple_physics_component = EntityGetFirstComponentIncludingDisabled(card_to_enchant, "SimplePhysicsComponent")
	EntitySetComponentIsEnabled(card_to_enchant, simple_physics_component, false)

	-- Add enchanting tag to pedestal and handle disabling/enabling some components
	EntityAddTag(entity, "is_enchanting")
	EntitySetComponentsWithTagEnabled(entity, "no_spell", false)
	EntitySetComponentsWithTagEnabled(entity, "requires_spell", true)

	-- Play sound
	GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/invisibility/activate", x, y)

	-- Add a lua component to the spell card to remove a tag when it is picked up
	if(not EntityHasTag(card_to_enchant, "has_pickup_fix"))then
		EntityAddTag(card_to_enchant, "has_pickup_fix")
		EntityAddComponent2(card_to_enchant, "LuaComponent", {
			script_item_picked_up="mods/evaisa.enchantments/files/entities/enchantment_table/card_picked_up.lua"
		})
	end
	
	local inherit_transform_components = EntityGetComponentIncludingDisabled(card_to_enchant, "InheritTransformComponent")
	if(inherit_transform_components ~= nil)then
		for k, v in ipairs(inherit_transform_components)do
			EntityRemoveComponent(card_to_enchant, v)
		end
	end
	
	-- Make card child of pedestal and move to position above the pedestal
	EntityAddChild(entity, card_to_enchant)
	EntityApplyTransform(card_to_enchant, x, y - 24)
end