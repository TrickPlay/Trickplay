Event = Class {
	shared = {
		trigger = function() end,
		add = function(self,...)
			for _,v in ipairs(arg) do
				table.insert(self,v)
			end
		end,
		drop = function(self,...)
			for _,v in ipairs(arg) do
				self[v] = nil
			end
		end,
		clear = function(self)
			for k in pairs(self) do
				if type(k) ~= 'string' then
					self[k] = nil
				end
			end
		end
	},
	meta = {
		__call = function(self,...)
			self.trigger(...)
		end,
		__mode = 'k'
	},
	new = function(self,t,k)
		self.trigger = function(...)
			for k,v in pairs(self) do
				if type(k) == 'number' then
					v(...)
				elseif type(k) ~= 'string' then
					v(k,...)
				end
			end
		end
		if indexable(t) then
			if callable(t[k]) then
				self:add(t[k])
			end
			t[k] = self
		end
	end
}