
test_description = "Upload and display various types of bitmap jpgs."
test_group = "smoke"
test_area = "bitmap"
test_api = "src - jpg"


local test_image = Canvas (screen.w, screen.h)

function generate_test_image ()
 	

        local bitmap1 = Bitmap ( "packages/assets/small_240x160_panda.jpg")
	local image1 = bitmap1:Image()
	image1.position = { 30, screen.h/6}

        local bitmap2 = Bitmap ( "packages/assets/medium_640x420_MQ_Progressive_panda.jpg")
	local image2 = bitmap2:Image()
	image2.position = { 300, screen.h/6}

        local bitmap3 = Bitmap ( "packages/assets/large_3000x2000_MQ_panda.jpg")
	local image3 = bitmap3:Image()
	image3.position = { screen.w/8 * 4, screen.h/6}
	image3.scale = {0.3, 0.3 }
	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           image1,
		   Text {
			text = "Small jpg\n240x160",
			position = { 30, screen.h/6 + 170},
			color = "000000",
			font = "sans 40px"
		   },
		   image2,
		   Text {
			text = "Medium progressive jpg\n640x420",
			position = { 300, screen.h/6 + 450},
			color = "000000",
			font = "sans 40px"
		   },
		   image3,
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















