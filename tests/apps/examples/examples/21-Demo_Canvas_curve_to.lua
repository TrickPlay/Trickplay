        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "FFFFFFff" )
        canvas.line_width = 10

		-- Draw a simple Bezier curve
		canvas:move_to( 400, 400 )
		canvas:curve_to( 500, 500, 600, 200, 700, 300 )
		canvas:stroke()
		
		-- Draw the control lines used in the curve
		canvas:set_source_color( "707070ff" )
		canvas.line_width = 5
		
		-- Draw first control line
		canvas:move_to( 400, 400 )
		canvas:line_to( 500, 500 )
		canvas:stroke()
		
		-- Draw second control line
		canvas:move_to( 600, 200 )
		canvas:line_to( 700, 300 )
		canvas:stroke()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

