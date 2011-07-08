
local gl = gl

-------------------------------------------------------------------------------
-- Generic creation of a shader program

local function create_program( vertex_shader_source , fragment_shader_source )

   local v = gl:createShader( gl.VERTEX_SHADER )
   local f = gl:createShader( gl.FRAGMENT_SHADER )
   
   gl:shaderSource( v , vertex_shader_source )
   gl:shaderSource( f , fragment_shader_source )
   
   gl:compileShader( v )
   assert( gl:getShaderParameter( v , gl.COMPILE_STATUS ) )
   
   gl:compileShader( f )
   assert( gl:getShaderParameter( f , gl.COMPILE_STATUS ) )
   
   local program = gl:createProgram()
   
   gl:attachShader( program , v )
   gl:attachShader( program , f )
   
   gl:linkProgram( program )
   
   assert( gl:getProgramParameter( program , gl.LINK_STATUS ) )
   
   return program

end

-------------------------------------------------------------------------------

local function initGL()
end

-------------------------------------------------------------------------------

local program

local vertexPositionAttribute
local vertexNormalAttribute
local textureCoordAttribute

local pMatrixUniform
local mvMatrixUniform
local nMatrixUniform
local samplerUniform
local materialShininessUniform
local showSpecularHighlightsUniform
local useTexturesUniform
local useLightingUniform
local ambientColorUniform
local pointLightingLocationUniform
local pointLightingSpecularColorUniform
local pointLightingDiffuseColorUniform

local function initShaders()

   program = create_program( readfile( "vertex.glsl" ) , readfile( "fragment.glsl" ) )

   gl:useProgram( program )
   
   vertexPositionAttribute = gl:getAttribLocation( program , "aVertexPosition" )
   gl:enableVertexAttribArray( vertexPositionAttribute )
   
   vertexNormalAttribute = gl:getAttribLocation( program , "aVertexNormal" )
   gl:enableVertexAttribArray( vertexNormalAttribute )
   
   textureCoordAttribute = gl:getAttribLocation( program , "aTextureCoord" )
   gl:enableVertexAttribArray( textureCoordAttribute )

   pMatrixUniform = gl:getUniformLocation(program, "uPMatrix")
   mvMatrixUniform = gl:getUniformLocation(program, "uMVMatrix")
   nMatrixUniform = gl:getUniformLocation(program, "uNMatrix")
   samplerUniform = gl:getUniformLocation(program, "uSampler")
   materialShininessUniform = gl:getUniformLocation(program, "uMaterialShininess")
   showSpecularHighlightsUniform = gl:getUniformLocation(program, "uShowSpecularHighlights")
   useTexturesUniform = gl:getUniformLocation(program, "uUseTextures")
   useLightingUniform = gl:getUniformLocation(program, "uUseLighting")
   ambientColorUniform = gl:getUniformLocation(program, "uAmbientColor")
   pointLightingLocationUniform = gl:getUniformLocation(program, "uPointLightingLocation")
   pointLightingSpecularColorUniform = gl:getUniformLocation(program, "uPointLightingSpecularColor")
   pointLightingDiffuseColorUniform = gl:getUniformLocation(program, "uPointLightingDiffuseColor")
   
end

-------------------------------------------------------------------------------

local function initTextures( ... )

   local sources = {...}
   
   local textures = {}

   for i = 1 , # sources do
   
      local bitmap = Bitmap( sources[ i ] )
  
      local texture = gl:createTexture()

      gl:pixelStorei( gl.UNPACK_FLIP_Y_WEBGL , 1 )
      gl:bindTexture( gl.TEXTURE_2D , texture )
      gl:texImage2D( gl.TEXTURE_2D , 0 , gl.RGB , gl.RGB , gl.UNSIGNED_BYTE , bitmap )
      gl:texParameteri( gl.TEXTURE_2D , gl.TEXTURE_MAG_FILTER , gl.NEAREST )
      gl:texParameteri( gl.TEXTURE_2D , gl.TEXTURE_MIN_FILTER , gl.LINEAR_MIPMAP_NEAREST )
      gl:generateMipmap(gl.TEXTURE_2D)
      gl:bindTexture( gl.TEXTURE_2D , 0 )

      table.insert( textures , texture )
   end

   return unpack( textures )
end

-------------------------------------------------------------------------------

local earthTexture
local galvanizedTexture
local logoTexture

-------------------------------------------------------------------------------

local mvMatrix = Matrix()
local pMatrix 

-------------------------------------------------------------------------------

