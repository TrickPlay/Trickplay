-- Play background loop
mediaplayer.on_loaded = function () mediaplayer:play() end
mediaplayer.on_end_of_stream = function ()
						mediaplayer:seek(0)
						mediaplayer:play()
					end
mediaplayer:load('background.mp4')

plane = Image{ src="plane.png" , position = { screen.w + 10 , 0 } }
screen:add(plane)

plane_timer=Timer( 8 )

function plane_timer.on_timer()
    plane.position={screen.w+10,math.random(0,screen.h-plane.h)}
    plane.scale={0.2,0.2}
    plane:animate{duration=4000,x=0-plane.w,y=math.random(0,screen.h-plane.h),scale={1,1}}
end

plane_timer:start()

-- Create the logo Image we'll spin
local logo = Image { size = { screen.w/2, screen.h/2 }, src = "trickplay_logo_dark_bg.png" }

-- We move the anchor point to the center of the logo so it'll spin in place when we rotate it below
logo:move_anchor_point( logo.size[1]/2, logo.size[2]/2 )

-- And now position the anchor point (and image) in the middle of the screen
logo.position = { screen.w/2, screen.h/2 }

screen:add( logo )

screen:show_all()

function controllers.on_controller_connected(controllers,controller)
    if(controller.has_accelerometer) then
    	controller:start_accelerometer("L",0.01)
    	
    	function controller.on_key_down ( controller, key )
    		if key == keys.Return then
    			exit()
    		end
    	end
    	
    	function controller.on_accelerometer(controller, x, y, z)
    		--[[
				Decompose rotation into 2 rotations, about y-axis onto x-z plane, then about x-axis onto negative y-axis
				Then rotate about z-axis to align tilt
    		]]--

    		-- Accelerometer measurements are based on axes from http://www.switchonthecode.com/sites/default/files/825/images/device_axes.png

    		-- Angle to the x-z plane
    		local theta_to_xz_plane = math.deg(math.atan2(x, z))
    		-- Correct now for quadrant
    		if z <= 0 then
    			theta_to_xz_plane = 180 - theta_to_xz_plane
    		end

    		-- Angle to the x-axis is the atan.  Then we move another 90º to hit the negative y-axis (which is where gravity lives)
    		local theta_to_z_axis = math.deg(math.atan2(y, math.sqrt(x^2 + z^2)))
    		local theta_to_negative_y_axis = theta_to_z_axis + 90
    		-- Correct now for quadrant
    		if z > 0 then
    			theta_to_negative_y_axis = - theta_to_negative_y_axis
    		end

			-- Angle the phone is titled relative to ground
			local theta_for_tilt = math.deg(x, math.sqrt(x^2 + z^2))


			-- And now do the rotations!
			logo.y_rotation = { theta_to_xz_plane, 0, 0 }
			logo.x_rotation = { theta_to_negative_y_axis, 0, 0 }
			logo.z_rotation = { theta_for_tilt, 0, 0 }
    	end
    end
end

local controller
for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end
