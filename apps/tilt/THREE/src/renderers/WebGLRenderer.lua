function foo(...)
	--print("foo")
	gl:drawElements(...)
end
function foo2(...)
	--print("foo2")
	gl:drawArrays(...)
end

gl_program = {}
THREE = THREE or {}
THREE.WebGLRenderer = {}
THREE.WebGLRenderer.types = THREE.WebGLRenderer.types or {}
THREE.WebGLRenderer.types[THREE.WebGLRenderer] = true
setmetatable(THREE.WebGLRenderer, THREE.WebGLRenderer)
THREE.WebGLRenderer.__index = THREE.WebGLRenderer
THREE.WebGLRenderer.__call = function (parameters)
	WGLR = {}
	setmetatable(WGLR, THREE.WebGLRenderer)
	local _this = WGLR
	local _gl; local _programs = {}
	local _currentProgram = nil
	local _currentFramebuffer = nil
	local _currentDepthMask = true
	local _oldDoubleSided = nil
	local _oldFlipSided = nil
	local _oldBlending = nil
	local _oldDepth = nil
	local _oldPolygonOffset = nil
	local _oldPolygonOffsetFactor = nil
	local _oldPolygonOffsetUnits = nil
	local _cullEnabled = true
	local _viewportX = 0
	local _viewportY = 0
	local _viewportWidth = 0
	local _viewportHeight = 0
	local _frustum = {
		[0] = THREE.Vector4(),
		[1] = THREE.Vector4(),
		[2] = THREE.Vector4(),
		[3] = THREE.Vector4(),
		[4] = THREE.Vector4(),
		[5] = THREE.Vector4()
	 }
	local _projScreenMatrix = THREE.Matrix4{}
	local _projectionMatrixArray = Float32Array( 16 )
	local _viewMatrixArray = Float32Array( 16 )
	local _vector3 = THREE.Vector4()
	local _lights = {
		ambient = {[0]= 0,[1]= 0,[2]= 0 },
		directional= { length= 0, colors= {}, positions= {} },
		point= { length= 0, colors= {}, positions= {}, distances= {} }
	}
	local parameters = parameters or {}
	local _stencil = rawget(parameters,"stencil") and parameters.stencil or true
	local _antialias = rawget(parameters,"antialias") and parameters.antialias or false
	local _clearColor = rawget(parameters,"clearColor") and THREE.Color( parameters.clearColor ) or THREE.Color( 0x000000 )
	local _clearAlpha = rawget(parameters,"clearAlpha") and parameters.clearAlpha or 0
	WGLR.data = {
		vertices= 0,
		faces= 0,
		drawCalls= 0
	}
	WGLR.maxMorphTargets = 8

-----used to be: "WGLR.domElement = _canvas"
	WGLR.domElement = nil

	WGLR.autoClear = true
	WGLR.sortObjects = true

-----"initialize" WebGL
	_gl = gl

	_gl:clearColor( 0, 0, 0, 1 )
	_gl:clearDepth( 1 )
	_gl:enable( _gl.DEPTH_TEST )
	_gl:depthFunc( _gl.LEQUAL )
	_gl:frontFace( _gl.CCW )
	_gl:cullFace( _gl.BACK )
	_gl:enable( _gl.CULL_FACE )
	_gl:enable( _gl.BLEND )
	_gl:blendEquation( _gl.FUNC_ADD )
	_gl:blendFunc( _gl.SRC_ALPHA, _gl.ONE_MINUS_SRC_ALPHA )
	_gl:clearColor( _clearColor.r, _clearColor.g, _clearColor.b, _clearAlpha )
	_cullEnabled = true
	WGLR.context = _gl
-----declare functions
	function maxVertexTextures()

		return _gl:getParameter( _gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS );

	end

	function getShader( t, string )
		local shader;

		if ( t == "fragment" ) then

			shader = _gl:createShader( _gl.FRAGMENT_SHADER );

		elseif ( t == "vertex" ) then

			shader = _gl:createShader( _gl.VERTEX_SHADER );

		end

		_gl:shaderSource( shader, string );
		_gl:compileShader( shader );
		--print(shader)
		if ( not _gl:getShaderParameter( shader, _gl.COMPILE_STATUS ) ) then
			--print( _gl:getShaderInfoLog( shader ) );
			--print( string );
print("not happening")
			return nil;

		end

		return shader;

	end

	local _supportsVertexTextures = ( maxVertexTextures() > 0 )
	if ( _stencil ) then
		local _stencilShadow      = {}
		_stencilShadow.vertices = Float32Array( 12 )
		_stencilShadow.faces    = Uint16Array( 6 )
		_stencilShadow.darkness = 0.5
		_stencilShadow.vertices[ 0 * 3 + 0 ] = -20; _stencilShadow.vertices[ 0 * 3 + 1 ] = -20; _stencilShadow.vertices[ 0 * 3 + 2 ] = -1
		_stencilShadow.vertices[ 1 * 3 + 0 ] =  20; _stencilShadow.vertices[ 1 * 3 + 1 ] = -20; _stencilShadow.vertices[ 1 * 3 + 2 ] = -1
		_stencilShadow.vertices[ 2 * 3 + 0 ] =  20; _stencilShadow.vertices[ 2 * 3 + 1 ] =  20; _stencilShadow.vertices[ 2 * 3 + 2 ] = -1
		_stencilShadow.vertices[ 3 * 3 + 0 ] = -20; _stencilShadow.vertices[ 3 * 3 + 1 ] =  20; _stencilShadow.vertices[ 3 * 3 + 2 ] = -1
		_stencilShadow.faces[ 0 ] = 0; _stencilShadow.faces[ 1 ] = 1; _stencilShadow.faces[ 2 ] = 2
		_stencilShadow.faces[ 3 ] = 0; _stencilShadow.faces[ 4 ] = 2; _stencilShadow.faces[ 5 ] = 3
		_stencilShadow.vertexBuffer  = _gl:createBuffer()
		_stencilShadow.elementBuffer = _gl:createBuffer()
		_gl:bindBuffer( _gl.ARRAY_BUFFER, _stencilShadow.vertexBuffer )
		_gl:bufferData( _gl.ARRAY_BUFFER,  _stencilShadow.vertices, _gl.STATIC_DRAW )
		_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, _stencilShadow.elementBuffer )
		_gl:bufferData( _gl.ELEMENT_ARRAY_BUFFER, _stencilShadow.faces, _gl.STATIC_DRAW )
		_stencilShadow.program = _gl:createProgram()
		gl_program[_stencilShadow.program] = {}
		_gl:attachShader( _stencilShadow.program, getShader( "fragment", THREE.ShaderLib.shadowPost.fragmentShader ))
		_gl:attachShader( _stencilShadow.program, getShader( "vertex",   THREE.ShaderLib.shadowPost.vertexShader   ))
		_gl:linkProgram( _stencilShadow.program )
		_stencilShadow.vertexLocation     = _gl:getAttribLocation ( _stencilShadow.program, "position"         )
		_stencilShadow.projectionLocation = _gl:getUniformLocation( _stencilShadow.program, "projectionMatrix" )
		_stencilShadow.darknessLocation   = _gl:getUniformLocation( _stencilShadow.program, "darkness"         )
	end
	local _lensFlare = {}
	local verticesArray = {-1,-1,0,0,1,-1,1,0,1,1,1,1,-1,1,0,1}
	local faceArray =     {0,1,2,0,2,3}
	_lensFlare.vertices     = Float32Array(verticesArray)
	_lensFlare.faces        = Uint16Array(faceArray)
	_lensFlare.vertexBuffer     = _gl:createBuffer()
	_lensFlare.elementBuffer    = _gl:createBuffer()
	_lensFlare.tempTexture      = _gl:createTexture()
	_lensFlare.occlusionTexture = _gl:createTexture()
	_gl:bindBuffer( _gl.ARRAY_BUFFER, _lensFlare.vertexBuffer )
	_gl:bufferData( _gl.ARRAY_BUFFER,  _lensFlare.vertices, _gl.STATIC_DRAW )
	_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, _lensFlare.elementBuffer )
	_gl:bufferData( _gl.ELEMENT_ARRAY_BUFFER, _lensFlare.faces, _gl.STATIC_DRAW )
	_gl:bindTexture( _gl.TEXTURE_2D, _lensFlare.tempTexture )
	_gl:texImage2D( _gl.TEXTURE_2D, 0, _gl.RGB, 16, 16, 0, _gl.RGB, _gl.UNSIGNED_BYTE, nil )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.CLAMP_TO_EDGE )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.CLAMP_TO_EDGE )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.NEAREST )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.NEAREST )
	_gl:bindTexture( _gl.TEXTURE_2D, _lensFlare.occlusionTexture )
	_gl:texImage2D( _gl.TEXTURE_2D, 0, _gl.RGBA, 16, 16, 0, _gl.RGBA, _gl.UNSIGNED_BYTE, nil )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.CLAMP_TO_EDGE )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.CLAMP_TO_EDGE )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.NEAREST )
	_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.NEAREST )
	if( _gl:getParameter( _gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS ) <= 0 ) then
		_lensFlare.hasVertexTexture = false
		_lensFlare.program = _gl:createProgram()
		gl_program[_lensFlare.program] = {}
		_gl:attachShader( _lensFlare.program, getShader( "fragment", THREE.ShaderLib.lensFlare.fragmentShader ))
		_gl:attachShader( _lensFlare.program, getShader( "vertex",   THREE.ShaderLib.lensFlare.vertexShader   ))
		_gl:linkProgram( _lensFlare.program )
	else 
		_lensFlare.hasVertexTexture = true
		_lensFlare.program = _gl:createProgram()
		gl_program[_lensFlare.program] = {}
		
		_gl:attachShader( _lensFlare.program, getShader( "fragment", THREE.ShaderLib.lensFlareVertexTexture.fragmentShader ))
		_gl:attachShader( _lensFlare.program, getShader( "vertex",   THREE.ShaderLib.lensFlareVertexTexture.vertexShader   ))
		_gl:linkProgram( _lensFlare.program )
	end
	_lensFlare.attributes = {}
	_lensFlare.uniforms = {}
	_lensFlare.attributes.vertex       = _gl:getAttribLocation ( _lensFlare.program, "position" )
	_lensFlare.attributes.uv           = _gl:getAttribLocation ( _lensFlare.program, "UV" )
	_lensFlare.uniforms.renderType     = _gl:getUniformLocation( _lensFlare.program, "renderType" )
	_lensFlare.uniforms.map            = _gl:getUniformLocation( _lensFlare.program, "map" )
	_lensFlare.uniforms.occlusionMap   = _gl:getUniformLocation( _lensFlare.program, "occlusionMap" )
	_lensFlare.uniforms.opacity        = _gl:getUniformLocation( _lensFlare.program, "opacity" )
	_lensFlare.uniforms.scale          = _gl:getUniformLocation( _lensFlare.program, "scale" )
	_lensFlare.uniforms.rotation       = _gl:getUniformLocation( _lensFlare.program, "rotation" )
	_lensFlare.uniforms.screenPosition = _gl:getUniformLocation( _lensFlare.program, "screenPosition" )
	--_gl:enableVertexAttribArray( _lensFlare.attributes.vertex )
	--_gl:enableVertexAttribArray( _lensFlare.attributes.uv )
	local _lensFlareAttributesEnabled = false
	local _sprite = {}
	verticesArray = {-1,-1,0,1,1-1,1,1,1,1,1,0,-1,1,0,0}
	facesArray = {0,1,2,0,2,3}
	_sprite.vertices = Float32Array(verticesArray)
	_sprite.faces    = Uint16Array(facesArray)
	_sprite.vertexBuffer  = _gl:createBuffer()
	_sprite.elementBuffer = _gl:createBuffer()
	_gl:bindBuffer( _gl.ARRAY_BUFFER, _sprite.vertexBuffer )
	_gl:bufferData( _gl.ARRAY_BUFFER,  _sprite.vertices, _gl.STATIC_DRAW )
	_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, _sprite.elementBuffer )
	_gl:bufferData( _gl.ELEMENT_ARRAY_BUFFER, _sprite.faces, _gl.STATIC_DRAW )

	_sprite.program = _gl:createProgram()


	gl_program[_sprite.program] = {}

	_gl:attachShader( _sprite.program, getShader( "fragment", THREE.ShaderLib.sprite.fragmentShader ))
	_gl:attachShader( _sprite.program, getShader( "vertex",   THREE.ShaderLib.sprite.vertexShader   ))
	_gl:linkProgram( _sprite.program )
	_sprite.attributes = {}
	_sprite.uniforms = {}
	_sprite.attributes.position           = _gl:getAttribLocation ( _sprite.program, "position" )
	_sprite.attributes.uv                 = _gl:getAttribLocation ( _sprite.program, "uv" )
	_sprite.uniforms.uvOffset             = _gl:getUniformLocation( _sprite.program, "uvOffset" )
	_sprite.uniforms.uvScale              = _gl:getUniformLocation( _sprite.program, "uvScale" )
	_sprite.uniforms.rotation             = _gl:getUniformLocation( _sprite.program, "rotation" )
	_sprite.uniforms.scale                = _gl:getUniformLocation( _sprite.program, "scale" )
	_sprite.uniforms.alignment            = _gl:getUniformLocation( _sprite.program, "alignment" )
	_sprite.uniforms.map                  = _gl:getUniformLocation( _sprite.program, "map" )
	_sprite.uniforms.opacity              = _gl:getUniformLocation( _sprite.program, "opacity" )
	_sprite.uniforms.useScreenCoordinates = _gl:getUniformLocation( _sprite.program, "useScreenCoordinates" )
	_sprite.uniforms.affectedByDistance   = _gl:getUniformLocation( _sprite.program, "affectedByDistance" )
	_sprite.uniforms.screenPosition    	  = _gl:getUniformLocation( _sprite.program, "screenPosition" )
	_sprite.uniforms.modelViewMatrix      = _gl:getUniformLocation( _sprite.program, "modelViewMatrix" )
	_sprite.uniforms.projectionMatrix     = _gl:getUniformLocation( _sprite.program, "projectionMatrix" )
	--_gl:enableVertexAttribArray( _sprite.attributes.position )
	--_gl:enableVertexAttribArray( _sprite.attributes.uv )
	local _spriteAttributesEnabled = false
--------------end initialization
	function WGLR:setSize( width, height ) 
		--_canvas.width = width
		--_canvas.height = height
		self:setViewport( 0, 0, width, height )
	end

	function WGLR:setViewport ( x, y, width, height )
		_viewportX = x
		_viewportY = y
		_viewportWidth = width
		_viewportHeight = height
		_gl:viewport( _viewportX, _viewportY, _viewportWidth, _viewportHeight )
	end

	function WGLR:setScissor( x, y, width, height )
		_gl:scissor( x, y, width, height )
	end

	function WGLR:enableScissorTest( enable ) 
		if ( enable ) then
			_gl:enable( _gl.SCISSOR_TEST )
		else
			_gl:disable( _gl.SCISSOR_TEST )
		end
	end

	function WGLR:enableDepthBufferWrite( enable )
		_currentDepthMask = enable;
		_gl:depthMask( enable );
	end

	function WGLR:setClearColorHex( hex, alpha )
		_clearColor:setHex( hex )
		_clearAlpha = alpha
		_gl:clearColor( _clearColor.r, _clearColor.g, _clearColor.b, _clearAlpha )
	end

	function WGLR:setClearColor( color, alpha )
		_clearColor:copy( color )
		_clearAlpha = alpha
		_gl:clearColor( _clearColor.r, _clearColor.g, _clearColor.b, _clearAlpha )
	end

	function WGLR:clear()
		_gl:clear( _gl.COLOR_BUFFER_BIT)
		_gl:clear(_gl.DEPTH_BUFFER_BIT)
		_gl:clear(_gl.STENCIL_BUFFER_BIT )
	end

	function WGLR:setStencilShadowDarkness( value )
		_stencilShadow.darkness = value;
	end

	function WGLR:getContext()
		return _gl
	end
------------start local functions
	function setupLights ( program, lights )
		local l; local ll; local light; local r = 0; local g = 0; local b = 0
		local color; local position; local intensity; local distance
		local zlights = _lights
		local dcolors = zlights.directional.colors
		local dpositions = zlights.directional.positions
		local pcolors = zlights.point.colors
		local ppositions = zlights.point.positions
		local pdistances = zlights.point.distances
		local dlength = 0
		local plength = 0
		local doffset = 0
		local poffset = 0

		for k,v in pairs(lights) do
			light = v
			color = light.color
			position = light.position
			intensity = rawget(light,"intensity")
			distance = rawget(light, "distance")
			if ( getmetatable(light).types[THREE.AmbientLight] ) then
				r = r+color.r
				g = g+color.g
				b = b+color.b
			elseif ( getmetatable(light).types[THREE.DirectionalLight] ) then
				doffset = dlength * 3
				dcolors[ doffset ] = color.r * intensity
				dcolors[ doffset + 1 ] = color.g * intensity
				dcolors[ doffset + 2 ] = color.b * intensity
				dpositions[ doffset ] = position.x
				dpositions[ doffset + 1 ] = position.y
				dpositions[ doffset + 2 ] = position.z
				dlength =dlength+1
			elseif( getmetatable(light).types[THREE.PointLight] ) then
				poffset = plength * 3
				pcolors[ poffset ] = color.r * intensity
				pcolors[ poffset + 1 ] = color.g * intensity
				pcolors[ poffset + 2 ] = color.b * intensity
				ppositions[ poffset ] = position.x
				ppositions[ poffset + 1 ] = position.y
				ppositions[ poffset + 2 ] = position.z
				pdistances[ plength ] = distance
				plength = plength + 1
			end
		end
		for l = dlength*3, length(dcolors)-1 do dcolors[ l ] = 0.0 end
		for l = plength*3, length(pcolors)-1 do pcolors[ l ] = 0.0 end
		zlights.point.length = plength
		zlights.directional.length = dlength
		zlights.ambient[ 0 ] = r;
		zlights.ambient[ 1 ] = g;
		zlights.ambient[ 2 ] = b;
	end
------------end setuplights
	function createParticleBuffers ( geometry )
		geometry.__webglVertexBuffer = _gl:createBuffer()
		geometry.__webglColorBuffer = _gl:createBuffer()
	end

	function createLineBuffers( geometry )
		geometry.__webglVertexBuffer = _gl:createBuffer()
		geometry.__webglColorBuffer = _gl:createBuffer()
	end

	function createRibbonBuffers( geometry ) 
		geometry.__webglVertexBuffer = _gl:createBuffer()
		geometry.__webglColorBuffer = _gl:createBuffer()
	end

	function createMeshBuffers( geometryGroup )
		--print("createMeshBuffer")
		geometryGroup.__webglVertexBuffer = _gl:createBuffer()
		geometryGroup.__webglNormalBuffer = _gl:createBuffer()
		geometryGroup.__webglTangentBuffer = _gl:createBuffer()
		geometryGroup.__webglColorBuffer = _gl:createBuffer()
		geometryGroup.__webglUVBuffer = _gl:createBuffer()
		geometryGroup.__webglUV2Buffer = _gl:createBuffer()
		geometryGroup.__webglSkinVertexABuffer = _gl:createBuffer()
		geometryGroup.__webglSkinVertexBBuffer = _gl:createBuffer()
		geometryGroup.__webglSkinIndicesBuffer = _gl:createBuffer()
		geometryGroup.__webglSkinWeightsBuffer = _gl:createBuffer()
		geometryGroup.__webglFaceBuffer = _gl:createBuffer()
		geometryGroup.__webglLineBuffer = _gl:createBuffer()
		if ( geometryGroup.numMorphTargets ) then
			geometryGroup.__webglMorphTargetsBuffers = {}
			for m = 0, geometryGroup.numMorphTargets-1 do
				--print("372 pushing")
				push(geometryGroup.__webglMorphTargetsBuffers,_gl:createBuffer())
			end
		end
	end

	function initLineBuffers ( geometry )
		local nvertices = length(geometry.vertices)
		geometry.__vertexArray = Float32Array( nvertices * 3 )
		geometry.__colorArray = Float32Array( nvertices * 3 )
		geometry.__webglLineCount = nvertices
	end

	function initRibbonBuffers ( geometry )
		local nvertices = length(geometry.vertices)
		geometry.__vertexArray = Float32Array( nvertices * 3 );
		geometry.__colorArray = Float32Array( nvertices * 3 );
		geometry.__webglVertexCount = nvertices;
	end

	function initParticleBuffers ( geometry )
		local nvertices = length(geometry.vertices)
		geometry.__vertexArray = Float32Array( nvertices * 3 )
		geometry.__colorArray = Float32Array( nvertices * 3 )
		geometry.__sortArray = {}
		geometry.__webglParticleCount = nvertices
	end
