        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )
        canvas:set_source_color( "ffffffff" )
        canvas.line_width = 10
        
        -- Draw a star with intersecting lines
        canvas:move_to( 100, 170 )
        canvas:line_to( 300, 170 )
        canvas:line_to( 100, 300 )
        canvas:line_to( 200, 100 )
        canvas:line_to( 300, 300 )
        canvas:close_path()
        
        -- Draw the lines, saving the path
        canvas:stroke( true )
        
        -- Set the fill rule
        canvas.fill_rule = "WINDING"
        
        -- Fill the shape, using a fill color
        canvas:set_source_color( "ff0000ff" )
        canvas:fill()
        
        -- Draw the same shape in another location
        canvas:move_to( 400, 170 )
        canvas:line_to( 600, 170 )
        canvas:line_to( 400, 300 )
        canvas:line_to( 500, 100 )
        canvas:line_to( 600, 300 )
        canvas:close_path()
        
        -- Draw the lines, saving the path
        canvas:set_source_color( "ffffffff" )
        canvas:stroke( true )
        
        -- Set the fill rule
        canvas.fill_rule = "EVEN_ODD"
        
        -- Fill the shape, using a fill color
        canvas:set_source_color( "ff0000ff" )
        canvas:fill()
        
        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()

