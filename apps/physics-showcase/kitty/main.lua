
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

local SCREEN_W_3 = screen.w / 3
local SCREEN_H_3 = screen.h / 3 

local QUADRANTS =
{
    [1] = { 1 , 2 , 3 },
    [2] = { 4 , 5 , 6 },
    [3] = { 7 , 8 , 9 }
}

local DESTINATIONS =
{
    [1] = { { 3 , RUN_E } , { 9 , RUN_SE } , { 7 , RUN_S } },
    [2] = { { 7 , RUN_SW} , { 9 , RUN_SE } },
    [3] = { { 1 , RUN_W } , { 7 , RUN_SW } , { 9 , RUN_S } },
    [4] = { { 3 , RUN_NE} , { 9 , RUN_SE } },
    [5] = { { 1 , RUN_NW} , { 3 , RUN_NE } },
    [6] = { { 1 , RUN_NW} , { 7 , RUN_SW } },
    [7] = { { 1 , RUN_N } , { 3 , RUN_NE } , { 9 , RUN_E } },
    [8] = { { 1 , RUN_NW} , { 3 , RUN_NE } },
    [9] = { { 3 , RUN_N } , { 1 , RUN_NW } , { 7 , RUN_W } }
}

-------------------------------------------------------------------------------

local function move( seconds )
end

-------------------------------------------------------------------------------

local KITTY_SPEED = 2   -- Seconds for the kitty to get to its new location
local MOVE_TIME = 4     -- How often the kitty chooses a new location

-------------------------------------------------------------------------------

local function start_moving( )

    local function get_quadrant()
        local c = math.floor( kitty.x / SCREEN_W_3 ) + 1 
        local r = math.floor( kitty.y / SCREEN_H_3 ) + 1
        return QUADRANTS[ r ][ c ]
    end
    
    local function get_destination()
        local q = get_quadrant() 
        local t = DESTINATIONS[ q ]
        t = t[ math.random( 1 , #t ) ]
        return unpack( t )
    end

    local q , sequence = get_destination()
    
    local row = math.ceil( q / 3 )
    local col = q - ( 3 * ( row - 1 ) )
    
    local sx = kitty.x
    local sy = kitty.y
    
    local tx = math.random( SCREEN_W_3 * ( col - 1 ) , SCREEN_W_3 * col )
    local ty = math.random( SCREEN_H_3 * ( row - 1 ) , SCREEN_H_3 * row )
    
    tx = math.min( tx , screen.w - kitty.w )
    ty = math.min( ty , screen.h - kitty.h )
    
    tx = math.max( tx , kitty.w )
    ty = math.max( ty , kitty.h )
    
    local t = 0
    local duration = KITTY_SPEED
    
    kitty.extra.set_sequence( sequence )
    
    function move( seconds )
    
        t = math.min( t + seconds , duration )
               
        kitty.x = sx + ( tx - sx ) * ( t / duration )
        kitty.y = sy + ( ty - sy ) * ( t / duration )
        
        if t >= duration then
            move = function() end
            kitty.extra.set_sequence( SIT )
        end
    
    end
    
end

-------------------------------------------------------------------------------

kitty = physics:Body( kitty , { density = 1 , bounce = 0 , friction = 1 , fixed_rotation = true , filter = { group = -1 } } )

physics.gravity = { 0 , 0.0 }

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
            { density = 10 , friction = 1 , bounce = 0 , filter = { group = -1 } }
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

kitty.set_sequence( RUN_NE ) -- Good kitty.

kitty.flip()

screen:add( kitty )

screen:show()

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

idle.limit = 1/60

local watch = Stopwatch()

function idle:on_idle( seconds )

    physics:step( seconds )

    if watch.elapsed_seconds >= MOVE_TIME then
    
        watch:start()
        
--        start_moving()
    
    end
    
    move( seconds )

    kitty.flip( seconds )
    

end

-------------------------------------------------------------------------------

kitty:apply_linear_impulse( { 100 , -20 } , kitty.position )
