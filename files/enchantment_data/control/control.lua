dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile = GetUpdatedEntityID()

local x, y = EntityGetTransform(projectile)

local player = get_players() ~= nil and get_players()[1] or nil

if(player == nil) then
	return
end

local controls_component = EntityGetFirstComponent(player, "ControlsComponent")

local mouse_mode = not is_using_gamepad(player)

if(mouse_mode)then
	local mouse_x, mouse_y = ComponentGetValue2(controls_component, "mMousePosition")

	SetRandomSeed(x + mouse_x + GameGetFrameNum(), y + mouse_y + GameGetFrameNum())

	local dir_x = (mouse_x + Random(-5, 5)) - x

	local dir_y = (mouse_y + Random(-5, 5)) - y

	local speed = 100

	edit_component( projectile, "VelocityComponent", function(comp,vars)
		local vel_x, vel_y = ComponentGetValue2( comp, "mVelocity")
		
		local len = math.sqrt((dir_x*dir_x) + (dir_y*dir_y))

		dir_x = dir_x / len
		dir_y = dir_y / len

		local force_x = (vel_x*0.96) + (dir_x * speed)
		local force_y = (vel_y*0.96) + (dir_y * speed)

		ComponentSetValue( comp, "gravity_x", 0 )
		ComponentSetValue( comp, "gravity_y", 0 )
		ComponentSetValue2( comp, "mVelocity", force_x, force_y )
	end)	
else
	local speed = 10

	edit_component( projectile, "VelocityComponent", function(comp,vars)
		local vel_x, vel_y = ComponentGetValue2( comp, "mVelocity")

		local dir_x, dir_y = ComponentGetValue2(controls_component, "mAimingVectorNormalized")

		local force_x = (vel_x*0.96) + (dir_x * speed)
		local force_y = (vel_y*0.96) + (dir_y * speed)

		ComponentSetValue( comp, "gravity_x", 0 )
		ComponentSetValue( comp, "gravity_y", 0 )
		ComponentSetValue2( comp, "mVelocity", force_x, force_y )
	end)	
end
