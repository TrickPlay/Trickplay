
test_description = "Display the top left quadrant of the bitmap with 0 opacity."
test_group = "smoke"
test_area = "bitmap"
test_api = "image"


function generate_test_image ()

	local bitmap1 = Bitmap ( "packages/assets/medium_480x640_layers.png")
	local image1 = bitmap1:Image({ opacity = 255 },{0, 0, 240, 320})
	image1.position = { 100, 100 }

	image2 = bitmap1:Image({ opacity = 120 })
	image2.position = { 100, 100 }

	local g = Group ()
	g:add (image1)
	g:add (image2)

	return g
end















