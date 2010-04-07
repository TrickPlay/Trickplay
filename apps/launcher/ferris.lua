--[[

	Ferris.lua
	----------
	
	Functions to create a ferris-wheel like setup of flat images attached around a circle.  They can be rotated to spin a new item to the "front" slot.

	TODO: Allow wheel to be "fixed number of slots", with extra items in the wheel either being duplicated if there are too few items, or magically disappearing/getting slotted in/out at the back of the rotation in the opacity=0 slot.

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
			item:move_anchor_point( item.w/2, item.h/2 )

			item.x = point.x
			item.y = point.y
			item.y_rotation = { 90, 0, 0 }

			circle:add(item)
			item.opacity = ((1+math.cos(math.rad(- (p-1)*360/num_items)))/2)*255
		end

		circle:move_anchor_point( radius, radius )

		local circle_group = Group {}
		circle_group:add(circle)

		return circle_group
	end,

	unhighlight = function ( self )
		-- Pan current active item back to flat
		local item = self.ferris.children[1].children[self.spin.frontmost+1]
		item:animate( { duration = 200, y_rotation = 90, scale = { 1, 1 }, mode = "EASE_IN_OUT_SINE" } )
		-- And turn "off" the frame
		item.children[1].src = item.children[1].src:gsub("-on.png", "-off.png")
		item.children[2].font = "Graublau Web,DejaVu Sans,Sans 24px"
	end,

	highlight = function ( self )
		local item = self.ferris.children[1].children[self:get_active()]
		item.children[1].src = item.children[1].src:gsub("-off.png", "-on.png")
		item.children[2].font = "Graublau Web,DejaVu Sans,Sans bold 24px"
		if self.highlight_on == true then
			item:animate( { duration = 200, y_rotation = -1.5*self.ferris.y_rotation[1], scale = {1.25, 1.25}, mode = "EASE_IN_OUT_SINE" } )
		else
			item:animate( { duration = 200, y_rotation = 90, scale = { 1, 1 }, mode = "EASE_IN_OUT_SINE" } )
		end
	end,

	goto = function ( self, destination )
		self:unhighlight()
		local circle = self.ferris.children[1]
		local children = circle.children

		circle.z_rotation = { destination*(360/self.num_items), 0, 0 }
		local child
		local num
		for num,child in ipairs(children) do
			child.z_rotation = { -destination*(360/self.num_items), 0, 0 }
			child.opacity = ((1+math.cos(math.rad(circle.z_rotation[1] - (num-1)*360/self.num_items)))/2)*255
		end

		self.spin.destination = destination % self.num_items
		self.spin.frontmost = self.spin.destination
		self:highlight()
	end,

	-- The rotate function "kicks" the wheel to spin faster (or slower) based on the impulse size.
	rotate = function ( self, impulse )
		self.spin.destination = self.spin.destination + impulse

		num_to_move = (self.spin.destination-self.spin.frontmost)

		-- Map onto a duration which it'll take to get where we want to be
		time_to_move = 500*(1 + math.log(math.abs(num_to_move)))

		-- This is the on_new_frame function for the rotation timeline
		local function tick( t, msecs )
			-- First rotate wheel, then rotate the elements of the wheel backwards
			local circle = self.ferris.children[1]
			local children = circle.children
			
			circle.z_rotation = { self.spin.i:get_value(self.spin.a.alpha), 0, 0 }
			local child
			local num
			for num,child in ipairs(children) do
				-- Child is rotated opposite to the wheel, plus an offset
				child.z_rotation = { -self.spin.i:get_value(self.spin.a.alpha) +
									(1-math.abs(self.spin.a.alpha + self.spin.a2.alpha - 1)) * 30
									, 0, 0 }
				-- And now fade based on the depth from front
				child.opacity = ((1+math.cos(math.rad(circle.z_rotation[1] - (num-1)*360/self.num_items)))/2)*255
			end
		end
		
		local function complete( t )
			self.spin.destination = self.spin.destination % self.num_items
			self.spin.frontmost = self.spin.destination
			self:highlight()
		end

		-- If we're not already spinning, then create a new timeline, interval, etc. otherwise adjust existing
		if not (self.spin.t and self.spin.t.is_playing) then
			self:unhighlight()

			self.spin.t = Timeline
							{
								duration = time_to_move,
								on_new_frame = tick,
								on_completed = complete,
							}
			self.spin.a = Alpha { timeline = self.spin.t, mode = "EASE_IN_OUT_SINE" }
			self.spin.a2 = Alpha { timeline = self.spin.t, mode = "EASE_OUT_BACK" }
			self.spin.i = Interval( self.spin.frontmost*(360/self.num_items), self.spin.destination*(360/self.num_items) )
			self.spin.t:start()
		else
			-- Already spinning: just extend the timeline out and reset target rotation
			-- We need to save the elapsed time then advance there, because otherwise timeline keeps progress, not absolute position
			local elapsed = self.spin.t.elapsed
			self.spin.t.duration = time_to_move
			self.spin.t:advance(elapsed)
			self.spin.i.to = self.spin.destination*(360/self.num_items)
		end
	end,

	get_active = function ( self )
		return (self.spin.frontmost % self.num_items) + 1
	end,

	new = function ( radius, items, tilt_angle )
		local obj =
				{
					spin = { t = nil, a = nil, a2 = nil, i = nil, frontmost = 0, destination = 0 },
					radius = radius,
					ferris = Ferris.create_circle( radius, items ),
					rotate = Ferris.rotate,
					goto = Ferris.goto,
					highlight = Ferris.highlight,
					unhighlight = Ferris.unhighlight,
					highlight_on = false,
					get_active = Ferris.get_active,
					num_items = #items,
				}
		obj.ferris.y_rotation = { tilt_angle, 0, 0 }
		obj:highlight()
		
		return obj
	end,
}
