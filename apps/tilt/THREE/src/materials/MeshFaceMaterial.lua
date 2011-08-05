THREE=THREE or {}
THREE.MeshFaceMaterial={}
THREE.MeshFaceMaterial.types = THREE.MeshFaceMaterial.types or {}
THREE.MeshFaceMaterial.types[THREE.MeshFaceMaterial] = true
setmetatable(THREE.MeshFaceMaterial, THREE.MeshFaceMaterial)
THREE.MeshFaceMaterial.__index = THREE.MeshFaceMaterial
THREE.MeshFaceMaterial.__call = function()
	local m = {}
	setmetatable(m,THREE.MeshFaceMaterial)
	return m
end
