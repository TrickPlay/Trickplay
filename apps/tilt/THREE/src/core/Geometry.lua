THREE = THREE or {}
THREE.Geometry = {}
THREE.Geometry.types = THREE.Geometry.types or {}
THREE.Geometry.types[THREE.Geometry] = true
THREE.GeometryIdCounter=0
setmetatable(THREE.Geometry,THREE.Geometry)
THREE.Geometry.__index = THREE.Geometry

THREE.Geometry.__call = function (_, t) 
	local g={}
	setmetatable(g, THREE.Geometry)
	g.id="Geometry"..THREE.GeometryIdCounter
	THREE.GeometryIdCounter = THREE.GeometryIdCounter+1
	g.vertices={}
	g.colors={}
	g.faces={}
	g.edges={}
	g.faceUvs={}
	g.faceVertexUvs={}
	g.morphTargets={}
	g.morphColors={}
	g.skinWeights={}
	g.skinIndices={}
	g.hasTangents=false
	return g
end

function THREE.Geometry:computeCentroids()
	for k,v in pairs(self.faces) do
		v.centroid:set(0,0,0)
		if (getmetatable(v).types[THREE.Face3]) then
			v.centroid:addSelf(self.vertices[v.a].position)
			v.centroid:addSelf(self.vertices[v.b].position)
			v.centroid:addSelf(self.vertices[v.c].position)
			v.centroid:divideScalar(3)
		elseif (getmetatable(v).types[THREE.Face4]) then
			v.centroid:addSelf(self.vertices[v.a].position)
			v.centroid:addSelf(self.vertices[v.b].position)
			v.centroid:addSelf(self.vertices[v.c].position)
			v.centroid:addSelf(self.vertices[v.d].position)
			v.centroid:divideScalar(4)
		end
	end
end

function THREE.Geometry:computeFaceNormals(useVertexNormals)
	local cb=THREE.Vector3()
	local ab=THREE.Vector3()
	for k,v in pairs(self.faces) do
		if (useVertexNormals and v.vertexNormals) then
			cb:set(0,0,0)
			for l,w in pairs(v.vertexNormals) do
				cb:addSelf(w.vertexNormals[l])
			end
			cb:divideScalar(3)
			if (not cb:isZero()) then
				cb:normalize()
			end
			v.normal:copy(cb)
		else
			local vA = self.vertices[v.a]
			local vB = self.vertices[v.b]
			local vC = self.vertices[v.c]
			cb:sub(vC.position, vB.position)
			ab:sub(vA.position, vB.position)
			cb:crossSelf(ab)
			if(not cb:isZero()) then
				cb:normalize()
			end
			v.normal:copy(cb)
		end
	end
end

function THREE.Geometry:computeVertexNormals()
	local vertices
	if (rawget(self,"__tmpVertices") == nil) then
		self.__tmpVertices = {}
		vertices = self.__tmpVertices
		for k,v in pairs(self.vertices) do
			vertices[k] = THREE.Vector3()
		end
		for k,v in pairs(self.faces) do
			if (getmetatable(v).types[THREE.Face3]) then
				v.vertexNormals={}
				for i=0,2 do
					v.vertexNormals[i]=THREE.Vector3()
				end
			elseif (getmetatable(v).types[THREE.Face4]) then
				v.vertexNormals={}
				for i=0,3 do
					v.vertexNormals[i]=THREE.Vector3()
					
				end
			end
		end
	else
		vertices=self.__tmpVertices
		for k,v in pairs(self.vertices) do
			vertices[k]:set(0,0,0)
		end
	end
	for k,v in pairs(self.faces) do
		if (getmetatable(v).types[THREE.Face3]) then
			vertices[v.a]:addSelf(v.normal)
			vertices[v.b]:addSelf(v.normal)
			vertices[v.c]:addSelf(v.normal)
		elseif (getmetatable(v).types[THREE.Face4]) then
			vertices[v.a]:addSelf(v.normal)
			vertices[v.b]:addSelf(v.normal)
			vertices[v.c]:addSelf(v.normal)
			vertices[v.d]:addSelf(v.normal)
		end
	end
	for k,v in pairs(self.vertices) do
		vertices[k]:normalize()
	end
	for k,v in pairs(self.faces) do
		if (getmetatable(v).types[THREE.Face3]) then
			v.vertexNormals[0]:copy(vertices[v.a])
			v.vertexNormals[1]:copy(vertices[v.b])
			v.vertexNormals[2]:copy(vertices[v.c])
		elseif (getmetatable(v).types[THREE.Face4]) then
			v.vertexNormals[0]:copy(vertices[v.a])
			v.vertexNormals[1]:copy(vertices[v.b])
			v.vertexNormals[2]:copy(vertices[v.c])
			v.vertexNormals[3]:copy(vertices[v.d])
		end
	end
end

