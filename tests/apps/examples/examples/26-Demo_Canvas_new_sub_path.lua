        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "ffffffFF" )
        canvas.line_width = 10

		-- Draw a vertical line
		canvas:move_to( 100, 100 )
		canvas:line_to( 100, 200 )
		
		-- Draw an arc; the vertical line will automatically connect to the start of the arc
		canvas:arc_negative( 150, 300, 50, 180, 360 )
		
		-- Draw everything
		canvas:stroke()
		
		-- Draw a second vertical line, similar to the first
		canvas:move_to( 300, 100 )
		canvas:line_to( 300, 200 )
		
		-- Draw an arc; this time, call new_sub_path() first so the vertical line is not connected to the arc
		canvas:new_sub_path()
		canvas:arc_negative( 350, 300, 50, 180, 360 )
		
		-- Draw everything
		canvas:stroke()

        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

