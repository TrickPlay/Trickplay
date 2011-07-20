
local gl = WebGLCanvas{ size = screen.size }

screen:add( gl )

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
local textureCoordAttribute
local pMatrixUniform
local mvMatrixUniform
local samplerUniform

local function initShaders()

   program = create_program( 
   
      [[
         attribute vec3 aVertexPosition;
         attribute vec2 aTextureCoord;
         
         uniform mat4 uMVMatrix;
         uniform mat4 uPMatrix;
         
         varying vec2 vTextureCoord;
         
         
         void main(void)
         {
             gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
             vTextureCoord = aTextureCoord;
         }
      ]]
      ,
      [[
         #ifdef GL_ES
         precision highp float;
         #endif
       
         varying vec2 vTextureCoord;
       
         uniform sampler2D uSampler;
       
         void main(void)
         {
             gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
         }
      ]]
      )      

   gl:useProgram( program )
   
   vertexPositionAttribute = gl:getAttribLocation( program , "aVertexPosition" )
   gl:enableVertexAttribArray( vertexPositionAttribute )

   textureCoordAttribute = gl:getAttribLocation( program , "aTextureCoord" )
   gl:enableVertexAttribArray( textureCoordAttribute )

   pMatrixUniform = gl:getUniformLocation( program , "uPMatrix" )
   mvMatrixUniform = gl:getUniformLocation( program , "uMVMatrix" )
   samplerUniform = gl:getUniformLocation( program , "uSampler" )
   
end

-------------------------------------------------------------------------------

local textures = {}

