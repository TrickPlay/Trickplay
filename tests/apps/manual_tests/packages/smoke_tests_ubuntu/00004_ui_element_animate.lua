--[[
Filename: 0001_rectangle_basic.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Test type: Manual GUI Test
Description: Create several rectangles and verify that they display as expected
--]]

-- Test Set up --

test_question = "Does the code image animate and finish looking like the baseline?"

function generate_test_image ()


	 local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = "FFFFFF",
	            	size = { screen.w, screen.h }
	            },
	         	Image {
					name = "animated_png",
	         		src = "/packages/"..test_folder.."/assets/logo.png",
	         		position = { 200, 200 },
	         		size = { 100, 100 }
	         	}
	         	
	 		 }
	 }

	g:find_child("animated_png"):animate{
									duration=2000,
									loop=false,
									position = { screen.w/2, screen.h/2 },
									h=400,
									w=400,
								 	z_rotation=90
								 	}
	return g
end











