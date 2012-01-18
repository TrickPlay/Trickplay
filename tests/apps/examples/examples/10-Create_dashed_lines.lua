        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "#ffffffff" )
        canvas.line_width = 10
        
		-- Define some dash patterns
		dash_regular = { 16.0, 4.0 }
		dash_dash_dash_dot = { 16.0, 4.0, 16.0 }
		dash_small = { 4.0 }

		-- Set the dash pattern
		canvas:set_dash( 0, dash_regular )
		
        -- Set a path and make a line
        canvas:move_to( 500, 100 )
        canvas:line_to( 1000, 100 )
        canvas:stroke()

		-- Make another line using a different dash pattern
		canvas:set_dash( 0, dash_dash_dash_dot )
		canvas:move_to( 500, 200 )
		canvas:line_to( 1000, 200 )
		canvas:stroke()
		
		-- Make a final line with another dash pattern
		canvas:set_dash( 0, dash_small )
		canvas:move_to( 500, 300 )
		canvas:line_to( 1000, 300 )
		canvas:stroke()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

