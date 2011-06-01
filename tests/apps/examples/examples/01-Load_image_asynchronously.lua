

-- Create an Image object
local myImage = Image()
myImage.async = true      -- will load image asynchronously

-- Define event handler
local function on_loadedHandler( loadedImage, failed )
    -- Best practice is to unhook the handler after it has served its purpose
    loadedImage.on_loaded = nil

    if failed then
        -- Image did not load; insert handling code here
        print( "Failed to load the image" )
    else
        -- Image is loaded; insert any applicable operations here
        print( "The image has been loaded and is" , loadedImage.w , "x" , loadedImage.h )
    end
end

-- Hook our event handler to the Image object
myImage.on_loaded = on_loadedHandler

-- Start loading the image asynchronously
myImage.src = "assets/globe.png"

--[[
--=============================================================================
-- This is a more compact version 
--=============================================================================

local my_image = Image{ src = "assets/globe.png" , async = true }

function my_image:on_loaded( failed )

    self.on_loaded = nil

    if failed then
        print( "Failed to load the image" )
    else
        print( "The image has been loaded and is" , self.w , "x" , self.h )
    end

end

]]
