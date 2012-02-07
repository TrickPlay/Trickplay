local a, s = {0,0}, {1,1}
local trans = {'l','t','r','b'}

local intersects = function(a,b)
	if a.update then a:update() end
	if b.update then b:update() end
	return a.x <= b.x + b.w and a.x + a.w >= b.x and
		   a.y <= b.y + b.h and a.y + a.h >= b.y
end
local contains = function(a,b)
	if a.update then a:update() end
	if b.update then b:update() end
	return a.x <= b.x and a.x + a.w >= b.x + b.w and 
		   a.y <= b.y and a.y + a.h >= b.y + b.h
end
local set = function(self,obj,t)
	if type(t) == 'table' then
		for k,v in ipairs(trans) do
			self[v] = t[k] or t[v] or 0
		end
		if self.dirty == 0 then 
			self.dirty = 1
		end
	end
	if obj then
		self.obj = obj
		self:update()
	end
end

BBox = Class {
	extends = Rect,
	static = {
		intersects = intersects,
		contains = contains
	},
	shared = {
		intersects = intersects,
		contains = contains,
		set = set,
		update = function(self,obj)
			if self.dirty ~= 0 and self.obj or obj then
				obj = obj or self.obj
				local a = obj.anchor_point or a
				local s = obj.scale or s
				self.x = obj.x - (a[1] - self.l) * s[1]
				self.y = obj.y - (a[2] - self.t) * s[2]
				self.w = (obj.w - self.l + self.r) * s[1]
				self.h = (obj.h - self.t + self.b) * s[2]
				if self.dirty == 1 then 
					self.dirty = 0
				end
			end
			return self
		end
	},
	public = {
		l = 0,
		t = 0,
		r = 0,
		b = 0,
		dirty = 1,
		obj = false
	},
	meta = {
		__mode = "kv"
	},
	new = set
}