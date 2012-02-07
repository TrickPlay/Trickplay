(...):load("Class")

local v

MetaBranch = Class {
	new = function(self,t)
		for k,v in ipairs(t) do
			rawset(self,k,v)
		end
	end,
	meta = {
		__index = function(self,k)
			v = nil
			for _,j in ipairs(self) do
				v = v or j[k]
			end
			return v
		end,
		__newindex = function(self,k,v)
			for _,j in ipairs(self) do
				if j[k] then
					j[k] = v
					return
				end
			end
			rawset(self,k,v)
		end
	}
}