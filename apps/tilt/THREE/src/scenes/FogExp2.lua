THREE = THREE or {}
THREE.FogExp2 = {}
THREE.FogExp2.types = THREE.FogExp2.types or {}
THREE.FogExp2.types[THREE.FogExp2] = true
setmetatable(THREE.FogExp2, THREE.FogExp2)

THREE.FogExp2.__index = THREE.FogExp2

THREE.FogExp2.__call = function(_, hex,density)
	local f = {}
	setmetatable(f, THREE.FogExp2)
	f.types = {}
	f.types[FogExp2]=true
	f.color = THREE.Color(hex)
	f.density = density and density or .00025
	print("f.density = ",f.density)
	return f
end

