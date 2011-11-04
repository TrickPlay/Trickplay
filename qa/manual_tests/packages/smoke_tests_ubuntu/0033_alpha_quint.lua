-- Test Set up --
local test_description = "Alpha Quint"
local test_group = "acceptance"
local test_area = "alpha"
local test_api = "quint"

test_question = "Match the 3 alpha movements on the right with the charts on the left."

function generate_test_image ()

	local g = Group ()

	-- EASE IN QUINT --

	local demoArea1 = Rectangle {
						color = { 100, 100, 100, 255 },
						border_color = { 0, 0, 0, 255 },
						border_width = 4,
						name = "demoArea",
						position = { 196, 396, 0 },
						size = { 308, 308 },
						opacity = 255,
					}
	g:add( demoArea1 )

	-- Create a sphere image using Canvas
	local sphere = Canvas( 40, 40 )
	sphere:set_source_radial_pattern( 12, 12, 2, 20, 20, 20 )
	sphere:add_source_pattern_color_stop( 0.0, "d00000FF" )
	sphere:add_source_pattern_color_stop( 1.0, "000000FF" )
	sphere:arc( 20, 20, 20, 0, 360 )
	sphere:fill()

	-- Convert Canvas object to Image object and show on the screen
	local sphereImage1 = sphere:Image()
	sphereImage1.position = { demoArea1.x + (demoArea1.width / 2) - 20, demoArea1.y }  -- top-center of demo area
	--sphereImage1.name = "Sphere"
	g:add( sphereImage1 )

	-- *** SET DESIRED ALPHA MODE HERE ***
	local alphaMode1 = "EASE_IN_QUINT"

	-- Animate the sphere
	sphereImage1:animate( { duration = 3000,
						   loop     = true,
						   y        = demoArea1.y + demoArea1.height - 40,
						   mode     = alphaMode1,
						 } )

	local alpha_desc1_txt = Text { 
							text = "EASE IN QUINT",
							position = { 230, 710 },
							font = "Deja Vu 50px",
							color = "000000"
					}
	g:add (alpha_desc1_txt) 


-- EASE OUT QUINT --

	local demoArea2 = Rectangle {
						color = { 100, 100, 100, 255 },
						border_color = { 0, 0, 0, 255 },
						border_width = 4,
						position = { 700, 396, 0 },
						size = { 308, 308 },
						opacity = 255,
					}
	g:add( demoArea2 )


	local sphereImage2 = sphere:Image()
	sphereImage2.position = { demoArea2.x + (demoArea2.width / 2) - 20, demoArea2.y }  
	g:add( sphereImage2 )

	-- *** SET DESIRED ALPHA MODE HERE ***
	local alphaMode2 = "EASE_OUT_QUINT"

	-- Animate the sphere
	sphereImage2:animate( { duration = 3000,
						   loop     = true,
						   y        = demoArea2.y + demoArea2.height - 40,
						   mode     = alphaMode2,
						 } )

	local alpha_desc2_txt = Text { 
							text = "EASE OUT QUINT",
							position = { 720, 710 },
							font = "Deja Vu 50px",
							color = "000000"
					}
	g:add (alpha_desc2_txt) 


	-- EASE IN OUT QUINT

	local demoArea3 = Rectangle {
						color = { 100, 100, 100, 255 },
						border_color = { 0, 0, 0, 255 },
						border_width = 4,
						position = { 1200, 396, 0 },
						size = { 308, 308 },
						opacity = 255,
					}
	g:add( demoArea3 )

	-- Convert Canvas object to Image object and show on the screen
	local sphereImage3 = sphere:Image()
	sphereImage3.position = { demoArea3.x + (demoArea3.width / 2) - 20, demoArea3.y }  
	g:add( sphereImage3 )

	-- *** SET DESIRED ALPHA MODE HERE ***
	local alphaMode3 = "EASE_IN_OUT_QUINT"

	-- Animate the sphere
	sphereImage3:animate( { duration = 3000,
						   loop     = true,
						   y        = demoArea3.y + demoArea3.height - 40,
						   mode     = alphaMode3,
						 } )

	local alpha_desc3_txt = Text { 
							text = "EASE IN OUT QUINT",
							position = { 1200, 710 },
							font = "Deja Vu 50px",
							color = "000000"
					}
	g:add (alpha_desc3_txt) 
	g.scale = {1.2, 1.2}

	return g

end







