THREE = THREE or {}

THREE.Light = table.copy(THREE.Object3D)
THREE.Light.types = THREE.Light.types or {}
THREE.Light.types[THREE.Light] = true
setmetatable(THREE.Light, THREE.Light)

THREE.Light.__index = THREE.Light

THREE.Light.__call = function(_, hex)

	local l = THREE.Object3D()
	setmetatable(l, THREE.Light)
	
	l.color = THREE.Color( hex )
	--print(l.color)
	return l
end

