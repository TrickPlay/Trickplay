		-- Asynchronous-load event handler
		function handleBitmapLoad( loadedImage, failed )
		  if failed then
		    -- Image did not load; insert handling code here
		    print( "Failed to load the image" )
		  else
		    -- Image is loaded; insert any applicable operations here
		    print( "The image has been loaded, size = ", loadedImage.width, " x ", loadedImage.height )
		  end
		end

		-- Initiate asynchronous image load
		local myBitmap = Bitmap( "image.png", true )

        -- Register image-load event handler
        myBitmap:add_onloaded_listener( handleBitmapLoad )
