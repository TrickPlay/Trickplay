
test_description = "Render a round rectangle"
test_group = "smoke"
test_area = "canvas"
test_api = "round_rectangle"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:round_rectangle (screen.w/2 - 230, screen.h/2 - 300, 600, 400, 100)
	test_image:set_source_color ("7878FF")
	test_image:fill(true)
	test_image:set_source_color ("FF0000AA")
	test_image.line_width = 10
	test_image:stroke()

	return test_image:Image ()
end















