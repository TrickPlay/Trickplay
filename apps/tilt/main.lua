screen:show()

--make 'gl' global or else you get this error
--LUA ERROR : ...x/tp/apps/tilt/THREE/src/renderers/WebGLRenderer.lua:75: attempt to index local '_gl' (a nil value)
gl=WebGLCanvas{size=screen.size}
screen:add(gl)

dofile("THREE/src/THREE.lua")

--------------------------------------------------------------------------------
-- Game Parameters
--------------------------------------------------------------------------------

local ball_r  =   40

local board_w = 900
local board_h = 600

local blox = {
    {x = 250, y =  -150, w = 200, h = 10},
    {x = 250, y =  150, w = 200, h = 10},
    {x = 250, y =  0, w = 200, h = 10},
    {x =   0, y = 200, w = 10, h = 40},


    {x =  -100, y = 0, w = 10, h = 80},
    {x =  -200, y = -200, w = 60, h = 60},
    {x =  -250, y = -30, w = 60, h = 60},
    {x =  -250, y = 200, w = 20, h = 20},
    {x =  -300, y = 160, w = 20, h = 20},
    {x =  -350, y = 200, w = 20, h = 20},
    
    
}





--------------------------------------------------------------------------------
-- Physics Setup - w/ invisible bodies
--------------------------------------------------------------------------------

local meta_board = Group{}

---------------
-- The Marble
---------------
local ball = physics:Body(
    Group{size = {ball_r*2,ball_r*2}},
    {
        density =  .6,
        bounce  = .2,
        filter  = { group = 1 },
        shape   = physics:Circle(ball_r),
        fixed_rotation   = true,
        sleeping_allowed = false,
        linear_damping   = .5
    }
)

function ball:on_begin_contact(c)
    
    if  math.abs(ball.linear_velocity[1]) > 6 or
        math.abs(ball.linear_velocity[2]) > 6 then
        
        mediaplayer:play_sound("tap-lg.mp3")
        
    elseif  math.abs(ball.linear_velocity[1]) > 2 or
            math.abs(ball.linear_velocity[2]) > 2 then
        
        mediaplayer:play_sound("tap-sm.mp3")
        
    end
    
end

meta_board:add(ball)


do
    ---------------
    -- The Walls
    ---------------
    local t_wall = physics:Body(
        Group{ size = {board_w,15} },
        {type="static"}
    )
    local b_wall = physics:Body(
        Group{ size = {board_w,15} },
        {type="static"}
    )
    local l_wall = physics:Body(
        Group{ size = {15,board_h} },
        {type="static"}
    )
    local r_wall = physics:Body(
        Group{ size = {15,board_h} },
        {type="static"}
    )
    
    t_wall.position = {          0,   board_h/2 }
    b_wall.position = {          0,  -board_h/2 }
    l_wall.position = { -board_w/2,           0 }
    r_wall.position = {  board_w/2,           0 }
    
    meta_board:add(  t_wall,  b_wall,  l_wall,  r_wall  )
    
    ---------------
    -- The Blocks
    ---------------
    for _,b in pairs(blox) do
        
        local block = physics:Body(
            Group{ size = {b.w,b.h} },
            {type="static"}
        )
        block.x = b.x
        block.y = b.y
        
        meta_board:add(block)
        
    end
    
    screen:add(meta_board)
    
end



--------------------------------------------------------------------------------
-- WebGL Setup
--------------------------------------------------------------------------------

-- do this line, otherwise you get this error
-- LUA ERROR : ...x/tp/apps/tilt/THREE/src/renderers/WebGLRenderer.lua:75: You must call 'acquire' first
gl:acquire()



local scene  = THREE.Scene();

local b = Bitmap("wood.jpg")
local b2 = Bitmap("wood-2.jpg")
local w_bmp = Bitmap("wall.jpg")


