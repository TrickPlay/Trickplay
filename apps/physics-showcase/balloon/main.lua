
------------------------------------------------------------------------------

local G = 0.5 

------------------------------------------------------------------------------
-- Sky

local sky = Canvas{ size = screen.size }

sky:begin_painting()
sky:set_source_linear_pattern( screen.w / 2 , 0 , screen.w / 2 , screen.h )
sky:add_source_pattern_color_stop( 0 , "54a9ff" )
sky:add_source_pattern_color_stop( 1 , "c9ffff" )
sky:rectangle( 0 , 0 , screen.w , screen.h )
sky:fill()
sky:finish_painting()

screen:add( sky )

------------------------------------------------------------------------------
-- Clouds

local cloud1 = Image{ src = "balloon/assets/cloud1.png" }
local cloud2 = Image{ src = "balloon/assets/cloud2.png" }
screen:add( cloud1 , cloud2 )
cloud1:hide()
cloud2:hide()

local CLOUDY = 8

local clouds = {}

math.randomseed( os.time() )

for i = 1 , CLOUDY do

    local source = cloud1
    
    if math.random( 1 , 100 ) > 50 then
        source = cloud2
    end
    
    local cloud = physics:Body(
        Clone
        {
            source = source,
            opacity = math.random( 160 , 255 )
        } ,
        {
            density = 1000 ,
            bounce = 0 ,
            friction = 0 ,
            filter = { group = -1 },
            linear_damping = math.random( 1 , 4 ),
            sleeping_allowed = false
        } )
        
    cloud.x = math.random( screen.w )
    cloud.y = math.random( 500 ) + 100
    
    cloud.extra.start_y = cloud.y
    
    screen:add( cloud )
    
    table.insert( clouds , cloud )

end

local screen_w = screen.w

function thermal( seconds )
    
    local vx , vy

    for _ , cloud in ipairs( clouds ) do
    
        cloud.y = cloud.extra.start_y
        
        if cloud.x > screen_w + cloud.w / 2 then
            cloud.x = - cloud.w / 2 
            cloud.y = math.random( 500 ) + 100
        elseif cloud.x < -cloud.w / 2 then
            cloud.x = screen_w + cloud.w / 2
            cloud.y = math.random( 500 ) + 100
        end
    end

end

------------------------------------------------------------------------------
-- Hills

screen:add( Image{ src = "balloon/assets/hills.png" , position = { 0 , 700 } } )

------------------------------------------------------------------------------
-- Floor

local ground = physics:Body(
    Group{ size = { screen.w , 100 } , position = { 0 , 980 } } ,
    { type = "static" , friction = 1 } )

screen:add( ground )

------------------------------------------------------------------------------
-- Windsock

local ws1 = Image{ src = "balloon/assets/windsock_1.png" }
local ws2 = Image{ src = "balloon/assets/windsock_2.png" }
local ws3 = Image{ src = "balloon/assets/windsock_3.png" }
local ws4 = Image{ src = "balloon/assets/windsock_4.png" }
local ws5 = Image{ src = "balloon/assets/windsock_5.png" }

local x = 294
local y = 720

local pole = physics:Body(
    Group{ position = { x , y } , size = { 1 , 1 } } ,
    { type = "static" , filter = { group = -1 } } )
    
local SOCK_DENSITY = 30
local SOCK_BODY    =
{
    density = SOCK_DENSITY ,
    filter = { group = -1 } ,
    angular_damping = 0.8,
    linear_damping = 0.8,
    sleeping_allowed = false
}

local SOCK_JOINT   = { enable_limit = true , lower_angle = -40 , upper_angle = 40 }

ws1 = physics:Body( ws1:set{ position = { x - 5 , y - 20 } } , SOCK_BODY )
ws1:RevoluteJoint( pole , { x , y } )

x = x + 30

ws2 = physics:Body( ws2:set{ position = { x - 15 , y - 20 } } , SOCK_BODY )
ws2:RevoluteJoint( ws1 , { x , y } , SOCK_JOINT )

x = x + 25

ws3 = physics:Body( ws3:set{ position = { x - 15 , y - 20 } } , SOCK_BODY )
ws3:RevoluteJoint( ws2 , { x , y } , SOCK_JOINT )

x = x + 25

ws4 = physics:Body( ws4:set{ position = { x - 15 , y - 20 } } , SOCK_BODY )
ws4:RevoluteJoint( ws3 , { x , y } , SOCK_JOINT )