----------------start initMeshBuffers
	function initMeshBuffers ( geometryGroup, object )
		local f; local fl, fi, face
		local m; local ml; local size
		local nvertices = 0; local ntris = 0; local nlines = 0
		local uvType
		local vertexColorType
		local normalType
		local materials; local material
		local attribute; local property; local originalAttribute

		local geometry = object.geometry
		local obj_faces = geometry.faces
		local chunk_faces = geometryGroup.faces

		for k,v in pairs(chunk_faces) do
			fi = v
			face = obj_faces[ fi ]
			if ( getmetatable(face).types[THREE.Face3] ) then
				nvertices = nvertices+3
				ntris = ntris+1
				nlines = nlines+3
			elseif ( getmetatable(face).types[THREE.Face4] ) then
				nvertices = nvertices+4
				ntris = ntris+2
				nlines = nlines+4
			end
		end
		materials = unrollGroupMaterials( geometryGroup, object )
		geometryGroup.__materials = materials
		uvType = bufferGuessUVType( materials, geometryGroup, object )
		normalType = bufferGuessNormalType( materials, geometryGroup, object )
		vertexColorType = bufferGuessVertexColorType( materials, geometryGroup, object )
		geometryGroup.__vertexArray = Float32Array( nvertices * 3 )
		if ( normalType ) then
			geometryGroup.__normalArray = Float32Array( nvertices * 3 )
		end
		if ( geometry.hasTangents ) then
			geometryGroup.__tangentArray = Float32Array( nvertices * 4 )
		end
		if ( vertexColorType ) then
			geometryGroup.__colorArray = Float32Array( nvertices * 3 )
		end
		if ( uvType ) then
			if ( length(geometry.faceUvs) > 0 or length(geometry.faceVertexUvs) > 0 ) then
				geometryGroup.__uvArray = Float32Array( nvertices * 2 );
			end
			if ( length(geometry.faceUvs) > 1 or length(geometry.faceVertexUvs) > 1 ) then
				geometryGroup.__uv2Array = Float32Array( nvertices * 2 );
			end
		end
		if ( length(object.geometry.skinWeights)>0 and length(object.geometry.skinIndices)>0 ) then
			geometryGroup.__skinVertexAArray = Float32Array( nvertices * 4 )
			geometryGroup.__skinVertexBArray = Float32Array( nvertices * 4 )
			geometryGroup.__skinIndexArray = Float32Array( nvertices * 4 )
			geometryGroup.__skinWeightArray = Float32Array( nvertices * 4 )
		end
		--print("FACEARRAYLENGTH", ntris,ntris * 3 + ( rawget(object.geometry,"edgeFaces") and length(object.geometry.edgeFaces) * 2 * 3 or 0 ))
		geometryGroup.__faceArray = Uint16Array( ntris * 3 + ( rawget(object.geometry,"edgeFaces") and length(object.geometry.edgeFaces) * 2 * 3 or 0 ))
		geometryGroup.__lineArray = Uint16Array( nlines * 2 )
		if ( geometryGroup.numMorphTargets ) then
			geometryGroup.__morphTargetsArrays = {}
			for m = 0,geometryGroup.numMorphTargets-1 do
				--print("461 pushing")
				push(geometryGroup.__morphTargetsArrays, Float32Array( nvertices * 3 ))
			end
		end
		geometryGroup.__needsSmoothNormals = ( normalType == THREE.SmoothShading )
		geometryGroup.__uvType = uvType
		geometryGroup.__vertexColorType = vertexColorType
		geometryGroup.__normalType = normalType
		geometryGroup.__webglFaceCount = ntris * 3 + ( rawget(object.geometry,"edgeFaces") and length(object.geometry.edgeFaces) * 2 * 3 or 0 )
		geometryGroup.__webglLineCount = nlines * 2
		for k,v in pairs(materials) do
			material = v
			if ( rawget(material,"attributes") ) then
				geometryGroup.__webglCustomAttributes = {}
				for a,val in pairs(material.attributes) do
					originalAttribute = val
					attribute = {}
					for property,value in originalAttribute do
						attribute[ property ] = value
					end
					if( not attribute.__webglInitialized or attribute.createUniqueBuffers ) then
						attribute.__webglInitialized = true
						size = 1
						if( attribute.type == "v2" ) then size = 2
						elseif( attribute.type == "v3" ) then size = 3
						elseif( attribute.type == "v4" ) then size = 4
						elseif( attribute.type == "c"  ) then size = 3 end
						attribute.size = size
						attribute.array = Float32Array( nvertices * size )
						attribute.buffer = _gl:createBuffer()
						attribute.buffer.belongsToAttribute = a
						originalAttribute.needsUpdate = true
						attribute.__original = originalAttribute
					end
					geometryGroup.__webglCustomAttributes[ a ] = attribute
				end
			end
		end
		geometryGroup.__inittedArrays = true
	end
