
local gl = gl

local vbo_0
local vbo_1

local position_loc
local color_loc
local mvp_matrix_loc

local projection_matrix = Matrix()
local modelview_matrix = Matrix()
local mvp_matrix = Matrix()

local program


local function init_gl_state()

   local v_shader_source =
   [[
      uniform mat4   u_mvpMatrix;               
      attribute vec4 a_position;                
      attribute vec4 a_color;                   
      varying vec4   v_color;                   
                                                
      void main()                               
      {                                         
        gl_Position = u_mvpMatrix * a_position; 
        v_color = a_color;                      
      }
    ]]
    
    local f_shader_source =
    [[
      precision mediump float;                  
      varying vec4 v_color;                     
                                                
      void main()                               
      {                                         
        gl_FragColor = v_color;                 
      }                                         
    ]]

    local cube = Float32Array(
    {
       --          POSITION                            COLOR                
       1.00000, 1.00000, -1.00000,     1.00000, 0.00000, 0.00000,
       1.00000, -1.00000, -1.00000,    1.00000, 0.00000, 0.00000,
       -1.00000, -1.00000, -1.00000,   1.00000, 0.00000, 0.00000, 
       -1.00000, 1.00000, -1.00000,    1.00000, 0.00000, 0.00000, 
    
       -1.00000, -1.00000, 1.00000,    1.00000, 1.00000, 0.00000,
       -1.00000, 1.00000, 1.00000,     1.00000, 1.00000, 0.00000,
       -1.00000, 1.00000, -1.00000,    1.00000, 1.00000, 0.00000, 
       -1.00000, -1.00000, -1.00000,   1.00000, 1.00000, 0.00000, 
    
       1.00000, -1.00000, 1.00000,     0.00000, 0.00000, 1.00000,
       1.00000, 1.00000, 1.00000,      0.00000, 0.00000, 1.00000,
       -1.00000, -1.00000, 1.00000,    0.00000, 0.00000, 1.00000, 
       -1.00000, 1.00000, 1.00000,     0.00000, 0.00000, 1.00000, 
    
       1.00000, -1.00000, -1.00000,    1.00000, 0.00000, 1.00000,
       1.00000, 1.00000, -1.00000,     1.00000, 0.00000, 1.00000,
       1.00000, -1.00000, 1.00000,     1.00000, 0.00000, 1.00000, 
       1.00000, 1.00000, 1.00000,      1.00000, 0.00000, 1.00000, 
    
       1.00000, 1.00000, -1.00000,     0.00000, 1.00000, 0.00000,
       -1.00000, 1.00000, -1.00000,    0.00000, 1.00000, 0.00000,
       1.00000, 1.00000, 1.00000,      0.00000, 1.00000, 0.00000, 
       -1.00000, 1.00000, 1.00000,     0.00000, 1.00000, 0.00000, 
    
       1.00000, -1.00000, -1.00000,    0.00000, 1.00000, 1.00000,
       1.00000, -1.00000, 1.00000,     0.00000, 1.00000, 1.00000,
       -1.00000, -1.00000, 1.00000,    0.00000, 1.00000, 1.00000, 
       -1.00000, -1.00000, -1.00000,   0.00000, 1.00000, 1.00000, 
    })
    
    local cube_idx = Uint16Array(
    {
       0, 1, 2,
       3, 0, 2,
       4, 5, 6,
       7, 4, 6,
       8, 9, 10,
       9, 11, 10,
       12, 13, 14,
       13, 15, 14,
       16, 17, 18,
       17, 19, 18,
       20, 21, 22,
       23, 20, 22,
    })
    
    gl:clearDepth( 1.0 )
    gl:clearColor( 0.0 , 0.2 , 0.0 , 1 )
    
    gl:enable( gl.DEPTH_TEST )
    gl:enable( gl.CULL_FACE )

    vbo_0 = gl:createBuffer()
    vbo_1 = gl:createBuffer()
    
    gl:bindBuffer( gl.ARRAY_BUFFER , vbo_0 )
    gl:bufferData( gl.ARRAY_BUFFER , cube , gl.STATIC_DRAW )
    
    gl:bindBuffer( gl.ELEMENT_ARRAY_BUFFER , vbo_1 )
    gl:bufferData( gl.ELEMENT_ARRAY_BUFFER , cube_idx , gl.STATIC_DRAW )
    
    local v = gl:createShader( gl.VERTEX_SHADER )
    local f = gl:createShader( gl.FRAGMENT_SHADER )
    
    gl:shaderSource( v , v_shader_source )
    gl:shaderSource( f , f_shader_source )
    
    gl:compileShader( v )
    assert( gl:getShaderParameter( v , gl.COMPILE_STATUS ) )
    
    gl:compileShader( f )
    assert( gl:getShaderParameter( f , gl.COMPILE_STATUS ) )
    
    program = gl:createProgram()
    
    gl:attachShader( program , v )
    gl:attachShader( program , f )
    
    gl:linkProgram( program )
    
    assert( gl:getProgramParameter( program , gl.LINK_STATUS ) )    
    
    position_loc = gl:getAttribLocation( program , "a_position" )
    color_loc = gl:getAttribLocation( program , "a_color" )

   
    mvp_matrix_loc = gl:getUniformLocation( program , "u_mvpMatrix" )
end


local function init_gl_viewport( width , height , panel_aspect , stretch )

    gl:viewport( 0 , 0 , width , height )
    
    if stretch then
        projection_matrix:perspective( 45 , panel_aspect , 100 , 1000 )
    else
        projection_matrix:perspective( 45 , width / height , 100 , 1000 )
    end
    
    modelview_matrix:identity()
    modelview_matrix:translate( 0 , 0 , -500 )
    modelview_matrix:scale( 100 , 100 , 100 )
end

local function display()

    modelview_matrix:rotate( 1 , 1 , 0 , 0 )
    
    modelview_matrix:rotate( 0.5 , 0 , 1 , 0 )
    
    mvp_matrix:multiply( projection_matrix , modelview_matrix )

    gl:clear( gl.COLOR_BUFFER_BIT + gl.STENCIL_BUFFER_BIT + gl.DEPTH_BUFFER_BIT )
    
    gl:useProgram( program )
    
    gl:bindBuffer( gl.ARRAY_BUFFER , vbo_0 )
    gl:vertexAttribPointer( position_loc , 3 , gl.FLOAT , false , 6 * 4 , 0 )
    gl:vertexAttribPointer( color_loc , 3 , gl.FLOAT , false , 6 * 4 , 3 * 4 )
    gl:enableVertexAttribArray( position_loc )
    gl:enableVertexAttribArray( color_loc )
    
    gl:uniformMatrix4fv( mvp_matrix_loc , false , mvp_matrix )
    
    gl:bindBuffer( gl.ELEMENT_ARRAY_BUFFER , vbo_1 )
    
    gl:drawElements( gl.TRIANGLES , 36 , gl.UNSIGNED_SHORT , 0 )
    
    gl:swap()
end

local function main()
    
    local vw , vh = unpack( screen.display_size )
    
    init_gl_state()
    init_gl_viewport( vw , vh , 1 , false )
    
    for i = 1 , 10 do
        collectgarbage( "collect" )
    end
    
    print( "Rendering" )
    
    local frames = 0
    local t = Stopwatch()
    
    function idle.on_idle()
        display()
        frames = frames + 1
        if t.elapsed_seconds >= 1 then
            print( string.format( "%d fps" , frames / t.elapsed_seconds ) )
            frames = 0
            t:start()
        end
        
    end

end

screen:show()

dolater(  dolater , main )
--main()
