
dofile( "controller.lua" )


-- Alex's code
local number_of_lives = 3
local high_score = settings.high_score or 0
local point_counter = 0
local my_plane_sz = 65*2
local topbar = Group{z=1}
topbar:add( 
	Rectangle{
		name = "BG",
		color="0000007F",
		w=1920,
		h=80
	},
    --[[
	Text{
		name = "LIVES",
		text = "Lives:",
		font="Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		x=30,
		y=20
	},
    --]]
	Text{
		name = "SCORE",
		text = "Current Score:",
		font="Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		y = 20
	},
	Text{
		name = "HIGHSCORE",
		text = "High Score:",
		font="Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		y = 20
	}

)
local score_txt = Text{
		text = "",
		font="Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		x = screen.w/2 +20,
		y = 20
}
local h_score_txt = Text{
		text = "",
		font="Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		y = 20
}
function redo_score_text()
	score_txt.text   = string.format("%06d",point_counter)
	h_score_txt.text = string.format("%06d",high_score) 
end

redo_score_text()
h_score_txt.x = screen.w-h_score_txt.w-20

topbar:add(score_txt,h_score_txt)
topbar:find_child("SCORE").x = screen.w/2 - topbar:find_child("SCORE").w - 20
topbar:find_child("HIGHSCORE").x = h_score_txt.x - topbar:find_child("HIGHSCORE").w - 20

local game_is_running = false
local splash = Group{z=10}
local end_game  = Group{z=10,opacity = 0}
end_game:add(
	Text{ text = "GAMEOVER",font = "Highway Gothic Wide Bold 70px", color = "FFFFFF",position={400,450}}--,
	--Text{ text = "Press any key to play again",font = "Highway Gothic Wide 36px", color = "FFFFFF",position={400,650}}
)
splash:add(

    Image{ name = "logo",src = "assets/splash/AirCombatLogo.png", position = {screen.w/2,screen.h/2-80}},
    Image{ name = "instr", src = "assets/splash/InstructionBar.png", position = {50,screen.h - 120}},
    Image{ name = "start",src = "assets/splash/StartButton.png", position = {screen.w/2,screen.h/2+240}}
)
local logo = splash:find_child("logo")
logo.anchor_point = {logo.w/2,logo.h/2}
--[[
local instr = splash:find_child("instr")
instr.anchor_point = {instr.w/2,instr.h/2}
--]]
local startt = splash:find_child("start")
startt.anchor_point = {startt.w/2,startt.h/2}

local life = Image{src = "assets/life.png",opacity=0,z=10}
screen:add(life)
local lives =
{
	Clone{name="life1",source=life,x=20,y=15,z=10},
	Clone{name="life2",source=life,x=80,y=15,z=10},
	Clone{name="life3",source=life,x=140,y=15,z=10},
	Clone{name="life4",source=life,x=200,y=15,z=10,opacity=0},
	Clone{name="life5",source=life,x=260,y=15,z=10,opacity=0},
}

screen:add(topbar,score,end_game,splash)
screen:add(unpack(lives))
-------------------------------------------------------------------------------

function clamp( v , min , max )

    if v < min then return min        
    elseif v > max then return max        
    else return v        
    end

end

-------------------------------------------------------------------------------

assets =
{
    water           = Image{ src = "assets/water.png" },
    my_plane_strip  = Image{ src = "assets/myplane.png" },
    my_bullet       = Image{ src = "assets/bullet.png" },
    enemy1          = Image{ src = "assets/e1_4x_test.png" },
    enemy2          = Image{ src = "assets/e2_4x_test.png" },
    enemy3          = Image{ src = "assets/e3_4x_test.png" },
    enemy_bullet    = Image{ src = "assets/enemybullet1.png" },
    explosion1      = Image{ src = "assets/explosion1_strip6.png" },
    explosion2      = Image{ src = "assets/explosion2_strip7.png" },
    island1         = Image{ src = "assets/island1.png" },
    island2         = Image{ src = "assets/island2.png" },
    island3         = Image{ src = "assets/island3.png" },
    score           = Text{ font = "Highway Gothic Wide 24px" , text = "+10" , color = "FFFF00" },
    g_over          = Text{ font = "Highway Gothic Wide 24px" , text = "GAMEOVER" , color = "FFFFFF" },
    up_life          = Text{ font = "Highway Gothic Wide 24px" , text = "+1 Life"  , color = "FFFFFF" },
}

