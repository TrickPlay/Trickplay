    -- Create the Rectangle to animate
   	movingRect = Rectangle{ position = { -100, 400 },
	                        size = { 100, 100 },
	                        color = { 225, 225, 0, 255 } }

	-- Show it on the screen
	screen:add( movingRect )	                        

	-- Animate the Rectangle using a Timeline
	movingRect_tl = Timeline{ duration = 5000,  -- 5 seconds
							  loop = true,      -- loop forever

		-- Event handler
		on_new_frame = function( self, msecs, progress )
		
			-- X changes from -100 to 2020
			movingRect.x = -100 + (2120 * progress)
			
			-- X rotation changes from 0 to 360
			movingRect.x_rotation = { 360 * progress, 0, 0 }
		end
	}

	-- Start the Timeline animation
	movingRect_tl:start()

