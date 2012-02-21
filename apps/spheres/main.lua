
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local BULB_PAD                      = 24 -- alpha around a bulb in px
local BULB_LINEAR_DAMPING           = 0.01
local BULB_ANGULAR_DAMPING          = 0.02
local BULB_FRICTION                 = 0.5
local BULB_DENSITY                  = 2
local BULB_BOUNCE                   = 1

local BULB_FORCE                    = 30 * BULB_DENSITY -- how much force one key press exerts
local BULB_OVERLAY_ROTATION_SPEED   = 20 -- degrees per second

local SPHERE_PAD                    = 12 -- alpha around a spehere in px
local SPHERE_LINEAR_DAMPING         = 0.07
local SPHERE_ANGULAR_DAMPING        = 0.02
local SPHERE_START_VELOCITY_MIN     = 6
local SPHERE_START_VELOCITY_MAX     = 12
local SPHERE_FRICTION               = 0.01
local SPHERE_DENSITY                = 1
local SPHERE_BOUNCE                 = 1.00

local RING_ANIMATE_IN_DURATION      = 400

local SCORE_FLIP_DURATION           = 200

local SCORE_FONT                    = "DejaVu Sans Mono 50px"

local DEBUG                         = false

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local RED           = "red"
local GREEN         = "green"
local BLUE          = "blue"
local YELLOW        = "yellow"
local NEUTRAL       = "N"

local COLORS        = { RED , GREEN , BLUE , YELLOW }

local SW , SH       = screen.w , screen.h

local RING_START    =
{
    [ RED    ]  = {  0 , SH },
    [ GREEN  ]  = { SW , SH },
    [ YELLOW ]  = {  0 ,  0 },
    [ BLUE   ]  = { SW ,  0 }
}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local step_functions = {}

local function run_step_funcs( seconds )
    for f , _ in pairs( step_functions ) do
        f( seconds )
    end
    collectgarbage( "step" )
end

local function add_step_func( duration , func , on_completed )

    local step

    if duration then

        local t = 0
        local d = duration / 1000
        local p = 0
        local min = math.min
    
        step =
            function( seconds )
                t = t + seconds
                p = min( t / d , 1 )
                func( p )
                if p >= 1 then
                    if on_completed then
                        dolater( on_completed )
                    end
                    step_functions[ step ] = nil
                end
            end
    else
    
        step =
            function( seconds )
                if false == func( seconds ) then
                    if on_completed then
                        dolater( on_completed )
                    end
                    step_functions[ step ] = nil
                end
            end
    
    end
    
    step_functions[ step ] = true
end

-------------------------------------------------------------------------------

local function KeyHandler( t )
    return
        function( o , key , ... )
            local k = keys[ key ]:upper()
            while k do
                local f = t[ k ]
                if type( f ) == "function" then
                    return f( o , key , ... )
                end
                k = f
            end
        end
end

-------------------------------------------------------------------------------
-- Load assets
-------------------------------------------------------------------------------

local assets    = {}

for i = 1 , # COLORS do
    local color = COLORS[i]
    local t =
    {
        bulb    = Image{ src = string.format( "assets/bulbs/bulb-%s.png" , color ) },
        overlay = Image{ src = string.format( "assets/bulbs/bulb-%s-overlay.png" , color ) },
        sphere  = Image{ src = string.format( "assets/spheres/sphere-%s.png" , color ) },
        ring    = Image{ src = string.format( "assets/ring-%s.png" , color ) }
    }
    assets[ color ] = t
    for k , v in pairs( t ) do
        screen:add( v:set{ visible = false } )
    end
end

assets[ NEUTRAL ] = { sphere = Image{ src = "assets/spheres/sphere-neutral.png" } }
screen:add( assets[ NEUTRAL ].sphere:set{ visible = false } )

-------------------------------------------------------------------------------
-- Background
-------------------------------------------------------------------------------

local bgc = Image{ src = "assets/bg-clouds-1080p.jpg" , scale = { 2 , 2 } }
local bgs = Image{ src = "assets/bg-planet-topleft.png" }

