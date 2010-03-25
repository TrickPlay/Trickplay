--[[

	Ferris.lua
	----------
	
	Functions to create a ferris-wheel like setup of flat images attached around a circle.  They can be rotated to spin a new item to the "front" slot.

]]--

Ferris = {

	-- Need to plot points around the circle in equal divisions.  Return circle with anchor placed at its center
	create_circle = function ( radius, items )

		-- Point #1 is 3 o'clock; center of circle is at (radius, radius)
		local function point_location( radius, point_number, num_points )
			local angle_per_point = math.pi*2 / num_points
			local point_angle = angle_per_point * ( point_number - 1 )

			-- Need to offset by (radius, radius) since reference is to top-left corner
			x = radius * ( 1 + math.cos(point_angle) )
			y = radius * ( 1 - math.sin(point_angle) )

			return { x = x, y = y }
		end

		local circle = Group {}

		local num_items = #items

		for p,item in ipairs(items) do
			local point = point_location( radius, p, num_items )
			item:move_anchor_point( item.w/2, 0 )

			item.x = point.x
			item.y = point.y
			item.y_rotation = { 90, 0, 0 }

			circle:add(item)
		end

		circle:move_anchor_point( radius, radius )

		local circle_group = Group {}
		circle_group:add(circle)

		return circle_group
	end,

	rotate = function ( self, num_slots, time )
		local circle = self.ferris.children[1]
		local children = circle.children
		local num_items = #children

		local t = Timeline { duration = time }
		local a = Interval ( circle.z_rotation[1], circle.z_rotation[1] + num_slots * 360/num_items )
		local c = Alpha{ timeline = t , mode = "EASE_IN_OUT_BACK" }

		local t2 = Timeline { duration = time * 2/3 }
		local a2 = Interval ( children[1].z_rotation[1], children[1].z_rotation[1] - num_slots * 360/num_items )
		local c2 = Alpha{ timeline = t2 , mode = "EASE_IN_OUT_BACK" }

		function t.on_new_frame( t , msecs )
			circle.z_rotation = { a:get_value( c.alpha ), 0, 0 }
		end

		function t2.on_new_frame( t, msecs )
			local child
			for _,child in ipairs(children) do
				child.z_rotation = { a2:get_value( c2.alpha ), 0, 0 }
			end
		end

		t:start()
		t2:start()
	end,

	new = function ( radius, items, tilt_angle )
		local obj =
				{
					ferris = Ferris.create_circle( radius, items ),
					rotate = Ferris.rotate,
				}
		obj.ferris.y_rotation = { tilt_angle, 0, 0 }
		
		return obj
	end,
}
