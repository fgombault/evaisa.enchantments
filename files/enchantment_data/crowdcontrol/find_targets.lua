dofile("mods/evaisa.enchantments/files/scripts/utils.lua")
local projectile = GetUpdatedEntityID()
local x, y = EntityGetTransform(projectile)

local max_degrees = 15

Radius = 30
local targets = EntityGetInRadiusWithTag(x, y, Radius, "homing_target")
for k, target in ipairs(targets)do
	local velocity_comp = EntityGetFirstComponentIncludingDisabled(projectile, "VelocityComponent")
	local projectile_comp = EntityGetFirstComponentIncludingDisabled(projectile, "ProjectileComponent")
	local vel_x, vel_y = ComponentGetValue2(velocity_comp, "mVelocity")
	target_x, target_y = EntityGetTransform(target)

	local target_angle = math.deg(math.atan2(target_y - y, target_x - x))

	local projectile_angle = math.deg(math.atan2(vel_y, vel_x))

	local angle_diff = math.abs(target_angle - projectile_angle)

	if(angle_diff <= max_degrees)then

		local mWhoShot = ComponentGetValue2(projectile_comp, "mWhoShot")

		EntitySetVariable(target, "mWhoShot", "int", mWhoShot)

		EntityLoadToEntity("mods/evaisa.enchantments/files/enchantment_data/crowdcontrol/enemy.xml", target)
	end
end