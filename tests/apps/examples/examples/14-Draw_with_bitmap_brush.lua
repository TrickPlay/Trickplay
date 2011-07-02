		-- Create a Canvas object on which to create our gradient pattern
        canvas = Canvas( 1920, 1080 )
        
		-- Define a vertical gradient pattern line from rectangle's top to bottom
		canvas:set_source_linear_pattern( 960, 0, 960, 1080 )
		
		-- Define 3 gradient color-stops from black to red and back to black
		canvas:add_source_pattern_color_stop( 0.0, "0000FFFF" )   -- TOP,    From blue/opaque to...
		canvas:add_source_pattern_color_stop( 0.5, "FF0000FF" )   -- CENTER, ...red/opaque to...
		canvas:add_source_pattern_color_stop( 1.0, "00FF00FF" )   -- BOTTOM, ...green/opaque

		-- Create a rectangle that covers the entire Canvas
		canvas:rectangle( 0, 0, 1920, 1080 )
		
		-- Fill the rectangle with our linear gradient pattern
		canvas:fill()
		
		-- Convert gradient to Bitmap
		gradientBrush = canvas:Bitmap()
		
		-- Create our screen Canvas
		canvas = Canvas( 1920, 1080 )
		
		-- Define a table of x,y coordinate around the canvas
		points = { 900, 100,
                   1200, 200,
                   1500, 400,
                   1800, 600,
                   1600, 800,
                   1100, 900,
                   700, 1000,
                   300, 700,
                   100, 500,
                   500, 300 }
                   
		-- Create a path of lines that connect all the x,y coordinate points
		for one_point = 1, #points, 2 do
			for all_points = 1, #points, 2 do
				-- Connect this point to all the other points
				canvas:move_to( points[ one_point ], points[ one_point + 1 ] )
				canvas:line_to( points[ all_points ], points[ all_points + 1 ] )
			end
		end
		
		-- Set the line width
		canvas.line_width = 10
		
		-- Assign our gradientBrush bitmap as the drawing source
		canvas:set_source_bitmap( gradientBrush )
		
		-- Draw all the lines
		canvas:stroke()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()       

