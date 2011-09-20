--the different angles of the Gallardo
local images = {
    Assets:source_from_src("assets/Lambo/00.png"),
    Assets:source_from_src("assets/Lambo/01.png"),
}

local tail_lights = Assets:Clone{
    name="brake lights",
    src="assets/Lambo/brake.png",
    --source=images.tail_lights,
    position={
        screen.w/2,
        5*screen.h/6+63
    },
    opacity=0
}
tail_lights.anchor_point = {tail_lights.w/2,tail_lights.h/2}
--Create the global user car
local user_car = Clone{
    
    name     = "THE CAR",
    source   = images[1],
    position = {
        screen.w/2,
        5*screen.h/6
    },
    anchor_point = {
        images[1].w/2,
        images[1].h/2
    },
    extra = {
        v_x     = 0,
        v_y     = 0,
        crashed = false,
        dx      = 960,
    }
}

local flipped_dirt = 1

local dirt1 = Assets:Clone{
    src = "assets/dirt/dirt1.png",
    x=user_car.x-120,
    y=user_car.y+120,
    --scale={1.5,1},
    opacity = 0,
}

dirt1.anchor_point = {dirt1.w/2,dirt1.h/2}

local dirt2 = Assets:Clone{
    src = "assets/dirt/dirt2.png",
    x=user_car.x+120,
    y=user_car.y+120,
    --scale={1.5,1},
    opacity = 0,
}

dirt2.anchor_point = {dirt2.w/2,dirt2.h/2}

local reset_car = function(old_state,new_state)
        --called together in order to garuntee order
        world:reset()
        user_car.crashed = false
        user_car.v_x     = 0
        user_car.v_y     = 0
        user_car.dx      = 960
        user_car:set_curr_path(road.curr_segment)
    end
Game_State:add_state_change_function(
    reset_car,
    STATES.CRASH,
    STATES.PLAYING
)
Game_State:add_state_change_function(
    reset_car,
    STATES.SPLASH,
    STATES.PLAYING
)

-- optimize primary functions, by using do-ends to isolate upvals