local function mat4_to_inverse_mat3( matrix )
   local a = matrix.table
   local c=a[1]
   local d=a[2]
   local e=a[3]
   local g=a[5]
   local f=a[6]
   local h=a[7]
   local i=a[9]
   local j=a[10]
   local k=a[11]
   local l=k*f-h*j
   local o=-k*g+h*i
   local m=j*g-f*i
   local n=c*l+d*o+e*m
   
   if n == 0 then
      return nil
   end
   
   n=1/n
   
   local b = {}
   
   b[1]=l*n
   b[2]=(-k*d+e*j)*n
   b[3]=(h*d-e*f)*n
   b[4]=o*n
   b[5]=(k*c-e*i)*n
   b[6]=(-h*c+e*g)*n
   b[7]=m*n
   b[8]=(-j*c+d*i)*n
   b[9]=(f*c-d*g)*n
   
   return b
end

-------------------------------------------------------------------------------

local function setMatrixUniforms()
   gl:uniformMatrix4fv( pMatrixUniform , false , pMatrix )
   gl:uniformMatrix4fv( mvMatrixUniform , false , mvMatrix )

   local normalMatrix = mat4_to_inverse_mat3( mvMatrix )
   --mat3.transpose(normalMatrix);
   gl:uniformMatrix3fv( nMatrixUniform , true , normalMatrix )
end

-------------------------------------------------------------------------------

local teapotVertexNormalBuffer
local teapotVertexNormalBuffer_itemSize
local teapotVertexNormalBuffer_numItems

local teapotVertexPositionBuffer
local teapotVertexPositionBuffer_itemSize
local teapotVertexPositionBuffer_numItems

local teapotVertexTextureCoordBuffer
local teapotVertexTextureCoordBuffer_itemSize
local teapotVertexTextureCoordBuffer_numItems

local teapotVertexIndexBuffer
local teapotVertexIndexBuffer_itemSize
local teapotVertexIndexBuffer_numItems

