
-- Test Set up --
local test_description = "Create simple rectangles in a Group with Children"
local test_group = "smoke"
local test_area = "rectangle"
local test_api = "basic"


test_question = "Do the two images match two?"

function generate_test_image ()

	 local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = "FFFFFF",
	            	size = { screen.w, screen.h }
	            },
	            Rectangle {
	            	color = { 153, 51, 85 },
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 400, 400 },
					position = { screen.w/2 , screen.h/2 }
	            },
	             Rectangle {
	            	color = "F5B800",
	            	size = { 100, 100 },
	            	position = { 100,100 }
	            },
	             Rectangle {
	            	color = "343434",
	            	size = { 430, 100 },
	            	position = { 100,100 }
	            },
	             Rectangle {
	            	color = "8781AA",
	            	size = { 100, 700 },
	            	position = { 100,100 }
	            },
	            Text {
	            	font = "sans 40px",
	            	text = "0002"
	            }
	         }
		}
	return g
end