screen:add( bgc , bgs )

local function bg_step( seconds )
    -- animate background
end

-------------------------------------------------------------------------------
-- Add invisible walls
-------------------------------------------------------------------------------

local CORNER_BUMPER_X    = 40
local CORNER_BUMPER_Y    = 40
local CORNER_BUMPER_SIZE = { CORNER_BUMPER_X * 2 , CORNER_BUMPER_Y * 2 }
local CORNER_BUMPER_ROTATION = { 46 , CORNER_BUMBER_X , CORNER_BUMPER_Y }
local STATIC = { type = "static" }

screen:add( 
    physics:Body( Group{ size = {  2 , SH } , position = { -2 ,  0 } } , STATIC ),
    physics:Body( Group{ size = {  2 , SH } , position = { SW ,  0 } } , STATIC ),
    physics:Body( Group{ size = { SW ,  2 } , position = {  0 , -2 } } , STATIC ),
    physics:Body( Group{ size = { SW ,  2 } , position = {  0 , SH } } , STATIC ),
    
    -- These help keep the small spheres from getting stuck in the corners
    
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { - CORNER_BUMPER_X , - CORNER_BUMPER_Y } } , STATIC ),
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { - CORNER_BUMPER_X , SH - CORNER_BUMPER_Y } } , STATIC ),
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { SW - CORNER_BUMPER_X , - CORNER_BUMPER_Y } } , STATIC ),
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { SW - CORNER_BUMPER_X , SH - CORNER_BUMPER_Y } } , STATIC )
)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function make_bulb( color )
    local bulb = Clone{ source = assets[ color ].bulb }
    local overlay = Clone{ source = assets[ color ].overlay }
    
    local result = Group
    {
        name = string.format( "%s-bulb" , color ),
        size = bulb.size,
        children = { bulb , overlay },
        extra = { color = color }
    }
    
    local oa = 0
    local za = { 0 , bulb.w / 2 , bulb.h / 2 }
    
    function result.extra.step( seconds )
        oa = oa + BULB_OVERLAY_ROTATION_SPEED * seconds
        if oa > 360 then
            oa = oa - 360
        end
        za[ 1 ] = oa
        overlay.z_rotation = za
    end
    
    local physics_props =
    {
        shape = physics:Circle( ( result.w / 2 ) - BULB_PAD ),
        friction = BULB_FRICTION,
        density = BULB_DENSITY,
        bounce = BULB_BOUNCE,
        linear_damping = BULB_LINEAR_DAMPING,
        angular_damping = BULB_ANGULAR_DAMPING
    }
    
    return physics:Body( result , physics_props )
end

local function make_ring( color )
    local ring = Clone{ source = assets[ color ].ring }
    local text = Text{ font = SCORE_FONT , color = color , text = "0000" , visible = false }
    
    text.anchor_point = text.center
    text.position = ring.center
    
    local result = Group
    {
        name = string.format( "%s-ring" , color ),
        size = ring.size,
        children =
        {
            ring,
            text,
        },
        anchor_point = ring.center,
        extra = { color = color }
    }
   
    result.position = RING_START[ color ]
    
    local flips = 0
    
    local function flip( p )
        text.x_rotation = { 180 * p }
    end

    local function flip_done()
        text.x_rotation = { 0 }
        flips = flips - 1
    end
    
    local function flip_it()
        flips = flips + 1
        if not step_functions[ flip ] then
            add_step_func( SCORE_FLIP_DURATION , flip , flip_done )
        end
    end
     
    local score = 0
    
    local e = result.extra
    
    function e:update_score( value )
        score = value
        text.text = string.format( "%4.4d" , score )
        flip_it()        
    end
    
    function e:add_score( value )
        self:update_score( score + value )
    end
    
    function e:reset()
        self.position = RING_START[ color ]
        self:update_score( 0 )
        text.visible = false
    end
    
    function e:animate_in( callback )
        self:reset()
        
        local dx = choose( self.x == 0 , self.w / 2 , SW - self.w / 2 )
        local dy = choose( self.y == 0 , self.h / 2 , SH - self.h / 2 )
        local xi = Interval( self.x , dx )
        local yi = Interval( self.y , dy )
        
        local function move( p )
            self.x = xi:get_value( p )
            self.y = yi:get_value( p )
        end
                
        local function flip( p )
            self.y_rotation = { 180 * p }
            text.opacity = 255 * p
        end
        
        local function flip_done()
            self.y_rotation = { 0 }
            dolater( callback )
        end
        
        local function move_done()
            text.opacity = 0
            text.visible = true
            add_step_func( RING_ANIMATE_IN_DURATION , flip , flip_done )
        end
        
        add_step_func( RING_ANIMATE_IN_DURATION , move , move_done )
        
    end
    
    return result
