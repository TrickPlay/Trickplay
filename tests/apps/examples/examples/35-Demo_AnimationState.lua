	-- Create a screen background
	bckgnd = Canvas( 1920, 1080 )
	bckgnd:set_source_color( "ffffffFF" )
	bckgnd:paint()
	bckgndImage = bckgnd:Image()
	bckgndImage.name = "Background"
	screen:add( bckgndImage )

	-- Create a rectangular demo area
	demoArea = Rectangle( { color        = { 100, 100, 100, 255 },
							border_color = { 0, 0, 0, 255 },
							border_width = 4,
							name         = "demoArea",
							position     = { 746, 96, 0 },
							size         = { 308, 308 },
							opacity      = 255,
	} )
	screen:add( demoArea )

	-- Create a sphere image using Canvas
	sphere = Canvas( 40, 40 )
	sphere:set_source_radial_pattern( 12, 12, 2, 20, 20, 20 )
	sphere:add_source_pattern_color_stop( 0.0, "d00000FF" )
	sphere:add_source_pattern_color_stop( 1.0, "000000FF" )
	sphere:arc( 20, 20, 20, 0, 360 )
	sphere:fill()

	-- Convert Canvas object to Image object and show on the screen
	sphereImage = sphere:Image()
	sphereImage.position = { 900, 220 }
	sphereImage.name = "Sphere"
	sphereImage.anchor_point = { 20, 20 }
	screen:add( sphereImage )
	screen:show()

	-- Define an AnimationState for the sphere
	sphereAnimationState = AnimationState( {
			duration = 2000,            -- default transition duration
			mode = "EASE_IN_OUT_QUAD",  -- default Ease mode for all transitions
			transitions = {
				{ -- Wildcard state--->Disappear
				  source = "*",
				  target = "disappear",
				  keys = {
				  		{ sphereImage, "scale", {0.0, 0.0} },
				  }
				},
				{ -- Disappear--->Appear
				  source = "disappear",
				  target = "appear",
				  keys = {
				  		{ sphereImage, "scale", {2.0, 2.0} },
				  }
				}
			}
	} )

	-- Define an on_completed event handler for the sphere's AnimationState so we can daisy-chain states
	function reverseDirection()
		-- Depending on completed state, toggle to other state
		if( sphereAnimationState.state == "disappear" )then
			sphereAnimationState.state = "appear"
		else
			sphereAnimationState.state = "disappear"
		end
	end

	-- Register the reverseDirection() handler with the on_completed event
	sphereAnimationState:add_oncompleted_listener( reverseDirection )

	-- Start the animation
	sphereAnimationState.state = "disappear"  -- Matches the wildcard "*" source transition
