THREE = THREE or {}
THREE.RenderableFace4 = {}
THREE.RenderableFace4.types = THREE.RenderableFace4.types or {}
THREE.RenderableFace4.types[THREE.RenderableFace4] = true
setmetatable(THREE.RenderableFace4,THREE.RenderableFace4)
THREE.RenderableFace4.__index = THREE.RenderableFace4
THREE.RenderableFace4.__call = function ()
	local r={}
	setmetatable(r,THREE.RenderableFace4)
	r.v1=THREE.RenderableVertex()
	r.v2=THREE.RenderableVertex()
	r.v3=THREE.RenderableVertex()
	r.v4=THREE.RenderableVertex()
	r.centroidWorld = THREE.Vector3();
	r.centroidScreen = THREE.Vector3();
	r.normalWorld = THREE.Vector3();
	r.vertexNormalsWorld = {[0]=THREE.Vector3(), [1]=THREE.Vector3(), [2]=THREE.Vector3(), [3]=THREE.Vector3()}
	r.overdraw = false;
	r.uvs = {}
	return r
end 

r=THREE.RenderableFace4()
