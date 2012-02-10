local duck_launcher = {}

local cursor, imgs, parent, anim_tracks, coll_box, hud

local has_been_initialized = false

function duck_launcher:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    print("duck launcher has been initialized")
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    imgs = t.imgs
    hud  = t.hud
    --animation tracks for the clone source timer
    anim_tracks = {
        side = {
            {imgs.duck.side[1],100},
            {imgs.duck.side[2],100},
            {imgs.duck.side[3],100},
            {imgs.duck.side[4],100},
            death_frame = imgs.duck.side[4],
        },
        front = {
            {imgs.duck.front[2], 50},
            {imgs.duck.front[3], 50},
            {imgs.duck.front[4], 50},
            {imgs.duck.front[5], 50},
            {imgs.duck.front[6], 25},
            death_frame = imgs.duck.front[1],
        },
        angle = {
            {imgs.duck.angle[1], 75},
            {imgs.duck.angle[2], 25},
            {imgs.duck.angle[3], 25},
            {imgs.duck.angle[4], 50},
            {imgs.duck.angle[5], 25},
            {imgs.duck.angle[6], 25},
            death_frame = imgs.duck.angle[5],
        },
        float = {
            {imgs.duck.float[1],2000},
            {imgs.duck.float[2],  20},
            {imgs.duck.float[3],  10},
            {imgs.duck.float[4],  10},
            {imgs.duck.float[5],  10},
            {imgs.duck.float[6],2000},
            {imgs.duck.float[7],  20},
            {imgs.duck.float[1],2000},
            death_frame = imgs.duck.angle[5],
        },
    }
    coll_box = {
        side = {
            x = 60,
            y = 160,
            w = 220,
            h = 60,
            z_rotation = -20,
        },
        front = {
            x = 145,
            y = 70,
            w = 70,
            h = 100,
            z_rotation = 0,
        },
        angle = {
            x = 85,
            y = 105,
            w = 70,
            h = 35,
            z_rotation = -20,
        },
        float = {
            x = 85,
            y = 105,
            w = 70,
            h = 35,
            z_rotation = 0,
        },
    }
    
    parent = t.parent
    
end

local active_ducks, old_ducks = {}, {}

