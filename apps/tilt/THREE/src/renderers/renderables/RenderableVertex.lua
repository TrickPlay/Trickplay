THREE = THREE or {}
THREE.RenderableVertex = {}
THREE.RenderableVertex.types = THREE.RenderableVertex.types or {}
THREE.RenderableVertex.types[THREE.RenderableVertex] = true
setmetatable(THREE.RenderableVertex,THREE.RenderableVertex)
THREE.RenderableVertex.__index = THREE.RenderableVertex
THREE.RenderableVertex.__call = function ()
	local r={}
	setmetatable(r,THREE.RenderableVertex)
	r.positionWorld=THREE.Vector3()
	r.positionScreen=THREE.Vector4()
	r.visable=true
	return r
end 

function THREE.RenderableVertex:copy(vertex)
	self.positionWorld:copy(vertex.positionWorld)
	self.positionScreen:copy(vertex.positionScreen)
end
