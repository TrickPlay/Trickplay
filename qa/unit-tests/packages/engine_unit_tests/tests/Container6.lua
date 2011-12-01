--[[
Filename: Container6.lua
Author: Peter von dem Hagen
Date: November 30, 2011
Description: Boundary test. Recursive create 300 groups within groups, each containing a rectangle.
--]]

-- Test Set up --
local g = Group()


-- Recursively create 300 gruops within groups
local function create_new_rect (g2, n)
      if n == 0 then return g2
      else
	local g1 = Group()
	 g1:add(Rectangle
		{
		size = { n * 2 , n * 2 },
		color = string.sub(n, 1)..string.sub(n,1)..string.sub(n, 1)..string.sub(n,1)..string.sub(n, 1)..string.sub(n,1),
		position = { n * 2 , n * 2 },
		name = "rect_"..n
		}
	 )
	 g1:add(g2)
	 g1:lower_child(g2)
	 return create_new_rect(g1, n-1)
      end
    end

local g3 = create_new_rect (g, 300)
test_group:add(g3)

-- Count all items to make sure there are 300
local count = 0
for i = 1, 300 do
	if g3:find_child("rect_"..i).name ~= nil then
		count = count + 1
	end
end


-- Tests --

-- Verify that 300 groups within groups.
function test_Container_group_boundary_recurse_300 ()
	assert_equal(count, 300 , "Returned: "..count.." Expected: 300")
end




-- Test Tear down --













