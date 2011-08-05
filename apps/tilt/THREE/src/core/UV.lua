THREE = THREE or {}

THREE.UV = {u = 0, v = 0}
THREE.UV.types = THREE.UV.types or {}
THREE.UV.types[THREE.UV] = true
setmetatable(THREE.UV, THREE.UV)
THREE.UV.__index = THREE.UV

THREE.UV.__call = function(_, t)
	
    local a = {}
    
    --print(t.u,t.v)
    
	a.u = t.u or 0
	a.v = t.v or 0
	
    setmetatable(a, THREE.UV)
    
	return a
    
end

function THREE.UV:set (u, v)
	self.u = u
	self.v = v

	return self
end

function THREE.UV:copy(uv)
	self:set(uv.u, uv.v)
	return self
end

--[[debug
function THREE.UV:print ()
	print(self.u, self.v)
end

myColor = THREE.UV{u = 5, v = 6}

myColor:print()

myUV = THREE.UV{}

myUV:copy(myColor)

myUV:print()

myUV2 = myColor:set(1, 4)

myColor:print()

myUV2:print()]]
