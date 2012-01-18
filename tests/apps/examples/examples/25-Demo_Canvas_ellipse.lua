        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        
        -- Be a good programming citizen
        canvas:save()
        
		-- Shift the center of the screen to coordinates 0, 0
        canvas:translate( canvas.width / 2, canvas.height / 2 )
        
        -- Create a circle in the center of the screen, i.e., translated coordinates 0,0.
        -- This circle will contain all the ellipses.
        canvas:arc( 0, 0, 300, 0, 360 )
        canvas.line_width = 3
        canvas:set_source_color( "d0d0d0FF" )
        canvas:stroke()
               
        -- Draw 36 ellipses in our circle
        for i = 1, 36, 1 do
        	-- Rotate drawing surface 10 degrees for each ellipse
        	canvas:rotate( 10 )
        	
        	-- Create the circle/ellipse
        	-- Note: We perform the scaling for each circle because we don't want
        	-- the scaling factor to affect the rotate operation.
        	canvas:save()
        	canvas:scale( .3, 1 )
        	canvas:arc( 0, 0, 300, 0, 360 )
        	canvas:restore()
        	
        	-- Draw the ellipse
        	canvas:stroke()
        end
        		
		-- Restore original drawing context
		canvas:restore()
		
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

