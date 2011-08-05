THREE = THREE or {}
THREE.RenderableObject = {}
THREE.RenderableObject.types = THREE.RenderableObject.types or {}
THREE.RenderableObject.types[THREE.RenderableObject] = true
setmetatable(THREE.RenderableObject,THREE.RenderableObject)
THREE.RenderableObject.__index = THREE.RenderableObject
THREE.RenderableObject.__call = function ()
	local r={}
	setmetatable(r,THREE.RenderableObject)
	return r
end 
