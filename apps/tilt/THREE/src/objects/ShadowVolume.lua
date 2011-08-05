THREE = THREE or {}

THREE.ShadowVolume = table.copy(THREE.Mesh)
THREE.ShadowVolume.types = THREE.ShadowVolume.types or {}
THREE.ShadowVolume.types[THREE.ShadowVolume] = true
THREE.ShadowVolume.__index = THREE.ShadowVolume
setmetatable(THREE.ShadowVolume, THREE.ShadowVolume)

THREE.ShadowVolume.__call = function(_, meshOrGeometry)

	local sv
	if getmetatable(meshOrGeometry).types[THREE.Mesh] then
		sv = THREE.Mesh(meshOrGeometry.geometry, {[0] = THREE.ShadowVolumeDynamicMaterial()})
		setmetatable(sv, THREE.ShadowVolume)
		meshOrGeometry:addChild(sv)
	else
		sv = THREE.Mesh(meshOrGeometry, {[0] = THREE.ShadowVolumeDynamicMaterial()})
		setmetatable(sv, THREE.ShadowVolume)
	end
	sv:calculateShadowVolumeGeometry()
	return sv

end


function THREE.ShadowVolume:calculateShadowVolumeGeometry()
	if self.geometry.edges and length(self.geometry.edges) > 0 then
		local faceA, faceB, faceAIndex, faceBIndex, vertexA, vertexB
		local faceACombination, faceBCombination
		local faceAvertexAIndex faceAvertexBIndex, faceBvertexAIndex, faceAvertexAIndex	= 0

		local vertexOffset = 0
		local vertexOffsetPerFace = {}

		local newGeometry = THREE.Geometry()
		newGeometry.faces = self.geometry.faces
		local faces = newGeometry.faces
		newGeometry.edges = self.geometry.edges 
		local edges = newGeometry.edges

		for k, v in pairs(faces.length) do

			local face = v
		
			push(vertexOffsetPerFace, vertexOffset)
			if getmetatable(face).types[THREE.Face3] then

				vertexOffset = vertexOffset + 3		
		
			else

				vertexOffset = vertexOffset + 4

			end

			face.vertexNormals[0] = face.normal
			face.vertexNormals[1] = face.normal
			face.vertexNormals[2] = face.normal

			if getmetatable(face).types[THREE.Face4] then

				face.vertexNormals[ 3 ] = face.normal

			end

		end

		for k,v in pairs(edges.length) do

			local edge = v

			faceA = edge.faces[ 0 ]
			faceB = edge.faces[ 1 ]
		
			faceAIndex = edge.faceIndices[ 0 ]
			faceBIndex = edge.faceIndices[ 1 ]

			vertexA = edge.vertexIndices[ 0 ]
			vertexB = edge.vertexIndices[ 1 ]
		
			--find combination and processed vertex index (vertices are split up by renderer)

			---------------------------------------------------------------

			if faceA.a == vertexA then
				faceAcombination = "a"
				faceAvertexAIndex = vertexOffsetPerFace[faceAIndex] + 0
			elseif faceA.b == vertexA then
				faceAcombination = "b"
				faceAvertexAIndex = vertexOffsetPerFace[faceAIndex] + 1
			elseif faceA.c == vertexA then
				faceAcombination = "c"
				faceAvertexAIndex = vertexOffsetPerFace[faceAIndex] + 2
			elseif faceA.d == vertexA then
				faceAcombination = "d"
				faceAvertexAIndex = vertexOffsetPerFace[faceAIndex] + 3
			end

			---------------------------------------------------------------

			if faceA.a == vertexB then
				faceAcombination = faceAcombination + "a"
				faceAvertexBIndex = vertexOffsetPerFace[faceAIndex] + 0
			elseif faceA.b == vertexB then
				faceAcombination = faceAcombination + "b"
				faceAvertexBIndex = vertexOffsetPerFace[faceAIndex] + 1
			elseif faceA.c == vertexB then
				faceAcombination = faceAcombination + "c"
				faceAvertexBIndex = vertexOffsetPerFace[faceAIndex] + 2
			elseif faceA.d == vertexB then
				faceAcombination = faceAcombination + "d"
				faceAvertexBIndex = vertexOffsetPerFace[faceAIndex] + 3
			end

			---------------------------------------------------------------

			if faceB.a == vertexA then
				faceBcombination = "a"
				faceBvertexAIndex = vertexOffsetPerFace[faceBIndex] + 0
			elseif faceB.b == vertexA then
				faceBcombination = "b"
				faceBvertexAIndex = vertexOffsetPerFace[faceBIndex] + 1
			elseif faceB.c == vertexA then
				faceBcombination = "c"
				faceBvertexAIndex = vertexOffsetPerFace[faceBIndex] + 2
			elseif faceB.d == vertexA then
				faceBcombination = "d"
				faceBvertexAIndex = vertexOffsetPerFace[faceBIndex] + 3
			end

			---------------------------------------------------------------

			if faceB.a == vertexB then
				faceBcombination = faceBcombination + "a"
				faceBvertexBIndex = vertexOffsetPerFace[faceBIndex] + 0
			elseif faceB.b == vertexB then
				faceBcombination = faceBcombination + "b"
				faceBvertexBIndex = vertexOffsetPerFace[faceBIndex] + 1
			elseif faceB.c == vertexB then
				faceBcombination = faceBcombination + "c"
				faceBvertexBIndex = vertexOffsetPerFace[faceBIndex] + 2
			elseif faceB.d == vertexB then
				faceBcombination = faceBcombination + "d"
				faceBvertexBIndex = vertexOffsetPerFace[faceBIndex] + 3
			end

			if faceACombination == "ac" or faceACombination == "ad" 
			or faceACombination == "ca" or faceACombination == "da" then

				if faceAvertexAIndex > faceAvertexBIndex then
	
					temp = faceAvertexAIndex
					faceAvertexAIndex = faceAvertexBIndex
					faceAvertexBIndex = temp

				end
			else

				if faceAvertexAIndex < faceAvertexBIndex then

					temp = faceAvertexAIndex
					faceAvertexAIndex = faceAvertexBIndex
					faceAvertexBIndex = temp
			
				end

			end

			if faceBCombination == "ac" or faceBCombination == "ad"
			or faceBCombination == "ca" or faceBCombination == "da" then

				if faceBvertexAIndex > faceBvertexBIndex then

					temp = faceBvertexAIndex
					faceBvertexAIndex = faceBvertexBIndex
					faceBvertexBIndex = temp

				end

			else

				if faceBvertexAIndex < faceBvertexBIndex then

					temp = faceBvertexAIndex
					faceBvertexAIndex = faceBvertexBIndex
					faceBvertexBIndex = temp

				end

			end

			face = THREE.Face4(faceAvertexAIndex, faceAvertexBIndex, faceBvertexAIndex, faceBvertexBIndex)
			face.normal:set(1,0,0)
			push(edgeFaces, face)

		end

		self.geometry = newGeometry
		
	else
		self:calculateShadowVolumeGeometryWithoutEdgeInfo( self.geometry )
	end
	

