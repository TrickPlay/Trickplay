--[[
Filename: UIElement2.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description:  Create a UI Element Image and change it's default values
--]]



-- Test Set up --
local image1 = Image()

image1.src = "assets/logo.png"
image1.name = "logo"
image1.h = 100
image1.w = 100
image1.x = 500
image1.y = 500
image1.z = 100
image1.anchor_point = { image1.x/2 , image1.y/2 }
image1.clip = { 0, 0, 50, 50 }

screen:add(image1)
screen:show()

-- Tests --

-- Modified basic properties of an image
function test_UIElement_modified_image_properties ()
    assert_equal( image1.name , "logo", "image1.name failed" )
    assert_equal( image1.h , 100 , "new image1.h failed" )
    assert_equal( image1.w , 100 , "new image1.w failed" )
    assert_equal( image1.x , 500 , "new image1.x failed" )
    assert_equal( image1.y , 500 , "new image1.yfailed" )
    assert_equal( image1.z , 100 , "new image1.yfailed" )
    assert_equal( image1.center[1], 300 , "new image1.center[1] failed") 
    assert_equal( image1.center[2], 300 , "new image1.center[2] failed")
    assert_equal( image1.anchor_point[1], 250 , "new image1.anchor_point[1] failed") 
    assert_equal( image1.anchor_point[2], 250 , "new image1.anchor_point[2] failed")
    assert_equal( image1.size[1] , 100 , "new image1.size[1] failed" )
    assert_equal( image1.size[2] , 100 , "new image1.size[2] failed" )
    assert_equal( image1.scale[1] , 1 , "new image1.scale[1] failed" )
    assert_equal( image1.scale[2] , 1 , "new image1.scale[2] failed" )
    assert_equal( image1.x_rotation[1] , 0 , "new image1.x_rotation[1] default 0 failed" )
    assert_equal( image1.x_rotation[2] , 0 , "new image1.x_rotation[2] default 0 failed" )
    assert_equal( image1.x_rotation[3] , 0 , "new image1.x_rotation[3] default 0 failed" )
    assert_equal( image1.y_rotation[1] , 0 , "new image1.y_rotation[1] default 0 failed" )
    assert_equal( image1.y_rotation[2] , 0 , "new image1.y_rotation[2] default 0 failed" )
    assert_equal( image1.y_rotation[3] , 0 , "new image1.y_rotation[3] default 0 failed" )
    assert_equal( image1.z_rotation[1] , 0 , "new image1.z_rotation[1] default 0 failed" )
    assert_equal( image1.z_rotation[2] , 0 , "new image1.z_rotation[2] default 0 failed" )
    assert_equal( image1.z_rotation[3] , 0 , "new image1.z_rotation[3] default 0 failed" )
    assert_equal( image1.is_scaled, false , "new image1.is_scaled default false failed" )
    assert_equal( image1.is_rotated, false , "new image1.is_rotated default false failed" )
    assert_equal( image1.opacity, 255 , "new image1.opacity default 0 failed" )
    assert_equal (image1.has_clip, true, "image1.has_clip not created ~= true")
    assert_equal( image1.reactive, false , "new image1.reactive = false failed" )
    is_string(image1.gid, "new image1.gid is_string failed" )
    is_nil(image1.parent, "new image1.parent not created ~= nil")
    assert_equal(image1.min_size[1], 100, "new image1.min_size default ~= 100")
    assert_equal(image1.min_size[2], 100, "new image1.min_size default ~= 100")
    assert_equal(image1.natural_size[1], 100, "new image1.natural_size default ~= 0")
    assert_equal(image1.natural_size[2], 100, "new image1.natural_size default ~= 0")
    assert_equal(image1.request_mode, "HEIGHT_FOR_WIDTH" ,"image1.request_mode ~= HEIGHT FOR WIDTH")
    assert_equal(image1.is_animating, false, "new image1.is_animating ~= false")
    assert_equal(image1.is_visible, true, "new image1.is_visible ~= true")
end


-- Test Tear down --