end

local function make_sphere()

    local sphere = Clone{ source = assets[ NEUTRAL ].sphere }
    
    local physics_props =
    {
        shape = physics:Circle( ( sphere.w / 2 ) - SPHERE_PAD ),
        friction = SPHERE_FRICTION,
        density = SPHERE_DENSITY,
        bounce = SPHERE_BOUNCE,
        linear_damping = SPHERE_LINEAR_DAMPING,
        angular_damping = SPHERE_ANGULAR_DAMPING,
    }
    
    local e = sphere.extra
    
    function e:switch( color )
        self.extra.color = choose( color == NEUTRAL , nil , color )
        self.source = assets[ color ].sphere
    end
    
    return physics:Body( sphere , physics_props )
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local rings = {}

for i = 1 , # COLORS do
    local color = COLORS[ i ]
    local ring = make_ring( color )
    rings[ color ] = ring
    screen:add( ring )
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

local players = {} -- key is color, value is a table

local spheres = {} -- key is sphere handle, value is sphere

local neutral_spheres = 0 -- how many are left

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

local setup_controller

local function player_joined( controller )

    -- Find a slot
    local color = nil
    for i = 1 , # COLORS do
        if players[ COLORS[i] ] == nil then
            color = COLORS[i]
            break
        end
    end
    -- No free slot
    if color == nil then
        print( "NO MORE PLAYERS!")
        return
    end
    
    print( "NEW PLAYER IS" , color )
    
    -- This player cannot join again
    controller.on_key_down = nil

    -- Set-up the player
    local player = {}
    players[ color ] = player

    local ring = rings[ color ]
    player.ring = ring

    ring:reset()
                
    local bulb = make_bulb( color )
    
    player.bulb = bulb
    
    -- animate the ring out, then show the bulb
    
    local function ring_done()
        
        
        bulb.position = ring.position
        bulb.opacity = 0
        screen:add( bulb )
        
        local oi = Interval( 0 , 255 )

        local function show_bulb( p )
            bulb.opacity = oi:get_value( p )
        end
        
        add_step_func( RING_ANIMATE_IN_DURATION , show_bulb )
        
        add_step_func( nil , bulb.extra.step )
        
        -- Now, we are ready to take events from the controller
        
        controller.on_key_down =
            
            KeyHandler
            {
                UP      = function() bulb:apply_force( { 0 , - BULB_FORCE } , bulb.position ) end,
                DOWN    = function() bulb:apply_force( { 0 , BULB_FORCE } , bulb.position ) end,
                LEFT    = function() bulb:apply_force( { - BULB_FORCE , 0 } , bulb.position ) end,
                RIGHT   = function() bulb:apply_force( { BULB_FORCE , 0 } , bulb.position ) end,
            }
