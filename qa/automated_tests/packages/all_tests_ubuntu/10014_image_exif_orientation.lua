
test_description = "View 2 pictures taken in portrait orientation. Verify the one with the exif orientation tag = rotate CW 90 is rotated correctly."
test_group = "acceptance"
test_area = "image"
test_api = "exif orientation"


function generate_test_image ()
 	
	local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	           Image {
			src = "packages/assets/exif_pic_none.jpg",
			position = { screen.w/2, 150},
		   },
		   Text {
		--	text = "no exif orientation tag",
			position = { screen.w/2, 150},
			color = "000000",
			font = "DejaVu Sans 40px"
		   },
		   Image {
			src = "packages/assets/exif_rotate_90_cw.jpg",
			position = { 150, 150},
		   },
		   Text {
		--	text = "exif orientation tag = Rotate 90 CW",
			position = { 150, 150 },
			color = "000000",
			font = "DejaVu Sans 40px"
		   }
		}
	}

	return g
end















