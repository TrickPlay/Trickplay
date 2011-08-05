THREE = THREE or {}
THREE.CubeReflectionMapping = {}
THREE.CubeRefractionMapping = {}
THREE.LatitudeReflectionMapping = {}
THREE.LatitudeRefractionMapping = {}
THREE.SphericalReflectionMapping = {}
THREE.SphericalRefractionMapping = {}
THREE.UVMapping = {}

THREE.CubeReflectionMapping.types = THREE.CubeReflectionMapping.types or {}
THREE.CubeRefractionMapping.types = THREE.CubeRefractionMapping.types or {}
THREE.LatitudeReflectionMapping.types = THREE.LatitudeReflectionMapping.types or {}
THREE.LatitudeRefractionMapping.types = THREE.LatitudeRefractionMapping.types or {}
THREE.SphericalReflectionMapping.types = THREE.SphericalReflectionMapping.types or {}
THREE.SphericalRefractionMapping.types = THREE.SphericalRefractionMapping.types or {}
THREE.UVMapping.types = THREE.UVMapping.types or {}

THREE.CubeReflectionMapping.types[THREE.CubeReflectionMapping] = true
THREE.CubeRefractionMapping.types[THREE.CubeRefractionMapping] = true
THREE.LatitudeReflectionMapping.types[THREE.LatitudeReflectionMapping] = true
THREE.LatitudeRefractionMapping.types[THREE.LatitudeRefractionMapping] = true
THREE.SphericalReflectionMapping.types[THREE.SphericalReflectionMapping] = true
THREE.SphericalRefractionMapping.types[THREE.SphericalRefractionMapping] = true
THREE.UVMapping.types[THREE.UVMapping] = true

setmetatable (THREE.CubeReflectionMapping, THREE.CubeReflectionMapping)
setmetatable (THREE.CubeRefractionMapping,THREE.CubeRefractionMapping)
setmetatable (THREE.LatitudeReflectionMapping,THREE.LatitudeReflectionMapping)
setmetatable (THREE.LatitudeRefractionMapping,THREE.LatitudeRefractionMapping)
setmetatable (THREE.SphericalReflectionMapping,THREE.SphericalReflectionMapping)
setmetatable (THREE.SphericalRefractionMapping,THREE.SphericalRefractionMapping)
setmetatable (THREE.UVMapping,THREE.UVMapping)

THREE.CubeReflectionMapping.__index = THREE.CubeReflectionMapping
THREE.CubeRefractionMapping.__index = THREE.CubeRefractionMapping
THREE.LatitudeReflectionMapping.__index = THREE.LatitudeReflectionMapping
THREE.LatitudeRefractionMapping.__index = THREE.LatitudeRefractionMapping
THREE.SphericalReflectionMapping.__index = THREE.SphericalReflectionMapping
THREE.SphericalRefractionMapping.__index = THREE.SphericalRefractionMapping
THREE.UVMapping.__index = THREE.UVMapping

THREE.CubeReflectionMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.CubeReflectionMapping)
	return t
end

THREE.CubeRefractionMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.CubeRefractionMapping)
	return t
end

THREE.LatitudeReflectionMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.LatitudeReflectionMapping)
	return t
end

THREE.LatitudeRefractionMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.LatitudeRefractionMapping)
	return t
end

THREE.SphericalReflectionMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.SphericalReflectionMapping)
	return t
end

THREE.SphericalRefractionMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.SphericalRefractionMapping)
	return t
end

THREE.UVMapping.__call = function ()
	local t={}
	setmetatable(t, THREE.UVMapping)
	return t
end
