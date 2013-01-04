
test_description = "Rotate the text beyond 360 degrees"
test_group = "acceptance"
test_area = "canvas"
test_api = "rotate"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)
	test_image:set_source_color ("CC0099")
	test_image:move_to (screen.w/2, screen.h/2)
	test_image:rotate (540)
	test_image:text_path ("DejaVu Sans 30px","<b>This text is upside down</b>")
	test_image:fill()

	return test_image:Image ()

end














