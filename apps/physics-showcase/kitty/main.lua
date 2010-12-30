
screen:add( Rectangle{ size = screen.size , color = "922914AA" } )

function Sprite( image , columns , total , frame_time )

    image = Image{ src = image }
    
    local sw = image.w / columns
    local sh = image.h / ( total / columns )
    
    local result =
        
        Group
        {
            size = { sw , sh },
            clip = { 0 , 0 , sw , sh },
            children = { image }
        }

    local sequence = {}
    
    local time = 0
    
    local index = 1
    
    function result.extra.set_sequence( s , t )
        assert( type( s ) == "table" )
        if sequence == s then
            return
        end
        sequence = s
        index = 1
        if t then
            frame_time = t
        end
    end
    
    function result.extra.flip( seconds )
        local flip_now = false
        if not seconds then
            flip_now = true
        else
            time = time + seconds
            if time >= frame_time then
                flip_now = true
                time = 0
            end
        end
    
        if not flip_now then
            return
        end
        
        local frame = sequence[ index ]
        
        if type( frame ) ~= "number" then
            return
        end
        
        local row = math.ceil( frame / columns )
        local col = frame - ( columns * ( row - 1 ) )

        image.position = { - sw * ( col - 1 ) , - sh * ( row - 1 ) }

        -- Now, find the next index
        
        local last_index = index
        local last_sequence = sequence
        
        index = index + 1
        
        while index ~= last_index do
        
            frame = sequence[ index ]
            
            if frame == nil then
                index = 1
            elseif type( frame ) == "function" then
                index = index + 1
                frame()
                if sequence ~= last_sequence then
                    break
                end
            else
                break
            end
        end
        
    end
    
    return result
end


local kitty = Sprite( "kitty/assets/sprites.png" , 8 , 24 , 0.125 )

kitty = physics:Body(
    kitty ,
    {
        density = 100 ,
        bounce = 0 ,
        friction = 1 ,
        fixed_rotation = true ,
        linear_damping = 2,
        filter = { group = -1 }
    } )

-------------------------------------------------------------------------------

physics.gravity = { 0 , 0 }

-------------------------------------------------------------------------------

local SIT       = { 1 }
local FREAK     = { 1 , 8 }
local SCRATCH   = { 3 , 4 }
local RUN_N     = { 9 , 10 }
local RUN_S     = { 11 , 12 }
local RUN_W     = { 13 , 14 }
local RUN_E     = { 15 , 16 }
local RUN_NW    = { 17 , 18 }
local RUN_NE    = { 19 , 20 }
local RUN_SW    = { 21 , 22 }
local RUN_SE    = { 23 , 24 }

-------------------------------------------------------------------------------

local push = Stopwatch()

local PUSH_TIME    = 2000
local PUSH_IMPULSE = 20

local abs = math.abs

local function move( seconds )

    local vx , vy = unpack( kitty.linear_velocity )
    
   
    if abs( vx ) <= 0.9 and abs( vy ) <= 0.9 then
    
        kitty.set_sequence( SIT )
        
        if push.elapsed >= PUSH_TIME then
        
            -- push the kitty
            
            local px = kitty.mass * math.random( -PUSH_IMPULSE , PUSH_IMPULSE )
            local py = kitty.mass * math.random( -PUSH_IMPULSE , PUSH_IMPULSE )
            
            print( "PUSHING" , px , py )
            
            kitty:apply_linear_impulse( { px , py } , kitty.position )
        
            push:start()
        
        end
        
    else
    
        local seq = SIT
        
        if vx > 0 then
        
            if abs( vy ) <= 1 then
            
                seq = RUN_E
                
            elseif vy < 1 then
                
                seq = RUN_NE
                
            else
            
                seq = RUN_SE
                
            end
                
        
        else
        
            if abs( vy ) <= 1 then
            
                seq = RUN_W
                
            elseif vy < 1 then
            
                seq = RUN_NW
                
            else
            
                seq = RUN_SW
                
            end
        
        end
        
        kitty.set_sequence( seq )
    
    end
    
    kitty.flip( seconds )
    
end

-------------------------------------------------------------------------------

local spike = physics:Body( Image { src = "kitty/assets/spike.png" } , { type = "static" , filter = { group = -1 } } )

screen:add( spike:set{ position = screen.center } )

-------------------------------------------------------------------------------

local link_image = Image{ src = "kitty/assets/link.png" }

screen:add( link_image )
link_image:hide()

kitty.position = { kitty.w , screen.h / 2 }

local function build_chain()

    local x = kitty.x
    local y = kitty.y 
    
    local last_body = kitty
    
    while x < spike.x do
    
        local link = physics:Body(
            Clone{ source = link_image },
            {
                density = 10 ,
                friction = 1 ,
                bounce = 0 ,
                filter = { group = -1 },
                linear_damping = 1
            }
        )
        
        screen:add( link )
        
        link.x = x + link.h / 2
        link.y = y
        link.angle = 90
        
        link:RevoluteJoint( last_body , { x , y } )

        x = x + link.h - 8  
        
        last_body = link
        
    end
    
    spike:RevoluteJoint( last_body , { x , y } )

end

build_chain()

-------------------------------------------------------------------------------

kitty.set_sequence( SIT ) -- Good kitty.

kitty.flip()

screen:add( kitty )

screen:show()

-------------------------------------------------------------------------------

local step = 1/60

local min = math.min

idle.limit = step

local watch = Stopwatch()

function idle:on_idle( seconds )

    physics:step( min( seconds , step ) )
   
    move( seconds )

end

-------------------------------------------------------------------------------

