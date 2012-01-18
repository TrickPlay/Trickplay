--[[
Filename: Container5.lua
Author: Peter von dem Hagen
Date: November 30, 2011
Description: Boundary test. Add 1000 text items.
--]]

-- Test Set up --

local g = Group ()

for i = 1, 1000 do
		
	g:add(Text
		{
			font = "DejaVu Sans 20px" ,
			color = "FF00FF" ,
			text = "Text "..i,
			position = { i * 2 , i }
		})

end

test_group:add(g)

-- Tests --

-- Verify that 1000 text items can be added.
function test_Container_group_boundary_add_1000 ()
	assert_equal(#g.children, 1000 , "Returned: "..#g.children.." Expected: 1000")
end


-- Test Tear down --













