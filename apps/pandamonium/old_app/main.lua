--------------------------------------------------------------------------------

local SEED 

SEED = SEED or os.time() % 1234

math.randomseed( SEED )

print( "SEED" , SEED )

--------------------------------------------------------------------------------

local CHEAT_INVINCIBLE      = false
local CHEAT_LEAVES_GALORE   = false


--------------------------------------------------------------------------------

local screen_w  = screen.w
local screen_h  = screen.h

-------------------------------------------------------------------------------

local TITLE_FONT    = "Sniglet"
local SCORE_FONT    = "Teen"
local SCORE_COLOR   = "000000"

-------------------------------------------------------------------------------

idle.limit = 1.0 / 60.0 

-------------------------------------------------------------------------------
-- The goat image is 125 pixels tall, and the average height of a goat is about
-- one meter - so we base the world on that.
-- Changing this will change forces and how score is calculated...so be careful

local PPM                   = 120

physics.pixels_per_meter    = PPM

-- Gravity

physics.gravity             = { 0 , 45 }

-- How much force we apply to the hopper when you press left or right

local SIDE_FORCE            = 6

local MAX_SIDE_VELOCITY     = 12

-- The score is calculated in meters. This lets us change it to feet.

local SCORE_MULTIPLIER      = 3.28 

local HOPPER_TARGET_VY      = 20

local LIFE_DRAIN_PER_SEC    = 5 / 100

local LIFE_PER_LEAF         = 20 / 100

local MAX_LEAVES_ALIVE      = CHEAT_LEAVES_GALORE and 30 or 4

-------------------------------------------------------------------------------

local asset_cache 

local assets =
{
    hopper      = "images/hopper.png",
    platform    = "images/platform-standard.png",
    leaf        = "images/leaf.png",
    life        = "images/life.png"
}

-------------------------------------------------------------------------------

local function make_hopper()

    local HOPPER_FEET_HALF_WIDTH = 36

    local actor = asset_cache( assets.hopper )

    local hh = actor.h / 2

    actor.anchor_point = actor.center


    local body = physics:Body( actor , 
    {
        density         = 1,
        bounce          = 0,
        friction        = 0,
        bullet          = true,
        fixed_rotation  = true,
        shape           = physics:Edge( { - HOPPER_FEET_HALF_WIDTH , hh } , { HOPPER_FEET_HALF_WIDTH , hh } )
    })
    
    return actor , body
    
end

-------------------------------------------------------------------------------

local function make_platform( asset_name )

    local image = asset_cache( asset_name or assets.platform )
    
    local actor = Group
    {
        size = image.size,
        anchor_point = image.center,
        children = { image }
    }
    
    local body = physics:Body( actor , 
    {
        type   = "static",
        density = 1,
        friction = 0,
        bounce = 0,
        sensor = true
    })

    return actor , body
    
end

-------------------------------------------------------------------------------

