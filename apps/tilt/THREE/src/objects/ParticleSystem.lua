THREE = THREE or {}

THREE.ParticleSystem = table.copy(THREE.Object3D)
THREE.ParticleSystem.types = THREE.ParticleSystem.types or {}
THREE.ParticleSystem.types[THREE.ParticleSystem] = true
setmetatable(THREE.ParticleSystem, THREE.ParticleSystem)
THREE.ParticleSystem.__index = THREE.ParticleSystem

THREE.ParticleSystem.__call = function(_, geo, mat)
	local a = THREE.Object3D()
	setmetatable(a, THREE.ParticleSystem)
	isArray = true
	if (type(mat)=="table") then
		for k,v in pairs(mat) do
			if (type(k)~="number") then isArray=false end
		end
	else
		isArray=false
	end
	a.materials = isArray and mat or {mat}
	a.geometry = geo
	a.sortParticles = false

	return a
end
