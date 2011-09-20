
test_description = "Lower an item in the container"
test_group = "smoke"
test_area = "path"
test_api = ""


function generate_test_image ()

	local g = Group ()

	local rectangle = Rectangle
	{
	    color = "FF0000" ,
	    size = { 100 , 100 },
	    position = { 0 , 980 }
	}

	--local path = Path( "M 0,980 C 0,0 1820,0 1820,980" )

	local path:curve_to

	local timeline = Timeline
	{
	    duration = 2000,
	    on_new_frame =
		function( timeline , duration , progress )
		    if progress < 0.5 then
		    	rectangle.position = path:get_position( progress )
		    end
	end
	}

	timeline:start()

	g:add( rectangle )

	return g
end











