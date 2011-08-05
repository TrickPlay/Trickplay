THREE = THREE or {}
THREE.Vector2={}
THREE.Vector2.types = THREE.Vector2.types or {}
THREE.Vector2.types[THREE.Vector2] = true
setmetatable(THREE.Vector2, THREE.Vector2)
--constuctor
THREE.Vector2.__index = THREE.Vector2
THREE.Vector2.__call = function (_, x, y)
	local vec2={}
	setmetatable(vec2, THREE.Vector2)
	vec2.x = x or 0
	vec2.y = y or 0
	return vec2
end

function THREE.Vector2:set(x,y)
	self.x=x
	self.y=y
end

function THREE.Vector2:copy(v)
	self.x= v.x
	self.y = v.y
end

function THREE.Vector2:clone()
	return THREE.Vector2(self.x, self.y)
end

function THREE.Vector2:add(v1, v2)
	self.x = v1.x + v2.x
	self.y = v1.y + v2.y
	return self
end

function THREE.Vector2:addSelf(v)
	self.x = self.x + v.x
	self.y = self.y + v.y
	return self
end

function THREE.Vector2:sub(v1,v2)
	self.x = v1.x-v2.x
	self.y = v1.y-v2.y
	return self
end

function THREE.Vector2:subSelf(v)
	self.x = self.x-v.x
	self.y = self.y-v.y
	return self
end

function THREE.Vector2:multiplyScalar(s)
	self.x = self.x*s
	self.y = self.y*s
	return self
end

function THREE.Vector2:divideScalar(s)
	if (s and s>0) then
		self.x = self.x/s
		self.y = self.y/s
	else
		self:set(0,0)
	end
	return self
end

function THREE.Vector2:negate()
	return self:multiplyScalar(-1)
end

function THREE.Vector2:dot(v)
	return self.x*v.x + self.y*v.y
end

function THREE.Vector2:lengthSq()
	return self.x*self.x+self.y*self.y
end

function THREE.Vector2:length()
	return math.sqrt(self:lengthSq())
end

function THREE.Vector2:normalize()
	return self:divideScalar(self:length())
end

function THREE.Vector2:distanceToSquared(v)
	local dx = self.x-v.x
	local dy = self.y-v.y
	return dx*dx + dy*dy
end

function THREE.Vector2:distanceTo(v)
	return math.sqrt(self:distanceToSquared(v))
end

function THREE.Vector2:setLength(l)
	return self:normalize():multiplyScalar(l)
end

function THREE.Vector2:unit()
	return self:normalize()
end

function THREE.Vector2:equals(v)
	return self.x==v.x and self.y==v.y
end

function THREE.Vector2:toString()
	return ""+self.x+" "+self.y
end

