
test_description = "Upload and display various types of bitmap gifs."
test_group = "smoke"
test_area = "bitmap"
test_api = "src - gif"


local test_image = Canvas (screen.w, screen.h)

function generate_test_image ()
 	

        local bitmap1 = Bitmap ( "packages/assets/small_120x90_shapes.gif")
	local image1 = bitmap1:Image()
	image1.position = { 30, screen.h/6}

        local bitmap2 = Bitmap ( "packages/assets/medium_640x480_compression_shapes.gif")
	local image2 = bitmap2:Image()
	image2.position = { screen.w/8, screen.h/6}

        local bitmap3 = Bitmap ( "packages/assets/large_1920x1440_shapes.gif")
	local image3 = bitmap3:Image()
	image3.position = { screen.w/8 * 4, screen.h/6}
	image3.scale = {0.5, 0.5 }
	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           image1,
		   Text {
			text = "Small gif\n120x90",
			position = { 30, screen.h/6 + 100},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   image2,
		   Text {
			text = "Medium gif with compression\n640x480",
			position = { screen.w/8, screen.h/6 + 500},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   image3,
		   Text {
			text = "Large gif scaled down\n1920x1440",
			position = { screen.w/8 * 4, screen.h/6 + 730},
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
		}
	}

	return g
end















