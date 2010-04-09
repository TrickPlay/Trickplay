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

	player.connected_controllers._[controller] = controller

    if controller.has_accelerometer then
	start_text.text = "Press ENTER or TAP to start"
	start_text.x = (screen.w-start_text.size[1])/2

    	function controller.on_accelerometer(controller, x, y, z)
    		-- Accelerometer measurements are based on axes from http://www.switchonthecode.com/sites/default/files/825/images/device_axes.png

			momentum_adjust(x)
    	end
    end

	controller:declare_resource("jumper","jumper.png")
	controller:declare_resource("splat","splat.png")

	controller:set_ui_background("jumper")

	controller.on_disconnected = function ()
		player.connected_controllers._[controller] = nil
		start_text.text = "Press ENTER to start"
		start_text.x = (screen.w-start_text.size[1])/2
	end

end

for _,controller in pairs(controllers.connected) do
    controllers:on_controller_connected(controller)
end

function player.connected_controllers.game_on(self)
	for key,controller in pairs(self._) do
            controller:set_ui_background("jumper")
            controller:start_accelerometer("H", SAMPLE_PERIOD)
        end
end

function player.connected_controllers.death_splat(self)
	for key,controller in pairs(self._) do
            controller:set_ui_background("splat")
            controller:stop_accelerometer()    
        end
end


local key_handlers =	{
				[keys.Return] =
							function ()
								if not player.live then
									player.live = true
									player.reset()
								end
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
