
test_description = "Create a few arc designs"
test_group = "smoke"
test_area = "canvas"
test_api = "arc"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)	
	local lesser = math.min(screen.w, screen.h)
	local xc, yc
	xc = screen.w/2
	yc = screen.h/2

	test_image.line_width = lesser * 0.02

	test_image:save()
	test_image:arc (screen.w/3, screen.h/4, lesser/4, -180/5, 180)
	test_image:close_path()
	test_image:set_source_color ("FF0000")
	test_image:fill(true)
	test_image:restore()
	test_image:stroke()

	test_image:save()
	test_image:arc(xc, yc, lesser/4, 0, 360)
	test_image:set_source_color("0000CCAA")
	test_image:fill(true)
	test_image:restore()
	test_image:stroke()
	
	local ex = xc
	local ey = 3 * screen.h /4
	local ew = 3 * screen.w /4
	local eh = screen.h / 3

	test_image:save()

	test_image:translate(ex, ey)
	test_image:scale(ew/2.0, eh/2.0)
	test_image:arc(0,0,1,0,360)
	test_image:set_source_color("B40000AA")
	test_image:fill(true)
	test_image:restore()
	test_image:stroke()


	return test_image:Image ()
end