for _ , v in pairs( assets ) do
    
    v.opacity = 0
        
    screen:add( v )
    
end

-------------------------------------------------------------------------------

ENEMY_PLANE_MIN_SPEED       = 105

ENEMY_PLANE_MAX_SPEED       = 150

ENEMY_FREQUENCY             = 1--0.8

ENEMY_SHOOTER_PERCENTAGE    = 20--deprecated

-------------------------------------------------------------------------------

render_list = {}

function add_to_render_list( item )

    if item then
    
        pcall( item.setup , item )
        
        table.insert( render_list , item )
    
    end

end

function remove_from_render_list( item )

    for i , v in ipairs( render_list ) do
    
        if v == item then
        
            table.remove( render_list , i )
            
            return true
            
        end
        
    end
    
    return false

end

-------------------------------------------------------------------------------
-- Item types for collision detection

TYPE_MY_PLANE       = 1
TYPE_MY_BULLET      = 2
TYPE_ENEMY_PLANE    = 3
TYPE_ENEMY_BULLET   = 4

collision_list = {}

function add_to_collision_list( item , start_point, end_point , size , other_type )

    table.insert( collision_list ,
        {
            item = item,
            start_point = start_point,
            end_point = end_point,
            size = size,
            other = other_type
        } )

end

function process_collisions( )

    -- This function uses two rectangles to do collision detection
    
    local function collided( source , target )
    
        local sx1 = math.min( source.start_point[ 1 ] - source.size[ 1 ] / 2 , source.end_point[ 1 ] - source.size[ 1 ] / 2 )
        local sy1 = math.min( source.start_point[ 2 ] - source.size[ 2 ] / 2 , source.end_point[ 2 ] - source.size[ 2 ] / 2 )
        local sx2 = math.max( source.start_point[ 1 ] + source.size[ 1 ] / 2 , source.end_point[ 1 ] + source.size[ 1 ] / 2 )
        local sy2 = math.max( source.start_point[ 2 ] + source.size[ 2 ] / 2 , source.end_point[ 2 ] + source.size[ 2 ] / 2 )
            
        local tx1 = math.min( target.start_point[ 1 ] - target.size[ 1 ] / 2 , target.end_point[ 1 ] - target.size[ 1 ] / 2 )
        local ty1 = math.min( target.start_point[ 2 ] - target.size[ 2 ] / 2 , target.end_point[ 2 ] - target.size[ 2 ] / 2 )
        local tx2 = math.max( target.start_point[ 1 ] + target.size[ 1 ] / 2 , target.end_point[ 1 ] + target.size[ 1 ] / 2 )
        local ty2 = math.max( target.start_point[ 2 ] + target.size[ 2 ] / 2 , target.end_point[ 2 ] + target.size[ 2 ] / 2 )
                
        return not ( sx1 > tx2 or sx2 < tx1 or sy1 > ty2 or sy2 < ty1  )
        
    end

    -- Track all the items we have already looked at

    local removed = {}

    for _ , source in ipairs( collision_list ) do
    
        if removed[ source ] == nil then
        
            for _ , target in ipairs( collision_list ) do
                
                if ( removed[ target ] == nil ) and
                    ( source ~= target ) and
                    ( source.other == target.item.type ) then
                
                    if collided( source , target ) then
                                        
                        -- Invoke the collision function on bothe the source and
                        -- the target, passing the other.
                        
                        pcall( source.item.collision , source.item , target.item )
                        pcall( target.item.collision , target.item , source.item )
                        
                        -- Mark them as 'removed'
                        
                        removed[ source ] = true
                        removed[ target ] = true
                    
                    end
                
                end
            
            end
            
        end
        
    end

    -- Clear the collision list
    
    collision_list = {}
