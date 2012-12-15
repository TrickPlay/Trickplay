--[[
Filename: SpriteSheet1.lua
Author: Craig Hughes
Date: Dec 14 2012
Description:  Load a spritesheet and paint some sprites onscreen
--]]


-- Test Set up --
local sheet = SpriteSheet({ map = "packages/engine_unit_tests/tests/assets/test-sprites.json" })

local sprite1 = Sprite({ sheet = sheet, id = "logo.png", position = { 800, 500 } })

test_group:add(sprite1)


-- Tests --

-- Default properties of loading a simple image.
function test_Sprite_basic_properties ()
    is_nil ( sprite1.name, "sprite1.name returned ".. tostring(sprite1.name).. " Expected: nil")
    assert_equal( sprite1.h , 61 , "sprite1.h returned ".. sprite1.h.. " Expected: 61")
    assert_equal( sprite1.w , 150 , "sprite1.w returned ".. sprite1.w.. " Expected: 150")
    assert_equal( sprite1.x , 800 , "sprite1.x returned ".. sprite1.x.. " Expected: 0")
    assert_equal( sprite1.y , 500 ,  "sprite1.y returned ".. sprite1.y.. " Expected: 0")
    assert_equal( sprite1.z , 0 ,  "sprite1.z returned ".. sprite1.z.. " Expected: 0")
    assert_equal( sprite1.center[1], 875 ,  "sprite1.center[1] returned ".. sprite1.center[1].. " Expected: 875")
    assert_equal( sprite1.center[2], 530.5 , "sprite1.center[2] returned ".. sprite1.center[2].. " Expected: 530.5")
    assert_equal( sprite1.anchor_point[1], 0 , "sprite1.anchor_point[1] returned ".. sprite1.anchor_point[1].. " Expected: 0")
    assert_equal( sprite1.anchor_point[2], 0 ,"sprite1.anchor_point[2] returned ".. sprite1.anchor_point[2].. " Expected: 0")
    assert_equal( sprite1.size[1] , 150 , "sprite1.size[1] returned ".. sprite1.size[1].. " Expected: 150")
    assert_equal( sprite1.size[2] , 61 ,  "sprite1.size[2] returned ".. sprite1.size[2].. " Expected: 61")
    assert_equal( sprite1.scale[1] , 1 ,  "sprite1.scale[1] returned ".. sprite1.size[1].. " Expected: 1")
    assert_equal( sprite1.scale[2] , 1 ,  "sprite1.scale[2] returned ".. sprite1.size[2].. " Expected: 1")
    local x_r = sprite1.x_rotation
    local y_r = sprite1.y_rotation
    local z_r = sprite1.z_rotation
    assert_equal( x_r[1] , 0 , "sprite1.x_rotation[1] returned ".. sprite1.x_rotation[1].. " Expected: 0")
    assert_equal( x_r[2] , 0 , "sprite1.x_rotation[2] returned ".. sprite1.x_rotation[2].. " Expected: 0")
    assert_equal( x_r[3] , 0 , "sprite1.x_rotation[3] returned ".. sprite1.x_rotation[3].. " Expected: 0")
    assert_equal( y_r[1] , 0 , "sprite1.y_rotation[1] returned ".. sprite1.y_rotation[1].. " Expected: 0")
    assert_equal( y_r[2] , 0 , "sprite1.y_rotation[2] returned ".. sprite1.y_rotation[2].. " Expected: 0")
    assert_equal( y_r[3] , 0 , "sprite1.y_rotation[3] returned ".. sprite1.y_rotation[3].. " Expected: 0")
    assert_equal( z_r[1] , 0 , "sprite1.z_rotation[1] returned ".. sprite1.z_rotation[1].. " Expected: 0")
    assert_equal( z_r[2] , 0 , "sprite1.z_rotation[2] returned ".. sprite1.z_rotation[2].. " Expected: 0")
    assert_equal( z_r[3] , 0 , "sprite1.z_rotation[3] returned ".. sprite1.z_rotation[3].. " Expected: 0")
    assert_equal( sprite1.is_scaled, false , "Returned: ", tostring(sprite1.is_scaled).. " Expected: false" )
    assert_equal( sprite1.is_rotated, false , "Returned: ", tostring(sprite1.is_rotated).. " Expected: false" )
    assert_equal( sprite1.opacity, 255 , "Returned: ", sprite1.opacity.. " Expected: 255" )
    is_nil(sprite1.clip, "sprite1.clip not created ~= nil")
    assert_equal( sprite1.reactive, false , "Returned: ", tostring(sprite1.reactive).. " Expected false" )
    is_string(sprite1.gid, "Returned: ", sprite1.gid.. " Expected a string")
    is_nil(sprite1.parent, "sprite1.parent not created ~= nil")
    assert_equal(sprite1.min_size[1], 0, "sprite1.min_size[1] returned: ".. sprite1.min_size[1].. " Expected: 0" )
    assert_equal(sprite1.min_size[2], 0, "sprite1.min_size[2] returned: ".. sprite1.min_size[2].. " Expected: 0" )
    assert_equal(sprite1.natural_size[1], 150, "sprite1.natural_size[1] returned: ".. sprite1.natural_size[1].. " Expected: 150" )
    assert_equal(sprite1.natural_size[2], 61, "sprite1.natural_size[2] returned: ".. sprite1.natural_size[2].. " Expected: 150" )
    assert_equal(sprite1.request_mode, "HEIGHT_FOR_WIDTH", "sprite1.request_mode returned: ",sprite1.request_mode.. " Expected: HEIGHT FOR WIDTH")
    assert_equal(sprite1.is_animating, false, "sprite1.is_animating ~= false")
    assert_equal(sprite1.is_visible, true, "sprite1.is_visible ~= true")
end


-- Test Tear down --