------------start setMeshBuffers
	function setMeshBuffers ( geometryGroup, object, hint )
		--print(object.geometry.faces[1].normal,"HERE")
		if ( not geometryGroup.__inittedArrays ) then
			return
		end
		local f; local fl; local fi; local face
		local vertexNormals; local faceNormal; local normal
		local vertexColors; local faceColor
		local vertexTangents
		local uvType; local vertexColorType; local normalType
		local uv; local uv2; local v1; local v2; local v3; local v4; local t1; local t2; local t3; local t4
		local c1; local c2; local c3; local c4
		local sw1; local sw2; local sw3; local sw4
		local si1; local si2; local si3; local si4
		local sa1; local sa2; local sa3; local sa4
		local sb1; local sb2; local sb3; local sb4
		local m; local ml; local i
		local vn; local uvi; local uv2i
		local vk; local vkl; local vka
		local a
		local vertexIndex = 0
		local offset = 0
		local offset_uv = 0
		local offset_uv2 = 0
		local offset_face = 0
		local offset_normal = 0
		local offset_tangent = 0
		local offset_line = 0
		local offset_color = 0
		local offset_skin = 0
		local offset_morphTarget = 0
		local offset_custom = 0
		local offset_customSrc = 0
		local vertexArray = geometryGroup.__vertexArray
		local uvArray = geometryGroup.__uvArray
		local uv2Array = geometryGroup.__uv2Array
		local normalArray = geometryGroup.__normalArray
		local tangentArray = geometryGroup.__tangentArray
		local colorArray = geometryGroup.__colorArray
		local skinVertexAArray = geometryGroup.__skinVertexAArray
		local skinVertexBArray = geometryGroup.__skinVertexBArray
		local skinIndexArray = geometryGroup.__skinIndexArray
		local skinWeightArray = geometryGroup.__skinWeightArray
		local morphTargetsArrays = geometryGroup.__morphTargetsArrays
		local customAttributes = geometryGroup.__webglCustomAttributes
		local customAttribute
		local faceArray = geometryGroup.__faceArray
		local lineArray = geometryGroup.__lineArray
		local needsSmoothNormals = geometryGroup.__needsSmoothNormals
		local vertexColorType = geometryGroup.__vertexColorType
		local uvType = geometryGroup.__uvType
		local normalType = geometryGroup.__normalType
		local geometry = object.geometry
		local dirtyVertices = geometry.__dirtyVertices
		local dirtyElements = geometry.__dirtyElements
		local dirtyUvs = geometry.__dirtyUvs
		local dirtyNormals = geometry.__dirtyNormals
		local dirtyTangents = geometry.__dirtyTangents
		local dirtyColors = geometry.__dirtyColors
		local dirtyMorphTargets = geometry.__dirtyMorphTargets
		local vertices = geometry.vertices
		local chunk_faces = geometryGroup.faces
		local obj_faces = geometry.faces
		local obj_uvs  = geometry.faceVertexUvs[ 0 ]
		local obj_uvs2 = geometry.faceVertexUvs[ 1 ]
		local obj_colors = geometry.colors
		local obj_skinVerticesA = rawget(geometry,"skinVerticesA")
		local obj_skinVerticesB = rawget(geometry,"skinVerticesB")
		local obj_skinIndices = rawget(geometry,"skinIndices")
		local obj_skinWeights = rawget(geometry,"skinWeights")
		local obj_edgeFaces = getmetatable(object).types[THREE.ShadowVolume] and geometry.edgeFaces or nil
		local morphTargets = geometry.morphTargets
		if ( customAttributes ) then
			for k,a in customAttributes do
				customAttributes[ a ].offset = 0
				customAttributes[ a ].offsetSrc = 0
			end
		end
		for f,fi in pairs(chunk_faces) do
			--print("updating faces", obj_faces[1].normal)
			face = obj_faces[ fi ]
			if ( obj_uvs ) then
				uv = obj_uvs[ fi ]
			end
			if ( obj_uvs2 ) then
				uv2 = obj_uvs2[ fi ]
			end
			vertexNormals = rawget(face,"vertexNormals")
			faceNormal = face.normal
			--print("faceNormal", faceNormal, face.normal)
			vertexColors = rawget(face,"vertexColors")
			faceColor = rawget(face,"color")
			vertexTangents = rawget(face,"vertexTangents")
			if ( getmetatable(face).types[THREE.Face3] ) then
				--print("Face3")
				if ( dirtyVertices ) then
					v1 = vertices[ face.a ].position
					v2 = vertices[ face.b ].position
					v3 = vertices[ face.c ].position
					vertexArray[ offset ]     = v1.x
					vertexArray[ offset + 1 ] = v1.y
					vertexArray[ offset + 2 ] = v1.z
					vertexArray[ offset + 3 ] = v2.x
					vertexArray[ offset + 4 ] = v2.y
					vertexArray[ offset + 5 ] = v2.z
					vertexArray[ offset + 6 ] = v3.x
					vertexArray[ offset + 7 ] = v3.y
					vertexArray[ offset + 8 ] = v3.z
					offset = offset+9
				end
				if ( customAttributes ) then
					for a,customAttribute in pairs(customAttributes) do
						if ( customAttribute.__original.needsUpdate ) then
							offset_custom = customAttribute.offset
							offset_customSrc = customAttribute.offsetSrc
							if ( not customAttribute.size or customAttribute.size == 1 ) then
								if ( not customAttribute.boundTo or customAttribute.boundTo == "vertices" ) then
									customAttribute.array[ offset_custom + 0 ] = customAttribute.value[ face.a ]
									customAttribute.array[ offset_custom + 1 ] = customAttribute.value[ face.b ]
									customAttribute.array[ offset_custom + 2 ] = customAttribute.value[ face.c ]
								elseif ( customAttribute.boundTo == "faces" ) then
									customAttribute.array[ offset_custom + 0 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.array[ offset_custom + 1 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.array[ offset_custom + 2 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.offsetSrc = customAttribute.offsetSrc + 1
								elseif ( customAttribute.boundTo == "faceVertices" ) then
									customAttribute.array[ offset_custom + 0 ] = customAttribute.value[ offset_customSrc + 0 ]
									customAttribute.array[ offset_custom + 1 ] = customAttribute.value[ offset_customSrc + 1 ]
									customAttribute.array[ offset_custom + 2 ] = customAttribu3te.value[ offset_customSrc + 2 ]
									customAttribute.offsetSrc = customAttribute.offsetSrc + 3
								end
								customAttribute.offset = customAttribute.offset + 3
							else
								if ( not customAttribute.boundTo or customAttribute.boundTo == "vertices" ) then
									v1 = customAttribute.value[ face.a ]
									v2 = customAttribute.value[ face.b ]
									v3 = customAttribute.value[ face.c ]
								elseif ( customAttribute.boundTo == "faces" ) then
									v1 = customAttribute.value[ offset_customSrc ]
									v2 = customAttribute.value[ offset_customSrc ]
									v3 = customAttribute.value[ offset_customSrc ]
									customAttribute.offsetSrc = customAttribute.offsetSrc + 1
								elseif ( customAttribute.boundTo == "faceVertices" ) then
									v1 = customAttribute.value[ offset_customSrc + 0 ]
									v2 = customAttribute.value[ offset_customSrc + 1 ]
									v3 = customAttribute.value[ offset_customSrc + 2 ]
									customAttribute.offsetSrc = customAttribute.offsetSrc+3
								end
								if ( customAttribute.size == 2 ) then
									customAttribute.array[ offset_custom + 0 ] = v1.x
									customAttribute.array[ offset_custom + 1 ] = v1.y
									customAttribute.array[ offset_custom + 2 ] = v2.x
									customAttribute.array[ offset_custom + 3 ] = v2.y
									customAttribute.array[ offset_custom + 4 ] = v3.x
									customAttribute.array[ offset_custom + 5 ] = v3.y
									customAttribute.offset = customAttribute.offset+6
								elseif ( customAttribute.size == 3 ) then
									if ( customAttribute.type == "c" ) then
										customAttribute.array[ offset_custom + 0 ] = v1.r
										customAttribute.array[ offset_custom + 1 ] = v1.g
										customAttribute.array[ offset_custom + 2 ] = v1.b
										customAttribute.array[ offset_custom + 3 ] = v2.r
										customAttribute.array[ offset_custom + 4 ] = v2.g
										customAttribute.array[ offset_custom + 5 ] = v2.b
										customAttribute.array[ offset_custom + 6 ] = v3.r
										customAttribute.array[ offset_custom + 7 ] = v3.g
										customAttribute.array[ offset_custom + 8 ] = v3.b
									else
										customAttribute.array[ offset_custom + 0 ] = v1.x
										customAttribute.array[ offset_custom + 1 ] = v1.y
										customAttribute.array[ offset_custom + 2 ] = v1.z
										customAttribute.array[ offset_custom + 3 ] = v2.x
										customAttribute.array[ offset_custom + 4 ] = v2.y
										customAttribute.array[ offset_custom + 5 ] = v2.z
										customAttribute.array[ offset_custom + 6 ] = v3.x
										customAttribute.array[ offset_custom + 7 ] = v3.y
										customAttribute.array[ offset_custom + 8 ] = v3.z
									end
									customAttribute.offset = customAttribute.offset+9
								else
									customAttribute.array[ offset_custom + 0  ] = v1.x
									customAttribute.array[ offset_custom + 1  ] = v1.y
									customAttribute.array[ offset_custom + 2  ] = v1.z
									customAttribute.array[ offset_custom + 3  ] = v1.w
									customAttribute.array[ offset_custom + 4  ] = v2.x
									customAttribute.array[ offset_custom + 5  ] = v2.y
									customAttribute.array[ offset_custom + 6  ] = v2.z
									customAttribute.array[ offset_custom + 7  ] = v2.w
									customAttribute.array[ offset_custom + 8  ] = v3.x
									customAttribute.array[ offset_custom + 9  ] = v3.y
									customAttribute.array[ offset_custom + 10 ] = v3.z
									customAttribute.array[ offset_custom + 11 ] = v3.w
									customAttribute.offset = customAttribute.offset+12
								end
							end
						end
					end
				end
				if ( dirtyMorphTargets ) then
					for vk,vkv in pairs(morphTargets) do
						v1 = morphTargets[ vk ].vertices[ face.a ].position
						v2 = morphTargets[ vk ].vertices[ face.b ].position
						v3 = morphTargets[ vk ].vertices[ face.c ].position
						vka = morphTargetsArrays[ vk ]
						vka[ offset_morphTarget + 0 ] = v1.x
						vka[ offset_morphTarget + 1 ] = v1.y
						vka[ offset_morphTarget + 2 ] = v1.z
						vka[ offset_morphTarget + 3 ] = v2.x
						vka[ offset_morphTarget + 4 ] = v2.y
						vka[ offset_morphTarget + 5 ] = v2.z
						vka[ offset_morphTarget + 6 ] = v3.x
						vka[ offset_morphTarget + 7 ] = v3.y
						vka[ offset_morphTarget + 8 ] = v3.z
					end
					offset_morphTarget = offset_morphTarget+9
				end
				--print("Checking skinweights")
				if ( obj_skinWeights and length(obj_skinWeights) > 0 ) then
					--print("Have skinweights")
					sw1 = obj_skinWeights[ face.a ]
					sw2 = obj_skinWeights[ face.b ]
					sw3 = obj_skinWeights[ face.c ]
					skinWeightArray[ offset_skin ]     = sw1.x
					skinWeightArray[ offset_skin + 1 ] = sw1.y
					skinWeightArray[ offset_skin + 2 ] = sw1.z
					skinWeightArray[ offset_skin + 3 ] = sw1.w
					skinWeightArray[ offset_skin + 4 ] = sw2.x
					skinWeightArray[ offset_skin + 5 ] = sw2.y
					skinWeightArray[ offset_skin + 6 ] = sw2.z
					skinWeightArray[ offset_skin + 7 ] = sw2.w
					skinWeightArray[ offset_skin + 8 ]  = sw3.x
					skinWeightArray[ offset_skin + 9 ]  = sw3.y
					skinWeightArray[ offset_skin + 10 ] = sw3.z
					skinWeightArray[ offset_skin + 11 ] = sw3.w
					si1 = obj_skinIndices[ face.a ]
					si2 = obj_skinIndices[ face.b ]
					si3 = obj_skinIndices[ face.c ]
					skinIndexArray[ offset_skin ]     = si1.x
					skinIndexArray[ offset_skin + 1 ] = si1.y
					skinIndexArray[ offset_skin + 2 ] = si1.z
					skinIndexArray[ offset_skin + 3 ] = si1.w
					skinIndexArray[ offset_skin + 4 ] = si2.x
					skinIndexArray[ offset_skin + 5 ] = si2.y
					skinIndexArray[ offset_skin + 6 ] = si2.z
					skinIndexArray[ offset_skin + 7 ] = si2.w
					skinIndexArray[ offset_skin + 8 ]  = si3.x
					skinIndexArray[ offset_skin + 9 ]  = si3.y
					skinIndexArray[ offset_skin + 10 ] = si3.z
					skinIndexArray[ offset_skin + 11 ] = si3.w
					sa1 = obj_skinVerticesA[ face.a ]
					sa2 = obj_skinVerticesA[ face.b ]
					sa3 = obj_skinVerticesA[ face.c ]
					skinVertexAArray[ offset_skin ]     = sa1.x
					skinVertexAArray[ offset_skin + 1 ] = sa1.y
					skinVertexAArray[ offset_skin + 2 ] = sa1.z
					skinVertexAArray[ offset_skin + 3 ] = 1
					skinVertexAArray[ offset_skin + 4 ] = sa2.x
					skinVertexAArray[ offset_skin + 5 ] = sa2.y
					skinVertexAArray[ offset_skin + 6 ] = sa2.z
					skinVertexAArray[ offset_skin + 7 ] = 1
					skinVertexAArray[ offset_skin + 8 ]  = sa3.x
					skinVertexAArray[ offset_skin + 9 ]  = sa3.y
					skinVertexAArray[ offset_skin + 10 ] = sa3.z
					skinVertexAArray[ offset_skin + 11 ] = 1
					sb1 = obj_skinVerticesB[ face.a ]
					sb2 = obj_skinVerticesB[ face.b ]
					sb3 = obj_skinVerticesB[ face.c ]
					skinVertexBArray[ offset_skin ]     = sb1.x
					skinVertexBArray[ offset_skin + 1 ] = sb1.y
					skinVertexBArray[ offset_skin + 2 ] = sb1.z
					skinVertexBArray[ offset_skin + 3 ] = 1
					skinVertexBArray[ offset_skin + 4 ] = sb2.x
					skinVertexBArray[ offset_skin + 5 ] = sb2.y
					skinVertexBArray[ offset_skin + 6 ] = sb2.z
					skinVertexBArray[ offset_skin + 7 ] = 1
					skinVertexBArray[ offset_skin + 8 ]  = sb3.x
					skinVertexBArray[ offset_skin + 9 ]  = sb3.y
					skinVertexBArray[ offset_skin + 10 ] = sb3.z
					skinVertexBArray[ offset_skin + 11 ] = 1
					offset_skin = offset_skin+ 12
				end
				if ( dirtyColors and vertexColorType ) then
					if ( length(vertexColors) == 3 and vertexColorType == THREE.VertexColors ) then
						c1 = vertexColors[ 0 ]
						c2 = vertexColors[ 1 ]
						c3 = vertexColors[ 2 ]
					else 
						c1 = faceColor
						c2 = faceColor
						c3 = faceColor
					end
					colorArray[ offset_color ]     = c1.r
					colorArray[ offset_color + 1 ] = c1.g
					colorArray[ offset_color + 2 ] = c1.b
					colorArray[ offset_color + 3 ] = c2.r
					colorArray[ offset_color + 4 ] = c2.g
					colorArray[ offset_color + 5 ] = c2.b
					colorArray[ offset_color + 6 ] = c3.r
					colorArray[ offset_color + 7 ] = c3.g
					colorArray[ offset_color + 8 ] = c3.b
					offset_color = offset_color + 9
				end

				if ( dirtyTangents and geometry.hasTangents ) then
					t1 = vertexTangents[ 0 ]
					t2 = vertexTangents[ 1 ]
					t3 = vertexTangents[ 2 ]
					tangentArray[ offset_tangent ]     = t1.x
					tangentArray[ offset_tangent + 1 ] = t1.y
					tangentArray[ offset_tangent + 2 ] = t1.z
					tangentArray[ offset_tangent + 3 ] = t1.w
					tangentArray[ offset_tangent + 4 ] = t2.x
					tangentArray[ offset_tangent + 5 ] = t2.y
					tangentArray[ offset_tangent + 6 ] = t2.z
					tangentArray[ offset_tangent + 7 ] = t2.w
					tangentArray[ offset_tangent + 8 ]  = t3.x
					tangentArray[ offset_tangent + 9 ]  = t3.y
					tangentArray[ offset_tangent + 10 ] = t3.z
					tangentArray[ offset_tangent + 11 ] = t3.w
					offset_tangent = offset_tangent + 12
				end
				if ( dirtyNormals and normalType ) then
					if ( length(vertexNormals) == 3 and needsSmoothNormals ) then
						for i = 0,2 do
							vn = vertexNormals[ i ]
							normalArray[ offset_normal ]     = vn.x
							normalArray[ offset_normal + 1 ] = vn.y
							normalArray[ offset_normal + 2 ] = vn.z
							offset_normal = offset_normal + 3
						end
					else
						for i = 0,2 do
							normalArray[ offset_normal ]     = faceNormal.x
							normalArray[ offset_normal + 1 ] = faceNormal.y
							normalArray[ offset_normal + 2 ] = faceNormal.z
							offset_normal =offset_normal + 3
						end
					end
				end
				if ( dirtyUvs and uv and uvType ) then
					for i=0,2 do
						uvi = uv[ i ]
						uvArray[ offset_uv ]     = uvi.u
						uvArray[ offset_uv + 1 ] = uvi.v
						offset_uv = offset_uv+2
					end
				end
				if ( dirtyUvs and uv2 and uvType ) then
					for i=0,2 do
						uv2i = uv2[ i ]
						uv2Array[ offset_uv2 ]     = uv2i.u
						uv2Array[ offset_uv2 + 1 ] = uv2i.v
						offset_uv2 = offset_uv2 + 2
					end
				end
				if ( dirtyElements ) then
					faceArray[ offset_face ] = vertexIndex
					faceArray[ offset_face + 1 ] = vertexIndex + 1
					faceArray[ offset_face + 2 ] = vertexIndex + 2
					offset_face = offset_face+3
					lineArray[ offset_line ]     = vertexIndex
					lineArray[ offset_line + 1 ] = vertexIndex + 1
					lineArray[ offset_line + 2 ] = vertexIndex
					lineArray[ offset_line + 3 ] = vertexIndex + 2
					lineArray[ offset_line + 4 ] = vertexIndex + 1
					lineArray[ offset_line + 5 ] = vertexIndex + 2
					offset_line = offset_line+6
					vertexIndex = vertexIndex+3
				end
			elseif ( getmetatable(face).types[THREE.Face4] ) then
				--print("Face4")
				if ( dirtyVertices ) then
					v1 = vertices[ face.a ].position
					v2 = vertices[ face.b ].position
					v3 = vertices[ face.c ].position
					v4 = vertices[ face.d ].position
					vertexArray[ offset ]     = v1.x
					vertexArray[ offset + 1 ] = v1.y
					vertexArray[ offset + 2 ] = v1.z
					vertexArray[ offset + 3 ] = v2.x
					vertexArray[ offset + 4 ] = v2.y
					vertexArray[ offset + 5 ] = v2.z
					vertexArray[ offset + 6 ] = v3.x
					vertexArray[ offset + 7 ] = v3.y
					vertexArray[ offset + 8 ] = v3.z
					vertexArray[ offset + 9 ]  = v4.x
					vertexArray[ offset + 10 ] = v4.y
					vertexArray[ offset + 11 ] = v4.z
					offset = offset+12
				end
				if ( customAttributes ) then
					for k,a in pairs(customAttributes) do 
						customAttribute = customAttributes[ a ]
						if ( customAttribute.__original.needsUpdate ) then
							offset_custom = customAttribute.offset
							offset_customSrc = customAttribute.offsetSrc
							if ( customAttribute.size == 1 ) then
								if ( not customAttribute.boundTo or customAttribute.boundTo == "vertices" ) then
									customAttribute.array[ offset_custom + 0 ] = customAttribute.value[ face.a ]
									customAttribute.array[ offset_custom + 1 ] = customAttribute.value[ face.b ]
									customAttribute.array[ offset_custom + 2 ] = customAttribute.value[ face.c ]
									customAttribute.array[ offset_custom + 3 ] = customAttribute.value[ face.d ]
								elseif ( customAttribute.boundTo == "faces" ) then
									customAttribute.array[ offset_custom + 0 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.array[ offset_custom + 1 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.array[ offset_custom + 2 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.array[ offset_custom + 3 ] = customAttribute.value[ offset_customSrc ]
									customAttribute.offsetSrc=customAttribute.offsetSrc+1;
								elseif ( customAttribute.boundTo == "faceVertices" ) then
									customAttribute.array[ offset_custom + 0 ] = customAttribute.value[ offset_customSrc + 0 ]
									customAttribute.array[ offset_custom + 1 ] = customAttribute.value[ offset_customSrc + 1 ]
									customAttribute.array[ offset_custom + 2 ] = customAttribute.value[ offset_customSrc + 2 ]
									customAttribute.array[ offset_custom + 3 ] = customAttribute.value[ offset_customSrc + 3 ]
									customAttribute.offsetSrc = customAttribute.offsetSrc+4
								end
								customAttribute.offset = customAttribute.offset + 4
							else
								if ( not customAttribute.boundTo or customAttribute.boundTo == "vertices" ) then
									v1 = customAttribute.value[ face.a ]
									v2 = customAttribute.value[ face.b ]
									v3 = customAttribute.value[ face.c ]
									v4 = customAttribute.value[ face.d ]
								elseif ( customAttribute.boundTo == "faces" ) then
									v1 = customAttribute.value[ offset_customSrc ]
									v2 = customAttribute.value[ offset_customSrc ]
									v3 = customAttribute.value[ offset_customSrc ]
									v4 = customAttribute.value[ offset_customSrc ]
									customAttribute.offsetSrc = customAttribute.offsetSrc+1
								elseif( customAttribute.boundTo == "faceVertices" ) then
									v1 = customAttribute.value[ offset_customSrc + 0 ]
									v2 = customAttribute.value[ offset_customSrc + 1 ]
									v3 = customAttribute.value[ offset_customSrc + 2 ]
									v4 = customAttribute.value[ offset_customSrc + 3 ]
									customAttribute.offsetSrc = customAttribute.offsetSrc +4
								end
								if ( customAttribute.size == 2 ) then
									customAttribute.array[ offset_custom + 0 ] = v1.x
									customAttribute.array[ offset_custom + 1 ] = v1.y
									customAttribute.array[ offset_custom + 2 ] = v2.x
									customAttribute.array[ offset_custom + 3 ] = v2.y
									customAttribute.array[ offset_custom + 4 ] = v3.x
									customAttribute.array[ offset_custom + 5 ] = v3.y
									customAttribute.array[ offset_custom + 6 ] = v4.x
									customAttribute.array[ offset_custom + 7 ] = v4.y
									customAttribute.offset = customAttribute.offset+8
								elseif ( customAttribute.size == 3 ) then
									if ( customAttribute.type == "c" ) then
										customAttribute.array[ offset_custom + 0  ] = v1.r
										customAttribute.array[ offset_custom + 1  ] = v1.g
										customAttribute.array[ offset_custom + 2  ] = v1.b
										customAttribute.array[ offset_custom + 3  ] = v2.r
										customAttribute.array[ offset_custom + 4  ] = v2.g
										customAttribute.array[ offset_custom + 5  ] = v2.b
										customAttribute.array[ offset_custom + 6  ] = v3.r
										customAttribute.array[ offset_custom + 7  ] = v3.g
										customAttribute.array[ offset_custom + 8  ] = v3.b
										customAttribute.array[ offset_custom + 9  ] = v4.r
										customAttribute.array[ offset_custom + 10 ] = v4.g
										customAttribute.array[ offset_custom + 11 ] = v4.b
									else
										customAttribute.array[ offset_custom + 0  ] = v1.x
										customAttribute.array[ offset_custom + 1  ] = v1.y
										customAttribute.array[ offset_custom + 2  ] = v1.z
										customAttribute.array[ offset_custom + 3  ] = v2.x
										customAttribute.array[ offset_custom + 4  ] = v2.y
										customAttribute.array[ offset_custom + 5  ] = v2.z
										customAttribute.array[ offset_custom + 6  ] = v3.x
										customAttribute.array[ offset_custom + 7  ] = v3.y
										customAttribute.array[ offset_custom + 8  ] = v3.z
										customAttribute.array[ offset_custom + 9  ] = v4.x
										customAttribute.array[ offset_custom + 10 ] = v4.y
										customAttribute.array[ offset_custom + 11 ] = v4.z
									end
									customAttribute.offset = customAttribute.offset+12
								else
									customAttribute.array[ offset_custom + 0  ] = v1.x
									customAttribute.array[ offset_custom + 1  ] = v1.y
									customAttribute.array[ offset_custom + 2  ] = v1.z
									customAttribute.array[ offset_custom + 3  ] = v1.w
									customAttribute.array[ offset_custom + 4  ] = v2.x
									customAttribute.array[ offset_custom + 5  ] = v2.y
									customAttribute.array[ offset_custom + 6  ] = v2.z
									customAttribute.array[ offset_custom + 7  ] = v2.w
									customAttribute.array[ offset_custom + 8  ] = v3.x
									customAttribute.array[ offset_custom + 9  ] = v3.y
									customAttribute.array[ offset_custom + 10 ] = v3.z
									customAttribute.array[ offset_custom + 11 ] = v3.w
									customAttribute.array[ offset_custom + 12 ] = v4.x
									customAttribute.array[ offset_custom + 13 ] = v4.y
									customAttribute.array[ offset_custom + 14 ] = v4.z
									customAttribute.array[ offset_custom + 15 ] = v4.w
									customAttribute.offset = customAttribute.offset+16
								end
							end
						end
					end
				end
				if ( dirtyMorphTargets ) then
					for vk,v in pairs(morphTargets) do
						v1 = morphTargets[ vk ].vertices[ face.a ].position
						v2 = morphTargets[ vk ].vertices[ face.b ].position
						v3 = morphTargets[ vk ].vertices[ face.c ].position
						v4 = morphTargets[ vk ].vertices[ face.d ].position
						vka = morphTargetsArrays[ vk ]
						vka[ offset_morphTarget + 0 ] = v1.x
						vka[ offset_morphTarget + 1 ] = v1.y
						vka[ offset_morphTarget + 2 ] = v1.z
						vka[ offset_morphTarget + 3 ] = v2.x
						vka[ offset_morphTarget + 4 ] = v2.y
						vka[ offset_morphTarget + 5 ] = v2.z
						vka[ offset_morphTarget + 6 ] = v3.x
						vka[ offset_morphTarget + 7 ] = v3.y
						vka[ offset_morphTarget + 8 ] = v3.z
						vka[ offset_morphTarget + 9 ] = v4.x
						vka[ offset_morphTarget + 10 ] = v4.y
						vka[ offset_morphTarget + 11 ] = v4.z
					end
					offset_morphTarget = offset_morphTarget+12
				end
				--print("checking skinweights")
				--print(obj_skinWeights)
				if (obj_skinWeights and length(obj_skinWeights) > 0 ) then
					--print("skinweights checked")
					sw1 = obj_skinWeights[ face.a ]
					sw2 = obj_skinWeights[ face.b ]
					sw3 = obj_skinWeights[ face.c ]
					sw4 = obj_skinWeights[ face.d ]
					skinWeightArray[ offset_skin ]     = sw1.x
					skinWeightArray[ offset_skin + 1 ] = sw1.y
					skinWeightArray[ offset_skin + 2 ] = sw1.z
					skinWeightArray[ offset_skin + 3 ] = sw1.w
					skinWeightArray[ offset_skin + 4 ] = sw2.x
					skinWeightArray[ offset_skin + 5 ] = sw2.y
					skinWeightArray[ offset_skin + 6 ] = sw2.z
					skinWeightArray[ offset_skin + 7 ] = sw2.w
					skinWeightArray[ offset_skin + 8 ]  = sw3.x
					skinWeightArray[ offset_skin + 9 ]  = sw3.y
					skinWeightArray[ offset_skin + 10 ] = sw3.z
					skinWeightArray[ offset_skin + 11 ] = sw3.w
					skinWeightArray[ offset_skin + 12 ] = sw4.x
					skinWeightArray[ offset_skin + 13 ] = sw4.y
					skinWeightArray[ offset_skin + 14 ] = sw4.z
					skinWeightArray[ offset_skin + 15 ] = sw4.w
					si1 = obj_skinIndices[ face.a ]
					si2 = obj_skinIndices[ face.b ]
					si3 = obj_skinIndices[ face.c ]
					si4 = obj_skinIndices[ face.d ]
					skinIndexArray[ offset_skin ]     = si1.x
					skinIndexArray[ offset_skin + 1 ] = si1.y
					skinIndexArray[ offset_skin + 2 ] = si1.z
					skinIndexArray[ offset_skin + 3 ] = si1.w
					skinIndexArray[ offset_skin + 4 ] = si2.x
					skinIndexArray[ offset_skin + 5 ] = si2.y
					skinIndexArray[ offset_skin + 6 ] = si2.z
					skinIndexArray[ offset_skin + 7 ] = si2.w
					skinIndexArray[ offset_skin + 8 ]  = si3.x
					skinIndexArray[ offset_skin + 9 ]  = si3.y
					skinIndexArray[ offset_skin + 10 ] = si3.z
					skinIndexArray[ offset_skin + 11 ] = si3.w
					skinIndexArray[ offset_skin + 12 ] = si4.x
					skinIndexArray[ offset_skin + 13 ] = si4.y
					skinIndexArray[ offset_skin + 14 ] = si4.z
					skinIndexArray[ offset_skin + 15 ] = si4.w
					sa1 = obj_skinVerticesA[ face.a ]
					sa2 = obj_skinVerticesA[ face.b ]
					sa3 = obj_skinVerticesA[ face.c ]
					sa4 = obj_skinVerticesA[ face.d ]
					skinVertexAArray[ offset_skin ]     = sa1.x
					skinVertexAArray[ offset_skin + 1 ] = sa1.y
					skinVertexAArray[ offset_skin + 2 ] = sa1.z
					skinVertexAArray[ offset_skin + 3 ] = 1
					skinVertexAArray[ offset_skin + 4 ] = sa2.x
					skinVertexAArray[ offset_skin + 5 ] = sa2.y
					skinVertexAArray[ offset_skin + 6 ] = sa2.z
					skinVertexAArray[ offset_skin + 7 ] = 1
					skinVertexAArray[ offset_skin + 8 ]  = sa3.x
					skinVertexAArray[ offset_skin + 9 ]  = sa3.y
					skinVertexAArray[ offset_skin + 10 ] = sa3.z
					skinVertexAArray[ offset_skin + 11 ] = 1
					skinVertexAArray[ offset_skin + 12 ] = sa4.x
					skinVertexAArray[ offset_skin + 13 ] = sa4.y
					skinVertexAArray[ offset_skin + 14 ] = sa4.z
					skinVertexAArray[ offset_skin + 15 ] = 1
					sb1 = obj_skinVerticesB[ face.a ]
					sb2 = obj_skinVerticesB[ face.b ]
					sb3 = obj_skinVerticesB[ face.c ]
					sb4 = obj_skinVerticesB[ face.d ]
					skinVertexBArray[ offset_skin ]     = sb1.x
					skinVertexBArray[ offset_skin + 1 ] = sb1.y
					skinVertexBArray[ offset_skin + 2 ] = sb1.z
					skinVertexBArray[ offset_skin + 3 ] = 1
					skinVertexBArray[ offset_skin + 4 ] = sb2.x
					skinVertexBArray[ offset_skin + 5 ] = sb2.y
					skinVertexBArray[ offset_skin + 6 ] = sb2.z
					skinVertexBArray[ offset_skin + 7 ] = 1
					skinVertexBArray[ offset_skin + 8 ]  = sb3.x
					skinVertexBArray[ offset_skin + 9 ]  = sb3.y
					skinVertexBArray[ offset_skin + 10 ] = sb3.z
					skinVertexBArray[ offset_skin + 11 ] = 1
					skinVertexBArray[ offset_skin + 12 ] = sb4.x
					skinVertexBArray[ offset_skin + 13 ] = sb4.y
					skinVertexBArray[ offset_skin + 14 ] = sb4.z
					skinVertexBArray[ offset_skin + 15 ] = 1
					offset_skin = offset_skin+16
				end
				--print("skinweights doublechecked")
				if ( dirtyColors and vertexColorType ) then
					--print(vertexColors)
					if ( vertexColors and length(vertexColors) == 4 and vertexColorType == THREE.VertexColors ) then
						c1 = vertexColors[ 0 ]
						c2 = vertexColors[ 1 ]
						c3 = vertexColors[ 2 ]
						c4 = vertexColors[ 3 ]
					else
						c1 = faceColor
						c2 = faceColor
						c3 = faceColor
						c4 = faceColor
					end
					colorArray[ offset_color ]     = c1.r
					colorArray[ offset_color + 1 ] = c1.g
					colorArray[ offset_color + 2 ] = c1.b
					colorArray[ offset_color + 3 ] = c2.r
					colorArray[ offset_color + 4 ] = c2.g
					colorArray[ offset_color + 5 ] = c2.b
					colorArray[ offset_color + 6 ] = c3.r
					colorArray[ offset_color + 7 ] = c3.g
					colorArray[ offset_color + 8 ] = c3.b
					colorArray[ offset_color + 9 ]  = c4.r
					colorArray[ offset_color + 10 ] = c4.g
					colorArray[ offset_color + 11 ] = c4.b
					offset_color = offset_color + 12
				end
				if ( dirtyTangents and geometry.hasTangents ) then
					t1 = vertexTangents[ 0 ]
					t2 = vertexTangents[ 1 ]
					t3 = vertexTangents[ 2 ]
					t4 = vertexTangents[ 3 ]
					tangentArray[ offset_tangent ]     = t1.x
					tangentArray[ offset_tangent + 1 ] = t1.y
					tangentArray[ offset_tangent + 2 ] = t1.z
					tangentArray[ offset_tangent + 3 ] = t1.w
					tangentArray[ offset_tangent + 4 ] = t2.x
					tangentArray[ offset_tangent + 5 ] = t2.y
					tangentArray[ offset_tangent + 6 ] = t2.z
					tangentArray[ offset_tangent + 7 ] = t2.w
					tangentArray[ offset_tangent + 8 ]  = t3.x
					tangentArray[ offset_tangent + 9 ]  = t3.y
					tangentArray[ offset_tangent + 10 ] = t3.z
					tangentArray[ offset_tangent + 11 ] = t3.w
					tangentArray[ offset_tangent + 12 ] = t4.x
					tangentArray[ offset_tangent + 13 ] = t4.y
					tangentArray[ offset_tangent + 14 ] = t4.z
					tangentArray[ offset_tangent + 15 ] = t4.w
					offset_tangent = offset_tangent+16
				end
				if ( dirtyNormals and normalType ) then
					--print("normals", vertexNormals)
					if ( vertexNormals and length(vertexNormals) == 4 and needsSmoothNormals ) then
						for i=0,3 do
							vn = vertexNormals[ i ]
							normalArray[ offset_normal ]     = vn.x
							normalArray[ offset_normal + 1 ] = vn.y
							normalArray[ offset_normal + 2 ] = vn.z
							offset_normal = offset_normal+3
						end
					else
						for i=0,3 do
							--print(object.geometry.faces[1].normal,"HERE")
							normalArray[ offset_normal ]     = faceNormal.x
							normalArray[ offset_normal + 1 ] = faceNormal.y
							normalArray[ offset_normal + 2 ] = faceNormal.z
							offset_normal = offset_normal + 3
						end
					end
				end
				if ( dirtyUvs and uv and uvType ) then
					for i=0,3 do
						uvi = uv[ i ]
						uvArray[ offset_uv ]     = uvi.u
						uvArray[ offset_uv + 1 ] = uvi.v
						offset_uv = offset_uv + 2
					end
				end

				if ( dirtyUvs and uv2 and uvType ) then
					for i=0,3 do
						uv2i = uv2[ i ]
						uv2Array[ offset_uv2 ]     = uv2i.u
						uv2Array[ offset_uv2 + 1 ] = uv2i.v
						offset_uv2 = offset_uv2+2
					end
				end
				if ( dirtyElements ) then
					--print("DIRTYELEMENTS 1212")
					faceArray[ offset_face ]     = vertexIndex
					faceArray[ offset_face + 1 ] = vertexIndex + 1
					faceArray[ offset_face + 2 ] = vertexIndex + 3
					faceArray[ offset_face + 3 ] = vertexIndex + 1
					faceArray[ offset_face + 4 ] = vertexIndex + 2
					faceArray[ offset_face + 5 ] = vertexIndex + 3
					offset_face = offset_face+6
					lineArray[ offset_line ]     = vertexIndex
					lineArray[ offset_line + 1 ] = vertexIndex + 1
					lineArray[ offset_line + 2 ] = vertexIndex
					lineArray[ offset_line + 3 ] = vertexIndex + 3
					lineArray[ offset_line + 4 ] = vertexIndex + 1
					lineArray[ offset_line + 5 ] = vertexIndex + 2
					lineArray[ offset_line + 6 ] = vertexIndex + 2
					lineArray[ offset_line + 7 ] = vertexIndex + 3
					offset_line = offset_line+8
					vertexIndex = vertexIndex+4
				end
			end
		end
		if ( obj_edgeFaces ) then
			for f,v in pairs(obj_edgeFaces) do
				faceArray[ offset_face ]     = obj_edgeFaces[ f ].a
				faceArray[ offset_face + 1 ] = obj_edgeFaces[ f ].b
				faceArray[ offset_face + 2 ] = obj_edgeFaces[ f ].c
				faceArray[ offset_face + 3 ] = obj_edgeFaces[ f ].a
				faceArray[ offset_face + 4 ] = obj_edgeFaces[ f ].c
				faceArray[ offset_face + 5 ] = obj_edgeFaces[ f ].d
				offset_face = offset_face + 6
			end
		end
		if ( dirtyVertices ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglVertexBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, vertexArray, hint )
		end
		if ( customAttributes ) then
			for a,v in pairs(customAttributes) do
				customAttribute = v
				if ( customAttribute.__original.needsUpdate ) then
					_gl:bindBuffer( _gl.ARRAY_BUFFER, customAttribute.buffer )
					_gl:bufferData( _gl.ARRAY_BUFFER, customAttribute.array, hint )
				end
			end
		end
		if ( dirtyMorphTargets ) then
			for vk,vkv in pairs(morphTargets) do
				_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglMorphTargetsBuffers[ vk ] )
				_gl:bufferData( _gl.ARRAY_BUFFER, morphTargetsArrays[ vk ], hint )
			end
		end
		if ( dirtyColors and offset_color > 0 ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglColorBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, colorArray, hint )
		end
		if ( dirtyNormals ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglNormalBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, normalArray, hint )
		end
		if ( dirtyTangents and geometry.hasTangents ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglTangentBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, tangentArray, hint )
		end

		if ( dirtyUvs and offset_uv > 0 ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglUVBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, uvArray, hint )
		end
		if ( dirtyUvs and offset_uv2 > 0 ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglUV2Buffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, uv2Array, hint )
		end
		if ( dirtyElements ) then
			_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, geometryGroup.__webglFaceBuffer )
			_gl:bufferData( _gl.ELEMENT_ARRAY_BUFFER, faceArray, hint )
			_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, geometryGroup.__webglLineBuffer )
			_gl:bufferData( _gl.ELEMENT_ARRAY_BUFFER, lineArray, hint )
		end
		if ( offset_skin > 0 ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinVertexABuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, skinVertexAArray, hint )
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinVertexBBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, skinVertexBArray, hint )
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinIndicesBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, skinIndexArray, hint )
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinWeightsBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, skinWeightArray, hint )
		end
		if ( not object.dynamic ) then
			geometryGroup.__inittedArrays = nil
			geometryGroup.__colorArray = nil
			geometryGroup.__normalArray = nil
			geometryGroup.__tangentArray = nil
			geometryGroup.__uvArray = nil
			geometryGroup.__uv2Array = nil
			geometryGroup.__faceArray = nil
			geometryGroup.__vertexArray = nil
			geometryGroup.__lineArray = nil
			geometryGroup.__skinVertexAArray = nil
			geometryGroup.__skinVertexBArray = nil
			geometryGroup.__skinIndexArray = nil
			geometryGroup.__skinWeightArray = nil
		end
	end
