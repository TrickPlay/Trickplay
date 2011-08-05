--[[
/**
 * @author alteredq / http://alteredqualia.com/
 *
 * parameters = {
 *  fragmentShader: <string>,
 *  vertexShader: <string>,
 
 *  uniforms: { "parameter1": { type: "f", value: 1.0 }, "parameter2": { type: "i" value2: 2 } },
 
 *  shading: THREE.SmoothShading,
 *  blending: THREE.NormalBlending,
 *  depthTest: <bool>,
 
 *  wireframe: <boolean>,
 *  wireframeLinewidth: <float>,
 
 *  lights: <bool>,
 *  vertexColors: <bool>,
 *  skinning: <bool>,
 *  morphTargets: <bool>,
 * }
 */
--]]

THREE=THREE or {}
THREE.MeshShaderMaterial = table.copy(THREE.Material)
THREE.MeshShaderMaterial.types = THREE.MeshShaderMaterial.types or {}
THREE.MeshShaderMaterial.types[THREE.MeshShaderMaterial] = true
setmetatable(THREE.MeshShaderMaterial,THREE.MeshShaderMaterial)
THREE.MeshShaderMaterial.__index = THREE.MeshShaderMaterial





THREE.MeshShaderMaterial.__call = function(self, parameters)
    local m = THREE.Material(parameters)
    
    setmetatable(m,THREE.MeshShaderMaterial)
	--THREE.Material.call( this, parameters );

    parameters = parameters or {}

	m.fragmentShader = parameters.fragmentShader and parameters.fragmentShader or "void main() {}"
	m.vertexShader   = parameters.vertexShader   and parameters.vertexShader   or "void main() {}"
	m.uniforms       = parameters.uniforms       and parameters.uniforms       or {}
	m.attributes     = parameters.attributes

	m.shading = parameters.shading and parameters.shading or THREE.SmoothShading

	m.wireframe          = parameters.wireframe and parameters.wireframe or false;
	m.wireframeLinewidth = parameters.wireframeLinewidth and parameters.wireframeLinewidth or 1

	m.fog          = parameters.fog          and parameters.fog          or false -- set to use scene fog
	m.lights       = parameters.lights       and parameters.lights       or false -- set to use scene lights
	m.vertexColors = parameters.vertexColors and parameters.vertexColors or false -- set to use "color" attribute stream
	m.skinning     = parameters.skinning     and parameters.skinning     or false -- set to use skinning attribute streams
	m.morphTargets = parameters.morphTargets and parameters.morphTargets or false -- set to use morph targets
    
    
    return m
end
