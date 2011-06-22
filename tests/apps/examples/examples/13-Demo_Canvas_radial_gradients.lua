        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas.line_width = 5
        
		-- Create a rectangle and draw dashed, gray outline around it
		canvas:rectangle( 100, 100, 600, 600 )
		canvas:set_source_color( "d0d0d0ff" )
		canvas:set_dash( 0, { 16.0, 4.0 } )
		canvas:stroke( true )   -- save the rectangle for subsequent fill()
		
		-- Define a vertical gradient pattern line from rectangle's top to bottom
		-- The two vertical circles touch each other in the center of the rectangle
		canvas:set_source_radial_pattern( 400, 400, 50, 400, 400, 300 )
		
		-- Define 3 gradient color-stops from black to red and back to black
		canvas:add_source_pattern_color_stop( 0.0, "00000000" )   -- TOP,    From black/transparent to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00000000" )   -- BOTTOM, ...black/transparent

		-- Fill the rectangle with our linear gradient pattern
		canvas:fill()
		
		-- Draw the two circles used for the radial gradient
		canvas:set_source_color( "00ff00ff" )

		canvas:arc( 400, 400, 50, 0, 360 )
		canvas:stroke()
		
		canvas:set_source_color( "0000ffff" )
		canvas:arc( 400, 400, 300, 0, 360 )
		canvas:stroke()
		
		-- Create a second rectangle
		canvas:rectangle( 800, 100, 600, 600 )
		canvas:set_source_color( "d0d0d0ff" )
		canvas:stroke( true )   -- save the rectangle for subsequent fill()

		-- Define a horizontal gradient pattern line from rectangle's left to right
		-- The two horizontal circles touch each other in the center of the rectangle
		-- Note: We use the same color-stop values
		canvas:set_source_radial_pattern( 950, 400, 50, 1100, 400, 300 )
		canvas:add_source_pattern_color_stop( 0.0, "00000000" )   -- LEFT,   From black/transparent to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00000000" )   -- RIGHT,  ...black/transparent
		canvas:fill()

		-- Draw the two circles used for the radial gradient
		canvas:set_source_color( "00ff00ff" )
		canvas:arc( 950, 400, 50, 0, 360 )
		canvas:stroke()
		
		canvas:set_source_color( "0000ffff" )
		canvas:arc( 1100, 400, 300, 0, 360 )
		canvas:stroke()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()       

