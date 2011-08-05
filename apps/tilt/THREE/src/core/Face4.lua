THREE = THREE or {}
THREE.Face4 = {}
THREE.Face4.types = THREE.Face4.types or {}
THREE.Face4.types[THREE.Face4] = true
THREE.Face4.__index = THREE.Face4
setmetatable(THREE.Face4,THREE.Face4)


--Constructor for Face4
THREE.Face4.__call = function (_, t) 
	
	local f4 = {}	
  	setmetatable(f4, THREE.Face4)
	f4.a = t.a
	f4.b = t.b
	f4.c = t.c
	f4.d = t.d
	if t.normal and getmetatable(t.normal) and getmetatable(t.normal).types[THREE.Vector3] then
		f4.normal = t.normal
		f4.vertexNormals = {}
	else
		f4.normal = THREE.Vector3()
		f4.vertexNormals = t.normal
	end

	if t.color and getmetatable(t.color) and getmetatable(t.color).types[THREE.Color] then
		f4.color = t.color
		f4.vertexColors = {}
	else
		f4.color = THREE.Color()
		f4.vertexColors = t.color
	end
	
	f4.vertexTangents = {}
	
	if type(t.materials) == "table" then
		f4.materials = t.materials
	else
		f4.materials = {t.materials}
	end

	f4.centroid = THREE.Vector3()	

   	return f4

end