--Function for updating velocities based on user input
do
    --[[
    local accel_rates = {
        30/1.71,
        60/4.13,
        100/9.02,
        200/24,
    }
    --]]
    --current rate
    local curr_accel_rate = 0
    
    local acceleration_from_velocity = function(self)
        
        if     self.v_y > 200*PIXELS_PER_MILE then self.v_y        = 200*PIXELS_PER_MILE
        elseif self.v_y <   0                 then self.v_y        = 0
        end
        
        --Gallardo reaches 200 mph in 30 seconds
        ----using sin to simulate reduction in acceleration at higher speeds
        --
        --v(t) = 200*sin(pi/2*t/30)
        --a(t) = ddx v(t)
        --a(t) = 10/3*pi*cos(pi*t/60)
        --
        --invert v(t)
        --t = 60/pi*asin(v/200)
        --
        --plug into a(t):
        --a = 10/3*pi*cos(pi*(60/pi*asin(v/200))/60)
        
        curr_accel_rate =
            10/3*math.pi*math.cos(
                math.pi*(60/math.pi*math.asin(
                    self.v_y/(200*PIXELS_PER_MILE)
                ))/60
            )
        --print(self.v_y,curr_accel_rate)
        --[[
        if     self.v_y > 200*PIXELS_PER_MILE then self.v_y        = 200*PIXELS_PER_MILE
                                                   curr_accel_rate = accel_rates[4]
        elseif self.v_y > 100*PIXELS_PER_MILE then curr_accel_rate = accel_rates[4]
        elseif self.v_y >  60*PIXELS_PER_MILE then curr_accel_rate = accel_rates[3]
        elseif self.v_y >  60*PIXELS_PER_MILE then curr_accel_rate = accel_rates[3]
        elseif self.v_y >  30*PIXELS_PER_MILE then curr_accel_rate = accel_rates[2]
        elseif self.v_y >   0                 then curr_accel_rate = accel_rates[1]
        elseif self.v_y <   0                 then self.v_y        = 0
                                                   curr_accel_rate = accel_rates[1]
        end
        --]]
    end
    user_car.driver_io= function(self,msecs)
        --update y-velocity
        self.v_y = self.v_y + PIXELS_PER_MILE*curr_accel_rate*msecs/1000 +
            io.throttle_position*20*PIXELS_PER_MILE*msecs/1000
        
        --update y-acceleration
        acceleration_from_velocity(user_car)
        
        
        
        --turn on tail lights if braking, decay the io.throttle_position
        if io.throttle_position < 0 then
            io.throttle_position = io.throttle_position + 20*msecs/1000
            tail_lights.opacity = 255
        else
            io.throttle_position = 0
            tail_lights.opacity = 0
        end
        
        --update x-velocity
        self.v_x = self.v_y/5*io.turn_impulse --+ self.v_x
        
        self.dx = self.dx + self.v_x*msecs/1000
        
        --if on or beyond the shoulder,
        --then your car receives heavy resistance
        if math.abs(self.dx) > STRAFE_CAP then
            self.v_y = self.v_y - 4*msecs
            if self.v_y < 800 then
                self.v_y = 800
            end
        end
        
        --decay
        if io.turn_impulse > 0 then
            if io.turn_impulse > .5 then
                self.source = images[2]
                self.y_rotation={0,0,0}
            else
                self.source = images[1]
                self.y_rotation={0,0,0}
            end
            io.turn_impulse = io.turn_impulse-2*msecs/1000
            if io.turn_impulse < 0 then
                io.turn_impulse = 0
            end
        else
            if io.turn_impulse < -.5 then
                self.source = images[2]
                self.y_rotation={180,0,0}
            else
                self.source = images[1]
                self.y_rotation={0,0,0}
            end
            io.turn_impulse = io.turn_impulse+2*msecs/1000
            if io.turn_impulse > 0 then
                io.turn_impulse = 0
            end
        end
    end
end

