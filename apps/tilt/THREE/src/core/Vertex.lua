THREE = THREE or {}
THREE.Vertex = {}
THREE.Vertex.types = THREE.Vertex.types or {}
THREE.Vertex.types[THREE.Vertex] = true
THREE.Vertex.__index = THREE.Vertex
setmetatable(THREE.Vertex,THREE.Vertex)


--Constructor for Vertex
THREE.Vertex.__call = function (_, position) 
	
	local v = {}
  	setmetatable(v, THREE.Vertex)
	v.position = position
   	return v

end

