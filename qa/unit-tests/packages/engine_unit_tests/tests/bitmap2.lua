--[[
Filename: bitmap2.lua
Author: Peter von dem Hagen
Date: November 15, 2011
Description:  Verify that: 
			* Alpha channel png file depth returns 4
			* png file without alpha channel file returns 3
			* unloaded png file should return 0

--]]

-- No Alpha channel gif  --
local bitmap1 = Bitmap ("packages/engine_unit_tests/tests/assets/small_120x90_shapes.gif")
local image1 = bitmap1:Image()
image1.position = { 300, 300 }
image1.scale = { 7, 7 }
test_group:add (image1)

-- png with alpha channel
local bitmap2 = Bitmap ("packages/engine_unit_tests/tests/assets/alpha_channel1.png")
local image2 = bitmap2:Image()
image2.position = { 250, 250 }
test_group:add(image2)

local bitmap3 = Bitmap ("")


-- Tests --

function test_bitmap_depth ()
    assert_equal( bitmap1.depth , 3 , "bitmap1.depth returned: "..bitmap1.depth..". Expected: 3")
    assert_equal( bitmap2.depth , 4 , "bitmap2.depth returned: "..bitmap2.depth..". Expected: 4")
    assert_equal( bitmap3.depth , 0 , "bitmap3.depth returned: "..bitmap3.depth..". Expected: 0")
end

function test_bitmap_has_alpha ()
	assert_true( bitmap2.has_alpha, "bitmap2.has_alpha returned: "..tostring(bitmap2.has_alpha)..". Expected: true")
    assert_false( bitmap1.has_alpha, "bitmap1.has_alpha returned: "..tostring(bitmap1.has_alpha)..". Expected: false")
end

function test_bitmap_loaded_nil ()
    assert_false ( bitmap3.loaded, "bitmap3.loaded returned: "..tostring(bitmap3.loaded)..". Expected: false")
end
















