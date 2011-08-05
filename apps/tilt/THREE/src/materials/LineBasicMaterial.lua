THREE = THREE or {}
THREE.LineBasicMaterial=table.copy(THREE.Material)
THREE.LineBasicMaterial.types = THREE.LineBasicMaterial.types or {}
THREE.LineBasicMaterial.types[THREE.LineBasicMaterial] = true
setmetatable(THREE.LineBasicMaterial, THREE.LineBasicMaterial)
THREE.LineBasicMaterial.__index=THREE.LineBasicMaterial
THREE.LineBasicMaterial.__call=function(self, params)
	local m = THREE.Material()
	local parameters = params or {}
	m.color = parameters.color and THREE.Color( parameters.color ) or THREE.Color( 0xffffff )
	m.linewidth = parameters.linewidth and parameters.linewidth or 1
	m.linecap = parameters.linecap and parameters.linecap or 'round'
	m.linejoin = parameters.linejoin and parameters.linejoin or 'round'
	m.vertexColors = parameters.vertexColors and parameters.vertexColors or false
	return m
end

