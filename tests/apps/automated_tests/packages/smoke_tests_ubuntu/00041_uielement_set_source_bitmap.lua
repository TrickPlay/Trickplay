
test_description = "Clip the globe so that only a square section of it displays"
test_group = "smoke"
test_area = "UI_element"
test_api = "set_source_bitmap"


function generate_test_image ()

local bitmap1 = Bitmap( "packages/"..test_folder.."/assets/globe.png",false)

	local test_image = Canvas (screen.w, screen.h)
	test_image:rectangle(200, 200, 400, 400 )
	test_image:set_source_bitmap (bitmap1, 100, 100)	
	--test_image:set_source_color({255, 51, 102, 190})
	test_image:fill()

	return test_image:Image()

end















