
test_description = "Rotate the text 90, 180 and 270 degrees"
test_group = "smoke"
test_area = "canvas"
test_api = "rotate"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)
	test_image:set_source_color ("CC0099")
	test_image:move_to (screen.w/2, screen.h/2)
	test_image:rotate (0)
	test_image:text_path ("DejaVu Sans 30px","This text is normal")
	test_image:rotate (90)
	test_image:text_path ("DejaVu Sans 30px","This text goes down")
	test_image:rotate (90)
	test_image:text_path ("DejaVu Sans 30px","This text is upside-down")
	test_image:rotate (90)
	test_image:text_path ("DejaVu Sans 30px","This text goes up")
	test_image:fill()

	return test_image:Image ()

end














