
test_description = "save a state, make a change to it and then restore"
test_group = "smoke"
test_area = "canvas"
test_api = "save/restore"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)

	test_image:rectangle (screen.w/2 - 200, screen.h/4, 600, 400)
	test_image:set_source_color({255, 51, 102, 190})

	test_image:save()

	test_image:rectangle (screen.w/2 - 200, screen.h/4, 600, 400)
	test_image:set_source_color({0, 0, 0, 255})

	test_image:restore()

	test_image:fill()

	return test_image:Image ()

end















