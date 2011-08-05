THREE = THREE or {}

THREE.Bone = table.copy(THREE.Object3D)
THREE.Bone.types = THREE.Bone.types or {}
THREE.Bone.types[THREE.Bone] = true
setmetatable(THREE.Bone, THREE.Bone)
THREE.Bone.__index = THREE.Bone

THREE.Bone.__call = function(_, belongs)
	local a = THREE.Object3D()
	setmetatable(a, THREE.Bone)
	a.skin = belongs
	a.skinMatrix = THREE.Matrix4()
	a.hasNoneBoneChildren = false
	return a
end

function THREE.Bone:update (parentSkinMatrix, forceUpdate, camera)

	if (self.matrixAutoUpdate) then
		if (not forceUpdate) then
			self:updateMatrix()
		end
	end

	if (forceUpdate or self.matrixWorldNeedsUpdate) then
		if (parentSkinMatrix) then
			self.skinMatrix:multiply(parentSkinMatrix, self.matrix)
		else
			self.skinMatrix:copy(self.matrix)
		end

		self.matrixWorldNeedsUpdate = false
		forceUpdate = true
	end

	if (self.hasNoneBoneChildren) then
		self.matrixWorld:multiply(self.skin.matrixWorld, self.skinMatrix)
		for k, child in pairs(self.children) do
			if (getmetatable(child).types[THREE.Bone]) then
				child:update(self.matrixWorld, true, camera)
			else
				child:update(self.skinMatrix, forceUpdate, camera)
			end
		end
	else
		for k,v in pairs(self.children) do
			v:update(self.skinMatrix, forceUpdate, camera)
		end
	end
end

function THREE.Bone:addChild (child) 
	if (indexOf(self.children, child) == -1) then
		if (rawget(child, "parent") ~= nil) then
			child.parent:removeChild(child)
		end
	

		child.parent = self
		push(self.children, child)

		if (getmetatable(child).types[THREE.Bone]) then
			self.hasNoneBoneChildren = true
		end
	end
end

function indexOf(table, object)
	for k,v in pairs(table) do
		if (v == object) then
			return k
		end	
	end
	return -1
end
