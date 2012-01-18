    -- Create the Rectangle to animate
   	movingRect = Rectangle{ position = { -100, 400 },
	                        size = { 100, 100 },
	                        color = { 225, 225, 0, 255 } }

	-- Show it on the screen
	screen:add( movingRect )

	-- Define Interval ranges for animating the Rectangle
	acrossScreen = Interval( -100, 2020 )  -- points along X-axis
	fullCircle   = Interval( 0, 360 )      -- degrees rotation around X-axis

	-- Define an Alpha mode for the movement along the X-axis
	-- Note: If desired, a second Alpha mode could also be define and applied in the same manner on the rotation.
	movementMode = Alpha{ mode = "EASE_IN_OUT_QUAD" }
	
	-- Animate the Rectangle using a Timeline
	movingRect_tl = Timeline{ duration = 5000,  -- 5 seconds
							  loop = true,      -- loop forever

		-- Event handler
		on_new_frame = function( self, msecs, progress )
		
			-- X changes along range specified in acrossScreen and transformed by the movementMode
			-- Note: To use the transformed progress value, we access the alpha property from the
			--       Alpha object, instead of the untransformed progress property.
			movingRect.x = acrossScreen:get_value( movementMode.alpha )
			
			-- X rotation around range specified in fullCircle
			movingRect.x_rotation = { fullCircle:get_value( progress ), 0, 0 }
		end
	}
	
	-- Assign the Alpha mode to the Timeline object
	-- If you forget to do this, accessing the alpha property in on_new_frame() will produce a bunch of errors.
	movementMode.timeline = movingRect_tl

	-- Start the Timeline animation
	movingRect_tl:start()