end

-------------------------------------------------------------------------------
-- This one deals with the water and occasional islands

water =
{
    speed = 100, -- pixels per second
    
    strips = {},
    
    top_y = 0,
    
    time = 0,
    
    island_time = 0.5, -- seconds
    
    setup =
    
        function( self )
                
            local tile = assets.water
            
            --tile:set{ w = screen.w , tile = { false  , false } }
                        
            for i = 1 , math.ceil( screen.h / tile.h ) + 3 do
                   
                table.insert( self.strips , Clone{ source = tile } )
                
            end
            
            local top = - ( tile.h * 2 )
            
            self.top_y = top
            
            for _ , strip in ipairs( self.strips ) do
            
                strip.position = { 0 , top }
                
                top = top + tile.h - 1
            
                screen:add( strip )
                
            end

        end,
            
    render =
    
        function( self , seconds )

                
            -- reposition all the water strips
            
            local dy = self.speed * seconds
            
            local maxy = screen.h
            
            self.top_y = self.top_y + dy    
            
            for _ , strip in ipairs( self.strips ) do

            
                strip.y = strip.y + dy

                if strip.y > maxy then
                
                    strip.y = self.top_y - strip.h + 1   
                    
                    self.top_y = strip.y
                
                end
            
            end
            
            -- see if we should drop an island
            
            self.time = self.time + seconds
            
            if false then

--self.time >= self.island_time then
            
                self.time = self.time - self.island_time
                
                if math.random( 100 ) < 50 then
                               
                    local island =
                        
                        {
                            speed = self.speed,
                            
                            image = Clone{ source = assets[ "island"..tostring( math.random( 1 , 3 ) ) ] , opacity = 255 },
                            
                            setup =
                            
                                function( self )
                                
                                    self.image.position = { math.random( 0 , screen.w ) , - self.image.h }
                                    
                                    if math.random( 100 ) > 50 then
                                    
                                        self.image.y_rotation = { 180 , self.image.w / 2 , 0 }
                                    
                                    end
                                    
                                    if math.random( 100 ) < 50 then
                                    
                                        self.image.x_rotation = { 180 , self.image.h / 2 , 0 }
                                    
                                    end
                                    
                                    self.image.z_rotation = { math.random( 180 ) , self.image.w / 2 , self.image.h / 2 }
                                    
                                    screen:add( self.image )
                                
                                end,
                                
                            render =
                            
                                function( self , seconds )
                                
                                    local y = self.image.y + self.speed * seconds
                                    
                                    if y > screen.h then
                                    
                                        remove_from_render_list( self )
                                        
                                        screen:remove( self.image )
                                        
                                    else
                                    
                                        self.image.y = y
                                        
                                    end
                                    
                                end,
                        }
                        
                    add_to_render_list( island )
                
                end
            
            end
            
        end,        
}

-------------------------------------------------------------------------------
-- This is my plane. It spawns bullets

