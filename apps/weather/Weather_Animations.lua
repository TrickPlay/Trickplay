
time_of_day = "DAY"

local active_tl_s   = {}
local active_timers = {}

--------------------------------------------------------------------------------
-- Sun                                                                        --
--------------------------------------------------------------------------------


local sun_state 
do
    local sun_g = Group{x=-16,y=screen_h}
    
    local flare = {}
    
    flare[1] = Clone{source=imgs.sun.flare[1]}
    flare[2] = Clone{source=imgs.sun.flare[2]}
    flare[3] = Clone{source=imgs.sun.flare[3]}
    base     = Clone{source=imgs.sun.base}
    
    sun_g:add(
        flare[3],
        base,
        flare[2],
        flare[1]
    )
    
    for _,v in ipairs(flare) do
        v:move_anchor_point(v.w/2,v.h/2)
        v.position={v.w/2,v.h/2}
    end
    
    base:move_anchor_point(base.w/2,base.h/2)
    base.position={base.w/2,base.h/2}
    
    local s1,s2,s3
    local amp = .05
    
    sun_g.shine = Timeline{
        duration=160000,
        loop=true,
        on_new_frame = function(tl,ms,p)
            s1 = math.sin(6*math.pi*p)
            s2 = math.sin(6*math.pi*p+2*math.pi/3)
            s3 = math.sin(6*math.pi*p+4*math.pi/3)
            
            
            --pulse the size
            flare[1].scale={.95+amp*s1,.95+amp*s1}
            --this_obj.flare[2].scale={.95+amp*s2,.95+amp*s2}
            --this_obj.flare[3].scale={.95+amp*s3,.95+amp*s3}
            
            
            --pulse the opacity
            flare[1].opacity=255*(.8+4*amp*s2)
            flare[2].opacity=255*(.4+4*amp*s3)
            --this_obj.flare[3].opacity=255*(.8+amp*s1)
            
            
            --rotate the flares
            flare[1].z_rotation={ 360*p,0,0}
            flare[2].z_rotation={-360*p,0,0}
            flare[3].z_rotation={ 720*p,0,0}
        end,
    }
    
    sun_state = AnimationState{
        transitions = {
            {
                source = "*",
                target = "SET",
                keys = {
                    {sun_g,"y","EASE_IN_SINE",screen_h},
                },
            },
            {
                source = "*",
                target = "HALF",
                keys = {
                    {sun_g,"opacity",255*.5},
                    {sun_g,"y","EASE_OUT_SINE",709},
                },
            },
            {
                source = "*",
                target = "FULL",
                keys = {
                    {sun_g,"opacity",255},
                    {sun_g,"y","EASE_IN_SINE",709},
                },
            },
        },
    }
    sun_state.state = "SET"
    
    sun_state.timeline.on_started = function()
        if sun_state.state ~= "SET" then
            if sun_g.parent == nil then
                curr_condition:add(sun_g)
            end
            sun_g.shine:start()
        end
    end
    
    sun_state.timeline.on_completed = function()
        if sun_state.state == "SET" then
            sun_g.shine:pause()
            sun_g:unparent()
        end
    end
    
    function sun_state:next_state(s)
        
        sun_state.state = s
        
    end
    
end
 




--------------------------------------------------------------------------------
-- Moon                                                                       --
--------------------------------------------------------------------------------


local moon_state
do
    
    local moon_g = Group{x=0,y=709}
    
    local stars = Clone{ source=imgs.stars,opacity=0}
    local star  = Clone{ source=imgs.star, opacity=0,x=10,y=100}
    local moon  = Clone{ source=imgs.moon, x=38, y=63 + (screen_h-709) }
    
    moon_g:add(stars,star,moon)
    
    moon_g.twinkle = Timer{
        interval = 3000,
        on_timer = function()
            
            star.position = {
                math.random(10,stars.w),
                math.random( 0,stars.h)
            }
            
            star:animate{
                duration = 100,
                mode     = "EASE_OUT_SINE",
                opacity  = 255,
                on_completed = function()
                    
                    star:animate{
                        duration = 100,
                        mode     = "EASE_IN_SINE",
                        opacity  = 0,
                    }
                    
                end
            }
            
            
        end
    }
    moon_g.twinkle:stop()
    
    
    moon_state = AnimationState{
        duration=2000,
        transitions = {
            {
                source = "*",
                target = "SET",
                keys = {
                    {moon,"y","EASE_IN_SINE",63 + (screen_h-709)},
                    {stars,"opacity",0},
                },
            },
            {
                source = "*",
                target = "RISEN",
                keys = {
                    {moon,"y","EASE_OUT_SINE",63},
                    {stars,"opacity",255},
                },
            },
        }
    }
    moon_state.state = "SET"
    
    moon_state.timeline.on_started = function()
        if moon_state.state ~= "SET" then
            if moon_g.parent == nil then
                curr_condition:add(moon_g)
            end
            moon_g.twinkle:start()
        end
    end
    
    moon_state.timeline.on_completed = function()
        if moon_state.state == "SET" then
            moon_g.twinkle:stop()
            moon_g:unparent()
        end
    end
    
    function moon_state:next_state(s)
        
        moon_state.state = s
        
    end
    
