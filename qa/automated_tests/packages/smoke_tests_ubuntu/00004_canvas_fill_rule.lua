
test_description = "Create a default fill, a winding fill and a even_odd fill"
test_group = "smoke"
test_area = "canvas"
test_api = "fill_rule"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)
	test_image:move_to (screen.w/6 - 80, screen.h/4 + 50 )
	test_image:text_path ("DejaVu 30px","BASIC FILL")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (screen.w/6 - 50, screen.h/4)
	test_image:line_to (50, -100, true)
	test_image:line_to (50, 100, true)
	test_image:line_to (-100, -50, true)
	test_image:line_to (100, 0, true)
	test_image:line_to (-100, 50, true)
	test_image:set_source_color ("FF0000")
	test_image:fill()
	
	test_image:move_to (screen.w/6 * 3 - 80, screen.h/4 + 50 )
	test_image:text_path ("DejaVu 30px","EVEN_ODD")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (screen.w/6 * 3 - 50, screen.h/4)
	test_image:line_to (50, -100, true)
	test_image:line_to (50, 100, true)
	test_image:line_to (-100, -50, true)
	test_image:line_to (100, 0, true)
	test_image:line_to (-100, 50, true)
	test_image.fill_rule = "EVEN_ODD"
	test_image:set_source_color ("FF0000")
	test_image:fill()
	
	test_image:move_to (screen.w/6 * 5 - 70, screen.h/4 + 50 )
	test_image:text_path ("DejaVu 30px","WINDING")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (screen.w/6 * 5 - 50, screen.h/4)
	test_image:line_to (50, -100, true)
	test_image:line_to (50, 100, true)
	test_image:line_to (-100, -50, true)
	test_image:line_to (100, 0, true)
	test_image:line_to (-100, 50, true)
	test_image.fill_rule = "WINDING"
	test_image:set_source_color ("FF0000")
	test_image:fill()
	
	return test_image:Image ()
	
	
end















