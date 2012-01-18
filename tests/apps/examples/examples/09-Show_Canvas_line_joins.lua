        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "#ffffffff" )
        
        -- Set a large line_width
        canvas.line_width = 75
        
		-- Draw a rectangle using the BEVEL line_join
		canvas.line_join = "BEVEL"
		canvas:rectangle( 100, 100, 200, 200 )
		canvas:stroke()
		
        -- Draw a rectangle using the MITER line_join
        canvas.line_join = "MITER"
        canvas:rectangle( 400, 100, 200, 200 )
        canvas:stroke()

		-- Draw a rectangle using the ROUND line_join
		canvas.line_join = "ROUND"
		canvas:rectangle( 700, 100, 200, 200 )
		canvas:stroke()
		
		-- Show the rectangles
		image = canvas:Image()
		screen:add( image )
		screen:show()