end





--------------------------------------------------------------------------------
-- ThunderStorms                                                              --
--------------------------------------------------------------------------------


local tstorm_state
do
    
    local tstorm_g = Group{}
    
    --clouds
    local glow_cloud = Clone{source=imgs.glow_cloud,y=650,opacity=0}
    local base_cloud = Clone{source=imgs.rain_clouds.lg[1],y=650}
    base_cloud.x = -base_cloud.w
    
    
    --rain
    local flip = false
    
    local rain = {}
    
    local rain_y = 765
    
    local rain_h = imgs.rain.falling.h
    local launch_i = 1
    local duration
    local rain_launcher = Timer{
        interval = 100,
        on_timer = function(self)
            if launch_i > #rain then
                self:stop()
            else
                curr_condition:add(rain[launch_i])
                rain[launch_i]:lower_to_bottom()
                rain[launch_i].y = rain_y
                duration = self.interval*#rain
                rain[launch_i]:animate{
                    duration = duration > 0 and duration or 1,
                    loop = true,
                    y = screen_h,
                }
                launch_i = launch_i + 1
            end
        end
    }
    rain_launcher:stop()
    
    for i = 1, 2*math.ceil((screen_h - rain_y) / rain_h) do
        
        flip = not flip
        
        local r
        
        r = Group{
            opacity=255*.5,
            y = rain_y,
            children = {
                Clone{
                    source = imgs.rain.falling,
                    x = flip and -30 + imgs.rain.falling.w or -30,
                    y_rotation = flip and {180,0,0} or nil,
                },
                Clone{
                    source = imgs.rain.falling,
                    x = flip and 221-30 + imgs.rain.falling.w or 221-30,
                    y_rotation = flip and {180,0,0} or nil,
                },
            },
            extra = {
                unparent_no_param = function()
                    r:unparent()
                end
            }
        }
        
        rain[i] = r
        
    end
    
    local lightning = {}
    
    --lightning
    for i = 1,#imgs.lightning do
        lightning[i]   = Clone{source=imgs.lightning[i],opacity=0}
        lightning[i].y = screen_h - lightning[i].h*2/3
    end
    
    lightning_index = 1
    
    zeus = Timer{
        
        interval = 4000,
        
        on_timer = function()
            
            --light up
            lightning[lightning_index].opacity = 255
            glow_cloud.opacity=255
            --light down
            dolater(100,function()
                --TODO: insert flag to stop it if fading out
                lightning[lightning_index].opacity = 0
                glow_cloud.opacity=0
                lightning_index = lightning_index%#lightning+1
                
            end)
            
        end
    }
    zeus:stop()
    
    function tstorm_g:add_to_curr_condition()
        curr_condition:add(unpack(lightning))
        curr_condition:add(base_cloud,glow_cloud)
    end

    local duration

    function tstorm_g:stop_rain()
        for i = 1, #rain do
            
            
            if rain[i].parent then
                duration = rain_launcher.interval*#rain * ((1+screen_h-rain[i].y)/(screen_h-rain_y))
                rain[i]:stop_animation()
                rain[i]:animate{
                    duration = duration > 0 and duration or 1,
                    y = screen_h,
                    on_completed = rain[i].unparent_no_param
                }
            end
        end
    end
    function tstorm_g:remove_to_curr_condition()
        glow_cloud:unparent()
        base_cloud:unparent()
        
        --self.glow_cloud = nil
        --self.base_cloud = nil
        
        for i = 1, #lightning do
            lightning[i]:unparent()
            --self.lightning[i] = nil
        end
    end
    
    local old_drops = {}
    
    local r
    
    --TODO figure out how many are needed, and how to launch them with looped animates
    
    
    
    
    
    tstorm_state = AnimationState{
        duration=400,
        transitions = {
            {
                source = "*",
                target = "OFF",
                keys = {
                    {base_cloud,"x",-base_cloud.w},
                    {glow_cloud,"opacity",0},
                },
            },
            {
                source = "*",
                target = "ON",
                keys = {
                    {base_cloud,"x",0},
                },
            },
        }
    }
    
    tstorm_state.state = "OFF"
    
    tstorm_state.timeline.on_started = function()
        if tstorm_state.state == "ON" then
            tstorm_g:add_to_curr_condition()
        else
            zeus:stop()
            rain_launcher:stop()
            tstorm_g:stop_rain()
        end
    end
    
    tstorm_state.timeline.on_completed = function()
        if tstorm_state.state == "OFF" then
            tstorm_g:remove_to_curr_condition()
        elseif tstorm_state.state == "ON" then
            zeus:start()
            rain_launcher:start()
            launch_i = 1
        end
    end
    
    function tstorm_state:next_state(s)
        
        tstorm_state.state = s
        
    end
    
end





--------------------------------------------------------------------------------
-- Clouds                                                                     --
--------------------------------------------------------------------------------



