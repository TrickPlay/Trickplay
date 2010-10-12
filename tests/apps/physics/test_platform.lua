
--------------------------------------------------------------------------------

local SEED 

SEED = SEED or os.time() % 1234

math.randomseed( SEED )

print( "SEED" , SEED )

--------------------------------------------------------------------------------

local screen_w  = screen.w
local screen_h  = screen.h

--------------------------------------------------------------------------------
-- The goat image is 125 pixels tall, and the average height of a goat is about
-- one meter - so we base the world on that.
-- Changing this will change forces and how score is calculated...so be careful

local PPM                   = 120

physics.pixels_per_meter    = PPM

local GOAT_FEET_HALF_WIDTH  = 36

-- Gravity

physics.gravity             = { 0 , 70 }

-- How much force we apply to the goat when you press left or right

local SIDE_FORCE            = 6

local MAX_SIDE_VELOCITY     = 12

-- The score is calculated in meters. This lets us change it to feet.

local SCORE_MULTIPLIER      = 3.28 

local GOAT_TARGET_VY        = 25

--------------------------------------------------------------------------------

local goat_actor = Image{ src = "images/goat-medium.png" }

local goat_hh = goat_actor.h / 2

goat_actor:set
{
    anchor_point = goat_actor.center,
    position = { screen_w / 2 , goat_hh }
}

screen:add( goat_actor )

local goat = physics:Body
{
    source          = goat_actor,
    
    density         = 1,
    bounce          = 0,
    friction        = 0,
    bullet          = true,
    fixed_rotation  = true,
    
    shape           = physics:Edge( { - GOAT_FEET_HALF_WIDTH , goat_hh } , { GOAT_FEET_HALF_WIDTH , goat_hh } )
}

local goat_handle = goat.handle

--------------------------------------------------------------------------------
-- Half height of a platform

local platform_hh


local function make_platforms()

    local platform = Image{ src = "images/platform-rock-medium.png" }

    screen:add( platform )
    
    platform:hide()
    
    platform_hh = platform.h / 2

    ---------------------------------------------------------------------------    

    local result = {}
    
    local platforms_by_handle = {}
    
    local function default_newx()
        return math.random( 100 , screen_w - 100 )
    end
    
    local function default_add_goodie( platform_actor , platform_body , goat , score )
    end
        
    local function push_platform( x , y , newx , add_goodie , clear_goodie , goodie_contact )
    
        local actor = Group
        {
            size            = platform.size,
            anchor_point    = platform.center,
            position        = { x , y },
            children        =
            {
                Clone{ source = platform , opacity = 255 }
            }
        }
        
        -- The body
        
        local body = physics:Body
        {
            source      = actor,
            type        = "static",
            density     = 1,
            friction    = 0,
            bounce      = 0,
            sensor      = true
        }
        
        -- Function to change the x of the platform when it gets recycled
        
        actor.extra.newx = newx or default_newx
        
        -- Function to add a goodie to the platform
        
        actor.extra.add_goodie = add_goodie or default_add_goodie
        

        -- Get the handle to the default fixture so
        -- that we can remove other fixtures and keep this one
        
        local default_fixture = body.fixtures[ 1 ].handle
        
        body.extra.default_fixture = default_fixture
        
        function actor.extra.clear_goodie( platform_actor , platform_body )
        
            -- Call the user provided function if any
            
            if clear_goodie then
                clear_goodie()
            end
            
            -- Remove all but the first child
            
            local children = platform_actor.children
            for i = 2 , # children do
                platform_actor:remove( children[ i ] )
            end
            
            -- Remove all but the default fixture
            
            local fixtures = platform_body.fixtures
            
            if # fixtures > 1 then
                local handle
                for i = 1 , # fixtures do
                    handle = fixtures[ i ].handle
                    if handle ~= default_fixture then
                        platform_body:remove_fixture( handle )
                    end
                end
            end
        end
        
        function actor.extra.goodie_contact( platform_actor , platform_body , goat , contact )
        
            if contact.other_fixture[ default_fixture ] or not goodie_contact then
                return false
            end
            
            return goodie_contact( platform_actor , platform_body , goat , contact )
            
        end
        
        screen:add( actor )
        
        local pair = { body , actor }
        
        table.insert( result , pair )
        
        platforms_by_handle[ body.handle ] = pair
        
    end

    ---------------------------------------------------------------------------    

    local function method1()

        local PLATFORM_COUNT = 20
        
        for i = 1 , PLATFORM_COUNT do
        
            local x
            local y 
        
            if i == 1 then
                x , y = screen_w / 2 , screen_h - 100
            else
                x = math.random( 100 , screen_w - 100 )
                y = math.random( screen_h / 4  , screen_h - 100 )
            end
            
            push_platform( x , y )
            
        end
        
    end
    
    ---------------------------------------------------------------------------
    
    local function method2()
    
        local function add_goodie( platform_actor , platform_body , goat , score )
                    
            if score < 10 then
                return
            end
            
            if math.random( 100 ) > 10 then
                return
            end
            
            local r = Rectangle
            {
                color = "0000FF" ,
                size = { 60 , 30 },
                anchor_point = { 30 , 15 },
                position = { platform.w / 2 , -15 }
            }
            
            platform_actor:add( r )
            
            local spring =
            {
                shape = physics:Box( r.size , { 0 , - ( platform_hh + 15 ) } ),
                density = 1,
                sensor = true
            }
            
            platform_body:add_fixture( spring )
                        
        end
        
        local function goodie_contact( platform_actor , platform_body , goat , contact )
        
            print( "SPROING!" )
        
            local mass = goat.mass
            local vx , vy = unpack( goat.linear_velocity )
            
            if vy >= 0 then
            
                local fy = -( ( mass * vy ) * 3  + ( GOAT_TARGET_VY - vy ) )
            
                goat:apply_linear_impulse( { 0 , fy } , goat.position )
                
            end
            
        end
            
        
    
        push_platform( screen_w / 2 , screen_h - 50 , nil , add_goodie )
        
        local BANDS     = 8
        local BAND_H    = screen_h / BANDS
        
        local x
        local y
        local k
        local w 
        
        for i = 1 , BANDS do
        
            k = math.random( 1 , 3 )
            
            w = screen_w / k
            
            for j = 1 , k do
            
                x = math.random( ( w * ( j - 1 ) ) + 100 , ( w * j ) - 100 )
                y = BAND_H * i + math.random( - BAND_H * 0.25 , BAND_H * 0.25 )
                
                push_platform( x , y ,
                
                    function()
                        return math.random( ( w * ( j - 1 ) ) + 100 , ( w * j ) - 100 )
                    end,
                    
                    add_goodie,
                    nil,
                    goodie_contact
                    )
                
            end
        
        end
    
    end

    ---------------------------------------------------------------------------    

    method2()
    
    return result , platforms_by_handle
        
