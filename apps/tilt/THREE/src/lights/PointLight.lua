THREE = THREE or {}

THREE.PointLight = table.copy(THREE.Light)
THREE.PointLight.types = THREE.PointLight.types or {}
THREE.PointLight.types[THREE.PointLight] = true
setmetatable(THREE.PointLight, THREE.PointLight)

THREE.Light.__index = THREE.Light

THREE.PointLight.__call = function(_, hex, intensity, distance)
	local pl = THREE.Light(hex)
	setmetatable(pl, THREE.PointLight)
	pl.position = THREE.Vector3()
	pl.intensity = intensity or 1
	pl.distance = distance or 0
	return pl
end

function THREE.PointLight:print()

	self.position:print()

end