x = x + 25

ws5 = physics:Body( ws5:set{ position = { x - 15 , y - 20 } } , SOCK_BODY )
ws5:RevoluteJoint( ws4 , { x , y } , SOCK_JOINT )


screen:add( pole , ws5 , ws4 , ws3 , ws2 , ws1 )

------------------------------------------------------------------------------
-- Balloon

local flame1 = Image{ src = "balloon/assets/flame1.png" }
local flame2 = Image{ src = "balloon/assets/flame2.png" }
local glow = Image{ src = "balloon/assets/glow.png" }
   

local balloon = physics:Body(

    Group
    {
        position = { 1412 - 200 , 980 - 570 },
        children =
        {
            Image{ src = "balloon/assets/balloon.png" },
            flame1:set{ position = { 171 , 449 } },
            flame2:set{ position = { 171 , 449 } },
            glow:set{ position = { 90 , 335 } }
        }
    }
    ,
    {
        density = 10,
        friction = 1,
        bounce = 0.3,
        filter = { group = -1 },
        linear_damping = 0.4,
        fixed_rotation = true
    }
)

flame1:hide()
flame2:hide()
glow:hide()

screen:add( balloon )

local fire_on = false

local function fire( seconds )

    local vx , vy = unpack( balloon.linear_velocity )

    if not fire_on then
    
        flame1:hide()
        flame2:hide()
        glow:hide()
        
    else
    
        if not flame1.is_visible then
            flame1:show()
            flame2:hide()
        else
            flame1:hide()
            flame2:show()
        end
        
        glow:show()
        glow.opacity = math.random( 127 , 255 )
        
        if vy > -2 then
        
            balloon:apply_force( { 0 , - ( G + ( 1 * balloon.mass ) ) } ,
                { balloon.x , balloon.y - 270 } )
            
        end
    end

end

------------------------------------------------------------------------------

local anchor = physics:Body(
    Group{ size = { 1 , 1 } , position = {635 , 925 } },
    { type = "static" , filter = { group = -1 } } )
    
screen:add( anchor )

local link_image = Image{ src = "balloon/assets/chain.png" }

screen:add( link_image )
link_image:hide()

local last_body = anchor
local x = anchor.x
local y = anchor.y

for i = 1 , 23 do
    
    local link = physics:Body(
        Clone{ source = link_image , position = { x , y } },
        { density = 20 , filter = { group = -1 } } )
        
    link:RevoluteJoint( last_body , { x , y } )
    
    screen:add( link )
    
    last_body = link
    
    x = x + 24
    
end

balloon.position = { x + 12 , anchor.y - 270 }

last_body:RevoluteJoint( balloon , { x , balloon.y + 270 } )

------------------------------------------------------------------------------

balloon:raise_to_top()

------------------------------------------------------------------------------

physics.gravity = { 0 , G }

------------------------------------------------------------------------------

screen:show()

------------------------------------------------------------------------------

idle.limit = 1/60

function idle:on_idle( seconds )

    physics:step( seconds )
    
    --physics:draw_debug()
    
    fire( seconds )
    
    thermal( seconds )
    
end

local OK_KEY    = keys.Return
local LEFT_KEY  = keys.Left
local RIGHT_KEY = keys.Right
local BACK_KEY  = keys.BACK

local W = 0.8

local random_key_timer = Timer { interval = 5000 }
local inject_keys = { LEFT_KEY , RIGHT_KEY , OK_KEY }
function random_key_timer:on_timer()
    local choose_key = math.random(#inject_keys)
    screen:on_key_down(inject_keys[choose_key])
end

random_key_timer:start()

function screen:on_key_down( key )

    local wind = physics.gravity[ 1 ]

    if key == OK_KEY then
        fire_on = not fire_on
    elseif key == RIGHT_KEY then
        if wind < 0 then
            wind = 0
        elseif wind == 0 then
            wind = W
        end
        physics.gravity = { wind , G }
    elseif key == LEFT_KEY then
        if wind > 0 then
            wind = 0
        elseif wind == 0 then
            wind = -W
        end
        physics.gravity = { wind , G }
    elseif key == BACK_KEY then
        random_key_timer:stop()
        idle.on_idle = nil
        screen.on_key_down = nil
        screen:clear()
        collectgarbage("collect")
        dofile("main.lua")
    end
end


