
test_description = "Lower an item in the container"
test_group = "smoke"
test_area = "path"
test_api = ""


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
	
	test_image:arc(screen.w/3 + 128, screen.h/2 + 128 , 20, 0, 360)
	test_image:fill()
	test_image:set_source_color("00FF00")


	--local path = Path ("M 153,334, C 153,334 151,334 151,334  C 151,339 153,344, 156,344 C 164,344 171,339 171,334") --[[ C 171, 322, 164, 314, 156, 314, C 142, 314, 131, 322, 131, 334, C 131, 350, 142, 364, 156, 364, C 175, 364, 191, 350, 191, 334, C 191, 311, 175, 294, 156, 294, C 131, 294, 111, 311, 111, 334, C 111, 361, 131, 384, 156, 384, C 186, 384, 211, 361, 211, 334, C 211, 300, 186, 274, 156, 274") --]]

	--local path = Path( "M 0,980 C 0,0 1820,0 1820,980" )

	d

local timeline = Timeline
	{
	    duration = 2000,
	    on_new_frame =
		function( timeline , duration , progress )
		    if progress < 1.0 then
		    	test_image.position = path:get_position( progress )
		    end
	end
	}

	timeline:start()

	return test_image:Image ()
end