local function initTexture()

   local sources = { "stanley.png" , "craig.png" , "robert.png" , "money.jpg" }
   
   for i = 1 , # sources do
   
      local bitmap = Bitmap( sources[ i ] )
  
      local texture = gl:createTexture()

      gl:bindTexture( gl.TEXTURE_2D , texture )
      
      gl:texParameteri( gl.TEXTURE_2D , gl.TEXTURE_MAG_FILTER , gl.LINEAR )
      gl:texParameteri( gl.TEXTURE_2D , gl.TEXTURE_MIN_FILTER , gl.LINEAR )
      gl:texParameteri( gl.TEXTURE_2D , gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
      gl:texParameteri( gl.TEXTURE_2D , gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)      
      
      gl:pixelStorei( gl.UNPACK_FLIP_Y_WEBGL , 1 )
      gl:pixelStorei( gl.UNPACK_ALIGNMENT , 1 )
      --gl:pixelStorei( gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL , 1 )
      gl:texImage2D( gl.TEXTURE_2D , 0 , gl.RGB , gl.RGB , gl.UNSIGNED_BYTE , bitmap )

      gl:bindTexture( gl.TEXTURE_2D , 0 )

      table.insert( textures , texture )
   end
   
end

-------------------------------------------------------------------------------

local mvMatrix = Matrix()
local pMatrix 

-------------------------------------------------------------------------------

local function setMatrixUniforms()
   gl:uniformMatrix4fv( pMatrixUniform , false , pMatrix )
   gl:uniformMatrix4fv( mvMatrixUniform , false , mvMatrix)
end

-------------------------------------------------------------------------------

local cubeVertexPositionBuffer
local cubeVertexPositionBuffer_itemSize
local cubeVertexPositionBuffer_numItems

local cubeVertexTextureCoordBuffer
local cubeVertexTextureCoordBuffer_itemSize
local cubeVertexTextureCoordBuffer_numItems

local cubeVertexIndexBuffer
local cubeVertexIndexBuffer_itemSize
local cubeVertexIndexBuffer_numItems

local function initBuffers()

   cubeVertexPositionBuffer = gl:createBuffer()
   gl:bindBuffer( gl.ARRAY_BUFFER , cubeVertexPositionBuffer )
   local vertices = Float32Array(
   {
      -- Front face
      -1.0, -1.0,  1.0,
       1.0, -1.0,  1.0,
       1.0,  1.0,  1.0,
      -1.0,  1.0,  1.0,

      -- Back face
      -1.0, -1.0, -1.0,
      -1.0,  1.0, -1.0,
       1.0,  1.0, -1.0,
       1.0, -1.0, -1.0,

      -- Top face
      -1.0,  1.0, -1.0,
      -1.0,  1.0,  1.0,
       1.0,  1.0,  1.0,
       1.0,  1.0, -1.0,

      -- Bottom face
      -1.0, -1.0, -1.0,
       1.0, -1.0, -1.0,
       1.0, -1.0,  1.0,
      -1.0, -1.0,  1.0,

      -- Right face
       1.0, -1.0, -1.0,
       1.0,  1.0, -1.0,
       1.0,  1.0,  1.0,
       1.0, -1.0,  1.0,

      -- Left face
      -1.0, -1.0, -1.0,
      -1.0, -1.0,  1.0,
      -1.0,  1.0,  1.0,
      -1.0,  1.0, -1.0,
   })        
        
   gl:bufferData( gl.ARRAY_BUFFER , vertices , gl.STATIC_DRAW )
   
   cubeVertexPositionBuffer_itemSize = 3
   cubeVertexPositionBuffer_numItems = 24
   
   cubeVertexTextureCoordBuffer = gl:createBuffer()
   gl:bindBuffer( gl.ARRAY_BUFFER , cubeVertexTextureCoordBuffer )
   local textureCoords = Float32Array(
   {
      -- Front face
      0.0, 0.0,
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,

      -- Back face
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,
      0.0, 0.0,

      -- Top face
      0.0, 1.0,
      0.0, 0.0,
      1.0, 0.0,
      1.0, 1.0,

      -- Bottom face
      1.0, 1.0,
      0.0, 1.0,
      0.0, 0.0,
      1.0, 0.0,

      -- Right face
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,
      0.0, 0.0,

      -- Left face
      0.0, 0.0,
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,
   })
        
   gl:bufferData( gl.ARRAY_BUFFER , textureCoords , gl.STATIC_DRAW )
   cubeVertexTextureCoordBuffer_itemSize = 2
   cubeVertexTextureCoordBuffer_numItems = 24
   
   
   cubeVertexIndexBuffer = gl:createBuffer()
   gl:bindBuffer( gl.ELEMENT_ARRAY_BUFFER , cubeVertexIndexBuffer )
   local cubeVertexIndices = Uint16Array(
   {
       0, 1, 2,      0, 2, 3,    -- Front face
       4, 5, 6,      4, 6, 7,    -- Back face
       8, 9, 10,     8, 10, 11,  -- Top face
       12, 13, 14,   12, 14, 15, -- Bottom face
       16, 17, 18,   16, 18, 19, -- Right face
       20, 21, 22,   20, 22, 23  -- Left face
   })
   
   gl:bufferData( gl.ELEMENT_ARRAY_BUFFER , cubeVertexIndices , gl.STATIC_DRAW )
   cubeVertexIndexBuffer_itemSize = 1
   cubeVertexIndexBuffer_numItems = 36
end


-------------------------------------------------------------------------------

local distance = 5

local xRot = 0
local yRot = 0
local zRot = 0

local vw , vh = gl.width , gl.height

local aspect = vw / vh

local function drawScene()

    gl:acquire()
    
   gl:viewport( 0 , 0 , vw , vh )
   
   gl:clear( gl.COLOR_BUFFER_BIT + gl.DEPTH_BUFFER_BIT )

   if not pMatrix then
      pMatrix = Matrix()
      pMatrix:perspective( 45 , aspect , 0.1 , 100.0 )
   end

   gl:activeTexture( gl.TEXTURE0 )

   mvMatrix:identity()
   mvMatrix:translate( 0.0 , 0.0 , - distance )
   mvMatrix:rotate( xRot , 1 , 0 , 0 )
   mvMatrix:rotate( yRot , 0 , 1 , 0 )
   mvMatrix:rotate( zRot , 0 , 0 , 1 )

   gl:bindBuffer( gl.ARRAY_BUFFER , cubeVertexPositionBuffer )
   gl:vertexAttribPointer( vertexPositionAttribute , cubeVertexPositionBuffer_itemSize , gl.FLOAT , false , 0 , 0 )

   gl:bindBuffer( gl.ARRAY_BUFFER , cubeVertexTextureCoordBuffer )
   gl:vertexAttribPointer( textureCoordAttribute , cubeVertexTextureCoordBuffer_itemSize , gl.FLOAT , false , 0 , 0 )

   gl:uniform1i( samplerUniform , 0 )

   gl:bindBuffer( gl.ELEMENT_ARRAY_BUFFER , cubeVertexIndexBuffer )
   
   gl:bindTexture( gl.TEXTURE_2D , textures[ 1 ] )
   
   setMatrixUniforms();
   
   gl:drawElements( gl.TRIANGLES , cubeVertexIndexBuffer_numItems , gl.UNSIGNED_SHORT , 0 )


   mvMatrix:identity()
   mvMatrix:translate( 0.0 , 0.0 , - distance )
   mvMatrix:scale( 0.2 , 0.2 , 0.2 )
   mvMatrix:rotate( xRot , 1 , 0 , 0 )
   mvMatrix:rotate( yRot , 0 , 1 , 0 )
   mvMatrix:rotate( zRot , 0 , 0 , 1 )


   gl:bindTexture( gl.TEXTURE_2D , textures[ 4 ] )
   
   setMatrixUniforms();
   
   gl:drawElements( gl.TRIANGLES , cubeVertexIndexBuffer_numItems , gl.UNSIGNED_SHORT , 0 )




   mvMatrix:identity()
   mvMatrix:translate( 5.0 , 0.0 , - distance * 2 )
   mvMatrix:rotate( -xRot , 1 , 0 , 0 )
   mvMatrix:rotate( -yRot , 0 , 1 , 0 )
   mvMatrix:rotate( -zRot , 0 , 0 , 1 )

   gl:bindTexture( gl.TEXTURE_2D , textures[ 2 ] )
   
   setMatrixUniforms();
   
   gl:drawElements( gl.TRIANGLES , cubeVertexIndexBuffer_numItems , gl.UNSIGNED_SHORT , 0 )

   mvMatrix:identity()
   mvMatrix:translate( -5.0 , 0.0 , - distance * 2 )
   mvMatrix:rotate( -xRot , 1 , 0 , 0 )
   mvMatrix:rotate( -yRot , 0 , 1 , 0 )
   mvMatrix:rotate( -zRot , 0 , 0 , 1 )

   gl:bindTexture( gl.TEXTURE_2D , textures[ 3 ] )

   setMatrixUniforms();

   gl:drawElements( gl.TRIANGLES , cubeVertexIndexBuffer_numItems , gl.UNSIGNED_SHORT , 0 )

    gl:release()
end

-------------------------------------------------------------------------------

local lastTime = timestamp()

local ROTATE_SPEED = 45 -- degrees per second

local function animate()
   local timeNow = timestamp()
   local elapsed = ( timeNow - lastTime ) / 1000.0
   
   xRot = xRot + ( ROTATE_SPEED * elapsed ) 
   yRot = yRot + ( ROTATE_SPEED * elapsed ) 
   zRot = zRot + ( ROTATE_SPEED * elapsed ) 
   
   lastTime = timeNow
end

local function WebGLStart()
    gl:acquire()
   initGL()
   initShaders()
   initBuffers()
   initTexture()

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
   
   gl:clearColor( 0.2 , 0.0 , 0.0 , 1.0 )
   gl:enable( gl.DEPTH_TEST )
   --gl:enable( gl.CULL_FACE )
   gl:enable( gl.BLEND )
   
  gl:release()
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
         --print( string.format( "%d fps" , frames / t.elapsed_seconds ) )
         frames = 0
         t:start()
      end
   end
   
   local U = keys.Up
   local D = keys.Down
   
   local DIST = 0.1
   
   function screen:on_key_down( k )
      if k == D then
         distance = distance + DIST
      elseif k == U then
         distance = distance - DIST
      end
   end

end

end

screen:show()

WebGLStart()