--[[            
        local MIN_ACCEL_TH = 0.20
        
        local function accel_to_force( a )
            return 20 * a * BULB_FORCE
        end
        
        if controller.has_accelerometer and controller:start_accelerometer( "HIGH" , 0.200 ) then
        
            function controller:on_accelerometer( x , y , z )
                
                if math.abs( x ) > MIN_ACCEL_TH then
                    print( "X =" , x )
                    bulb:apply_force( { accel_to_force( x ) , 0 } , bulb.position )
                end
                if math.abs( y ) > MIN_ACCEL_TH then
                    print( "Y =" , y )
                    bulb:apply_force( { 0 , accel_to_force( -y ) } , bulb.position )
                end
            end
        
        end
]]

        if controller.has_touches and controller:start_touches() then
        
            local lx
            local ly
            
            local mx , my = unpack( controller.input_size )
            local md = math.min( mx , my )
            
            local FORCE_MULT = 60
            
            function controller:on_touch_down( f , x , y )
                lx = x
                ly = y
            end
            
            function controller:on_touch_up( f , x , y )
                if lx and ly then
                    local dx = ( x - lx ) / md
                    local dy = ( y - ly ) / md
                    
                    print( dx , dy )
                    
                    bulb:apply_force( { FORCE_MULT * dx * BULB_FORCE , FORCE_MULT * dy * BULB_FORCE } , bulb.position )
                    
                    lx = nil
                    ly = nil
                end                
            end
        
        end
        
        function bulb:on_pre_solve_contact( contact )
            -- If we collied with a sphere and it has the same color as we do
            -- we disable the contact, so the sphere will pass right through us
            
            local sphere = spheres[ contact.other_body[ self.handle ] ]
            if sphere and sphere.extra.color == color then
                contact.enabled = false
            end
        end
        
        function bulb:on_begin_contact( contact )
            -- If we collide with a sphere that has no color, it becomes
            -- ours
            local sphere = spheres[ contact.other_body[ self.handle ] ]
            if sphere then
                local other_color = sphere.extra.color
                if other_color == nil then
                    sphere:switch( color )
                    players[ color ].ring:add_score( 5 )
                    neutral_spheres = neutral_spheres - 1
                    
                    -- All the neutral spheres are gone, the level is over
                    
                    if neutral_spheres == 0 then
                        for k , sphere in pairs( spheres ) do
                            sphere:switch( NEUTRAL )
                            neutral_spheres = neutral_spheres + 1
                        end
                    end
                end
            end
        end
    end
    
    ring:animate_in( ring_done )
    
    -- The controller went away, so we need to take this player out
    
    function controller:on_disconnected()
        print( "THE" , color , "PLAYER IS GONE" )
        -- TODO reset the ring
    end
    
    -- Find out if this is the first player
    
    local player_count = 0
    
    for i = 1 , # COLORS do
        if players[ COLORS[i] ] ~= nil then
            player_count = player_count + 1
            if player_count > 1 then
                break
            end
        end
    end
    
    if player_count == 1 then
    end
    
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

local function start_level()
    -- TODO put players back in their rings
    
    neutral_spheres = 0

    for i = 1 , 0 do
        local sphere = make_sphere()
        local W , H = sphere.w , sphere.h
        sphere.x = math.random( W , SW - W )
        sphere.y = math.random( H , SH - H )
        sphere.linear_velocity = {
            math.random( SPHERE_START_VELOCITY_MIN , SPHERE_START_VELOCITY_MAX ) ,
            math.random( SPHERE_START_VELOCITY_MIN , SPHERE_START_VELOCITY_MAX ) }
        screen:add( sphere )
        spheres[ sphere.handle ] = sphere
        neutral_spheres = neutral_spheres + 1
    end
end


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function setup_controller( c )
    if not c.has_keys then
        return
    end
    function c:on_key_down( key )
        -- A new controller wants to start playing
        if key == keys.OK then
            player_joined( c )
        end
    end
end

for i = 1 , # controllers.connected do
    setup_controller( controllers.connected[ i ] )
end

function controllers:on_controller_connected( c )
    setup_controller( c )
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

physics.gravity = { 0 , 0 }

physics:start()

screen:show()

dolater( start_level )

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function physics:on_step( seconds )
    run_step_funcs( seconds )
    if DEBUG then
        physics:draw_debug()
    end
end

--function screen:on_key_down( k ) if k == keys.BACK then physics.gravity = { -3 , -3 } end end
