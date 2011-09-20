
-- Create three demo areas showing the effect of the Alpha mode on a Timeline's animated property

-- Create a screen background
bckgnd = Canvas( 1920, 1080 )
bckgnd:set_source_color( "ffffffFF" )
bckgnd:paint()
bckgndImage = bckgnd:Image()
bckgndImage.name = "Background"
screen:add( bckgndImage )

-- Create a rectangular demo area
demoArea = Rectangle {
				color = { 100, 100, 100, 255 },
				border_color = { 0, 0, 0, 255 },
				border_width = 4,
				name = "demoArea",
				position = { 96, 96, 0 },
				size = { 308, 308 },
				opacity = 255,
			}
screen:add( demoArea )

-- Create clone demo areas
demoArea2 = Clone { 
				source = demoArea,
				name = "demoArea2",
				position = { 421, 96, 0 },
			}
screen:add( demoArea2 )

demoArea3 = Clone {
				source = demoArea,
				name = "demoArea3",
				position = { 746, 96, 0 },
			}
screen:add( demoArea3 )

-- Create a sphere image using Canvas
sphere = Canvas( 40, 40 )
sphere:set_source_radial_pattern( 12, 12, 2, 20, 20, 20 )
sphere:add_source_pattern_color_stop( 0.0, "d00000FF" )
sphere:add_source_pattern_color_stop( 1.0, "000000FF" )
sphere:arc( 20, 20, 20, 0, 360 )
sphere:fill()

-- Convert Canvas object to Image object and show on the screen
sphereImage = sphere:Image()
sphereImage.position = { 230, 100 }
sphereImage.name = "Sphere"
screen:add( sphereImage )

-- Create clone sphere images
sphereImage2 = Clone {
				source = sphereImage,
				name = "Sphere2",
				position = { 555, 100, 0 },
			}
screen:add( sphereImage2 )

sphereImage3 = Clone {
				source = sphereImage,
				name = "Sphere3",
				position = { 880, 100, 0 },
			}
screen:add( sphereImage3 )

-- Define an Interval for our animation
sphereInterval  = Interval( 100, 400 - 40 )

-- Define an Alpha mode for our animation
sphereAlpha  = Alpha { mode = "EASE_IN_ELASTIC" }
sphereAlpha2 = Alpha { mode = "EASE_OUT_ELASTIC" }
sphereAlpha3 = Alpha { mode = "EASE_IN_OUT_ELASTIC" }

-- Animate the spheres with Timelines
sphereTL = Timeline { 
				duration = 1500,
				loop = true,
			}
sphereTL2 = Timeline {
				duration = 1500,
				loop = true,
			}
sphereTL3 = Timeline {
				duration = 1500,
				loop = true,
			}
			
-- Hook the Alphas to the Timelines
sphereAlpha.timeline  = sphereTL
sphereAlpha2.timeline = sphereTL2
sphereAlpha3.timeline = sphereTL3
			
-- Define the on_new_frame() event handlers
function sphereTL:on_new_frame( msecs, progress )
	sphereImage.y = sphereInterval:get_value( sphereAlpha.alpha )
end

function sphereTL2:on_new_frame( msecs, progress )
	sphereImage2.y = sphereInterval:get_value( sphereAlpha2.alpha )
end

function sphereTL3:on_new_frame( msecs, progress )
	sphereImage3.y = sphereInterval:get_value( sphereAlpha3.alpha )
end

-- Start all the animations
sphereTL:start()
sphereTL2:start()
sphereTL3:start()

