THREE = THREE or {}
THREE.DirectionalLight = table.copy(THREE.Light)
THREE.DirectionalLight.types = THREE.DirectionalLight.types or {}
THREE.DirectionalLight.types[THREE.DirectionalLight] = true
setmetatable(THREE.DirectionalLight,THREE.DirectionalLight)
THREE.DirectionalLight.__index = THREE.DirectionalLight
THREE.DirectionalLight.__call = function(_,hex,intensity,distance,castShadow, pos)
	dl = THREE.Light(hex)
	setmetatable(dl,THREE.DirectionalLight)
	dl.position = pos or THREE.Vector3(0,1,0)
	dl.intensity = intensity or 1
	dl.distance = distance or 0
	dl.castShadow = castShadow and castShadow or false
	return dl
end
