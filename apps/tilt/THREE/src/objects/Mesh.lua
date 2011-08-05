THREE = THREE or {}
THREE.Mesh = table.copy(THREE.Object3D)
THREE.Mesh.types = THREE.Mesh.types or {}
THREE.Mesh.types[THREE.Mesh] = true
setmetatable(THREE.Mesh,THREE.Mesh)
THREE.Mesh.__index = THREE.Mesh
THREE.Mesh.__call = function(self, geometry,materials)
	local m = THREE.Object3D()
	setmetatable(m, THREE.Mesh)
	m.geometry = geometry
	m.materials = (materials and rawget(materials, 0)) and materials or {[0]=materials}
	m.overdraw = false
	if(m.geometry) then
		if (not rawget(m.geometry,"boundingSphere")) then
			m.geometry:computeBoundingSphere()
		end
		m.boundRadius = geometry.boundingSphere.radius
		if(length(m.geometry.morphTargets) >0) then
			m.morphTargetBase = -1
			m.morphTargetForcedOrder = {}
			m.morphTargetInfluences  = {}
			m.morphTargetDictionary = {}
			for k,v in pairs(m.geometry.morphTargets) do
				push(m.morphTargetInfluences,0)
				m.morphTargetDictionary[v.name] = k
			end
		end
	end
	return m
end

function THREE.Mesh: getMorphTargetIndexByName (name)
	if (self.morphTargetDictionary[name]) then
		return self.morphTargetDictionary[name]
	end
	return 0
end

--[[
function test_function()
geometry = Geometry()
end
test_function()
--]]
