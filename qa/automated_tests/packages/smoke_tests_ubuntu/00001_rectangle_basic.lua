
test_description = "Create simple rectangles in a Group with Children"
test_group = "smoke"
test_area = "rectangle"
test_api = "basic"


function generate_test_image ()

	 local test_image = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = { 153, 51, 85 },
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 200, 300 },
			position = { screen.w/4 , screen.h/2 }
	            },
	             Rectangle {
	            	color = "F5B800",
	            	size = {  100, 100 },
	            	position = { screen.w/4 * 3, screen.h/4 * 3  }
	            }
	         }
		}
	
	return test_image
end











