
test_description = "Scaling an image"
test_group = "smoke"
test_area = "UI_element"
test_api = "scale"


function generate_test_image ()
 	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Image {
	            	name = "myImage",
			src = "packages/assets/medium_640x420_panda.jpg",
			x = screen.w/6,
			y = screen.h/6,
			scale = {0.1, 0.1}
		   },
		Image {
	            	name = "myImage1",
			src = "packages/assets/medium_640x420_panda.jpg",
			x = screen.w/6 * 2,
			y = screen.h/6,
			scale = {0.5, 0.5}
		   },
		Text {
			text = "scale = { 0.5, 0.5 }",
			font = "san 30px",
			position = {screen.w/6, 100},
			color = "000000"
		},
		Image {
	            	name = "myImage2",
			src = "packages/assets/medium_640x420_panda.jpg",
			x = screen.w/6 * 4,
			y = screen.h/6,
			scale = {1, 1}
		   },
		Image {
	            	name = "myImage3",
			src = "packages/assets/medium_640x420_panda.jpg",
			x = 100,
			y = screen.h/6 * 3,
			scale = {1.5, 1.5}
		   },
		Image {
	            	name = "myImage3",
			src = "packages/assets/medium_640x420_panda.jpg",
			x = screen.w/6 * 4,
			y = screen.h/6 * 5,
			scale = {1, 0.5}
		   },
		Text {
			text = "scale = {0.1, 0.1}",
			x = screen.w/6 - 100,
			y = screen.h/6 - 50,
			font = "sans 40px"
		   }
-- Need to add text for each scale
		}
	}

-- Check that is scaled is returning true	
	local result
	if g:find_child("myImage1").is_scaled == true then
		result = "true"
	else
		result = "false"
	end
	
	local is_scaled_txt = Text()
	is_scaled_txt.font="sans 30px"
	is_scaled_txt.position={screen.w - 300, 100}
	is_scaled_txt.text = "is_scaled ="..result
	is_scaled_txt.color = "000000"
	g:add(is_scaled_txt)


	return g
end















