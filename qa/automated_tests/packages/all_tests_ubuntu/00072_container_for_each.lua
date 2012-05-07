
test_description = "Use for_each to rotate each item in the group by 45 degrees."
test_group = "smoke"
test_area = "container"
test_api = "for_each"


function generate_test_image ()

	 local test_image = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
			name = "rec1",
	            	color = { 153, 51, 85 },
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 100, 300 },
			position = { 300 , 100 }
	            },
	             Rectangle {
			name = "rec2",
	            	color = "F5B800",
	            	size = {  300, 500 },
	            	position = { 500, 400 }
	            },
		     Image {
			src = "packages/assets/small_240x320_layers.png",
			position = { screen.w/2, screen.h/2},
		   }
	         }
		}

	local rec3 = Rectangle {
			color = "00CC44",
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 400, 200 },
			position = { screen.w/4 * 3 , screen.h/4 * 2 }
			}
	test_image:add(rec3)

	function rotate_90_degrees ( uiElement )
		uiElement.z_rotation = { 45, 0 , 0 }
	end

	test_image:foreach_child ( rotate_90_degrees )	

	return test_image
end











