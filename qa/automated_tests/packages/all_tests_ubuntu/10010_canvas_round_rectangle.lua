
test_description = "Render a multiple round rectangles with different line_widths and sizes"
test_group = "smoke"
test_area = "canvas"
test_api = "round_rectangle"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	for i = 1, 10 do
            test_image:round_rectangle (i * i * 20, i * 80, i * 50, i * 50, i * 10)
            test_image:set_source_color ("7878FF")
            test_image:fill(true)
            test_image:set_source_color ("FF0000AA")
            test_image.line_width = i * 5
            test_image:stroke()
        end
	return test_image:Image ()
end















