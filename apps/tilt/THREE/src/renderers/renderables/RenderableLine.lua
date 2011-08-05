THREE = THREE or {}
THREE.RenderableLine = {}
THREE.RenderableLine.types = THREE.RenderableLine.types or {}
THREE.RenderableLine.types[THREE.RenderableLine] = true
setmetatable(THREE.RenderableLine,THREE.RenderableLine)
THREE.RenderableLine.__index = THREE.RenderableLine
THREE.RenderableLine.__call = function ()
	local r={}
	setmetatable(r,THREE.RenderableLine)
	r.v1=THREE.RenderableVertex()
	r.v2=THREE.RenderableVertex()
	return r
end 
