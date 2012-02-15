local duck_launcher = {}

local cursor, imgs, parent, anim_tracks, coll_box, hud -- upvals to be init-ed

local has_been_initialized = false

--helper functions
--------------------------------------------------------------------------------
local function falling_feather_animation(f)
    
    local a = Animator{
        duration = math.random(5000,8000),
        properties = {
            {
                source = f, name = "y",
                keys = {
                    {0.0,                   f.y     },
                    {0.05, "EASE_OUT_SINE", f.y-30  },
                    {0.1,  "EASE_IN_SINE",  f.y     },
                    {1.0,                   f.y+1000},
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
                    {0.0,                    0},
                    {0.1,                    0},
                    {0.2,  "EASE_OUT_SINE", 20},
                    {0.3,  "EASE_IN_SINE",   0},
                    {0.35, "EASE_OUT_SINE",-20},
                    {0.4,  "EASE_IN_SINE",   0},
                    {0.45, "EASE_OUT_SINE", 20},
                    {0.5,  "EASE_IN_SINE",   0},
                    {0.55, "EASE_OUT_SINE",-20},
                    {0.6,  "EASE_IN_SINE",   0},
                    {0.65, "EASE_OUT_SINE", 20},
                    {0.7,  "EASE_IN_SINE",   0},
                    {0.75, "EASE_OUT_SINE",-20},
                    {0.8,  "EASE_IN_SINE",   0},
                    {0.85, "EASE_OUT_SINE", 20},
                    {0.9,  "EASE_IN_SINE",   0},
                    {0.95, "EASE_OUT_SINE",-20},
                    {1.0,  "EASE_IN_SINE",   0},
                }
            },
        },
    }
    
    a.timeline.on_completed = function()
        
        a = nil
        
        f:unparent()
        
    end
    
    return a
    
end

local function flurry_of_feathers(duck)
    
    local fs = {}
    for i= 1, 20 do
        
        fs[i] = Clone{
            source = imgs.feathers[math.random(1,#imgs.feathers)],
            x = duck.x + math.random(-50,50),
            y = duck.y + math.random(-50,50),
            z = duck.z,
        }
        
        parent:add(fs[i])
        
        if math.random(1,10) < 2 then
            
            fs[i].anchor_point = { fs[i].w/2, -50 }
            fs[i].a = falling_feather_animation(fs[i])
            fs[i].a:start()
            
        else
            
            fs[i]:animate{
                
                duration = 300,
                
                x = fs[i].x + math.random(-300,300),
                y = fs[i].y + math.random(-300,300),
                z = fs[i].z - math.random(   0,300),
                
                z_rotation = math.random(0,90),
                opacity    = 0,
                
                on_completed = function()
                    
                    fs[i]:unparent()
                    
                end,
            }
            
        end
        
    end
end

local function make_splash(duck)
    
    mediaplayer:play_sound("audio/splash.mp3")
    
    local splash = Clone{
        source = imgs.splash,
        anchor_point = {
            imgs.splash.w/2,
            imgs.splash.h
        },
        scale = {1,0},
        x = duck.transformed_position[1]*screen_w / screen.transformed_size[1],
        y = screen_h-40,
    }
    
    parent:add(splash)
    
    splash:animate{
        duration = 150,
        scale    = {1,1.2},
        on_completed = function()
            
            splash:animate{
                duration = 300,
                scale = {1,0},
                on_completed = function()
                    
                    splash:unparent()
                    splash = nil
                    duck:remove_from_screen()
                    
                end
            }
            
        end
    }
    
end

--------------------------------------------------------------------------------
-- links the dependencies
--------------------------------------------------------------------------------
function duck_launcher:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    --dependencies
    parent = t.parent or error("must pass parent", 2)
    imgs   = t.imgs   or error("must pass imgs",   2)
    hud    = t.hud    or error("must pass hud",    2)
    
    --animation frames for the clone source timer to cycle through
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
            {imgs.duck.float[1], 2000},
            {imgs.duck.float[2],   20},
            {imgs.duck.float[3],   10},
            {imgs.duck.float[4],   10},
            {imgs.duck.float[5],   10},
            {imgs.duck.float[6], 2000},
            {imgs.duck.float[7],   50},
            {imgs.duck.float[8],  500},
            {imgs.duck.float[9],   50},
            {imgs.duck.float[10],  20},
            {imgs.duck.float[11],2000},
            death_frame = imgs.duck.float[7],
        },
    }
    
    --the collisions box spec for each type of duck
    coll_box = {
        side = {
            x = 60,
            y = 160,
            w = 250,
            h = 60,
            z_rotation = -20,
        },
        front = {
            x = 145,
            y = 90,
            w = 90,
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
            x = 25,
            y = 35,
            w = 90,
            h = 35,
            z_rotation = 0,
        },
    }
    
