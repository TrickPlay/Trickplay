
test_description = "Create 400 groups within a group."
test_group = "acceptance"
test_area = "container"
test_api = "add"


function generate_test_image ()

	-- Test Set up --
	local g = Group()
 	local test_image = Group()


	-- Recursively create 400 groups within groups
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

	local g3 = create_new_rect (g, 400)
	test_image:add(g3)
	
	return test_image
end











