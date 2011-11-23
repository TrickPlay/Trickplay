
test_description = "Display a bunch of gradients"
test_group = "smoke"
test_area = "canvas"
test_api = "set_source_linear_pattern"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	

-- 9 red vertical lines
	test_image:set_source_linear_pattern (50, 0, screen.w - 100, 200)

	local count = 1
	for j = 0.05, 1.0, 0.05 do
		if count % 2 == 1 then
			test_image:add_source_pattern_color_stop (j, "000000")
		else
			test_image:add_source_pattern_color_stop (j, "FF0000")
		end
		count = count + 1
	end

	test_image:rectangle (50, 150, screen.w - 100, 200)
	
	test_image:fill()

-- 19 blue vertical lines

	test_image:set_source_linear_pattern (0, 0, screen.w, 0)


	local count = 1
	local i = 0.05
	while i < 1.0 do
		if count % 2 == 1 then
			test_image:add_source_pattern_color_stop (i, "000000")
		else
			test_image:add_source_pattern_color_stop (i, "0000FF")
		end
		i = i + 0.025
		count = count + 1
	end

	test_image:rectangle (50, 450, screen.w - 100, 200)
	
	test_image:fill()

-- 1 yellow horizontal line
	test_image:set_source_linear_pattern (0, 750, 0, 950)
	
	test_image:add_source_pattern_color_stop (0.1, "000000")
	test_image:add_source_pattern_color_stop (0.5, "FFFF00")
	test_image:add_source_pattern_color_stop (0.9, "000000")

	test_image:rectangle (50, 750, screen.w - 100, 200)
	
	test_image:fill()




	return test_image:Image ()
end















