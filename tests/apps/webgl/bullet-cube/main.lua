
local gl = WebGLCanvas{ size = screen.size }

screen:add( gl )

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
        #ifdef GL_ES
        precision highp float;
        #endif
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
    gl:clearColor( 0.0 , 0.2 , 0.0 , 0.5 )
    
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
        projection_matrix:perspective( 45 , panel_aspect , 100 , 2000 )
    else
        projection_matrix:perspective( 45 , width / height , 100 , 90000 )
    end
    
    modelview_matrix:identity()
    modelview_matrix:translate( 0 , 200 , -1000 )
    modelview_matrix:scale( 100 , 100 , 100 )

    modelview_matrix:rotate( 45 , 0 , 1 , 1 )
--    modelview_matrix:rotate( 0.5 , 0 , 1 , 1 )
end

local function display( cubes )

    gl:acquire()

    --modelview_matrix:rotate( 1 , 1 , 0 , 0 )
    
    --modelview_matrix:rotate( 0.5 , 0 , 1 , 0 )

    gl:clear( gl.COLOR_BUFFER_BIT + gl.STENCIL_BUFFER_BIT + gl.DEPTH_BUFFER_BIT )
    
    gl:useProgram( program )
    
    gl:bindBuffer( gl.ARRAY_BUFFER , vbo_0 )
    gl:vertexAttribPointer( position_loc , 3 , gl.FLOAT , false , 6 * 4 , 0 )
    gl:vertexAttribPointer( color_loc , 3 , gl.FLOAT , false , 6 * 4 , 3 * 4 )
    gl:enableVertexAttribArray( position_loc )
    gl:enableVertexAttribArray( color_loc )
    
    gl:bindBuffer( gl.ELEMENT_ARRAY_BUFFER , vbo_1 )

    for i = 1 , # cubes do
    
        local cube = cubes[ i ]
        
        mvp_matrix:identity():multiply( projection_matrix , cube.matrix() )

        gl:uniformMatrix4fv( mvp_matrix_loc , false , mvp_matrix )
        gl:drawElements( gl.TRIANGLES , 36 , gl.UNSIGNED_SHORT , 0 )
    end
    
    gl:release()   
end

local function dm( m )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[1] , m[5] , m[9] , m[13] ) )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[2] , m[6] , m[10] , m[14] ) )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[3] , m[7] , m[11] , m[15] ) )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[4] , m[8] , m[12] , m[16] ) )
end

local function make_cube( x , y , z , hw , xr , yr , zr )

    local matrix = Matrix()

    matrix:translate( x , y , z )
    
    matrix:rotate( xr or 0 , 1 , 0 , 0 )
    matrix:rotate( yr or 0 , 0 , 1 , 0 )
    matrix:rotate( zr or 0 , 0 , 0 , 1 )
    
    local function gt()
        return matrix
    end
    
    local body =
        
        pb:Body3d
        {
            transform = matrix ,
            shape = pb:BoxShape( hw , hw , hw ),
            bounce = 0.1,
            mass = 1 ,
            friction = 1,
            on_get_transform = gt,
            on_set_transform = gt
        }
        
    local sm = Matrix()
        
    return
    {
        matrix = function() return sm:set( matrix ):scale(hw,hw,hw) end,
        body = body
    }
    
end

local function main()
    
    local vw  = gl.width
    local vh = gl.height

    gl:acquire()    
    init_gl_state()
    init_gl_viewport( vw , vh , 1 , false )
    gl:release()
    
    for i = 1 , 10 do
        collectgarbage( "collect" )
    end
    
    local function r(a)
        return math.random(a)
    end
    
    local cubes =
    {
--        make_cube(    0 , 200 , -1000 , 100 , 45 , 45 , 45 ),
        make_cube( -200 ,   0 , -1000 , 50 , 47 , 0 , r(90) ),
--        make_cube(  100 , 600 , -1000 , 100 ),
        make_cube( -300 , 400 , -1000 , 50 , 47 , 0 , r(90) ),
        

        make_cube( -400 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube( -200 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube(    0 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube(  200 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube(  400 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),

    }
    
    display( cubes )
    
    pb.gravity = { 0 , -10 * 64 , 0  }
    
    local ground_matrix = Matrix()
    ground_matrix:translate( 0 , -300 , -1000 )
    local ground = pb:Body3d{ transform = ground_matrix , shape = pb:BoxShape( 10000 , 16 , 100000 ) , mass = 0 , bounce = 0.4 , friction = 0.5 }
    
    local function render()
        pb:step()
        display( cubes )
    end
   
    function screen:on_key_down( k )
        if k == keys.OK then
            render()
        elseif k == keys.Up then
            for _ , c in ipairs( cubes ) do
                dm( c.matrix().table )
            end
        end
    end
    

    function idle.on_idle() render() end


end

screen:show()

main()
