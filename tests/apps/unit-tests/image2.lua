--[[
Filename: Image2.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Load and resize an image. Then verify on_loaded and on_size_changed event handlers are
             called. 
             Load a non-existent image and verify callback is still called/failed = true
--]]

-- Test Set up --

local image1 = Image()
local image2 = Image()
local image3 = Image()
local image3_callback_called = false

-- Add an image asyncronously
image1.async = false
image1.src = "assets/globe.png"
image1.position ={ 1500, 900 }
image1.size = { 100, 100}
screen:add (image1)

-- Tile an image
image2.src = "assets/jack.jpg"
image2.position = { 1500, 500 }
image2.size = { 320, 320 }
image2.tile = { true, true }
screen:add (image2)

-- Test callback for a failed load
function image3_on_loaded(image,failed)
	image3_callback_called = true
end

image3.on_loaded = image3_on_loaded

image3.async = true
image3.src = "assets/does_not_exist.png"
screen:show()


-- Tests --
function test_Image_base_size()
	assert_equal( image1.base_size[1] , 300, "image load callback failed" )
	assert_equal( image1.base_size[2] , 300, "image load callback failed" )
end

function test_Image_tile_setter()
	assert_equal( image2.tile[1] , true, "image tile failed" )
	assert_equal( image2.tile[2] , true, "image tile failed" )
end

function test_Image_loaded ()
	assert_equal( image1.loaded , true, "image 1 loaded ~= true" )
	assert_false ( image3.loaded, "non-existent image loaded ~= false" )
end

function test_Image_failed_to_load ()
	assert_equal( image3_callback_called, true, "no callback on a failed load" )
	assert_false ( image3.loaded, "non-existent image loaded ~= false" )
end

-- Test Tear down --














