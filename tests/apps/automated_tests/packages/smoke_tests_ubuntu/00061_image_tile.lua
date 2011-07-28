
test_description = "Tile jpg, gif and png files using async"
test_group = "smoke"
test_area = "image"
test_api = "tile"


function generate_test_image ()
 
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           Image {
			async = true,
			src = "packages/assets/small_120x90_shapes.gif",
			position = { 980, screen.h/2 + 100},
			size = { 480, 360 },
			tile = { true, true }
		   },
		   Text {
			text = "Small gif tiled",
			position = { 980, screen.h - 50},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   Image {
			async = true,
			src = "packages/assets/small_240x320_layers.png",
			position = { 50, screen.h/10},
			size = { 720, 960 },
			tile = { true, true }
		   },
		   Text {
			text = "Small png tiled",
			position = { 50, screen.h - 50},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   Image {
			async = true,
			src = "packages/assets/small_240x160_panda.jpg",
			position = { 980, screen.h/10},
			size = { 720, 480 },
			tile = { true, true }
		   },
		   Text {
			text = "Small jpg tiled",
			position = { 980, screen.h/2 + 50},
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
		}
	}


	return g
end