--Object Constructors
function makeCube(x,y,z,w,h,d,bmp)
	
    local tex = THREE.Texture(bmp)
    tex.needsUpdate = true
    
    local geometry = THREE.CubeGeometry( w,h,d,20,4,20);
    
	local materials = {};
	--[=[
    for i = 0,length(geometry.faces)-1 do
		local face = geometry.faces[i]
		face.material = {[0]=THREE.MeshLambertMaterial{ map = tex--[[color= c, shading= THREE.SmoothShading]] } }
	end
    --]=]
	local cube = THREE.Mesh(geometry, THREE.MeshLambertMaterial{ map = tex --[[color= c, shading= THREE.SmoothShading]] })
    
    cube.position.x = x
    cube.position.y = y
    cube.position.z = z
    
	return cube
    
end

local sphere_shader = THREE.ShaderUtils.lib["normal"]
uniforms = THREE.UniformsUtils.clone( sphere_shader.uniforms )
--local tex = THREE.Texture(b2)

local cloudsTexture     = Bitmap( "planets/earth_clouds_1024.png" )
local moonTexture       = Bitmap( "planets/moon_1024.jpg" )
local bubblesTexture    = Bitmap( "planets/bubbles.png" )
local bubbles2Texture   = Bitmap( "planets/bubbles2.png" )
local planetTexture     = Bitmap( "planets/earth_atmos_2048.jpg" )
local normalTexture     = Bitmap( "planets/earth_normal_2048.jpg" )
local specularTexture   = Bitmap( "planets/earth_specular_2048.jpg" )

cloudsTexture     = THREE.Texture(cloudsTexture)
moonTexture       = THREE.Texture(moonTexture)
bubblesTexture    = THREE.Texture(bubblesTexture)
bubbles2Texture   = THREE.Texture(bubbles2Texture)
planetTexture     = THREE.Texture(planetTexture)
normalTexture     = THREE.Texture(normalTexture)
specularTexture   = THREE.Texture(specularTexture)


cloudsTexture.needsUpdate   = true  
moonTexture.needsUpdate   = true    
bubblesTexture.needsUpdate   = true 
bubbles2Texture.needsUpdate   = true
planetTexture.needsUpdate   = true
normalTexture.needsUpdate   = true
specularTexture.needsUpdate = true


--tex.needsUpdate = true
uniforms[ "tNormal" ].texture    = normalTexture
uniforms[ "uNormalScale" ].value = 0.85

uniforms[ "tDiffuse" ].texture  = planetTexture
uniforms[ "tSpecular" ].texture = specularTexture

uniforms[ "enableAO" ].value       = 0
uniforms[ "enableDiffuse" ].value  = 1
uniforms[ "enableSpecular" ].value = 1

uniforms[ "uDiffuseColor" ].value:setHex(  0xffffff )
uniforms[ "uSpecularColor" ].value:setHex( 0xaaaaaa )
uniforms[ "uAmbientColor" ].value:setHex(  0x000000 )

uniforms[ "uShininess" ].value = 100

local texture_i = 0
local textures = {
    planetTexture,
    moonTexture,
    specularTexture,
    bubblesTexture,
    bubbles2Texture,
    cloudsTexture
}

function makeSphere(x,y,z,r,c)
    
    local geometry = THREE.SphereGeometry( r, 20,20);
	
    local materials = {};
	--[=[
    for i = 0,length(geometry.faces)-1 do
		local face = geometry.faces[i]
		face.material = {[0]=THREE.MeshBasicMaterial{ map = tex--[[color= c, shading= THREE.SmoothShading]] } }
	end
    --]=]
	local sphere = THREE.Mesh(geometry, THREE.MeshShaderMaterial{
            fragmentShader = sphere_shader.fragmentShader,
            vertexShader   = sphere_shader.vertexShader,
            uniforms       = uniforms,
            lights         = true
        }
    )
    
    
    sphere.position.x = x
    sphere.position.y = y
    sphere.position.z = z
    
	return sphere
    
end

