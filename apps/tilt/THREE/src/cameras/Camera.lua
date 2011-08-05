THREE = THREE or {}

THREE.Camera = table.copy(THREE.Object3D)
THREE.Camera.types = THREE.Camera.types or {}
THREE.Camera.types[THREE.Camera] = true
setmetatable(THREE.Camera, THREE.Camera)
THREE.Camera.__index = THREE.Camera

THREE.Camera.__call = function(_, t)
	local a = THREE.Object3D()
	setmetatable(a, THREE.Camera)
	a.fov = t.fov or 50
	a.aspect = t.aspect or 1
	a.near = t.near or 0.1
	a.far = t.far or 2000

	a.target = t.target or THREE.Object3D{}
	a.useTarget = true

	a.matrixWorldInverse = THREE.Matrix4{}
	a.projectionMatrix = nil
	
	a.full = false	
	
	a:updateProjectionMatrix()

	return a
end

function THREE.Camera:translate (distance, axis)
	self.matrix:rotateAxis(axis)
	axis:multiplyScalar(distance)

	self.position:addSelf(axis)
	self.target.position:addSelf(axis)
end

function THREE.Camera:updateProjectionMatrix()
	if (self.full) then
		local aspect = self.fullWidth / self.fullHeight
		local top = math.tan(self.fov * math.pi / 360) * self.near
		local bottom = -top
		local left = aspect * bottom
		local right = aspect * top
		local width = math.abs (right - left)
		local height = math.abs (top - bottom)

		self.projectionMatrix = THREE.Matrix4.makeFrustum(
			left + self.x * width / self.fullWidth,
			left + (self.x + self.width) * width / self.fullWidth,
			top - (self.y + self.height) * height / self.fullHeight,
			top - self.y * height / self.fullHeight,
			self.near,
			self.far )
	else
		self.projectionMatrix = THREE.Matrix4.makePerspective(self.fov, self.aspect, self.near, self.far)
	end
	
	--self.projectionMatrix:print()
end


function THREE.Camera:print()
	self.projectionMatrix:print()
	print("--------------")
	self.matrix:print()
	print("--------------")
	self.position:print()
end

--[[/**
 * Sets an offset in a larger frustum. This is useful for multi-window or
 * multi-monitor/multi-machine setups.
 *
 * For example, if you have 3x2 monitors and each monitor is 1920x1080 and
 * the monitors are in grid like this
 *
 *   +---+---+---+
 *   | A | B | C |
 *   +---+---+---+
 *   | D | E | F |
 *   +---+---+---+
 *
 * then for monitor each monitor you would call it like this
 *
 *   var w = 1920;
 *   var h = 1080;
 *   var fullWidth = w * 3;
 *   var fullHeight = h * 2;
 *
 *   --A--
 *   camera.setOffset( fullWidth, fullHeight, w * 0, h * 0, w, h );
 *   --B--
 *   camera.setOffset( fullWidth, fullHeight, w * 1, h * 0, w, h );
 *   --C--
 *   camera.setOffset( fullWidth, fullHeight, w * 2, h * 0, w, h );
 *   --D--
 *   camera.setOffset( fullWidth, fullHeight, w * 0, h * 1, w, h );
 *   --E--
 *   camera.setOffset( fullWidth, fullHeight, w * 1, h * 1, w, h );
 *   --F--
 *   camera.setOffset( fullWidth, fullHeight, w * 2, h * 1, w, h );
 *
 *   Note there is no reason monitors have to be the same size or in a grid.
 */]]

function THREE.Camera:setViewOffset(fullWidth, fullHeight, x, y, width, height)
	self.fullWidth = fullWidth
	self.fullHeight = fullHeight
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.full = true
	self:updateProjectionMatrix()
end

--[[NOT YET TESTED]]--

function THREE.Camera:update (parentMatrixWorld, forceUpdate, camera) 
	if (self.useTarget) then
		--local
		newTarg = THREE.Vector3();
		targOffset = THREE.Vector3(250,100,50);
		--self.matrix:lookAt (self.position, newTarg:add(self.target.position, targOffset), self.up)
		self.matrix:lookAt (self.position, self.target.position, self.up)
		self.matrix:setPosition (self.position)

		--global

		if (parentMatrixWorld) then
			self.matrixWorld:multiply(parentMatrixWorld, self.matrix)
		else
			self.matrixWorld:copy(self.matrix)
		end

		THREE.Matrix4.makeInvert(self.matrixWorld, self.matrixWorldInverse)
		
		forceUpdate = true
	else
		if(self.matrixAutoUpdate) then 
			self:updateMatrix()
		end

		if (forceUpdate or self.matrixWorldNeedsUpdate) then
			if (parentMatrixWorld) then
				self.matrixWorld:multiply(parentMatrixWorld, self.matrix)
			else
				self.matrixWorld:copy(self.matrix)
			end

			self.matrixWorldNeedsUpdate = false
			forceUpdate = true

			THREE.Matrix4.makeInvert(self.matrixWorld, self.matrixWorldInverse)
		end

	end

	--update children

	for i, v  in pairs(self.children) do
		self.children[ i ]:update(self.matrixWorld, forceUpdate, camera)
	end
				
end
