--[[
Filename: Image1.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Load and resize an image. Then verify on_loaded and on_size_changed event handlers are
             called.
--]]

-- Test Set up --

local my_image = Image()
local sizeChanged


function my_image_on_loaded(image,failed)
	image1Loaded = true
    --print("LOADED",failed)
end

function my_image_on_size_changed()
	sizeChanged = true
end

my_image.on_loaded = my_image_on_loaded
my_image.on_size_changed = my_image_on_size_changed

my_image.async = true
my_image.src = "packages/engine_unit_tests/tests/assets/logo.png"
my_image.position={400,200}
my_image.h = 400
my_image.w = 600
test_group:add(my_image)



-- Tests --
function test_Image_loaded_callback()
	assert_equal( image1Loaded , true, "image load callback failed" )
end

function test_Image_size_changed_callback ()
	assert_equal( sizeChanged , true, "image size change callback failed" )
end




-- Test Tear down --













