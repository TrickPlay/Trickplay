local tree = {
	common = {
		"table",
	},
	basic = {
		"Class",
		"Set",
		events = {
			"Event",
			"evFrame"
		},
		shapes = {
			"Shapes",
			"Rect",
			"BBox"
		},
		ducktypes = {
			"DuckType",
			"indexable",
			"callable"
		}
	},
	trickplay = {
		"Sprite",
		"FlipSprite",
		"Layer",
	}
}

local index, loaded = {}, {}

local function build(path,t)
	for k,v in pairs(t) do
		if type(v) == 'string' then
			index[v] = path..v..'.lua'
		else
			build(path..k..'/',v)
		end
	end
end

build("",tree)

local orient = setmetatable({
	path = 'orient/'
},{
	__call = function(self)
		dofile(self.path .. index['table'])
		return self
	end
})

local _G__index = getmetatable(_G).__index
getmetatable(_G).__index = function(t,k)
	if index[k] and not loaded[k] then
		dofile(orient.path .. index[k])
		loaded[k] = true
		return _G[k]
	else
		return _G__index(t,k)
	end
end

return orient