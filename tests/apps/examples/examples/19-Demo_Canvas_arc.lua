        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "FFFFFFff" )
        canvas.line_width = 10

		-- Draw an arc
		-- Starting angle is 30 degrees, ending angle is 120 degrees
		canvas:arc( 500, 500, 200, 30, 120 )
		
		-- Draw the arc
		canvas:stroke()
		
		-- Create a path of the angles used in the arc
		-- First, get current point to start of arc
		canvas:arc( 500, 500, 200, 30, 30 )  -- this is where our arc begins
		canvas:line_to( 500, 500 )  -- draw line back to arc's center
		
		-- Do the same for the end of the arc
		canvas:arc( 500, 500, 200, 120, 120 )  -- now current point is where arc ends
		canvas:line_to( 500, 500 )

		-- Draw the arc's angle lines
		canvas:set_source_color( "707070ff" )
		canvas.line_width = 5
		canvas:stroke()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

