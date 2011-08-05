THREE = THREE or {}
THREE.Face3 = {}
THREE.Face3.types = THREE.Face3.types or {}
THREE.Face3.types[THREE.Face3] = true
THREE.Face3.__index = THREE.Face3
setmetatable(THREE.Face3,THREE.Face3)

--Constructor for Face3
THREE.Face3.__call = function (_, t) 
	
	local f3 = {}
  	setmetatable(f3, THREE.Face3)
	f3.a = t.a
	f3.b = t.b
	f3.c = t.c

	if getmetatable(t.normal) and setmetatable(t.normal).types[THREE.Vector3] then
		f3.normal = t.normal
		f3.vertexNormals = {}
	else
		f3.normal = THREE.Vector3()
		f3.vertexNormals = t.normal
	end

	if getmetatable(t.color) and setmetatable(t.color).types[THREE.Color] then
		f3.color = t.color
		f3.vertexColors = {}
	else
		f3.color = THREE.Color()
		f3.vertexColors = t.color
	end
	
	f3.vertexTangents = {}
	
	if type(t.materials) == "table" then
		f3.materials = t.materials
	else
		f3.materials = {t.materials}
	end

	f3.centroid = THREE.Vector3()	
	
   	return f3

end