function THREE.Geometry:computeTangents()
	local tan1={}; local tan2={}
	local sdir=THREE.Vector3(); local tdir = THREE.Vector3()
	local tmp=THREE.Vector3(); local tmp2=THREE.Vector3()
	local n = THREE.Vector3();
	for k,v in pairs(self.vertices) do
		tan1[k]=THREE.Vector3()
		tan2[k]=THREE.Vector3()
	end
	local function handleTriangle(context,a,b,c,ua,ub,uc)
		local vA = context.vertices[ a ].position
		local vB = context.vertices[ b ].position
		local vC = context.vertices[ c ].position
		local uvA = uv[ ua ]
		local uvB = uv[ ub ]
		local uvC = uv[ uc ]

		local x1 = vB.x - vA.x
		local x2 = vC.x - vA.x
		local y1 = vB.y - vA.y
		local y2 = vC.y - vA.y
		local z1 = vB.z - vA.z
		local z2 = vC.z - vA.z

		local s1 = uvB.u - uvA.u
		local s2 = uvC.u - uvA.u
		local t1 = uvB.v - uvA.v
		local t2 = uvC.v - uvA.v
		r = 1.0 / ( s1 * t2 - s2 * t1 )
		sdir:set( ( t2 * x1 - t1 * x2 ) * r,
				  ( t2 * y1 - t1 * y2 ) * r,
				  ( t2 * z1 - t1 * z2 ) * r )
		tdir:set( ( s1 * x2 - s2 * x1 ) * r,
				  ( s1 * y2 - s2 * y1 ) * r,
				  ( s1 * z2 - s2 * z1 ) * r )
		tan1[ a ]:addSelf( sdir )
		tan1[ b ]:addSelf( sdir )
		tan1[ c ]:addSelf( sdir )
		tan2[ a ]:addSelf( tdir )
		tan2[ b ]:addSelf( tdir )
		tan2[ c ]:addSelf( tdir )
	end
	for k,v in pairs(self.faces) do
		uv=self.faceVertexUvs[0][k]
		if (getmetatable(v).types[THREE.Face3]) then
			handleTriangle(self,v.a,v.b,v.c,0,1,2)
		elseif (getmetatable(v).types[THREE.Face4]) then
			handleTriangle(self,v.a,v.b,v.c,0,1,2)
			handleTriangle(self,v.a,v.d,v.c,0,1,3)
		end
	end
	local faceIndex={}
	faceIndex[0]="a"
	faceIndex[1]="b"
	faceIndex[2]="c"
	faceIndex[3]="d"
	for k,v in pairs(self.faces) do
		for l,w in pairs(v.vertexNormals) do
			n:copy(v.vertexNormals[l])
			local vertexIndex=v[faceIndex[l]]
			local t=tan1[vertexIndex]
			tmp:copy(t)
			tmp:subSelf(n:multiplyScalar(n:dot(t))):normalize()
			tmp2:cross(v.vertexNormals[l], t)
			local test=tmp2:dot(tan2[vertexIndex])
			w = test<0.0 and -1.0 or 1.0
			v.vertexTangents[l]=THREE.Vector4(tmp.x,tmp.y,tmp.z,w)
		end
	end
	self.hasTangents=true
end

function THREE.Geometry:computeBoundingBox()
	local vertex
	local empty=true
	for k,v in pairs(self.vertices) do
		empty=false
		break
	end
	if (not empty) then
		self.boundingBox={["x"]={}, ["y"]={}, ["z"]={}}
		self.boundingBox.x[0]=self.vertices[0].position.x
		self.boundingBox.x[1]=self.vertices[0].position.x
		self.boundingBox.y[0]=self.vertices[0].position.y
		self.boundingBox.y[1]=self.vertices[0].position.y
		self.boundingBox.z[0]=self.vertices[0].position.z
		self.boundingBox.z[1]=self.vertices[0].position.z
		for k,v in pairs(self.vertices) do
			if (v.position.x<self.boundingBox.x[0]) then
				self.boundingBox.x[0]=v.position.x
			elseif (v.position.x>self.boundingBox.x[1]) then
				self.boundingBox.x[1]=v.position.x
			end
			if (v.position.y<self.boundingBox.y[0]) then
				self.boundingBox.y[0]=v.position.y
			elseif (v.position.y>self.boundingBox.y[1]) then
				self.boundingBox.y[1]=v.position.y
			end
			if (v.position.z<self.boundingBox.z[0]) then
				self.boundingBox.z[0]=v.position.z
			elseif (v.position.z>self.boundingBox.z[1]) then
				self.boundingBox.z[1]=v.position.z
			end
		end
	end
end

function THREE.Geometry:computeBoundingSphere()
	local radius=0
	for k,v in pairs(self.vertices) do
		radius = math.max(radius, v.position:length())
	end
	self.boundingSphere={["radius"]=radius}
end

function THREE.Geometry:computeEdgeFaces()
	local function push(t,e)
		if (not t[0]) then t[0]=e
		else t[#t+1]=e end
	end
	local function edge_hash(a,b)
		return math.min(a,b) .. "_" .. math.max(a,b)
	end
	local function addToMap(map, hash, i)
		if (not map[hash]) then
			map[hash]={set={}, array={}}
			map[hash].set[i]=1
			push(map[hash].array,i)
		else
			if (not map[hash].set[i]) then
				map[hash].set[i]=i
				push(map[hash].array,i)
			end
		end
	end
	local hash
	local vfMap={}
	for k,v in pairs(self.faces) do
		if (getmetatable(v).types[THREE.Face3]) then
			hash = edge_hash(v.a, v.b)
			addToMap(vfMap, hash, k)
			hash=edge_hash(v.b,v.c)
			addToMap(vfMap, hash, k)
			hash=edge_hash(v.a,v.c)
			addToMap(vfMap, hash, k)
		elseif(getmetatable(v).types[THREE.Face4]) then
			hash = edge_hash(v.b, v.d)
			addToMap(vfMap, hash, k)
			hash=edge_hash(v.a,v.b)
			addToMap(vfMap, hash, k)
			hash=edge_hash(v.a,v.d)
			addToMap(vfMap, hash, k)
			hash=edge_hash(v.b,v.c)
			addToMap(vfMap, hash, k)
			hash=edge_hash(v.c,v.d)
			addToMap(vfMap, hash, k)
		end
	end
	for k,v in pairs(self.edges) do
		local v1=v.vertexIndices[0]
		local v2=v.vertexIndices[1]
		v.faceIndices=vfMap[edge_hash(v1,v2)].array
		for l,w in pairs(v.faceIndices) do
			local faceIndex = edge.faceIndices[l]
			push(edges.faces, self.faces[faceIndex])
		end
	end
end

