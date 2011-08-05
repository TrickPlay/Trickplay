THREE = THREE or {}
THREE.ParticleCanvasMaterial=table.copy(THREE.Material)
THREE.ParticleCanvasMaterial.types = THREE.ParticleCanvasMaterial.types or {}
THREE.ParticleCanvasMaterial.types[THREE.ParticleCanvasMaterial] = true
setmetatable(THREE.ParticleCanvasMaterial, THREE.ParticleCanvasMaterial)
THREE.ParticleCanvasMaterial.__index=THREE.ParticleCanvasMaterial
THREE.ParticleCanvasMaterial.__call=function(self, params)
	local m = THREE.Material()
	local parameters = params or {}
	m.color = parameters.color and THREE.Color( parameters.color ) or THREE.Color( 0xffffff )
	m.program = parameters.program and parameters.program or function ( context, color ) end;
	return m
end
