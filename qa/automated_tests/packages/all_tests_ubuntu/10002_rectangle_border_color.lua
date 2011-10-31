test_description = "Create rectangles with a variety of border colors including alphas"
test_group = "acceptance"
test_area = "rectangle"
test_api = "border_color"


function generate_test_image ()

	 local test_image = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 32,
	            	border_color = "0000000",
	            	size = { 200, 200 },
		        position = { screen.w/8 , screen.h/4 }
	             },
                     Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 32,
	            	border_color = "000000AA",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 2 , screen.h/4 }
		     },
	              Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 32,
	            	border_color = "00000044",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 3 , screen.h/4 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 32,
	            	border_color = "CCCCCCFF",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 4 , screen.h/4 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 32,
	            	border_color = "00000011",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 5 , screen.h/4 }
		     }
                     }
	}
	
	return test_image
end
