THREE=THREE or {}
THREE.MeshLambertMaterial = table.copy(THREE.Material)
THREE.MeshLambertMaterial.types = THREE.MeshLambertMaterial.types or {}
THREE.MeshLambertMaterial.types[THREE.MeshLambertMaterial] = true
setmetatable(THREE.MeshLambertMaterial,THREE.MeshLambertMaterial)
THREE.MeshLambertMaterial.__index = THREE.MeshLambertMaterial
THREE.MeshLambertMaterial.__call = function(self, parameters)
	local m = THREE.Material(parameters)
	setmetatable(m,THREE.MeshLambertMaterial)
	parameters = parameters or {}
	m.color = parameters.color and THREE.Color(parameters.color) or THREE.Color(0xffffff)
	m.map = parameters.map and parameters.map or nil

	m.lightMap = parameters.lightMap and parameters.lightMap or nil

	m.envMap = parameters.envMap and parameters.envMap or nil
	m.combine = parameters.combine and parameters.combine or THREE.MultiplyOperation
	m.reflectivity = parameters.reflectivity and parameters.reflectivity or 1
	m.refractionRatio = parameters.refractionRatio and parameters.refractionRatio or 0.98

	-- m.enableFog = parameters.enableFog and parameters.enableFog or true

	m.shading = parameters.shading and parameters.shading or THREE.SmoothShading

	m.wireframe = parameters.wireframe and parameters.wireframe or false
	m.wireframeLinewidth = parameters.wireframeLinewidth and parameters.wireframeLinewidth or 1
	m.wireframeLinecap = parameters.wireframeLinecap and parameters.wireframeLinecap or 'round'
	m.wireframeLinejoin = parameters.wireframeLinejoin and parameters.wireframeLinejoin or 'round'

	m.vertexColors = parameters.vertexColors and parameters.vertexColors or false

	m.skinning = parameters.skinning and parameters.skinning or false
	m.morphTargets = parameters.morphTargets and parameters.morphTargets or false
	
	return m
end

