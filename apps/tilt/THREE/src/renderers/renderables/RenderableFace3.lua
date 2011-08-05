THREE = THREE or {}
THREE.RenderableFace3 = {}
THREE.RenderableFace3.types = THREE.RenderableFace3.types or {}
THREE.RenderableFace3.types[THREE.RenderableFace3] = true
setmetatable(THREE.RenderableFace3,THREE.RenderableFace3)
THREE.RenderableFace3.__index = THREE.RenderableFace3
THREE.RenderableFace3.__call = function ()
	local r={}
	setmetatable(r,THREE.RenderableFace3)
	r.v1=THREE.RenderableVertex()
	r.v2=THREE.RenderableVertex()
	r.v3=THREE.RenderableVertex()
	r.centroidWorld = THREE.Vector3();
	r.centroidScreen = THREE.Vector3();
	r.normalWorld = THREE.Vector3();
	r.vertexNormalsWorld = {[0]=THREE.Vector3(), [1]=THREE.Vector3(), [2]=THREE.Vector3()}
	r.overdraw = false;
	r.uvs = {}
	return r
end 

r=THREE.RenderableFace3()
