        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas.line_width = 5
        
		-- Create a rectangle and draw gray outline around it
		canvas:rectangle( 100, 100, 600, 600 )
		canvas:set_source_color( "d0d0d0ff" )
		canvas:stroke( true )   -- save the rectangle for subsequent fill()
		
		-- Define a radial gradient pattern using two circles. Both circles share the same
		-- center, but the start circle has a smaller radius than the end, thereby
		-- creating a symmetrical donut shape.
		canvas:set_source_radial_pattern( 400, 400, 50, 400, 400, 300 )
		
		-- Define 3 gradient color-stops from black to red and back to black
		canvas:add_source_pattern_color_stop( 0.0, "00000000" )   -- START,  From black/transparent to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00000000" )   -- END,    ...black/transparent

		-- Fill the rectangle with our radial gradient pattern
		canvas:fill()
		
		-- Draw the two circles used for the radial gradient
		canvas:set_dash( 0, { 16.0, 4.0 } )
		canvas:set_source_color( "00ff00ff" )  -- green start circle

		canvas:arc( 400, 400, 50, 0, 360 )
		canvas:stroke()
		
		canvas:set_source_color( "0000ffff" )  -- blue end circle
		canvas:arc( 400, 400, 300, 0, 360 )
		canvas:stroke()
		canvas:clear_dash() -- return to a solid line
		
		-- Create a second rectangle
		canvas:rectangle( 800, 100, 600, 600 )
		canvas:set_source_color( "d0d0d0ff" )
		canvas:stroke( true )   -- save the rectangle for subsequent fill()

		-- Define a second radial gradient pattern. This time the smaller start circle
		-- is located to the left of the outer end circle's center, which results in an
		-- asymmetrical radial pattern.
		-- Note: Both radial patterns use the same color-stop values.
		canvas:set_source_radial_pattern( 950, 400, 50, 1100, 400, 300 )
		canvas:add_source_pattern_color_stop( 0.0, "00000000" )   -- START,  From black/transparent to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00000000" )   -- END,    ...black/transparent
		canvas:fill()

		-- Draw the two circles used for the radial gradient
		canvas:set_dash( 0, { 16.0, 4.0 } )
		canvas:set_source_color( "00ff00ff" )  -- green start circle
		canvas:arc( 950, 400, 50, 0, 360 )
		canvas:stroke()
		
		canvas:set_source_color( "0000ffff" )  -- blue end circle
		canvas:arc( 1100, 400, 300, 0, 360 )
		canvas:stroke()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()       