---------------end setMeshBuffers
	function setLineBuffers ( geometry, hint )
		local v; local c; local vertex; local offset
		local vertices = geometry.vertices
		local colors = geometry.colors
		local vl = length(vertices)
		local cl = length(colors)
		local vertexArray = geometry.__vertexArray
		local colorArray = geometry.__colorArray
		local dirtyVertices = geometry.__dirtyVertices
		local dirtyColors = geometry.__dirtyColors
		if ( dirtyVertices ) then
			for v = 0,vl-1 do
				vertex = vertices[ v ].position
				offset = v * 3
				vertexArray[ offset ]     = vertex.x
				vertexArray[ offset + 1 ] = vertex.y
				vertexArray[ offset + 2 ] = vertex.z
			end
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometry.__webglVertexBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, vertexArray, hint )
		end
		if ( dirtyColors ) then
			for c = 0,cl-1 do 
				color = colors[ c ]
				offset = c * 3
				colorArray[ offset ]     = color.r
				colorArray[ offset + 1 ] = color.g
				colorArray[ offset + 2 ] = color.b
			end
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometry.__webglColorBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, colorArray, hint )
		end
	end

	function setRibbonBuffers ( geometry, hint )
		local v; local c; local vertex; local offset
		local vertices = geometry.vertices
		local colors = geometry.colors
		local vl = length(vertices)
		local cl = length(colors)
		local vertexArray = geometry.__vertexArray
		local colorArray = geometry.__colorArray
		local dirtyVertices = geometry.__dirtyVertices
		local dirtyColors = geometry.__dirtyColors
		if ( dirtyVertices ) then
			for v = 0,vl-1 do 
				vertex = vertices[ v ].position
				offset = v * 3
				vertexArray[ offset ]     = vertex.x
				vertexArray[ offset + 1 ] = vertex.y
				vertexArray[ offset + 2 ] = vertex.z
			end
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometry.__webglVertexBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, vertexArray, hint )
		end
		if ( dirtyColors ) then
			for c = 0,cl-1 do
				color = colors[ c ]
				offset = c * 3
				colorArray[ offset ]     = color.r
				colorArray[ offset + 1 ] = color.g
				colorArray[ offset + 2 ] = color.b
			end
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometry.__webglColorBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, colorArray, hint )
		end
	end

	function setParticleBuffers ( geometry, hint, object )
		local v; local c; local vertex; local offset
		local vertices = geometry.vertices
		local vl = length(vertices)
		local colors = geometry.colors
		local cl = length(colors)
		local vertexArray = geometry.__vertexArray
		local colorArray = geometry.__colorArray
		local sortArray = geometry.__sortArray
		local dirtyVertices = geometry.__dirtyVertices
		local dirtyElements = geometry.__dirtyElements
		local dirtyColors = geometry.__dirtyColors
		if ( object.sortParticles ) then
			_projScreenMatrix:multiplySelf( object.matrixWorld )
			for v = 0,vl-1 do
				vertex = vertices[ v ].position
				_vector3:copy( vertex )
				_projScreenMatrix:multiplyVector3( _vector3 )
				sortArray[ v ] = {[0]=_vector3.z, [1]=v }
			end
			sortArray:sort( function(a,b) return b[0] - a[0] end )
			for v = 0,vl-1 do
				vertex = vertices[ sortArray[v][1] ].position
				offset = v * 3
				vertexArray[ offset ]     = vertex.x
				vertexArray[ offset + 1 ] = vertex.y
				vertexArray[ offset + 2 ] = vertex.z
			end
			for c = 0,cl-1 do
				offset = c * 3
				color = colors[ sortArray[c][1] ]
				colorArray[ offset ]     = color.r
				colorArray[ offset + 1 ] = color.g
				colorArray[ offset + 2 ] = color.b
			end
		else
			if ( dirtyVertices ) then
				for v = 0,vl do
					vertex = vertices[ v ].position
					offset = v * 3
					vertexArray[ offset ]     = vertex.x
					vertexArray[ offset + 1 ] = vertex.y
					vertexArray[ offset + 2 ] = vertex.z
				end
			end
			if ( dirtyColors ) then
				for c = 0,cl-1 do
					color = colors[ c ]
					offset = c * 3
					colorArray[ offset ]     = color.r
					colorArray[ offset + 1 ] = color.g
					colorArray[ offset + 2 ] = color.b
				end
			end
		end
		if ( dirtyVertices or object.sortParticles ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometry.__webglVertexBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, vertexArray, hint )
		end
		if ( dirtyColors or object.sortParticles ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometry.__webglColorBuffer )
			_gl:bufferData( _gl.ARRAY_BUFFER, colorArray, hint )
		end
	end
-------------end buffer sets
	function setMaterialShaders( material, shaders )
		material.uniforms = THREE.UniformsUtils.clone( shaders.uniforms )
		for k,v in pairs(shaders) do
			--print(k,v)
		end
		material.vertexShader = shaders.vertexShader
		material.fragmentShader = shaders.fragmentShader
	end

	function refreshUniformsCommon( uniforms, material )
		local bool

		uniforms.diffuse.value = rawget(material, "color")
		uniforms.opacity.value = rawget(material, "opacity")
		uniforms.map.texture = rawget(material, "map")
		if ( rawget(material,"map") ) then
			uniforms.offsetRepeat.value:set( material.map.offset.x, material.map.offset.y, material.map.repeats.x, material.map.repeats.y )
		end
		uniforms.lightMap.texture = rawget(material,"lightMap")
		uniforms.envMap.texture = rawget(material, "envMap")
		uniforms.reflectivity.value = rawget(material, "reflectivity")
		uniforms.refractionRatio.value = rawget(material, "refractionRatio")
		uniforms.combine.value = rawget(material, "combine")

---MAY NOT BE CORRECT
---uniforms.useRefract.value = ??
		if (rawget(material, "envMap") and getmetatable(material.envMap.mapping).types[THREE.CubeRefractionMapping]) then bool=1 else bool=0 end
		uniforms.useRefract.value = bool
	end

	function refreshUniformsLine( uniforms, material )
		uniforms.diffuse.value = material.color
		uniforms.opacity.value = material.opacity
		uniforms.size.value = material.size
	end

	function refreshUniformsParticle( uniforms, material )
		uniforms.psColor.value = material.color
		uniforms.opacity.value = material.opacity
		uniforms.size.value = material.size
		uniforms.scale.value = _canvas.height / 2.0
		uniforms.map.texture = material.map
	end

	function refreshUniformsFog( uniforms, fog )
		uniforms.fogColor.value = fog.color
		if ( getmetatable(fog).types[THREE.Fog] ) then
			uniforms.fogNear.value = fog.near
			uniforms.fogFar.value = fog.far
		elseif ( getmetatable(fog).types[THREE.FogExp2] ) then
			uniforms.fogDensity.value = fog.density
		end
	end

	function refreshUniformsPhong( uniforms, material )
		uniforms.ambient.value = material.ambient
		uniforms.specular.value = material.specular
		uniforms.shininess.value = material.shininess
	end

	function refreshUniformsLights( uniforms, lights )
		uniforms.enableLighting.value = lights.directional.length + lights.point.length
		uniforms.ambientLightColor.value = lights.ambient
		uniforms.directionalLightColor.value = lights.directional.colors
		uniforms.directionalLightDirection.value = lights.directional.positions
		uniforms.pointLightColor.value = lights.point.colors
		uniforms.pointLightPosition.value = lights.point.positions
		uniforms.pointLightDistance.value = lights.point.distances
	end

	function WGLR:initMaterial( material, lights, fog, object )
		local u; local a; local identifiers; local i; local parameters; local maxLightCount; local maxBones; local shaderID
		if ( getmetatable(material).types[THREE.MeshDepthMaterial] ) then
			shaderID = "depth";
		elseif ( getmetatable(material).types[THREE.ShadowVolumeDynamicMaterial] ) then
			shaderID = "shadowVolumeDynamic"
		elseif ( getmetatable(material).types[THREE.MeshNormalMaterial] ) then
			shaderID = "normal"
		elseif ( getmetatable(material).types[THREE.MeshBasicMaterial] ) then
			shaderID = "basic"
		elseif ( getmetatable(material).types[THREE.MeshLambertMaterial] ) then
			shaderID = "lambert"
		elseif ( getmetatable(material).types[THREE.MeshPhongMaterial] ) then
			shaderID = "phong"
		elseif ( getmetatable(material).types[THREE.LineBasicMaterial] ) then
			shaderID = "basic"
		elseif ( getmetatable(material).types[THREE.ParticleBasicMaterial] ) then
			shaderID = "particle_basic"
		end
		if ( shaderID ) then
			setMaterialShaders( material, THREE.ShaderLib[ shaderID ] )
		end
		maxLightCount = allocateLights( lights, 4 )
		maxBones = allocateBones( object )
		parameters = {
			map=rawget(material,"map")~=nil, envMap=rawget(material,"envMap")~=nil, lightMap=rawget(material,"lightMap")~=nil,
			vertexColors=material.vertexColors,
			fog=fog, sizeAttenuation=rawget(material,"sizeAttenuation"),
			skinning=rawget(material,"skinning"),
			morphTargets=rawget(material,"morphTargets"),
			maxMorphTargets=rawget(WGLR,"maxMorphTargets"),
			maxDirLights=rawget(maxLightCount,"directional"), maxPointLights=rawget(maxLightCount,"point"),
			maxBones=maxBones
		}
		material.program = buildProgram( shaderID, material.fragmentShader, material.vertexShader, material.uniforms, rawget(material,"attributes"), parameters )
		local attributes = gl_program[material.program].attributes
		if ( attributes.position >= 0 ) then _gl:enableVertexAttribArray( attributes.position ) end
		if ( attributes.color >= 0 ) then _gl:enableVertexAttribArray( attributes.color ) end
		if ( attributes.normal >= 0 ) then _gl:enableVertexAttribArray( attributes.normal ) end
		if ( attributes.tangent >= 0 ) then _gl:enableVertexAttribArray( attributes.tangent ) end
		if ( material.skinning and
			 attributes.skinVertexA >=0 and attributes.skinVertexB >= 0 and
			 attributes.skinIndex >= 0 and attributes.skinWeight >= 0 ) then
			_gl:enableVertexAttribArray( attributes.skinVertexA )
			_gl:enableVertexAttribArray( attributes.skinVertexB )
			_gl:enableVertexAttribArray( attributes.skinIndex )
			_gl:enableVertexAttribArray( attributes.skinWeight )
		end
		if ( rawget(material,"attributes") ) then
			for a,av in pairs( material.attributes ) do
				if( attributes[ a ] and attributes[ a ] >= 0 ) then _gl:enableVertexAttribArray( attributes[ a ] ) end
			end
		end
		if ( material.morphTargets ) then
			material.numSupportedMorphTargets = 0
			if ( attributes.morphTarget0 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget0 )
				material.numSupportedMorphTargets= material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget1 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget1 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget2 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget2 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget3 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget3 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget4 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget4 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget5 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget5 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget6 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget6 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			if ( attributes.morphTarget7 >= 0 ) then
				_gl:enableVertexAttribArray( attributes.morphTarget7 )
				material.numSupportedMorphTargets = material.numSupportedMorphTargets+1
			end
			object.__webglMorphTargetInfluences = Float32Array( WGLR.maxMorphTargets )
			for i = 0,WGLR.maxMorphTargets-1 do
				object.__webglMorphTargetInfluences[ i ] = 0
			end
		end
	end
