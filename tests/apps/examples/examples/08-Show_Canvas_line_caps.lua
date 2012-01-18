        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "#ffffffff" )
        
        -- Set a large line_width
        canvas.line_width = 100
        
        -- Set a path
        canvas:move_to( 500, 100 )
        canvas:line_to( 1000, 100 )

        -- Explicitly set line_cap
        canvas.line_cap = "BUTT"
        
        -- Make a line
        canvas:stroke()
        
        -- Do the same for ROUND line_cap
        canvas:move_to( 500, 300 )
        canvas:line_to( 1000, 300 )
        canvas.line_cap = "ROUND"
        canvas:stroke()
        
        -- Once more for SQUARE
        canvas:move_to( 500, 500 )
        canvas:line_to( 1000, 500 )
        canvas.line_cap = "SQUARE"
        canvas:stroke()
        
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

