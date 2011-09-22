
test_description = "Create a donut design using arc"
test_group = "smoke"
test_area = "canvas"
test_api = "arc"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)

	test_image.line_width = 1.0
	
	test_image:translate (screen.w/2, screen.h/2)
	test_image:arc(0,0,400,0,360)
	test_image:stroke()

	for i=1, 36 do
		test_image:save()
		test_image:rotate(i * 180/36)
		test_image:scale(0.3, 1)
		test_image:arc(0, 0, 400, 0, 360)
		test_image:restore()
		test_image:stroke()
	end


	return test_image:Image ()
end















