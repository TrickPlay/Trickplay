THREE = THREE or {}
THREE.Vector4 = {}
THREE.Vector4.types = THREE.Vector4.types or {}
THREE.Vector4.types[THREE.Vector4] = true
THREE.Vector4.__index = THREE.Vector4
setmetatable(THREE.Vector4, THREE.Vector4)


--Constructor for Vector4
THREE.Vector4.__call = function (_, x, y, z, w) 
	
	local v4 = {}
	setmetatable(v4, THREE.Vector4)
	v4.x = x or 0
	v4.y = y or 0
	v4.z = z or 0
	v4.w = w or 1
   	return v4

end

--set function
function THREE.Vector4:set(x, y, z, w)
	self.x = x
	self.y = y
	self.z = z
	self.w = w
end

--copy function
function THREE.Vector4:copy(v)
	self.x = v.x
 	self.y = v.y
	self.z = v.z 
	self.w = rawget(v, "w") or 1.0		
end

--clone function
function THREE.Vector4:clone()
	return THREE.Vector4(self.x, self.y, self.z, self.w)
end

--add function
function THREE.Vector4:add(v1, v2)
	self.x = v1.x + v2.x
	self.y = v1.y + v2.y
	self.z = v1.z + v2.z
	self.w = v1.w + v2.w

	return self
end

--addSelf function
function THREE.Vector4:addSelf(v2)
	self.x = self.x + v2.x
	self.y = self.y + v2.y
	self.z = self.z + v2.z
	self.w = self.w + v2.w

	return self
end

--sub function
function THREE.Vector4:sub(v1, v2)
	self.x = v1.x - v2.x
	self.y = v1.y - v2.y
	self.z = v1.z - v2.z
	self.w = v1.w - v2.w

	return self
end

--subSelf function
function THREE.Vector4:subSelf(v2)
	self.x = self.x - v2.x
	self.y = self.y - v2.y
	self.z = self.z - v2.z
	self.w = self.w - v2.w

	return self
end

--multiplyScalar function
function THREE.Vector4:multiplyScalar(s)
	self.x = self.x * s
	self.y = self.y * s
	self.z = self.z * s
	self.w = self.w * s
	
	return self
end

--divideScalar function
function THREE.Vector4:divideScalar(s)
	if s then
		self.x = self.x / s
		self.y = self.y / s
		self.z = self.z / s
		self.w = self.w / s	
	else
		self.x = 0
		self.y = 0
		self.z = 0
		self.w = 1	
	end
	
	return self
end

--negate function
function THREE.Vector4:negate()
	return self:multiplyScalar(-1)
end

--dot function
function THREE.Vector4:dot(v)
	return self.x * v.x + self.y * v.y + self.z * v.z + self.w * v.w
end

--lengthSq function
function THREE.Vector4:lengthSq()
	return self:dot(self)
end

--length function
function THREE.Vector4:length()
	return math.sqrt(self:lengthSq())
end

--normalize function
function THREE.Vector4:normalize()
	return self:divideScalar(self:length())
end

--setLength function
function THREE.Vector4:setLength(len)
	local temp = self:normalize()
	return temp:multiplyScalar(len)
end

--lerpSelf function
function THREE.Vector4:lerpSelf(v, a)
	self.x = self.x + (v.x - self.x) * a
	self.y = self.y + (v.y - self.y) * a
	self.z = self.z + (v.z - self.z) * a
	self.w = self.w + (v.w - self.w) * a

	return self
end

--Debugging Print function
function THREE.Vector4:print()
	print(self.x, self.y, self.z, self.w)
end


