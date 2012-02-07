local duck_launcher = {}

local cursor, imgs, parent, anim_tracks, coll_box

local has_been_initialized = false

function duck_launcher:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    print("duck launcher has been initialized")
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    imgs = t.imgs
    --animation tracks for the clone source timer
    anim_tracks = {
        side = {
            imgs.duck.side[1],
            imgs.duck.side[2],
        },
        front = {
            --imgs.duck.front[1],
            imgs.duck.front[2],
            imgs.duck.front[3],
            imgs.duck.front[4],
            imgs.duck.front[5],
            imgs.duck.front[4],
            imgs.duck.front[3],
            --imgs.duck.front[2],
        },
        angle = {
            imgs.duck.angle[1],
            imgs.duck.angle[2],
            imgs.duck.angle[3],
            imgs.duck.angle[4],
            imgs.duck.angle[3],
            imgs.duck.angle[2],
        }
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
    }
    
    parent = t.parent
    
end

local active_ducks, old_ducks = {}, {}

local function make_new_duck()
    
    local duck = Group()
    
    duck.img = Clone()
    duck.coll_box = Rectangle{size= {100,100},opacity = 100}
    duck.coll_box.reactive = true
    function duck.coll_box:on_button_down()
        if last_cursor:fire() then
            duck:die()
        end
        return true
    end
    
    duck:add(duck.img, duck.coll_box)
    
    local source_i = 0
    
    function duck.remove_from_screen()
        
        duck:unparent()
        
        active_ducks[duck] = nil
        
        table.insert(old_ducks,duck)
        
    end
    
    local death
    
    function duck:die()
        
        self:stop_animation()
        duck.clone_src_timer:stop()
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
                            { 0.0, "EASE_IN_CIRC", self.y },
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
                            { 1.0, -180}
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
                            { 0.0, "EASE_IN_CIRC", self.y },
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
                            { 1.0, 180}
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
        
    end
    
    duck.clone_src_timer = Timer{
        interval = 100,
        on_timer = function(self)
            
            source_i = (source_i + 1 ) % #duck.anim_track
            
            duck.img.source = duck.anim_track[source_i+1]
            
        end
    }
    
    function duck:stop()
        self:stop_animation()
    end
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
        animate_to.z = -500
        
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
        
        animate_to.duration = math.sqrt(math.pow(animate_to.x - duck.x,2) + math.pow(animate_to.y - duck.y,2))/(speed*1.5) * 1000
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
    
    duck_upval.anchor_point = {
        duck_upval.anim_track[1].w/2,
        duck_upval.anim_track[1].h/2
    }
    
    duck_upval.clone_src_timer:start()
    
    active_ducks[duck_upval] = duck_upval
    
    parent:add(duck_upval)
    
    return duck_upval
    
end

return duck_launcher