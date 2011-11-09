--[[
Filename: UIElement2.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description:  Create a UI Element Image and change it's default values
--]]



-- Test Set up --
local image1 = Image()

image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.name = "logo"
image1.h = 100
image1.w = 100
image1.x = 500
image1.y = 500
image1.z = 100
image1.anchor_point = { image1.x/2 , image1.y/2 }
image1.clip = { 0, 0, 50, 50 }

test_group:add(image1)

-- Tests --

-- Modified basic properties of an image
function test_UIElement_modified_image_properties ()
    assert_equal( image1.name , "logo", "image1.name returned ", image1.name, " Expected: logo")
  	assert_equal( image1.h , 100 , "image1.h returned ", image1.h, "Expected: 100")
    assert_equal( image1.w , 100 , "image1.w returned ", image1.w, "Expected: 100")
    assert_equal( image1.x , 500 , "image1.x returned ", image1.x, "Expected: 500")
    assert_equal( image1.y , 500 ,  "image1.y returned ", image1.y, "Expected: 500")
    assert_equal( image1.z , 100 ,  "image1.z returned ", image1.z, "Expected: 100")
  	assert_equal( image1.center[1], 300 ,  "image1.center[1] returned ", image1.center[1], "Expected: 300")
    assert_equal( image1.center[2], 300 , "image1.center[2] returned ", image1.center[2], "Expected: 300")
    assert_equal( image1.anchor_point[1], 250 , "image1.anchor_point[1] returned ", image1.anchor_point[1], "Expected: 250")
    assert_equal( image1.anchor_point[2], 250 ,"image1.anchor_point[2] returned ", image1.anchor_point[2], "Expected: 250")
    assert_equal( image1.size[1] , 100 , "image1.size[1] returned ", image1.size[1], "Expected: 100")
    assert_equal( image1.size[2] , 100 ,  "image1.size[2] returned ", image1.size[2], "Expected: 100")
    assert_equal( image1.scale[1] , 1 ,  "image1.scale[1] returned ", image1.size[1], "Expected: 1")
    assert_equal( image1.scale[2] , 1 ,  "image1.scale[2] returned ", image1.size[2], "Expected: 1")
    assert_equal( image1.x_rotation[1] , 0 , "image1.x_rotation[1] returned ", image1.x_rotation[1], "Expected: 0")
    assert_equal( image1.x_rotation[2] , 0 , "image1.x_rotation[2] returned ", image1.x_rotation[2], "Expected: 0")
    assert_equal( image1.x_rotation[3] , 0 , "image1.x_rotation[3] returned ", image1.x_rotation[3], "Expected: 0")
    assert_equal( image1.y_rotation[1] , 0 , "image1.y_rotation[1] returned ", image1.y_rotation[1], "Expected: 0")
    assert_equal( image1.y_rotation[2] , 0 , "image1.y_rotation[2] returned ", image1.y_rotation[2], "Expected: 0")
    assert_equal( image1.y_rotation[3] , 0 , "image1.y_rotation[3] returned ", image1.y_rotation[3], "Expected: 0")
    assert_equal( image1.z_rotation[1] , 0 , "image1.z_rotation[1] returned ", image1.z_rotation[1], "Expected: 0")
    assert_equal( image1.z_rotation[2] , 0 , "image1.z_rotation[2] returned ", image1.z_rotation[2], "Expected: 0")
    assert_equal( image1.z_rotation[3] , 0 , "image1.z_rotation[3] returned ", image1.z_rotation[3], "Expected: 0")
    assert_equal( image1.is_scaled, false , "Returned: ", image1.is_scaled, " Expected: false" )
    assert_equal( image1.is_rotated, false , "Returned: ", image1.is_rotated, " Expected: false" )
    assert_equal( image1.opacity, 255 , "new image1.opacity default 0 failed" )
    assert_equal (image1.has_clip, true, "image1.has_clip not created ~= true")
    assert_equal( image1.reactive, false , "Returned: ", image1.reactive, " Expected false" )
    is_string(image1.gid, "Returned: ", image1.gid, " Expected a string")
    is_nil(image1.parent, "new image1.parent not created ~= nil")
    assert_equal(image1.min_size[1], 100, "image1.min_size[1] returned: ", image1.min_size[1], " Expected: 100" )
    assert_equal(image1.min_size[2], 100, "image1.min_size[2] returned: ", image1.min_size[2], " Expected: 100" )
    assert_equal(image1.natural_size[1], 100, "image1.natural_size[1] returned: ", image1.natural_size[1], " Expected: 100" )
    assert_equal(image1.natural_size[2], 100, "image1.natural_size[2] returned: ", image1.natural_size[2], " Expected: 100" )
    assert_equal(image1.request_mode, "HEIGHT_FOR_WIDTH", "image1.request_mode returned: ",image1.request_mode, " Expected: HEIGHT FOR WIDTH")
    assert_equal(image1.is_animating, false, "new image1.is_animating ~= false")
    assert_equal(image1.is_visible, true, "new image1.is_visible ~= true")
end

-- Test Tear down --













