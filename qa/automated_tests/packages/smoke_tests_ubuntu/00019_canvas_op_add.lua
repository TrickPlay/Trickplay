
test_description = "OP = add"
test_group = "smoke"
test_area = "canvas"
test_api = "op = ADD"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)


	-- add
	test_image:rectangle (screen.w/2 - 200, screen.h/4, 600, 400)
	test_image:set_source_color({255, 51, 102, 190})
	test_image:fill()
	
	test_image.op = "ADD"
	test_image:rectangle (screen.w/2 - 200 + 100, screen.h/4 + 100, 600, 400)
	test_image:set_source_color({0, 0, 230, 95})
	test_image:fill()
	

--]]
	return test_image:Image ()

end















