CollisionLayer = Class {
	extends = Event,
	public = {
		touches = false,
		trigger = function(self)
			for l,f in pairs(self.listeners) do
				for i,t in pairs(self.touches) do
					for k,v in pairs(t.listeners) do
						if l ~= k and BBox.intersects(l,k) then
							if not f(l,k,t) then v(k,l,self) end
						end
					end
				end
			end
		end
	},
	new = function(self,t)
		self.name = "onCollision"
		self.touches = table.weak(t or {})
	end
}