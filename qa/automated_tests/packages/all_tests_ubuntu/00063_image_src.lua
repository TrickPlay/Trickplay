
test_description = "Upload and display an image using http."
test_group = "smoke"
test_area = "image"
test_api = "src - HTTP"


function generate_test_image ()
 	
	local g = Group
	 {
	        children = {
	           Image {
			src = "http://www.google.com/images/logos/logo.png",
			position = { screen.w/2, screen.h/2},
			scale = { 3.0, 3.0 }
		   }
		}
	}


	return g
end