do
    
    local dy,dr
    
    
    local curr_path            = nil
    local dy_remaining_in_path = 0
    local dr_remaining_in_path = 0
    local dist_in_dirt = 0
    local played_dirt = false
    user_car.update_position_on_path=function(self,msecs)
        assert(road.curr_segment ~= nil)
        --update distance from the center of the road
        
        dy = self.v_y*msecs/1000
        dr = curr_path.rot*dy/curr_path.dist --relative to amount travelled
        
        self.dx = self.dx - dr*50
        
        
        if math.abs(self.dx) > STRAFE_CAP then
            
            dist_in_dirt = dist_in_dirt + dy
            self.z_rotation = {sin(dist_in_dirt)/2,0,0}
            
            if not played_dirt then
                played_dirt = true
                mediaplayer:load("audio/inditch.wav")
                dirt1.opacity = 255
                dirt2.opacity = 255
                --mediaplayer:play_sound("audio/inditch.wav")
            end
            
            if dist_in_dirt > 100 then
                dirt1.x = screen_w/2+flipped_dirt*120
                dirt2.x = screen_w/2-flipped_dirt*120
                
                flipped_dirt = -flipped_dirt
                dist_in_dirt = 0
            end
            --[[
            if self.v_y > 30*PIXELS_PER_MILE and dist_in_dirt > 1000 then
                dist_in_dirt = 0
                
                local dirt_shpeckle = Assets:Clone{
                    src = "assets/dirt/s1.png",
                    x=user_car.x,
                    y=user_car.y
                }
                
                dirt_shpeckle.anchor_point = {dirt_shpeckle.w/2,dirt_shpeckle.h/2}
                dirt_shpeckle.v_y = math.random(30,60)
                
                screen:add(dirt_shpeckle)
                
                user_car:raise_to_top()
                print("oh shit")
                Idle_Loop:add_function(
                    function(self,msecs,p)
                        self.x = screen_w/2+(screen_w/2+100)*p
                        self.y = self.y + msecs/1000*self.v_y
                        if p == 1 then
                            self:unparent()
                        end
                    end,
                    dirt_shpeckle,
                    2000
                )
            end
            --]]
        else
            if played_dirt then
                mediaplayer:pause()
                mediaplayer:seek(0)
                dirt1.opacity = 0
                dirt2.opacity = 0
                dist_in_dirt = 0
                self.z_rotation = {0,0,0}
            end
            played_dirt = false
            
        end
        
        
        
        Game_State.points = Game_State.points + self.v_y*msecs/1000/(PIXELS_PER_MILE*10)
        hud:update(self.v_y/pixels_per_mile,Game_State.points)
        
        while dy_remaining_in_path < dy do
            --move by whatever distance is left in the current path segment
            world:move(
                dy_remaining_in_path,
                self.dx,
                dr_remaining_in_path,
                curr_path.radius
            )
            
            --move onto the next path segment
            road.curr_segment = road.curr_segment.next_segment
            curr_path = road.segments[road.curr_segment]
            --re-adjust the path center to compensate for rounding error
            world:normalize_to(curr_path.parent)
            
            --update the amount of remaining distance to cover
            dy = dy - dy_remaining_in_path
            dr = curr_path.rot*dy/curr_path.dist
            
            --set the amount of distance there is to cover in this path segment
            dy_remaining_in_path = curr_path.dist
            dr_remaining_in_path = curr_path.rot
            
        end
        
        --move by the incremental amount
        world:move(dy,self.dx,dr,curr_path.radius)
        
        --decrement the remaining by the amount travelled
        dy_remaining_in_path = dy_remaining_in_path - dy
        dr_remaining_in_path = dr_remaining_in_path - dr
    end
    
    user_car.post_collision = function(self,msecs)
        self.dx = self.dx + self.v_x*msecs/1000
        dy = self.v_y*msecs/1000
        
        world:move(dy,self.dx,0,0)
        
        if self.v_x > 0 then
            self.v_x = self.v_x - 10 * msecs
            if self.v_x < 1 then
                self.v_x = 1
            end
        else
            self.v_x = self.v_x + 10 * msecs
            if self.v_x > -1 then
                self.v_x = -1
            end
        end
        
        if self.v_y > 0 then
            self.v_y = self.v_y - 10 * msecs
            if self.v_y < 1 then
                self.v_y =  1
            end
        else
            self.v_y = self.v_y + 10 * msecs
            if self.v_y > -1 then
                self.v_y = -1
            end
        end
    end
    
    --method to initialize the upvals
    user_car.set_curr_path = function(self,curr_segment)
        curr_path = road.segments[curr_segment]
        dumptable(curr_path)
		dy_remaining_in_path = curr_path.dist
		dr_remaining_in_path = curr_path.rot
    end
end
--[[
local idling = false
mediaplayer.on_loaded = mediaplayer.play
mediaplayer.on_end_of_stream = function()
    if user_car.v_y >= 190*PIXELS_PER_MILE and not idling then
        mediaplayer:load("audio/car_idle.wav")
    else
        mediaplayer:seek(0)
        mediaplayer:play()
    end
end
--]]
Game_State:add_state_change_function(
    function(old_state,new_state)
        Idle_Loop:add_function(user_car.driver_io,user_car)
        Idle_Loop:add_function(user_car.update_position_on_path,user_car)
        
        --mediaplayer:load("audio/loud01.wav")
    end,
    nil,
    STATES.PLAYING
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        Idle_Loop:remove_function(user_car.driver_io)
        Idle_Loop:remove_function(user_car.update_position_on_path)
    end,
    STATES.PLAYING,
    nil
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        Idle_Loop:add_function(user_car.post_collision,user_car)
        mediaplayer:play_sound("audio/car_brake.wav")
    end,
    nil,
    STATES.CRASH
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        Idle_Loop:remove_function(user_car.post_collision)
    end,
    STATES.CRASH,
    nil
)
screen:add(user_car,tail_lights,dirt1,dirt2)

return user_car