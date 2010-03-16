--[[
	The controller's accelerometer will control only the on-screen X momentum of the player.
]]--

local SAMPLE_PERIOD		= 0.02
local MOMENTUM_DAMPING	= 3
local MAX_MOMENTUM		= 1000

local function momentum_adjust(x)
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

function controllers.on_controller_connected(controllers,controller)
	start_text.text = "Press ENTER or TAP to start"
	start_text.x = (screen.w-start_text.size[1])/2
    if(controller.has_accelerometer) then
    	controller:start_accelerometer("H", SAMPLE_PERIOD)

    	function controller.on_accelerometer(controller, x, y, z)
    		-- Accelerometer measurements are based on axes from http://www.switchonthecode.com/sites/default/files/825/images/device_axes.png

			momentum_adjust(x)
    	end
    end

	controller.on_disconnected = function ()
		start_text.text = "Press ENTER to start"
		start_text.x = (screen.w-start_text.size[1])/2
	end

end



local key_handlers =	{
				[keys.Return] =
							function ()
								player.reset()
							end,
				[keys.Left]  =
							function ()
								momentum_adjust(-1)
							end,
				[keys.Right] =
							function ()
								momentum_adjust(1)
							end
				}

function screen.on_key_down(screen,keyval)
	if key_handlers[keyval] then
		key_handlers[keyval]()
	end
end
