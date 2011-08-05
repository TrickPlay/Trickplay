THREE = THREE or {}

THREE.Edge = {}
THREE.Edge.types = THREE.Edge.types or {}
setmetatable(THREE.Edge, THREE.Edge)
THREE.Edge.__index = THREE.Edge

THREE.Edge.__call = function(_, t)
	local a = {}
	a.vertices = {t.v1, t.v2}
	a.vertexIndices = {t.vi1, t.vi2}
	a.faces = {}
	a.faceIndices = {}
	setmetatable(a, THREE.Edge)
	return a
end

--[[debug
function THREE.Edge:print ()
	print(self.vertices[1], self.vertices[2], self.vertexIndices[1], self.vertexIndices[2])
end

myColor = THREE.Edge{v1 = 5, v2 = 3.6, vi1 = 3, vi2 = 6}

myColor:print()

myEdge = THREE.Edge{v1 = 3, v2 = 1.62, vi1 = 4, vi2 = 0}

myEdge:print()]]
