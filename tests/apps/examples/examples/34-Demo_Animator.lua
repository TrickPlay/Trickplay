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
sphereImage.position = { 770, 220 }
sphereImage.name = "Sphere"
sphereImage.anchor_point = { 20, 20 },
screen:add( sphereImage )
screen:show()

-- Attach a Timeline to the Animator's animation to have it loop
sphereTL = Timeline { duration = 1500, loop = true }

-- Define an Animator for the sphere
sphereAnimator = Animator( {
	timeline = sphereTL,
	properties = {
		-- Object-Property #1
		-- Animate along the X-axis. The sphere simply moves back and forth along the X-axis.
		-- When moving from left to right, it moves faster than when moving from right to left.
		-- When combined with the scale key frames below, this gives the appearance of the sphere
		-- moving faster when it is closer to us, and slower when farther away.
		{ source = sphereImage,     -- object to animate
		  name = "x",               -- property to animate
		  interpolation = "CUBIC",  -- smooth interpolation
		  -- X-axis key frames
		  keys = {
		  	{ 0.000, "LINEAR", 770 },
		  	{ 0.150, "LINEAR", 900 },
		  	{ 0.300, "LINEAR", 1030 },
		  	{ 0.600, "LINEAR", 900 },
		  	{ 1.000, "LINEAR", 770 }
		  }
		},

		-- Object-Property #2
		-- Animate the sphere's scale to give the appearance of moving closer and then farther away.
		{ source = sphereImage,
		  name = "scale",
		  -- Scale key frames
		  keys = {
		    { 0.000, "LINEAR", { 1.0, 1.0 } },
		    { 0.150, "LINEAR", { 3.0, 3.0 } },
		    { 0.300, "LINEAR", { 1.0, 1.0 } },
		    { 0.600, "EASE_OUT_QUAD", { 0.5, 0.5 } },
		    { 1.000, "EASE_IN_QUAD", { 1.0, 1.0 } }
		  }
		}
	}
} )

-- Start the Animator animation
sphereAnimator:start()
