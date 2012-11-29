-- Create the Rectangle to animate
movingRect = Rectangle( { position = { -100, 400 },
                          size     = { 100, 100 },
                          color    = { 225, 225, 0, 255 },
} )
screen:add( movingRect )

-- Animate the Rectangle using a Timeline
movingRect_tl = Timeline( { duration = 5000,  	-- 5 seconds
						    loop     = true,    -- loop forever
} )

-- Define and register an on_marker_reached event handler
function onMarkerReachedHandler( timeline, name, duration )
	-- Print an informational message
	print( "In on_marker_reached(): Name = ", name, ", time = ", msecs )
end
movingRect_tl:add_onmarkerreached_listener( onMarkerReachedHandler )

-- Define and register an on_new_frame event handler
function onNewFrameHandler( timeline, duration, progress )
	-- X changes from -100 to 2020
	movingRect.x = -100 + (2120 * progress)
	-- X rotation changes from 0 to 360
	movingRect.x_rotation = { 360 * progress, 0, 0 }
end
movingRect_tl:add_onnewframe_listener( onNewFrameHandler )

-- Define Timeline markers at one-second intervals
movingRect_tl:add_marker( "Marker1000", 1000 )
movingRect_tl:add_marker( "Marker2000", 2000 )
movingRect_tl:add_marker( "Marker3000", 3000 )
movingRect_tl:add_marker( "Marker4000", 4000 )

-- Show everything onscreen
screen:show()

-- Start the Timeline animation
movingRect_tl:start()