----------setProgram
	function setProgram( camera, lights, fog, material, object )
		--print("SETPROGRAM")
		if ( not rawget(material, "program") ) then
			_this:initMaterial( material, lights, fog, object )
		end
		local program = material.program
		local p_uniforms = gl_program[program].uniforms
		local m_uniforms = material.uniforms
		if ( program ~= _currentProgram ) then
			_gl:useProgram( program )
			_currentProgram = program
		end
		_gl:uniformMatrix4fv( p_uniforms.projectionMatrix, false, _projectionMatrixArray )
		if ( fog and (
			 getmetatable(material).types[THREE.MeshBasicMaterial] or
			 getmetatable(material).types[THREE.MeshLambertMaterial] or
			 getmetatable(material).types[THREE.MeshPhongMaterial] or
			 getmetatable(material).types[THREE.LineBasicMaterial] or
			 getmetatable(material).types[THREE.ParticleBasicMaterial] or
			 material.fog )
			) then
			refreshUniformsFog( m_uniforms, fog )
		end
		if ( getmetatable(material).types[THREE.MeshPhongMaterial] or
			 getmetatable(material).types[THREE.MeshLambertMaterial] or
			 rawget(material, "lights") ) then
			setupLights( program, lights )
			refreshUniformsLights( m_uniforms, _lights )
		end
		if ( getmetatable(material).types[THREE.MeshBasicMaterial] or
			 getmetatable(material).types[THREE.MeshLambertMaterial] or
			 getmetatable(material).types[THREE.MeshPhongMaterial] ) then
			refreshUniformsCommon( m_uniforms, material )
		end
		if ( getmetatable(material).types[THREE.LineBasicMaterial] ) then
			refreshUniformsLine( m_uniforms, material )
		elseif ( getmetatable(material).types[THREE.ParticleBasicMaterial] ) then
			refreshUniformsParticle( m_uniforms, material )
		elseif ( getmetatable(material).types[THREE.MeshPhongMaterial] ) then
			refreshUniformsPhong( m_uniforms, material )
		elseif ( getmetatable(material).types[THREE.MeshDepthMaterial] ) then
			m_uniforms.mNear.value = camera.near
			m_uniforms.mFar.value = camera.far
			m_uniforms.opacity.value = material.opacity
		elseif ( getmetatable(material).types[THREE.MeshNormalMaterial] ) then
			m_uniforms.opacity.value = material.opacity
		end
		loadUniformsGeneric( program, m_uniforms )
		loadUniformsMatrices( p_uniforms, object )
		if ( getmetatable(material).types[THREE.MeshShaderMaterial] or
			 getmetatable(material).types[THREE.MeshPhongMaterial] or
			 rawget(material, "envMap") ) then
			if( p_uniforms.cameraPosition ) then
				_gl:uniform3f( p_uniforms.cameraPosition, camera.position.x, camera.position.y, camera.position.z )
			end
		end

		if ( getmetatable(material).types[THREE.MeshShaderMaterial] or
			 rawget(material, "envMap") or
			 rawget(material, "skinning") ) then
			if ( p_uniforms.objectMatrix) then
				_gl:uniformMatrix4fv( p_uniforms.objectMatrix, false, object._objectMatrixArray )
			end
		end

		if ( getmetatable(material).types[THREE.MeshPhongMaterial] or
			 getmetatable(material).types[THREE.MeshLambertMaterial] or
			 getmetatable(material).types[THREE.MeshShaderMaterial] or
			 material.skinning ) then
			if( p_uniforms.viewMatrix ) then
				_gl:uniformMatrix4fv( p_uniforms.viewMatrix, false, _viewMatrixArray )
			end
		end
		if ( getmetatable(material).types[THREE.ShadowVolumeDynamicMaterial] ) then
			local dirLight = m_uniforms.directionalLightDirection.value
			dirLight[ 0 ] = -lights[ 1 ].position.x
			dirLight[ 1 ] = -lights[ 1 ].position.y
			dirLight[ 2 ] = -lights[ 1 ].position.z
			_gl:uniform3fv( p_uniforms.directionalLightDirection, dirLight )
			_gl:uniformMatrix4fv( p_uniforms.objectMatrix, false, object._objectMatrixArray )
			_gl:uniformMatrix4fv( p_uniforms.viewMatrix, false, _viewMatrixArray )
		end
		if ( material.skinning ) then
			loadUniformsSkinning( p_uniforms, object )
		end
		return program
	end

	function renderBuffer( camera, lights, fog, material, geometryGroup, object )
		--print("renderBuffer",geometryGroup)
		if (material.opacity == 0) then return; end
		local program = setProgram(camera, lights, fog, material, object)
		local attributes = gl_program[program].attributes
		
		-- vertices

		if (not material.morphTargets and attributes.position >= 0) then
			_gl:bindBuffer(_gl.ARRAY_BUFFER, geometryGroup.__webglVertexBuffer)
			_gl:vertexAttribPointer( attributes.position, 3, _gl.FLOAT, false, 0, 0)
		else
			setupMorphTargets (material, geometryGroup, object)
		end

		-- custom attributes
		
		-- Use the per-geometryGroup custom attribute arrays which are setup in initMeshBuffers

		local attribute		

		if ( rawget(geometryGroup, "__webglCustomAttributes") ) then
			for k, a in pairs(geometryGroup.__webglCustomAttributes) do
				if (attributes[a] >= 0) then
					attribute = geometryGroup.__webglCustomAttributes[a]
					_gl:bindBuffer(_gl.ARRAY_BUFFER, attribute.buffer)
					_gl:vertexAttribPointer(attributes[a], attribute.size, _gl.FLOAT, false, 0, 0)
				end
			end
		end