local function initBuffers()

   local teapotData = json:parse( readfile( "teapot.json" ) )

   teapotVertexNormalBuffer = gl:createBuffer()
   gl:bindBuffer(gl.ARRAY_BUFFER, teapotVertexNormalBuffer)
   gl:bufferData(gl.ARRAY_BUFFER, Float32Array(teapotData.vertexNormals), gl.STATIC_DRAW)
   teapotVertexNormalBuffer_itemSize = 3;
   teapotVertexNormalBuffer_numItems = ( # teapotData.vertexNormals ) / 3

   teapotVertexTextureCoordBuffer = gl:createBuffer()
   gl:bindBuffer(gl.ARRAY_BUFFER, teapotVertexTextureCoordBuffer)
   gl:bufferData(gl.ARRAY_BUFFER, Float32Array(teapotData.vertexTextureCoords), gl.STATIC_DRAW)
   teapotVertexTextureCoordBuffer_itemSize = 2
   teapotVertexTextureCoordBuffer_numItems = ( # teapotData.vertexTextureCoords ) / 2

   teapotVertexPositionBuffer = gl:createBuffer();
   gl:bindBuffer(gl.ARRAY_BUFFER, teapotVertexPositionBuffer)
   gl:bufferData(gl.ARRAY_BUFFER, Float32Array(teapotData.vertexPositions), gl.STATIC_DRAW)
   teapotVertexPositionBuffer_itemSize = 3
   teapotVertexPositionBuffer_numItems = ( # teapotData.vertexPositions ) / 3

   teapotVertexIndexBuffer = gl:createBuffer()
   gl:bindBuffer(gl.ELEMENT_ARRAY_BUFFER, teapotVertexIndexBuffer)
   gl:bufferData(gl.ELEMENT_ARRAY_BUFFER, Uint16Array(teapotData.indices), gl.STATIC_DRAW)
   teapotVertexIndexBuffer_itemSize = 1
   teapotVertexIndexBuffer_numItems = # teapotData.indices
   
end


-------------------------------------------------------------------------------

local vw , vh = unpack( screen.display_size )
local aspect = vw / vh

-------------------------------------------------------------------------------

local teapotAngle = 180

local teapotXAngle = 0
local teapotZAngle = 0

local specularHighlights = 1

local lighting = 1

local ambientR = 0.2
local ambientG = 0.2
local ambientB = 0.2

local lightPositionX = -10
local lightPositionY = 4
local lightPositionZ = -20

local specularR = 0.8
local specularG = 0.8
local specularB = 0.8

local diffuseR = 0.8
local diffuseG = 0.8
local diffuseB = 0.8

local shininess = 32

local function drawScene()

   gl:viewport( 0 , 0 , vw , vh )
   
   gl:clear( gl.COLOR_BUFFER_BIT + gl.DEPTH_BUFFER_BIT )

   if not pMatrix then
      pMatrix = Matrix()
      pMatrix:perspective( 45 , aspect , 0.1 , 100.0 )
   end
   
   gl:uniform1i( showSpecularHighlightsUniform , specularHighlights )

   gl:uniform1i( useLightingUniform, lighting )
   
   if (lighting == 1) then
       gl:uniform3f( ambientColorUniform , ambientR , ambientG , ambientB )
       gl:uniform3f( pointLightingLocationUniform, lightPositionX , lightPositionY , lightPositionZ )
       gl:uniform3f( pointLightingSpecularColorUniform, specularR , specularG , specularB )
       gl:uniform3f( pointLightingDiffuseColorUniform, diffuseR , diffuseG , diffuseB )
   end
   
   gl:uniform1i( useTexturesUniform , 1 )

   mvMatrix:identity()
   mvMatrix:translate( 0 , 0 , -40 )
   mvMatrix:rotate( teapotXAngle , 1 , 0 , 0 )
   mvMatrix:rotate( teapotZAngle , 0 , 0 , 1 )
   mvMatrix:rotate( teapotAngle , 0, 1, 0 )

   gl:activeTexture(gl.TEXTURE0)
   gl:bindTexture(gl.TEXTURE_2D, logoTexture )
   
   gl:uniform1i( samplerUniform, 0)

   gl:uniform1f( materialShininessUniform, shininess )

   gl:bindBuffer(gl.ARRAY_BUFFER, teapotVertexPositionBuffer)
   gl:vertexAttribPointer(vertexPositionAttribute, teapotVertexPositionBuffer_itemSize, gl.FLOAT, false, 0, 0)

   gl:bindBuffer(gl.ARRAY_BUFFER, teapotVertexTextureCoordBuffer)
   gl:vertexAttribPointer(textureCoordAttribute, teapotVertexTextureCoordBuffer_itemSize, gl.FLOAT, false, 0, 0);

   gl:bindBuffer(gl.ARRAY_BUFFER, teapotVertexNormalBuffer);
   gl:vertexAttribPointer(vertexNormalAttribute, teapotVertexNormalBuffer_itemSize, gl.FLOAT, false, 0, 0);

   gl:bindBuffer(gl.ELEMENT_ARRAY_BUFFER, teapotVertexIndexBuffer)
   setMatrixUniforms()
   gl:drawElements(gl.TRIANGLES, teapotVertexIndexBuffer_numItems, gl.UNSIGNED_SHORT, 0)


   gl:swap()
end

-------------------------------------------------------------------------------

local lastTime = timestamp()

local ROTATE_SPEED = 50 -- degrees per second

local function animate()
   local timeNow = timestamp()
   local elapsed = ( timeNow - lastTime ) / 1000.0

   teapotAngle = teapotAngle + ( ROTATE_SPEED  * elapsed )
   
   lastTime = timeNow
end

local function WebGLStart()
   -----------------------------------------
   -- These are the GL defaults
   gl:disable( gl.BLEND )
   gl:disable( gl.CULL_FACE )
   gl:disable( gl.DEPTH_TEST )
   gl:disable( gl.POLYGON_OFFSET_FILL )
   gl:disable( gl.SAMPLE_ALPHA_TO_COVERAGE )
   gl:disable( gl.SAMPLE_COVERAGE )
   gl:disable( gl.SCISSOR_TEST )
   gl:disable( gl.STENCIL_TEST )
   gl:enable( gl.DITHER )
   gl:frontFace( gl.CCW )
   -----------------------------------------

   initGL()
   initShaders()
   initBuffers()

   earthTexture , galvanizedTexture , logoTexture = initTextures( "earth.jpg" , "metal.jpg" , "logo.png" )
   
   gl:clearColor( 0.2 , 0.0 , 0.0 , 1.0 )
   gl:enable( gl.DEPTH_TEST )
      
   print( "READY" )
   
if false then

   function screen:on_key_down( key )
      if key == keys.Return then
         drawScene()
         animate()
      end
   end

else

   local frames = 0
   local t = Stopwatch()
   
   function idle.on_idle()
      drawScene()
      animate()
       
      frames = frames + 1
      if t.elapsed_seconds >= 1 then
         print( string.format( "%d fps" , frames / t.elapsed_seconds ) )
         frames = 0
         t:start()
      end
   end
   
   local U = keys.Up
   local D = keys.Down
   local L = keys.Left
   local R = keys.Right
   
   function screen:on_key_down( key )
      if key == U then
         teapotXAngle = teapotXAngle - 1
      elseif key == D then
         teapotXAngle = teapotXAngle + 1
      elseif key == L then
         teapotZAngle = teapotZAngle - 1
      elseif key == R then
         teapotZAngle = teapotZAngle + 1
      end
   end
end

end

screen:show()

dolater( 1000 , WebGLStart )

