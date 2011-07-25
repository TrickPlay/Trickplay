screen:add(Image{src="sky.png",size=screen.size})

--[==[
screen:show()

function main()


degrees_to_gees = 3
max_tilt = 5

x_rot = 70
tilt  = 2

ball_img = Image{src = "marble-2x.png",x=300,y=300,x_rotation = {-x_rot,0,0}}
ball = physics:Body(
    ball_img,
    {
        density=1,
        bounce = .1,
        filter={group=1},
        shape = physics:Circle(ball_img.w/2),
        fixed_rotation   = true,
        sleeping_allowed = false,
        linear_damping = .7
    }
)

shadow = Image{src = "marble-shadow-2x.png", z = -ball.h/2, scale = {1.5,1.5},opacity = 255*.9 }
shadow.anchor_point = {shadow.w/2,shadow.h/2}


function make_level(w,h)
    
    local board = Group{}
    
    floor = Image{
        src     = "wood.jpg",
        tile    = {true,true},
        w       = w,
        h       = h,
        z       = -ball.h/2
    }
    
    local t_wall = physics:Body(
        Image{
            src  = "wall.jpg",
            tile = {false,true},
            h    = floor.w,
            y_rotation = {90,0,0}
        },
        {type="static",shape = physics:Box({5,w})}
    )
    local b_wall = physics:Body(
        Image{
            src  = "wall.jpg",
            tile = {false,true},
            h    = floor.w,
            y_rotation = {90,0,0}
        },
        {type="static",shape = physics:Box({5,w})}
    )
    local l_wall = physics:Body(
        Image{
            src = "wall.jpg",
            tile={false,true},
            h=floor.h,
            y_rotation = {90,0,0}
        },
        {type="static",shape = physics:Box({5,h})}
    )
    local r_wall = physics:Body(
        Image{
            src = "wall.jpg",
            tile={false,true},
            h=floor.h,
            y_rotation = {90,0,0}
        },
        {type="static",shape = physics:Box({5,h})}
    )
    
    board:add(floor,shadow,t_wall,l_wall,r_wall,ball,b_wall)
    
    t_wall.x = w/2
    t_wall.y = 0
    t_wall.angle    = 90
    b_wall.x = w/2
    b_wall.y = h
    b_wall.angle    = 90
    l_wall.x = 0
    l_wall.y = h/2
    r_wall.x = w
    r_wall.y = h/2
    
    board.anchor_point = {w/2,h/2}
    
    board.x_rotation   = {x_rot,0,0}
    
    
    
    return board
end



board = make_level(5/4*screen.w,5/4*screen.h)
screen:add(board)

board.position     = {screen.w/2,screen.h*3/4}
board.z = -1000




block = physics:Body(
    Image{src="wood-2.jpg",size = {300,300},z=ball.h/3},
    {type="static"}
)
block.x = screen.w/2
block.y = screen.h/2
physics.gravity = {0,0}
physics:start()


local curr_x, curr_y = 0,0

function tilt_to(x,y)
    
    if x >  max_tilt then x =  max_tilt end
    if y >  max_tilt then y =  max_tilt end
    if x < -max_tilt then x = -max_tilt end
    if y < -max_tilt then y = -max_tilt end
    
    board.z_rotation = {       x, 0, 0}
    board.x_rotation = { x_rot+y, 0, 0}
    
    physics.gravity = {
        
        degrees_to_gees *  x,
        degrees_to_gees * -y
        
    }
    
    curr_x = x
    curr_y = y
end

function tilt_by(dx,dy)
    
    tilt_to(
        curr_x + dx,
        curr_y + dy
    )
    
end

local tilt_inc = .1
local keys ={
    [keys.Left]  = function() tilt_by( -tilt_inc,         0) end,
    [keys.Right] = function() tilt_by(  tilt_inc,         0) end,
    [keys.Up]    = function() tilt_by(         0,  tilt_inc) end,
    [keys.Down]  = function() tilt_by(         0, -tilt_inc) end,
    [keys.OK]    = function()
        if physics.running then
            physics:stop()
        else
            physics:start()
        end
    end,
    
}

function screen:on_key_down(k) if keys[k] then keys[k]() end end

---[[
function physics:on_step(s)
    --physics:draw_debug()
    shadow.x = ball.x
    shadow.y = ball.y
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

end

dolater(main)

--]==]














---[==[
screen:show()

function main()

physics.z_for_y = true
degrees_to_gees = 3
max_tilt = 5

x_rot = 60
tilt  = 2

ball_img = Image{
    src = "marble-2x.png",
    x   =  300,
    z   = -300,
}
ball_img.x_rotation = {90-x_rot,0,-ball_img.h/2}
ball = physics:Body(
    ball_img,
    {
        density=1,
        bounce = .1,
        filter={group=1},
        shape = physics:Circle(ball_img.w/2),
        fixed_rotation   = true,
        sleeping_allowed = false,
        linear_damping = .7
    }
)

function ball:on_begin_contact(c)
    --print(ball.linear_velocity[1],ball.linear_velocity[2])
    
    if  math.abs(ball.linear_velocity[1]) > 6 or
        math.abs(ball.linear_velocity[2]) > 6 then
        
        mediaplayer:play_sound("tap-lg.mp3")
        
    elseif  math.abs(ball.linear_velocity[1]) > 2 or
        math.abs(ball.linear_velocity[2]) > 2 then
        
        mediaplayer:play_sound("tap-sm.mp3")
        
    end
    
end


shadow        = Image{
   src        = "marble-shadow-2x.png",
   y          = ball.h/2,
   scale      = {1.5,1.5},
   opacity    = 255*.9,
   x_rotation = {90,0,0}
}
shadow.anchor_point = {shadow.w/2,shadow.h/2}


function make_level(w,h)
    
    local board = Group{}
    
    floor = Image{
        src        = "wood.jpg",
        tile       = {true,true},
        w          = w,
        h          = h,
        y          = ball.h/2,
        z          = -h,
        x_rotation = {90,0,0}
    }
    
     t_wall = physics:Body(
        Image{
            src  = "wall.jpg",
            tile = {false,true},
            h    = w,
            --y_rotation = {90,0,0},
            x_rotation = {0,0,0},
            z_rotation = {90,0,0},
        },
        {type="static",shape = physics:Box({w,5})}
    )
    --t_wall.y_rotation = {0,0,0}
     b_wall = physics:Body(
        Image{
            src  = "wall.jpg",
            tile = {false,true},
            h    = w,
            --y_rotation = {90,0,0},
            x_rotation = {0,0,0},
            z_rotation = {90,0,0},
            
        },
        {type="static",shape = physics:Box({w,5})}
    )
     l_wall = physics:Body(
        Image{
            src = "wall.jpg",
            tile={false,true},
            h=h,
            z_rotation = {90,0,0},
            x_rotation = {90,0,0}
        },
        {type="static",shape = physics:Box({5,h})}
    )
     r_wall = physics:Body(
        Image{
            src = "wall.jpg",
            tile={false,true},
            h=h,
            z_rotation = {90,0,0},
            x_rotation = {90,0,0}
        },
        {type="static",shape = physics:Box({5,h})}
    )
    
    board:add(floor,shadow,t_wall,l_wall,r_wall,ball,b_wall)
    
    t_wall.x = w/2
    t_wall.z = -h
    t_wall.angle = 0
    b_wall.x = w/2
    b_wall.z = 0
    b_wall.angle = 0
    l_wall.x = 0
    l_wall.z = -h/2
    l_wall.angle = 0
    r_wall.x =  w
    r_wall.z = -h/2
    r_wall.angle = 0
    
    board.anchor_point = {w/2,0}
    
    board.x_rotation   = {x_rot-90,0,0}
    
    
    
    return board
end



board = make_level(screen.w,screen.h)
screen:add(board)

board.position = {screen.w/2,screen.h*3/4}
--board.y = 1000



---[[
function place_block(x,z)
    local block = physics:Body(
        Group{
            size = {100,100},
            children = {
                --top
                Image{src="wood-2.jpg",size = {100,100},z=ball.h/3,anchor_point={50,50},x_rotation = {90,0,0},x=50,z=50},
                --left
                Image{src="wood-2.jpg",size = {100,100},z=ball.h/3,anchor_point={50,50},y_rotation = {90,0,0},x=0,z=50,y=50},
                --rigght
                Image{src="wood-2.jpg",size = {100,100},z=ball.h/3,anchor_point={50,50},y_rotation = {90,0,0},x=100,z=50,y=50},
                --front
                Image{src="wood-2.jpg",size = {100,100},z=ball.h/3,anchor_point={50,50},x=50,z=100,y=50},
            }
        },
        
        
        {type="static"}
    )
    block.x = x
    block.z = z
    board:add(block)
end

place_block(floor.w/2,-floor.h/2)
place_block(floor.w/4,-floor.h/2)
place_block(floor.w*3/4,-floor.h/2)

physics.gravity = {0,0}
physics:start()

--]]
physics.gravity = {0,0}
local curr_x, curr_z = 0,0

function tilt_to(x,z)
    
    if x >  max_tilt then x =  max_tilt end
    if z >  max_tilt then z =  max_tilt end
    if x < -max_tilt then x = -max_tilt end
    if z < -max_tilt then z = -max_tilt end
    
    board.z_rotation = {       x, 0, 0}
    board.x_rotation = { x_rot-90+z, 0, 0}
    
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

local tilt_inc = .1
local keys ={
    [keys.Left]  = function() tilt_by( -tilt_inc,         0) end,
    [keys.Right] = function() tilt_by(  tilt_inc,         0) end,
    [keys.Up]    = function() tilt_by(         0,  tilt_inc) end,
    [keys.Down]  = function() tilt_by(         0, -tilt_inc) end,
    [keys.OK]    = function()
        if physics.running then
            physics:stop()
        else
            physics:start()
        end
    end,
    
}

function screen:on_key_down(k) if keys[k] then keys[k]() end end
--]]
---[[
function physics:on_step(s)
    --physics:draw_debug()
    shadow.x = ball.x
    shadow.z = ball.z-1
end
--]]












---[[
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
--]]
end

dolater(main)

--]==]