my_plane =
{
    type = TYPE_MY_PLANE,
    
    max_h_speed = 600,
    
    max_v_speed = 175,
    
    friction = 0.85,
    
    friction_bump = 1000, -- per second
    
    speed_bump = 200,
        
    group = Group{ size = { --[[65 , 65]]my_plane_sz,my_plane_sz } , clip = { 0 , 0 , my_plane_sz,my_plane_sz--[[65 , 65]] } },
    
    image = Clone{ source = assets.my_plane_strip },
    
    bullet = assets.my_bullet,
    
    v_speed = 0,
    
    h_speed = 0,
    
    dead = false,
    
    dead_blinks = 5,
    
    dead_time = 0,
    
    dead_blink_delay = 0.5,
    
    
    max_dead_time = 2,
    
    setup =
    
        function( self )
        
            self.image.opacity = 255
            
            self.group:add( self.image )
            
            screen:add( self.group )
            
            self.group.position = { screen.w / 2 - my_plane_sz / 2 , screen.h - my_plane_sz }
            
        end,
        
    render =
    
        function( self , seconds )
        
            -- Flip sprites
            
            -- We just move the image within the group, which has a clipping
            -- area set.
            
            local x = self.image.x - my_plane_sz
            
            if x == -390 then
            
                x = 0
                
            end
            
            self.image.x = x
            
            self.group:raise_to_top()
    
            -- Move
            
            if game_is_running then--not self.dead then
if self.dead then
                -- Figure the total time we have been dead
                self.dead_time = self.dead_time + seconds
                
                -- If it is the maximum time, we go back to being alive
                
                if self.dead_time >= self.max_dead_time then
                    self.dead = false
                    
                    self.dead_time = 0
                    
                    self.group:show()
                    
                -- Otherwise, we blink
                    
                elseif self.dead_time > self.dead_blink_delay then
                
                    local blink_on = math.floor( self.dead_time / ( 1 / self.dead_blinks ) ) % 2 == 0
                    
                    if blink_on then
                    
                        self.group:show()
                        
                    else
                        
                        self.group:hide()
                        
                    end
                
                end

end

            
                local start_point = self.group.center
                
                if self.h_speed > 0 then
                
                    local x = self.group.x + ( self.h_speed * seconds )
                    
                    if x > screen.w - my_plane_sz then
                    
                        x = screen.w -my_plane_sz 
                        
                        self.h_speed = 0
                    
                    else
                    
                        self.h_speed = clamp( ( self.h_speed * ( self.friction ^ seconds ) ) - ( self.friction_bump * seconds ) , 0 , self.max_h_speed )
                        
                    end
                    
                    self.group.x = x
                                
                elseif self.h_speed < 0 then
                
                    local x = self.group.x + ( self.h_speed * seconds )
                    
                    if x < 0 then
                    
                        x = 0
                        
                        self.h_speed = 0
                    
                    else
                    
                        self.h_speed = clamp( ( self.h_speed * ( self.friction ^ seconds ) ) + ( self.friction_bump * seconds )  , - self.max_h_speed , 0 )
                    end
                    
                    self.group.x = x
                
                end
                
                if self.v_speed > 0 then
    
                    local y = self.group.y + ( self.v_speed * seconds )
                    
                    if y > screen.h - my_plane_sz then
                    
                        y = screen.h -my_plane_sz 
                        
                        self.v_speed = 0
                    
                    else
                    
                        self.v_speed = clamp( ( self.v_speed * ( self.friction ^ seconds ) ) - ( self.friction_bump * seconds ) , 0 , self.max_v_speed )
                        
                    end
                    
                    self.group.y = y
                
                elseif self.v_speed < 0 then
                
                    local y = self.group.y + ( self.v_speed * seconds )
                    
                    if y < 0 then
                    
                        y = 0
                        
                        self.v_speed = 0
                    
                    else
                    
                        self.v_speed = clamp( ( self.v_speed * ( self.friction ^ seconds ) ) + ( self.friction_bump * seconds )  , - self.max_v_speed , 0 )
                    end
                    
                    self.group.y = y
                end
    if not self.dead then
                add_to_collision_list( self , start_point , self.group.center , { self.group.w - 10 , self.group.h - 30 } , TYPE_ENEMY_PLANE )
end
            
            -- when dead
            --[[
            elseif game_is_running then
                -- Figure the total time we have been dead
                self.dead_time = self.dead_time + seconds
                
                -- If it is the maximum time, we go back to being alive
                
                if self.dead_time >= self.max_dead_time then
                    self.dead = false
                    
                    self.dead_time = 0
                    
                    self.group:show()
                    
                -- Otherwise, we blink
                    
                elseif self.dead_time > self.dead_blink_delay then
                
                    local blink_on = math.floor( self.dead_time / ( 1 / self.dead_blinks ) ) % 2 == 0
                    
                    if blink_on then
                    
                        self.group:show()
                        
                    else
                        
                        self.group:hide()
                        
                    end
                
                end
            --]]
            end
        end,
        
    -- Adds a bullet to the render list
        
    new_bullet =
    
        function( self )
        
            return
            
            {
                type = TYPE_MY_BULLET,
                
                speed = -400,
                
                image =
                    
                    Clone
                    {                    
                        source = self.bullet,
                        opacity = 255,
                        anchor_point = { self.bullet.w / 2 , self.bullet.h / 2 },
                        position = { self.group.x + self.group.w / 2 , self.group.y }
                    },
                    
                setup =
                
                    function( self )
                    
                        screen:add( self.image )
                        
                    end,
                    
                render =
                
                    function( self , seconds )
                    
                        local y = self.image.y + self.speed * seconds
                        
                        if y < -self.image.h then
                            
                            remove_from_render_list( self )
                            
                            screen:remove( self.image )
                        
                        else
                        
                            add_to_collision_list(
                                self ,
                                { self.image.x , self.image.y },
                                { self.image.x , y },
                                { self.image.w , self.image.h },
                                TYPE_ENEMY_PLANE )
                        
                            self.image.y = y
                        
                        end
                    
                    end,
                    
                collision =
                
                    function( self , other )
                    
                        remove_from_render_list( self )
                        
                        local location = other.group.position

                        screen:remove( self.image )
                        
                        -- Now, we create a score bubble
                        
                        local score =
                            {
                                speed = 255,
                                
                                text = Clone{ source = assets.score },
                                
                                setup =
                                
                                    function( self )
                               
if point_counter < 999990 then     
	point_counter = point_counter+10
	if point_counter > high_score then
		high_score = point_counter
	end
	if (point_counter % 1000) == 0 and lives[number_of_lives + 1] ~= nil then
		number_of_lives = number_of_lives + 1
		lives[number_of_lives].opacity =255
		self.text = Clone{source=assets.up_life}
	end
	redo_score_text()
end

                                        self.text.position = { location[ 1 ] + 30 , location[ 2 ] }
                                        
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        
                                        self.text.opacity = 255;
                                    
                                        screen:add( self.text )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                   -- print("aaaa")
                                        local o = self.text.opacity - self.speed * seconds
                                        
                                        local scale = self.text.scale
                                        
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        
                                        if o <= 0 then
                                        
                                            remove_from_render_list( self )
                                            
                                            screen:remove( self.text )
                                        
                                        else
                                        
                                            self.text.opacity = o
                                            
                                            self.text.scale = scale
                                        
                                        end
                                    
                                    end,
                            }
                            
                        add_to_render_list( score )
                    
                    end
            }
        
        end,
        
    -- When we crash with an enemy plane
    
    collision =
    
        function( self , other )



--more Alex code
if number_of_lives == 0 then
	game_is_running = false
	--end_game.y = -100
	--end_game.opacity = 255
--	end_game.scale = {.5,.5}
	remove_from_render_list( my_plane )
	add_to_render_list(
                
                            {
                                speed = 20,
                                
                                text = Clone{ source = assets.g_over },
                                
                                setup =
                                
                                    function( self )
                                    
                                        self.text.position = { screen.w/2,screen.h/2}--location[ 1 ] + 30 , location[ 2 ] }
                                        
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        
                                        self.text.opacity = 255;
                                    
                                        screen:add( self.text )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                    
                                        local o = self.text.opacity - self.speed * seconds
                                        
                                        local scale = self.text.scale
                                        
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        
                                        if o <= 0 then
                                        
                                            remove_from_render_list( self )
                                            
                                            screen:remove( self.text )
                                        
                                        else
                                        
                                            self.text.opacity = o
                                            
                                            self.text.scale = scale
                                        
                                        end
                                    
                                    end,
                            })
	add_to_render_list(
                
                            {
                                elapsed = 0,
                                
                                --text = Clone{ source = assets.g_over },
                                
                                setup =
                                
                                    function( self )
					self.save_keys = screen.on_key_down
					screen.on_key_down = nil

                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                   	self.elapsed = self.elapsed + seconds
					if self.elapsed > 5 then
						remove_from_render_list( self )
						screen.on_key_down = self.save_keys
					elseif self.elapsed >4 then
						splash.opacity = 255
					end
                                    end,
                            })