do

    local corner_dist = 800
    local height      = 1200

	local pointLight1 = THREE.PointLight( 0xffffff, .3 )
	pointLight1.position.y=corner_dist
	pointLight1.position.x=corner_dist
	pointLight1.position.z=height

	local pointLight2 = THREE.PointLight( 0xffffff, .3 )
	pointLight2.position.y=-corner_dist
	pointLight2.position.x=corner_dist
	pointLight2.position.z=height
    
    local pointLight3 = THREE.PointLight( 0xffffff, .3 )
	pointLight3.position.y=corner_dist
	pointLight3.position.x=-corner_dist
	pointLight3.position.z=height
    
    local pointLight4 = THREE.PointLight( 0xffffff, .3 )
	pointLight4.position.y=-corner_dist
	pointLight4.position.x=-corner_dist
	pointLight4.position.z=height
    
	--dLight = THREE.DirectionalLight(0xffffff, 1)
	--scene:addLight(pointLight1)
    --dumptable(scene)
    --print(rawget(scene,addLight))
    scene:addLight(pointLight1)
    scene:addLight(pointLight2)
    scene:addLight(pointLight3)
    scene:addLight(pointLight4)
	--scene:addLight(dLight)
end


--the Board object
local gl_board = THREE.Object3D();

do
    --Walls and Floor
    local base     = makeCube(          0, -ball_r,          0,    board_w,         15,    board_h, b )
	local wall_f   = makeCube(          0,       0, -board_h/2, board_w+15, 1.5*ball_r,         15, w_bmp )
	local wall_f_x = makeCube(          0,       0, -board_h/2-20, board_w+15, 1.5*ball_r,         15, w_bmp )
	local wall_b   = makeCube(          0,       0,  board_h/2, board_w+15, 1.5*ball_r,         15, w_bmp )
	local wall_b_x = makeCube(          0,       0,  board_h/2+20, board_w+15, 1.5*ball_r,         15, w_bmp )
	local wall_r   = makeCube( -board_w/2,       0,          0,         15, 1.5*ball_r, board_h+15, w_bmp )
	local wall_r_x = makeCube( -board_w/2-20,       0,          0,         15, 1.5*ball_r, board_h+15, w_bmp )
	local wall_l   = makeCube(  board_w/2,       0,          0,         15, 1.5*ball_r, board_h+15, w_bmp )
	local wall_l_x = makeCube(  board_w/2+20,       0,          0,         15, 1.5*ball_r, board_h+15, w_bmp )
    
    gl_board:addChild(wall_f)
	gl_board:addChild(wall_r)
	gl_board:addChild(wall_l)
	gl_board:addChild(wall_b)
	gl_board:addChild(base)
    
    scene:addChild(wall_f_x)
	scene:addChild(wall_r_x)
	scene:addChild(wall_l_x)
	scene:addChild(wall_b_x)
    
    
    
    --Blocks
    for _,b in pairs(blox) do
        gl_board:addChild(
            makeCube(  -b.x, 0, b.y, b.w, 1.5*ball_r, b.h, b2 )
        )
    end
end

gl_board.position.y=30
local gl_ball = makeSphere(0,0,0,ball_r,0xffffff)

gl_ball.useQuaternion = true

gl_board:addChild(gl_ball)


local camera_r = 1000

camera = THREE.Camera{
    fov    = 45,
    aspect = screen.display_size[1] /
             screen.display_size[2],
    near   =     1,
    far    = 10000,
    target = gl_board
}

--set a camera position, otherwise you get this error
--LUA PANIC : ...x/tp/apps/tilt/THREE/src/renderers/WebGLRenderer.lua:2120: attempt to compare nil with number
camera.position.x = 0
camera.position.y = 400
camera.position.z = camera_r

scene:addObject(gl_board)

--local gl_ball_pitch = THREE.Object3D();


local renderer = THREE.WebGLRenderer();
renderer:setSize(screen.size[1],screen.size[2])
gl:release()





--------------------------------------------------------------------------------
-- Mapping from Physics to WebGL
--------------------------------------------------------------------------------

physics.gravity = {0,0}
physics:start()

local degrees_to_gees = 3
local max_tilt = 5

local curr_x = 0
local curr_z = 0

