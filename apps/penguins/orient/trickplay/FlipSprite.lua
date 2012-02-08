FlipSprite = Class {
	extends = Sprite,
	shared = {
		flip = function(self,reset)
			self.frame = self.frame % #self.srcs + 1
			self.src = self.srcs[self.frame]
			if reset then
				self:stop()
				self:start()
			end
		end,
		flop = function(self,reset)
			self.frame = self.frame-2
			self:flip(reset)
		end,
		start = function(self,interval)
			if interval then
				self.timer.interval = interval
			end
			self.timer:start()
		end,
		stop = function(self)
			self.timer:stop()
		end
	},
	public = {
		frame = 1,
		srcs = false,
		timer = false
	},
	new = function(self,t)
		t = t or {}
		t.srcs = t.srcs or {}
		if self.bbox then
			self.bbox:set(self,t.bbox)
		else
			self.bbox = BBox(self,t.bbox)
		end
		t.timer = Timer{on_timer = function(timer)
			if self.flip then
				self:flip()
			else
				timer:stop()
			end
		end, interval = t.interval or 0}
		t.bbox = nil
		t.interval = nil
		table.merge(self,t)
	end
}