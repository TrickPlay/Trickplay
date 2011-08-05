
THREE = THREE or {}
THREE.Ray = {}
THREE.Ray.types = THREE.Ray.types or {}
THREE.Ray.types[THREE.Ray] = true
setmetatable(THREE.Ray,THREE.Ray)
THREE.Ray.__index = THREE.Ray
THREE.Ray.__call = function (_, o,d) 
	local r={}
	setmetatable(r, THREE.Ray)
	r.origin = o or THREE.Vector3()
	r.direction = d or THREE.Vector3()
	return r
end





function distanceFromIntersection(origin,direction,object)
	position = object.matrixWorld:getPosition()
	
	vector = position:clone():subSelf(origin)
	dot = vector:dot(direction)
	
	intersect = origin:clone():addSelf(direction:clone():multiplyScalar(dot))
	distance = position:distanceTo(intersect)
	--TODO Check to see if distance is negative(object behind camera)
	return distance
end


function pointInFace3(p,a,b,c)
	v0 = c:clone():subSelf(a)
	v1 = b:clone():subSelf(a)
	v2 = p:clone():subSelf(a)
	dot00 = v0:dot(v0)
	dot01 = v0:dot(v1)
	dot02 = v0.dot(v2)
	dot11 = v1.dot(v1)
	dot12 = v1.dot(v2)
	invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
	u = (dot11 * dot02 - dot01 * dot12) * invDenom
	v = (dot00 * dot12 - dot01 * dot02) * invDenom
	return (u > 0) and (v > 0) and (u + v < 1)
end

local function push(t,e)
        if (not t[0]) then t[0]=e
        else t[#t+1]=e end
end

--cannot test until scene works
function THREE.Ray: intersectScene(scene)
	return self:intersectObjects(scene.objects)
end

function THREE.Ray: intersectObjects(objects)
	local intersects = {}
	l = (objects[0] and #objects + 1) or 0

	local mt = {}
	function mt.__lt (op1, op2) 
		return op1.distance < op2.distance
	end 
	for i = 0, l-1 do 
		intersects[i] = (self:intersectObject(objects[i]))
		setmetatable(intersects[i], mt)
	end
	--function intersect.sort(a,b)
	--	return a.distance - b.distance
	--end
	--intersects.sort(function(a,b) {return a.distance - b.distance)}
	return intersects
end


function THREE.Ray: intersectObject(object)
	if (getmetatable(object).types[Three.Particle]) then
		distance = distanceFromIntersection(self.origin, self.direction,object)
		if(not distance or distance > object.scale.x) then
			return {}
		end
	local final = {}
	final[0] = {
		["distance"] = distance,
		["point"] = object.position,
		["face"] =  nil,
		["object"] = object 
		}
	return final

	elseif(getmetatable(object).types[THREE.Mesh]) then
		--checking boundingSphere
		distance = distanceFromIntersection(self.origin,self.direction,object)
		if(not distance or distance > 
			object.geometry.boundingSphere.radius * math.max(object.scale.x,math.max(object.scale.y,object.scale.z))) then
		return {}
		end

		f1 = #(geometry.faces)
		for f = 0, f1 do
			face = geometry.faces[f]

			origin = self.origin:clone()
			direction = self.direction:clone()

			objMatrix = object.matrixWorld

			a = objMatrix:multiplyVector3(vertices[face.a].position:clone())
			b = objMatrix:multiplyVector3(vertices[face.b].position:clone())
			c = objMatrix:multiplyVector3(vertices[face.c].position:clone())
			d = (getmetatable(face).types[Three.Face4]) and objMatrix:multiplyVector3(vertices[face.d].position:clone())) or nil			
			normal = object.matrixRotationWorld:multiplyVector3(face.normal:clone())
			dot = direction:dot(normal)
			
			if((object.doubleSided or (object.flipSided and (dot > 0))) or dot <0) then
				scalar = normal:dot(THREE.Vector3():sub(a,origin))/dot
				intersectPoint = origin:addSelf(direction:multiplyScalar(scalar))
				if(getmetatable(face).types[Three.Face3]) then
					if(pointInFace3(intersectPoint,a,b,c)) then
						intersect[0] = {
							["distance"] = self.origin:distanceTo(intersectPoint),
							["point"] = intersectPoint,
							["face"] = face,
							["object"] = object
						}
						push(intersects,intersect)
					end
					
				elseif (getmetatable(face).types([THREE.Face4])) then
					if(pointInFace3(intersectPoint,a,b,d) or pointInFace3(intersectPoint,b,c,d)) then
						
						intersect = {
							["distance"] = self.origin:distanceTo(intersectPoint),
							["point"] = intersectPoint,
							["face"] = face,
							["object"] = object
							}
							push(intersects,intersect)
						
					end
				end
			end
		end
		return intersects
	else
	return {}
	end
end






















