--[[
example = DuckType {
	[type] = 'function', -- first layer is OR
	[indexable.is] = {
		addition = false, -- futher layers are AND
		type = 'thisType',
		'foobar',
		layers = 5,
		[class.of] = Sprite, -- how to handle this?
		[checkable.is] = { -- anything involving a table is an if statement
			'index'
		},
		{ [walkable.is] = true } = { -- also an if statement
			[talkable.is] = true
		},
		function(self) return (getmetatable(self) or table.hole).__call end,
	}
}
--]]

local tk, tv
local noop = function() end
local check

local nb = { -- numeric index
	['nil'] = noop,
	['boolean'] = noop,
	['number'] = noop,
	['string'] = function(k,i) return not not i[k] end,
	['function'] = function(k,i) return k(i) end,
	['table'] = function(t,i) return check(t) end,
	['userdata'] = noop,
	['thread'] = noop,
}
local kb = { -- key index
	['nil'] = noop,
	['boolean'] = rawequal,
	['number'] = rawequal,
	['string'] = rawequal,
	['function'] = function(v,k,i) return v == k(i) end,
	['table'] = function(v,t,i) return v and check(t,i) end,
	['userdata'] = noop,
	['thread'] = noop,
}

check = function(t,i,any)
	any = not not any
	for k,v in pairs(t) do
		tk, tv = type(k), type(v)
		if tk == 'number' or (tk == 'table' and check(k,i)) then
			v = nb[tv](v,i)
		elseif tk == 'string' then
			v = kb[tv](i[k],v,i)
		elseif tk == 'function' then
			v = kb[tv](k(i),v,i)
		else
			v = false
		end
		
		if any and v or not (any or v) then
			return any
		end
	end
	return not any
end

DuckType = Class {
	meta = {
		__call = function(t,i)
			return t:is(i)
		end
	},
	public = {
		is = noop
	},
	new = function(self,t)
		self.is = function(j,i)
			i = i or j
			return check(t,i,true)
		end
	end
}