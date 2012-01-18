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
		
		-- Translate origin to 100, 100, scale to 2:2, and create red rectangle
		canvas:translate( 100, 100 )
		canvas:scale( 2, 2 )
		new_rectangle( canvas, "ff0000FF" )
		
		-- Translate origin to 200, 200, scale to 2:1, and create green rectangle
		-- Note: The X, Y arguments to translate() are also scaled according to 
		-- any scaling factor in the current transformation matrix. Thus, with a 
		-- current scaling facter of 2:2, X,Y coordinates of 200, 200 will actually
		-- scale to be 400, 400.
		canvas:translate( 200, 200 )
		canvas:scale( 2, 1 )
		new_rectangle( canvas, "00ff00FF" )
		
		-- Translate origin to -100, -100, scale to 3:1, and create gray rectangle
		canvas:translate( -100, -100 )
		canvas:scale( 3, 1 )
		new_rectangle( canvas, "d0d0d0FF" )
		
		-- Restore original drawing context
		canvas:restore()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

