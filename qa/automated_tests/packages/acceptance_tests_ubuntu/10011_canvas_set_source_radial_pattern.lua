
test_description = "Render a bunch of radial patterns"
test_group = "smoke"
test_area = "canvas"
test_api = "set_source_radial_pattern"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:set_source_linear_pattern (0, 100, 0, screen.h)
	test_image:add_source_pattern_color_stop (1, "000000")
	test_image:add_source_pattern_color_stop (0, "FFFFFF")
	test_image:rectangle (0, 100, screen.w, screen.h)
	test_image:fill ()

--test_image:translate (screen.w/2 - 200, screen.h/2 - 200)
        for i = 1, 8 do
            test_image:set_source_radial_pattern ( i * 190, i * i * 14, 30, i * 195, i * 195, i * 30)
            test_image:add_source_pattern_color_stop (1, i..i.."0000")
            test_image:add_source_pattern_color_stop (0, i..i.."FFFF")
            test_image:arc (i * 200, i * i * 13 + 80, i * 20, 0, 360)
            test_image:fill()
        end

	return test_image:Image ()
end















