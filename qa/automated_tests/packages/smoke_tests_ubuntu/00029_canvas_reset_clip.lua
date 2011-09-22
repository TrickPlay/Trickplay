
test_description = "Set a clip and then remove it."
test_group = "smoke"
test_area = "canvas"
test_api = "reset_clip"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:arc(screen.w/3 + 128, screen.h/2 + 128 , 76.8, 0, 360)

	test_image:clip()
	test_image:new_path()
	test_image:rectangle(screen.w/3, screen.h/2, 256, 256)
	test_image:fill()
	test_image:set_source_color("00FF00")
	test_image:move_to(screen.w/3, screen.h/2)
	test_image:line_to(screen.w/3 + 256, screen.h/2 + 256)
	test_image:move_to(screen.w/3 + 256, screen.h/2)
	test_image:line_to (screen.w/3, screen.h/2 + 256)
	test_image.line_width = 10 
	test_image:reset_clip()
	test_image:stroke()

	
--[[
	test_image:arc (256, 256, 76.8, 0, 360)
	test_image:clip()
	test_image:new_path()
	local bmp = Bitmap ("assets/medium_640x420_panda.jpg")
	local bw = bmp.w
	local bh = bmp.h
	test_image:scale (256/bw, 256/bh)
	test_image:set_source_bitmap(bmp, 256, 256)
	test_image:paint()
	--]]
	return test_image:Image ()
end















