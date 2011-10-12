
test_description = "OP = DEST leaves 1st object intact and discards 2nd."
test_group = "smoke"
test_area = "canvas"
test_api = "op = DEST"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)


	-- DEST
	test_image:rectangle (screen.w/2 - 200, screen.h/4, 600, 400)
	test_image:set_source_color({255, 51, 102, 190})
	test_image:fill()
	
	test_image.op = "DEST"
	test_image:rectangle (screen.w/2 - 200 + 100, screen.h/4 + 100, 600, 400)
	test_image:set_source_color({0, 0, 230, 95})
	test_image:fill()
	

--]]
	return test_image:Image ()

end