function tilt_to(x,z)
    
    if x >  max_tilt then x =  max_tilt end
    if z >  max_tilt then z =  max_tilt end
    if x < -max_tilt then x = -max_tilt end
    if z < -max_tilt then z = -max_tilt end
    
    gl_board.rotation.z = x*math.pi/180
    gl_board.rotation.x = z*math.pi/180
    
    physics.gravity = {
        
        degrees_to_gees *  x,
        degrees_to_gees *  z
        
    }
    
    curr_x = x
    curr_z = z
end

function tilt_by(dx,dz)
    
    tilt_to(
        curr_x + dx,
        curr_z + dz
    )
    
end

rot_to_x_y = function(radius,radians)
    return radius*math.sin(radians),radius*math.cos(radians)
end

local following = false
local offset_x = 0
local offset_z = 1000



local curr_rotation = 0
local rotation = Interval(0,math.pi/2)

local camera_rotate = Timeline{
    
    duration = 400,
    
    on_new_frame = function(_,ms,p)
        
        offset_x, offset_z =
            
            rot_to_x_y(
                
                camera_r,
                
                rotation:get_value(p)
                
            )
        
    end,
    on_completed = function()
        offset_x, offset_z =
            
            rot_to_x_y(
                
                camera_r,
                
                curr_rotation
                
            )
    end
}


local cam_i = 0

local camera_options = {
    function()
        camera.target = gl_board
        camera_r = 1000
        camera.position.y = 400
        offset_x, offset_z =
            
            rot_to_x_y(
                
                camera_r,
                
                curr_rotation
                
            )
        following = false
    end,
    function()
        camera.target = gl_ball
    end,
    function()
        camera.target = gl_ball
        following = true
        camera_r = 300
        camera.position.y = 200
        offset_x, offset_z =
            
            rot_to_x_y(
                
                camera_r,
                
                curr_rotation
                
            )
    end,
}

local base_i = 0
local tilt_inc = .1
local tilt_functions = {
    function() tilt_by(  tilt_inc,         0) end,
    function() tilt_by(         0, -tilt_inc) end,
    function() tilt_by( -tilt_inc,         0) end,
    function() tilt_by(         0,  tilt_inc) end,
}