local function start_playing( fade_splash , hopper , platform , on_dead )
    
    local hopper_actor = hopper
    local hopper_hh    = hopper_actor.h / 2
    local platform_hh  = platform.h / 2 

        
    ---------------------------------------------------------------------------
    -- Add the splash platform to the table of platforms
        
    local pair = { platform , platform }     

    local platforms = { pair }
    
    local platforms_by_handle = { [ platform.handle ] = pair }
        
    ---------------------------------------------------------------------------
    -- This calculates the initial coordinates for the platforms. It returns
    -- a table of tables. Each of these tables has two items, 1) a table with
    -- x and y coordinates for the platform and 2) a function that calculates
    -- new coordinates when this platform is recycled.
    
    local function distribute_platforms()
    
        local BANDS     = 8
        local BAND_H    = screen_h / BANDS
        
        local x
        local y
        local k
        local w
        
        local result = {}
        
        for i = 1 , BANDS do
        
            k = math.random( 1 , 3 )
            
            w = screen_w / k
            
            for j = 1 , k do
            
                x = math.random( ( w * ( j - 1 ) ) + 100 , ( w * j ) - 100 )
                y = BAND_H * i + math.random( - BAND_H * 0.25 , BAND_H * 0.25 )
                
                local function new_position( position )
                    return { math.random( ( w * ( j - 1 ) ) + 100 , ( w * j ) - 100 ) , position[ 2 ] }
                end
                
                table.insert( result , { { x , y } , new_position } )
                
            end
        
        end
        
        return result
    
    end
    
    ---------------------------------------------------------------------------
    -- Place the initial platforms
    
    local coordinates = distribute_platforms()
    
    for i = 1 , # coordinates do
    
        local position , new_position = unpack( coordinates[ i ] )
        
        local platform_actor , platform = make_platform()
        
        platform.position = position
        
        platform.extra.new_position = new_position
    
        platform_actor.opacity = 0
        
        screen:add( platform_actor )
        
        local pair = { platform , platform_actor }
        
        table.insert( platforms , pair )
        
        platforms_by_handle[ platform.handle ] = pair
        
        platform.active = false
        
    end
    
    ---------------------------------------------------------------------------
    -- The score
    
    local score = 0
    local score_label = Text
    {
        font = SCORE_FONT.." 80px",
        color = SCORE_COLOR,
        text = "0",
        position = { 50 , 50 },
        opacity = 0
    }
    
    screen:add( score_label )
    
    local high_score_label = Text
    {
        font = SCORE_FONT.." 40px",
        color = SCORE_COLOR,
        text = "high score",
    }
    
    high_score_label.x = score_label.x
    high_score_label.y = score_label.y + score_label.h
    
    screen:add( high_score_label )
    
    high_score_label:hide()

    ---------------------------------------------------------------------------
    -- The life bar
    
    local life_bar = Image{ src = assets.life }
    local life_bar_w = life_bar.w
    local life_bar_h = life_bar.h
    
    life_bar:set
    {
        x = screen_w - ( life_bar_w + 50 ),
        y = 65,
        opacity = 0
    }
    
    screen:add( life_bar )
    
    life_bar:move_anchor_point( life_bar.w / 2 , life_bar.h / 2 )
    
    ---------------------------------------------------------------------------
    -- This function fades out the splash (via a provided function) and fades
    -- in the real game elements.
    
    local fade_in
    
    do
    
        local DURATION = 1000
    
        local start = nil
        local opacity
        local progress
    
        fade_in = function()
    
            if not start then
                
                start = Stopwatch()
                
                return
                
            end
            
            progress = math.min( start.elapsed / DURATION , 1 )
            
            -- Fade out the splash screen
            
            fade_splash( progress )
            
            -- Fade in the platforms
            
            opacity = 255 * progress
            
            for i = 1 , # platforms do
                
                platforms[ i ][ 2 ].opacity = opacity
                
            end
            
            -- Fade in the score label
            
            score_label.opacity = opacity
            
            life_bar.opacity = opacity
            
            return progress == 1
            
        end
        
    end

    ---------------------------------------------------------------------------
    -- Game is over
    
    local function game_over()
    
        if CHEAT_INVINCIBLE then
        
            hopper.linear_velocity = { 0 , - HOPPER_TARGET_VY }
        
            return
        end
    
        -- Turn off the key handler
        
        screen.on_key_down = nil
        
        
        
        local SPEED = screen_h * 2.5
        
        local start = Stopwatch()
        
        local done = false
        local dy
        local my = 0
        local y
        
        local function move_up( thing )
            y = thing.y - dy
            thing.y = y
            my = math.max( y , my )
        end
        
        function idle:on_idle( seconds )
        
            my = 0
        
            dy = SPEED * seconds
            
            for i = 1 , # platforms do
                
                move_up( platforms[ i ][ 1 ] )
                
            end
            
            move_up( score_label )
            
            move_up( high_score_label )
            
            move_up( life_bar )
            
            done = my == 0
            
            dy = dy / 2
            
            move_up( hopper )

            if done then
            
                hopper.linear_velocity = { 0 , 0 }
            
                function idle:on_idle( seconds )
                
                    physics:step( seconds )
                    
                    if hopper.y - hopper_hh > screen_h then
                    
                        idle.on_idle = nil
                        
                        dolater( on_dead , score )

                    end
                
                end
            
            end    
            
        end
    
    end

    ---------------------------------------------------------------------------
    -- Platform recycling
    
    local leaf_platforms = {}
    
    local recycle_platform  -- function
        
    local eat_leaf          -- function
    
    local move_leaves       -- function
    
    local drain_life
            
    do
        
        local leaves        = {}
        local leaves_alive  = 0
        local leaf          
    
        recycle_platform = function( platform_actor , platform_body )
        
            --print( "LEAVES ALIVE" , leaves_alive )
        
            -- See if it has a leaf
            
            leaf = platform_actor.extra.leaf
            
            if leaf then
                leaf:unparent()
                table.insert( leaves , leaf )
                platform_actor.extra.leaf = nil
                leaves_alive = leaves_alive - 1
                leaf = nil
                leaf_platforms[ platform_body.handle ] = nil
            end
            
            if leaves_alive < MAX_LEAVES_ALIVE then
            
                -- Get a leaf
                
                leaf = table.remove( leaves ) or asset_cache( assets.leaf )
                
                leaf:set
                {
                    z_rotation = { math.random( 0 , 3 ) * 90 , leaf.w / 2 , leaf.h / 2 },
                    x = math.random( 15 , platform_actor.w - leaf.w - 15 ),
                    y = - leaf.h + 4
                }
                                
                platform_actor:add( leaf )
                
                platform_actor.extra.leaf = leaf
                
                leaves_alive = leaves_alive + 1
            
                leaf_platforms[ platform_body.handle ] = leaf
            
            end
                
        
        end
    
        local life = 1
        

        local blink_time        = 0
        local BLINK_DURATION    = 0.25
        local BLINK_AT_LIFE     = 0.49
        local BD
    
        drain_life = function( seconds )
        
            life = math.max( life - LIFE_DRAIN_PER_SEC * seconds , 0 )
            
            if life <= 0 then
            
                return true
                
            end
            
            life_bar.clip = { 0 , 0 , life_bar_w * life , life_bar_h }
            
            if life <= BLINK_AT_LIFE then
            
                BD = BLINK_DURATION * ( life / BLINK_AT_LIFE )
        
                blink_time = blink_time + seconds
                
                if blink_time >= BD then
                    blink_time = 0
                    if life_bar.is_visible then
                        life_bar:hide()
                    else
                        life_bar:show()
                    end
                end
                
            else
            
                life_bar:show()
                
            end
                
        end

        local traveling_leaves = {}
        local platform
        local ap
        local watch = Stopwatch()
        local tx = screen_w - 50
        local ty = 50
        local LEAF_DURATION = 1000
        
        eat_leaf = function( leaf )
        
            platform = leaf.parent
            
            platform.extra.leaf = nil
            
            leaves_alive = leaves_alive - 1
            
            leaf:unparent()
            
            ap = platform.anchor_point
            
            leaf.x = leaf.x + platform.x - ap[ 1 ]
            leaf.y = leaf.y + platform.y - ap[ 2 ]
            
            screen:add( leaf )
            
            local start = watch.elapsed
            local xi = Interval( leaf.x , tx )
            local yi = Interval( leaf.y , ty )
            local progress
            
            table.insert( traveling_leaves ,
                function()
                    progress = math.min( ( watch.elapsed - start ) / LEAF_DURATION , 1 )
                    leaf.x = xi:get_value( progress )
                    leaf.y = yi:get_value( progress )
                    
                    if progress == 1 then
                        return leaf
                    end
                end
                )
        
        end
        
        local leaf
        
        move_leaves = function( seconds )
        
            for i = # traveling_leaves , 1 , -1 do
            
                leaf = traveling_leaves[ i ]()
                
                if leaf then
                
                    leaf:unparent()
                    
                    table.insert( leaves , leaf )
                    
                    table.remove( traveling_leaves , i )
                    
                    life = math.min( life + LIFE_PER_LEAF , 1 )
                    
                    drain_life( 0 )
                
                end
            
            end
        
        end
    
    end

    ---------------------------------------------------------------------------

    do
    
        local mass
        local vy
        local fy
        local hopper_handle = hopper.handle
        local leaf
        local other

        function hopper.on_begin_contact( hopper , contact )
    
            mass = hopper.mass
    
            vy = hopper.linear_velocity[ 2 ]
            
            if vy >= 0 then
            
                fy = -( ( mass * vy ) * 2  + ( HOPPER_TARGET_VY - vy ) )
            
                hopper:apply_linear_impulse( { 0 , fy } , hopper.position )
                
                other = contact.other_body[ hopper_handle ]
                
                leaf = leaf_platforms[ other ]
                
                if leaf then
                    
                    leaf_platforms[ other ] = nil
                    
                    eat_leaf( leaf )
                    
                end
            end
        end
        
    end

    ---------------------------------------------------------------------------
    -- This is the function that runs the game. It scrolls the platforms,
    -- wraps the hopper and detects when the game is over.
        
    local game_step
        
    do
    
        local x
        local y
        local vx
        local vy
        local dy
        local platform
        local platform_actor
        local high_score = settings.high_score or 0
        
        local blink_time        = 0
        local blink_count       = 0
        local blink_it          = false
        local BLINK_DURATION    = 0.25
        
        
        local function blink( seconds )
        
            blink_time = blink_time + seconds
            
            if blink_time >= BLINK_DURATION then
                blink_time = 0
                blink_count = blink_count + 1
                if high_score_label.is_visible then
                    high_score_label:hide()
                else
                    high_score_label:show()
                end
                if blink_count > 20 then
                    high_score_label:show()
                    return true
                end
            end
        
        end
        
        game_step = function( seconds )
        
            x = hopper_actor.x
            y = hopper_actor.y
            
            -- Wrap round the left and right of the screen
            
            if x > screen_w then
            
                hopper.x = x - screen_w
                
            elseif x < 0 then
            
                hopper.x = screen_w + x
                
            end

            if blink and blink_it then                

                if blink( seconds ) then
                    blink = nil
                end
                
            end
            
            vx , vy = unpack( hopper.linear_velocity )
            
            if vx < 0 then
            
                hopper_actor.y_rotation = { 0 , 0 , 0 }
                
            elseif vx > 0 then
            
                hopper_actor.y_rotation = { 180 , 0 , 0 }
                
            end
            
            move_leaves( seconds )
            
            -- When there is no life left, we disconnect the collision detection
            -- callback, so the hopper will just fall through and die
            
            if drain_life( seconds ) then
            
                if not CHEAT_INVINCIBLE then
                
                    hopper.on_begin_contact = nil
                    
                end
                
            end
                        
            -- Hopper went past the bottom of the screen
                
            if y > screen_h then
            
                game_over()
                
                
            -- Or, it got high enough to scroll down
            
            elseif y < screen_h / 4 then
            
                -- Hopper is over the top of the screen, we should scroll platforms, but
                -- only when the hopper is traveling up ( negative vy )
                
                
                if vy < 0 then
        
                    -- This is how far down everything has to scroll
                    
                    dy = screen_h / 4 - hopper_actor.y
                    
                    -- It is also what we add to the score, converting to meters or feet
                    
                    score = score + ( ( dy / PPM ) * SCORE_MULTIPLIER ) 
                    
                    score_label.text = string.format( "%1.0f" , score )
                    
                    if score > high_score then
                    
                        if not blink_it then
                        
                            high_score_label:show()
                            
                            blink_it = true
                            
                        end
                        
                    end
                    
                    -- Clamp the goat
                    
                    hopper.y = screen_h / 4
                    
                    -- Move all the platforms
                    
                    for i = 1 , # platforms do
                    
                        platform , platform_actor = unpack( platforms[ i ] )
                        
                        vy = platform_actor.y + dy
                        
                        -- This platform is off the screen, bring it to the top
                    
                        if vy - platform_hh > screen_h then
                        
                            vy = vy - screen_h
                            
                            local new_position = platform.extra.new_position
                            
                            if new_position then
                            
                                platform.position = new_position( platform.position )
                                
                            end
                            
                            recycle_platform( platform_actor , platform )
                            
    --                        extra = platform_actor.extra
                            
    --                        extra.clear_goodie( platform_actor , platform )
                            
    --                        platform.x = extra.newx()
                            
    --                        extra.add_goodie( platform_actor , platform , goat , score )
                        
                        end
                    
                        platform.y = vy
                        
                    end
                                
                end
                
            end
        
        end

    end
    
    ---------------------------------------------------------------------------
    -- Stop the physics that the splash screen started and start an idle
    
    physics:stop()
        
    local paused = false
    
    hopper_actor:raise_to_top()
    
    score_label:raise_to_top()
    
    function idle:on_idle( seconds )
    
        physics:step( seconds )
        
        if fade_in() then
            
            -- Fading in is done, we are ready to go
            
            -- Activate all the platforms
            
            for i = 1 , # platforms do
                
                platforms[ i ][ 1 ].active = true
                
            end
            
            -- Set our key handler
            
            local key_left  = keys.Left
            local key_right = keys.Right
            
            function screen:on_key_down( key )
            
                if key == key_left then
                
                    local vx = hopper.linear_velocity[ 1 ]
                
                    if vx > - MAX_SIDE_VELOCITY then
                    
                        hopper:apply_linear_impulse( { -SIDE_FORCE , 0 } , hopper.position )
                        
                    end
                
                elseif key == key_right then
                
                    local vx = hopper.linear_velocity[ 1 ]
                    
                    if vx < MAX_SIDE_VELOCITY then
                    
                        hopper:apply_linear_impulse( { SIDE_FORCE , 0 } , hopper.position )
                        
                    end
                
                end
            
            end
            
            -- Set a new idle to run game steps
            
            function idle:on_idle( seconds )
            
                if paused then
                    return
                end
            
                physics:step( seconds )
                
                game_step( seconds )
            
            end
            
        end
    
    end
    
