
test_description = "x_rotating an image"
test_group = "smoke"
test_area = "UI_element"
test_api = "x_rotation"


function generate_test_image ()
 	local g = Group ()

	local myImg = Image {
	            	name = "myImage",
			src = "packages/assets/globe.png",
			x = screen.w/6,
			y = 300
		}

	local myImg1 = Image {
	            	name = "myImage1",
			src = "packages/assets/globe.png",
			x = screen.w/6 * 2,
			y = 300
		}

	local myImg2 = Image {
	            	name = "myImage2",
			src = "packages/assets/globe.png",
			x = screen.w/6 * 3,
			y = 300
		   }

	local myImg3 = Image {
        		name = "myImage4",
			src = "packages/assets/globe.png",
			x = screen.w/6 * 4,
			y = 300
		   }
	myImg.anchor_point = { myImg.w/2, myImg.h/2}
	myImg1.anchor_point = { myImg1.w/2, myImg1.h/2}
	myImg2.anchor_point = { myImg2.w/2, myImg2.h/2}
	myImg3.anchor_point = { myImg3.w/2, myImg3.h/2}
	myImg1.x_rotation = { 30, 200, 0 }
	myImg2.x_rotation = { 45, 200, 0 }
	myImg3.x_rotation = { 60, 200, 0 }


g:add (myImg, myImg1, myImg2, myImg3)

-- Check that is_rotated is returning true	
	local result
	if myImg2.is_rotated == true then
		result = "true"
	else
		result = "false"
	end
	
	local is_rotated_txt = Text()
	is_rotated_txt.font="DejaVu Sans 30px"
	is_rotated_txt.position={screen.w - 300, 100}
	is_rotated_txt.text = "is_rotated = "..result
	is_rotated_txt.color = "000000"
	g:add(is_rotated_txt)

	return g
end