local cloud_state
do
    
    local active_clouds = {}
    
    local cloud --upval
    
    local old_small_clouds = {}
    local old_large_clouds = {}
    
    local sm_cloud_count = 0
    local lg_cloud_count = 0
    
    local make_small_cloud = function()
        
        sm_cloud_count = sm_cloud_count + 1
        
        local cloud = Clone{
            name    = "small_cloud # "..sm_cloud_count,
            x       = 0,
        }
        
        local animation = Animator{
            duration = 40000,
            properties = {
                {
                    source = cloud, name   = "opacity",
                    keys   = {
                        {0.8, "LINEAR", 255},
                        {1.0, "LINEAR",   0},
                    }
                },
                {
                    source = cloud, name   = "x",
                    keys   = {
                        {0.0, "LINEAR", -cloud.w},
                        {1.0, "LINEAR", 230},
                    }
                },
            }
        }
        
        animation.timeline.on_completed = function()
            active_clouds[cloud] = nil
            table.insert(old_small_clouds,cloud)
            cloud:unparent()
        end
        
        function cloud:hurry_out()
            
            animation.timeline:stop()
            
            cloud:animate{
                duration = 200,
                opacity  = 0,
                on_completed = animation.timeline.on_completed
            }
            
        end
        
        function cloud:start()
            self.x       = 0
            self.y       = 850+math.random(0,100)
            self.opacity = 255
            animation:start()
        end
        
        return cloud
        
    end
    
    local make_large_cloud = function()
        
        lg_cloud_count = lg_cloud_count + 1
        
        local cloud = Clone{
            name    = "lg_cloud # "..lg_cloud_count,
            x       = 40,
            opacity = 0
        }
        
        local animation = Animator{
            duration = 60000,
            properties = {
                {
                    source = cloud,
                    name   = "opacity",
                    keys   = {
                        {0.0, "LINEAR",   0},
                        {0.1, "LINEAR", 255},
                    }
                },
                {
                    source = cloud,
                    name   = "x",
                    keys   = {
                        {0.0, "LINEAR",  40},
                        {1.0, "LINEAR", -450},
                    }
                },
            }
        }
        
        animation.timeline.on_completed = function()
            active_clouds[cloud] = nil
            table.insert(old_large_clouds,cloud)
            cloud:unparent()
        end
        
        function cloud:hurry_out()
            ---[[
            animation.timeline:stop()
            
            cloud:animate{
                duration = 200,
                opacity  = 0,
                on_completed = animation.timeline.on_completed
            }
            --]]
            
            --local p = cloud.animation.timeline.progress
            --cloud.animation.timeline.duration = 500
            
        end
        
        function cloud:start()
            self.x       = 40
            self.y       = 670+math.random(0,150)
            self.opacity = 0
            
            animation:start()
        end
        
        return cloud
        
    end
    
    local large_cloud_launcher = Timer{
        
        interval = 30000, --this value gets changed by the ENUM
        
        on_timer = function(self)
            
            cloud = table.remove(old_large_clouds) or make_large_cloud()
            
            --set out here so that 
            cloud.source = imgs.reg_clouds.lg[
                
                math.random(1,#imgs.reg_clouds.lg)
                
            ]
            
            cloud.y = 670+math.random(0,150)
            
            curr_condition:add(cloud)
            
            active_clouds[cloud] = cloud
            
            cloud:start()
            
        end
        
    }
    
    large_cloud_launcher:stop()
    
    local small_cloud_launcher = Timer{
        
        interval = 40000,
        
        on_timer = function(self)
            
            cloud = table.remove(old_small_clouds) or make_small_cloud()
            
            --set out here so that its not the same 2 clouds circling around
            cloud.source  = imgs.reg_clouds.sm[
                
                math.random(1,#imgs.reg_clouds.sm)
                
            ]
            
            cloud.y = 850+math.random(0,100)
            
            curr_condition:add(cloud)
            
            active_clouds[cloud] = cloud
            
            cloud:start()
            
        end
        
    }
    
    small_cloud_launcher:stop()
    
    cloud_state = ENUM{"NONE","PARTLY","MOSTLY"}
    cloud_state:add_state_change_function(
        function()
            large_cloud_launcher.interval = 60000
        end,
        nil,"PARTLY"
    )
    cloud_state:add_state_change_function(
        function()
            large_cloud_launcher.interval = 30000
        end,
        nil,"MOSTLY"
    )
    cloud_state:add_state_change_function(
        function()
            for k,v in pairs(active_clouds) do
                k:hurry_out()
            end
            large_cloud_launcher:stop()
            small_cloud_launcher:stop()
        end,
        nil,"NONE"
    )
    cloud_state:add_state_change_function(
        function()
            large_cloud_launcher:start()
            small_cloud_launcher:start()
            large_cloud_launcher:on_timer()
            small_cloud_launcher:on_timer()
        end,
        "NONE",nil
    )
    
    function cloud_state:next_state(s)
        
        cloud_state:change_state_to(s)
        
    end
    
end




--------------------------------------------------------------------------------
-- Frozen Window                                                              --
--------------------------------------------------------------------------------

local frozen_window_state
do
    
    local wiper_freeze = Clone{
        source=imgs.wiper.freezing,
        y=760,
        opacity=0
    }
    
    local show = false
    local pulse_timer = Timer{
        interval = 8000*.7,
        on_timer = function(self)
            
            show = not show
            
            self.interval = show and 8000*.3 or 8000*.7
            
            wiper_freeze:animate{
                duration = 200,
                opacity = show and 255*.35 or 0,
            }
            
        end
    }
    pulse_timer:stop()
    frozen_window_state = AnimationState{
        transitions = {
            {
                source = "*",
                target = "OFF",
                keys = {
                    {wiper_freeze,  "opacity", 0},
                },
            },
            {
                source = "*",
                target = "ON",
                keys = {
                    {wiper_freeze,  "opacity", 255*.35},
                },
            },
            {
                source = "*",
                target = "PULSE",
                keys = {
                    {wiper_freeze,  "opacity", 0},
                },
            },
        }
    }
    frozen_window_state.state = "OFF"
    local on_started = {
        ["OFF"] = function()
            wiper_freeze:stop_animation()
            pulse_timer:stop()
        end,
        ["ON"] = function()
            wiper_freeze:stop_animation()
            pulse_timer:stop()
            curr_condition:add(wiper_freeze)
            wiper_freeze:lower_to_bottom()
        end,
        ["PULSE"] = function()
            pulse_timer.interval = 8000*.3
            show = false
            pulse_timer:start()
            curr_condition:add(wiper_freeze)
            wiper_freeze:lower_to_bottom()
        end,
    }
    local on_completed = {
        ["OFF"] = function()
            wiper_freeze:unparent()
        end,
        ["ON"] = function()
        end,
        ["PULSE"] = function()
        end,
    }
    
    frozen_window_state.timeline.on_started = function()
        on_started[frozen_window_state.state]()
    end
    
    frozen_window_state.timeline.on_completed = function()
        on_completed[frozen_window_state.state]()
    end
    
    function frozen_window_state:next_state(s)
        
        frozen_window_state.state = s
        
    end
    
end




--------------------------------------------------------------------------------
-- Wiper                                                                      --
--------------------------------------------------------------------------------


local wiper_state
do
    
    local snow_blade   = Clone{
        name = "Snow Blade",
        source=imgs.wiper.snow_blade,
        x=-124+50,
        y=screen_h+30,
        opacity=0
    }
    local wiper_blade  = Clone{
        name = "Wiper Blade",
        source=imgs.wiper.blade,
        x=-124+50,
        y=screen_h+30,
        opacity=0
    }
    local wiper_rain   = Clone{
        name = "Wiper bg",
        source=imgs.wiper.corner,
        y=573,
        opacity=0
    }
    snow_blade.anchor_point  = {50, snow_blade.h}
    wiper_blade.anchor_point = {50,wiper_blade.h}
    
    local curr_blade
    local prev_drops = {}
    local active_drops = {}
    local window_drops = function(rad,deg,src,opacity)
        
        local drop = table.remove(prev_drops) or Clone{
            name = "Window Drop",
            extra = {
                add_to_screen = function(self)
                    
                    curr_condition:add(self)
                    
                    self:animate{
                        duration = 100,
                        mode     = "EASE_OUT_SINE",
                        scale    = {.75,.75}
                    }
                    
                    active_drops[self] = self
                    
                end,
                check_wipe = function(self,deg_1,deg_2)
                    if deg_2 < self.deg and self.deg < deg_1 then
                        self:unparent()
                        table.insert(prev_drops,self)
                        return true
                    end
                    return false
                end
            }
        }
        
        drop:set{
            x =   curr_blade.x+rad*math.cos(math.pi/180*deg),
            y =   curr_blade.y+rad*math.sin(math.pi/180*deg),
            scale   = {0,0},
            opacity = opacity,
            source  = src
        }
        drop.anchor_point = {drop.w/2,drop.h/2}
        drop.deg = deg
        
        return drop
        
    end
    
    local rain_timer = Timer{
        interval = 100,
        on_timer = function()
            local rad = math.random(1,(wiper_blade.w-30)/4)*4
            local deg = math.random(1,20)*-4
            local r   = window_drops(
                rad,
                deg,
                imgs.rain.drops[  math.random(1,#imgs.rain.drops)  ],
                255*.4
            )
            
            r:add_to_screen()
        end
    }
    local snow_timer = Timer{
        interval = 100,
        on_timer = function()
            local rad = math.random(1,(wiper_blade.w-30)/4)*4
            local deg = math.random(1,20)*-4
            local r   = window_drops(
                rad,
                deg,
                imgs.snow_flake.lg[  math.random(1,#imgs.snow_flake.lg)  ],
                255*.4
            )
            
            r:add_to_screen()
        end
    }
    rain_timer:stop()
    snow_timer:stop()
    
    local wiper_animation = Timeline{
        duration = 4000,
        loop     = true,
        on_new_frame = function(tl,ms,p)
            
            if p < 1/4 then
                p = p*4 -- 0 - 1/4 goes to 0 - 1
                for k,v in pairs(active_drops) do
                    
                    if k:check_wipe(
                            curr_blade.z_rotation[1],
                            p*-100-5
                        ) then
                        
                        active_drops[k] = nil
                    end
                end
                curr_blade.z_rotation={-100*p,0,0}
            elseif p < 2/4 then
                p = 2-p*4 -- 1/4 - 2/4 goes to 1 - 0
                for k,v in pairs(active_drops) do
                    
                    if k:check_wipe(
                            p*-100+5,
                            curr_blade.z_rotation[1]
                        ) then
                        
                        active_drops[k] = nil
                    end
                end
                curr_blade.z_rotation={-100*p,0,0}
            end
            
        end
    }
    
    wiper_state = AnimationState{
        transitions = {
            {
                source = "*",
                target = "NONE",
                keys = {
                    {wiper_rain,  "opacity",   0},
                    {wiper_blade, "opacity",   0},
                    {snow_blade,  "opacity",   0},
                },
            },
            {
                source = "*",
                target = "SLEET",
                keys = {
                    {wiper_rain,  "opacity", 255},
                    {wiper_blade, "opacity",   0},
                    {snow_blade,  "opacity", 255},
                },
            },
            {
                source = "*",
                target = "RAIN",
                keys = {
                    {wiper_rain,  "opacity", 255},
                    {wiper_blade, "opacity", 255},
                    {snow_blade,  "opacity",   0},
                },
            },
        },
    }
    
    wiper_state.state = "NONE"
    
    local add_to_screen = function()
        
        if wiper_rain.parent == nil then
            curr_condition:add(
                snow_blade,
                wiper_blade,
                wiper_rain
            )
        end
        snow_blade.z_rotation = {0,0,0}
        wiper_blade.z_rotation = {0,0,0}
        
    end
    
    local remove_from_screen = function()
        
        for k,v in pairs(active_drops) do
            active_drops[k] = nil
            k:unparent()
        end
        
        snow_blade:unparent()
        wiper_blade:unparent()
        wiper_rain:unparent()
        
    end
    wiper_state.timeline.on_completed = function()
        if wiper_state.state ~= "NONE" then
            if wiper_state.state == "SLEET" then
                curr_blade = snow_blade
            else
                curr_blade = wiper_blade
            end
            wiper_animation:start()
            wiper_animation.loop = true
            if wiper_state.state == "SLEET" then
                snow_timer:start()
            end
            rain_timer:start()
        else
            remove_from_screen()
        end
    end
    
    function wiper_state:next_state(s)
        
        if s == wiper_state.state then
            return
        end
        if wiper_state.state == "NONE" then
            add_to_screen()
        else
            snow_timer:stop()
            rain_timer:stop()
            wiper_animation.loop = false
        end
        wiper_state.state = s
        
    end
    
end




--------------------------------------------------------------------------------
-- Fog                                                                        --
--------------------------------------------------------------------------------

local fog_state

do
    local fog = Clone{source=imgs.fog,opacity=0,y=screen_h-imgs.fog.h}
    
    fog_state = AnimationState{
        transitions = {
            {
                source = "*",
                target = "NONE",
                keys = {
                    {fog,  "opacity", 0},
                },
            },
            {
                source = "*",
                target = "HALF",
                keys = {
                    {fog,  "opacity", 255*.5},
                },
            },
            {
                source = "*",
                target = "FULL",
                keys = {
                    {fog,  "opacity", 255},
                },
            },
        }
    }
    fog_state.state = "NONE"
    
    fog_state.timeline.on_started = function()
        if fog_state.state ~= "NONE" and fog.parent == nil then
            curr_condition:add(fog)
        end
    end
    fog_state.timeline.on_completed = function()
        if fog_state.state == "NONE" and fog.parent ~= nil then
            fog:unparent()
        end
    end
    
    function fog_state:next_state(s)
        
        fog_state.state = s
        
    end
end




--------------------------------------------------------------------------------
-- Snow                                                                       --
--------------------------------------------------------------------------------

local snow_state

do
    local snow_corner = Clone{source=imgs.snow_corner,x=-10,y=screen_h-imgs.snow_corner.h+30,opacity=0}
    
    local flake
    
    local old_flakes = {}
    
    local active_flakes = {}
    
    local new_flake = function()
        
        local flake
        
        flake = Clone{
            name = "snow_flake",
            extra={
                drift = function(self)
                    self:animate{
						duration   = flake.duration > 0 and flake.duration or 1,
						--loop       = true,
						x          = self.x + flake.speed_x*flake.duration/1000,--math.random(screen_w/5,screen_h/2),
						y          = screen_h+100,
						z_rotation = (flake.duration/(math.random(900,1100)*10))*360,
                        on_completed = function(self)
                            active_flakes[flake] = nil
                            flake:unparent()
                            table.insert(old_flakes,flake)
                        end
					}
                    
                end,
                hurry_out = function(self)
                    self:stop_animation()
                    self:animate{
                        duration     = 1000,
                        x            = self.x+300,
                        y            = screen_h+100,
						on_completed = function(self)
                            active_flakes[flake] = nil
                            flake:unparent()
                            table.insert(old_flakes,flake)
                        end
                    }
                end
            }
        }
        return flake
    end
    local function launch_flake(speed_x,speed_y,y)
        
        flake = table.remove(old_flakes) or new_flake()
        
        local s = math.random(12,20)/20*math.random(12,20)/20
        flake:set{
            source = imgs.snow_flake.lg[  math.random(1,#imgs.snow_flake.lg)  ],
            x=-100,
            y = y,
            opacity=255*s*(1+math.random(-10,10)/50),
            anchor_point = {flake.w/2-math.random(60,120),flake.h/2},
            z_rotation = {0,0,0},
            scale = {s,s}
        }
        
        flake.speed_x = speed_x
        
        flake.duration = (screen_h+150 - flake.y)/speed_y * 1000

	flake.duration = flake.duration > 0 and flake.duration or 1
        
        curr_condition:add(flake)
        
        flake:drift()
        
        active_flakes[flake] = flake
        
    end
    
    local flurry_timer = Timer{
        interval = 689,
        on_timer = function()
            launch_flake(math.random(50,100),20,math.random(750,950))
        end
    }
    flurry_timer:stop()
    local snow_timer = Timer{
        interval = 689/16,
        on_timer = function()
            launch_flake(math.random(500,600),200,math.random(600,950))
        end
    }
    snow_timer:stop()
    snow_state = AnimationState{
        transitions = {
            {
                source = "*",
                target = "NONE",
                keys = {
                    {snow_corner,  "opacity", 0},
                },
            },
            {
                source = "*",
                target = "FLURRY",
                keys = {
                    {snow_corner,  "opacity", 255},
                },
            },
            {
                source = "*",
                target = "SNOW",
                keys = {
                    {snow_corner,  "opacity", 255},
                },
            },
        }
    }
    snow_state.state = "NONE"
    
    snow_state.timeline.on_started = function()
        
        snow_timer:stop()
        flurry_timer:stop()
        
        if snow_state.state == "FLURRY" then
            flurry_timer:start()
        end
        if snow_state.state == "SNOW" then
            snow_timer:start()
        end
    end
    snow_state.timeline.on_completed = function()
        if snow_state.state == "NONE" and snow_corner.parent ~= nil then
            for _,flake in pairs(active_flakes) do
                flake:hurry_out()
            end
            snow_corner:unparent()
        end
    end
    
    function snow_state:next_state(s)
        
        if snow_state.state == "NONE" and s ~= "NONE" then
            
            curr_condition:add(snow_corner)
            
        end
        
        snow_state.state = s
        
    end
end




--------------------------------------------------------------------------------
-- Chance Rain                                                                --
--------------------------------------------------------------------------------

local chance_rain_state = {}
do
    
    local old_rain = {}
    local flip = false
    local drop_rain = function()
        
        local rain = table.remove(old_rain) or Clone{
            name = "small rain",
            source = imgs.rain.light,
        }
        flip = not flip
        rain:set{
            x      = flip and rain.w or 0,
            y      = 806,
            y_rotation = flip and {180,0,0} or {0,0,0},
            
        }
        
        curr_condition:add(rain)
        
        rain:lower_to_bottom()
        
        rain:animate{
            duration = 400,
            y = screen_h,
            on_completed = function()
                
                table.insert(old_rain,rain)
                rain:unparent()
            end
        }
        
    end
    
    local rain_drops_timer = Timer{
        interval = 150,
        on_timer = function()
            drop_rain()
        end
    }
    
    
    local rain_on = true
    local intermittent_rain_timer = Timer{
        interval = 8000*.7,
        on_timer = function(self)
            rain_on = not rain_on
            
            if rain_on then
                self.interval = 8000*.3
                
                rain_drops_timer:start()
                
            else
                self.interval = 8000*.7
                
                rain_drops_timer:stop()
                
            end
        end,
    }
    intermittent_rain_timer.begin = function(self)
        self.interval = 8000*.3
        rain_on = false
        self:start()
        
    end
    
    intermittent_rain_timer:stop()
    rain_drops_timer:stop()
    
    local curr_state = "OFF"
    function chance_rain_state:next_state(next_state)
        intermittent_rain_timer:stop()
        rain_drops_timer:stop()
        if next_state ~= "OFF" then
            intermittent_rain_timer:begin()
        end
        curr_state = next_state
    end
    
end




--------------------------------------------------------------------------------
-- Chance Snow                                                                --
--------------------------------------------------------------------------------
local chance_snow_state = {}
do
    local old_snow = {}
    local new_snow = function()
        local snow
        snow = Clone{
            name = "chance of snow",
            extra = {
                fall = Timeline{
                    on_new_frame = function(tl,ms,p)
                        
                        snow.y = 830*(1-p) + screen_h*p
                        snow.x = snow.start_x + snow.speed_x*ms/1000
                        
                        p = ms/tl.seesaw_duration*2
                        
                        snow.z_rotation = {30*math.sin(math.pi*p),0,0}
                        
                    end,
                    on_completed = function(self)
                        table.insert(old_snow,snow)
                        snow:unparent()
                    end,
                }
            }
        }
        return snow
    end
    local snow
    local launch_snow = function(speed_x,speed_y)
        
        snow = table.remove(old_snow) or new_snow()
        
        snow.speed_x = speed_x
        
        snow.fall.duration = (screen_h - 830) /speed_y * 1000

	snow.fall.duration = snow.fall.duration > 0 and snow.fall.duration or 1
        
        snow.fall.seesaw_duration = math.random(900,1100)
        
        snow.start_x = math.random(20,300)
        
        snow.x = snow.start_x
        
        snow.source=imgs.snow_flake.sm[  math.random(1,#imgs.snow_flake.sm)  ]
        
        curr_condition:add(snow)
        
        snow.fall:start()
        
        snow:lower_to_bottom()
    end
    
    local curr_timer
    local snow_timer = Timer{
        interval = 200,
        on_timer = function()
            launch_snow(10,300)
        end
    }
    
    
    local flurry_timer = Timer{
        interval = 400,
        on_timer = function()
            launch_snow(10,50)
        end
    }
    
    
    snow_timer:stop()
    flurry_timer:stop()
    local snow_on = false
    local intermittent_timer = Timer{
        interval = 8000*.7,
        on_timer = function(self)
            snow_on = not snow_on
            
            if snow_on then
                
                self.interval = 8000*.3
                
                curr_timer:start()
                
            else
                self.interval = 8000*.7
                
                curr_timer:stop()
                
            end
        end
    }
    intermittent_timer.begin = function(self)
        self.interval = 8000*.3
        snow_on = false
        self:start()
        
    end
    intermittent_timer:stop()
    local curr_state = "OFF"
    function chance_snow_state:next_state(next_state)
        --if curr_state ~= next_state then
            intermittent_timer:stop()
            flurry_timer:stop()
            snow_timer:stop()
            if next_state == "OFF" then
            elseif next_state == "FLURRY" then
                intermittent_timer:begin()
                curr_timer = flurry_timer
            else
                intermittent_timer:begin()
                curr_timer = snow_timer
            end
            curr_state = next_state
        --end
    end
    
end



--------------------------------------------------------------------------------
-- Chance Cloud                                                               --
--------------------------------------------------------------------------------
local chance_cloud_state
do
    local cloud = Clone{source=imgs.reg_clouds.lg[2],y=802,}
    
    chance_cloud_state = AnimationState{
        transitions = {
            {
                source = "*",
                target = "OFF",
                keys = {
                    {cloud,  "x", -cloud.w-50},
                },
            },
            {
                source = "*",
                target = "ON",
                keys = {
                    {cloud,  "x", -50},
                },
            },
        }
    }
    
    chance_cloud_state.state = "OFF"
    
    chance_cloud_state.timeline.on_started = function()
        if fog_state.state ~= "OFF" and cloud.parent == nil then
            curr_condition:add(cloud)
        end
    end
    chance_cloud_state.timeline.on_completed = function()
        if fog_state.state == "OFF" and cloud.parent ~= nil then
            cloud:unparent()
        end
    end
    
    function chance_cloud_state:next_state(s)
        
        chance_cloud_state.state = s
        
    end
end


--------------------------------------------------------------------------------
-- Chance Lightning                                                           --
--------------------------------------------------------------------------------
local chance_lightning_state = {}
do
    local lightning = {}
    for i = 1,#imgs.lightning do
        lightning[i]   = Clone{source=imgs.lightning[i],opacity=0,y=850}
    end
    
    
    local l_index = 1
    local double_lightning = true
    local lightning_timer = Timer{
        interval = 8000,
        on_timer = function(self)
            
            double_lightning = not double_lightning
            
            self.interval = double_lightning and 8000 or 300
            
            l_index = l_index%#imgs.lightning+1
            
            lightning[l_index].opacity=255
            
            lightning[l_index]:lower_to_bottom()
            
            dolater(100,function()
                
                lightning[l_index].opacity=0
                
            end)
            
        end
    }
    lightning_timer:stop()
    
    local curr_state = "OFF"
    function chance_lightning_state:next_state(next_state)
        if curr_state ~= next_state then
            
            if next_state == "OFF" then
                for i = 1,#lightning do
                    lightning[i]:unparent()
                end
                lightning_timer:stop()
            else
                curr_condition:add(unpack(lightning))
                lightning_timer:start()
            end
            curr_state = next_state
        end
    end
    
end

--------------------------------------------------------------------------------
-- State Changer                                                              --
--------------------------------------------------------------------------------


local no_conditions = {
    sun              =  "SET",
    moon             =  "SET",
    tstorm           =  "OFF",
    wiper            = "NONE",
    clouds           = "NONE",
    fog              = "NONE",
    snow             = "NONE",
    chance_rain      =  "OFF",
    chance_snow      =  "OFF",
    chance_cloud     =  "OFF",
    frozen_window    =  "OFF",
    chance_lightning =  "OFF",
}

local condition_states = {
    sun              = sun_state,
    moon             = moon_state,
    tstorm           = tstorm_state,
    wiper            = wiper_state,
    clouds           = cloud_state,
    fog              = fog_state,
    snow             = snow_state,
    chance_snow      = chance_snow_state,
    chance_rain      = chance_rain_state,
    chance_cloud     = chance_cloud_state,
    frozen_window    = frozen_window_state,
    chance_lightning = chance_lightning_state,
}

local set_states = function(t)
    
    if t.sun ~= "SET" and time_of_day == "NIGHT" then
        t.sun = "SET"
        t.moon="RISEN"
    end
    
    for k,default_state in pairs(no_conditions) do
        
        condition_states[k]:next_state(t[k] or default_state)
        
    end
    
    
end
    

conditions = {
    ["Chance of Flurries"]       = function() set_states{chance_cloud = "ON", chance_snow="FLURRY"} end,
    ["Chance of Rain"]           = function() set_states{chance_cloud = "ON", chance_rain="ON"     }end,
    ["Chance of Freezing Rain"]  = function() set_states{chance_cloud = "ON", chance_rain="F_RAIN",frozen_window="PULSE"} end,
    ["Chance of Sleet"]          = function() set_states{chance_cloud = "ON", chance_rain="ON", chance_snow="SNOW"} end,
    ["Chance of Snow"]           = function() set_states{chance_cloud = "ON", chance_snow="SNOW"} end,
    ["Chance of Thunderstorms"]  = function() set_states{chance_cloud = "ON", chance_lightning="ON"} end,
    --["Chance of a Thunderstorm"] = nil,
    --["Clear"]                    = nil,
    --["Cloudy"]                   = nil,
    ["Flurries"]                 = function() set_states{snow="FLURRY"} end,
    ["Fog"]                      = function() set_states{sun="HALF",clouds="PARTLY",fog="FULL"} end,
    ["Haze"]                     = function() set_states{sun="HALF",fog="FULL"} end,
    ["Mostly Cloudy"]            = function() set_states{clouds="MOSTLY"} end,
    --["Mostly Sunny"]             = nil,
    ["Partly Cloudy"]            = function() set_states{sun="FULL",clouds="PARTLY"} end,
    --["Partly Sunny"]             = nil,
    ["Freezing Rain"]            = function() set_states{wiper  = "RAIN",frozen_window="ON"} end,
    ["Rain"]                     = function() set_states{wiper="RAIN"} end,
    ["Sleet"]                    = function() set_states{wiper="SLEET"} end,
    ["Snow"]                     = function() set_states{fog="HALF",snow="SNOW"} end,
    ["Sunny"]                    = function() set_states{sun="FULL"} end,
    ["Thunderstorms"]            = function() set_states{tstorm="ON"} end,
    --["Thunderstorm"]             = nil,
    ["Unknown"]                  = function() set_states{} end,
    ["Overcast"]                 = function() set_states{sun="HALF",clouds="MOSTLY",fog="FULL"} end,
    --["Scattered Clouds"]         = nil,
}


for k,_ in pairs(conditions) do
    table.insert(all_anims,k) -- index all the animations for the test bar
end

conditions["Clear"]                  = conditions["Sunny"]
--conditions["Chance of Sleet"]        = conditions["Chance of Freezing Rain"]
conditions["Partly Sunny"]           = conditions["Mostly Cloudy"]
conditions["Cloudy"]                 = conditions["Mostly Cloudy"]
conditions["Mostly Sunny"]           = conditions["Partly Cloudy"]
conditions["Scattered Clouds"]       = conditions["Partly Cloudy"]
conditions["Thunderstorm"]           = conditions["Thunderstorms"]
conditions["Chance of a Thunderstorm"] = conditions["Chance of Thunderstorms"]
--from curr conditions
conditions["Rain Showers"]        = conditions["Rain"]
conditions["Drizzle"]             = conditions["Rain"]
--conditions["Light Rain"]          = conditions["Rain"]
--conditions["Heavy Rain"]          = conditions["Rain"]
conditions["Snow Grains"]         = conditions["Snow"]
conditions["Ice Crystals"]        = conditions["Snow"]
conditions["Ice Pellets"]         = conditions["Snow"]
conditions["Hail"]                = conditions["Snow"]
--conditions["Heavy Snow"]          = conditions["Snow"]
--conditions["Light Snow"]          = conditions["Snow"]
conditions["Mist"]                = conditions["Haze"]
conditions["Smoke"]               = conditions["Fog"]
conditions["Low Drifting Snow"]   = conditions["Flurries"]
conditions["Blowing Snow"]        = conditions["Snow"]
conditions["Ice Pellets Showers"] = conditions["Snow"]
conditions["Hail Showers"]        = conditions["Snow"]
conditions["Small Hail Showers"]  = conditions["Snow"]
conditions["Thunderstorms and Rain"]        = conditions["Thunderstorms"]
conditions["Thunderstorms and Snow"]        = conditions["Thunderstorms"]
conditions["Thunderstorms and Ice Pellets"] = conditions["Thunderstorms"]
conditions["Thunderstorms and Hail"]        = conditions["Thunderstorms"]
conditions["Thunderstorms and Small Hail"]  = conditions["Thunderstorms"]

local n1, n2
setmetatable(conditions,{
    __index = function(t,k)
        
        k = k or "" --quick fix to not cause nil exception in the gsubs
        
        k, n1 = string.gsub(k,"^Light ","")
        k, n2 = string.gsub(k,"^Heavy ","")
        
        if n1 > 0 or n2 > 0 then
            
            return t[k]
        else
            
            print("conditions in WeatherAnimations.lua received unexpected weather condition: ")
            print("\t",k)
            print("Please tell Alex Indaco that this happened\n\n")
            
            return t["Unknown"]
            
        end
    end,
})








--conditions["Chance of Rain"]()
