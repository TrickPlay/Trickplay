
THREE = THREE or {}
THREE.Object3D = {}
THREE.Object3D.types = THREE.Object3D.types or {}
THREE.Object3D.types[THREE.Object3D] = true
setmetatable(THREE.Object3D,THREE.Object3D)
THREE.Object3D.__index = THREE.Object3D

--Constructor for Object3D
THREE.Object3D.__call = function (_) 
	local o = {}
	o.parent = -1
	o.children = {}
	
	o.up = THREE.Vector3(0,1,0)

	o.position = THREE.Vector3()
	o.rotation = THREE.Vector3()
	o.eulerOrder = 'XYZ'
	o.scale = THREE.Vector3(1,1,1)
	
	o.dynamic = false
	
	o.doubleSided = false
	o.flipSided = false

	o.renderDepth = nil

	o.rotationAutoUpdate = true

	o.matrix = THREE.Matrix4()
	o.matrixWorld = THREE.Matrix4()
	o.matrixRotationWorld = THREE.Matrix4()

	o.matrixAutoUpdate = true
	o.matrixWorldNeedsUpdate = true

	o.quaternion = THREE.Quaternion{}
	o.useQuaternion = false

	o.boundRadius = 0.0
	o.boundRadiusScale = 1.0
	
	o.visible = true
	
	o._vector = THREE.Vector3()

	o.name = ""

  	setmetatable(o, THREE.Object3D)
   	return o

end

--translate function
function THREE.Object3D:translate(distance, axis)
	self.matrix:rotateAxis(axis)
	self.position:addSelf(axis:multiplyScalar(distance))
end

--translateX function
function THREE.Object3D:translateX(distance)
	self:translate(distance, self._vector:set(1,0,0))
end


--translateY function
function THREE.Object3D:translateY(distance)
	self:translate(distance, self._vector:set(0,1,0))
end


--translateZ function
function THREE.Object3D:translateZ(distance)
	self:translate(distance, self._vector:set(0,0,1))
end


--lookAt function
function THREE.Object3D:lookAt(vector)
	self.matrix:lookAt(vector, self.position, self.up)
	if self.rotationAutoUpdate then
		self.rotation:setRotationFromMatrix(self.matrix)	
	end
end


--------------------------------------------------------------------------------------------
------------------------THE FOLLOWING FUNCTIONS HAVE NOT BEEN TESTED------------------------

--addChild function
function THREE.Object3D:addChild(child)
	local childIndex = indexOf(self.children, child)
	if childIndex == -1 then
		if child.parent ~= -1 then
			child.parent:removeChild(child)
		end	
	end
	child.parent = self
	push(self.children, child)
	--add to scene
	local scene = self
	while scene.parent ~= -1 do
		scene = scene.parent	
	end

	if scene ~= -1 and getmetatable(scene).types[THREE.Scene] then
		scene:addChildRecurse( child )
	end

end


--removeChild function
function THREE.Object3D:removeChild( child )
	local childIndex = indexOf(self.children, child )
	if  childIndex ~= -1 then
		child.parent = -1
		delete(self.children, child)
	end
end


--getChildByName function
function THREE.Object3D:getChildByName( name, doRecurse)

	local recurseResult = -1

	for k,v in pairs(self.children) do	

		if v.name == name then
			return v
		end

		if doRecurse then

			recurseResult = v:getChildByName(name, doRecurse)

			if recurseResult ~= -1 then

				return recurseResult	
	
			end	
		end

	end
	
	return -1
	
end

--------------------------THE ABOVE FUNCTIONS HAVE NOT BEEN TESTED--------------------------
--------------------------------------------------------------------------------------------

--updateMatrix function
function THREE.Object3D:updateMatrix()

	self.matrix:setPosition(self.position)

	if self.useQuaternion then
		self.matrix:setRotationFromQuaternion(self.quaternion)	
	else
		self.matrix:setRotationFromEuler(self.rotation, self.eulerOrder)
	end

	if (self.scale.x ~= 1) or (self.scale.y ~= 1) or (self.scale.z ~= 1) then
		self.matrix:scale(self.scale)
		self.boundRadiusScale = math.max(self.scale.x, math.max(self.scale.y, self.scale.z))	
	end

	self.matrixWorldNeedsUpdate = true

end


--update function
function THREE.Object3D:update(parentMatrixWorld, forceUpdate, camera)

	if self.matrixAutoUpdate then 
		self:updateMatrix() 
	end
	
	-- update matrixWorld

	if self.matrixWorldNeedsUpdate or forceUpdate then
	
		if parentMatrixWorld then

			self.matrixWorld:multiply(parentMatrixWorld, self.matrix)

		else

			self.matrixWorld:copy(self.matrix)
		end

		self.matrixRotationWorld:extractRotation(self.matrixWorld, self.scale)
		self.matrixWorldNeedsUpdate = false
		forceUpdate = true
		
	end

	--update children
	for k,v in pairs(self.children) do
		v:update(self.matrixWorld, forceUpdate, camera)
	end

end


function THREE.Object3D:setName(name)
	self.name = name
end