--[[
		if (rawget(material, attributes)) then
			for k, a in pairs(material.attributes) do
				if (attributes[a] ~= nil and attributes[a] >= 0) then
					attribute = material.attributes[a]
					if (attribute.buffer) then
						_gl:bindBuffer( _gl.ARRAY_BUFFER, attribute.buffer)
						_gl:vertextAttribPointer( attributes[a], attribute.size, _gl.FlOAT, false, 0, 0)
					end
				end
			end
		end]]

		-- colors

		if (attributes.color >= 0) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglColorBuffer)
			_gl:vertexAttribPointer( attributes.color, 3, _gl.FLOAT, false, 0, 0)
		end
		
		--normals
		
		if (attributes.normal >= 0) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglNormalBuffer)
			_gl:vertexAttribPointer( attributes.normal, 3, _gl.FLOAT, false, 0, 0)
		end

		--tangents
		
		if (attributes.tangent >= 0) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglTangentBuffer)
			_gl:vertexAttribPointer( attributes.tangent, 4, _gl.FLOAT, false, 0, 0)
		end
		
		--uvs

		if (attributes.uv >= 0) then
			if (rawget(geometryGroup, "__webglUVBuffer") ) then
				_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglUVBuffer)
				_gl:vertexAttribPointer( attributes.uv, 2, _gl.FLOAT, false, 0, 0)

				_gl:enableVertexAttribArray( attributes.uv)
			else
				_gl:disableVertexAttribArray( attributes.uv)
			end
		end

		if (attributes.uv2 >= 0) then
			if (rawget(geometryGroup, "__webglUV2Buffer")) then
				_gl:bindBuffer( _gl_ARRAY_BUFFER, geometryGroup.__webglUV2Buffer)
				_gl:vertexAttribPointer( attributes.uv2, 2, _gl.FLOAT, false, 0, 0)
				_gl:enableVertexAttribArray( attributes.uv2)
			else
				_gl:disableVertexAttribArray( attributes.uv2)
			end
		end

		if (rawget(material, "skinning") and attributes.skinVertexA >= 0 and attributes.skinVertexB >= 0 and
		 	attributes.skinIndex >= 0 and attributes.skinWeight >= 0) then
			
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinVertexABuffer)
			_gl:vertexAttribPointer( attributes.skinVertexA, 4, _gl.FLOAT, false, 0, 0)

			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinVertexBBuffer)
			_gl:vertexAttribPointer( attributes.skinVertexB, 4, _gl.FLOAT, false, 0, 0)

			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinIndicesBuffer)
			_gl:vertexAttribPointer( attributes.skinIndex, 4, _gl.FLOAT, false, 0, 0)

			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglSkinWeightsBuffer)
			_gl:vertexAttribPointer( attributes.skinWeight, 4, _gl.FLOAT, false, 0, 0)
		end

		-- render mesh

		if ( getmetatable(object).types[THREE.Mesh]) then
			
			-- wireframe
			if (rawget(material, "wireframe") ) then
				_gl:lineWidth( material.wireframeLinewidth)
				_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, geometryGroup.__webglLineBuffer)
				foo( _gl.LINES, geometryGroup.__webglLineCount, _gl.UNSIGNED_SHORT, 0)
			else

			--triangles
				--print("foo (DRAWELEMENTS)", geometryGroup.__webglFaceBuffer, geometryGroup.__webglFaceCount)
				_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, geometryGroup.__webglFaceBuffer)
				foo( _gl.TRIANGLES, geometryGroup.__webglFaceCount, _gl.UNSIGNED_SHORT, 0)
			end

			_this.data.vertices = _this.data.vertices + geometryGroup.__webglFaceCount
			_this.data.faces = _this.data.faces + geometryGroup.__webglFaceCount / 3
			_this.data.drawCalls = _this.data.drawCalls + 1

		elseif (getmetatable(object).types[THREE.ParticleSystem]) then
			foo2( _gl.POINTS, 0, geometryGroup.__webglParticleCount)
	
			_this.data.drawCalls = _this.data.drawCalls + 1
		elseif (getmetatable(object).types[THREE.Ribbon]) then
			foo2( _gl.TRIANGLE_STRIP, 0, geometryGroup.__webglVertexCount)
			_this.data.drawCalls = _this.data.drawCalls + 1
		end 

	end

	function setupMorphTargets (material, geometryGroup, object)
		-- set base

		local attributes = gl_program[material.program].attributes

		if (object.morphTargetBase ~= -1) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglMorphTargetsBuffers[object.morphTargetBase] )
			_gl:vertexAttribPointer( attributes.position, 3, _gl.FLOAT, false, 0, 0)
		elseif ( attributes.position >= 0 ) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglVertexBuffer )
			_gl:vertexAttribPointer( attributes.position, 3, _gl.FLOAT, false, 0, 0)
		end

		if (length(object.morphTargetForcedOrder) ~= 0) then
			-- set forced order

			local m = 0
			local order = object.morphTargetForcedOrder
			local influences = object.morphTargetInfluencees

			while (m < material.numSupportedMorphTargets and m < length(order)) do
				_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglMorphTargetsBuffers[order[m]] )
				_gl:vertexAttribPointer( attributes[ "morphTarget" + m], 3, _gl.FLOAT, false, 0, 0)
				object.__webglMorphTargetInfluences[m] = influences[order[m]]
	
				m = m + 1
			end
		else
			-- find most influencing

			local used = {}
			local candidateInfluence = -1
			local candidate = 0
			local influences = object.morphTargetInfluences
			local il = length(influences) - 1
			local m = 0

			if (object.morphTargetBase ~= -1) then
				used[object.morphTargetBase] = true
			end

			while (m < material.numSupportedMorphTargets) do
				for i = 0, il do
					if (not used[i] and influences[i] > candidateInfluence) then
						candidate = i
						candidateInfluence = influences[candidate]
					end
				end

				_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglMorphTargetsBuffers[candidate])
				_gl:vertexAttribPointer( attributes["morphTarget" + m], 3, _gl.FLOAT, false, 0, 0)

				object.__webglMorphTargetInfluences[m] = candidateInfluence

				used[candidate] = 1
				candidateInfluence = -1
				m = m + 1
			end
		end

		-- load updated influences uniform

		if (gl_program[material.program].uniforms.morphTargetInfluences ~= nil) then
			_gl:uniform1fv( gl_program[material.program].uniforms.morphTargetInfluences, object.__webglMorphTargetInfluences)
		end
	end

	function renderBufferImmediate( object, program, shading) 
		if (not object.__webglVertexBuffer) then object.__webglVertexBuffer = _gl:createBuffer() end
		if (not object.__webglNormalBuffer) then object.__webglNormalBuffer = _gl:createBuffer() end

		if (object.hasPos) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, object.__webglVertexBuffer)
			_gl:bufferData( _gl.ARRAY_BUFFER, object.positionArray, _gl.DYNAMIC_DRAW)
			_gl:enableVertexAttribArray( gl_program[program].attributes.position)
			_gl:vertexAttribPointer( gl_program[program].attributes.position, 3, _gl.FLOAT, false, 0, 0)
		end

		if (object.hasNormal) then
			_gl:bindBuffer( _gl.ARRAY_BUFFER, object.__webglNormalBuffer)

			if (shading == THREE.FlatShading) then
				local il = object.count * 3 - 1
				local nx, ny, nz, nax, nbx, ncx, nay, nby, ncy, naz, nbz, ncz, normalArray

				for i = 0, il, 9 do
					normalArray = object.normalArray
					nax = normalArray[i]
					nay = normalArray[i + 1]
					naz = normalArray[i + 2]

					nbx = normalArray[i + 3]
					nby = normalArray[i + 4]
					nbz = normalArray[i + 5]

					ncx = normalArray[i + 6]
					ncy = normalArray[i + 7]
					ncz = normalArray[i + 8]

					nx = ( nax + nbx + ncx ) / 3
					ny = ( nay + nby + ncy ) / 3
					nz = ( naz + nbz + ncz ) / 3

					normalArray[i]     = nx
					normalArray[i + 1] = ny
					normalArray[i + 2] = nz

					normalArray[i + 3] = nx
					normalArray[i + 4] = ny
					normalArray[i + 5] = nz

					normalArray[i + 6] = nx
					normalArray[i + 7] = ny
					normalArray[i + 8] = nz
				end
			end

			_gl:bufferData( _gl.ARRAY_BUFFER, object.normalArray, _gl.DYNAMIC_DRAW )
			_gl:enableVertexAttribArray( gl_program[program].attributes.normal)
			_gl:vertexAttribPointer( g_program[program].attributes.normal, 3, _gl.FLOAT, false, 0, 0)

		end

		foo2( _gl.TRIANGLES, 0, object.count)

		object.count = 0
	end

	function setObjectFaces( object ) 
		if (_oldDoubleSided ~= object.doubleSided) then
			if (object.doubleSided) then
				_gl:disable( _gl.CULL_FACE)
			else
				_gl:enable( _gl.CULL_FACE)
			end
		

			_oldDoubleSided = object.doubleSided
		end
	
		if (_oldFlipSided ~= object.flipSided) then
			if (object.flipSided) then
				_gl:frontFace( _gl.CW)
			else
				_gl:frontFace( _gl.CCW)
			end
		

			_oldFlipSided = object.flipSided
		end

	end

	function setDepthTest( test ) 
		if ( _oldDepth ~= test ) then
			if (test) then
				_gl:enable( _gl.DEPTH_TEST)
			else 
				_gl:disable( _gl.DEPTH_TEST)
			end

			_oldDepth = test
		end
	end

	function setPolygonOffset (polygonoffset, factor, units)
		if ( _oldPolygonOffset ~= polygonoffset) then
			if (polygonoffset) then
				_gl:enable( _gl.POLYGON_OFFSET_FILL)
			else
				_gl:disable( _gl.POLYGON_OFFSET_FILL)
			end

			_oldPolygonOffset = polygonoffset
		end

		if (polygonoffset and ( _oldPolygonOffsetFactor ~= factor or _oldPolygonOffsetUnits ~= units)) then
			_gl:polygonOffset(factor, units)
			
			_oldPolygonOffsetFactor = factor
			_oldPolygonOffsetUnits = units
		end
	end

	function computeFrustum(m)

		_frustum[0]:set(m.n41 - m.n11, m.n42 - m.n12, m.n43 - m.n13, m.n44 - m.n14)
		_frustum[1]:set(m.n41 + m.n11, m.n42 + m.n12, m.n43 + m.n13, m.n44 + m.n14)
		_frustum[2]:set(m.n41 + m.n21, m.n42 + m.n22, m.n43 + m.n23, m.n44 + m.n24)
		_frustum[3]:set(m.n41 - m.n21, m.n42 - m.n22, m.n43 - m.n23, m.n44 - m.n24)
		_frustum[4]:set(m.n41 - m.n31, m.n42 - m.n32, m.n43 - m.n33, m.n44 - m.n34)
		_frustum[5]:set(m.n41 + m.n31, m.n42 + m.n32, m.n43 + m.n33, m.n44 + m.n34)

		local plane

		for i = 0, 5 do
			plane = _frustum[i]
			plane:divideScalar(math.sqrt (plane.x * plane.x + plane.y * plane.y + plane.z * plane.z) )
		end
	end

	function isInFrustum( object )

		local distance
		local matrix = object.matrixWorld
		local radius = -object.geometry.boundingSphere.radius * math.max( object.scale.x, object.scale.y, object.scale.z)

		for i = 0, 5 do
			distance = _frustum[i].x * matrix.n14 + _frustum[i].y * matrix.n24 + _frustum[i].z * matrix.n34 + _frustum[i].w
			if (distance <= radius ) then return false end
		end

		return true

	end

	function addToFixedArray( where, what) 
		where.list[where.count] = what
		where.count = where.count + 1
	end

	function unrollImmediateBufferMaterials( globject)

		local object = globject.object
		local opaque = globject.opaque
		local transparent = globject.transparent
		local ml = length(object.materials) - 1
		local material

		transparent.count = 0
		opaque.count = 0

		for m = 0, ml do
			material = object.materials[m]
			if (material.transparent) then
				addToFixedArray( transparent, material)
			else
				addToFixedArray( opaque, material)
			end
		end

	end

	function unrollBufferMaterials( globject)

		local object = globject.object
		local buffer = globject.buffer
		local opaque = globject.opaque
		local transparent = globject.transparent
		local material, meshMaterial
		local l = length(buffer.materials) - 1

		transparent.count = 0
		opaque.count = 0

		for m = 0,length(object.materials)-1  do
			meshMaterial = object.materials[m]
			if (getmetatable(meshMaterial).types[THREE.MeshFaceMaterial]) then
				for i = 0,length(buffer.materials)-1 do
					material = buffer.materials[i]
					if (material) then
						if (material.transparent) then
							addToFixedArray(transparent, material)
						else
							addToFixedArray(opaque, material)
						end
					end
				end
			else
				material = meshMaterial
				if (material) then
					if (material.transparent) then
						addToFixedArray(transparent, material)
					else
						addToFixedArray(opaque, material)
					end
				end
			end
		end
	end

	function painterSort( a, b)
		return b.z < a.z
	end

	function WGLR:render(scene, camera, renderTarget, forceClear)
		local lights = rawget(scene, "lights")
		local fog = rawget(scene, "fog")
		local i
		local program
		local opaque
		local transparent
		local material 
		local	o
		local ol
		local oil
		local webglObject
		local object
		local buffer

		_this.data.vertices = 0
		_this.data.faces = 0
		_this.data.drawCalls = 0

		if(camera.matrixAutoUpdate) then camera:update( nil, true) end
		scene:update (nil, false, camera)

		camera.matrixWorldInverse:flattenToArray( _viewMatrixArray)
		camera.projectionMatrix:flattenToArray( _projectionMatrixArray)

		_projScreenMatrix:multiply( camera.projectionMatrix, camera.matrixWorldInverse)
		computeFrustum( _projScreenMatrix)
		self:initWebGLObjects(scene)
		setRenderTarget( renderTarget)

		if (self.autoClear or forceClear) then
				self:clear()
		end

		ol = length(scene.__webglObjects) - 1

		for o = 0, ol do
			webglObject = scene.__webglObjects[o]
			object = webglObject.object
			--print("visible", object.visible)
			if ( object.visible ) then
				--print(getmetatable(object).types[THREE.Mesh])
				if ( not getmetatable(object).types[THREE.Mesh] or isInFrustum( object )  )then
					object.matrixWorld:flattenToArray( object._objectMatrixArray)
					setupMatrices( object, camera)
					unrollBufferMaterials( webglObject)
					webglObject.render = true
					if (self.sortObjects) then
						if (rawget(webglObject.object, "renderDepth")) then
							webglObject.z = webglObject.object.renderDepth
						else
							_vector3:copy(object.position)
							_projScreenMatrix:multiplyVector3( _vector3)
							webglObject.z = _vector3.z
						end
					end
				else
					webglObject.render = false
				end
			else
				webglObject.render = false
			end
		end

		--print("should render", webglObject.render)

		if (self.sortObjects) then
				table.sort(scene.__webglObjects, painterSort)
		end

		oil = length(scene.__webglObjectsImmediate) - 1
		for o = 0, oil do
			webglObject = scene.__webglObjectsImmediate[o]
			object = webglObject.object

			if (object.visible) then
				if (object.matrixAutoUpdate) then
					object.matrixWorld:flattenToArray(object._objectMatrixArray)
				end

				setupMatrices( object, camera )
				unrollImmediateBufferMaterials(webglObject)
			end
		end

		if (rawget(scene,"overrideMaterial")) then
			setDepthTest( scene.overrideMaterial.depthTest)
			setBlending( scene.overrideMaterial.blending)

			for o = 0, ol do
				webglObject = scene.__webglObjects[o]
	
				if ( webglObject.render) then
					object = webglObject.object
					buffer = webglObject.buffer
					setObjectFaces( object )

					renderBuffer( camera, lights, fog, scene.overrideMaterial, buffer, object)
				end
			end

			for o = 0, oil do
				webglObject = scene.__webglObjectsImmediate[o]
				object = webglObject.object

				if (object.visible) then
					setObjectFaces(object)
					program = setProgram( camera, lights, fog, scene.overrideMaterial, object)
					object:render( function(object) renderBufferImmediate( object, program, scene.overrideMaterial.shading); end )

				end
			end
		else
			--print("opaque pass")

			setBlending(THREE.NormalBlending)

			for o = 0, ol do
				--print(o)
				webglObject = scene.__webglObjects[o]

				if (webglObject.render) then
					object = webglObject.object
					buffer = webglObject.buffer
					opaque = webglObject.opaque
					setObjectFaces(object)

					for i = 0, opaque.count - 1 do

						material = opaque.list[i]
						setDepthTest(material.depthTest)
						setPolygonOffset(material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits)
						renderBuffer(camera, lights, fog, material, buffer, object)
					end
				end
			end

			--print("opaque pass (immediate simulator)")

			for o = 0, oil do
				webglObject = scene.__webglObjectsImmediate[o]
				object = webglObject.object

				if (object.visible) then	
					opaue = webglObject.opaque
					setObjectFaces(object)
					for i = 0, opaque.count - 1 do
						material = opaque.list[i]
						setDepthTest( material.depthTest)
						setPolygonOffset( material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits)

						program = setProgram( camera, lights, fog, material, object)
						object:render( function(object) renderBufferImmediate(object, program, material.shading) end )
					end
				end
			end

			--print("transparent pass")

			for o = 0, ol do
				webglObject = scene.__webglObjects[o]

				if (webglObject.render) then
					object = webglObject.object
					buffer = webglObject.buffer
					transparent = webglObject.transparent
					setObjectFaces( object )

					for i = 0, transparent.count - 1 do
						material = transparent.list[i]
						setBlending( material.blending )
						setDepthTest( material.depthTest)
						setPolygonOffset( material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits)

						renderBuffer( camera, lights, fog, material, buffer, object )

					end
				end
			end

			--print("transparent pass (immediate simulator)")

			for o = 0, oil do
				webglObject = scene.__webglObjectsImmediate[o]
				object = webglObject.object

				if (object.visible) then 

					transparent = webglObject.transparent

					setObjectFaces( object )

					for i = 0, transparent.count - 1 do
						material = transparent.list[i]
						setBlending( material.blending )
						setDepthTest( material.depthTest )
						setPolygonOffset( material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits )

						program = setProgram( camera, lights, fog, material, object)
						object:render( function( object ) renderBufferImmediate( object, program, material.shading) end )
					end
				end
			end
		end

		--print("render 2D")

		if ( length(scene.__webglSprites) ~= 0) then
			renderSprites( scene, camera)
		end

		--print("render stencil shadows")

		if (_stencil and length(scene.__webglShadowVolumes) ~= 0 and length(scene.light) ~= 0) then
			renderStencilShadows(scene)
		end

		--print("render lens flares")

		if (length(scene.__webglLensFlares) ~= 0) then
			renderLensFlares( scene, camera)
		end

		--print("generate mipmap if we're using any kind of mipmap filtering")

		if (renderTarget and renderTarget.minFilter ~= THREE.NearestFilter and renderTarget.minFilter ~= THREE.LinearFilter) then
			updateRenderTargetMipmap( renderTarget)
		end
		WGLR._projScreenMatrix = _projScreenMatrix
	end

	--[[/*
	 * Stencil Shadows
	 * method: we're rendering the world in light, then the shadow
	 *         volumes into the stencil and last a big darkening
	 *         quad over the whole thing. This is not how "you're
	 *	       supposed to" do stencil shadows but is much faster
	 *
	 */]]

	function renderStencilShadows( scene ) 

		-- setup stencil

		_gl:enable( _gl.POLYGON_OFFSET_FILL );
		_gl:polygonOffset( 0.1, 1.0 );
		_gl:enable( _gl.STENCIL_TEST );
		_gl:enable( _gl.DEPTH_TEST );
		_gl:depthMask( false );
		_gl:colorMask( false, false, false, false );

		_gl:stencilFunc( _gl.ALWAYS, 1, 0xFF );
		_gl:stencilOpSeparate( _gl.BACK,  _gl.KEEP, _gl.INCR, _gl.KEEP );
		_gl:stencilOpSeparate( _gl.FRONT, _gl.KEEP, _gl.DECR, _gl.KEEP );


		-- loop through all directional lights

		local l, ll = length(scene.lights) - 1;
		local p;
		local light, lights = scene.lights;
		local dirLight = {};
		local object, geometryGroup, material;
		local program;
		local p_uniforms;
		local m_uniforms;
		local attributes;
		local o 
		local ol = length(scene.__webglShadowVolumes) - 1

		for l = 0, ll do

			light = scene.lights[ l ];

			if ( getmetatable(light).types[THREE.DirectionalLight] and light.castShadow ) then

				dirLight[ 0 ] = -light.position.x;
				dirLight[ 1 ] = -light.position.y;
				dirLight[ 2 ] = -light.position.z;

				-- render all volumes

				for o = 0, ol do

					object        = scene.__webglShadowVolumes[ o ].object;
					geometryGroup = scene.__webglShadowVolumes[ o ].buffer;
					material      = object.materials[ 0 ];

					if ( not material.program ) then _this.initMaterial( material, lights, undefined, object ); end

					program = material.program
					p_uniforms = gl_program[program].uniforms
					m_uniforms = material.uniforms
					attributes = gl_program[program].attributes

					if ( _currentProgram ~= program ) then

						_gl:useProgram( program );
						_currentProgram = program;

						_gl:uniformMatrix4fv( p_uniforms.projectionMatrix, false, _projectionMatrixArray );
						_gl:uniformMatrix4fv( p_uniforms.viewMatrix, false, _viewMatrixArray );
						_gl:uniform3fv( p_uniforms.directionalLightDirection, dirLight );
					end


					object.matrixWorld:flattenToArray( object._objectMatrixArray );
					_gl:uniformMatrix4fv( p_uniforms.objectMatrix, false, object._objectMatrixArray );


					_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglVertexBuffer );
					_gl:vertexAttribPointer( attributes.position, 3, _gl.FLOAT, false, 0, 0 );

					_gl:bindBuffer( _gl.ARRAY_BUFFER, geometryGroup.__webglNormalBuffer );
					_gl:vertexAttribPointer( attributes.normal, 3, _gl.FLOAT, false, 0, 0 );

					_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, geometryGroup.__webglFaceBuffer );

					_gl:cullFace( _gl.FRONT );
					foo( _gl.TRIANGLES, geometryGroup.__webglFaceCount, _gl.UNSIGNED_SHORT, 0 );

					_gl:cullFace( _gl.BACK );
					foo( _gl.TRIANGLES, geometryGroup.__webglFaceCount, _gl.UNSIGNED_SHORT, 0 );

				end

			end

		end


		-- setup color+stencil

		_gl:disable( _gl.POLYGON_OFFSET_FILL );
		_gl:colorMask( true, true, true, true );
		_gl:stencilFunc( _gl.NOTEQUAL, 0, 0xFF );
		_gl:stencilOp( _gl.KEEP, _gl.KEEP, _gl.KEEP );
		_gl:disable( _gl.DEPTH_TEST );


		-- draw darkening polygon

		_oldBlending = -1;
		_currentProgram = _stencilShadow.program;

		_gl:useProgram( _stencilShadow.program );
		_gl:uniformMatrix4fv( _stencilShadow.projectionLocation, false, _projectionMatrixArray );
		_gl:uniform1f( _stencilShadow.darknessLocation, _stencilShadow.darkness );

		_gl:bindBuffer( _gl.ARRAY_BUFFER, _stencilShadow.vertexBuffer );
		_gl:vertexAttribPointer( _stencilShadow.vertexLocation, 3, _gl.FLOAT, false, 0, 0 );
		_gl:enableVertexAttribArray( _stencilShadow.vertexLocation );

		_gl:blendFunc( _gl.ONE, _gl.ONE_MINUS_SRC_ALPHA );
		_gl:blendEquation( _gl.FUNC_ADD );

		_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, _stencilShadow.elementBuffer );
		foo( _gl.TRIANGLES, 6, _gl.UNSIGNED_SHORT, 0 );


		-- disable stencil

		_gl:disable( _gl.STENCIL_TEST );
		_gl:enable( _gl.DEPTH_TEST );
		_gl:depthMask( _currentDepthMask );

	end

	--[[/*
	 * Render sprites
	 *
	 */]]

	function renderSprites( scene, camera )

		local o, ol, object;
		local attributes = _sprite.attributes;
		local uniforms = _sprite.uniforms;
		local anyCustom = false;
		local invAspect = _viewportHeight / _viewportWidth;
		local size 
		local scale = {};
		local screenPosition;
		local halfViewportWidth = _viewportWidth * 0.5;
		local halfViewportHeight = _viewportHeight * 0.5;
		local mergeWith3D = true;

		-- setup gl

		_gl:useProgram( _sprite.program );
		_currentProgram = _sprite.program;
		_oldBlending = -1;

		if ( not _spriteAttributesEnabled ) then

			_gl:enableVertexAttribArray( _sprite.attributes.position );
			_gl:enableVertexAttribArray( _sprite.attributes.uv );

			_spriteAttributesEnabled = true;

		end

		_gl:disable( _gl.CULL_FACE );
		_gl:enable( _gl.BLEND );
		_gl:depthMask( true );

		_gl:bindBuffer( _gl.ARRAY_BUFFER, _sprite.vertexBuffer );
		_gl:vertexAttribPointer( attributes.position, 2, _gl.FLOAT, false, 2 * 8, 0 );
		_gl:vertexAttribPointer( attributes.uv, 2, _gl.FLOAT, false, 2 * 8, 8 );

		_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, _sprite.elementBuffer );

		_gl:uniformMatrix4fv( uniforms.projectionMatrix, false, _projectionMatrixArray );

		_gl:activeTexture( _gl.TEXTURE0 );
		_gl:uniform1i( uniforms.map, 0 );

		-- update positions and sort

		ol = length(scene.__webglSprites) - 1

		for o = 0, ol do

			object = scene.__webglSprites[ o ];

			if( not object.useScreenCoordinates ) then

				object._modelViewMatrix:multiplyToArray( camera.matrixWorldInverse, object.matrixWorld, object._modelViewMatrixArray );
				object.z = -object._modelViewMatrix.n34;

			else

				object.z = -object.position.z;

			end

		end

		table.sort(scene.__webglSprites, painterSort );

		-- render all non-custom shader sprites

		ol = length(scene.__webglSprites) - 1

		for o = 0, ol do

			object = scene.__webglSprites[ o ];

			if ( rawget(object, "material") == nil ) then

				if ( object.map and object.map.image and object.map.image.width ) then

					if ( object.useScreenCoordinates ) then

						_gl:uniform1i( uniforms.useScreenCoordinates, 1 );
						_gl:uniform3f( uniforms.screenPosition, ( object.position.x - halfViewportWidth  ) / halfViewportWidth,
																( halfViewportHeight - object.position.y ) / halfViewportHeight,
																  math.max( 0, math.min( 1, object.position.z )));

					else

						_gl:uniform1i( uniforms.useScreenCoordinates, 0 );
						_gl:uniform1i( uniforms.affectedByDistance, object.affectedByDistance and 1 or 0 );
						_gl:uniformMatrix4fv( uniforms.modelViewMatrix, false, object._modelViewMatrixArray );

					end

					size = object.map.image.width / ( object.scaleByViewport and _viewportHeight or 1 );
					scale[ 0 ] = size * invAspect * object.scale.x;
					scale[ 1 ] = size * object.scale.y;

					_gl:uniform2f( uniforms.uvScale, object.uvScale.x, object.uvScale.y );
					_gl:uniform2f( uniforms.uvOffset, object.uvOffset.x, object.uvOffset.y );
					_gl:uniform2f( uniforms.alignment, object.alignment.x, object.alignment.y );
					_gl:uniform1f( uniforms.opacity, object.opacity );
					
					
					_gl:uniform1f( uniforms.rotation, object.rotation );
					_gl:uniform2fv( uniforms.scale, scale );

					if ( object.mergeWith3D and not mergeWith3D ) then 

						_gl:enable( _gl.DEPTH_TEST );
						mergeWith3D = true;

					elseif ( not object.mergeWith3D and mergeWith3D ) then

						_gl:disable( _gl.DEPTH_TEST );
						mergeWith3D = false;

					end

					setBlending( object.blending );
					setTexture( object.map, 0 );

					foo( _gl.TRIANGLES, 6, _gl.UNSIGNED_SHORT, 0 );
				end

			else

				anyCustom = true;

			end

		end


		-- loop through all custom

		--[[
		if( anyCustom ) {

		}
		]]

		-- restore gl

		_gl:enable( _gl.CULL_FACE );
		_gl:enable( _gl.DEPTH_TEST );
		_gl:depthMask( _currentDepthMask );

	end

	--[[/*
	 * Render lens flares
	 * Method: renders 16x16 0xff00ff-colored points scattered over the light source area,
	 *         reads these back and calculates occlusion.
	 *         Then LensFlare.updateLensFlares() is called to re-position and
	 *         update transparency of flares. Then they are rendered.
	 *
	 */]]

	function renderLensFlares( scene, camera ) 

		local object, objectZ, geometryGroup, material;
		local o;
		local ol = length(scene.__webglLensFlares) - 1
		local f, fl, flare;
		local tempPosition = new THREE.Vector3();
		local invAspect = _viewportHeight / _viewportWidth;
		local halfViewportWidth = _viewportWidth * 0.5;
		local halfViewportHeight = _viewportHeight * 0.5;
		local size = 16 / _viewportHeight;
		local scale = {[0]= size * invAspect, [1]=size };
		local screenPosition = {[0]= 1, [1]=1, [2]=0 };
		local screenPositionPixels = {[0]= 1,[1]= 1 };
		local sampleX, sampleY, readBackPixels = _lensFlare.readBackPixels;
		local sampleMidX = 7 * 4;
		local sampleMidY = 7 * 16 * 4;
		local sampleIndex, visibility;
		local uniforms = _lensFlare.uniforms;
		local attributes = _lensFlare.attributes;


		-- set lensflare program and reset blending

		_gl:useProgram( _lensFlare.program );
		_currentProgram = _lensFlare.program;
		_oldBlending = -1;


		if ( not _lensFlareAttributesEnabled ) then

			_gl:enableVertexAttribArray( _lensFlare.attributes.vertex );
			_gl:enableVertexAttribArray( _lensFlare.attributes.uv );

			_lensFlareAttributesEnabled = true;

		end

		-- loop through all lens flares to update their occlusion and positions
		-- setup gl and common used attribs/unforms

		_gl:uniform1i( uniforms.occlusionMap, 0 );
		_gl:uniform1i( uniforms.map, 1 );

		_gl:bindBuffer( _gl.ARRAY_BUFFER, _lensFlare.vertexBuffer );
		_gl:vertexAttribPointer( attributes.vertex, 2, _gl.FLOAT, false, 2 * 8, 0 );
		_gl:vertexAttribPointer( attributes.uv, 2, _gl.FLOAT, false, 2 * 8, 8 );


		_gl:bindBuffer( _gl.ELEMENT_ARRAY_BUFFER, _lensFlare.elementBuffer );

		_gl:disable( _gl.CULL_FACE );
		_gl:depthMask( false );

		_gl:activeTexture( _gl.TEXTURE0 );
		_gl:bindTexture( _gl.TEXTURE_2D, _lensFlare.occlusionTexture );

		_gl:activeTexture( _gl.TEXTURE1 );

		for o=0, ol-1 do

			-- calc object screen position

			object = scene.__webglLensFlares[ o ].object;

			tempPosition:set( object.matrixWorld.n14, object.matrixWorld.n24, object.matrixWorld.n34 );

			camera.matrixWorldInverse:multiplyVector3( tempPosition );
			objectZ = tempPosition.z;
			camera.projectionMatrix:multiplyVector3( tempPosition );


			-- setup arrays for gl programs

			screenPosition[ 0 ] = tempPosition.x;
			screenPosition[ 1 ] = tempPosition.y;
			screenPosition[ 2 ] = tempPosition.z;

			screenPositionPixels[ 0 ] = screenPosition[ 0 ] * halfViewportWidth + halfViewportWidth;
			screenPositionPixels[ 1 ] = screenPosition[ 1 ] * halfViewportHeight + halfViewportHeight;


			-- screen cull

			if ( _lensFlare.hasVertexTexture or ( screenPositionPixels[ 0 ] > 0 and
				screenPositionPixels[ 0 ] < _viewportWidth and
				screenPositionPixels[ 1 ] > 0 and
				screenPositionPixels[ 1 ] < _viewportHeight )) then


				-- save current RGB to temp texture

				_gl:bindTexture( _gl.TEXTURE_2D, _lensFlare.tempTexture );
				_gl:copyTexImage2D( _gl.TEXTURE_2D, 0, _gl.RGB, screenPositionPixels[ 0 ] - 8, screenPositionPixels[ 1 ] - 8, 16, 16, 0 );


				-- render pink quad

				_gl:uniform1i( uniforms.renderType, 0 );
				_gl:uniform2fv( uniforms.scale, scale );
				_gl:uniform3fv( uniforms.screenPosition, screenPosition );

				_gl:disable( _gl.BLEND );
				_gl:enable( _gl.DEPTH_TEST );

				foo( _gl.TRIANGLES, 6, _gl.UNSIGNED_SHORT, 0 );


				-- copy result to occlusionMap

				_gl:bindTexture( _gl.TEXTURE_2D, _lensFlare.occlusionTexture );
				_gl:copyTexImage2D( _gl.TEXTURE_2D, 0, _gl.RGBA, screenPositionPixels[ 0 ] - 8, screenPositionPixels[ 1 ] - 8, 16, 16, 0 );


				-- restore graphics

				_gl:uniform1i( uniforms.renderType, 1 );
				_gl:disable( _gl.DEPTH_TEST );
				_gl:bindTexture( _gl.TEXTURE_2D, _lensFlare.tempTexture );
				foo( _gl.TRIANGLES, 6, _gl.UNSIGNED_SHORT, 0 );


				-- update object positions

				object.positionScreen.x = screenPosition[ 0 ];
				object.positionScreen.y = screenPosition[ 1 ];
				object.positionScreen.z = screenPosition[ 2 ];

				if ( object.customUpdateCallback ) then

					object.customUpdateCallback( object );

				else

					object:updateLensFlares();

				end


				-- render flares

				_gl:uniform1i( uniforms.renderType, 2 );
				_gl:enable( _gl.BLEND );

				fl = length(object.lensFlares) - 1

				for f = 0, fl do

					flare = object.lensFlares[ f ];

					if ( flare.opacity > 0.001 and flare.scale > 0.001 ) then

						screenPosition[ 0 ] = flare.x;
						screenPosition[ 1 ] = flare.y;
						screenPosition[ 2 ] = flare.z;

						size = flare.size * flare.scale / _viewportHeight;
						scale[ 0 ] = size * invAspect;
						scale[ 1 ] = size;

						_gl:uniform3fv( uniforms.screenPosition, screenPosition );
						_gl:uniform2fv( uniforms.scale, scale );
						_gl:uniform1f( uniforms.rotation, flare.rotation );
						_gl:uniform1f( uniforms.opacity, flare.opacity );

						setBlending( flare.blending );
						setTexture( flare.texture, 1 );

						foo( _gl.TRIANGLES, 6, _gl.UNSIGNED_SHORT, 0 );

					end

				end

			end

		end

		-- restore gl

		_gl:enable( _gl.CULL_FACE );
		_gl:enable( _gl.DEPTH_TEST );
		_gl:depthMask( _currentDepthMask );

	end

	function setupMatrices( object, camera ) 
		object._modelViewMatrix:multiplyToArray( camera.matrixWorldInverse, object.matrixWorld, object._modelViewMatrixArray );
		--print("SETUPMATRICES",object._modelViewMatrix.m33)
		THREE.Matrix4.makeInvert3x3( object._modelViewMatrix ):transposeIntoArray( object._normalMatrixArray );
	end

	function WGLR:initWebGLObjects ( scene )

		if ( not rawget(scene,"__webglObjects") ) then 
			scene.__webglObjects = {};
			scene.__webglObjectsImmediate = {};
			scene.__webglShadowVolumes = {};
			scene.__webglLensFlares = {};
			scene.__webglSprites = {};

		end
		
		--[[
		while ( length(scene.__objectsAdded) ~= 0 ) do
			--print("added objects", length(scene.__objectsAdded))
			--print(scene.__objectsAdded)
			addObject( scene.__objectsAdded[ 0 ], scene );
			table.remove(scene.__objectsAdded, 0);

		end]]

		for k, v in pairs(scene.__objectsAdded) do
			addObject(v, scene)
		end
		scene.__objectsAdded = {}

		--[[
		while ( length(scene.__objectsRemoved) ~= 0 ) do
			--print("removed objects", length(scene.__objectsRemoved))
			removeObject( scene.__objectsRemoved[ 0 ], scene );
			table.remove(scene.__objectsRemoved, 0);

		end]]

		for k, v in pairs(scene.__objectsRemoved) do
			removeObject(v, scene)
		end
		scene.__objectsRemoved = {}

		-- update must be called after objects adding / removal

		ol = length(scene.__webglObjects) - 1
		--print("updating webglobjects")
		for o = 0, ol do
			--print(o, scene.__webglObjects[ o ])
			updateObject( scene.__webglObjects[ o ].object, scene );

		end
		--print("webglobjects updated")
		ol = length(scene.__webglShadowVolumes) - 1

		for o = 0, ol do

			updateObject( scene.__webglShadowVolumes[ o ].object, scene );

		end

		ol = length(scene.__webglLensFlares) - 1

		for o = 0, ol do

			updateObject( scene.__webglLensFlares[ o ].object, scene );

		end

		--[[/*
		for ( var o = 0, ol = scene.__webglSprites.length; o < ol; o ++ ) {

			updateObject( scene.__webglSprites[ o ].object, scene );

		}
		*/]]

	end

	function addObject( object, scene )
		--print("addObject")
		local g, geometry, geometryGroup;
		if ( rawget(object,"_modelViewMatrix") == nil ) then
			object._modelViewMatrix = THREE.Matrix4();
			object._normalMatrixArray = Float32Array( 9 );
			object._modelViewMatrixArray = Float32Array( 16 );
			object._objectMatrixArray = Float32Array( 16 );
			object.matrixWorld:flattenToArray( object._objectMatrixArray );

		end

		if ( getmetatable(object).types[THREE.Mesh] ) then
			geometry = object.geometry;

			if ( rawget(geometry,"geometryGroups") == nil ) then
				sortFacesByMaterial( geometry );
			end
			-- create separate VBOs per geometry chunk

			for k, g in pairs(geometry.geometryGroups ) do

				geometryGroup = geometry.geometryGroups[ k ];

				-- initialise VBO on the first access

				if ( not rawget(geometryGroup,"__webglVertexBuffer") ) then

					createMeshBuffers( geometryGroup );
					initMeshBuffers( geometryGroup, object );

					geometry.__dirtyVertices = true;
					geometry.__dirtyMorphTargets = true;
					geometry.__dirtyElements = true;
					geometry.__dirtyUvs = true;
					geometry.__dirtyNormals = true;
					geometry.__dirtyTangents = true;
					geometry.__dirtyColors = true;

				end

				-- create separate wrapper per each use of VBO

				if ( getmetatable(object).types[THREE.ShadowVolume] ) then

					addBuffer( scene.__webglShadowVolumes, geometryGroup, object );

				else
					--print("webglobjects", scene.__webglObjects)
					addBuffer( scene.__webglObjects, geometryGroup, object );
					--print("WEBGLOBJECTS", scene.__webglObjects[1])
				end

			end

		elseif ( getmetatable(object).types[THREE.LensFlare] ) then

			addBuffer( scene.__webglLensFlares, undefined, object );

		elseif ( getmetatable(object).types[THREE.Ribbon] ) then

			geometry = object.geometry;

			if( not geometry.__webglVertexBuffer ) then

				createRibbonBuffers( geometry );
				initRibbonBuffers( geometry );

				geometry.__dirtyVertices = true;
				geometry.__dirtyColors = true;

			end

			addBuffer( scene.__webglObjects, geometry, object );

		elseif ( getmetatable(object).types[THREE.Line] ) then

			geometry = object.geometry;

			if( not geometry.__webglVertexBuffer ) then

				createLineBuffers( geometry );
				initLineBuffers( geometry );

				geometry.__dirtyVertices = true;
				geometry.__dirtyColors = true;

			end

			addBuffer( scene.__webglObjects, geometry, object );

		elseif ( getmetatable(object).types[THREE.ParticleSystem] ) then

			geometry = object.geometry;

			if ( not geometry.__webglVertexBuffer ) then

				createParticleBuffers( geometry );
				initParticleBuffers( geometry );

				geometry.__dirtyVertices = true;
				geometry.__dirtyColors = true;

			end

			addBuffer( scene.__webglObjects, geometry, object );

		--TODO: THREE.MarchingCubes implementation removed.
		elseif ( getmetatable(object).types[THREE.Sprite] ) then
			--print("3005 pushing")
			push(scene.__webglSprites, object );

		end
		--[[
		/*else if ( object instanceof THREE.Particle ) {

		}*/]]

	end

	function areCustomAttributesDirty( geometryGroup )

		local a; 
		local m;
		local ml;
		local material;
		local materials;

		materials = geometryGroup.__materials;

		ml = length(materials) - 1

		for m = 0, ml do

			material = materials[ m ];

			if ( rawget(material,"attributes") ) then

				for k, a in pairs(material.attributes ) do

					if ( material.attributes[ a ].needsUpdate ) then return true; end

				end

			end

		end


		return false;

	end

	function clearCustomAttributes( geometryGroup )

		local a;
		local m; 
		local ml; 
		local material; 
		local materials;

		materials = geometryGroup.__materials;

		 ml = length(materials) - 1

		for m = 0, ml do

			material = materials[ m ];

			if ( rawget(material,"attributes") ) then

				for k, a in pairs(material.attributes ) do

					material.attributes[ a ].needsUpdate = false;

				end

			end

		end

	end

	function updateObject( object, scene )

		local g;
		local geometry;
		local geometryGroup; 
		local a; 
		local customAttributeDirty;

		if ( getmetatable(object).types[THREE.Mesh] ) then
			--print("updating mesh")
			geometry = object.geometry;

			-- check all geometry groups

			for k, g in pairs(geometry.geometryGroups ) do
				geometryGroup = geometry.geometryGroups[ k ];

				customAttributeDirty = areCustomAttributesDirty( geometryGroup );

				if ( geometry.__dirtyVertices or geometry.__dirtyMorphTargets or geometry.__dirtyElements or
					 geometry.__dirtyUvs or geometry.__dirtyNormals or
					 geometry.__dirtyColors or geometry.__dirtyTangents or customAttributeDirty ) then
					--print("setting mesh buffers", g)
					--print(object.geometry.faces[0].normal, "HERE")
					setMeshBuffers( geometryGroup, object, _gl.DYNAMIC_DRAW );
					--print("mesh buffers set")
				end

			end

			geometry.__dirtyVertices = false;
			geometry.__dirtyMorphTargets = false;
			geometry.__dirtyElements = false;
			geometry.__dirtyUvs = false;
			geometry.__dirtyNormals = false;
			geometry.__dirtyTangents = false;
			geometry.__dirtyColors = false;

			clearCustomAttributes( geometryGroup );

		elseif ( getmetatable(object).types[THREE.Ribbon] ) then

			geometry = object.geometry;

			if( geometry.__dirtyVertices or geometry.__dirtyColors ) then

				setRibbonBuffers( geometry, _gl.DYNAMIC_DRAW );

			end

			geometry.__dirtyVertices = false;
			geometry.__dirtyColors = false;

		elseif ( getmetatable(object).types[THREE.Line] ) then

			geometry = object.geometry;

			if( geometry.__dirtyVertices or  geometry.__dirtyColors ) then

				setLineBuffers( geometry, _gl.DYNAMIC_DRAW );

			end

			geometry.__dirtyVertices = false;
			geometry.__dirtyColors = false;

		elseif ( getmetatable(object).types[THREE.ParticleSystem] ) then

			geometry = object.geometry;

			if ( geometry.__dirtyVertices or geometry.__dirtyColors or object.sortParticles ) then

				setParticleBuffers( geometry, _gl.DYNAMIC_DRAW, object );

			end

			geometry.__dirtyVertices = false;
			geometry.__dirtyColors = false;
		
	--[[/* else if ( THREE.MarchingCubes !== undefined && object instanceof THREE.MarchingCubes ) {

			// it updates itself in render callback

		}else if ( object instanceof THREE.Particle ) {

		}*/

		/*
		delete geometry.vertices;
		delete geometry.faces;
		delete geometryGroup.faces;
		*/]]
		end

	end


	function removeInstances( objlist, object )

		for o = length(objlist) - 1, 0, -1 do

			if ( objlist[ o ].object == object ) then

				objlist.splice( o, 1 );

			end

		end

	end

	function removeInstancesDirect( objlist, object )

		for o = length(objlist) - 1, 0, -1 do

			if ( objlist[ o ] == object ) then

				objlist.splice( o, 1 );

			end

		end

	end

	function removeObject( object, scene )

		-- must check as shadow volume before mesh (as they are also meshes)

		if ( getmetatable(object).types[THREE.ShadowVolume] ) then

			removeInstances( scene.__webglShadowVolumes, object );

		elseif ( getmetatable(object).types[THREE.Mesh]  or
			 getmetatable(object).types[THREE.ParticleSystem] or
			 getmetatable(object).types[THREE.Ribbon] or
			 getmetatable(object).types[THREE.Line] ) then

			removeInstances( scene.__webglObjects, object );

		elseif ( getmetatable(object).types[THREE.Sprite] ) then

			removeInstancesDirect( scene.__webglSprites, object );

		elseif ( getmetatable(object).types[THREE.LensFlare] ) then

			removeInstances( scene.__webglLensFlares, object );

		end --[[else if ( object instanceof THREE.MarchingCubes ) {

			removeInstances( scene.__webglObjectsImmediate, object );

		}]]

	end

	function sortFacesByMaterial( geometry )

		-- TODO
		-- Should optimize by grouping faces with ColorFill / ColorStroke materials
		-- which could then use vertex color attributes instead of each being
		-- in its separate VBO

		local i; 
		local l; 
		local f; 
		local fl; 
		local face; 
		local material; 
		local materials; 
		local vertices; 
		local mhash; 
		local ghash; 
		local hash_map = {};
		local numMorphTargets = geometry.morphTargets~=nil and length(geometry.morphTargets) or 0;

		geometry.geometryGroups = {};

		function materialHash( material )

			local hash_array = {}

			l = length(material) - 1

			for i = 0, l do

				if ( material[ i ] == nil ) then

					push(hash_array, "undefined" );

				else
					--print("3256 pushing")
					push(hash_array, material[ i ].id );

				end

			end

			return join(hash_array, "_" ); 

		end

		fl = length(geometry.faces) - 1
	
		for f = 0, fl do

			face = geometry.faces[ f ];
			materials = face.materials;

			mhash = materialHash( materials );

			if ( not hash_map[ mhash ] ) then

				hash_map[ mhash ] = { hash = mhash, counter = 0 }

			end

			ghash = hash_map[ mhash ].hash .. '_' .. hash_map[ mhash ].counter;

			if ( not geometry.geometryGroups[ ghash ] ) then

				geometry.geometryGroups[ ghash ] = { faces = {}, materials = materials, vertices = 0, numMorphTargets = numMorphTargets };

			end

			vertices = getmetatable(face).types[THREE.Face3] and 3 or 4;

			if ( geometry.geometryGroups[ ghash ].vertices + vertices > 65535 ) then

				hash_map[ mhash ].counter = hash_map[ mhash ].counter + 1;
				ghash = hash_map[ mhash ].hash + '_' + hash_map[ mhash ].counter;

				if ( geometry.geometryGroups[ ghash ] == nil ) then

					geometry.geometryGroups[ ghash ] = { faces = {}, materials = materials, vertices = 0, numMorphTargets = numMorphTargets };

				end

			end
			--print("3304 pushing")
			push(geometry.geometryGroups[ ghash ].faces, f );
			geometry.geometryGroups[ ghash ].vertices = geometry.geometryGroups[ ghash ].vertices + vertices;

		end

	end

	function addBuffer( objlist, buffer, object )
		--print("3313 pushing")
		push(objlist, {
			buffer = buffer, object = object,
			opaque = { list = {}, count = 0 },
			transparent = { list = {}, count = 0 }
		} );

	end

	function addBufferImmediate( objlist, object )
		--print("3323 pushing")
		push( objlist, {
			object = object,
			opaque = { list = {}, count = 0 },
			transparent = { list = {}, count = 0 }
		} );

	end

	function WGLR:setFaceCulling( cullFace, frontFace )

		if ( cullFace ) then

			if ( not frontFace or frontFace == "ccw" ) then

				_gl:frontFace( _gl.CCW );

			else

				_gl:frontFace( _gl.CW );

			end

			if ( cullFace == "back" ) then

				_gl:cullFace( _gl.BACK );

			elseif ( cullFace == "front" ) then

				_gl:cullFace( _gl.FRONT );

			else

				_gl:cullFace( _gl.FRONT_AND_BACK );

			end

			_gl:enable( _gl.CULL_FACE );

		else

			_gl:disable( _gl.CULL_FACE );

		end

	end

	function WGLR:supportsVertexTextures()

		return _supportsVertexTextures;

	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

	function buildProgram( shaderID, fragmentShader, vertexShader, uniforms, attributes, parameters )

		local p; 
		local pl; 
		local program;
		local code;
		local chunks = {};

		-- Generate code

		if ( shaderID ) then

			push(chunks, shaderID );

		else

			push(chunks, fragmentShader );
			push(chunks, vertexShader );

		end

		for p,k in pairs(parameters ) do

			push(chunks, p );
			push(chunks, parameters[ p ] );

		end

		code = join(chunks);
	
		-- Check if code has been already compiled

		 pl = length(_programs) - 1

		for p = 0, pl do

			if ( _programs[ p ].code == code ) then

				-- console.log( "Code already compiled." /*: \n\n" + code*/ );

				return _programs[ p ].program;

			end

		end

		--console.log( "building new program " );

		program = _gl:createProgram();
		gl_program[program] = {}
		local prefix_vertex =

			(_supportsVertexTextures and "#define VERTEX_TEXTURES" or "").."\n"..

			"#define MAX_DIR_LIGHTS " .. parameters.maxDirLights.."\n"..
			"#define MAX_POINT_LIGHTS " .. parameters.maxPointLights.."\n"..

			"#define MAX_BONES " .. parameters.maxBones.."\n"..

			(parameters.map and "#define USE_MAP" or "").."\n"..
			(parameters.envMap and "#define USE_ENVMAP" or "").."\n"..
			(parameters.lightMap and "#define USE_LIGHTMAP" or "").."\n"..
			(parameters.vertexColors and "#define USE_COLOR" or "").."\n"..
			(parameters.skinning and "#define USE_SKINNING" or "").."\n"..
			(parameters.morphTargets and "#define USE_MORPHTARGETS" or "").."\n"..

			(parameters.sizeAttenuation and "#define USE_SIZEATTENUATION" or "").."\n"..

			"uniform mat4 objectMatrix;".."\n"..
			"uniform mat4 modelViewMatrix;".."\n"..
			"uniform mat4 projectionMatrix;".."\n"..
			"uniform mat4 viewMatrix;".."\n"..
			"uniform mat3 normalMatrix;".."\n"..
			"uniform vec3 cameraPosition;".."\n"..

			"uniform mat4 cameraInverseMatrix;".."\n"..

			"attribute vec3 position;".."\n"..
			"attribute vec3 normal;".."\n"..
			"attribute vec2 uv;".."\n"..
			"attribute vec2 uv2;".."\n"..

			"#ifdef USE_COLOR".."\n"..

				"attribute vec3 color;".."\n"..

			"#endif".."\n"..

			"#ifdef USE_MORPHTARGETS".."\n"..

				"attribute vec3 morphTarget0;".."\n"..
				"attribute vec3 morphTarget1;".."\n"..
				"attribute vec3 morphTarget2;".."\n"..
				"attribute vec3 morphTarget3;".."\n"..
				"attribute vec3 morphTarget4;".."\n"..
				"attribute vec3 morphTarget5;".."\n"..
				"attribute vec3 morphTarget6;".."\n"..
				"attribute vec3 morphTarget7;".."\n"..

			"#endif".."\n"..

			"#ifdef USE_SKINNING".."\n"..

				"attribute vec4 skinVertexA;".."\n"..
				"attribute vec4 skinVertexB;".."\n"..
				"attribute vec4 skinIndex;".."\n"..
				"attribute vec4 skinWeight;".."\n"..

			"#endif".."\n"..

			""


		local prefix_fragment = 

			"#ifdef GL_ES".."\n"..
			"precision highp float;".."\n"..
			"#endif".."\n"..

			"#define MAX_DIR_LIGHTS " .. parameters.maxDirLights.."\n"..
			"#define MAX_POINT_LIGHTS " .. parameters.maxPointLights.."\n"..

			(parameters.fog and "#define USE_FOG" or "").."\n"..
			((parameters.fog and getmetatable(parameters.fog).types[THREE.FogExp2]) and "#define FOG_EXP2" or "").."\n"..

			(parameters.map and "#define USE_MAP" or "").."\n"..
			(parameters.envMap and "#define USE_ENVMAP" or "").."\n"..
			(parameters.lightMap and "#define USE_LIGHTMAP" or "").."\n"..
			(parameters.vertexColors and "#define USE_COLOR" or "").."\n"..

			"uniform mat4 viewMatrix;".."\n"..
			"uniform vec3 cameraPosition;".."\n"..
			""
		--print(prefix_fragment .. fragmentShader)
		--print(prefix_vertex .. vertexShader)
		--print("PROGRAM",program, getShader( "fragment", prefix_fragment .. fragmentShader ))
		_gl:attachShader( program, getShader( "fragment", prefix_fragment .. fragmentShader ) );
		_gl:attachShader( program, getShader( "vertex", prefix_vertex .. vertexShader ) );

		_gl:linkProgram( program );

		if ( not _gl:getProgramParameter( program, _gl.LINK_STATUS ) ) then
			--print( "Could not initialise shader\n" + "VALIDATE_STATUS: " .. _gl:getProgramParameter( program, _gl.VALIDATE_STATUS ) .. ", gl error [" + _gl:getError() .. "]" );
		end

		--console.log( prefix_fragment + fragmentShader );
		--console.log( prefix_vertex + vertexShader );

		gl_program[program].uniforms = {};
		gl_program[program].attributes = {};

		local identifiers, u, a, i;

		-- cache uniform locations

		identifiers = {

			[0]='viewMatrix', [1]='modelViewMatrix', [2]='projectionMatrix', [3]='normalMatrix', [4]='objectMatrix', [5]='cameraPosition',
			[6]='cameraInverseMatrix', [7]='boneGlobalMatrices', [8]='morphTargetInfluences'

		};

		for u,k in pairs(uniforms ) do

			push( identifiers,u );

		end
		cacheUniformLocations( program, identifiers );

		-- cache attributes locations

		identifiers = {

			[0]="position", [1]="normal", [2]="uv", [3]="uv2", [4]="tangent", [5]="color",
			[6]="skinVertexA", [7]="skinVertexB", [8]="skinIndex", [9]="skinWeight"

		};

		for i = 0, parameters.maxMorphTargets - 1 do

			push(identifiers, "morphTarget" .. i );

		end

		if (attributes) then
			for a,k in pairs(attributes ) do

				push(identifiers, a );

			end
		end
		cacheAttributeLocations( program, identifiers );

		push(_programs, { program = program, code = code } );

		return program;

	end

	function loadUniformsSkinning( uniforms, object )

		_gl:uniformMatrix4fv( uniforms.cameraInverseMatrix, false, _viewMatrixArray );
		_gl:uniformMatrix4fv( uniforms.boneGlobalMatrices, false, object.boneMatrices );

	end

	function loadUniformsMatrices( uniforms, object )

		_gl:uniformMatrix4fv( uniforms.modelViewMatrix, false, object._modelViewMatrixArray );
		_gl:uniformMatrix3fv( uniforms.normalMatrix, false, object._normalMatrixArray );

	end

	function loadUniformsGeneric( program, uniforms )

		local u, uniform, value, t, location, texture;

		for u,k in pairs(uniforms ) do
			location = gl_program[program].uniforms[u];
			if ( location~=-1 ) then
				uniform = uniforms[u];

				t = uniform.type;
				value = uniform.value;
