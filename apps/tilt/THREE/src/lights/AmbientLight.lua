THREE = THREE or {}
THREE.AmbientLight = table.copy(THREE.Light)
THREE.AmbientLight.types = THREE.AmbientLight.types or {}
THREE.AmbientLight.types[THREE.AmbientLight] = true
setmetatable(THREE.AmbientLight,THREE.AmbientLight)
THREE.Light.__index = THREE.Light
THREE.AmbientLight.__call = function(_,hex)
	al = THREE.Light(hex)
	setmetatable(al,THREE.AmbientLight)
	return al
end

