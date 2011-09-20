
test_description = "Render various linear pattern rectangle with different color stops"
test_group = "acceptance"
test_area = "canvas"
test_api = "set_source_linear_pattern"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	for i = 1, 9 do
            test_image:set_source_linear_pattern (0,  i * 110, screen.w, i * 100)
            test_image:add_source_pattern_color_stop (i * 0.1, "0"..(i*2).."0"..(i*1).."0"..(i*1))
            test_image:add_source_pattern_color_stop (0, "FFFFFF")
            test_image:rectangle (0, i * 100 , screen.w, i * 100)
            test_image:fill ()
        end

	return test_image:Image ()
end















