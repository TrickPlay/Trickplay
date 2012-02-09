local trans = {'x','y','w','h'}

Rect = Class {
	extends = Shape,
	public = {
		x = 0,
		y = 0,
		w = 0,
		h = 0
	},
	new = function(self,t)
		if t then
			for k,v in ipairs(trans) do
				self[v] = t[k] or t[v] or 0
			end
		end
	end
}