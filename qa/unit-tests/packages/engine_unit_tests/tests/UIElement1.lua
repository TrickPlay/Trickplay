--[[
Filename: UIElement1.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description:  Create a UI Element Image and test its default properties
--]]


-- Test Set up --
local image1 = Image()

image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
test_group:add(image1)


-- Tests --

-- Default properties of loading a simple image.
function test_UIElement_image_basic_setters ()
    is_nil ( image1.name, "image1.name ~= nil" )
    assert_equal( image1.h , 61 , "image1.h failed" )
    assert_equal( image1.w , 150 , "image1.w failed" )
    assert_equal( image1.x , 0 , "image1.x default 0 failed" )
    assert_equal( image1.y , 0 , "image1.y default 0 failed" )
    assert_equal( image1.z , 0 , "image1.y default 0 failed" )
    assert_equal( image1.center[1], 75 , "image1.center[1] failed") 
    assert_equal( image1.center[2], 30.5 , "image1.center[2] failed")
    assert_equal( image1.anchor_point[1], 0 , "image1.anchor_point[1] default 0 failed") 
    assert_equal( image1.anchor_point[2], 0 , "image1.anchor_point[2] default 0 failed")
    assert_equal( image1.size[1] , 150 , "image1.size[1] failed" )
    assert_equal( image1.size[2] , 61 , "image1.size[2] failed" )
    assert_equal( image1.scale[1] , 1 , "image1.scale[1] failed" )
    assert_equal( image1.scale[2] , 1 , "image1.scale[2] failed" )
    assert_equal( image1.x_rotation[1] , 0 , "image1.x_rotation[1] default 0 failed" )
    assert_equal( image1.x_rotation[2] , 0 , "image1.x_rotation[2] default 0 failed" )
    assert_equal( image1.x_rotation[3] , 0 , "image1.x_rotation[3] default 0 failed" )
    assert_equal( image1.y_rotation[1] , 0 , "image1.y_rotation[1] default 0 failed" )
    assert_equal( image1.y_rotation[2] , 0 , "image1.y_rotation[2] default 0 failed" )
    assert_equal( image1.y_rotation[3] , 0 , "image1.y_rotation[3] default 0 failed" )
    assert_equal( image1.z_rotation[1] , 0 , "image1.z_rotation[1] default 0 failed" )
    assert_equal( image1.z_rotation[2] , 0 , "image1.z_rotation[2] default 0 failed" )
    assert_equal( image1.z_rotation[3] , 0 , "image1.z_rotation[3] default 0 failed" )
    assert_equal( image1.is_scaled, false , "image1.is_scaled default false failed" )
    assert_equal( image1.is_rotated, false , "image1.is_rotated default false failed" )
    assert_equal( image1.opacity, 255 , "image1.opacity default 0 failed" )
    is_nil(image1.clip, "image1.clip not created ~= nil")
    assert_equal( image1.reactive, false , "image1.reactive = false failed" )
    is_string(image1.gid, "image1.gid is_string failed" )
    is_nil(image1.parent, "image1.parent not created ~= nil")
    assert_equal(image1.min_size[1], 0, "image1.min_size default ~= 0")
    assert_equal(image1.min_size[2], 0, "image1.min_size default ~= 0")
    assert_equal(image1.natural_size[1], 150, "image1.natural_size default ~= 0")
    assert_equal(image1.natural_size[2], 61, "image1.natural_size default ~= 0")
    assert_equal(image1.request_mode, "HEIGHT_FOR_WIDTH" ,"image1.request_mode ~= HEIGHT FOR WIDTH")
    assert_equal(image1.is_animating, false, "image1.is_animating ~= false")
    assert_equal(image1.is_visible, true, "image1.is_visible ~= true")
end


-- Test Tear down --













