--[[
Filename: bitmap1.lua
Author: Peter von dem Hagen
Date: January 31, 2011
Description:  Verify that:
					- on_load gets called when successful async bitmap is loaded.
					- image is rendered at expected coordinates
					- bitmap.loaded returns true.
--]]




-- Test Set up --
local image1

local bitmap_async_loaded_called = false
local bitmap1 = Bitmap( "packages/acceptance_unit_tests/assets/logo.png",true)

bitmap1.on_loaded = function()
	bitmap_async_loaded_called = true
	image1 = bitmap1:Image()
	image1.position = { 400, 400}
	test_group:add(image1)
end


-- Tests --


function test_bitmap_loaded ()
    assert_equal( bitmap1.loaded , true , "bitmap.loaded failed" )
end

function test_bitmap_w_h ()
    assert_equal( bitmap1.w , 150 , "bitmap.w failed" )
    assert_equal( bitmap1.h , 61 , "bitmap.h failed" )
end
    
function test_bitmap_on_loaded ()
    assert_equal( bitmap_async_loaded_called , true , "bitmap.on_loaded failed" )
end

function test_bitmap_rendered ()
    assert_equal( image1.position[1] , 400 , "Rendering bitmap image failed" )
    assert_equal( image1.position[2] , 400 , "Rendering bitmap image failed" ) 
end
-- Test Tear down --