end

local active_ducks, old_ducks = {}, {}

local function make_new_duck()
    
    --the Clutter pieces of the duck
    local duck = Group{name="duck"}
    
    duck.img = Clone{name = "clone"}
    duck.coll_box = Rectangle{
        name      = "collision box",
        size      = {100,100},
        opacity   = 0,
        reactive  = true,
        on_button_down = function()
            if last_cursor:fire(true) then
                duck:die()
            end
            return true
        end
    }
    
    duck:add(duck.img, duck.coll_box)
    
    local source_i
    
    --called from the "launch duck" function, resets the index for the timer
    function duck:reset_source_i() source_i = -1 end
    
    --called when a duck finishes dieing or when a duck escapes
    function duck.remove_from_screen()
        duck.animation = nil
        duck:unparent()
        
        active_ducks[duck] = nil
        duck.clone_src_timer:stop()
        table.insert(old_ducks,duck)
        
    end
    
    --called when a duck gets shot
    function duck:die()
        hud:inc_birds_hit()
        
        if self.animation then
            self.animation.timeline:stop()
        else
            self:stop_animation()
        end
        duck.clone_src_timer:stop()
        
        --if close enough, duck explodes!!!
        if duck.z > -500 then
            
            duck.remove_from_screen()
            
            flurry_of_feathers(duck)
            
            
        else -- if far enough away, duck drops out of the sky and splashes
            
            duck.img.source = duck.anim_track.death_frame
            
            local death = Animator{
                duration = 700,
                properties = {
                    {
                        source = duck, name = "x",
                        keys = {
                            { 0.0, "EASE_OUT_CIRC", self.x },
                            { 1.0, "EASE_OUT_CIRC", self.x - 100}
                        }
                    },
                    {
                        source = duck, name = "y",
                        keys = {
                            { 0.0, "EASE_OUT_CIRC", self.y },
                            { 0.1, "EASE_OUT_CIRC", self.y -70},
                            { 1.0, "EASE_IN_CIRC",  3/2*screen_h}
                        }
                    },
                    {
                        source = duck, name = "opacity",
                        keys = {
                            { 0.0, "EASE_IN_QUINT", 255 },
                            { 1.0, "EASE_IN_QUINT", 0   }
                        }
                    },
                    {
                        source = duck, name = "z_rotation",
                        keys = {
                            { 0.0, 0 },
                            { 1.0, 45}
                        }
                    },
                },
            }
            death.timeline.on_completed = function()
                
                make_splash(duck)
                
                death = nil
                
            end
            
            death:start()
            
        end
        
    end
    
    --the timer that flips through the animation frames
    duck.clone_src_timer = Timer{
        interval = 100,
        on_timer = function(self)
            
            source_i = (source_i + 1 ) % #duck.anim_track
            
            duck.img.source = duck.anim_track[source_i+1][1]
            
            self.interval = duck.anim_track[source_i+1][2]
            
        end
    }
    
    duck.clone_src_timer:stop()
    
    
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
    
    
    
    return duck
    
end

local animate_to

local speed =  200 --px/s


