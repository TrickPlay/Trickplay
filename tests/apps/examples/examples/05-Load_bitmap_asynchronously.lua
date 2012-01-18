		-- Initiate asynchronous image load
		local myBitmap = Bitmap( "image.png", true )
		
		-- Asynchronous-load event handler
		function myBitmap:on_loaded( failed )
		  if failed then
		    -- Image did not load; insert handling code here
		    print( "Failed to load the image" )
		  else
		    -- Image is loaded; insert any applicable operations here
		    print( "The image has been loaded, size = ", self.width, " x ", self.height )
		  end
		end

