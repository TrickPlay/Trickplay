THREE=THREE or {}

THREE.NoShading = 0
THREE.FlatShading = 1
THREE.SmoothShading = 2

THREE.NoColors = 0
THREE.FaceColors = 1
THREE.VertexColors = 2

THREE.NormalBlending = 0
THREE.AdditiveBlending = 1
THREE.SubtractiveBlending = 2
THREE.MultiplyBlending = 3
THREE.AdditiveAlphaBlending = 4

THREE.MaterialCounter={value=0}

THREE.Material={}
THREE.Material.types = THREE.Material.types or {}
THREE.Material.types[THREE.Material] = true
setmetatable(THREE.Material, THREE.Material)
THREE.Material.__index=THREE.Material
THREE.Material.__call=function(self, param)
	local m = {}
	setmetatable(m,THREE.Material)
	m.id = THREE.MaterialCounter.value
	THREE.MaterialCounter.value=THREE.MaterialCounter.value+1
	local parameters = param or {}
	m.opacity = parameters.opacity and parameters.opacity or 1
	m.transparent = parameters.transparent and parameters.transparent or false
	m.blending = parameters.blending and parameters.blending or THREE.NormalBlending
	m.depthTest = parameters.depthTest and parameters.depthTest or true

	m.polygonOffset = parameters.polygonOffset and parameters.polygonOffset or false
	m.polygonOffsetFactor = parameters.polygonOffsetFactor and parameters.polygonOffsetFactor or 0
	m.polygonOffsetUnits = parameters.polygonOffsetUnits and parameters.polygonOffsetUnits or 0
	return m
end

m= THREE.Material()