local keys ={
    [keys.Left]  = function() tilt_functions[(base_i  )%(#tilt_functions) + 1 ]() end,
    [keys.Up]    = function() tilt_functions[(base_i+1)%(#tilt_functions) + 1 ]() end,
    [keys.Right] = function() tilt_functions[(base_i+2)%(#tilt_functions) + 1 ]() end,
    [keys.Down]  = function() tilt_functions[(base_i+3)%(#tilt_functions) + 1 ]() end,
    [keys.GREEN]   = function()
        
        rotation.from = curr_rotation
        
        curr_rotation = curr_rotation + math.pi/2
        
        rotation.to   = curr_rotation
        
        curr_rotation = curr_rotation % (math.pi*2)
        
        camera_rotate:start()
        
        base_i = (base_i - 1)%(#tilt_functions)
        
    end,
    [keys.RED] = function()
        
        rotation.from = curr_rotation
        
        curr_rotation = curr_rotation - math.pi/2
        
        rotation.to   = curr_rotation
        
        curr_rotation = curr_rotation % (math.pi*2)
        
        camera_rotate:start()
        
        base_i = (base_i + 1)%(#tilt_functions)
        
    end,
    [keys.YELLOW] = function()
        
        texture_i = (texture_i + 1) % (# textures)
        
        uniforms[ "tDiffuse" ].texture = textures[texture_i+1]
        
        print(texture_i+1)
    end,
    [keys.BLUE] = function()
        
        cam_i = (cam_i + 1) % (# camera_options)
        
        camera_options[cam_i+1]()
        
        print(cam_i+1)
    end,
    [keys.OK]    = function()
        if physics.running then
            physics:stop()
        else
            physics:start()
        end
    end,
    
}

function screen:on_key_down(k) if keys[k] then keys[k]() end end
local e = 0
---[[

local q = THREE.Quaternion{}
local u = THREE.Vector3()
function physics:on_step(s)
    
    e = e + s
    --physics:draw_debug()
    --print(ball.x,ball.y)
    gl:acquire()
    gl:clearColor(.2,.2,.2,1)
	gl:clear(gl.COLOR_BUFFER_BIT)
    
    --gl_ball.rotation.y = 
    
    
   
    
    
    
    x1 = -(gl_ball.position.x - (-ball.x))
    z1 = -(gl_ball.position.z - ball.y)
    
    
    
    --x1 = x1 ~= 0 and x1 or 0.00001
    --z1 = z1 ~= 0 and z1 or 0.00001
    
    --xx = gl_ball.position.z < 0 and -1 or 1
    
    --u:set(1,0,-x1/z1)
    u:set(z1,0,-x1)
    
    u:normalize()
    
    --print(u.x,"\t",u.y,"\t",u.z)
    
    local len = math.sqrt(x1 *x1   +   z1 * z1)
    
    local theta = math.pi*2* len / (math.pi * 2 * ball_r)
    
    q:setFromAxisAngle ( u, theta)
    
    q:normalize()
    
    gl_ball.quaternion:multiply(q,gl_ball.quaternion)
    
    gl_ball.quaternion:normalize()
    
    gl_ball.position.x = -ball.x
    gl_ball.position.z =  ball.y
    
    if following then
        --print(222222)
        camera.position.x = gl_ball.position.x + offset_x
        camera.position.z = gl_ball.position.z + offset_z
        
    else
        --print(offset_x,offset_z)
        camera.position.x = offset_x
        camera.position.z = offset_z
        --print("gah")
    end
    
    --x1 = -ball.x--(gl_ball.position.x - (-ball.x))
    --y1 =  ball.y-- gl_ball.position.z - ball.y
    
    
    --[=[
    x1 = gl_ball.position.x ~= 0 and gl_ball.position.x or 0.00001
    z1 = gl_ball.position.z ~= 0 and gl_ball.position.z or 0.00001
    
    xx = gl_ball.position.z < 0 and -1 or 1
    
    
    local u = THREE.Vector3(xx,0,-x1/z1)
    
    u:normalize()
    
    --[[
    local z_0 = (gl_ball.position.x + ball.x)
    local y_0 = 0
    local x_0 = gl_ball.position.z - ball.y
    
    local len = math.abs(x_0)+math.abs(z_0)
    
    x_0 = x_0/len
    z_0 = z_0/len
    --]]
    
    
    
    --if len ~= 0 then
    --gl_ball.rotation.z = -math.pi*2*gl_ball.position.x/(math.pi*2*ball_r)
    --gl_ball.rotation.x = math.pi*2*gl_ball.position.z/(math.pi*2*ball_r)
    
    len = math.sqrt(gl_ball.position.x *gl_ball.position.x   +   gl_ball.position.z * gl_ball.position.z)
    
    local theta = math.pi*2* len / (math.pi * 2 * 40)
    
    print()
    
    print(len,u.x,u.y,u.z)
    --[[
    print(u.x*math.sin(theta/2),
        u.y*math.sin(theta/2),
        u.z*math.sin(theta/2),
            math.cos(theta/2))
    --]]
    
    gl_ball.quaternion:setFromAxisAngle ( u, theta)
    --[[
    :set(
        u.x*math.sin(theta/2),
        u.y*math.sin(theta/2),
        u.z*math.sin(theta/2),
            math.cos(theta/2)
    )
    --]]
    gl_ball.quaternion:normalize()
    --end
    
    --]=]
    --gl_ball.matrixRotationWorld = THREE.Matrix4:setRotationY(90)
    
    --print(1)
    renderer:render( scene, camera )
    gl:release()
   -- print(2)
end
--]]
function controllers.on_controller_connected( controllers , controller )
    
    if controller.has_accelerometer then
        
        controller.on_accelerometer = function( controller , x , y , z )
			
            tilt_to(-2*max_tilt*y,2*max_tilt*x)
            
        end
        
        controller:start_accelerometer( "L" , .05 )
        
    end
    
end

for _,controller in pairs(controllers.connected) do
	
    controllers:on_controller_connected( controller )
    
end
