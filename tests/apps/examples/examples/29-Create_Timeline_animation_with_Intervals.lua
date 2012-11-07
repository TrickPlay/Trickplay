-- Create the Rectangle to animate
movingRect = Rectangle{ position = { -100, 400 },
                        size     = { 100, 100 },
                        color    = { 225, 225, 0, 255 },
}

-- Show it on the screen
screen:add( movingRect )

-- Define Interval ranges for animating the Rectangle
acrossScreen = Interval( -100, 2020 )  -- points along X-axis
fullCircle   = Interval( 0, 360 )      -- degrees rotation around X-axis

-- Animate the Rectangle using a Timeline
movingRect_tl = Timeline{ duration = 5000,  -- 5 seconds
						  loop     = true,  -- loop forever
}

-- Handler for on_new_frame events: Updates the Rectangle's location and rotation
function moveRect( self, msecs, progress )
	-- X changes along range specified in acrossScreen
	movingRect.x = acrossScreen:get_value( progress )

	-- X rotation around range specified in fullCircle
	movingRect.x_rotation = { fullCircle:get_value( progress ), 0, 0 }
end

-- Hook the Timeline into on_new_frame event
movingRect_tl:add_onnewframe_listener( moveRect )

-- Show the screen
screen:show()

-- Start the Timeline animation
movingRect_tl:start()
