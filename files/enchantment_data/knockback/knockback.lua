-- get root entity
local knockback_entity = GetUpdatedEntityID()
local root = EntityGetRootEntity(knockback_entity)

local x, y = EntityGetTransform(root)

local force = 10000

-- get CharacterDataComponent
local character_data_component = EntityGetFirstComponentIncludingDisabled(root, "CharacterDataComponent")
if(character_data_component ~= nil) then
	-- get variable storage components with knockback_velocity_x and knockback_velocity_y
	local x_comp = EntityGetFirstComponentIncludingDisabled(root, "VariableStorageComponent", "knockback_velocity_x")
	local y_comp = EntityGetFirstComponentIncludingDisabled(root, "VariableStorageComponent", "knockback_velocity_y")

	if(x_comp ~= nil and y_comp ~= nil)then
		-- get velocity from variable storage components
		local vx = ComponentGetValue2(x_comp, "value_float")
		local vy = ComponentGetValue2(y_comp, "value_float")

		-- normalize velocity
		local vx_norm = vx / math.sqrt(vx^2 + vy^2)
		local vy_norm = vy / math.sqrt(vx^2 + vy^2)

		-- apply force to velocity
		vx = vx + (force * vx_norm)
		vy = vy + ((force + 100) * vy_norm)

		-- set velocity to CharacterDataComponent mVelocity
		ComponentSetValue2(character_data_component, "mVelocity", -vx , vy)

		-- turn into string and print
		local vx_str = tostring(vx)
		local vy_str = tostring(vy)

		EntityKill(knockback_entity)
	end
end