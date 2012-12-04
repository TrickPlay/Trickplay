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
					    position     = { 96, 96, 0 },
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
sphereImage          = sphere:Image()
sphereImage.position = { 100, 100 }
sphereImage.name     = "Sphere"
screen:add( sphereImage )

-- Define an Ease mode for our animation
sphereEase = Ease( "EASE_IN_OUT_QUINT" )

-- Animate the sphere with a Timeline
sphereTL = Timeline( { duration = 3000, loop = true } )

--Define a Path for the sphere
spherePath = Path( "M100 100 l30 0 l30 260 l30 -200 l30 200 l30 -100 l30 100 l30 -25 l30 25 L360 360" )

--[[ Note: The same Path could have been constructed by calling the following functions...
spherePath = Path()
spherePath:move_to( 100, 100 )       -- "M100 100"
spherePath:line_to( 30, 0, true )    -- "l30 0" using coordinates relative to last-defined node
spherePath:line_to( 30, 260, true )  -- "l30, 260"
spherePath:line_to( 30, -200, true ) -- "l30 -200"
spherePath:line_to( 30, 200, true )  -- "l30 200"
spherePath:line_to( 30, -100, true ) -- "l30 -100"
spherePath:line_to( 30, 100, true )  -- "l30 100"
spherePath:line_to( 30, -25, true )  -- "l30 -25"
spherePath:line_to( 30, 25, true )   -- "l30 25"
spherePath:line_to( 360, 360 )       -- "L360 360" using coordinates absolute to the display
--]]

-- Define a handler for Timeline on_new_frame events that accesses the transformed Path and Ease values to determine the sphere's location
function followPath( self, msecs, progress )
	sphereImage.position = spherePath:get_position( sphereEase:get_value( progress ) )
end

-- Hook the handler into the Timeline's on_new_frame events
sphereTL:add_onnewframe_listener( followPath )

-- Make the screen visible
screen:show()

-- Start the animation
sphereTL:start()
