
-- Test Set up --


test_question = "Do the two images match three?"

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
	            	color = "F5B800",
	            	size = { 200, 200 },
	            	position = { 100,100 }
	            } ,
	             Rectangle {
	            	color = "F5B800",
	            	size = { 500, 500 },
	            	position = { 100,100 }
	            },
	            Text {
	            	font = "sans 40px",
	            	text = "0003"
	            }
	         }
		}
	return g
end











