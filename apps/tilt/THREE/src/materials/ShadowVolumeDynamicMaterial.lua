THREE = THREE or {}
THREE.ShadowVolumeDynamicMaterial = table.copy(THREE.Material)
THREE.ShadowVolumeDynamicMaterial.types = THREE.ShadowVolumeDynamicMaterial.types or {}
THREE.ShadowVolumeDynamicMaterial.types[THREE.ShadowVolumeDynamicMaterial] = true
THREE.ShadowVolumeDynamicMaterial.__index = THREE.ShadowVolumeDynamicMaterial
setmetatable(THREE.ShadowVolumeDynamicMaterial, THREE.ShadowVolumeDynamicMaterial)

THREE.ShadowVolumeDynamicMaterial.__call = function(_, parameters)

	local s = THREE.Material(parameters)
	setmetatable(s, THREE.ShadowVolumeDynamicMaterial)

	parameters = parameters or {}
	
	if parameters.color ~= nil then
		s.color = THREE.Color(parameter.color)
	else 
		s.color = THREE.Color(0xffffff)
	end

	if parameters.map ~= nil then
		s.map = parameters.map
	else
		s.map = -1
	end

	if parameters.lightMap ~= nil then
		s.lightMap = parameters.lightMap
	else
		s.lightMap = -1
	end

	if parameters.envMap ~= nil then
		s.envMap = parameters.envMap
	else
		s.envMap = -1
	end

	if parameters.combine ~= nil then
		s.combine = parameters.combine
	else
		s.combine = THREE.MultiplyOperation
	end

	if parameters.reflectivity ~= nil then
		s.reflectivity = parameters.reflectivity
	else
		s.reflectivity = 1
	end

	if parameters.refractionRatio ~= nil then
		s.refractionRatio = parameters.refractionRatio
	else
		s.refractionRatio = 0.98
	end

	if parameters.shading ~= nil then
		s.shading = parameters.shading
	else
		s.shading = THREE.SmoothShading
	end

	if parameters.wireframe ~= nil then
		s.wireframe = parameters.wireframe
	else
		s.wireframe = false
	end

	if parameters.wireframeLinewidth ~= nil then
		s.wireframeLinewidth = parameters.wireframeLinewidth
	else
		s.wireframeLinewidth = 1
	end

	if parameters.wireframeLinecap ~= nil then
		s.wireframeLinecap = parameters.wireframeLinecap
	else
		s.wireframeLinecap = 'round'
	end

	if parameters.wireframeLinejoin ~= nil then
		s.wireframeLinejoin = parameters.wireframeLinejoin
	else
		s.wireframeLinejoin = 'round'
	end

	if parameters.vertexColors ~= nil then
		s.vertexColors = parameters.vertexColors
	else
		s.vertexColors = false
	end

	if parameters.skinning ~= nil then
		s.skinning = parameters.skinning
	else
		s.skinning = false
	end

	if parameters.morphTargets ~= nil then
		s.morphTargets = parameters.morphTargets
	else
		s.morphTargets = false
	end

	return s

end