end


function THREE.ShadowVolume:calculateShadowVolumeGeometryWithoutEdgeInfo( originalGeometry )

	--create geometry
	self.geometry = THREE.Geometry()
	self.geometry.boundingSphere = originalGeometry.boundingSphere
	self.geometry.edgeFaces = {}

	--copy vertices / faces from original mesh
	local vertices = self.geometry.vertices
	local faces = self.geometry.faces
	local edgeFaces = self.geometry.edgeFaces
	
	local originalFaces = originalGeometry.faces
	local originalVertices = originalGeometry.vertices

	for k, v in pairs(originalFaces) do

		local numVertices = length(vertices)
		local originalFace = v
		
		if getmetatable(originalFace).types[THREE.Face4] then

			n = 4
			face = THREE.Face4(numVertices, numVertices+1, numVertices+2, numVertices+3)			
			
		else
		
			n = 3
			face = THREE.Face3(numVertices, numVertice+1, numVertice+2 )
	
		end

		face.normal = table.copy(originalFace.normal)
		push(faces, face)

		for i = 0, n - 1  do

			vertex = originalVertices[originalFace[indices[i]]]
			push(vertices, THREE.Vertex(vertex.positon:clone()))

		end

	end

	-- calculate edge face

	local result, faceA, faceB, v, v1
	
	for fa = 0, (length(originalFaces) - 1) do

		faceA = faces[fa]
		
		for fb = fa + 1, (length(originalFaces))  do

			faceB = faces[k + 1]		
			result = self:facesShareEdge(vertices, faceA, faceB)

			if result ~= nil then

				numVertices = length(vertices)
				face = THREE.Face4(result.indices[0], result.indices[3], result.indices[2], result.indices[1])
				face.normal:set(1,0,0)
				push(edgeFaces, face)

			end

		end

	end

end


function THREE.ShadowVolume:facesShareEdge(vertices, faceA,faceB)

	local indicesA, indicesB, indexA, indexB, vertexA, vertexB
	local savedVertexA, savedVertexB, savedIndexA, savedIndexB
	local indexLetters
	local a, b
	local numMatches = 0
	local indices = {"a","b","c","d"}

	if getmetatable(faceA).types[THREE.Face4] then indicesA = 4 else indicesA = 3 end
	if getmetatable(faceB).types[THREE.Face4] then indicesB = 4 else indicesB = 3 end

	for a = 0, indicesA - 1 do
	
		indexA = faceA[ indices[a] ]
		vertexA = vertices[ indexA ]

		for b = 0, indicesB - 1 do

			indexB = faceB[ indices [ b ] ]
			vertexB = vertices[ indexB ]

			if math.abs(vertexA.position.x - vertexB.position.x) < 0.0001 and
				math.abs(vertexA.position.y - vertexB.position.y) < 0.0001 and
				math.abs(vertexA.position.z - vertexB.position.z) < 0.0001 then

				numMateches = numMatches + 1
			
				if numMatches == 1 then
			
					savedVertexA = vertexA
					savedVertexB = vertexB
					savedIndexA = indexA
					savedIndexB = indexB
					indexLetters = indices[ a ]

				end

				if numMatches == 2 then

					indexLetters = indexLetters + indices[ a ]
					if indexLetters == "ad" or indexLetters == "ac" then

						return {
				
							faces = {[0] = faceA, [1] = faceB},
							vertices = {[0] = savedVertexA, [1] = savedVertexB, [2] = vertexB, [3] = vertexA},
							indices = {[0] = savedIndexA, [1] = savedIndexB, [2] = indexB, [3] = indexA},
							vertexTypes = { [0] = 1, [1] = 2, [2] = 2, [3] = 1 },
							extrudable = true
						}
						
					else
				
						return{
							faces = {[0] = faceA, [1] = faceB},
							vertices = {[0] = savedVertexA, [1] = vertexA, [2] = vertexB, [3] = savedVertexB},
							indices = {[0] = savedIndexA, [1] = indexA, [2] = indexB, [3] = savedIndexB},
							vertexTypes = { [0] = 1, [1] = 1, [2] = 2, [3] = 2 },
							extrudable = true					
						}
					end

				end

			end

		end

	end

	return nil

end

