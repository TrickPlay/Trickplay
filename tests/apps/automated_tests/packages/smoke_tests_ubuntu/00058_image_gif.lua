
test_description = "Upload and display various types of gifs."
test_group = "smoke"
test_area = "image"
test_api = "src - gif"


function generate_test_image ()
 	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           Image {
			src = "packages/assets/small_120x90_shapes.gif",
			position = { 30, screen.h/6},
		   },
		   Text {
			text = "Small gif\n120x90",
			position = { 30, screen.h/6 + 100},
			color = "000000",
			font = "sans 40px"
		   },
		   Image {
			src = "packages/assets/medium_640x480_compression_shapes.gif",
			position = { screen.w/8, screen.h/6},
		   },
		   Text {
			text = "Medium gif with compression\n640x480",
			position = { screen.w/8, screen.h/6 + 500},
			color = "000000",
			font = "sans 40px"
		   },
		   Image {
			src = "packages/assets/large_1920x1440_shapes.gif",
			position = { screen.w/8 * 4, screen.h/6},
			scale = {0.5, 0.5 }
		   },
		   Text {
			text = "Large gif scaled down\n1920x1440",
			position = { screen.w/8 * 4, screen.h/6 + 730},
			color = "000000",
			font = "sans 40px"
		   }
		}
	}


	return g
end















