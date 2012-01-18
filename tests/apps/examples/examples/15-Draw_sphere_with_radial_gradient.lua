        -- Create a Canvas object
        canvas = Canvas( 1920, 1080 )

		-- Draw a sphere with a radial gradient
		canvas:scale( 3.0, 3.0 )
		canvas:set_source_radial_pattern( 115.2, 102.4, 25.6, 102.4, 102.4, 128.0 )
		canvas:add_source_pattern_color_stop( 0.0, "FFFFFFFF" )
		canvas:add_source_pattern_color_stop( 1.0, "000000FF" )
		canvas:arc( 128.0, 128.0, 76.8, 0, 360 )
		canvas:fill()

        -- Convert Canvas to Image for display and show onscreen
        image = canvas:Image()
        screen:add( image)
        screen:show()       

