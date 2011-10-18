
test_description = "Offset the x, y coordinates so they are off the screen."
test_group = "acceptance"
test_area = "canvas"
test_api = "translate"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)

	test_image:translate (screen.w + 300  ,  screen.h + 200 )
	test_image:rectangle (-600, -400,  300, 200)
	test_image:set_source_color({120, 200, 300 , 255})

	test_image:fill()

	return test_image:Image ()

end















