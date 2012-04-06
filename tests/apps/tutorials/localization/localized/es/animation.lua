--
-- Localized animation function
--
-- Spanish
--
-- *********************************************************

-- Function argument(s)
-- Note: This syntax is like defining a function that accepts a single argument called billbrd.
-- To define a function with multiple arguments, simply separate them with commas, as in:
-- 		local billbrd, property, duration = ...
local billbrd = ...


	ROTATION_LOW	= 0			-- low range of rotation in degrees
	ROTATION_HIGH	= -7		-- high range of rotation in degrees
	DURATION		= 3000		-- animation duration in milliseconds
	
	timelineOne		= nil		-- performs first half of animation
	timelineTwo		= nil		-- performs second half of animation
	
	rotationOne		= nil		-- Phase One rotation Interval in degrees
	rotationTwo		= nil		-- Phase Two rotation Interval in degrees
	
	
	-- Define degree intervals of rotation
	rotationOne = Interval( ROTATION_LOW,  ROTATION_HIGH )
	rotationTwo = Interval( ROTATION_HIGH, ROTATION_LOW )

	-- Rotate along the X-axis, Phase One
	timelineOne = Timeline( { duration = DURATION,
	                       
	    -- *********************************************
	    -- Event handler for each new animation frame
		on_new_frame = function( self, msecs, progress )
		
			-- Rotate billbrd along X-axis
			billbrd.x_rotation = { rotationOne:get_value( progress ), 0, 0 }
		end,

		-- ********************************************
		-- Event handler called when animation is finished
		on_completed = function( self )
		
			-- Start rotating in opposite direction
			timelineTwo:start()
		end,
		
		-- ********************************************
	} )
	
	-- Rotate along the X-axis, Phase Two
	timelineTwo = Timeline( { duration = DURATION,
	
		-- ********************************************
		-- Event handler for each new animation frame
		on_new_frame = function( self, msecs, progress )
		
			-- Rotate billbrd along X-axis
			billbrd.x_rotation = { rotationTwo:get_value( progress ), 0, 0 }
		end,
		
		-- ********************************************
		-- Event handler called when animation is finished
		on_completed = function( self )
		
			-- Begin cycle again by rotating in opposite direction
			timelineOne:start()
		end,
		
		-- ********************************************
	} )
	
	-- Start animation, Phase One
	timelineOne:start()
	
-- *********************************************************

