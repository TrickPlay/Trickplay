THREE = THREE or {}

THREE.Ribbon = table.copy(THREE.Object3D)
THREE.Ribbon.types = THREE.Ribbon.types or {}
THREE.Ribbon.types[THREE.Ribbon] = true
setmetatable(THREE.Ribbon, THREE.Ribbon)
THREE.Ribbon.__index = THREE.Ribbon

THREE.Ribbon.__call = function(_, geo, mat)
	local a = THREE.Object3D()
	setmetatable(a, THREE.Ribbon)
	a.geometry = geo
	isArray = true
	if (type(mat)=="table") then
		for k,v in pairs(mat) do
			if (type(k)~="number") then isArray=false end
		end
	else
		isArray=false
	end
	
	a.materials = isArray and mat or {[0] = mat}
	return a
end
