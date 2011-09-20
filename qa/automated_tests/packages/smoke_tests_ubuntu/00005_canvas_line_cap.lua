
test_description = "Create a line with the various line_cap values"
test_group = "smoke"
test_area = "canvas"
test_api = "line_cap"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:move_to (200, screen.h/5)
	test_image:text_path ("DejaVu 30px","DEFAULT")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, screen.h/5 - 50)
	test_image:line_to (screen.w - 200, screen.h/5 - 50)
	test_image.line_width = 50
	test_image:set_source_color ("000000")
	test_image:stroke()
	
	test_image:move_to (200, screen.h/5 * 2)
	test_image:text_path ("DejaVu 30px","ROUND")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, screen.h/5 * 2 - 50)
	test_image:line_to (screen.w - 200, screen.h/5 * 2 - 50)
	test_image.line_width = 50
	test_image.line_cap = "ROUND"
	test_image:set_source_color ("000000")
	test_image:stroke()
	
	test_image:move_to (200, screen.h/5 * 3)
	test_image:text_path ("DejaVu 30px","SQUARE")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, screen.h/5 * 3 - 50)
	test_image:line_to (screen.w - 200, screen.h/5 * 3 - 50)
	test_image.line_width = 50
	test_image.line_cap = "SQUARE"
	test_image:set_source_color ("000000")
	test_image:stroke()
	
	test_image:move_to (200, screen.h/5 * 4)
	test_image:text_path ("DejaVu 30px","BUTT")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, screen.h/5 * 4 - 50)
	test_image:line_to (screen.w - 200, screen.h/5 * 4 - 50)
	test_image.line_width = 50
	test_image.line_cap = "BUTT"
	test_image:set_source_color ("000000")
	test_image:stroke()
	--[[
	test_image:move_to (200,500)
	test_image:text_path ("DejaVu 30px","SQUARE line_cap")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, 450)
	test_image:line_to (screen.w - 200, 450)
	test_image.line_width = 50
	test_image.line_cap = "SQUARE"
	test_image:set_source_color ("000000")
	test_image:stroke()
	
	test_image:move_to (200,650)
	test_image:text_path ("DejaVu 30px","ROUND line_cap")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, 600)
	test_image:line_to (screen.w - 200, 600)
	test_image.line_width = 50
	test_image.line_cap = "ROUND"
	test_image:set_source_color ("000000")
	test_image:stroke()
	
	test_image:move_to (200,800)
	test_image:text_path ("DejaVu 30px","BUTT line_cap")
	test_image:set_source_color ("FF0000")
	test_image:fill()
	test_image:move_to (170, 750)
	test_image:line_to (screen.w - 200, 750)
	test_image.line_width = 50
	test_image.line_cap = "BUTT"
	test_image:set_source_color ("000000")
	test_image:stroke()
--]]
	return test_image:Image ()

end















