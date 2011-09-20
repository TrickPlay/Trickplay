        -- Function to create a new filled rectangle at drawing surface origin.
        -- Arguments are a Canvas object and an RGB/alpha color specification
        function new_rectangle( canvas, color )

        	-- Create rectangle at (0, 0)
        	canvas:rectangle( 0, 0, 50, 50 )
        	canvas:set_source_color( color )
        	canvas:fill()
        end
        
        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        
		-- Create blue rectangle
		new_rectangle( canvas, "0000ffFF" )
		
		-- Be a good code neighbor and save the current drawing context
		canvas:save()
		
		-- Translate origin to 100, 100, rotate surface 30 degrees, and create red rectangle
		canvas:translate( 100, 100 )
		canvas:rotate( 30 )
		new_rectangle( canvas, "ff0000FF" )
		
		-- Translate origin to 400, 400, rotate surface an additional 30 degrees, and create green rectangle
		canvas:translate( 400, 400 )
		canvas:rotate( 30 )
		new_rectangle( canvas, "00ff00FF" )
		
		-- Translate origin to -100, -100, rotate surface 45 degrees, and create gray rectangle
		canvas:translate( -100, -100 )
		canvas:rotate( 45 )
		new_rectangle( canvas, "d0d0d0FF" )
		
		-- Restore original drawing context
		canvas:restore()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

