-- Create the Rectangle to animate
movingRect = Rectangle( { position = { -100, 400 },
                          size     = { 100, 100 },
   	                      color    = { 225, 225, 0, 255 },
} )
screen:add( movingRect )

-- Animate the Rectangle using a Timeline
movingRect_tl = Timeline( { duration = 5000,  -- 5 seconds
						    loop     = true,  -- loop forever
} )

-- Define a handler for on_new_frame events
function onNewFrame( timeline, duration, progress )
	-- X changes from -100 to 2020
	movingRect.x = -100 + (2120 * progress)

	-- X rotation changes from 0 to 360
	movingRect.x_rotation = { 360 * progress, 0, 0 }
end

-- Register the handler for the on_new_frame event
movingRect_tl:add_onnewframe_listener( onNewFrame )

-- Show everything on the screen
screen:show()

-- Start the Timeline animation
movingRect_tl:start()
