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
image1.src = "packages/engine_unit_tests/tests/assets/globe.png"
image1.position ={ 1500, 900 }
image1.size = { 100, 100}
test_group:add (image1)

-- Tile an image
image2.src = "packages/engine_unit_tests/tests/assets/jack.jpg"
image2.position = { 1500, 500 }
image2.size = { 320, 320 }
image2.tile = { true, true }
test_group:add(image2)

-- Test callback for a failed load
function image3_on_loaded(image,failed)
	image2_callback_called = true
end

image3.on_loaded = image3_on_loaded

image3.async = true
print("UNIT-TEST: WE SHOULD GET WARNING ABOUT MISSING IMAGE")
image3.src = "packages/engine_unit_tests/tests/assets/does_not_exist.png"


-- Tests --
function test_Image_base_size()
	assert_equal( image1.base_size[1] , 300, "Returned: "..image1.base_size[1].." Expected: 300" )
	assert_equal( image1.base_size[2] , 300, "Returned: "..image1.base_size[2].." Expected: 300" )
end

function test_Image_tile_setter()
	assert_equal( image2.tile[1] , true, "Returned: ".. tostring(image2.tile[1]) .." Expected: true" )
	assert_equal( image2.tile[2] , true, "Returned: ".. tostring(image2.tile[2]).." Expected: true" )
end

function test_Image_loaded ()
	assert_equal( image1.loaded , true, "image1.loaded returned "..tostring(image1.loaded).." Expected: true")
end

function test_Image_failed_to_load ()
	assert_equal( image2_callback_called, true, "no callback on a failed load" )
	assert_false ( image3.loaded, "image3.loaded returned "..tostring(image3.loaded).." Expected: false")
end

-- Test Tear down --














