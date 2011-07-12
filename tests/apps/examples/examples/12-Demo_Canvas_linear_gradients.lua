        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas.line_width = 10
        
		-- Create a rectangle and draw gray outline around it
		canvas:rectangle( 100, 100, 300, 600 )
		canvas:set_source_color( "d0d0d0ff" )
		canvas:stroke( true )   -- save the rectangle for subsequent fill()
		
		-- Define a vertical gradient pattern line from rectangle's top to bottom
		canvas:set_source_linear_pattern( 0, 100, 0, 700 )
		
		-- Define 3 gradient color-stops from black to red and back to black
		canvas:add_source_pattern_color_stop( 0.0, "00000000" )   -- TOP,    From black/transparent to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00000000" )   -- BOTTOM, ...black/transparent

		-- Fill the rectangle with our linear gradient pattern
		canvas:fill()
		
		-- Create a second rectangle
		canvas:rectangle( 500, 100, 300, 600 )
		canvas:set_source_color( "d0d0d0ff" )
		canvas:stroke( true )   -- save the rectangle for subsequent fill()

		-- Define a horizontal gradient pattern line from rectangle's left to right
		-- Note: We use the same color-stop values
		canvas:set_source_linear_pattern( 500, 0, 800, 0 )
		canvas:add_source_pattern_color_stop( 0.0, "00000000" )   -- LEFT,   From black/transparent to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00000000" )   -- RIGHT,  ...black/transparent
		canvas:fill()

        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()       

