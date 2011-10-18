--[[
Filename: Container1.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Create a group with children. Add a new element to the group using add
--]]

-- Test Set up --
local image1 = Image()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.x = 320
image1.y = 480

local g = Group
{   
	children =
	{
		Text
		{
			font = "DejaVu Sans 38px" ,
			color = "FFFFFFAA" ,
			text = "This is my text1",
			position = { 300 , 400 }
		}
		,
		Rectangle
		{
			color = "66cdaa",
			size = { 60 , 60 },
			position = { 700 , 700 }
		}
	}
}



local children = g.children
local initial_children = #children
g:add(image1)
test_group:add(g)
local children = g.children


-- Tests --

-- Verify that unparent adds one item from the group.
function test_Container_group_adds ()
	assert_equal(#children, initial_children+1 , "container.remove failed")
end


-- Test Tear down --













