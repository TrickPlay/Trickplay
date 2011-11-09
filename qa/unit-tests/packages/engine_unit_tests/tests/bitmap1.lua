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

bitmap1_async_loaded_called = false
local bitmap1 = Bitmap( "packages/engine_unit_tests/tests/assets/logo.png",true)

bitmap1.on_loaded = function()
	bitmap1_async_loaded_called = true
	image1 = bitmap1:Image()
	image1.position = { 400, 400}
	test_group:add(image1)
end


-- Tests --


function test_bitmap_loaded ()
    assert_equal( bitmap1.loaded , true , "bitmap.loaded failed" )
end

function test_bitmap_w_h ()
    assert_equal( bitmap1.w , 150 , "bitmap.w returned: "..bitmap1.w.." Expected 150")
    assert_equal( bitmap1.h , 61 ,"bitmap.h returned: "..bitmap1.w.." Expected 61")
end
    
function test_bitmap_on_loaded ()
    assert_equal( bitmap1_async_loaded_called , true , "bitmap.on_loaded failed" )
end

function test_bitmap_rendered ()
    assert_equal( image1.position[1] , 400 ,"image1.position[1] returned: "..image1.position[1].." Expected 400")
    assert_equal( image1.position[2] , 400 ,"image1.position[2] returned: "..image1.position[2].." Expected 400")
end
-- Test Tear down --