end

-------------------------------------------------------------------------------

local main

main = function()

    asset_cache = dofile( "assets-cache" )

    local function make_title()
    
        local title = Canvas{ size = { screen.w , 300 } }
        title:begin_painting()
        title:move_to( 35 , 20 )
        title:text_path( TITLE_FONT.." 220px" , "Pandamonium" )
        --title:set_source_color( "6c5d53" )
        --title:set_source_color( "c8beb7" )
        title:set_source_color( "000000" )
        title:fill( true )
        title:set_source_color( "ffffff" )
        title:set_line_width( 10 )
        title:stroke()
        title:finish_painting()
        
        if title.Image then
            title = title:Image()
        end
            
        
        return title
        
    end

    ---------------------------------------------------------------------------
    -- Background
    
    local background = screen:find_child( "background" )
    
    if not background then
    
        background = Image
        {
            name = "background",
            src = "images/background.jpg" ,
            async = true
        }
    
        function background.on_loaded( background )
            background.on_loaded = nil
            background.size = screen.size
            screen:add( background )
            background:lower_to_bottom()
        end
        
    end
    
    ---------------------------------------------------------------------------

    local function clear_except( ... )
    
        local except = {...}
        
        local children = screen.children
        
        for i = 1 , # children do
        
            local skip = false
            
            for j = 1 , # except do
            
                if children[ i ] == except[ j ] then
                    skip = true
                    table.remove( except , j )
                    break
                end
                
            end
            
            if not skip then
                children[ i ]:unparent()
            end
        end
    
    end
    
    ---------------------------------------------------------------------------
    -- Add the title
    
    local title = make_title()


    title.position = { 0 , screen.h / 5 - title.h / 2 }
    title.z_rotation = { -8 , title.w / 2 , title.h / 2 }

    screen:add( title )

    ---------------------------------------------------------------------------
    -- Add the scores
    
    
    local high_score = settings.high_score
    local last_score = settings.last_score
    
    if high_score then
    
        if high_score == 0 then
            high_score = nil
        else
            high_score = Text
            {
                font        = SCORE_FONT.." 40px",
                color       = SCORE_COLOR,
                markup      = 'high score<span font="'..SCORE_FONT..' 60px"><b>  '..tostring( high_score ).."</b></span>",
                y           = screen_h - 145
            }
            
            high_score.x = screen_w / 2 - ( high_score.w + 30 )
            
            screen:add( high_score )
        end
    
    end

    if last_score then
    
        last_score = Text
        {
            font        = SCORE_FONT.." 40px",
            color       = SCORE_COLOR,
            markup      = 'last score<span font="'..SCORE_FONT..' 60px"><b>  '..tostring( last_score ).."</b></span>",
            position    = { screen_w / 2 + 30 , screen_h - 145 } 
        }
        
        screen:add( last_score )
    
    end
        
    ---------------------------------------------------------------------------
    -- Add a single platform 
    
    local _ , platform = make_platform()
    
    screen:add( platform )
    
    platform.position = { screen.w - ( platform.w  / 2 + 40 ) , screen.h - 100 }
    
    ---------------------------------------------------------------------------
    -- Add the hopper

    local _ , hopper = make_hopper()
    
    hopper.x = platform.x
    hopper.y = screen.h + 200 
    
    screen:add( hopper )
    
    hopper.linear_velocity = { 0 , - HOPPER_TARGET_VY * 1.5 }
    
    do
    
        local mass
        local vy
        local fy

        function hopper.on_begin_contact( hopper , contact )
    
            mass = hopper.mass
    
            vy = hopper.linear_velocity[ 2 ]
            
            if vy >= 0 then
            
                fy = -( ( mass * vy ) * 2  + ( HOPPER_TARGET_VY - vy ) )
            
                hopper:apply_linear_impulse( { 0 , fy } , hopper.position )
                
            end
        end
        
    end
    
    ---------------------------------------------------------------------------
    
    local function fade_splash( progress )
    
        local opacity = 255 - ( 255 * progress )
        
        title.opacity = opacity
        
        if high_score then
            high_score.opacity = opacity
        end
        
        if last_score then
            last_score.opacity = opacity
        end
        
    end
    
    ---------------------------------------------------------------------------

    local function on_dead( score )
    
        clear_except( background )
    
        score = tonumber( string.format( "%1.0f" , score ) )
    
        settings.last_score = score
        
        local high_score = settings.high_score
        
        if not high_score or score > high_score then
            settings.high_score = score
        end
        
        dolater( collectgarbage , "collect" )
        
        dolater( main )
    end

    ---------------------------------------------------------------------------
    -- Create a timer to delay launching the hopper
    
    local timer = Timer( 600 )
    
