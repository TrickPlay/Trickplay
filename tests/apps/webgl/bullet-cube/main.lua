
    local function dump_properties( o )
        local t = {}
        local l = 0
        for k , v in pairs( getmetatable( o ).__getters__ ) do
            local s = v( o )
            if type( s ) == "table" then
                s = serialize( s )
            elseif type( s ) == "string" then
                s = string.format( "%q" , s )
            else
                s = tostring( s )
            end
            table.insert( t , { k , s } )
            l = math.max( l , # k )
        end
        table.sort( t , function( a , b ) return a[1] < b[1] end )
        for i = 1 , # t do
            print( string.format( "%-"..tostring(l+1).."s = %s" , t[i][1] , t[i][2] ) )
        end
    end

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

local cube_vs=
    {
       --          POSITION            
       1.00000, 1.00000, -1.00000, 
       1.00000, -1.00000, -1.00000, 
       -1.00000, -1.00000, -1.00000, 
       -1.00000, 1.00000, -1.00000,  
    
       -1.00000, -1.00000, 1.00000,  
       -1.00000, 1.00000, 1.00000,   
       -1.00000, 1.00000, -1.00000,  
       -1.00000, -1.00000, -1.00000, 
    
       1.00000, -1.00000, 1.00000,   
       1.00000, 1.00000, 1.00000,    
       -1.00000, -1.00000, 1.00000,  
       -1.00000, 1.00000, 1.00000,   
    
       1.00000, -1.00000, -1.00000,    
       1.00000, 1.00000, -1.00000,     
       1.00000, -1.00000, 1.00000,      
       1.00000, 1.00000, 1.00000,       
    
       1.00000, 1.00000, -1.00000,     
       -1.00000, 1.00000, -1.00000,    
       1.00000, 1.00000, 1.00000,       
       -1.00000, 1.00000, 1.00000,      
    
       1.00000, -1.00000, -1.00000,    
       1.00000, -1.00000, 1.00000,     
       -1.00000, -1.00000, 1.00000,     
       -1.00000, -1.00000, -1.00000,    
    }


local cube_is=
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
    }


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

local function dm( m )
    local t = m.table
    if t then
        m = t
    end
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[1] , m[5] , m[9] , m[13] ) )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[2] , m[6] , m[10] , m[14] ) )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[3] , m[7] , m[11] , m[15] ) )
    print( string.format( "%5.0f %5.0f %5.0f %5.0f" , m[4] , m[8] , m[12] , m[16] ) )
end

local function display( cubes )

    gl:acquire()

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
        
        gl:drawElements( gl.TRIANGLES , 3 * 12 , gl.UNSIGNED_SHORT , 0 )
    end
    
    gl:release()   
end


local function make_cube( x , y , z , hw , xr , yr , zr , props )

    local matrix = Matrix()

    matrix:translate( x , y , z )
    
    matrix:rotate( xr or 0 , 1 , 0 , 0 )
    matrix:rotate( yr or 0 , 0 , 1 , 0 )
    matrix:rotate( zr or 0 , 0 , 0 , 1 )
    
    local w , h , d = hw , hw , hw
    
    if type( hw ) == "table" then
        w , h , d = unpack( hw )
    end
    
    local shape
    
    if false then
        
        shape = pb:TriangleMeshShape( cube_vs , cube_is , { w , h , d } )
        
    else
    
        shape = pb:BoxShape( w , h , d )
        
    end
    
    --dumptable( shape.local_scaling )
    --dumptable( shape.aabb )
    
    local b = 
        {
            transform = matrix ,
            shape = shape,
            bounce = 0.1,
            mass = 1 ,
            friction = 1
        }
    
    if type( props ) == "table" then
        for k , v in pairs( props ) do
            b[ k ] = v
        end
    end
    
    local body = pb:Body3d( b )
        
    local sm = Matrix()
    
    pb:add( body )
    
    return
    {
        matrix = function() return body:get_transform( sm ):scale(w,h,d) end,
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
        make_cube( -250 , 200 , -1000 , 50 , 0 , 0 , 0 ),

----[[
        make_cube( -100 , 200 , -1000 , 50 , 0 , 0 , 0 ),
        
----[[
        make_cube( -400 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube( -200 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube(    0 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube(  200 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
        make_cube(  400 , 800 , -1000 , r(90) , r(90) , r(90) , r(90) ),
--]]
    }
    
    pb.gravity = { 0 ,  1 * -10 * 64 , 0  }
    
    local ground_matrix = Matrix()
    ground_matrix:translate( 0 , -320 , -1000 )
    local ground_shape = pb:StaticPlaneShape( 0 , 1 , 0 , 1 )
    local ground = pb:Body3d{ transform = ground_matrix , shape = ground_shape, mass = 0 , bounce = 0.5 , friction = 0.2 }
    
    local wall_matrix = Matrix()
    wall_matrix:translate( -200 , -320 , -1000 )
    local wall_shape = pb:StaticPlaneShape( 1 , 0.9 , 0 , 1 )
    local wall = pb:Body3d{ transform = wall_matrix , shape = wall_shape, mass = 0 , bounce = 0.5 , friction = 0.2 }
    
    pb:add( ground , wall )
        

--[[ Slider constraint example

    local c1 = cubes[1].body
    local c2 = cubes[2].body
    

    local cn = pb:SliderConstraint( c1 , Matrix():translate( 50 , 0 , 0 ) , false , c2 , Matrix():translate( -50 , 0 , 0 ) )
    
    --cn.linear_lower_limit = 600
    --cn.linear_upper_limit = 100
    
    dump_properties( cn )
    
    cn.linear_motor_on = true
    cn.linear_motor_target_velocity = 5
    cn.linear_motor_max_force = 10
    
    
    pb:add_constraint( cn , false )
    
--]]
    

--[[ Hinge constraint example

    local bar = make_cube( -300 , -320 + 150 , -1000 , { 10 , 150 , 50 } , 0 , 0 , 0 , { mass = 0 } )
    local paddle = make_cube( -300 + 150 + 10 , -320 + 150 + 150 + 25 , -1000 , { 150 , 25 , 50 } , 0 , 0 , 0 , { mass = 2 } )
    
    paddle.body.gravity = { 100 * 64 , 16 * 64 , 0 }
    paddle.body.angular_damping = 0.95
    
    cn = pb:HingeConstraint( bar.body , { 10 , 150 , 0 } , { 0 , 0 , 1 } , false , paddle.body , { -150 , -25 , 0 } , { 0 , 0 , 1 } )
    
    --cn:enable_angular_motor( true , 100000 , 1900 )
    --cn:set_motor_target( -10 , 10 )
    
    pb:add_constraint( cn )
    
    table.insert( cubes , bar )
    table.insert( cubes , paddle )

--]]    
    
    
    display( cubes )
    
   
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

    function pb:on_step( seconds )
--[[
        local contacts = pb:get_contacts( 10 ) -- , cubes[1].body , ground )
        
        if contacts then
            --print( # contacts )
            --dumptable( contacts )
        end
--]]        
    end

end

screen:show()

main()



