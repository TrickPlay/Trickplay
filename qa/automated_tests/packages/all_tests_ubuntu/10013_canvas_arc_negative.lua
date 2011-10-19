
test_description = "Create a bunch of negative-arcs with increasing line_width and lengths."
test_group = "acceptance"
test_area = "canvas"
test_api = "arc_negative"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)

	
	
	test_image:translate (screen.w/2 - 400, screen.h/2 - 200)

        local i = 360
	while i > 0  do
		test_image:save()
                test_image:set_source_color ("000000")
                test_image:arc_negative (250,250 ,i , i, 0)
		test_image:restore()
                test_image.line_width = i/60
		test_image:stroke()
                test_image:fill()
                i = i - 60
	end


	return test_image:Image ()
end













