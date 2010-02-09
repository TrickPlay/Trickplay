--[[
	The controller's accelerometer will control only the on-screen X momentum of the player.
]]--

local SAMPLE_PERIOD		= 0.02
local MOMENTUM_DAMPING	= 3
local MAX_MOMENTUM		= 1000

function controllers.on_controller_connected(controllers,controller)
    if(controller.has_accelerometer) then
    	controller:start_accelerometer("H", SAMPLE_PERIOD)

    	function controller.on_accelerometer(controller, x, y, z)
    		-- Accelerometer measurements are based on axes from http://www.switchonthecode.com/sites/default/files/825/images/device_axes.png

			-- Use 1/10 of the original momentum when adjusting to a new momentum
			player.horizontal_momentum =	(
												MOMENTUM_DAMPING*player.horizontal_momentum
												+ (MAX_MOMENTUM * x)
											) / ( 1 + MOMENTUM_DAMPING )

			if(player.horizontal_momentum > MAX_MOMENTUM) then
				player.horizontal_momentum = MAX_MOMENTUM
			end

			if(player.horizontal_momentum < -MAX_MOMENTUM) then
				player.horizontal_momentum = -MAX_MOMENTUM
			end
    	end
    end
end

local key_enter = 65293

function screen.on_key_down(screen,keyval)
	if keyval == key_enter then
		player.reset()
	end
end
