--[[
Filename: UIElement10.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Create a group with children. Use unparent to remove one item then verify that the
             number of children is one less.
--]]

-- Test Set up --
local image1 = Image()

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
		Text
		{
			font = "DejaVu Sans 22px" ,
			color = "FFFFFFAA" ,
			text = "This is my text1",
			position = { 500 ,600 }
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

screen:add(g)
children[1]:unparent()
local children = g.children
screen:show()

-- Tests --

-- Verify that unparent removes one item from the group.
function test_UIElement_image_unparent ()
	assert_equal(#children, initial_children-1 , "unparent failed")
end


-- Test Tear down --













