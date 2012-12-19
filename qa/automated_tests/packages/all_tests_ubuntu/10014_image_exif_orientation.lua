
test_description = "View 2 pictures taken in portrait orientation. Verify the one with the exif orientation tag = rotate CW 90 is rotated correctly."
test_group = "acceptance"
test_area = "image"
test_api = "exif orientation"


function generate_test_image ()

	image1_loaded = false
	image2_loaded = false

	local image1 = Image ()

	image1.src = "packages/assets/exif_pic_none.jpg"
	image1.position = { screen.w/2, 150}


	local image2 = Image ()

	image2.src = "packages/assets/exif_rotate_90_cw.jpg"
	image2.position = { 150, 150}


	local g = Group ()

	g:add(image1, image2)

	return g
end















