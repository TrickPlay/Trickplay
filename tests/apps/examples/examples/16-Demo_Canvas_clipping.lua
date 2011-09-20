        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        
        -- Paint the canvas with a solid gray color
        canvas:set_source_color( "808080FF" )
        canvas:paint()

        -- Save the current drawing context state with no clipping
        canvas:save()
        
		-- Create a rectangle that will be the clipping region
		canvas:rectangle( 300, 300, 600, 400 )
		
		-- Clip everything outside the rectangle's boundary
		canvas:clip()

		-- Define a vertical gradient pattern line from screen's top to bottom
		canvas:set_source_linear_pattern( 0, 0, 0, 1080 )
		
		-- Define 2 gradient color-stops from red to black
		canvas:add_source_pattern_color_stop( 0.0, "FF0000FF" )   -- TOP,    From red...
		canvas:add_source_pattern_color_stop( 1.0, "000000FF" )   -- BOTTOM, ...to black
	
		-- Paint the canvas with the gradient pattern
		-- Note: Only the portion that lies within our clipping region will actually be painted
		canvas:paint()

        -- Restore original drawing context with no clipping
        canvas:restore()       

        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

