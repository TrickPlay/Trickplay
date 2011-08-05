THREE = THREE or {}
THREE.ParticleBasicMaterial=table.copy(THREE.Material)
THREE.ParticleBasicMaterial.types = THREE.ParticleBasicMaterial.types or {}
THREE.ParticleBasicMaterial.types[THREE.ParticleBasicMaterial] = true
setmetatable(THREE.ParticleBasicMaterial, THREE.ParticleBasicMaterial)
THREE.ParticleBasicMaterial.__index=THREE.ParticleBasicMaterial
THREE.ParticleBasicMaterial.__call=function(self, params)
	local m = THREE.Material()
	local parameters = params or {}
	m.color = parameters.color and THREE.Color( parameters.color ) or THREE.Color( 0xffffff )
	m.map = parameters.map and parameters.map or nil
	m.size = parameters.size and parameters.size or 1
	m.sizeAttenuation = parameters.sizeAttenuation and parameters.sizeAttenuation or true
	m.vertexColors = parameters.vertexColors and parameters.vertexColors or false
	return m
end
