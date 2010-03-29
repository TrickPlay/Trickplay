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

	-- The rotate function "kicks" the wheel to spin faster (or slower) based on the impulse size.
	rotate = function ( self, impulse )
		self.destination = self.destination + impulse

		num_to_move = (self.destination-self.frontmost)

		-- Map onto a duration which it'll take to get where we want to be
		time_to_move = 500*(1 + math.log(math.abs(num_to_move)-1))

		-- This is the on_new_frame function for the rotation timeline
		local function tick( t, msecs )
			-- First rotate wheel, then rotate the elements of the wheel backwards
			local circle = self.ferris.children[1]
			local children = circle.children
			
			circle.z_rotation = { self.spin.i:get_value(self.spin.a.alpha), 0, 0 }
			local child
			for _,child in ipairs(children) do
				-- Child is rotated opposite to the wheel, plus an offset
				child.z_rotation = { -self.spin.i:get_value(self.spin.a.alpha) +
									(1-math.abs(self.spin.a.alpha + self.spin.a2.alpha - 1)) * 15
									, 0, 0 }
			end
		end
		
		local function wobble( t )
			self.destination = self.destination % self.num_items
			self.frontmost = self.destination
		end

		-- If we're not already spinning, then create a new timeline, interval, etc. otherwise adjust existing
		if not (self.spin.t and self.spin.t.is_playing) then
			self.spin.t = Timeline
							{
								duration = time_to_move,
								on_new_frame = tick,
								on_completed = wobble,
							}
			self.spin.a = Alpha { timeline = self.spin.t, mode = "EASE_IN_OUT_SINE" }
			self.spin.a2 = Alpha { timeline = self.spin.t, mode = "EASE_IN_OUT_BACK" }
			self.spin.i = Interval( self.frontmost*(360/self.num_items), self.destination*(360/self.num_items) )
			self.spin.t:start()
		else
			-- Already spinning: just extend the timeline out and reset target rotation
			-- We need to save the elapsed time then advance there, because otherwise timeline keeps progress, not absolute position
			local elapsed = self.spin.t.elapsed
			self.spin.t.duration = time_to_move
			self.spin.t:advance(elapsed)
			self.spin.i.to = self.destination*(360/self.num_items)
		end
	end,

	new = function ( radius, items, tilt_angle )
		local obj =
				{
					spin = { t = nil, a = nil, a2 = nil, i = nil },
					ferris = Ferris.create_circle( radius, items ),
					rotate = Ferris.rotate,
					frontmost = 0,
					destination = 0,
					num_items = #items,
				}
		obj.ferris.y_rotation = { tilt_angle, 0, 0 }
		
		return obj
	end,
}