else
	lives[number_of_lives].opacity=0
	number_of_lives = number_of_lives - 1
	
end
redo_score_text()
--------



            self.dead = true
            
            self.group:hide()
            
            self.h_speed = 0
            
            self.v_speed = 0
            
            local location = self.group.center
            
            self.group.position = { screen.w / 2 - self.group.w / 2 , screen.h - self.group.h }

            -- Spawn an explosion
            
            local explosion =
                
                {
                    image = Clone{ source = assets.explosion2 , opacity = 255 },
                    
                    group = nil,
                    
                    duration = 0.4, 
                    
                    time = 0,
                    
                    setup =
                    
                        function( self )
                        
                            self.group = Group
                                {
                                    size = { self.image.w / 7 , self.image.h },
                                    position = location,
                                    clip = { 0 , 0 , self.image.w / 7 , self.image.h },
                                    children = { self.image },
                                    anchor_point = { ( self.image.w / 7 ) / 2 , self.image.h / 2 }
                                }
                            
                            screen:add( self.group )
                            
                        end,
                        
                    render =
                    
                        function( self , seconds )
                        
                            self.time = self.time + seconds
                            
                            if self.time > self.duration then
                                
                                remove_from_render_list( self )
                                
                                screen:remove( self.group )
                            
                            else
                            
                                local frame = math.floor( self.time / ( self.duration / 6 ) )
                                
                                self.image.x = - ( ( self.image.w / 7 ) * frame )
                            
                            end
                        
                        end,
                }
            
            add_to_render_list( explosion )
        
        end,
        
    on_key =
    
        function( self , key )
        --[[
            if number_of_lives == 0 then--self.dead then
            
                return
                
            end
            --]]   
            if key == keys.Right then
            
                self.h_speed = clamp( self.h_speed + self.speed_bump , -self.max_h_speed , self.max_h_speed )
                
            elseif key == keys.Left then
            
                self.h_speed = clamp( self.h_speed - self.speed_bump , -self.max_h_speed , self.max_h_speed )
                
            elseif key == keys.Down then
            
                self.v_speed = clamp( self.v_speed + self.speed_bump , -self.max_v_speed , self.max_v_speed )
                
            elseif key == keys.Up then
            
                self.v_speed = clamp( self.v_speed - self.speed_bump , -self.max_v_speed , self.max_v_speed )
            
            elseif key == keys.Return then
            
                add_to_render_list( self:new_bullet() )
                
            end
                
        end
}

