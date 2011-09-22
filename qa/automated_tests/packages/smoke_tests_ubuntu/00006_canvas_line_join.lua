
test_description = "Create a line with the various line_join values"
test_group = "smoke"
test_area = "canvas"
test_api = "line_join"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)
	-- Text description
	test_image:move_to (screen.w/5 - 200,screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","DEFAULT")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	-- Draw graphic
	test_image:move_to (screen.w/5 - 50, screen.h/5)
	test_image:line_to (-150, 150, true)
	test_image:line_to (150, 150, true)
	test_image:set_source_color ("000000")
	test_image.line_width = 75
	test_image:stroke()
	
		-- Text description
	test_image:move_to (screen.w/5 * 2 - 100,screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","ROUND")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	-- Draw graphic
	test_image:move_to (screen.w/5 * 2, screen.h/5)
	test_image:line_to (-150, 150, true)
	test_image:line_to (150, 150, true)
	test_image.line_join = "ROUND"
	test_image:set_source_color ("000000")
	test_image.line_width = 75
	test_image:stroke()
	
		-- Text description
	test_image:move_to (screen.w/5 * 3 - 100,screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","BEVEL")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	-- Draw graphic
	test_image:move_to (screen.w/5 * 3, screen.h/5)
	test_image:line_to (-150, 150, true)
	test_image:line_to (150, 150, true)
	test_image.line_join = "BEVEL"
	test_image:set_source_color ("000000")
	test_image.line_width = 75
	test_image:stroke()

		-- Text description
	test_image:move_to (screen.w/5 * 4 - 100,screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","MITER")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	-- Draw graphic
	test_image:move_to (screen.w/5 * 4, screen.h/5)
	test_image:line_to (-150, 150, true)
	test_image:line_to (150, 150, true)
	test_image.line_join = "MITER"
	test_image:set_source_color ("000000")
	test_image.line_width = 75
	test_image:stroke()


	return test_image:Image ()

end















