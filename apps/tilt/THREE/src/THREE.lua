THREE={}

function printVerts(v)
	print("vertices")
	for k,v in pairs(v) do
		print(k, v.position.x, v.position.y, v.position.z)
	end
end

function table.copy(t, b)
    local tc={}
    for k,v in pairs(t) do
			if (k=="types") then
				tc[k] = table.copy(v)
			else
				tc[k]=v
			end
    end
    return tc
end


function getPath()
	local str=debug.getinfo(1).source
	str=string.sub(str,2)
	local found=0
	local b=1
	while(found) do
		b=found+1
		found=string.find(str, "/", b)
	end
	return string.sub(str,1,b-1)
end

function getPath()
	return "THREE/src/"
end

function push(t,e)
	if (not rawget(t,0)) then t[0]=e
	else t[#t+1]=e end
end


function length(t)
	return rawget(t,0) and #t+1 or 0
end

function join(t, jp)
	local str = ""
	local j = jp or ""
	for i=0,length(t)-1 do
		local jl = i==0 and "" or j
		local tl = type(t[i])=="boolean" and (t[i] and "true" or "false") or t[i]
		str = str..jl..tl
	end
	return str
end

function indexOf(t,e)
	local retval=-1 
	for k,v in pairs(t) do
		if (v==e) then retval=k; break end
	end
	return retval
end 


function delete(t, item)
	for k,v in pairs(t) do
		if (item==v) then
			if (k==0) then
				t[0]=nil
				local i=1
				while(t[i]) do
					t[i-1]=t[i]
					i=i+1
				end
				t[#t] = nil
			else
				table.remove(t,k)
			end
		end
	end
	 
end


SRCDIR = getPath()

dofile(SRCDIR.."core/Color.lua")
dofile(SRCDIR.."core/Vector2.lua")
dofile(SRCDIR.."core/Vector3.lua")
dofile(SRCDIR.."core/Vector4.lua")
dofile(SRCDIR.."core/Matrix3.lua")
dofile(SRCDIR.."core/Matrix4.lua")
dofile(SRCDIR.."core/Face3.lua")
dofile(SRCDIR.."core/Face4.lua")
dofile(SRCDIR.."core/Vertex.lua")
dofile(SRCDIR.."core/Edge.lua")
dofile(SRCDIR.."core/Quaternion.lua")
dofile(SRCDIR.."core/Rectangle.lua")
dofile(SRCDIR.."core/UV.lua")
dofile(SRCDIR.."core/Spline.lua")
dofile(SRCDIR.."core/Geometry.lua")
dofile(SRCDIR.."core/Object3D.lua")
dofile(SRCDIR.."core/Spline.lua")
--dofile(SRCDIR.."core/Ray.lua")
dofile(SRCDIR.."cameras/Camera.lua")
dofile(SRCDIR.."objects/Mesh.lua")
dofile(SRCDIR.."materials/Mappings.lua")
dofile(SRCDIR.."materials/Texture.lua")
dofile(SRCDIR.."materials/Material.lua")
dofile(SRCDIR.."materials/MeshBasicMaterial.lua")
dofile(SRCDIR.."materials/MeshFaceMaterial.lua")
dofile(SRCDIR.."materials/MeshPhongMaterial.lua")
dofile(SRCDIR.."materials/MeshLambertMaterial.lua")
dofile(SRCDIR.."materials/MeshShaderMaterial.lua")
dofile(SRCDIR.."materials/Mappings.lua")
dofile(SRCDIR.."materials/ParticleBasicMaterial.lua")
dofile(SRCDIR.."materials/ParticleCanvasMaterial.lua")
dofile(SRCDIR.."materials/LineBasicMaterial.lua")
dofile(SRCDIR.."materials/ShadowVolumeDynamicMaterial.lua")
dofile(SRCDIR.."extras/geometries/CubeGeometry.lua")
dofile(SRCDIR.."extras/geometries/SphereGeometry.lua")
dofile(SRCDIR.."scenes/Scene.lua")
dofile(SRCDIR.."scenes/Fog.lua")
dofile(SRCDIR.."scenes/FogExp2.lua")
dofile(SRCDIR.."objects/Line.lua")
dofile(SRCDIR.."objects/Particle.lua")
dofile(SRCDIR.."objects/ParticleSystem.lua")
dofile(SRCDIR.."objects/Bone.lua")
dofile(SRCDIR.."objects/ShadowVolume.lua")
dofile(SRCDIR.."lights/Light.lua")
dofile(SRCDIR.."lights/PointLight.lua")
dofile(SRCDIR.."lights/AmbientLight.lua")
dofile(SRCDIR.."lights/DirectionalLight.lua")
dofile(SRCDIR.."renderers/renderables/RenderableVertex.lua")
dofile(SRCDIR.."renderers/renderables/RenderableParticle.lua")
dofile(SRCDIR.."renderers/renderables/RenderableObject.lua")
dofile(SRCDIR.."renderers/renderables/RenderableLine.lua")
dofile(SRCDIR.."renderers/renderables/RenderableFace3.lua")
dofile(SRCDIR.."renderers/renderables/RenderableFace4.lua")
dofile(SRCDIR.."renderers/WebGLRenderer.lua")
dofile(SRCDIR.."renderers/WebGLShaders.lua")
dofile(SRCDIR.."extras/ShaderUtils.lua")
--dofile(SRCDIR.."renderers/Projector.lua")