--------------------------------------------------------------------------------
-- The possible flight paths / Animation frames for the ducks to have
--------------------------------------------------------------------------------
local duck_animation_setup = {
    ----------------------------------------------------------------------------
    -- Flying Up at an angle away from the screen
    ----------------------------------------------------------------------------
    function(duck)
        
        duck.anim_track = anim_tracks.angle
        
        duck.coll_box:set{
            x = coll_box.angle.x,
            y = coll_box.angle.y,
            w = coll_box.angle.w,
            h = coll_box.angle.h,
            z_rotation = {coll_box.angle.z_rotation,0,0}
        }
        
        
        local left = math.random(1,2) == 1
        
        --start values
        duck:set{
            x          = left and screen_w+50 or -50,
            y_rotation = left and {180,0,0}   or {0,0,0},
            z = 1,
            y = math.random(screen_h/2,screen_h),
        }
        
        
        --end values
        animate_to = {
            x = left and math.random(-4*screen_w,0) or math.random(screen_w,5*screen_w),
            y = math.random(-3000,400),
            z = -5000,
            on_completed = function()
                duck:animate{
                    duration = 500,
                    opacity = 0,
                    on_completed = function()
                        duck.remove_from_screen()
                    end
                }
            end
        }
        
        
        --duration is based on length traveled
        animate_to.duration =
            math.sqrt(
                math.pow(animate_to.x - duck.x,2) +
                math.pow(animate_to.y - duck.y,2)
            )  /  speed * 1000
        
        
        duck:animate(animate_to)
        
    end,
    ----------------------------------------------------------------------------
    -- Flying sideways and upwards
    ----------------------------------------------------------------------------
    function(duck)
        
        duck.anim_track = anim_tracks.side
        
        duck.coll_box:set{
            x = coll_box.side.x,
            y = coll_box.side.y,
            w = coll_box.side.w,
            h = coll_box.side.h,
            z_rotation = {coll_box.side.z_rotation,0,0}
        }
        
        local left = math.random(1,2) == 1
        
        --start values
        duck:set{
            x          = left and screen_w+50 or -200,
            y_rotation = left and {180,0,0}   or {0,0,0},
            z = 1,
            y = math.random(300,800),
        }
        --end values
        animate_to = {
            x = left and -50-screen_w or 2*screen_w+50,
            y = math.random(-2000,400),
            z = -500,
            on_completed = duck.remove_from_screen
        }
        
        --duration is based on length traveled
        animate_to.duration =
            math.sqrt(
                
                math.pow(animate_to.x - duck.x,2) +
                math.pow(animate_to.y - duck.y,2)
                
            )  /  (speed*2) * 1000
        
        duck:animate(animate_to)
        
    end,
    ----------------------------------------------------------------------------
    -- Flying towards the screen
    ----------------------------------------------------------------------------
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
        
        
        --start values
        duck:set{
            x = math.random(-10000,10000),
            y_rotation = {0,0,0},
            z = -10000,
            y = screen_h*2/3,
        }
        --end values
        duck:animate{
            duration = 10100/(speed*4) * 1000,
            x = math.random(100,screen_w-100),
            y = -50,
            z = 100,
            on_completed = duck.remove_from_screen
        }
        
        
    end,
    ----------------------------------------------------------------------------
    -- Floating, eating and turning around
    ----------------------------------------------------------------------------
    function(duck)
        
        duck.y_rotation = {0,0,0}
        
        duck.anim_track = anim_tracks.float
        
        duck.coll_box:set{
            x = coll_box.float.x,
            y = coll_box.float.y,
            w = coll_box.float.w,
            h = coll_box.float.h,
            z_rotation = {coll_box.front.z_rotation,0,0}
        }
        --duck.coll_box.anchor_point = {coll_box.angle.w/2,coll_box.angle.h/2}
        
        
        local left = math.random(1,2) == 1
        
        duck:set{
            x          = left and -50 or screen_w+50,
            y_rotation = left and {180,0,0}   or {0,0,0},
            z = 0,
            y = screen_h-40,
        }
        
        --a little hacky, this animates the duck floating in, and then back out,
        --the numbers must be updatad if the number of frames or the frame durations change
        duck.animation = Animator{
            duration = 6720,
            properties = {
                {
                    source = duck, name = "x",
                    keys = {
                        {0.0,duck.x},
                        {2000/6720,left and screen_w/5 or screen_w*4/5},
                        {4720/6720,left and screen_w/5 or screen_w*4/5},
                        {1.0,duck.x},
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
    
    hud:ducks_launched()
    
    --reuse an old duck or grab a new one
    duck_upval = table.remove(old_ducks) or make_new_duck()
    
    --set up its flight path / starting position
    duck_animation_setup[
        
        i or math.random(1,#duck_animation_setup)
        
    ](duck_upval)
    
    --set up all other start values
    duck_upval.opacity = 255
    duck_upval.z_rotation = {0,0,0}
    
    
    duck_upval.scale = {1,1}
    duck_upval.anchor_point = {
        duck_upval.anim_track[1][1].w/2,
        duck_upval.anim_track[1][1].h/2
    }
    
    --set up the clone-source timer
    duck_upval.clone_src_timer:start()
    duck_upval:reset_source_i()
    duck_upval.clone_src_timer:on_timer()
    
    
    active_ducks[duck_upval] = duck_upval
    
    parent:add(duck_upval)
    
    return duck_upval
    
end

return duck_launcher