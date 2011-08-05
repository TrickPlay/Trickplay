THREE=THREE or {}
THREE.SphereGeometry=table.copy(THREE.Geometry)
THREE.SphereGeometry.types = THREE.SphereGeometry.types or {}
THREE.SphereGeometry.types[THREE.SphereGeometry] = true
setmetatable(THREE.SphereGeometry, THREE.SphereGeometry)
THREE.SphereGeometry.__index = THREE.SphereGeometry
THREE.SphereGeometry.__call = 
function (self,radius,segmentsWidth,segmentsHeight)
	local sg = THREE.Geometry();
	setmetatable(sg, THREE.SphereGeometry);
	local radius = radius or 50
	local gridX = segmentsWidth or 8
	local gridY = segmentsHeight or 6
	local i
	local j
	local pi = math.pi
	local iHor = math.max( 3, gridX )
	local iVer = math.max( 2, gridY )
	local aVtc = {}

	for j = 0,iVer do
		local fRad1 = j / iVer
		local fZ = radius * math.cos( fRad1 * pi )
		local fRds = radius * math.sin( fRad1 * pi )
		local aRow = {}
		local oVtx = 0
		for i=0,iHor-1 do
			local fRad2 = 2 * i / iHor
			local fX = fRds * math.sin( fRad2 * pi )
			local fY = fRds * math.cos( fRad2 * pi )
			if ( not ( ( j == 0 or j == iVer ) and i > 0 ) ) then
				push (sg.vertices, THREE.Vertex( THREE.Vector3( fY, fZ, fX ) ))
				oVtx = length(sg.vertices)-1
			end
			push(aRow, oVtx )
		end
		push(aVtc, aRow )

	end

	local n1
	local n2
	local n3
	local iVerNum = length(aVtc)
    
    sg.faceVertexUvs[0]={}
	for j = 0,iVerNum-1 do
        --print(j)
		local iHorNum = length(aVtc[ j ])
		if ( j > 0 ) then
			for i = 0,iHorNum-1 do
                --print(j,i)
				local bEnd = i == ( iHorNum - 1 )
				local aP1 = aVtc[ j     ][   bEnd and 0 or i + 1 ]
				local aP2 = aVtc[ j     ][ ( bEnd and iHorNum - 1 or i ) ];
				local aP3 = aVtc[ j - 1 ][ ( bEnd and iHorNum - 1 or i ) ];
				local aP4 = aVtc[ j - 1 ][   bEnd and 0 or i + 1 ];
                
				local fJ0 = j / ( iVerNum - 1 );
				local fJ1 = ( j - 1 ) / ( iVerNum - 1 );
				local fI0 = ( i + 1 ) / iHorNum;
				local fI1 = i / iHorNum;

				local aP1uv = THREE.UV{u= 1 - fI0, v= fJ0 };
				local aP2uv = THREE.UV{u= 1 - fI1, v= fJ0 };
				local aP3uv = THREE.UV{u= 1 - fI1, v= fJ1 };
				local aP4uv = THREE.UV{u= 1 - fI0, v= fJ1 };

				if ( j < ( length(aVtc) - 1 ) ) then

					n1 = sg.vertices[ aP1 ].position:clone();
					n2 = sg.vertices[ aP2 ].position:clone();
					n3 = sg.vertices[ aP3 ].position:clone();
					n1:normalize();
					n2:normalize();
					n3:normalize();

					push(
                        
                        sg.faces,
                        
                        THREE.Face3{
                            a=aP1,
                            b=aP2,
                            c=aP3,
                            normal={
                                [0]= THREE.Vector3( n1.x, n1.y, n1.z ),
                                [1]= THREE.Vector3( n2.x, n2.y, n2.z ),
                                [2]= THREE.Vector3( n3.x, n3.y, n3.z )
                            }
                        }
                        
                    );
                    
					--sg.faceVertexUvs[0]={}
					push(sg.faceVertexUvs[ 0 ], { [0]=aP1uv,[1]= aP2uv,[2]= aP3uv } );

				end

				if ( j > 1 ) then

					n1 = sg.vertices[aP1].position:clone();
					n2 = sg.vertices[aP3].position:clone();
					n3 = sg.vertices[aP4].position:clone();
					n1:normalize();
					n2:normalize();
					n3:normalize();

					push(sg.faces, THREE.Face3{a= aP1,b= aP3,c= aP4,normal= {[0]= THREE.Vector3( n1.x, n1.y, n1.z ), [1]= THREE.Vector3( n2.x, n2.y, n2.z ), [2]= THREE.Vector3( n3.x, n3.y, n3.z ) } } );

					push(sg.faceVertexUvs[ 0 ], {[0]= aP1uv, [1]= aP3uv,[2]= aP4uv } );

				end

			end
		end
	end
    
    --dumptable(sg.faceVertexUvs)
    --print(# sg.faceVertexUvs)
	sg:computeCentroids();
	sg:computeFaceNormals();
	sg:computeVertexNormals();

	sg.boundingSphere = { radius= radius };
	return sg

end
