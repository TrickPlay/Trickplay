        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "#D00000ff" )

		-- To draw a circle, define the starting and ending degrees to 0 and 360
		canvas:arc( 500, 500, 200, 0, 360 )
		
		-- Fill the circle
		canvas:fill()

        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

