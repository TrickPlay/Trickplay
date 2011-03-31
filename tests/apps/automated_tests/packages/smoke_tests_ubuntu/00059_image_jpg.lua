
test_description = "Upload and display various types of jpg."
test_group = "smoke"
test_area = "image"
test_api = "src - jpg"


function generate_test_image ()
 	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           Image {
			src = "packages/assets/small_240x160_panda.jpg",
			position = { 30, screen.h/6},
		   },
		   Text {
			text = "Small jpg\n240x160",
			position = { 30, screen.h/6 + 180},
			color = "000000",
			font = "sans 40px"
		   },
		   Image {
			src = "packages/assets/medium_640x420_MQ_Progressive_panda.jpg",
			position = { 300, screen.h/6},
		   },
		   Text {
			text = "Medium progressive jpg\n640x420",
			position = { 300, screen.h/6 + 460},
			color = "000000",
			font = "sans 40px"
		   },
		   Image {
			src = "packages/assets/large_3000x2000_MQ_panda.jpg",
			position = { screen.w/8 * 4, screen.h/6},
			scale = {0.3, 0.3 }
		   },
		   Text {
			text = "Large jpg scaled down\n3000x2000",
			position = { screen.w/8 * 4, screen.h/6 + 600},
			color = "000000",
			font = "sans 40px"
		   }
		}
	}

	return g
end















