	-- Expanded Timeline Demo Animation

	-- ********************************
	-- Globals

	-- Constants
	DEMO_SIZE = 300		-- size of demoArea
	SIZE      = 30		-- size of animated rectangle

	-- ********************************
	function
	rectNewFrameEvent( animationTL, msecs, progress )

		-- This event handler is hooked to the Timeline's on_new_frame event. It is called
		-- intermittently while the animation runs. It is responsible for determining the current
		-- property values for each animated property based upon the current progress of the
		-- animation. Every Timeline-based animation must have an on_new_frame event handler.
		--
		-- For this animation, each rectangle is animated along its X and Y coordinates and is
		-- rotated along the Z-axis. The starting and ending ranges for each animated property
		-- have been assigned to Interval objects, so the Interval performs all the calculations
		-- to determine a property's current value.

		-- Determine each rectangle's current position
		rectRed.position   = { rectRedRangeX:get_value( progress ),   rectRedRangeY:get_value( progress ) }
		rectGreen.position = { rectGreenRangeX:get_value( progress ), rectGreenRangeY:get_value( progress ) }
		rectBlue.position  = { rectBlueRangeX:get_value( progress ),  rectBlueRangeY:get_value( progress ) }

		-- Rotate each rectangle
		local zRotation = rectRangeRotation:get_value( progress )
		rectRed.z_rotation   = { zRotation, 0, 0 }
		rectGreen.z_rotation = { zRotation, 0, 0 }
		rectBlue.z_rotation  = { zRotation, 0, 0 }

	end  -- rectNewFrameEvent

	-- ********************************
	function
	rectCompletedEvent( animationTL )

		-- This event handler is hooked to the Timeline's on_completed event. It is called
		-- when the animation completes, and can perform any desired operations, such as object
		-- clean-up, etc. Animations that have no completion requirements need not implement
		-- this handler.
		--
		-- For this demo, another iteration of the animation will be started. This entails
		-- getting new starting and ending positions for each rectangle, assigning them to the
		-- Interval objects to ease property calculations in the on_new_frame event handler,
		-- positioning the rectangles to their new starting positions, and finally, starting
		-- the animation. Notice that the original Timeline and Interval objects are simply
		-- re-used with new starting and ending positions plugged into them.

		-- Determine new starting and ending animation positions
		rectRedAnimationPositions   = getAnimationPositions()
		rectGreenAnimationPositions = getAnimationPositions()
		rectBlueAnimationPositions  = getAnimationPositions()

		-- Update Interval objects with new animated X and Y coordinates
		rectRedRangeX.from   = rectRedAnimationPositions[ 1 ]
		rectRedRangeX.to     = rectRedAnimationPositions[ 3 ]
		rectRedRangeY.from   = rectRedAnimationPositions[ 2 ]
		rectRedRangeY.to     = rectRedAnimationPositions[ 4 ]
		rectGreenRangeX.from = rectGreenAnimationPositions[ 1 ]
		rectGreenRangeX.to   = rectGreenAnimationPositions[ 3 ]
		rectGreenRangeY.from = rectGreenAnimationPositions[ 2 ]
		rectGreenRangeY.to   = rectGreenAnimationPositions[ 4 ]
		rectBlueRangeX.from  = rectBlueAnimationPositions[ 1 ]
		rectBlueRangeX.to    = rectBlueAnimationPositions[ 3 ]
		rectBlueRangeY.from  = rectBlueAnimationPositions[ 2 ]
		rectBlueRangeY.to    = rectBlueAnimationPositions[ 4 ]

		-- Place rectangles in their starting positions
		positionRects()

		-- Start animation again
		animationTL:start()

	end  -- rectCompletedEvent

	-- ********************************
	function
	getAnimationPositions()

		-- This function generates random starting and ending X and Y positions for the
		-- objects that will be animated.
		--
		-- Positions are always just outside of the demoArea space. They can start from
		-- any side and end on any different side.
		--
		-- The function returns a table in the format { startX, startY, endX, endY }

		-- Constants representing the four sides of the demoArea
		local TOP, RIGHT, BOTTOM, LEFT = 1, 2, 3, 4

		-- Determine starting and ending sides (each must be a different side)
		local startSide, endSide = 1, 1
		while( startSide == endSide ) do
			startSide = math.random( 4 )
			endSide   = math.random( 4 )
		end

		-- Determine starting and ending X and Y coordinates
		local rangeLower = SIZE / 2
		local rangeUpper = DEMO_SIZE - (SIZE / 2)
		local startX = math.random( rangeLower, rangeUpper )
		local startY = math.random( rangeLower, rangeUpper )
		local endX   = math.random( rangeLower, rangeUpper )
		local endY   = math.random( rangeLower, rangeUpper )

		-- Depending on the starting and ending side, some coordinates will require adjustment
		if( startSide == TOP ) then
			-- Force Y coordinate
			startY = -(SIZE / 2)
		end
		if( endSide == TOP ) then
			-- Force Y coordinate
			endY = -(SIZE / 2)
		end
		if( startSide == LEFT ) then
			-- Force X coordinate
			startX = -(SIZE / 2)
		end
		if( endSide == LEFT ) then
			-- Force X coordinate
			endX = -(SIZE / 2)
		end
		if( startSide == RIGHT ) then
			-- Force X coordinate
			startX = DEMO_SIZE + (SIZE / 2)
		end
		if( endSide == RIGHT ) then
			-- Force X coordinate
			endX = DEMO_SIZE + (SIZE / 2)
		end
		if( startSide == BOTTOM ) then
			-- Force Y coordinate
			startY = DEMO_SIZE + (SIZE / 2)
		end
		if( endSide == BOTTOM ) then
			-- Force Y coordinate
			endY = DEMO_SIZE + (SIZE / 2)
		end

		-- Return "calculated" positions
		return { startX, startY, endX, endY }

	end  -- getAnimationPositions()

	-- ********************************
	function
	positionRects()

		-- Position the three rectangles to their starting animation positions
		rectRed.position   = { rectRedAnimationPositions[ 1 ],   rectRedAnimationPositions[ 2 ] }
		rectGreen.position = { rectGreenAnimationPositions[ 1 ], rectGreenAnimationPositions[ 2 ] }
		rectBlue.position  = { rectBlueAnimationPositions[ 1 ],  rectBlueAnimationPositions[ 2 ] }

	end  -- positionRects()

	-- ********************************
	-- Program entry point

	-- Create a screen background
	bckgnd = Canvas( 1920, 1080 )
	bckgnd:set_source_color( { 70, 100, 130, 255 } )      -- nice blue
	bckgnd:paint()
	bckgndImage      = bckgnd:Image()
	bckgndImage.name = "Background"
	screen:add( bckgndImage )

	-- Demo area X and Y position, near screen center
	local DEMO_X, DEMO_Y = 800, 300

	-- Create a rectangular demo area and add it to the screen
	demoArea = Rectangle( { position     = { DEMO_X, DEMO_Y },
    	            	    size         = { DEMO_SIZE + 8, DEMO_SIZE + 8 }, -- add 8 for borders
    	            		color        = { 100, 100, 100, 255 },
    	            		border_color = { 0, 0, 0, 255 },
    	            		border_width = 4,
    	            		name         = "demoArea",
    	            		opacity      = 255,
	} )
	screen:add( demoArea )

	-- Create a Group for the demo area for clipping purposes and add it to the screen
	demoGroup = Group( { position = { DEMO_X, DEMO_Y }, -- must overlay demoArea rectangle
	                     size     = { DEMO_SIZE + 8, DEMO_SIZE + 8 },
	                     name     = "demoGroup",
	                     clip     = { 4, 4, DEMO_SIZE, DEMO_SIZE },  -- clip within demoArea's borders
	} )
	screen:add( demoGroup )

	-- Define three rectangles to animate and add them to the demoGroup
	rectRed   = Rectangle( { size         = { SIZE, SIZE },
	                         color        = { 250, 0, 0, 255 },
	                         anchor_point = { SIZE / 2, SIZE / 2 },
	                         name         = "rectRed",
	} )
	rectGreen = Rectangle( { size         = { SIZE, SIZE },
							 color        = { 0, 250, 0, 255 },
							 anchor_point = { SIZE / 2, SIZE / 2 },
							 name         = "rectGreen",
	} )
	rectBlue  = Rectangle( { size         = { SIZE, SIZE },
	                         color        = { 0, 0, 250, 255 },
	                         anchor_point = { SIZE / 2, SIZE / 2 },
	                         name         = "rectBlue",
	} )
	demoGroup:add( rectRed, rectGreen, rectBlue )

	-- Determine starting and ending positions for each rectangle
	-- Each variable is in the format { startX, startY, endX, endY }
	rectRedAnimationPositions   = getAnimationPositions()
	rectGreenAnimationPositions = getAnimationPositions()
	rectBlueAnimationPositions  = getAnimationPositions()

	-- Create Interval objects for all the animated X and Y coordinates
	-- Note: These objects are re-used and reset for each iteration through the animation
	rectRedRangeX   = Interval( rectRedAnimationPositions[ 1 ],   rectRedAnimationPositions[ 3 ] )
	rectRedRangeY   = Interval( rectRedAnimationPositions[ 2 ],   rectRedAnimationPositions[ 4 ] )
	rectGreenRangeX = Interval( rectGreenAnimationPositions[ 1 ], rectGreenAnimationPositions[ 3 ] )
	rectGreenRangeY = Interval( rectGreenAnimationPositions[ 2 ], rectGreenAnimationPositions[ 4 ] )
	rectBlueRangeX  = Interval( rectBlueAnimationPositions[ 1 ],  rectBlueAnimationPositions[ 3 ] )
	rectBlueRangeY  = Interval( rectBlueAnimationPositions[ 2 ],  rectBlueAnimationPositions[ 4 ] )

	-- Create Interval object for the rectangle's Z-rotation
	-- Each rectangle shares this object
	rectRangeRotation = Interval( 0, 1080 )  -- rotate three times (360x3)

	-- Place rectangles at their starting positions
	positionRects()

	-- Create the animation Timeline object
	animationTL = Timeline( { duration = 2000 } )

	-- Hook the event handlers into their events
	animationTL:add_onnewframe_listener( rectNewFrameEvent )
	animationTL:add_oncompleted_listener( rectCompletedEvent )

	-- Show the screen
	screen:show()

	-- Start the animation
	animationTL:start()

	-- ********************************
