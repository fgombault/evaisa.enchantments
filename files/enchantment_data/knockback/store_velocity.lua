-- get projectile entity
local projectile_entity = GetUpdatedEntityID()

-- get velocity component
local velocity_component = EntityGetFirstComponent(projectile_entity, "VelocityComponent")

local x, y = EntityGetTransform(projectile_entity)

if(velocity_component ~= nil)then
	-- get all hittable entities in radius of 20
	local entities = EntityGetInRadiusWithTag(x, y, 80, "hittable")
	local entities2 = EntityGetInRadiusWithTag(x, y, 30, "hittable")

	-- get velocity from velocity component
	local vx, vy = ComponentGetValue2(velocity_component, "mVelocity")

	local disallow_table = {}

	for k, v in ipairs(entities2)do
		disallow_table[v] = true
	end

	-- for each entity in entities
	for k, v in ipairs(entities)do
		if(not disallow_table[v])then
			local x_comp = EntityGetFirstComponentIncludingDisabled(v, "VariableStorageComponent", "knockback_velocity_x")
			local y_comp = EntityGetFirstComponentIncludingDisabled(v, "VariableStorageComponent", "knockback_velocity_y")

			if(not x_comp)then
				x_comp = EntityAddComponent(v, "VariableStorageComponent")
				ComponentAddTag(x_comp, "knockback_velocity_x")
				ComponentSetValue2(x_comp, "value_float", vx)
			else
				ComponentSetValue2(x_comp, "value_float", vx)
			end

			if(not y_comp)then
				y_comp = EntityAddComponent(v, "VariableStorageComponent")
				ComponentAddTag(x_comp, "knockback_velocity_y")
				ComponentSetValue2(y_comp, "value_float", vy)
			else
				ComponentSetValue2(y_comp, "value_float", vy)
			end
		end
	end
end