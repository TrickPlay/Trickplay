local reset = {extra = {}, position = {}, scale = {1,1},anchor_point = {},
		x_rotation = {}, y_rotation = {}, z_rotation = {}}
local free = {}

Layer = Class {
	extends = function()
		return table.remove(free) or Group()
	end,
	shared = {
		free = function(self)
			self:set(reset)
			self:unparent()
			for _,v in pairs(self.children) do
				(v.free or v.unparent)(v)
			end
			table.insert(free,self)
		end
	},
	new = function(self,t)
		table.merge(self,t)
	end
}