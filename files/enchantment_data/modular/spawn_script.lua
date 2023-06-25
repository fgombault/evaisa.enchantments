dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile = GetUpdatedEntityID()

local x, y = EntityGetTransform(projectile)

local valid_whoshot = 0
local valid_entityThatShot = 0

local projectile_component = EntityGetComponent(projectile, "ProjectileComponent") or {}
for k, v in pairs(projectile_component)do
	local mWhoShot = ComponentGetValue2(v, "mWhoShot")
	local mEntityThatShot = ComponentGetValue2(v, "mEntityThatShot")

	if(mWhoShot > 0)then
		valid_whoshot = mWhoShot
		break
	end

	if(mEntityThatShot > 0)then
		valid_entityThatShot = mEntityThatShot
		break
	end
end

for k, v in pairs(projectile_component)do
	ComponentSetValue2(v, "mWhoShot", valid_whoshot)
	ComponentSetValue2(v, "mEntityThatShot", valid_entityThatShot)
end
