
THREE = THREE or {}
THREE.Spline = {}
THREE.Spline.types = THREE.Spline.types or {}
THREE.Spline[THREE.Spline] = true
setmetatable(THREE.Spline,THREE.Spline)
--constructor
THREE.Spline.__index = THREE.Spline
THREE.Spline.__call = function(_,points)
	local spline = {}
	setmetatable(spline, THREE.Spline)
	spline.points = points
	return spline
end

function THREE.Spline:initFromArray(a)
	self.points = {}
	for i=0, #a do
		self.points[i] = {x = a[i][0], y =  a[i][1] , z = a[i][2]}
	end
end

function THREE.Spline: interpolate(p0,p1,p2,p3,t,t2,t3) 
	v0 = (p2 - p0) * 0.5
	v1 = (p3 - p1) * 0.5
	value = (2 *(p1 - p2) + v0 + v1) * t3 + (-3 * (p1 - p2) - 2 * v0 - v1) * t2 + v0 * t + p1	
	return value
end




function THREE.Spline: getPoint(k)
	 local c = {}
	  local v3 = {x = 0, y = 0, z = 0}
	point = (#(self.points)) * k
	--print("point = ",point)
	intPoint = math.floor(point)
	--print( "intpoint = ", intPoint)
	weight = point - intPoint
	--print("weight =  ", weight)
	c[0] = intPoint == 0 and intPoint or intPoint - 1
	c[1] = intPoint
	c[2] = (intPoint > #(self.points) - 1 and intPoint) or intPoint + 1
	c[3] = (intPoint > #(self.points) - 2 and intPoint) or intPoint + 2

	pa = self.points[c[0]]
	pb = self.points[c[1]]
	pc = self.points[c[2]]
	pd = self.points[c[3]]

	w2 = weight * weight
	w3 = weight * w2


	v3.x = self:interpolate(pa.x,pb.x,pc.x,pd.x,weight,w2,w3)
	--print(v3.x)
	v3.y = self:interpolate(pa.y,pb.y,pc.y,pd.y,weight,w2,w3)
	--print(v3.y)
	v3.z = self:interpolate(pa.z,pb.z,pc.z,pd.z,weight,w2,w3)
	--print(v3.z)
	return v3
end


function THREE.Spline:print()
	for i = 0, #self.points do
		print(self.points[i].x,self.points[i].y, self.points[i].z)
	end
end

function test_function()
	a = {}
	--points initialization
	a[0] = {}
	a[0][0] = 1
	a[0][1] = 2
	a[0][2] = 3
	a[1] = {}
	a[1][0] = 4
	a[1][1] = 5
	a[1][2] = 6
	--end points initialization

	spline1 = THREE.Spline(a)
	print(spline1)
	print("end constructor")
	spline1:initFromArray(a)
	print(spline1.points[0].x, spline1.points[0].y, spline1.points[0].z)
	print(spline1.points[1].x, spline1.points[1].y, spline1.points[1].z)
	print("end initalize array")
	spline1:getPoint(0)
	-- end getPoint
	print(spline1:interpolate(0,1,2,3,4,5,6,7))
	--end interpolation
end
--test_function()


function THREE.Spline: getControlPointsArray()
	l = #self.points
	coords = {}
	for i = 0,l   do 
		p = self.points[i]
		coords[i] = {x = p.x,y = p.y,z = p.z}
	end
	return coords
end


function THREE.Spline: getLength(nSubDivisions)
	local point = 0 
	local intPoint = 0 
	local oldIntPoint = 0
	oldPosition = THREE.Vector3()
	tmpVec = THREE.Vector3()
	chunkLengths = {}
	totalLength = 0
	final = {}
	-- first point has 0 length
	chunkLengths[0] = 0
	if  not nSubDivisions then nSubDivisions = 100 end
	nSamples = (#(self.points) + 1) * nSubDivisions
	oldPosition:copy(self.points[0])
	for i = 1,nSamples - 1 do 
		index = i / nSamples
		position = self:getPoint(index)
		tmpVec:copy(position)
		totalLength = totalLength + tmpVec:distanceTo(oldPosition)
		oldPosition:copy(position)
		point = #(self.points) * index
		intPoint = math.floor(point)
		if (intPoint ~= oldIntPoint) then
			chunkLengths[intPoint] = totalLength
			oldIntPoint = intPoint
		end
	end
	--last point ends with total length
	chunkLengths[#chunkLengths+1] = totalLength
	--not sure if this works
	final = {chunks = chunkLengths,total = totalLength}
	return final

end

function THREE.Spline: reparametrizeByArcLength(samplingCoef)
	newpoints = {}
	tmpVec = new THREE.Vector3()
	sl = self:getLength()
	table.insert(newpoints, 0, (tmpVec:copy(self.points[0]):clone()));

	for i = 1,(#self.points) do
		--tmpVec.copy( this.points[ i - 1 ] )
		--linearDistance = tmpVec.distanceTo( this.points[ i ] )
		realDistance = sl.chunks[i] - sl.chunks[i - 1]
		sampling = math.ceil(samplingCoef * realDistance / sl.total)
		indexCurrent = ( i - 1 ) / (#(self.points))
		indexNext = i / (#(self.points))

		for j = 1,sampling - 2 do
			index = indexCurrent + j * (1 / sampling) * (indexNext -indexCurrent)
			position = self:getPoint(index)
			table.insert(newpoints,(tmpVec:copy(position):clone()))

		end
		table.insert(newpoints,(tmpVec:copy(self.points[i]):clone()))
	end
	self.points = newpoints
end





