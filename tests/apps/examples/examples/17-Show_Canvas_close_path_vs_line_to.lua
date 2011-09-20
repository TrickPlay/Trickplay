        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "#ffffffff" )
        canvas.line_width = 75
        canvas.line_cap = "SQUARE"
        canvas.line_join = "MITER"
        
        -- Define a triangular path
        canvas:move_to( 400, 500 )
        canvas:line_to( 400, 100 )
        canvas:line_to( 900, 100 )
        
        -- Close with close_path() (uses current line_join setting)
        canvas:close_path()
        
        -- Draw the lines on the path
        canvas:stroke()
                
        -- Define the same triangular path
        canvas:move_to( 1100, 500 )
        canvas:line_to( 1100, 100 )
        canvas:line_to( 1600, 100 )
        
        -- This time, close with line_to() (uses current line_cap setting)
        canvas:line_to( 1100, 500 )
        
        -- Draw the path
        canvas:stroke()
        
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