--[[
				print(u, t)
				if (type(value)=="table") then
					for k,v in pairs(value) do print("", k,v) end
				else
					print("",value)
				end
--]]
				if( t == "i" ) then
					--print(u)
					_gl:uniform1i( location, value );

				elseif( t == "f" ) then

					_gl:uniform1f( location, value );
	
				elseif( t == "fv1" ) then

					_gl:uniform1fv( location,Float32Array(value));

				elseif( t == "fv" ) then
					
					_gl:uniform3fv( location, value );

				elseif( t == "v2" ) then

					_gl:uniform2f( location, value.x, value.y );

				elseif( t == "v3" ) then

					_gl:uniform3f( location, value.x, value.y, value.z );

				elseif( t == "v4" ) then

					_gl:uniform4f( location, value.x, value.y, value.z, value.w );

				elseif( t == "c" ) then

					_gl:uniform3f( location, value.r, value.g, value.b );

				elseif( t == "t" ) then

					_gl:uniform1i( location, value );

					texture = uniform.texture;

					if ( texture ) then

						if ( type(texture.image) == "table" and length(texture.image) == 6 ) then

							setCubeTexture( texture, value );

						else

							setTexture( texture, value );

						end

					end

				end

			end

		end

	end

	function setBlending( blending )

		if ( blending ~= _oldBlending ) then

			if ( blending == THREE.AdditiveBlending) then

				_gl:blendEquation( _gl.FUNC_ADD );
				_gl:blendFunc( _gl.SRC_ALPHA, _gl.ONE );

			elseif( blending == THREE.SubtractiveBlending) then

				-- TODO: Find blendFuncSeparate() combination

				_gl:blendEquation( _gl.FUNC_ADD );
				_gl:blendFunc( _gl.ZERO, _gl.ONE_MINUS_SRC_COLOR );

			elseif( blending == THREE.MultiplyBlending) then

				-- TODO: Find blendFuncSeparate() combination

				_gl:blendEquation( _gl.FUNC_ADD );
				_gl:blendFunc( _gl.ZERO, _gl.SRC_COLOR );

			else

				_gl:blendEquationSeparate( _gl.FUNC_ADD, _gl.FUNC_ADD );
				_gl:blendFuncSeparate( _gl.SRC_ALPHA, _gl.ONE_MINUS_SRC_ALPHA, _gl.ONE, _gl.ONE_MINUS_SRC_ALPHA );

			end

			_oldBlending = blending;

		end

	end

	function setTextureParameters( textureType, texture, image )

		if ( isPowerOfTwo( image.width ) and isPowerOfTwo( image.height ) ) then

			_gl:texParameteri( textureType, _gl.TEXTURE_WRAP_S, paramThreeToGL( texture.wrapS ) );
			_gl:texParameteri( textureType, _gl.TEXTURE_WRAP_T, paramThreeToGL( texture.wrapT ) );

			_gl:texParameteri( textureType, _gl.TEXTURE_MAG_FILTER, paramThreeToGL( texture.magFilter ) );
			_gl:texParameteri( textureType, _gl.TEXTURE_MIN_FILTER, paramThreeToGL( texture.minFilter ) );

			_gl:generateMipmap( textureType );

		else

			_gl:texParameteri( textureType, _gl.TEXTURE_WRAP_S, _gl.CLAMP_TO_EDGE );
			_gl:texParameteri( textureType, _gl.TEXTURE_WRAP_T, _gl.CLAMP_TO_EDGE );

			_gl:texParameteri( textureType, _gl.TEXTURE_MAG_FILTER, filterFallback( texture.magFilter ) );
			_gl:texParameteri( textureType, _gl.TEXTURE_MIN_FILTER, filterFallback( texture.minFilter ) );

		end

	end

	function setTexture( texture, slot ) 

		if ( texture.needsUpdate ) then

			if ( not rawget(texture,"__webglInit") ) then

				texture.__webglTexture = _gl:createTexture();

				_gl:bindTexture( _gl.TEXTURE_2D, texture.__webglTexture );
				-- _gl.pixelStorei( _gl.UNPACK_FLIP_Y_WEBGL, true );
				_gl:texImage2D( _gl.TEXTURE_2D, 0, _gl.RGBA, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image );

				texture.__webglInit = true;

			else

				_gl:bindTexture( _gl.TEXTURE_2D, texture.__webglTexture );
				-- _gl.pixelStorei( _gl.UNPACK_FLIP_Y_WEBGL, true );
				_gl:texImage2D( _gl.TEXTURE_2D, 0, _gl.RGBA, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image );
				-- _gl.texSubImage2D( _gl.TEXTURE_2D, 0, 0, 0, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image );

			end

			setTextureParameters( _gl.TEXTURE_2D, texture, texture.image );

			_gl:bindTexture( _gl.TEXTURE_2D, -1 );

			texture.needsUpdate = false;

		end

		--[[/*
		if ( texture.needsUpdate ) {

			if ( texture.__webglTexture ) {

				texture.__webglTexture = _gl.deleteTexture( texture.__webglTexture );

			}

			texture.__webglTexture = _gl.createTexture();

			_gl.bindTexture( _gl.TEXTURE_2D, texture.__webglTexture );
			_gl.texImage2D( _gl.TEXTURE_2D, 0, _gl.RGBA, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image );

			setTextureParameters( _gl.TEXTURE_2D, texture, texture.image );

			_gl.bindTexture( _gl.TEXTURE_2D, null );

			texture.needsUpdate = false;

		}
		*/]]

		_gl:activeTexture( _gl.TEXTURE0 + slot );
		--dumptable(texture)
		_gl:bindTexture( _gl.TEXTURE_2D, texture.__webglTexture );


	end

	function setCubeTexture( texture, slot )

		if ( length(texture.image) == 6 ) then

			if ( texture.needsUpdate ) then

				if ( not texture.__webglInit ) then

					texture.image.__webglTextureCube = _gl:createTexture();

					_gl:bindTexture( _gl.TEXTURE_CUBE_MAP, texture.image.__webglTextureCube );

					for i = 0, 5 do

						_gl:texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, _gl.RGBA, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image[ i ] );

					end

					texture.__webglInit = true;

				else

					_gl:bindTexture( _gl.TEXTURE_CUBE_MAP, texture.image.__webglTextureCube );

					for i = 0, 5 do

						-- _gl.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, _gl.RGBA, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image[ i ] );
						_gl:texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, 0, 0, _gl.RGBA, _gl.UNSIGNED_BYTE, texture.image[ i ] );

					end

				end

				setTextureParameters( _gl.TEXTURE_CUBE_MAP, texture, texture.image[0] );
				_gl:bindTexture( _gl.TEXTURE_CUBE_MAP, null );

				texture.needsUpdate = false;

			end

			_gl:activeTexture( _gl.TEXTURE0 + slot );
			_gl:bindTexture( _gl.TEXTURE_CUBE_MAP, texture.image.__webglTextureCube );

		end

	end


	function setRenderTarget( renderTexture )

		if ( renderTexture and not renderTexture.__webglFramebuffer ) then

			if( renderTexture.depthBuffer == nil ) then renderTexture.depthBuffer = true; end
			if( renderTexture.stencilBuffer == nil ) then renderTexture.stencilBuffer = true; end

			renderTexture.__webglFramebuffer = _gl:createFramebuffer();
			renderTexture.__webglRenderbuffer = _gl:createRenderbuffer();
			renderTexture.__webglTexture = _gl:createTexture();


			-- Setup texture

			_gl:bindTexture( _gl.TEXTURE_2D, renderTexture.__webglTexture );
			_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, paramThreeToGL( renderTexture.wrapS ) );
			_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, paramThreeToGL( renderTexture.wrapT ) );
			_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, paramThreeToGL( renderTexture.magFilter ) );
			_gl:texParameteri( _gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, paramThreeToGL( renderTexture.minFilter ) );
			_gl:texImage2D( _gl.TEXTURE_2D, 0, paramThreeToGL( renderTexture.format ), renderTexture.width, renderTexture.height, 0, paramThreeToGL( renderTexture.format ), paramThreeToGL( renderTexture.type ), null );

			-- Setup render and frame buffer

			_gl:bindRenderbuffer( _gl.RENDERBUFFER, renderTexture.__webglRenderbuffer );
			_gl:bindFramebuffer( _gl.FRAMEBUFFER, renderTexture.__webglFramebuffer );

			_gl:framebufferTexture2D( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, renderTexture.__webglTexture, 0 );

			if ( renderTexture.depthBuffer and not renderTexture.stencilBuffer ) then

				_gl:renderbufferStorage( _gl.RENDERBUFFER, _gl.DEPTH_COMPONENT16, renderTexture.width, renderTexture.height );
				_gl:framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.DEPTH_ATTACHMENT, _gl.RENDERBUFFER, renderTexture.__webglRenderbuffer );

			--[[/* For some reason this is not working. Defaulting to RGBA4.
			} else if( !renderTexture.depthBuffer && renderTexture.stencilBuffer ) {

				_gl.renderbufferStorage( _gl.RENDERBUFFER, _gl.STENCIL_INDEX8, renderTexture.width, renderTexture.height );
				_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.STENCIL_ATTACHMENT, _gl.RENDERBUFFER, renderTexture.__webglRenderbuffer );
			*/]]
			elseif( renderTexture.depthBuffer and renderTexture.stencilBuffer ) then

				_gl:renderbufferStorage( _gl.RENDERBUFFER, _gl.DEPTH_STENCIL, renderTexture.width, renderTexture.height );
				_gl:framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.DEPTH_STENCIL_ATTACHMENT, _gl.RENDERBUFFER, renderTexture.__webglRenderbuffer );

			else

				_gl:renderbufferStorage( _gl.RENDERBUFFER, _gl.RGBA4, renderTexture.width, renderTexture.height );

			end


			-- Release everything

			_gl:bindTexture( _gl.TEXTURE_2D, null );
			_gl:bindRenderbuffer( _gl.RENDERBUFFER, null );
			_gl:bindFramebuffer( _gl.FRAMEBUFFER, null);

		end

		local framebuffer; 
		local width; 
		local height;

		if ( renderTexture ) then

			framebuffer = renderTexture.__webglFramebuffer;
			width = renderTexture.width;
			height = renderTexture.height;

		else 

			framebuffer = nil;
			width = _viewportWidth;
			height = _viewportHeight;

		end

		if ( framebuffer ~= _currentFramebuffer ) then

			_gl:bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );
			_gl:viewport( _viewportX, _viewportY, width, height );

			_currentFramebuffer = framebuffer;

		end

	end

	function updateRenderTargetMipmap( renderTarget )

		_gl:bindTexture( _gl.TEXTURE_2D, renderTarget.__webglTexture );
		_gl:generateMipmap( _gl.TEXTURE_2D );
		_gl:bindTexture( _gl.TEXTURE_2D, nil );

	end

	function cacheUniformLocations( program, identifiers )

		local i, l, id;

		l = length(identifiers) - 1

		for i = 0, l do

			id = identifiers[ i ];
			
			gl_program[program].uniforms[ id ] = _gl:getUniformLocation( program, id );
			--print("\t\t\t",id, gl_program[program].uniforms[ id ])
		end

	end

	function cacheAttributeLocations( program, identifiers )

		local i
		local l
		local id;

		 l = length(identifiers) - 1

		for i = 0, l do

			id = identifiers[ i ];
			gl_program[program].attributes[ id ] = _gl:getAttribLocation( program, id );

		end

	end

	-- fallback filters for non-power-of-2 textures

	function filterFallback( f )

		if ( f == THREE.NearestFilter or f == THREE.NearestMipMapNearestFilter or
				f == THREE.NearestMipMapLinearFilter ) then
			return _gl.NEAREST
		else
			return _gl.LINEAR

		end

	end

	function paramThreeToGL( p )

		if (p == THREE.RepeatWrapping) then return _gl.REPEAT; 
		elseif (p == THREE.ClampToEdgeWrapping) then return _gl.CLAMP_TO_EDGE; 
		elseif (p == THREE.MirroredRepeatWrapping) then return _gl.MIRRORED_REPEAT; 

		elseif (p == THREE.NearestFilter) then return _gl.NEAREST; 
		elseif (p == THREE.NearestMipMapNearestFilter) then return _gl.NEAREST_MIPMAP_NEAREST; 
		elseif (p == THREE.NearestMipMapLinearFilter) then return _gl.NEAREST_MIPMAP_LINEAR; 

		elseif (p == THREE.LinearFilter) then return _gl.LINEAR; 
		elseif (p == THREE.LinearMipMapNearestFilter) then return _gl.LINEAR_MIPMAP_NEAREST; 
		elseif (p == THREE.LinearMipMapLinearFilter) then return _gl.LINEAR_MIPMAP_LINEAR; 

		elseif (p == THREE.ByteType) then return _gl.BYTE; 
		elseif (p == THREE.UnsignedByteType) then return _gl.UNSIGNED_BYTE; 
		elseif (p == THREE.ShortType) then return _gl.SHORT; 
		elseif (p == THREE.UnsignedShortType) then return _gl.UNSIGNED_SHORT; 
		elseif (p == THREE.IntType) then return _gl.INT; 
		elseif (p == THREE.UnsignedShortType) then return _gl.UNSIGNED_INT; 
		elseif (p == THREE.FloatType) then return _gl.FLOAT; 

		elseif (p == THREE.AlphaFormat) then return _gl.ALPHA; 
		elseif (p == THREE.RGBFormat) then return _gl.RGB; 
		elseif (p == THREE.RGBAFormat) then return _gl.RGBA; 
		elseif (p == THREE.LuminanceFormat) then return _gl.LUMINANCE; 
		elseif (p == THREE.LuminanceAlphaFormat) then return _gl.LUMINANCE_ALPHA;

		end

		return 0;

	end
	
	--TODO: Make this faster if possible
	function isPowerOfTwo( value )
		local tmp = value
		while (tmp ~= 1 and tmp % 2 == 0) do
			tmp = tmp / 2
		end
		return tmp == 1;
	end

	function materialNeedsSmoothNormals( material )

		return material and material.shading ~= nil and material.shading == THREE.SmoothShading;

	end

	function bufferNeedsSmoothNormals( geometryGroup, object )

		local m
		local ml
		local i
		local l
		local meshMaterial

		local needsSmoothNormals = false;

		ml = length(object.materials) - 1

		for m = 0, ml do

			meshMaterial = object.materials[ m ];

			if ( getmetatable(meshMaterial).types[THREE.MeshFaceMaterial] ) then

				l = length(geometryGroup.materials) - 1

				for i = 0, l do

					if ( materialNeedsSmoothNormals( geometryGroup.materials[ i ] ) ) then

						needsSmoothNormals = true;
						break;

					end

				end

			else

				if ( materialNeedsSmoothNormals( meshMaterial ) ) then

					needsSmoothNormals = true;
					break;

				end

			end

			if ( needsSmoothNormals ) then break; end

		end

		return needsSmoothNormals;

	end

	function unrollGroupMaterials( geometryGroup, object ) 

		local m; 
		local ml; 
		local i; 
		local il;
		local material; 
		local meshMaterial;
			
		local materials = {};

		 ml = length(object.materials) - 1

		for m = 0, ml do

			meshMaterial = object.materials[ m ];

			if ( getmetatable(meshMaterial).types[THREE.MeshFaceMaterial] ) then

				l = length(geometryGroup.materials) - 1

				for i = 0, l do

					material = geometryGroup.materials[ i ];

					if ( material ) then
						--print("4089 pushing")
						push(materials, material );

					end

				end

			else

				material = meshMaterial;

				if ( material ) then

					push(materials, material );

				end

			end

		end

		return materials;

	end

	function bufferGuessVertexColorType( materials, geometryGroup, object )

		local i
		local m 

		local ml = length(materials) - 1

		-- use vertexColor type from the first material in unrolled materials

		for i = 0, ml do

			m = materials[ i ];

			if ( m.vertexColors ) then

				return m.vertexColors;

			end

		end

		return false;

	end

	function bufferGuessNormalType( materials, geometryGroup, object )

		local i
		local m 

		local ml = length(materials) - 1

		-- only MeshBasicMaterial and MeshDepthMaterial don't need normals

		for i = 0, ml do

			m = materials[ i ];

			if ( not ( ( getmetatable(m).types[THREE.MeshBasicMaterial] and not rawget(m,"envMap") ) or 
						getmetatable(m).types[THREE.MeshDepthMaterial] )) then

				if ( materialNeedsSmoothNormals( m ) ) then

					return THREE.SmoothShading;
				else

					return THREE.FlatShading;
				end

			end

		end

		return false;

	end

	function bufferGuessUVType( materials, geometryGroup, object )

		local i
		local m 

		local ml = length(materials) - 1

		-- material must use some texture to require uvs

		for i = 0, ml do 

			m = materials[ i ];

			if ( rawget(m,"map") or rawget(m,"lightMap") or getmetatable(m).types[THREE.MeshShaderMaterial] ) then

				return true;

			end

		end

		return false;

	end

	function allocateBones( object ) 

		--[[
		// default for when object is not specified
		// ( for example when prebuilding shader
		//   to be used with multiple objects )
		//
		// 	- leave some extra space for other uniforms
		//  - limit here is ANGLE's 254 max uniform vectors
		//    (up to 54 should be safe)
		]]

		local maxBones = 50;

		if ( object ~= nil and getmetatable(object).types[THREE.SkinnedMesh] ) then

			maxBones = length(object.bones);

		end

		return maxBones;

	end 


	function allocateLights( lights, maxLights )

		local l
		local ll
		local light
		local dirLights
		local pointLights
		local maxDirLights
		local maxPointLights;
		local dirLights = 0
		local pointLights = 0
		local maxDirLights = 0
		local maxPointLights = 0;

		ll = length(lights) - 1

		for l = 0, ll do

			light = lights[ l ];

			if ( getmetatable(light).types[THREE.DirectionalLight] ) then dirLights = dirLights + 1; end
			if ( getmetatable(light).types[THREE.PointLight] ) then pointLights = pointLights + 1; end

		end

		if ( ( pointLights + dirLights ) <= maxLights ) then

			maxDirLights = dirLights;
			maxPointLights = pointLights;

		else

			maxDirLights = math.ceil( maxLights * dirLights / ( pointLights + dirLights ) );
			maxPointLights = maxLights - maxDirLights;

		end

		return { directional = maxDirLights, point = maxPointLights };

	end
	return WGLR

end

