THREE = THREE or {}
THREE.LineStrip=0
THREE.LinePieces=1
THREE.Line=table.copy(THREE.Object3D)
THREE.Line.types = THREE.Line.types or {}
THREE.Line.types[THREE.Line] = true
setmetatable(THREE.Line, THREE.Line)
THREE.Line.__index=THREE.Line
THREE.Line.__call=function(self, geometry, materials, lType)
	l=THREE.Object3D()
	local isArray=true
	if (type(materials)=="table") then
		for k,v in pairs(materials) do
			if (type(k)~="number") then isArray=false end
		end
	else
		isArray=false
	end
	setmetatable(l,THREE.Line)
	l.geometry=geometry
	l.materials = isArray and materials or {[0]=materials}
	l.type = lType and lType or THREE.LineStrip
end
