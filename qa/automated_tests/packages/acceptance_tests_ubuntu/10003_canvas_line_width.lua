
test_description = "Create lines with various line widths"
test_group = "smoke"
test_area = "canvas"
test_api = "line_width"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	test_image:set_source_color ("FF0000")
	test_image:move_to (80, screen.h/8 - 25)
	test_image:text_path ("DejaVu 30px","0 px: ")
	test_image:fill()
	test_image:move_to (200, screen.h/8)
	test_image:line_to (screen.w - 200, screen.h/8)
	test_image.line_width = 0
	test_image:set_source_color ("000000")
	test_image:stroke()
	
	test_image:set_source_color ("FF0000")
	test_image:move_to (80, screen.h/8 * 2 - 25)
	test_image:text_path ("DejaVu 30px","1 px: ")
	test_image:fill()
	test_image:set_source_color ("000000")
	test_image:move_to (200, screen.h/8 * 2)
	test_image:line_to (screen.w - 200, screen.h/8 * 2)
	test_image.line_width = 1
	test_image:stroke()
	
	test_image:set_source_color ("FF0000")
	test_image:move_to (80, screen.h/8 * 3 - 25)
	test_image:text_path ("DejaVu 30px","-1 px: ")
	test_image:fill()
	test_image:set_source_color ("000000")
	test_image:move_to (200, screen.h/8 * 3)
	test_image:line_to (screen.w - 200, screen.h/8 * 3)
	test_image.line_width = -1
	test_image:stroke()
	
	test_image:set_source_color ("FF0000")
	test_image:move_to (80, screen.h/8 * 4 - 25)
	test_image:text_path ("DejaVu 30px","-16 px: ")
	test_image:fill()
	test_image:set_source_color ("000000")
	test_image:move_to (200, screen.h/8 * 4)
	test_image:line_to (screen.w - 200, screen.h/8 * 4)
	test_image.line_width = -16
	test_image:stroke()
	
	test_image:set_source_color ("FF0000")
	test_image:move_to (80, screen.h/8 * 6 - 25)
	test_image:text_path ("DejaVu 30px","512 px: ")
	test_image:fill()
	test_image:set_source_color ("000000")
	test_image:move_to (200, screen.h/8 * 7)
	test_image:line_to (screen.w - 200, screen.h/8 * 7)
	test_image.line_width = 256
	test_image:stroke()
	--
	--test_image:set_source_color ("FF0000")
	--test_image:move_to (80, screen.h/8 * 6 - 25)
	--test_image:text_path ("DejaVu 30px","64 px: ")
	--test_image:fill()
	--test_image:set_source_color ("000000")
	--test_image:move_to (200, screen.h/8 * 6)
	--test_image:line_to (screen.w - 200, screen.h/8 * 6)
	--test_image.line_width = 64
	--test_image:stroke()
	--
	--test_image:set_source_color ("FF0000")
	--test_image:move_to (80, screen.h/8 * 7 - 25)
	--test_image:text_path ("DejaVu 30px","128 px: ")
	--test_image:fill()
	--test_image:set_source_color ("000000")
	--test_image:move_to (200, screen.h/8 * 7)
	--test_image:line_to (screen.w - 200, screen.h/8 * 7)
	--test_image.line_width = 128
	--test_image:stroke()
	--       
	
	return test_image:Image ()
	
	
	
end











