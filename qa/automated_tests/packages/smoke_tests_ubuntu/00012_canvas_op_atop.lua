
test_description = "OP = atop leaves first object intact and mixes 2nd object."
test_group = "smoke"
test_area = "canvas"
test_api = "op = atop"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)


	-- atop
	test_image:rectangle (screen.w/2 - 200, screen.h/4, 600, 400)
	test_image:set_source_color({255, 51, 102, 190})
	test_image:fill()
	
	test_image.op = "ATOP"
	test_image:rectangle (screen.w/2 - 200 + 100, screen.h/4 + 100, 600, 400)
	test_image:set_source_color({0, 0, 230, 95})
	test_image:fill()
	

--]]
	return test_image:Image ()

end















