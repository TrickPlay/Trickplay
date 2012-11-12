
-- Create an Image object
local myImage = Image()
myImage.async = true        -- will load image asynchronously

-- Define event handler
handleLoadedEvent = nil
function on_loadedHandler( loadedImage, failed )
  -- Best practice is to unhook the handler after it has served its purpose
  loadedImage:remove_onloaded_listener( handleLoadedEvent )
  handleLoadedEvent = nil

  if failed then
    -- Image did not load; insert handling code here
    print( "Failed to load the image" )
  else
    -- Image is loaded; insert any desired operations here
    print( "The image has been loaded and is", loadedImage.w, "x", loadedImage.h )
  end
end

-- Register our event handler to the Image object
handleLoadedEvent = myImage:add_onloaded_listener( on_loadedHandler )

-- Start loading the image asynchronously
myImage.src = "assets/globe.png"
