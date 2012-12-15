
test_description = "y_rotating an image"
test_group = "smoke"
test_area = "UI_element"
test_api = "y_rotation"


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
	myImg1.y_rotation = { 30, 0, 0 }
	myImg2.y_rotation = { 45, 0, 0 }
	myImg3.y_rotation = { 60, 0, 0 }


    g:add (myImg, myImg1, myImg2, myImg3)

	return g
end















