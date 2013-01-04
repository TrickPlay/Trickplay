
test_description = "Rotate the text 90, 180 and 270 degrees in negative direction"
test_group = "acceptance"
test_area = "canvas"
test_api = "rotate"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)
	test_image:set_source_color ("CC0099")
	test_image:move_to (screen.w/2, screen.h/2)
	test_image:rotate (0)
	test_image:text_path ("DejaVu Sans 30px","<b>This text is normal</b>")
	test_image:rotate (-90)
	test_image:text_path ("DejaVu Sans 30px","<b>This text goes up</b>")
	test_image:rotate (-90)
	test_image:text_path ("DejaVu Sans 30px","<b>This text is upside-down</b>")
	test_image:rotate (-90)
	test_image:text_path ("DejaVu Sans 30px","<b>This text goes down</b>")
	test_image:fill()

	return test_image:Image ()

end














