
test_description = "Upload and display a bitmap using http."
test_group = "smoke"
test_area = "bitmap"
test_api = "src - HTTP"


function generate_test_image ()

   local bitmap1 = Bitmap ( "http://www.google.com/images/logos/logo.png")
	local image1 = bitmap1:Image()
	image1.position = { screen.w/2, screen.h/2}
	image1.scale = { 3.0, 3.0 }

	return image1
end















