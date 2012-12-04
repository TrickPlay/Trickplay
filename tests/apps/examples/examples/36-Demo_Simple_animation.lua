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

-- Define the animation
local function do_animation()
    sphereImage:animate( {
                            duration     = 2000,
                            opacity      = 0,
                            scale        = { 0, 0 },
                            mode         = "EASE_IN_OUT_QUAD",
                            on_completed = function()
                                sphereImage:animate( { duration     = 2000,
                                                       opacity      = 255,
                                                       scale        = { 2, 2 },
                                                       mode         = "EASE_IN_OUT_QUAD",
                                                       on_completed = do_animation,
                                } )
                            end,
    } )
end

-- Start the animation
do_animation()
