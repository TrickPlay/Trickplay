THREE = THREE or {}
THREE.Fog = {}
THREE.Fog.types = THREE.Fog.types or {}
THREE.Fog.types[THREE.Fog] = true
setmetatable(THREE.Fog, THREE.Fog)

THREE.Fog.__index = THREE.Fog

THREE.Fog.__call = function(_, hex,near,far)
	local f = {}
	setmetatable(f, THREE.Fog)
	f.color = THREE.Color(hex)
	f.near = near or 1
	--print("f.near = ",f.near)
	f.far = far or 1000
	--print("f.far = ",f.far)
	return f
end

