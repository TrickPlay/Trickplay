function table.merge(t,s,raw,weak)
	if t and s then
		for k,v in pairs(s) do
			if not weak or t[k] == nil then
				if raw then
					rawset(t,k,v)
				else
					t[k] = v
				end
			end
		end
	end
	return t
end

table.hole = setmetatable({},{
	__index = function() end,
	__newindex = function() end,
	__metatable = false
})

function table.new()
	return {}
end

function table.count(t)
	local n = 1
	for k in pairs(t) do
		n = n+1
	end
	return n
end

function table.clear(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

local weak = {k = {__mode = "k"}, v = {__mode = "v"}, kv = {__mode = "kv"}}
function table.weak(t,type)
	return setmetatable(t or {},weak[type or 'kv'])
end

 --[[ proxies might too convoluted an idea

local orig = table.weak()
local pmt, p = {__index = function(p,k)
	return orig[p][k]
end, __newindex = function()
	print("Cannot write to proxy table.")
end, __metatable = false}

function table.proxy(t)
	p = {}
	orig[p] = t
	return setmetatable(p,pmt)
end

function table.deproxy(p)
	return table.merge(setmetatable(p),orig[p],true)
end

--]]