local function make_new_duck()
    
    local duck = Group()
    
    duck.img = Clone()
    duck.coll_box = Rectangle{size= {100,100},opacity = 0}
    duck.coll_box.reactive = true
    function duck.coll_box:on_key_down(...)
        print("duck:on_key_down",...)
    end
    function duck.coll_box:on_button_down()
        if last_cursor:fire(true) then
            duck:die()
        end
        return true
    end
    
    duck:add(duck.img, duck.coll_box)
    
    local source_i = 0
    function duck:reset_source_i()
        source_i = -1
    end
    function duck.remove_from_screen()
        
        duck:unparent()
        
        active_ducks[duck] = nil
        
        table.insert(old_ducks,duck)
        
    end
    
    local death
    
    function duck:die()
        hud:inc_birds_hit()
        
        if self.animation then
            self.animation.timeline:stop()
        else
            self:stop_animation()
        end
        duck.clone_src_timer:stop()
        
        
        
        duck.remove_from_screen()
        
        for i= 1, 20 do
            
            local f = Clone{
                source = imgs.feathers[math.random(1,#imgs.feathers)],
                position = duck.position,
                z        = duck.z,
            }
            
            parent:add(f)
            
            if math.random(1,10) < 2 then
                
                f.x = f.x + math.random(-50,50)
                f.y = f.y + math.random(-50,50)
                local t = math.random(5000,8000)
                f.anchor_point = { f.w/2, -50 }
                t = Animator{
                    duration = t,
                    properties = {
                        {
                            source = f, name = "y",
                            keys = {
                                {0.0,duck.y},
                                {0.1,duck.y-100},
                                {1.0,duck.y+1000},
                            }
                        },
                        {
                            source = f, name = "x",
                            keys = {
                                {0.0,f.x},
                                {0.3,f.x+ math.random(-100,100)},
                            }
                        },
                        {
                            source = f, name = "opacity",
                            keys = {
                                {0.0,255},
                                {0.8,255},
                                {1.0,  0},
                            }
                        },
                        {
                            source = f, name = "z_rotation",
                            keys = {
                                {0.0,  0},
                                {0.1,  0},
                                {0.2, 20},
                                {0.3,-20},
                                {0.4, 20},
                                {0.5,-20},
                                {0.6, 20},
                                {0.7,-20},
                                {0.8, 20},
                                {0.9,-20},
                                {1.0,  0},
                            }
                        },
                    },
                }
                
                t.timeline.on_completed = function()
                    
                    f:unparent()
                    
                end
                
                t:start()
                --Timeline{
                --    duration = t,
                --    on_new_frame = function(tl,ms,p)
                --        
                --        f.z_rotation = {20*math.sin(math.pi*4*p),0,0}
                --        
                --    end,
                --    on_completed = function()
                --        
                --        f:unparent()
                --        
                --    end,
                --}:start()
            else
                f:animate{
                    duration = 300,
                    
                    x = f.x + math.random(-300,300),
                    y = f.y + math.random(-300,300),
                    z = f.z - math.random(   0,300),
                    
                    z_rotation = math.random(0,90),
                    opacity    = 0,
                    
                    on_completed = function()
                        
                        f:unparent()
                        
                    end,
                }
            end
        end
        
        --[[
        
        duck.img.source = duck.anim_track.death_frame
        if self.dir == "left" then
            
            death = Animator{
                duration = 1000,
                properties = {
                    {
                        source = self, name = "x",
                        keys = {
                            { 0.0, "EASE_OUT_CIRC", self.x },
                            { 1.0, "EASE_OUT_CIRC", self.x - 100}
                        }
                    },
                    {
                        source = self, name = "y",
                        keys = {
                            { 0.0, "EASE_OUT_CIRC", self.y },
                            { 0.2, "EASE_OUT_CIRC", self.y -70},
                            { 1.0, "EASE_IN_CIRC", 3*screen_h}
                        }
                    },
                    {
                        source = self, name = "opacity",
                        keys = {
                            { 0.0, "EASE_IN_QUINT", 255 },
                            { 1.0, "EASE_IN_QUINT", 0   }
                        }
                    },
                    {
                        source = self, name = "z_rotation",
                        keys = {
                            { 0.0, 0 },
                            { 1.0, 45}
                        }
                    },
                }
            }
            
            death.timeline.on_completed = function()
                death = nil
                duck:remove_from_screen()
            end
            
            death:start()
            
        else
            
            death = Animator{
                duration = 1000,
                properties = {
                    {
                        source = self, name = "x",
                        keys = {
                            { 0.0, "EASE_OUT_CIRC", self.x },
                            { 1.0, "EASE_OUT_CIRC", self.x + 100}
                        }
                    },
                    {
                        source = self, name = "y",
                        keys = {
                            { 0.0, "EASE_OUT_CIRC", self.y },
                            { 0.2, "EASE_OUT_CIRC", self.y -70},
                            { 1.0, "EASE_IN_CIRC", 3*screen_h}
                        }
                    },
                    {
                        source = self, name = "opacity",
                        keys = {
                            { 0.0, "EASE_IN_QUINT", 255 },
                            { 1.0, "EASE_IN_QUINT", 0   }
                        }
                    },
                    {
                        source = self, name = "z_rotation",
                        keys = {
                            { 0.0, 0 },
                            { 1.0, -45}
                        }
                    },
                }
            }
            
            death.timeline.on_completed = function()
                death = nil
                duck:remove_from_screen()
            end
            
            death:start()
            
            
        end
        --]]
    end
    
    duck.clone_src_timer = Timer{
        interval = 100,
        on_timer = function(self)
            
            source_i = (source_i + 1 ) % #duck.anim_track
            
            duck.img.source = duck.anim_track[source_i+1][1]
            
            self.interval = duck.anim_track[source_i+1][2]
            
        end
    }
    
    function duck:stop()
        self:stop_animation()
    end
    
    --[[ code that figures out if a point is in the collision box of the duck
    function duck:contains(px,py)
        
        local rx = self.x - self.anchor_point[1] + self.coll_box.x
        local ry = self.y - self.anchor_point[2] + self.coll_box.y
        
        local rw = self.coll_box.w
        local rh = self.coll_box.h
        
        local dx = px - rx
        local dy = py - ry
        
        local h1 = math.sqrt(dx*dx + dy*dy)
        
        local currA = math.atan2(dy,dx)
        
        local newA = currA - math.rad(self.coll_box.z_rotation[1])
        
        local x2 = math.cos(newA) * h1
        local y2 = math.sin(newA) * h1
        return (x2 > 0 and x2 < rw and y2 > 0 and y2 < rh)
        
        
    end
    --]]
    
    duck.clone_src_timer:stop()
    
    return duck
    
end

local animate_to = {}

local speed =  200 --px/s

local duck_animation_setup = {
    function(duck)
        
        duck.anim_track = anim_tracks.angle
        
        duck.coll_box:set{
            x = coll_box.angle.x,
            y = coll_box.angle.y,
            w = coll_box.angle.w,
            h = coll_box.angle.h,
            z_rotation = {coll_box.angle.z_rotation,0,0}
        }
        --duck.coll_box.anchor_point = {coll_box.angle.w/2,coll_box.angle.h/2}
        --go right to left
        if math.random(1,2) == 1 then
            
            duck.y_rotation = {180,0,0}
            
            duck.x = screen_w+50
            animate_to.x = -50-screen_w
            
            duck.dir = "left"
            
        --go left to right
        else
            
            duck.y_rotation = {0,0,0}
            
            duck.x = -50
            animate_to.x = 2*screen_w+50
            
            duck.dir = "right"
            
        end
        
        duck.y = screen_h - math.random(0,400)
        animate_to.y = duck.y - math.random(600,screen_h+100)
        
        duck.z = 1
        animate_to.z = -5000
        
        animate_to.duration = math.sqrt(math.pow(animate_to.x - duck.x,2) + math.pow(animate_to.y - duck.y,2))/speed * 1000
        animate_to.mode = "LINEAR"
        animate_to.on_completed = duck.remove_from_screen
        
        duck:animate(animate_to)
        
    end,
    function(duck)
        
        duck.anim_track = anim_tracks.side
        
        duck.coll_box:set{
            x = coll_box.side.x,
            y = coll_box.side.y,
            w = coll_box.side.w,
            h = coll_box.side.h,
            z_rotation = {coll_box.side.z_rotation,0,0}
        }
        --duck.coll_box.anchor_point = {coll_box.angle.w/2,coll_box.angle.h/2}
        
        --go right to left
        if math.random(1,2) == 1 then
            
            duck.y_rotation = {180,0,0}
            
            duck.x = screen_w+50
            animate_to.x = -50-screen_w
            
            duck.dir = "left"
            
        --go left to right
        else
            
            duck.y_rotation = {0,0,0}
            
            duck.x = -200
            animate_to.x = 2*screen_w+50
            
            duck.dir = "right"
            
        end
        
        duck.y = screen_h - math.random(300,600)
        animate_to.y = duck.y - math.random(300,400)
        
        duck.z = 1
        animate_to.z = -500
        
        animate_to.duration = math.sqrt(math.pow(animate_to.x - duck.x,2) + math.pow(animate_to.y - duck.y,2))/(speed*2) * 1000
        animate_to.mode = "LINEAR"
        animate_to.on_completed = duck.remove_from_screen
        
        duck:animate(animate_to)
        
    end,
    function(duck)
        
        duck.y_rotation = {0,0,0}
        
        duck.anim_track = anim_tracks.front
        
        duck.coll_box:set{
            x = coll_box.front.x,
            y = coll_box.front.y,
            w = coll_box.front.w,
            h = coll_box.front.h,
            z_rotation = {coll_box.front.z_rotation,0,0}
        }
        --duck.coll_box.anchor_point = {coll_box.angle.w/2,coll_box.angle.h/2}
        
        duck.x = screen_w/2 + math.random(-300,300)
        animate_to.x = screen_w/2 + math.random(-300,300)
        
        if animate_to.x > duck.x then
            
            duck.dir = "left"
            
        else
            
            duck.dir = "right"
            
        end
        
        duck.y = screen_h*2/3
        animate_to.y = -50
        
        duck.z = -10000
        animate_to.z = 100
        
        animate_to.duration = math.sqrt(math.pow(animate_to.x - duck.x,2) + math.pow(animate_to.y - duck.y,2))/(speed/2) * 1000
        animate_to.mode = "LINEAR"
        animate_to.on_completed = duck.remove_from_screen
        
        duck:animate(animate_to)
        
    end,
    function(duck)
        
        duck.y_rotation = {0,0,0}
        
        duck.anim_track = anim_tracks.float
        
        duck.coll_box:set{
            x = coll_box.front.x,
            y = coll_box.front.y,
            w = coll_box.front.w,
            h = coll_box.front.h,
            z_rotation = {coll_box.front.z_rotation,0,0}
        }
        --duck.coll_box.anchor_point = {coll_box.angle.w/2,coll_box.angle.h/2}
        
        duck.x = screen_w
        
        duck.dir = "left"
        
        duck.y = screen_h-50
        
        duck.z = 0
        
        duck.animation = Animator{
            duration = 6070,
            properties = {
                {
                    source = duck, name = "x",
                    keys = {
                        {0.0,duck.x},
                        {2000/6070,screen_w*2/3},
                        {4070/6070,screen_w*2/3},
                        {1.0,screen_w},
                    }
                },
            }
        }
        duck.animation.timeline.on_completed = duck.remove_from_screen
        
        duck.animation:start()
        
    end,
}

local duck_upval

function duck_launcher:launch_duck(i)
    
    if not has_been_initialized then error("Must initialize",2) end
    
    duck_upval = table.remove(old_ducks) or make_new_duck()
    
    duck_upval.opacity = 255
    duck_upval.z_rotation = {0,0,0}
    
    duck_animation_setup[
        
        i or math.random(1,#duck_animation_setup)
        
    ](duck_upval)
    
    duck_upval.scale = {1,1}
    duck_upval.anchor_point = {
        duck_upval.anim_track[1][1].w/2,
        duck_upval.anim_track[1][1].h/2
    }
    
    duck_upval.clone_src_timer:start()
    duck_upval.clone_src_timer:on_timer()
    duck_upval:reset_source_i()
    active_ducks[duck_upval] = duck_upval
    
    parent:add(duck_upval)
    
    return duck_upval
    
end

return duck_launcher