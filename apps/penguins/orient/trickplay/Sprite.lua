local reset = {extra = {}, position = {}, scale = {1,1}, anchor_point = {},
		x_rotation = {}, y_rotation = {}, z_rotation = {}}
local index, free = {}, {}
local clones = table.weak()

local _Image, _Clone = Image, Clone

local group = Group{name = "Sprite texture pool"}
screen:add(group)
group:hide()

Sprite = Class {
	extends = function()
		return _Clone()--table.remove(free) or _Clone()
	end,
	static = {
		path = "assets/",
		index = index,
		load = function(self,file)
			if not index[file] then
				index[file] = _Image{src = self.path .. file, name = file}
				group:add(index[file])
			end
			return index[file]
		end,
		clones = clones
	},
	shared = {
		free = function(self)
			self.source = nil
			self.mask = nil
			self:set(reset)
			self:unparent()
			--[[if self.w == 0 and self.h == 0 then
				self:set(reset)
				table.insert(free,self)
			else
				print(self.w,self.h)
			end]]
		end
	},
	public = {
		mask = false
	},
	meta = {
		__index = function(self,k)
			self = clones[self]
			if k == 'src' then
				return self.source.src
			else
				return Class:shared(self,k)
			end
		end,
		__newindex = function(self,k,v)
			if k == 'src' then
				clones[self].source = index[v] or Sprite:load(v)
			else
				rawset(self,k,v)
			end
		end
	},
	new = function(self,t)
		clones[self.extra] = self
		if t then
			--[[if index[t.src] then
				self.size = index[t.src].size
			end]]
			table.merge(self,t)
		end
	end
}