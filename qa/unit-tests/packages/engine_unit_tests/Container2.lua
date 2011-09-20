--[[
Filename: Container2.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Create a group with children. Move each item by 100 pixels on the x and y coordinate.
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
			position = { 300 , 400 }
		}
		,
		Rectangle
		{
			color = "66cdaa",
			size = { 60 , 60 },
			position = { 700 , 700 }
		}
		,
		Image
		{
			src = "packages/acceptance_unit_tests/assets/logo.png",
			x = 320,
			y = 480
		}
	}
}

local children = g.children
test_group:add(g)


function move_each_child(myElement)
	myElement.position = {myElement.x + 100, myElement.y + 100}
end

g:foreach_child(move_each_child)

-- Tests --

-- Verify that each item was moved 100 pixels on both x and y coordinate.
function test_Container_group_foreach_child ()
	assert_equal( children[1].x , 400 , "foreach_child 1 item  failed" )
	assert_equal( children[1].y , 500 , "foreach_child 1 item  failed" )
	assert_equal( children[2].x , 800 , "foreach_child 1 item  failed" )
	assert_equal( children[2].y , 800 , "foreach_child 1 item  failed" )
	assert_equal( children[3].x , 420 , "foreach_child 1 item  failed" )
	assert_equal( children[3].y , 580 , "foreach_child 1 item  failed" )
end


-- Test Tear down --













