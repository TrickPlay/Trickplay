
test_description = "Set the miter_limit on a miter line_join so that it converts to a bevel"
test_group = "smoke"
test_area = "canvas"
test_api = "miter_limit"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)
	 -- Text description
	test_image:move_to (screen.w/5 - 100,screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","Miter: Miter_limit = 1")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	-- Draw graphic
	test_image:move_to (screen.w/5 + 100, screen.h/5)
	test_image:line_to (-150, 150, true)
	test_image:line_to (150, 150, true)
	test_image:set_source_color ("000000")
	test_image.line_join = "MITER"
	test_image.line_width = 75
	test_image.miter_limit = 10
	test_image:stroke()
	
		 -- Text description
	test_image:move_to (screen.w/5 * 3 - 100,screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","Bevel: Miter_limit = 0")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	-- Draw graphic
	test_image:move_to (screen.w/5 * 3+ 100, screen.h/5)
	test_image:line_to (-150, 150, true)
	test_image:line_to (150, 150, true)
	test_image:set_source_color ("000000")
	test_image.line_join = "MITER"
	test_image.line_width = 75
	test_image.miter_limit = 0
	test_image:stroke()
	return test_image:Image ()
end











