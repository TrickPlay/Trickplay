--[[

NewClass = Class {
	extends = BaseClass,
	static = {},
	shared = {},
	public = {},
	meta = {},
	new = function() end
}

--]]
local instsOf = {}
local metaOf, nameOf, classOf, newOf, extsnOf, sharedOf =
	table.weak(), table.weak(), table.weak(), table.weak(), table.weak(), table.weak()
local noop = function() end

local newclass = function(this,def)
	nameOf[this] = "(local class)"
	table.merge(this,def.static)
	local public, make, new = def.public, table.new
	sharedOf[this] = def.shared
	
	if def.extends then
		extsnOf[this] = def.extends
		make = extsnOf[this]
		new = newOf[extsnOf[this]]
		if sharedOf[this] and sharedOf[extsnOf[this]] then
			setmetatable(sharedOf[this],{__index = sharedOf[extsnOf[this]]})
		end
	end
	
	new = def.new or new or noop
	newOf[this] = new
	
	local mt = def.meta or {}
	mt.__index = mt.__index or sharedOf[this] or nil
	table.merge(mt,metaOf[extsnOf[this]],false,true)
	metaOf[this] = mt
	local insts = table.weak()
	instsOf[this] = insts
	
	setmetatable(this,{
		__index = nameOf[extsnOf[this]] and extsnOf[this] or sharedOf[classOf[this]] or nil,
		__call = function(_,...)
			local i = make()
			classOf[i] = this
			insts[i] = true
			table.merge(i,public)
			setmetatable(type(i) == 'table' and i or i.extra,mt)
			new(i,...)
			return i
		end
	})
	
	return this
end

local echo = function(t)
	return type(t) == 'string' and '"' .. t .. '"' or nameOf[t]
		or (nameOf[classOf[t]] and tostring(t) .. " (" .. nameOf[classOf[t]] .. ")")
		or tostring(t) .. (type(t) == 'userdata' and " (" .. t.type .. ")" or "")
end

local dumped
local function dump(t,i)
	i = (i or "") .. "\t     "
	if dumped[t] then
		print(i .. "* RECURSION *")
		return
	end
	dumped[t] = true
	print(i .. '{')
	for k,v in pairs(type(t) == 'table' and t or t.extra) do
		print(i .. "  " .. echo(k) .. " = " .. echo(v))
		if type(v) == 'table' or type(v) == 'userdata' and not nameOf[v] then
			dump(v,i)
		end
	end
	print(i .. '}')
end

getmetatable(_G).__newindex = function(t,k,v)
	rawset(t,k,v)
	if nameOf[v] then
		nameOf[v] = k
	end
end

local c = {}
classOf[c] = c

Class = newclass(c,{
	static = {
		of = function(_,i)
			return classOf[i]
		end,
		echo = function(_,i)
			return echo(i)
		end,
		dump = function(_,t)
			print(echo(t))
			if type(t) == 'table' or type(t) == 'userdata' then
				dumped = {}
				dump(t)
			end
		end,
		shared = function(_,i,k)
			return (sharedOf[classOf[i]] or table.hole)[k]
		end,
		meta = function(_,i,k)
			return (metaOf[classOf[i]] or table.hole)[k]
		end
	},
	shared = {
		is = function(self,i)
			return instsOf[self][i] or false
		end,
		each = function(self,func)
			for k,_ in pairs(instsOf[self]) do
				func(k)
			end
		end,
		extends = function(self)
			return extsnOf[self]
		end,
		count = function(self)
			local n = 1
			for k in pairs(instsOf[self]) do
				n = n+1
			end
			return n
		end,
		insts = function(self)
			return instsOf[self]
		end
	},
	new = newclass
})

instsOf[c][c] = true