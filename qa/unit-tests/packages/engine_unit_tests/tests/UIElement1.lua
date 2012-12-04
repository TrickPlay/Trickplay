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
    is_nil ( image1.name, "image1.name returned ".. tostring(image1.name).. " Expected: nil")
    assert_equal( image1.h , 61 , "image1.h returned ".. image1.h.. " Expected: 61")
    assert_equal( image1.w , 150 , "image1.w returned ".. image1.w.. " Expected: 150")
    assert_equal( image1.x , 0 , "image1.x returned ".. image1.x.. " Expected: 0")
    assert_equal( image1.y , 0 ,  "image1.y returned ".. image1.y.. " Expected: 0")
    assert_equal( image1.z , 0 ,  "image1.z returned ".. image1.z.. " Expected: 0")
    assert_equal( image1.center[1], 75 ,  "image1.center[1] returned ".. image1.center[1].. " Expected: 75")
    assert_equal( image1.center[2], 30.5 , "image1.center[2] returned ".. image1.center[2].. " Expected: 75")
    assert_equal( image1.anchor_point[1], 0 , "image1.anchor_point[1] returned ".. image1.anchor_point[1].. " Expected: 0")
    assert_equal( image1.anchor_point[2], 0 ,"image1.anchor_point[2] returned ".. image1.anchor_point[2].. " Expected: 0")
    assert_equal( image1.size[1] , 150 , "image1.size[1] returned ".. image1.size[1].. " Expected: 150")
    assert_equal( image1.size[2] , 61 ,  "image1.size[2] returned ".. image1.size[2].. " Expected: 61")
    assert_equal( image1.scale[1] , 1 ,  "image1.scale[1] returned ".. image1.size[1].. " Expected: 1")
    assert_equal( image1.scale[2] , 1 ,  "image1.scale[2] returned ".. image1.size[2].. " Expected: 1")
    local x_r = image1.x_rotation
    local y_r = image1.y_rotation
    local z_r = image1.z_rotation
    assert_equal( x_r[1] , 0 , "image1.x_rotation[1] returned ".. image1.x_rotation[1].. " Expected: 0")
    assert_equal( x_r[2] , 0 , "image1.x_rotation[2] returned ".. image1.x_rotation[2].. " Expected: 0")
    assert_equal( x_r[3] , 0 , "image1.x_rotation[3] returned ".. image1.x_rotation[3].. " Expected: 0")
    assert_equal( y_r[1] , 0 , "image1.y_rotation[1] returned ".. image1.y_rotation[1].. " Expected: 0")
    assert_equal( y_r[2] , 0 , "image1.y_rotation[2] returned ".. image1.y_rotation[2].. " Expected: 0")
    assert_equal( y_r[3] , 0 , "image1.y_rotation[3] returned ".. image1.y_rotation[3].. " Expected: 0")
    assert_equal( z_r[1] , 0 , "image1.z_rotation[1] returned ".. image1.z_rotation[1].. " Expected: 0")
    assert_equal( z_r[2] , 0 , "image1.z_rotation[2] returned ".. image1.z_rotation[2].. " Expected: 0")
    assert_equal( z_r[3] , 0 , "image1.z_rotation[3] returned ".. image1.z_rotation[3].. " Expected: 0")
    assert_equal( image1.is_scaled, false , "Returned: ", tostring(image1.is_scaled).. " Expected: false" )
    assert_equal( image1.is_rotated, false , "Returned: ", tostring(image1.is_rotated).. " Expected: false" )
    assert_equal( image1.opacity, 255 , "Returned: ", image1.opacity.. " Expected: 255" )
    is_nil(image1.clip, "image1.clip not created ~= nil")
    assert_equal( image1.reactive, false , "Returned: ", tostring(image1.reactive).. " Expected false" )
    is_string(image1.gid, "Returned: ", image1.gid.. " Expected a string")
    is_nil(image1.parent, "image1.parent not created ~= nil")
    assert_equal(image1.min_size[1], 0, "image1.min_size[1] returned: ".. image1.min_size[1].. " Expected: 0" )
    assert_equal(image1.min_size[2], 0, "image1.min_size[2] returned: ".. image1.min_size[2].. " Expected: 0" )
    assert_equal(image1.natural_size[1], 150, "image1.natural_size[1] returned: ".. image1.natural_size[1].. " Expected: 150" )
    assert_equal(image1.natural_size[2], 61, "image1.natural_size[2] returned: ".. image1.natural_size[2].. " Expected: 150" )
    assert_equal(image1.request_mode, "HEIGHT_FOR_WIDTH", "image1.request_mode returned: ",image1.request_mode.. " Expected: HEIGHT FOR WIDTH")
    assert_equal(image1.is_animating, false, "image1.is_animating ~= false")
    assert_equal(image1.is_visible, true, "image1.is_visible ~= true")
end


-- Test Tear down --













