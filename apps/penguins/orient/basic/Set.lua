local r
local add = function(self,...)
    local arg = table.pack(...)
	for _,v in ipairs(arg) do
		self[v] = true
	end
end

Set = Class {
	shared = {
		add = add,
		drop = function(self,...)
            local arg = table.pack(...)
			for _,v in ipairs(arg) do
				self[v] = nil
			end
		end,
		clear = function(self)
			for k in pairs(self) do
				self[k] = nil
			end
		end
	},
	meta = {
		__add = function(a,b) -- union
			r = Set()
			for k in pairs(a) do
				r[k] = true
			end
			if type(b) == 'table' then
				for k,_ in pairs(b) do
					r[k] = true
				end
			end
			return r
		end,
		__mul = function(a,b) -- intersect
			r = Set()
			if type(b) == 'table' then
				if #b < #a then
					a, b = b, a
				end
				for k in pairs(a) do
					r[k] = b[k]
				end
			end
			return r
		end
	},
	new = add
}
