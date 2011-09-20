
test_description = "Reset anchor point so that image is centered in the screen."
test_group = "smoke"
test_area = "UI_element"
test_api = "anchor_point"


function generate_test_image ()
 	
local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Image {
	            	name = "myImage",
			src = "packages/assets/medium_640x420_panda.jpg",
			x = screen.w/2,
			y = screen.h/2
		   }
		}
	}

	g:find_child("myImage").anchor_point = { g:find_child("myImage").w/2 , g:find_child("myImage").h/2}


local test_image = Canvas (screen.w, screen.h)
test_image:arc(g:find_child("myImage").anchor_point[1], g:find_child("myImage").anchor_point[2] , 15, 0, 360)
	test_image:set_source_color ("FF0000")
	test_image:fill()
	g:add(test_image:Image ())

	return g
end















