THREE=THREE or {}
THREE.CubeGeometry=table.copy(THREE.Geometry)
THREE.CubeGeometry.types = THREE.CubeGeometry.types or {}
THREE.CubeGeometry.types[THREE.CubeGeometry] = true
setmetatable(THREE.CubeGeometry, THREE.CubeGeometry)
THREE.CubeGeometry.__index = THREE.CubeGeometry
THREE.CubeGeometry.__call = 
function (self,width,height,depth,segmentsWidth,segmentsHeight,segmentsDepth,materials,flipped,sides)
	local cg=THREE.Geometry()
	setmetatable(cg, THREE.CubeGeometry)
	local scope=cg
	local width_half=width/2
	local height_half=height/2
	local depth_half=depth/2
	local flip = flipped and -1 or 1
	if (materials) then
		local isArray=true
		if (type(materials)=="table") then
			for k,v in pairs(materials) do
				if (type(k)~="number") then isArray=false end
			end
		else
			isArray=false
		end
		if (isArray) then
			cg.materials=materials
		else
			cg.materials={}
			for i=0,5 do
				push(cg.materials, {[0]=materials})
			end
		end
	else
		cg.materials={}
	end
	cg.sides={px=true, nx=true, py=true, ny = true, pz=true, nz=true}
	if (sides) then
		for k,v in pairs(sides) do
			if (not cg.sides[k]) then
				cg.sides=v
			end
		end
	end

	local function buildPlane(u, v, udir, vdir, width, height, depth, material )
		local gridX=segmentsWidth or 1
		local gridY=segmentsHeight or 1
		local width_half=width/2
		local height_half=height/2
		local offset=length(scope.vertices)
		if ((u=="x" and v=="y") or (u=="y" and v=="x")) then
			w="z"
		elseif ((u=="x" and v=="z") or (u=="z" and v=="x")) then
			w="y"
			gridY = segmentsDepth or 1
		elseif ((u=="z" and v=="y") or (u=="y" and v=="z")) then
			w="x"
			gridX = segmentsDepth or 1
		end
		local gridX1 = gridX+1
		local gridY1 = gridY+1
		local segment_width = width/gridX
		local segment_height = height/gridY
		for iy=0,gridY1-1 do
			for ix=0,gridX1-1 do
				local vector = THREE.Vector3()
				vector[u]=(ix*segment_width-width_half)*udir
				vector[v]=(iy*segment_height-height_half)*vdir
				vector[w]=depth
				push(scope.vertices, THREE.Vertex(vector))
			end
		end
		if (not scope.faceVertexUvs[0]) then scope.faceVertexUvs[0]={} end
		for iy=0,gridY-1 do
			for ix=0,gridX-1 do
				local a = ix + gridX1 * iy
				local b = ix + gridX1 * ( iy + 1 )
				local c = ( ix + 1 ) + gridX1 * ( iy + 1 )
				local d = ( ix + 1 ) + gridX1 * iy
				push(scope.faces, THREE.Face4{a=a+offset, b=b+offset, c=c+offset, d=d+offset, normal=nil, color=nil, materials=material})
				push(scope.faceVertexUvs[0], {[0]=THREE.UV{u= ix / gridX, v = iy / gridY },
							[1]=THREE.UV{u = ix / gridX, v = ( iy + 1 ) / gridY },
							[2]=THREE.UV{u = ( ix + 1 ) / gridX, v = ( iy + 1 ) / gridY },
							[3]=THREE.UV{u = ( ix + 1 ) / gridX, v = iy / gridY } } )
			end
		end
	end
		
	local function mergeVertices()
		local unique={}
		local changes={}
		for i=0,length(scope.vertices)-1 do
			local v = scope.vertices[i]
			local duplicate=false
			for j=0,length(unique)-1 do
				local vu=unique[j]
				if (v.position.x==vu.position.x and v.position.y==vu.position.y and v.position.z==vu.position.z) then
					changes[i]=j
					duplicate=true
					break
				end
			end
			if (not duplicate) then
				changes[i]=length(unique)
				push(unique, THREE.Vertex(v.position:clone()))
			end
		end
		for i=0,length(scope.faces)-1 do
			local face = scope.faces[i]
			face.a=changes[face.a]
			face.b=changes[face.b]
			face.c=changes[face.c]
			face.d=changes[face.d]
		end
		scope.vertices=unique
	end
	if (cg.sides.px) then buildPlane( "z", "y",   1 * flip, - 1, depth, height, - width_half, cg.materials[ 0 ] ) end
	if (cg.sides.nx) then buildPlane( "z", "y", - 1 * flip, - 1, depth, height, width_half, cg.materials[ 1 ] ) end
	if (cg.sides.py) then buildPlane( "x", "z",   1 * flip,   1, width, depth, height_half, cg.materials[ 2 ] ) end
	if (cg.sides.ny) then buildPlane( "x", "z",   1 * flip, - 1, width, depth, - height_half, cg.materials[ 3 ] ) end
	if (cg.sides.pz) then buildPlane( "x", "y",   1 * flip, - 1, width, height, depth_half, cg.materials[ 4 ] ) end
	if (cg.sides.nz) then buildPlane( "x", "y", - 1 * flip, - 1, width, height, - depth_half, cg.materials[ 5 ] ) end
	mergeVertices()
	cg:computeCentroids()
	cg:computeFaceNormals()
	return cg
end
