
test_description = "Use for_each to remove all ui items in the container"
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
			position = { 100 , 100 }
	            },
	             Rectangle {
			name = "rec2",
	            	color = "F5B800",
	            	size = {  300, 500 },
	            	position = { 400, 500 }
	            }
	         }
		}

	local rec3 = Rectangle {
			color = "00CC44",
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 200, 300 },
			position = { screen.w/4 * 3 , screen.h/4 * 2 }
			}
	test_image:add(rec3)

	local children = test_image.children
	for _,child in ipairs (children) do
		print (child)
		test_image:remove (child)
	end
	return test_image
end











