
local gl = WebGLCanvas{ size = screen.size }

screen:add( gl )

-------------------------------------------------------------------------------

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

local userData =
{
    programObject = 0,
    positionLoc = 0,
    texCoordLoc = 0,
    samplerLoc = 0,
    textureId = 0,
    vertexObject = 0,
    vertexBytesPerElement = 0,
    indexObject = 0
}


-------------------------------------------------------------------------------
-- Create a simple 2x2 texture image with four different colors
-------------------------------------------------------------------------------

local function CreateSimpleTexture2D( )

    -- Texture object handle
    local textureId
  
    -- 2x2 Image, 3 bytes per pixel (R, G, B)
    local pixels = Uint8Array({
       255,   0,   0, 
        0,   255,   0, 
         0 ,0, 255 ,
        255 , 255 , 0
    })
 
    -- Use tightly packed data
    gl:pixelStorei ( gl.UNPACK_ALIGNMENT, 1 )
  
    -- Generate a texture object
    textureId = gl:createTexture ( )
  
    -- Bind the texture object
    gl:bindTexture ( gl.TEXTURE_2D, textureId )
  
    -- Load the texture
    gl:texImage2D ( gl.TEXTURE_2D, 0, gl.RGB, 2, 2, 0, gl.RGB, gl.UNSIGNED_BYTE , pixels )
  
    -- Set the filtering mode
    gl:texParameteri ( gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST )
    gl:texParameteri ( gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST )
  
    return textureId
 
end


-------------------------------------------------------------------------------
-- Initialize the shader and program object
-------------------------------------------------------------------------------

local function Init (  )

   local vShaderStr =
    [[
       attribute vec4 a_position;   
       attribute vec2 a_texCoord;   
       varying vec2 v_texCoord;     
       void main()                  
       {                            
          gl_Position = a_position; 
          v_texCoord = a_texCoord;  
       }
    ]]
    
 
   local fShaderStr =
    [[
        #ifdef GL_ES
        precision highp float;
        #endif
        varying vec2 v_texCoord;                            
        uniform sampler2D s_texture;                        
        void main()                                         
        {                                                   
            gl_FragColor = texture2D( s_texture, v_texCoord );
        }
    ]]
 
   -- Load the shaders and get a linked program object
   userData.programObject = create_program( vShaderStr, fShaderStr );
 
   -- Get the attribute locations
   userData.positionLoc = gl:getAttribLocation ( userData.programObject, "a_position" );
   userData.texCoordLoc = gl:getAttribLocation ( userData.programObject, "a_texCoord" );
 
   -- Get the sampler location
   userData.samplerLoc = gl:getUniformLocation ( userData.programObject, "s_texture" );
 
   -- Load the texture
   userData.textureId = CreateSimpleTexture2D ();
   
   -- Setup the vertex data
   local vVertices = Float32Array(
                         { -0.5,  0.5, 0.0,  -- Position 0
                            0.0,  0.0,       -- TexCoord 0
                           -0.5, -0.5, 0.0,  -- Position 1
                            0.0,  1.0,       -- TexCoord 1
                            0.5, -0.5, 0.0,  -- Position 2
                            1.0,  1.0,       -- TexCoord 2
                            0.5,  0.5, 0.0,  -- Position 3
                            1.0,  0.0        -- TexCoord 3
                         });
                         
   local indices = Uint16Array({0, 1, 2, 0, 2, 3});
 
   userData.vertexObject = gl:createBuffer();
   gl:bindBuffer ( gl.ARRAY_BUFFER, userData.vertexObject );
   gl:bufferData ( gl.ARRAY_BUFFER, vVertices, gl.STATIC_DRAW );
   userData.vertexBytesPerElement = vVertices.BYTES_PER_ELEMENT;
   userData.indexObject = gl:createBuffer();
   gl:bindBuffer ( gl.ELEMENT_ARRAY_BUFFER, userData.indexObject );
   gl:bufferData ( gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW );
 
   gl:clearColor ( 0.0, 0.0, 0.0, 1.0 );
   return true;
end

-------------------------------------------------------------------------------
-- Draw a triangle using the shader pair created in Init()
-------------------------------------------------------------------------------

local vw , vh = gl.width , gl.height

function Draw (  )

   -- Set the viewport
   gl:viewport ( 0, 0, vw, vh);
 
   -- Clear the color buffer
   gl:clear ( gl.COLOR_BUFFER_BIT );
 
   -- Use the program object
   gl:useProgram ( userData.programObject );
 
   -- Load the vertex position
   gl:bindBuffer ( gl.ARRAY_BUFFER, userData.vertexObject );
   gl:vertexAttribPointer ( userData.positionLoc, 3, gl.FLOAT,
                           false, 5 * userData.vertexBytesPerElement, 0 );
   -- Load the texture coordinate
   gl:vertexAttribPointer ( userData.texCoordLoc, 2, gl.FLOAT,
                           false, 5 * userData.vertexBytesPerElement, 
                           3 * userData.vertexBytesPerElement );
 
   gl:enableVertexAttribArray ( userData.positionLoc );
   gl:enableVertexAttribArray ( userData.texCoordLoc );
 
   -- Bind the texture
   gl:activeTexture ( gl.TEXTURE0 );
   gl:bindTexture ( gl.TEXTURE_2D, userData.textureId );
 
   -- Set the sampler texture unit to 0
   gl:uniform1i ( userData.samplerLoc, 0 );
 
   gl:bindBuffer ( gl.ELEMENT_ARRAY_BUFFER, userData.indexObject );
   gl:drawElements ( gl.TRIANGLES, 6, gl.UNSIGNED_SHORT, 0 );
   
end
 
 
function main ( )

    gl:acquire()
    Init();
    gl:release()
    
    function idle.on_idle()
        gl:acquire()
        Draw()
        gl:release()
    end

end
 
 
screen:show()

main()

