THREE = THREE or {}

--set up metatable for THREE.Scene

THREE.Scene = table.copy(THREE.Object3D)--now Scene has everything that Object3D has
THREE.Scene.types = THREE.Scene.types or {}
THREE.Scene.types[THREE.Scene] = true
THREE.Scene.__index=THREE.Scene
setmetatable(THREE.Scene, THREE.Scene)--[[Scene looks inside its own metatable for functions
                                      (allows us to use the .__call metamethod which constructs 
                                      our Scene object)]]

--Constructor for THREE.Scene
THREE.Scene.__call = function (_)
	local s = THREE.Object3D()
	setmetatable(s,THREE.Scene)
	s.matrixAutoUpdate = false

	s.fog = nil

	s.overrideMaterial = nil

	s.collisions = nil

	s.objects = {}
	s.lights = {}

	s.__objectsAdded = {}
	s.__objectsRemoved = {}
    print(s,getmetatable(s))
	return s
end

--addChild function
local old_addChild = THREE.Scene.addChild
function THREE.Scene:addChild( child )
	--print('a')
    old_addChild(self, child)
    --print('b')
	self:addChildRecurse( child )
    --print('c')
	if (getmetatable(child)==THREE.Mesh) then print(child.materials.color) end
end

--addChildRecurse function
function THREE.Scene:addChildRecurse( child )
	if ( getmetatable(child).types[THREE.Light]) then
		childIndex = indexOf(self.lights, child )
		if ( childIndex == -1 ) then
			push(self.lights, child)

		end

	elseif ( not( getmetatable(child).types[THREE.Camera] or getmetatable(child).types[THREE.Bone] ) ) then
		childIndex = indexOf(self.objects, child)
		if ( childIndex == -1 ) then
			push(self.objects, child )
			push(self.__objectsAdded, child )

		end

	end

	for k,v in pairs(child.children) do

		self:addChildRecurse(v)

	end

end

--removeChild function
local old_removeChild = THREE.Scene.removeChild
function THREE.Scene:removeChild( child )
	old_removeChild(self, child)
	self:removeChildRecurse( child )

end

--removeChildRecurse function
function THREE.Scene:removeChildRecurse( child )

	if ( getmetatable(child).types[THREE.Light] ) then
		if ( childIndex ~= -1 ) then
			delete(self.lights, child)

		end

	elseif ( not( getmetatable(child).types[THREE.Camera] ) ) then
		childIndex = indexOf(self.objects, child )
		if( i ~= -1 ) then

			delete(self.objects, child)
			push(self.__objectsRemoved, child )

		end

	end

	for k,v in pairs(child.children) do

		self:removeChildRecurse(v)

	end

end

function THREE.Scene:addObject(child) self:addChild(child) end
function THREE.Scene:removeObject(child) self:removeChild(child) end
function THREE.Scene:addLight(child) self:addChild(child) end
function THREE.Scene:removeLight(child) self:removeChild(child) end