-------------------------------------------------------------------------------

    local leaf_blower
    
    do
            
        local leaf 
    
        local leaf_time = 0
        
        local leaves = {}
        
        local compost = {}
        
        local function clean_up()
                    
            local timer = Timer( 2000 )
            
            function timer:on_timer( )
            
                for i = 1 , # leaves do
                    leaves[ i ]:unparent()
                end
                
                for i = 1 , # compost do
                    compost[ i ]:unparent()
                end
                
                compost = {}
                leaves = {}
                leaf = nil
                leaf_time = 0
                
                self.on_timer = nil
            
            end
            
            timer:start()
        
        end
        
        leaf_blower = function( seconds , stop )
        
            if stop then
                clean_up()
                return
            end
        
            for i = # leaves , 1 , -1 do
            
                leaf = leaves[ i ]
            
                if leaf.y > screen_h + 30 then
                
                    table.insert( compost , leaf )
                    table.remove( leaves , i )
                    leaf:hide()
                    
                end
                
            end
        
            leaf_time = leaf_time + seconds
            
            if leaf_time < 1 then
                return
            end
            
            leaf_time = 0
            
            lef = nil
            
            if # compost > 0 then
                leaf = table.remove( compost )
            else
                leaf = physics:Body( asset_cache( assets.leaf ) ,
                {
                    density = 1,
                    friction = 0.5,
                    bounce = 0.2
                })
                
                screen:add( leaf )
                
                leaf:lower( title )
            end
            
            table.insert( leaves , leaf )
            
            leaf:set
            {
                position = { - 100 , screen_h },
                linear_velocity = { math.random( 6 , 8 ) , math.random( -30 , -27 ) },
                angular_velocity = math.random( 600 , 2000 ),
                angle = math.random( 360 )
            }
            
            leaf:show()
        
        end
    
    end
        
    ---------------------------------------------------------------------------
    -- Add a bumper to catch leaves
    
    local bumper = physics:Body( 
        Group
        {
            size = { 1273 - 575 , 4 } ,
            position = { 575 , 960 }
        } ,
        {
            type = "static" ,
            friction = 1
        })
    
    screen:add( bumper )
    
    ---------------------------------------------------------------------------    
    
    function timer.on_timer()
    
        function idle.on_idle( idle , seconds )
            
            physics:step( seconds )
            
            leaf_blower( seconds )
            
        end
        
        function screen.on_key_down( screen , key )
            
            if key == keys.OK then
            
                screen.on_key_down = nil
                
                idle.on_idle = nil
                
                bumper:unparent()
                
                leaf_blower( 0 , true )
                                
                start_playing( fade_splash , hopper , platform , on_dead )
                
            end
            
        end
        
        return false
    end
    
    timer:start()
        
    screen:show()
            
end


main()
