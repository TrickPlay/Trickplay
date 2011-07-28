
test_description = "Upload and display various types of bitmap jpgs."
test_group = "smoke"
test_area = "bitmap"
test_api = "src - jpg"


local test_image = Canvas (screen.w, screen.h)

function generate_test_image ()
 	

        local bitmap1 = Bitmap ( "packages/assets/small_240x320_layers.png")
	local image1 = bitmap1:Image()
	image1.position = { 30, screen.h/6}

        local bitmap2 = Bitmap ( "packages/assets/medium_480x640_layers.png")
	local image2 = bitmap2:Image()
	image2.position = { 300, screen.h/6}

	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           image1,
		   Text {
			text = "Small png\n240x320",
			position = { 30, screen.h/6 + 340},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   image2,
		   Text {
			text = "Medium layers png\n480x640",
			position = { 300, screen.h/6 + 660},
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
		}
	}

	return g
end












