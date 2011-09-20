--[[
Filename: Container4.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Create a group with children. Use find_child to find the image element then remove
             it using remove. Verify there is one less element in the group after this.
--]]

-- Test Set up --

local g = Group
{   
	children =
	{
		Text
		{
			font = "DejaVu Sans 38px" ,
			color = "FFFFFFAA" ,
			text = "This is my text1",
			position = { 700 , 800 }
		}
		,
		Rectangle
		{
			color = "66cdaa",
			size = { 60 , 60 },
			position = { 800 , 900 }
		}
		,
		Image
		{
			src = "packages/acceptance_unit_tests/assets/logo.png",
			name = "logo",
			x = 650,
			y = 320
		}
	}
}
local children = g.children
local initial_children = #children
test_group:add(g)
local logo = g:find_child("logo")
g:remove(logo)
local children = g.children


-- Tests --

-- Verify that find_child finds the image and remove removes it.
function test_Container_group_remove_find_child ()
	assert_equal(#children, initial_children-1 , "container.remove failed")
end


-- Test Tear down --













