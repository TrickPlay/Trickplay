THREE = THREE or {}
THREE.RenderableParticle = {}
THREE.RenderableParticle.types = THREE.RenderableParticle.types or {}
THREE.RenderableParticle.types[THREE.RenderableParticle] = true
setmetatable(THREE.RenderableParticle,THREE.RenderableParticle)
THREE.RenderableParticle.__index = THREE.RenderableParticle
THREE.RenderableParticle.__call = function ()
	local r={}
	setmetatable(r,THREE.RenderableParticle)
	r.scale=THREE.Vector2()
	return r
end 