end


--------------------------------------------------------------------------------

local platforms , platforms_by_handle = make_platforms()

--------------------------------------------------------------------------------

local score_text = Text
{
    font = "DejaVu Sans Mono 60px",
    color = "FF0000",
    text = "0",
    position = { 50 , 50 }
}

local score = 0

screen:add( score_text )

--------------------------------------------------------------------------------
-- When the goat collides with a platform, we give it an impulse up

function goat.on_begin_contact( goat , contact )

    local pair = platforms_by_handle[ contact.other_body[ goat_handle ] ]
    
    if pair then
    
        local platform_body , platform_actor = unpack( pair )
        
        if platform_actor.extra.goodie_contact( platform_body , platform_actor , goat , contact ) then
        
            return
            
        end
    
    end
    

    local mass = goat.mass
    local vx , vy = unpack( goat.linear_velocity )
    
    if vy >= 0 then
    
        local fy = -( ( mass * vy ) * 2  + ( GOAT_TARGET_VY - vy ) )
    
        --print( "  MASS" , mass , "VX" , vx , "VY" , vy , "FY" , fy )
    
        goat:apply_linear_impulse( { 0 , fy } , goat.position )
        
    end
    
end

--------------------------------------------------------------------------------

goat_actor:raise_to_top()

screen:show()



local paused    = false

function screen:on_key_down( key )
    
    if key == keys.space then
    
        paused = not paused
        
    elseif key == keys.Left then
    
        local vx = goat.linear_velocity[ 1 ]
    
        if vx > - MAX_SIDE_VELOCITY then
        
            goat:apply_linear_impulse( { -SIDE_FORCE , 0 } , goat.position )
            
        end
    
    elseif key == keys.Right then

        local vx = goat.linear_velocity[ 1 ]
        
        if vx < MAX_SIDE_VELOCITY then
        
            goat:apply_linear_impulse( { SIDE_FORCE , 0 } , goat.position )
            
        end
    
    end

end

-------------------------------------------------------------------------------

local scrolling = false

local x
local y
local vx
local vy
local dy
local platform
local platform_actor
local extra

function idle.on_idle( idle , seconds )

    if paused then
        return
    end
    
    physics:step( seconds )
    
    physics:draw_debug()

    -- This wraps the goat around the screen horizontally
    
    x = goat_actor.x
    y = goat_actor.y
    
    if x > screen_w then
    
        goat.x = x - screen_w
        
    elseif x < 0 then
    
        goat.x = screen_w + x
        
    end
        
    -- Goat went past the bottom of the screen
        
    if y > screen_h then
        
        -- DEAD!
        
        goat.position = { screen_w / 2 , 0 - goat_hh }
        goat.linear_velocity = { 0 , 0 }
        
        score = 0
        score_text.text = "0"
        
    -- Or, it got high enough to scroll down
    
    elseif y < screen_h / 4 then
    
        -- Goat is over the top of the screen, we should scroll platforms, but
        -- only when the goat is traveling up ( negative vy )
        
        vx , vy = unpack( goat.linear_velocity )
        
        if vy < 0 then

            -- This is how far down everything has to scroll
            
            dy = screen_h / 4 - goat_actor.y
            
            -- It is also what we add to the score, converting to meters or feet
            
            score = score + ( ( dy / PPM ) * SCORE_MULTIPLIER ) 
            
            score_text.text = string.format( "%1.0f" , score )
            
            -- Clamp the goat
            
            goat.y = screen_h / 4
            
            -- Move all the platforms
            
            for i = 1 , # platforms do
            
                platform , platform_actor = unpack( platforms[ i ] )
                
                vy = platform_actor.y + dy
                
                -- This platform is off the screen, bring it to the top
            
                if vy - platform_hh > screen_h then
                
                    vy = vy - screen_h
                    
                    extra = platform_actor.extra
                    
                    extra.clear_goodie( platform_actor , platform )
                    
                    platform.x = extra.newx()
                    
                    extra.add_goodie( platform_actor , platform , goat , score )
                
                end
            
                platform.y = vy
                
            end
                        
        end
        
    end
    
end

-------------------------------------------------------------------------------

--[[
function clear()
    screen:clear()
    platforms = nil
    platforms_by_handle = nil
end
]]