-------------------------------------------------------------------------------
-- This thing renders nothing, it just spawns enemies

enemies =
{
    count = 0,
    
    time = 0,
    
    enemy_seconds = ENEMY_FREQUENCY,
    
    images = { assets.enemy1 , assets.enemy2 , assets.enemy3 , assets.enemy4 , assets.enemy5 },
        
    setup = 
    
        function( self )
        
        end,
        
    -- Spawn a new enemy
    
    new_enemy =
    
        function( self , image , speed , position )
        
            return
            {
                type = TYPE_ENEMY_PLANE,
                
                enemies = self,
                
                speed = nil, 
                
                image = nil,
                
                group = nil,
                
                shoots = false,
                
                shoot_time = 4,--0.5 + math.random(), -- seconds
                
                last_shot_time = 2,
                
                setup =
                
                    function( self )
                    
                        if not image then
                        
                            self.image = Clone{ source = self.enemies.images[ math.random( #self.enemies.images ) ] , opacity = 255 }
                            
                        else
                        
                            self.image = Clone{ source = image , opacity = 255 }
                        end
                        
                        if speed then
                        
                            self.speed = speed
                            
                        else
                        
                            self.speed = math.random( ENEMY_PLANE_MIN_SPEED , ENEMY_PLANE_MAX_SPEED )
                            
                        end
                        
                        local position = position
                        
                        if not position then
                        
                            position = { math.random( 0 , screen.w - self.image.w ) , - self.image.h }
                        
                        end
                    
                        self.group = Group
                            {
                                size = { self.image.w / 3 , self.image.h },
                                position = position,
                                clip = { 0 , 0 , self.image.w / 3 , self.image.h },
                                children = { self.image }
                            }
                            
                        screen:add( self.group )
                        
                        self.shoots = true-- math.random( 100 ) < ENEMY_SHOOTER_PERCENTAGE
                    
                    end,
                    
                render =
                
                    function( self , seconds )
                    
                        -- Flip
                        
                        local x = self.image.x - self.image.w / 3
                        
                        if x == - self.image.w then
                        
                            x = 0
                            
                        end
                        
                        self.image.x = x
                        
                        -- Move
                        
                        local y = self.group.y + self.speed * seconds
                        
                        if y > screen.h then
                        
                            screen:remove( self.group )
                            
                            remove_from_render_list( self )
                            
                            self.enemies.count = self.enemies.count - 1
                        
                        else
                        
                            add_to_collision_list(
                                
                                self,
                                { self.group.x + self.group.w / 2 , self.group.y + self.group.h / 2 },
                                { self.group.x + self.group.w / 2 , y + self.group.h / 2 },
                                { self.group.w , self.group.h },
                                TYPE_MY_BULLET
                            )
                        
                            self.group.y = y
                            
                        end
                        
                        -- Shoot
                        
                        --if self.shoots then
                        local r = math.random()*2
                            self.last_shot_time = self.last_shot_time + seconds + r
                            --print(self.last_shot_time,self.shoot_time)
                            if self.last_shot_time >= self.shoot_time and math.random(1,20) == 8 then
                            
                                self.last_shot_time = self.last_shot_time - self.shoot_time - r
                                
                                local enemy = self
                                
                                local bullet =
                                    {
                                        speed = enemy.speed * 1.5,
                                        
                                        image = Clone{ source = assets.enemy_bullet , opacity = 255 },
                                        
                                        setup =
                                        
                                            function( self )
                                            
                                                self.image.anchor_point = { self.image.w / 2 , self.image.h / 2 }
                                                
                                                self.image.position = enemy.group.center
                                                
                                                self.image.y = self.image.y + 10
                                                
                                                --self.image.y = self.image.y + 10
                                                
                                                screen:add( self.image )
                                            
                                            end,
                                            
                                        render =
                                        
                                            function( self , seconds )
                                            
                                                local y = self.image.y + self.speed * seconds
                                                
                                                if y > screen.h then
                                                
                                                    remove_from_render_list( self )
                                                    
                                                    screen:remove( self.image )
                                                
                                                else
                                                
                                                    local start_point = self.image.center
                                                
                                                    self.image.y = y
                                                    
                                                    add_to_collision_list(
                                                    
                                                        self , start_point , self.image.center , { 4 , 4 } , TYPE_MY_PLANE
                                                    
                                                    )
                                                
                                                end
                                            
                                            end,
                                            
                                        collision =
                                        
                                            function( self , other )
                                            
                                                remove_from_render_list( self )
                                                
                                                screen:remove( self.image )
                                            
                                            end
                                    }
                                    
                                add_to_render_list( bullet )
                                
			else
				self.last_shot_time = self.last_shot_time - r
                            end
                        
                        --end
                    
                    end,
                    
                collision =
                
                    function( self , other )
                    
--[[
point_counter = point_counter+10
if point_counter > high_score then
	high_score = point_counter
end
if (point_counter % 1000) == 0 and lives[number_of_lives + 1] ~= nil then
	number_of_lives = number_of_lives + 1
	lives[number_of_lives].opacity =255
end
redo_score_text()
--]]
                        screen:remove( self.group )
                        
                        remove_from_render_list( self )
                        
                        self.enemies.count = self.enemies.count - 1
                        
                        -- Explode
                        
                        local enemy = self
                        
                        local explosion =
                            
                            {
                                image = Clone{ source = assets.explosion1 , opacity = 255 },
                                
                                group = nil,
                                
                                duration = 0.2, 
                                
                                time = 0,
                                
                                setup =
                                
                                    function( self )
                                    
                                        self.group = Group
                                            {
                                                size = { self.image.w / 6 , self.image.h },
                                                position = enemy.group.center,
                                                clip = { 0 , 0 , self.image.w / 6 , self.image.h },
                                                children = { self.image },
                                                anchor_point = { ( self.image.w / 6 ) / 2 , self.image.h / 2 }
                                            }
                                        
                                        screen:add( self.group )
                                        
                                    end,
                                    
                                render =
                                
                                    function( self , seconds )
                                    
                                        self.time = self.time + seconds
                                        
                                        if self.time > self.duration then
                                            
                                            remove_from_render_list( self )
                                            
                                            screen:remove( self.group )
                                        
                                        else
                                        
                                            local frame = math.floor( self.time / ( self.duration / 6 ) )
                                            
                                            self.image.x = - ( ( self.image.w / 6 ) * frame )
                                        
                                        end
                                    
                                    end,
                            }
                        
                        add_to_render_list( explosion )
                    
                    end,
            }
            
        end,
    
    -- Figure out if it is time to spawn a new enemy
    
    render =
    
        function( self , seconds )
        
            self.time = self.time + seconds
            
            if self.time >= self.enemy_seconds then
            
                if math.random(100) < 10 then
                
                    local image = self.images[ math.random( #self.images ) ]
                    
                    local speed = math.random( ENEMY_PLANE_MIN_SPEED , ENEMY_PLANE_MAX_SPEED )
                    
                    local count = 3
                    
                    local w = image.w / 3
                    
                    local left = math.random( 0 , screen.w - ( count * w ) )
                    
                    add_to_render_list( self:new_enemy( image , speed , { left , - image.h * 2 } ) )
                    add_to_render_list( self:new_enemy( image , speed , { left + w , - image.h } ) )
                    add_to_render_list( self:new_enemy( image , speed , { left + w * 2 , - image.h * 2 } ) )
                    
                    self.count = self.count + count
                
                else
            
                    add_to_render_list( self:new_enemy() )
                
                    self.count = self.count + 1
                    
                end
                
                self.time = self.time - self.enemy_seconds
            
            end
        
        end,
}

-------------------------------------------------------------------------------
-- This table contains all the things that are moving on the screen
function start_game()
add_to_render_list( my_plane )
end
add_to_render_list( water )

add_to_render_list( enemies )


paused = false

-------------------------------------------------------------------------------

screen:show()


-------------------------------------------------------------------------------
-- Game loop, renders everything in the render list

local c = 0
local t = 0
local ma = 0
local mi = 1000
local sw = Stopwatch()

function idle.on_idle( idle , seconds )

    if not paused then


	if false then

		c = c + 1
		ma = math.max( seconds , ma )
		mi = math.min( seconds , mi )

		t = t + seconds

		if sw.elapsed >= 1000 then
	
			print( mi , ma , t / c , string.format( "%1.0f" , 1 / ( t / c ) ) )

	
			t = 0
			c= 0
			sw:start()
			ma = 0
			mi = 1000
			
		end

    end

        for _ , item in ipairs( render_list ) do
       
            pcall( item.render , item , seconds ) 

        end
        
--        process_collisions( )
        
    end
    
end

-------------------------------------------------------------------------------
-- Event handler

function screen.on_key_down( screen , key )

    if not game_is_running then
        start_game()
	splash.opacity = 0
	game_is_running = true
	end_game.opacity = 0
	number_of_lives = 3
	point_counter = 0
	redo_score_text()
	lives[1].opacity=255
	lives[3].opacity=255
	lives[2].opacity=255
    elseif key == keys.space then
        
        paused = not paused
    elseif not paused then
    
        for _ , item in ipairs( render_list ) do
       
            pcall( item.on_key , item , key )
       
        end

    end
end

-------------------------------------------------------------------------------
function app:on_closing()
	settings.high_score = high_score
end
math.randomseed( os.time() )
