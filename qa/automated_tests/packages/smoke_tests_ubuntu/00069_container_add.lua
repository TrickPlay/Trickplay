
test_description = "Add a rectangle to the container"
test_group = "smoke"
test_area = "container"
test_api = "add"


function generate_test_image ()

	 local test_image = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = { 153, 51, 85 },
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 100, 300 },
			position = { 100 , 100 }
	            },
	             Rectangle {
	            	color = "F5B800",
	            	size = {  300, 500 },
	            	position = { 400, 500 }
	            }
	         }
		}

	local rec1 = Rectangle {
			color = "00CC44",
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 200, 300 },
			position = { screen.w/4 * 3 , screen.h/4 * 2 }
			}
	test_image:add(rec1)
	
	return test_image
end











