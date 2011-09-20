
test_description = "Upload and display various types of png."
test_group = "smoke"
test_area = "image"
test_api = "src - png"


function generate_test_image ()
 	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           Image {
			src = "packages/assets/small_240x320_layers.png",
			position = { 100, screen.h/6},
		   },
		   Text {
			text = "Small png\n240x320",
			position = { 100, screen.h/6 + 340},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   Image {
			src = "packages/assets/medium_480x640_layers.png",
			position = { 500, screen.h/6},
		   },
		   Text {
			text = "Medium layers png\n480x640",
			position = { 500, screen.h/6 + 660},
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
		}
	}


	return g
end















