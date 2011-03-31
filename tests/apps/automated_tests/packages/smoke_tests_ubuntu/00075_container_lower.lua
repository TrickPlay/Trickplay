
test_description = "Lower an item in the container"
test_group = "smoke"
test_area = "container"
test_api = "lower_child"


function generate_test_image ()

	 local test_image = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
		     Group {
			name = "text1",
			children = 
			{
			     Rectangle {
				color = { 153, 51, 85 },
			    	border_width = 5,
			    	border_color = "FF0066",
			    	size = { 200, 300 },
				position = { 200, 200 }
			     },
			     Text {
				font = "Sans 60px",
				text = "Text 1",
			    	color = "000000",
			    	position = { 250, 350 }
			    }
			}
		     },
 		    Group {
			name = "text2",
			children = 
			{
			     Rectangle {
				color = "F5B800",
			    	border_width = 5,
			    	border_color = "FF0066",
			    	size = { 200, 300 },
				position = { 200, 200 }
			     },
			     Text {
				font = "Sans 60px",
				text = "Text 2",
			    	color = "000000",
			    	position = { 250, 350 }
			    }
			}
		     },
 		    Group {
			name = "text3",
			children = 
			{
			     Rectangle {
				color = "003DF5",
			    	border_width = 5,
			    	border_color = "FF0066",
			    	size = { 200, 300 },
				position = { 200, 200 }
			     },
			     Text {
				font = "Sans 60px",
				text = "Text 3",
			    	color = "000000",
			    	position = { 250, 350 }
			    }
			}
	             }
		  }

		}
	test_image:lower_child(test_image:find_child("text3"))

	return test_image
end











