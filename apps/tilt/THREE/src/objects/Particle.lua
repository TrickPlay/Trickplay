THREE = THREE or {}

THREE.Particle = table.copy(THREE.Object3D)
THREE.Particle.types = THREE.Particle.types or {}
THREE.Particle.types[THREE.Particle] = true
setmetatable(THREE.Particle, THREE.Particle)
THREE.Particle.__index = THREE.Particle

THREE.Particle.__call = function(_, mat)
	local a = THREE.Object3D()
	setmetatable(a, THREE.Particle)
	isArray = true
	if (type(mat)=="table") then
		for k,v in pairs(mat) do
			if (type(k)~="number") then isArray=false end
		end
	else
		isArray=false
	end
	
	a.materials = isArray and mat or {[0] = mat}
	return a
end
