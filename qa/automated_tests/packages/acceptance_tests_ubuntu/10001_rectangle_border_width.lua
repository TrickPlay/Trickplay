test_description = "Create rectangles with a variety of border_widths"
test_group = "acceptance"
test_area = "rectangle"
test_api = "border_width"


function generate_test_image ()

	 local test_image = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 0,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		        position = { screen.w/8 , screen.h/4 }
	             },
                     Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 1,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 2 , screen.h/4 }
		     },
	              Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 2,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 3 , screen.h/4 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 4,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 4 , screen.h/4 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 8,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 5 , screen.h/4 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 16,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 6 , screen.h/4 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 32,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8, screen.h/4 * 2 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 64,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 2, screen.h/4 * 2 }
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 128,
	            	border_color = "FF0066",
	            	size = { 200, 200 },
		       position = { screen.w/8 * 3 , screen.h/4 * 2}
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 0,
	            	border_color = "FF0066",
	            	size = { 400, 200 },
		       position = { screen.w/8 * 4 , screen.h/4 * 2}
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 1,
	            	border_color = "FF0066",
	            	size = { 400, 200 },
		       position = { screen.w/8 * 6 , screen.h/4 * 2}
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 2,
	            	border_color = "FF0066",
	            	size = { 400, 200 },
		       position = { screen.w/8 , screen.h/4 * 3}
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 4,
	            	border_color = "FF0066",
	            	size = { 400, 200 },
		       position = { screen.w/8 * 3 , screen.h/4 * 3}
		     },
                      Rectangle {
	            	color = { 220, 151, 85 },
	            	border_width = 8,
	            	border_color = "FF0066",
	            	size = { 400, 200 },
		       position = { screen.w/8 * 5 , screen.h/4 * 3}
		     },
                     }
	}
	
	return test_image
end
