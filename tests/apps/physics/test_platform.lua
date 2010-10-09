
--------------------------------------------------------------------------------

goat = Image{ src = "images/goat-medium.png" }

goat:set
{
    anchor_point = goat.center,
    position = { screen.w / 2 , goat.h / 2 }
}

screen:add( goat )

goat = physics:Body
{
    source      = goat,
    
    density         = 1,
    bounce          = 0,
    friction        = 0,
    bullet          = true,
    fixed_rotation  = true,
    
    shape           = physics:Edge( { - 36 , goat.h / 2 } , { 36 , goat.h / 2 } )
}

--------------------------------------------------------------------------------

local platform = Image{ src = "images/platform-rock-medium.png" , opacity = 0 }

screen:add( platform )


local PLATFORM_COUNT = 20

math.randomseed( os.time() )

local function make_platforms()

    for i = 1 , PLATFORM_COUNT do
    
        local x
        local y 
    
        if i == 1 then
            x , y = screen.w / 2 , screen.h - 100
        else
            x = math.random( 100 , screen.w - 100 )
            y = math.random( 100 , screen.h - 100 )
        end
        
        local c = Clone
        {
            source = platform ,
            opacity = 255 ,
            anchor_point = platform.center,
            position = { x , y }
        }
        
        local p = physics:Body
        {
            source = c,
            type = "static",
            density = 1,
            friction = 1,
            bounce = 1,
            sensor = true
        }
        
        screen:add( c )
        
    end
        
end

make_platforms()
    

    

function goat.on_begin_contact( goat , contact )

    local mass = goat.mass
    local vx , vy = unpack( goat.linear_velocity )
    
    if vy < 0 then
        print( "COLLISION GOING UP" )
    else
    
        local fy = -( ( mass * vy ) * 2  + ( 40 - vy ) )
    
        print( "  MASS" , mass , "VX" , vx , "VY" , vy , "FY" , fy )
    
        goat:apply_linear_impulse( { 0 , fy } , goat.position )
        
    end
    
end

function goat.on_pre_solve_contact( goat , contact )
    --print( "GOAT PRE SOLVE" )
end

--------------------------------------------------------------------------------

physics.gravity = { 0 , 90 }


screen:show()

physics:start()

local SIDE_FORCE = 6

function screen:on_key_down( key )
    
    if key == keys.space then
    
        if physics.running then
            physics:stop()
        else
            physics:start()
        end
    
    elseif key == keys.Left then
    
        goat:apply_linear_impulse( { -SIDE_FORCE , 0 } , goat.position )
    
    elseif key == keys.Right then

        goat:apply_linear_impulse( { SIDE_FORCE , 0 } , goat.position )
    
    end

end