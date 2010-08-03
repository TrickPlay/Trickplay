-- menu_extra

-- These are nifty, but unused

-- Change the color of the button text when you have it in focus
function Menu:apply_color_change(color1, color2)
	self.text_color1 = color1
	self.text_color2 = color2
	
	local container = self.buttons
	
	local change = {container.extra.up, container.extra.down, container.extra.left, container.extra.right}
	for i=1,4 do
		local temp = change[i]
		change[i] = function()
			if self.text_color1 ~= nil and self.list[self.y][self.x].extra.text ~= nil then self.list[self.y][self.x].extra.text.color = self.text_color1 end
			temp()	
			if self.text_color2 ~= nil and self.list[self.y][self.x].extra.text ~= nil then self.list[self.y][self.x].extra.text.color = self.text_color2 end	
		end
	end
	container.extra.up = change[1]
	container.extra.down = change[2]
	container.extra.left = change[3]
	container.extra.right = change[4]
	if self.text_color2 ~= nil and self.list[self.y][self.x].extra.text ~= nil then self.list[self.y][self.x].extra.text.color = self.text_color2 end	
end

-- Animate something with a timeline
function Menu:animation(start, finish, dur, val, com)

	print("starting animation")
	local time = Timeline{duration=dur}
	local t = Interval( start , finish )

	function time.on_new_frame(time, elapsed, progress)
		self.container[val] = t:get_value( progress )
		print("value: ", t:get_value( progress ))
	end
	
	function time.on_completed()
		if com and self.loaded ~= nil then self.loaded() end
	end

	time:start()

end



