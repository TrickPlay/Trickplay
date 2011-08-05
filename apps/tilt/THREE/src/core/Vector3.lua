--c[[ Vector in 3 Space
--]]
THREE = THREE or {}
THREE.Vector3 = {}
THREE.Vector3.types = THREE.Vector3.types or {}
THREE.Vector3.types[THREE.Vector3] = true
setmetatable(THREE.Vector3,THREE.Vector3)
--constructor
THREE.Vector3.__index = THREE.Vector3
THREE.Vector3.__call = function(_,x,y,z)
	local v3 = {}
	setmetatable(v3, THREE.Vector3)
	v3.x = x or 0
	v3.y = y or 0
	v3.z = z or 0
	return v3
end



function THREE.Vector3: copy(v)
	self.x = v.x
	self.y = v.y
	self.z = v.z
	return self

end

function THREE.Vector3: clone()
	return THREE.Vector3(self.x,self.y,self.z)
end

function THREE.Vector3: set(x,y,z)
	self.x = x
	self.y = y 
	self.z = z 
	return self
end


-- for debugging
function THREE.Vector3: print()
	print(self.x,self.y,self.z)
end



function THREE.Vector3: add(v1,v2)
	self.x = v1.x + v2.x
	self.y = v1.y + v2.y 
	self.z = v1.z + v2.z
	return self 
end


function THREE.Vector3: addSelf(v)
	self.x = self.x + v.x
	self.y = self.y + v.y
	self.z = self.z + v.z
	return self
end


function THREE.Vector3: addScalar(s) 
	self.x = self.x + s
	self.y = self.y + s 
	self.z = self.z + s
	return self 
end


function THREE.Vector3: sub(v1,v2)
	self.x = v1.x - v2.x
	self.y = v1.y - v2.y
	self.z = v1.z - v2.z
	return self
end


function THREE.Vector3: subSelf(v)
	self.x = self.x - v.x
	self.y = self.y - v.y 
	self.z = self.z - v.z 
	return self
end

function THREE.Vector3: multiply(a,b)
	self.x = a.x * b.x 
	self.y = a.y * b.y
	self.z = a.z * b.z
	return self
end


function THREE.Vector3: multiplySelf(v)
	self.x = self.x * v.x 
	self.y = self.y * v.y
	self.z = self.z * v.z
	return self

end

function THREE.Vector3: multiplyScalar (s)
	self.x = self.x * s
	self.y = self.y * s
	self.z = self.z * s
	return self
end



--did not include this function
function THREE.Vector3: divide(a,b)
end
--

function THREE.Vector3: divideSelf(v)
	if(v.x ~= 0 or v.y ~= 0 or v.z ~= 0) then
		self.x = self.x / v.x or self.x
		self.y = self.y / v.y or self.y
		self.z = self.z / v.z or self.z
	else
	print("Error: cannot divide by zero")
	end
	return self
end

function THREE.Vector3: divideScalar(s)
	if(s and s ~= 0) then
		self.x = self.x / s
		self.y = self.y / s
		self.z = self.z / s 
	else
		self:set(0,0,0)
	end
	return self
end

function THREE.Vector3: negate()
	return self:multiplyScalar(-1)
end

function THREE.Vector3: dot(v)
	return self.x * v.x + self.y * v.y + self.z  * v.z
end

function THREE.Vector3: lengthSq()
	return self.x * self.x + self.y * self.y + self.z * self.z
end


function THREE.Vector3 : length()
	return math.sqrt(self:lengthSq())
end


function THREE.Vector3: lengthManhattan()
	return math.abs(self.x) + math.abs(self.y) + math.abs(self.z)
end


function THREE.Vector3: normalize()
	return self:divideScalar(self:length())
end

function THREE.Vector3: setLength(l)
	return self:normalize():multiplyScalar(l)
end

function THREE.Vector3: cross(a,b)
	self.x = (a.y * b.z) - (a.z * b.y)
	self.y = (a.z * b.x) - (a.x * b.z)
	self.z = (a.x * b.y) - (a.y * b.x)
	return self
end

function THREE.Vector3: crossSelf(v) 
	return self:set(
	
		self.y * v.z - self.z * v.y,
		self.z * v.x - self.x * v.z,
		self.x * v.y - self.y * v.x
	)
end

function THREE.Vector3: distanceTo(v)
	return math.sqrt(self:distanceToSquared(v))
end

function THREE.Vector3: distanceToSquared(v)
	return THREE.Vector3():sub(self,v):lengthSq()
end

--requires matrix object to be written
function THREE.Vector3: setPositionFromMatrix(m)
	self.x = m.n14
	self.y = m.n24
	self.z = m.n34
end

function THREE.Vector3: setRotationFromMatrix (m)
	local cosY = math.cos(self.y)
	self.y = math.asin(m.n13)

	if(math.abs(cosY) > .00001) then
		self.x = math.atan2( - m.n23 / cosY, m.n33 / cosY)
		self.z = math.atan2( - m.n12 / cosY, m.n11 / cosY)
	else
		self.x = 0
		self.z = math.atan2(m.n32, m.n22)
	end
end


function THREE.Vector3: isZero()
	-- .0001 is almost zero
	return (self:lengthSq() < .0001)
end

