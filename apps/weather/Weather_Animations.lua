local temp_var
sun = {
    state="SET",
    setup = function(self)
        if self.group == nil then
            
            self.group = Group{
                x=-16,
                y=screen_h,
                --opacity=255*.4
            }
            
            self.flare = {}
            
            self.flare[1] = Clone{source=imgs.sun.flare[1]}
            self.flare[2] = Clone{source=imgs.sun.flare[2]}
            self.flare[3] = Clone{source=imgs.sun.flare[3]}
            
            self.sun      = Clone{source=imgs.sun.base}
            
            self.group:add(
                self.flare[3],
                self.sun,
                self.flare[2],
                self.flare[1]
            )
            
            for _,v in ipairs(self.flare) do
                v:move_anchor_point(v.w/2,v.h/2)
                v.position={v.w/2,v.h/2}
            end
            
            self.sun:move_anchor_point(self.sun.w/2,self.sun.h/2)
            self.sun.position={self.sun.w/2,self.sun.h/2}
            --self.state="SET"
        end
        --animate_list[self.func_tbls.shine] = self
        sun.flare[1]:complete_animation()
        sun.flare[2]:complete_animation()
        sun.flare[3]:complete_animation()
        
        sun.flare[1]:animate{duration=5000,loop=true,z_rotation=360}
        sun.flare[2]:animate{duration=5000,loop=true,z_rotation=-360}
        sun.flare[3]:animate{duration=5000,loop=true,z_rotation=720}
        
        sun.group:animate{duration=2000,y=701}
        
        curr_condition:add(self.group)
    end,
    
    
    --[[
    func_tbls = {
        rise  = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.group.y = screen_h + (701-screen_h)*math.sin(math.pi/2*p)
            end
        },
        shine = {
            duration=160000,
            loop=true,
            func=function(this_obj,this_func_tbl,secs,p)
                local s1 = math.sin(6*math.pi*p)
                local s2 = math.sin(6*math.pi*p+2*math.pi/3)
                local s3 = math.sin(6*math.pi*p+4*math.pi/3)
                
                local amp = .05
                this_obj.flare[1].scale={.95+amp*s1,.95+amp*s1}
                --this_obj.flare[2].scale={.95+amp*s2,.95+amp*s2}
                --this_obj.flare[3].scale={.95+amp*s3,.95+amp*s3}
                
                amp=.2
                this_obj.flare[1].opacity=255*(.8+amp*s2)
                this_obj.flare[2].opacity=255*(.4+amp*s3)
                --this_obj.flare[3].opacity=255*(.8+amp*s1)
                
                this_obj.flare[1].z_rotation={ 360*p,0,0}
                this_obj.flare[2].z_rotation={-360*p,0,0}
                this_obj.flare[3].z_rotation={ 720*p,0,0}
            end,
        },
        set   = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.group.y = 701 + (screen_h-701)*(1-math.sin(math.pi/2*p+math.pi/2))
                if p == 1 then
                    --animate_list[this_obj.func_tbls.shine] = nil
                    this_obj:remove()
                end
            end
        },
        half_to_full_opacity = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.group.opacity = 255*.5+255*.5*p
            end
        },
        full_to_half_opacity = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.group.opacity = 255*.5+255*.5*(1-p)
            end
        },
    },
    --]]
    remove = function(self)
        self.group:unparent()
    end
}

moon = {
    state="SET",
    setup = function(self)
        if self.group == nil then
            self.group = Group{
                x=0,
                y=709
            }
            self.stars = Clone{source=imgs.stars,opacity=0}
            self.star  = Clone{name="SHTAR",source=imgs.star, opacity=0,x=10,y=100}
            self.moon  = Clone{
                    source=imgs.moon,
                    x=38,
                    y=63 + (screen_h-709)
            }
            self.group:add(self.stars,self.star,self.moon)
            self.twinkle_timer = Timer{interval=3000,on_timer =
                function()
                    self.star.position = {
                        math.random(10,self.stars.w),
                        math.random(0,self.stars.h)
                    }
                    self.star.opacity = 255
                    self.star:animate{duration=200,opacity=0}
                end
            }
            --self.state="SET"
        end
        curr_condition:add(self.group)
        self.group:animate{duration=2000,y=63}
        self.stars:animate{duration=2000,opacity=255}
        self.twinkle_timer:start()
        self.group:lower_to_bottom()
    end,
--[[
    func_tbls = {
        rise  = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.stars.opacity=255*p
                this_obj.moon.y = 63 + (screen_h-709) *(1-math.sin(math.pi/2*p))
                if p == 1 then
                    this_obj.state="RISEN"
                    --animate_list[this_obj.func_tbls.twinkle] = this_obj
                end
            end
        },
        set   = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.stars.opacity=255*(1-p)
                this_obj.moon.y = 63 + (screen_h-709) *(math.sin(math.pi/2*p))
                if p == 1 then
                    this_obj.state="SET"
                    animate_list[this_obj.func_tbls.twinkle] = nil
                end
            end
        },
        twinkle = {
            duration = 3000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p >= .90 then
                    this_obj.star.opacity = 255*math.sin(math.pi*(p-.9)*10)
                    --print(this_obj.star.opacity)
                
                end
                if p < .1 then
                    this_obj.star.position = {
                        math.random(10,this_obj.stars.w),
                        math.random(0,this_obj.stars.h)
                    }
                    this_obj.star.opacity = 0
                end
            end
        }
    },
    --]]
    on_remove = function(self)
        self.group:unparent()
    end,
}


lg_cloud = function() return{
    
    setup = function(self)
        self.speed = math.random(4,6)
        local r = math.random(1,#imgs.reg_clouds.lg)
        self.start = -imgs.reg_clouds.lg[r].w
        self.img = Clone{
            name="lg_cloud",
            source=imgs.reg_clouds.lg[r],
            x=40,--self.start,
            y=670+math.random(0,150),
            opacity=0
        }
        
        
        curr_condition:add(self.img)
    end,
    --[[
    func_tbls = {
        drift = {
            
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.img.x = this_obj.img.x - this_obj.speed*secs
                if this_obj.img.x < -this_obj.img.w then
                    animate_list[this_func_tbl] = nil
                    this_obj.img:unparent()
                    cloud_spawner.cloud_list[this_obj] = nil
                end
            end
        },
        fade_in = {
            duration = 4000,
            
            func = function(this_obj,this_func_tbl,secs,p)
            --print("wtf")
                this_obj.img.opacity = 255*p
                if p == 1 then
                    animate_list[this_obj.func_tbls.drift] = this_obj
                end
            end
        },
    },
    --]]
    hurry_out = function(self)
        self.speed = 300
    end

}end

sm_cloud = function() return{
    
    setup = function(self)
        self.speed = math.random(4,8)
        local r = math.random(1,#imgs.reg_clouds.sm)
        self.start = -imgs.reg_clouds.sm[r].w
        self.img = Clone{
            name="small",
            source=imgs.reg_clouds.sm[r],
            x=self.start,
            y=850+math.random(0,100),
            opacity=255
        }
        
        curr_condition:add(self.img)
    end,
    
    fading = false,
    --[[
    func_tbls = {
        drift_in = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.img.x = this_obj.img.x + this_obj.speed*secs
                if not this_obj.fading and this_obj.img.x > 200 then
                    this_obj.fading = true
                    animate_list[this_obj.func_tbls.fade_out] = this_obj
                end
            end
        },
        fade_out = {
            func = function(this_obj,this_func_tbl,secs,p)
                if this_obj.img.opacity - this_obj.speed*secs < 0 then
                    animate_list[this_func_tbl] = nil
                    animate_list[this_obj.func_tbls.drift_in] = nil
                    this_obj.img:unparent()
                    cloud_spawner.cloud_list[this_obj] = nil
                else
                    this_obj.img.opacity = this_obj.img.opacity - this_obj.speed*secs
                end
            end
        }
    },
    --]]
    hurry_out = function(self)
        self.speed = 300
    end

}end


cloud_spawner = {
    lg_thresh     = 60000,
    lg_elapsed_1  = 60000,
    lg_elapsed_2  = 90000,
    
    sm_thresh   = 40000,
    sm_elapsed  = 40000,

    state="NONE",
    
    last_cloud = nil,
    setup = function(self)
        if self.lg_cloud_timer == nil then
            self.lg_cloud_timer=Timer{interval=60000,on_timer=
                function()
                    local r = math.random(1,#imgs.reg_clouds.lg)
                    temp_var = Clone{
                        name="lg_cloud",
                        source=imgs.reg_clouds.lg[r],
                        x=40,--self.start,
                        y=670+math.random(0,150),
                        opacity=0
                    }
                    temp_var:animate{duration=4000,opacity=255,on_completed=
                        function()
                            temp_var:animate{
                                duration=(temp_var.x+temp_var.img.w)/math.random(4,6),
                                x=-temp_var.img.w,
                                on_completed = function()
                                    temp_var:unparent()
                                    
                                end
                            }
                        end
                    }
                    cloud_list[temp_var] = temp_var
                end
            }
            self.sm_cloud_timer=Timer{interval=40000,on_timer=
                function()
                    local r = math.random(1,#imgs.reg_clouds.lg)
                    temp_var = Clone{
                        name="lg_cloud",
                        source=imgs.reg_clouds.sm[r],
                        x=-imgs.reg_clouds.sm[r].w,--self.start,
                        y=850+math.random(0,100),
                        opacity=0
                    }
                    temp_var:animate{
                        duration=(temp_var.x+200)/math.random(4,6),
                        x=200,
                        on_completed=function()
                            temp_var:animate{
                                duration=(100)/math.random(4,6),
                                x=temp_var.x+100,
                                opacity=0,
                                on_completed = function()
                                    temp_var:unparent()
                                end
                            }
                        end
                    }
                    cloud_list[temp_var] = temp_var
                end
            }
        end
        self.sm_cloud_timer:start()
        self.lg_cloud_timer:start()
        
        self.sm_cloud_timer.on_timer()
        self.lg_cloud_timer.on_timer()

    end,
    --[[
    func_tbls = {
        spawn_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                
                this_obj.lg_elapsed_1 = this_obj.lg_elapsed_1 + secs*1000
                this_obj.lg_elapsed_2 = this_obj.lg_elapsed_2 + secs*1000
                this_obj.sm_elapsed   = this_obj.sm_elapsed   + secs*1000
                
                
                if this_obj.lg_elapsed_1 > this_obj.lg_thresh then
                    local c = lg_cloud(cloud_spawner)
                    this_obj.cloud_list[c] = c
                    c:setup()
                    animate_list[c.func_tbls.fade_in] = c
                    this_obj.lg_elapsed_1 = this_obj.lg_elapsed_1%this_obj.lg_thresh
                    this_obj.last_cloud = c
                end
                
                if this_obj.state == "MOSTLY" and this_obj.lg_elapsed_2 > this_obj.lg_thresh then
                    local c = lg_cloud(cloud_spawner)
                    this_obj.cloud_list[c] = c
                    c:setup()
                    animate_list[c.func_tbls.fade_in] = c
                    this_obj.lg_elapsed_2 = this_obj.lg_elapsed_2%this_obj.lg_thresh
                    this_obj.last_cloud = c
                end
                
                
                if this_obj.sm_elapsed > this_obj.sm_thresh then
                    local c = sm_cloud(cloud_spawner)
                    this_obj.cloud_list[c] = c
                    c:setup()
                    animate_list[c.func_tbls.drift_in] = c
                    this_obj.sm_elapsed = 0
                end
            end,
        }
    },
    --]]
    cloud_list = {},
    rem_last_cloud = function(self)
        if self.last_cloud == nil then return end
        --self.last_cloud:hurry_out()
        self.last_cloud:animate{duration=300,opacity=0,
            on_timer=function()
                self.last_cloud:unparent()
                
            end
        }
        self.cloud_list[self.last_cloud] = nil
        self.last_cloud = nil
    end,
    remove = function(self)
        for i,v in pairs(self.cloud_list) do
            v:animate{duration=200,opacity=0,on_timer=function() v:unparent() end}
        end
        self.cloud_list={}
        --animate_list[self.func_tbls.spawn_loop] = nil
        self.state = "NONE"
        self.last_cloud = nil
        --[[
        self.lg_elapsed_1 = 60000
        self.lg_elapsed_2 = 90000
        self.sm_elapsed   = 40000
        --]]
        self.sm_cloud_timer:stop()
        self.lg_cloud_timer:stop()
    end
    
}


window_snow = function(x,y,deg) return{
    
    setup = function(self)
        self.deg = deg
        local r = math.random(1,#imgs.snow_flake.lg)
        self.img = Clone{
            name="small",
            source=imgs.snow_flake.lg[r],
            x=x,--+math.random(0,10)*10,
            y=y,
            opacity=255*.4,
            anchor_point = {imgs.snow_flake.lg[r].w/2,imgs.snow_flake.lg[r].h/2},
            scale = {0,0}
        }
        self.anchor_point = {self.img.w/2,self.img.h/2}
        curr_condition:add(self.img)
    end,
    check_wipe_down = function(self,deg_2,deg_1)
        if self.deg < deg_1 and self.deg > deg_2 then
            --animate_list[self.func_tbls.fade_out] = self
            --self.img.opacity=0
            self.img:unparent()
        end
    end,
    check_wipe_up = function(self,deg_1,deg_2)
        if self.deg < deg_1 and self.deg > deg_2 then
            --animate_list[self.func_tbls.fade_out] = self
            --self.img.opacity=0
            self.img:unparent()
        end
    end,
    func_tbls={
        drop={
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if this_obj.img.y > screen_h then
                    animate_list[this_func_tbl]=nil
                    this_obj.img:unparent()
                    --this_obj.img = nil
                end
            end
        },
        fade_out = {
            duration = 200,
            func     = function(this_obj,this_func_tbl,secs,p)
                this_obj.img.opacity=255*.4*(1-p)
                if p == 1 then
                    this_obj.img:unparent()
                end
            end
        },
        stick = {
            duration = 100,
            func=function(this_obj,this_func_tbl,secs,p)
                local s = .75*math.sin(math.pi/2*p)
                this_obj.img.scale={s,s}
                --this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if p == 1 then
                    --animate_list[this_obj.func_tbls.wobble]=this_obj
                end
            end
        },
        wobble = {
            duration = math.random(200,1000),
            func=function(this_obj,this_func_tbl,secs,p)
                local s = 1 + .05*math.cos(1/2*math.pi*p)
                this_obj.img.scale={s,s}
                --this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if p == 1 then
                    --animate_list[this_obj.func_tbls.drop]=this_obj
                end
            end
        },
    },

}end
window_drops = function(x,y,deg) return{
    
    setup = function(self)
        self.deg = deg
        local r = math.random(1,#imgs.rain.drops)
        self.img = Clone{
            name="small",
            source=imgs.rain.drops[r],
            x=x,--+math.random(0,10)*10,
            y=y,
            opacity=255*.75,
            anchor_point = {imgs.rain.drops[r].w/2,imgs.rain.drops[r].h/2},
            scale = {0,0}
        }
        self.anchor_point = {self.img.w/2,self.img.h/2}
        curr_condition:add(self.img)
    end,
    check_wipe_down = function(self,deg_2,deg_1)
        if self.deg < deg_1 and self.deg > deg_2 then
            --animate_list[self.func_tbls.fade_out] = self
            --self.img.opacity=0
            self.img:unparent()
        end
    end,
    check_wipe_up = function(self,deg_1,deg_2)
        if self.deg < deg_1 and self.deg > deg_2 then
            --animate_list[self.func_tbls.fade_out] = self
            --self.img.opacity=0
            self.img:unparent()
        end
    end,
    func_tbls={
        drop={
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if this_obj.img.y > screen_h then
                    animate_list[this_func_tbl]=nil
                    this_obj.img:unparent()
                    --this_obj.img = nil
                end
            end
        },
        fade_out = {
            duration = 100,
            func     = function(this_obj,this_func_tbl,secs,p)
                this_obj.img.opacity=255*.75*(1-p)
                if p == 1 then
                    this_obj.img:unparent()
                end
            end
        },
        stick = {
            duration = 100,
            func=function(this_obj,this_func_tbl,secs,p)
                local s = .75*math.sin(math.pi/2*p)
                this_obj.img.scale={s,s}
                --this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if p == 1 then
                    --animate_list[this_obj.func_tbls.wobble]=this_obj
                end
            end
        },
        wobble = {
            duration = math.random(200,1000),
            func=function(this_obj,this_func_tbl,secs,p)
                local s = 1 + .05*math.cos(1/2*math.pi*p)
                this_obj.img.scale={s,s}
                --this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if p == 1 then
                    --animate_list[this_obj.func_tbls.drop]=this_obj
                end
            end
        },
    },

}end

wiper = {
    drops    = {},
    rain_thresh   = 200,
    rain_elapsed  =   0,
    snow_thresh   = 200,
    snow_elapsed  =   0,
    state    = "NONE", -- "RAIN", "F_RAIN", "SLEET"
    
    snow_blade   = Clone{
        source=imgs.wiper.snow_blade,
        x=-124+50,
        y=screen_h+30,
        anchor_point={50,imgs.wiper.snow_blade.h},
        opacity=0
    },
    wiper_blade  = Clone{
        source=imgs.wiper.blade,
        x=-124+50,
        y=screen_h+30,
        anchor_point={50,imgs.wiper.blade.h},
        opacity=0
    },
    wiper_rain   = Clone{
        source=imgs.wiper.corner,
        y=573,
        opacity=0
    },
    wiper_freeze = Clone{
        source=imgs.wiper.freezing,
        y=760,
        opacity=0
    },
    
    remove   = function(self)
        self.wiper_rain:unparent()
        self.wiper_freeze:unparent()
        self.wiper_blade:unparent()
        self.snow_blade:unparent()
        --animate_list[self.func_tbls.rain_loop] = nil
        --animate_list[self.func_tbls.snow_loop] = nil
    end,
    
    setup    = function(self)
        if self.wipe_timer == nil then
            self.wiper_tl = Timeline{
                duration     = 2000,
                on_new_frame = function(self,msecs,p)
                    if p < .5 then
                        for k,v in pairs(this_obj.drops) do
                            k:check_wipe_up(this_obj.wiper_blade.z_rotation[1],(p)*-200-5)
                        end
                        --this_obj.func_tbls.wipe_up(this_obj,p*4)
                        this_obj.wiper_blade.z_rotation={-100*p*2,0,0}
                    else
                        for k,v in pairs(this_obj.drops) do
                            k:check_wipe_down(this_obj.wiper_blade.z_rotation[1],-(1-p*2)*100)
                        end
                        --this_obj.func_tbls.wipe_up(this_obj,2-p*4)
                        this_obj.wiper_blade.z_rotation={-100*(1-p*2),0,0}
                    end
                end
            }
            self.wiper_timer = Timer{
                interval = 4000,
                on_timer = function()
                    self.wiper_tl:start()
                end
            }
            self.rain_timer = Timer{
                interval = 100,
                on_timer = function()
                    local rad = math.random(1,(self.wiper_blade.w-30)/4)*4
                    local deg = math.random(1,20)*-4
                    local r   = math.random(1,#imgs.rain.drops)
                    local droplet = Clone{
                        name="small",
                        source=imgs.rain.drops[r],
                        x=self.wiper_blade.x+rad*math.cos(math.pi/180*deg),
                        y=self.wiper_blade.y+rad*math.sin(math.pi/180*deg),
                        opacity=255*.75,
                        anchor_point = {imgs.rain.drops[r].w/2,imgs.rain.drops[r].h/2},
                        scale = {0,0},
                        extra = {
                            deg = deg,
                        }
                    }
                    droplet.anchor_point = {droplet.img.w/2,droplet.img.h/2}
                    curr_condition:add(droplet.img)
                    
                    droplet:animate{duration=math.random(300,600),scale={1,1}}
                    
                    self.drops[droplet] = droplet
                end
            }
            self.snow_timer = Timer{
                interval = 150,
                on_timer = function()
                    local rad = math.random(1,(self.wiper_blade.w-30)/4)*4
                    local deg = math.random(1,20)*-4
                    local r   = math.random(1,#imgs.snow_flake.lg)
                    local droplet = Clone{
                        name="small",
                        source=imgs.snow_flake.lg[r],
                        x=self.wiper_blade.x+rad*math.cos(math.pi/180*deg),
                        y=self.wiper_blade.y+rad*math.sin(math.pi/180*deg),
                        opacity=255*.4,
                        anchor_point = {imgs.snow_flake.lg[r].w/2,imgs.snow_flake.lg[r].h/2},
                        scale = {0,0},
                        extra = {
                            deg = deg,
                        }
                    }
                    curr_condition:add(droplet.img)
                    
                    droplet:animate{duration=math.random(300,600),scale={1,1}}
                    
                    self.drops[droplet] = droplet
                end
            }
        end
        curr_condition:add(
            self.wiper_rain,
            self.wiper_freeze,
            self.wiper_blade,
            self.snow_blade
        )
    end,
    
    func_tbls = {
        
        rain_loop = {
            duration = 4000,
            loop     = true,
            func     = function(this_obj,this_func_tbl,secs,p)
                --Rain code
                this_obj.rain_elapsed = this_obj.rain_elapsed + secs*1000
                if this_obj.rain_elapsed > 100 then
                    
                    local rad = math.random(1,(this_obj.wiper_blade.w-30)/4)*4
                    local deg = math.random(1,20)*-4
                    local r   = window_drops(
                        this_obj.wiper_blade.x+rad*math.cos(math.pi/180*deg),
                        this_obj.wiper_blade.y+rad*math.sin(math.pi/180*deg),
                        deg
                    )
                    r:setup()
                    this_obj.drops[r] = r
                    animate_list[r.func_tbls.stick] = r
                    
                    this_obj.rain_elapsed = 0
                end
                
                --Wiper Code
                if p < 1/4 then
                    for k,v in pairs(this_obj.drops) do
                        k:check_wipe_up(this_obj.wiper_blade.z_rotation[1],(p)*-400-5)
                    end
                    --this_obj.func_tbls.wipe_up(this_obj,p*4)
                    this_obj.wiper_blade.z_rotation={-100*p*4,0,0}
                elseif p < 2/4 then
                    for k,v in pairs(this_obj.drops) do
                        k:check_wipe_down(this_obj.wiper_blade.z_rotation[1],-(2-p*4)*100)
                    end
                    --this_obj.func_tbls.wipe_up(this_obj,2-p*4)
                    this_obj.wiper_blade.z_rotation={-100*(2-p*4),0,0}
                end
            end
        },
        snow_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.rain_elapsed = this_obj.rain_elapsed + secs*1000
                if this_obj.rain_elapsed > 150 then
                    
                    local rad = math.random(1,(this_obj.wiper_blade.w-30)/4)*4
                    local deg = math.random(1,20)*-4
                    local r   = window_snow(
                        this_obj.wiper_blade.x+rad*math.cos(math.pi/180*deg),
                        this_obj.wiper_blade.y+rad*math.sin(math.pi/180*deg),
                        deg
                    )
                    r:setup()
                    this_obj.drops[r] = r
                    animate_list[r.func_tbls.stick] = r
                    
                    this_obj.rain_elapsed = 0
                end
            end
        },
        --Fade Ins
        reg_fade_in = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_rain.opacity=255*p
                this_obj.wiper_blade.opacity=255*p
                if p == 1 then
                    animate_list[this_obj.func_tbls.rain_loop] = this_obj
                end
            end,
        },
        frost_fade_in = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_freeze.opacity=255*p
            end,
        },
        sleet_fade_in = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.snow_blade.opacity=255*p
                if p == 1 then
                    animate_list[this_obj.func_tbls.snow_loop] = this_obj
                end
            end,
        },
        --Fade Outs
        reg_fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_rain.opacity=255*(1-p)
                this_obj.wiper_blade.opacity=255*(1-p)
            end,
        },
        frost_fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_freeze.opacity=255*(1-p)
            end,
        },
        sleet_fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.snow_blade.opacity=255*(1-p)
            end,
        },
    }
}

falling_snow = function(speed_x,speed_y,x,y) return{
    
    setup = function(self)
        self.speed_x = speed_x
        self.speed_y = speed_y
        self.x = x
        local r = math.random(1,#imgs.snow_flake.sm)
        self.img = Clone{
            name="lg flake",
            source=imgs.snow_flake.sm[r],
            x=self.x,--+math.random(0,10)*10,
            y=y,
            opacity=255,
            anchor_point = {imgs.snow_flake.sm[r].w/2,imgs.snow_flake.sm[r].h/2-20}
        }
        curr_condition:add(self.img)
    end,
    func_tbls={
        drop={
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.y = this_obj.img.y + this_obj.speed_y*secs
                this_obj.img.x = this_obj.img.x + this_obj.speed_x*secs
                --this_obj.img.scale = {this_obj.img.scale[1] + 4*secs,this_obj.img.scale[1] + 4*secs}
                if this_obj.img.y > screen_h then
                    animate_list[this_func_tbl]=nil
                    this_obj.img:unparent()
                    --this_obj.img = nil
                end
            end
        },
        seesaw = {
            duration = math.random(900,1100)*2,
            loop = true,
            func=function(this_obj,this_func_tbl,secs,p)
                --this_obj.img.x = this_obj.x + 5*math.sin(math.pi*4*p)
                this_obj.img.z_rotation = {30*math.sin(math.pi*2*p),0,0}
            end
        }
    },

}end

chance_of = {
    rain_elapsed =   0,
    rain_thresh  = 300,
    
    snow_elapsed   =   0,
    snow_thresh    = 200,
    flurry_thresh  = 400,
        
    l_thresh   = 3000,
    l_elapsed  = 1000,
    l_len      = 100,
    
    l_index = 1,
    r_flip = true,
    state="NONE",
    
    cloud_1   = Clone{source=imgs.reg_clouds.lg[2],x=-imgs.reg_clouds.lg[6].w-50,y=802,},
    cloud_2   = Clone{source=imgs.reg_clouds.lg[1],x=-imgs.reg_clouds.lg[7].w-20,y=812,},
    wiper_freeze   = Clone{name="wiper freeze",source=imgs.wiper.freezing, y=760,opacity=0},
    lightning = Clone{source=imgs.lightning[1],y=850,opacity=0},
    
    state_tbl = {
        ["FLURRIES"] = function(self)
            self.snow_timer:start()
        end,
        ["RAIN"]     = function(self)
            self.rain_timer:start()
        end,
        ["F_RAIN"]   = function(self)
            self.rain_timer:start()
            self.wiper_freeze:animate={duration=200,opacity=255}
        end,
        ["SLEET"]    = function(self)
            self.rain_timer:start()
            self.snow_timer:start()
        end,
        ["SNOW"]     = function(self)
            self.snow_timer:start()
        end,
        ["TSTORMS"]  = function(self)
            self.rain_timer:start()
            self.lightning_timer:start()
        end,

    }
    
    setup = function(self)
        
        if self.rain_timer == nil then
            self.pause_timer = Timer{interval=8000,
                on_timer = function()
                    self.state_tbl[self.state](self)
                end
            }
            self.rain_timer = Timer{interval = 300,
                on_timer = function()
                    self.rain_timer.count = self.rain_timer.count + 1
                    if self.rain_timer.count > 10 then
                        self.rain_timer.count = 0
                        self.rain_timer:stop()
                        if self.state == "F_RAIN" then
                            self.wiper_freeze:animate={duration=200,opacity=0}
                        end
                        return
                    end
                    self.r_flip = not self.r_flip
                        
                    temp_var = Clone{
                        source=imgs.rain.light,
                        x=0,
                        y=806,
                        opacity=255*.5
                    }
                    if self.r_flip then
                        temp_var.y_rotation={180,0,0}
                        temp_var.x = temp_var.x + temp_var.w
                    end
                    temp_var:animate{duration=(screen_h-temp_var.y)/600,y=screen_h,on_completed=
                        function()
                            temp_var.unparent()
                            tabl.insert(prev_rain_drops,temp_var)
                        end
                    }
                    curr_conditions:add(temp_var)
                        
                        
                    self.cloud_1:raise_to_top()
                    self.cloud_2:raise_to_top()
                end
            }
            self.snow_timer = Timer{interval = 300,
                on_timer = function()
                    self.rain_timer.count = self.rain_timer.count + 1
                    if self.rain_timer.count > 10 then
                        self.rain_timer.count = 0
                        self.rain_timer:stop()
                        if self.state == "F_RAIN" then
                            self.wiper_freeze:animate={duration=200,opacity=0}
                        end
                        return
                    end
                    self.r_flip = not self.r_flip
                        
                    temp_var = Clone{
                        source=imgs.rain.light,
                        x=0,
                        y=806,
                        opacity=255*.5
                    }
                    if self.r_flip then
                        temp_var.y_rotation={180,0,0}
                        temp_var.x = temp_var.x + temp_var.w
                    end
                    temp_var:animate{duration=(screen_h-temp_var.y)/600,y=screen_h,on_completed=
                        function()
                            temp_var.unparent()
                            tabl.insert(prev_rain_drops,temp_var)
                        end
                    }
                    curr_conditions:add(temp_var)
                        
                        
                    self.cloud_1:raise_to_top()
                    self.cloud_2:raise_to_top()
                end
            }
            self.lightning_timer = Timer{interval = 300,
                on_timer = function()
                    self.state_tbl[self.state](self)
                end
            }
        end
        
        
        
        curr_condition:add(self.wiper_freeze,self.lightning,self.cloud_1,self.cloud_2)
        self.wiper_freeze:lower_to_bottom()
        animate_list[self.func_tbls.fade_in] = self
    end,
    
    remove = function(self)
        self.cloud_1:unparent()
        self.cloud_2:unparent()
        self.wiper_freeze:unparent()
        self.lightning:unparent()
    end,
    
    func_tbls = {
        fade_in = {
            duration = 400,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.cloud_1.x = -50-this_obj.cloud_1.w*(1-p)
                --this_obj.cloud_2.x = -20-this_obj.cloud_2.w*(1-p)
            end,
        },
        fade_out = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.cloud_1.x = -50-this_obj.cloud_1.w*(1-p)
                this_obj.cloud_2.x = -20-this_obj.cloud_2.w*(1-p)
                this_obj.rain_elapsed=0
                this_obj.l_elapsed=1000
                if p == 1 then
                    this_obj:remove()
                end
            end,
        },
        --[[
        fade_in_frost = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_freeze.opacity = 255*.35*p
                this_obj.wiper_freeze:lower_to_bottom()
            end,
        },
        fade_out_frost = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_freeze.opacity = 255*.35*(1-p)
            end,
        },
        --]]
        frost_loop = {
            duration = 8000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p < .7 then
                    this_obj.wiper_freeze.opacity = 0
                elseif p < .75 then
                    this_obj.wiper_freeze.opacity = 255*.35*(p-.7)*20
                elseif p <.95 then
                    this_obj.wiper_freeze.opacity = 255*.35
                else
                    this_obj.wiper_freeze.opacity = 255*.35*(1-(p-.95)*20)
                end
                
            end
        },
        rain_loop = {
            duration = 8000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p < .7 then return end
                this_obj.rain_elapsed = this_obj.rain_elapsed + secs*1000
                if this_obj.rain_elapsed > this_obj.rain_thresh then
                    this_obj.r_flip = not this_obj.r_flip
                    local r = rain_drops(0,806,imgs.rain.light,400,this_obj.r_flip)
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    
                    this_obj.rain_elapsed = 0
                end
                
                this_obj.cloud_1:raise_to_top()
                this_obj.cloud_2:raise_to_top()
            end
        },
        snow_loop = {
            duration = 8000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p < .7 then return end
                this_obj.snow_elapsed = this_obj.snow_elapsed + secs*1000
                if this_obj.snow_elapsed > this_obj.snow_thresh/8 then
                    
                    local r = falling_snow(10,300,math.random(20,300),830)
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    
                    animate_list[r.func_tbls.seesaw] = r
                    this_obj.snow_elapsed = 0
                    
                end
                this_obj.cloud_1:raise_to_top()
                this_obj.cloud_2:raise_to_top()
            end
        },
        flurries_loop = {
            duration = 8000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p < .7 then return end
                this_obj.snow_elapsed = this_obj.snow_elapsed + secs*1000
                if this_obj.snow_elapsed > this_obj.flurry_thresh then
                    
                    local r = falling_snow(10,50,math.random(20,300),830)
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    
                    animate_list[r.func_tbls.seesaw] = r
                    this_obj.snow_elapsed = 0
                    
                end
                this_obj.cloud_1:raise_to_top()
                this_obj.cloud_2:raise_to_top()
            end
        },
        lightning_loop = {
            duration = 8000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p < .7 then
                    this_obj.lightning.opacity=0
                    return
                end
                this_obj.l_elapsed = this_obj.l_elapsed + secs*1000
                if this_obj.l_elapsed < this_obj.l_len or
                  (this_obj.l_elapsed > 3*this_obj.l_len and
                   this_obj.l_elapsed < 4*this_obj.l_len) then
                    this_obj.lightning.opacity=255
                    --this_obj.glow_cloud.opacity=255
                elseif this_obj.l_elapsed > this_obj.l_thresh then
                    
                    this_obj.l_elapsed = 0
                    --self.l_index = self.l_index%#imgs.lightning+1
                    --self.lightning.source=imgs.lightning[self.l_index]
                    this_obj.lightning.opacity=255
                    --this_obj.glow_cloud.opacity=255
                elseif this_obj.lightning.opacity==255 then
                    this_obj.lightning.opacity=0
                    --this_obj.glow_cloud.opacity=0
                    
                    this_obj.l_index = this_obj.l_index%#imgs.lightning+1
                    this_obj.lightning.source=imgs.lightning[this_obj.l_index]
                end
            end
        },
    }
    
}
--[[
local prev_rain_drops = {}
rain_drops = function(x,y,clone_src,speed,flipped) return{
    
    setup = function(self)
        if #prev_rain_drops ~= 0 then
            
        end
        --self.speed = speed
        local r = math.random(1,#imgs.reg_clouds.sm)
        self.img = Clone{
            name="small",
            source=clone_src,
            x=x,--+math.random(0,10)*10,
            y=y,
            opacity=255*.5
        }
        if flipped then
            self.img.y_rotation={180,0,0}
            self.img.x = self.img.x + self.img.w
        end
        curr_condition:add(self.img)
        self.img:animate{duration=(screen_h-self.img.y)/speed,y=screen_h,on_completed=
            function()
                self.img.unparent()
                tabl.insert(prev_rain_drops,self)
            end
        }
    end,
    func_tbls={
        drop={
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.y = this_obj.img.y + this_obj.speed*secs
                if this_obj.img.y > screen_h then
                    animate_list[this_func_tbl]=nil
                    this_obj.img:unparent()
                    --this_obj.img = nil
                end
            end
        }
    },

}end
--]]
local prev_t_drops = {}

--rain = {
tstorm = {
    drops = {},
    r_thresh   = 200,
    r_elapsed  = 200,
    
    l_thresh   = 5000,
    l_elapsed  = 5000,
    l_len      = 100,
    
    l_index = 1,
    r_flip = true,
    state="OFF",
    
    glow_cloud = Clone{source=imgs.glow_cloud,y=650,opacity=0},
    base_cloud = Clone{source=imgs.rain_clouds.lg[1],y=650,x=-imgs.rain_clouds.lg[1].w},
    lightning  = Clone{source=imgs.lightning[1],y=screen_h-imgs.lightning[1].h*2/3,opacity=0},
    

    setup = function(self)
            if self.rain_timer == nil then
                self.rain_timer = Timer{interval=200,on_timer=
                    function()
                        self.r_flip = not self.r_flip
                        
                        temp_var = Clone{
                            source=imgs.rain.falling,
                            x=-30,--+math.random(0,10)*10,
                            y=765,
                            opacity=255*.5
                        }
                        if self.r_flip then
                            temp_var.y_rotation={180,0,0}
                            temp_var.x = temp_var.x + temp_var.w
                        end
                        temp_var:animate{duration=(screen_h-temp_var.y)/600,y=screen_h,on_completed=
                            function()
                                temp_var.unparent()
                                tabl.insert(prev_rain_drops,temp_var)
                            end
                        }
                        curr_conditions:add(temp_var)
                        
                        temp_var = Clone{
                            source=imgs.rain.falling,
                            x=221-30,--+math.random(0,10)*10,
                            y=777,
                            opacity=255*.5
                        }
                        if self.r_flip then
                            temp_var.y_rotation={180,0,0}
                            temp_var.x = temp_var.x + temp_var.w
                        end
                        temp_var:animate{duration=(screen_h-temp_var.y)/600,y=screen_h,on_completed=
                            function()
                                temp_var.unparent()
                                tabl.insert(prev_rain_drops,temp_var)
                            end
                        }
                        curr_conditions:add(temp_var)
                        self.base_cloud:raise_to_top()
                        --[[
                        temp_var = rain_drops(-30,765,imgs.rain.falling,600,self.r_flip)
                        temp_var:setup()
                        --animate_list[r.func_tbls.drop] = r
                        temp_var = rain_drops(221-30,777,imgs.rain.falling,600,self.r_flip)
                        temp_var:setup()
                        --animate_list[r.func_tbls.drop] = r
                        --]]
                    end
                }
                self.l_timer = Timer{interval=5000,on_timer=
                    function()
                        if interval == 5000 then
                            interval = 200
                        else
                            interval = 5000
                        end
                        self.l_index = self.l_index%#imgs.lightning+1
                        self.lightning.source=imgs.lightning[self.l_index]
                        self.lightning.opacity=255
                        self.glow_cloud.opacity=255
                        self.lightning:animate{duration=100,opacity=0}
                        self.glow_cloud:animate{duration=100,opacity=0}
                    end
                }
            end
            curr_condition:add(self.lightning,self.base_cloud,self.glow_cloud)
            
            self.base_cloud:animate{duration=400,x=0,on_completed=
                function()
                    self.l_timer:start()
                    self.rain_timer:start()
                end
            }
    end,
    
    func_tbls = {
        tstorm_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.r_elapsed = this_obj.r_elapsed + secs*1000
                this_obj.l_elapsed = this_obj.l_elapsed + secs*1000
                
                if this_obj.r_elapsed > this_obj.r_thresh then
                    --local r = rain_drops_1()
                    --animate_list[r] = r
                    this_obj.r_flip = not this_obj.r_flip
                    local r = rain_drops(-30,765,imgs.rain.falling,600,this_obj.r_flip)
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    r = rain_drops(221-30,777,imgs.rain.falling,600,this_obj.r_flip)
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    this_obj.r_elapsed = 0
                end
                
                if this_obj.l_elapsed < this_obj.l_len or
                  (this_obj.l_elapsed > 3*this_obj.l_len and
                   this_obj.l_elapsed < 4*this_obj.l_len) then
                    this_obj.lightning.opacity=255
                    this_obj.glow_cloud.opacity=255
                elseif this_obj.l_elapsed > this_obj.l_thresh then
                    
                    this_obj.l_elapsed = 0
                    --self.l_index = self.l_index%#imgs.lightning+1
                    --self.lightning.source=imgs.lightning[self.l_index]
                    this_obj.lightning.opacity=255
                    this_obj.glow_cloud.opacity=255
                elseif this_obj.lightning.opacity==255 then
                    this_obj.lightning.opacity=0
                    this_obj.glow_cloud.opacity=0
                    
                    this_obj.l_index = this_obj.l_index%#imgs.lightning+1
                    this_obj.lightning.source=imgs.lightning[this_obj.l_index]
                end
                this_obj.base_cloud:raise_to_top()
                --print("tis")
            end,
        },
        fade_out = {
            duration = 400,
            func = function(this_obj,this_func_tbl,secs,p)
                
                if this_obj.glow_cloud.opacity - 255/200*secs < 0 then
                    this_obj.glow_cloud.opacity = 0
                else
                    this_obj.glow_cloud.opacity = this_obj.glow_cloud.opacity - 255/200*secs
                end
                
                this_obj.base_cloud.x = -this_obj.base_cloud.w*(p)
                
                if this_obj.lightning.opacity - 255/200*secs < 0 then
                    this_obj.lightning.opacity = 0
                else
                    this_obj.lightning.opacity = this_obj.lightning.opacity - 255/200*secs
                end
                
            end
        },
        fade_in = {
            duration = 400,
            func = function(this_obj,this_func_tbl,secs,p)
                
                this_obj.base_cloud.x = -this_obj.base_cloud.w*(1-p)
                if p==1 then
                    animate_list[this_obj.func_tbls.tstorm_loop] = this_obj
                    --this_obj.r_thresh=200
                end
            end
        },
    },
    remove = function(self)
        self.glow_cloud:unparent()
        self.base_cloud:unparent()
        self.lightning:unparent()

    end
}

snow_flake_flurry = function(speed_x,speed_y,x,y) return{
    
    setup = function(self)
        local s = math.random(12,20)/20*math.random(12,20)/20
local ss = s*(1+math.random(-10,10)/50)
        self.speed_x = speed_x*s
        self.speed_y = speed_y
        self.x = x
        local r = math.random(1,#imgs.snow_flake.lg)
        self.img = Clone{
            name="lg flake",
            source=imgs.snow_flake.lg[r],
            x=-100,--self.x,--+math.random(0,10)*10,
            y=y,
            opacity=255*s*(1+math.random(-10,10)/50),
            scale = {s,s},
            anchor_point = {imgs.snow_flake.lg[r].w/2-math.random(10,60),imgs.snow_flake.lg[r].h/2}
        }
        curr_condition:add(self.img)
    end,
    func_tbls={
        drop={
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.y = this_obj.img.y + this_obj.speed_y*secs
                this_obj.img.x = this_obj.img.x + this_obj.speed_x*secs
                --this_obj.img.scale = {this_obj.img.scale[1] + 4*secs,this_obj.img.scale[1] + 4*secs}
                if this_obj.img.y > screen_h+200 then
                    animate_list[this_func_tbl]=nil
                    this_obj.img:unparent()
                    --this_obj.img = nil
                end
            end
        },
        whirl = {
            duration = math.random(900,1100)*10,
            loop = true,
            func=function(this_obj,this_func_tbl,secs,p)
                --this_obj.img.x = this_obj.x + 5*math.sin(math.pi*4*p)
                this_obj.img.z_rotation = {360*p,0,0}
            end
        }
    },
    hurry_out = function(self)
        self.speed_y=200
    end

}end

local prev_snow_flake_lg={}
local num = 0
snow_flake_lg = function(speed_x,speed_y,x,y)

    if #prev_snow_flake_lg ~= 0 then
        local flake = table.remove(prev_snow_flake_lg)
        flake.setup = function(self)
            self.img.x   = -100
            self.img.y   = y
            curr_condition:add(self.img)
        end
        return flake
    else
        num = num+1
        --print(num)
        return{
            setup = function(self)
                local s = math.random(12,20)/20*math.random(12,20)/20
                local ss = s*(1+math.random(-10,10)/50)
                self.speed_x = speed_x*s
                self.speed_y = speed_y
                self.x = x
                local r = math.random(1,#imgs.snow_flake.lg)
                self.img = Clone{
                    name="lg flake",
                    source=imgs.snow_flake.lg[r],
                    x=-100,--self.x,--+math.random(0,10)*10,
                    y=y,
                    opacity=255*s*(1+math.random(-10,10)/50),
                    scale = {s,s},
                    anchor_point = {imgs.snow_flake.lg[r].w/2-math.random(60,120),imgs.snow_flake.lg[r].h/2}
                }
                curr_condition:add(self.img)
            end,
            func_tbls={
                drop={
                    func=function(this_obj,this_func_tbl,secs,p)
                        if this_obj.speed_y > 200 then
                            print(this_obj.speed_y)
                        end
                        this_obj.img.y = this_obj.img.y + this_obj.speed_y*secs
                        this_obj.img.x = this_obj.img.x + this_obj.speed_x*secs
                        --this_obj.img.scale = {this_obj.img.scale[1] + 4*secs,this_obj.img.scale[1] + 4*secs}
                        if this_obj.img.y > screen_h+100 then
                            animate_list[this_func_tbl]=nil
                            this_obj.img:unparent()
                            table.insert(prev_snow_flake_lg,this_obj)
                            --this_obj.img = nil
                        end
                    end
                },
                whirl = {
                    duration = math.random(900,1100)*5,
                    loop = true,
                    func=function(this_obj,this_func_tbl,secs,p)
                        --this_obj.img.x = this_obj.x + 5*math.sin(math.pi*4*p)
                        this_obj.img.z_rotation = {360*p,0,0}
                    end
                }
            },
        }
    end
end
local prev_flakes = {}
snow = {
    thresh   = 689,
    elapsed  = 2000,
    sm_elapsed  = 2000,
    snow_corner = Clone{source=imgs.snow_corner,y=screen_h-imgs.snow_corner.h+30,x=-10,opacity=0},
    
    state="NONE",
    remove=function(self)
        self.snow_corner:unparent()
    end,
    setup = function(self)
        if self.flake_timer == nil then
            self.flake_timer = Timer{
                interval = 700,
                on_timer = function()
                    local flake
                    if #prev_flakes ~= 0 then
                        flake = table.remove(prev_flakes)
                    else
                        local s = math.random(12,20)/20*math.random(12,20)/20
                        flake = Clone{
                            source = imgs.snow_flake.lg[math.random(1,#imgs.snow_flake.lg)],
                            scale  = {s,s},
                            opacity=255*s*(1+math.random(-10,10)/50),
                        }
                    end
                    if self.state == "SNOW" then
                        flake.anchor_point = {
                            flake.w/2-math.random(60,120),
                            flake.h/2
                        }
                        flake:animate={
                            duration=400,
                            x = math.random(200,screen_w/2),
                            y = screen_h+100,
                            z_rotation = math.random(100,360),
                            on_completed=function()
                                
                            end
                        }
                    else
                        flake.anchor_point = {
                            flake.w/2-math.random(10,60),
                            flake.h/2
                        }
                        flake:animate={
                            duration=4000,
                            x = math.random(100,screen_w/4),
                            y = screen_h+100,
                            z_rotation = math.random(100,360),
                            on_completed=function()
                                
                            end
                        }
                    end
                    
                    curr_condition:add(flake)
                end
            }
        end
        curr_condition:add(self.snow_corner)
    end,
    remove = function(self)
        self.snow_corner:unparent()
    end
    --[[
    func_tbls = {
        flurry_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.elapsed = this_obj.elapsed + secs*1000
                
                if this_obj.elapsed > this_obj.thresh then
                    
                    local r = snow_flake_flurry(
                        math.random(50,100),20,
                        math.random(-100,-10),math.random(750,950)
                    )
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    
                    
                    animate_list[r.func_tbls.whirl] = r
                    this_obj.elapsed = 0
                    
                end
                
                this_obj.snow_corner:raise_to_top()
            end,
        },
        fade_in = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.snow_corner.opacity=255*p
            end
        },
        fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.snow_corner.opacity=255*(1-p)
            end
        },
        snow_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.elapsed = this_obj.elapsed + secs*1000
                this_obj.sm_elapsed = this_obj.sm_elapsed + secs*1000
                
                if this_obj.elapsed > this_obj.thresh/16 then
                    
                    local r = snow_flake_lg(
                        math.random(500,600),
                        200,
                        -math.random(30,100),
                        math.random(600,950)
                    )
                    r:setup()
                    animate_list[r.func_tbls.drop] = r
                    
                    
                    animate_list[r.func_tbls.whirl] = r
                    this_obj.elapsed = 0
                    
                end
                
                this_obj.snow_corner:raise_to_top()
            end,
        },
    }
    --]]
}


fog = {
    state="NONE",
    img = Clone{source=imgs.fog,opacity=0,y=screen_h-imgs.fog.h},
    setup = function(self)
        curr_condition:add(self.img)
    end,
    remove = function(self)
        self.img:unparent()
    end,
    func_tbls ={
        fade_in = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                if this_obj.img == nil then
                    this_obj.img = Clone{source=imgs.fog,opacity=0,y=screen_h-imgs.fog.h}
                    curr_condition:add(this_obj.img)
                end
                this_obj.img.opacity=255*p
                if p == 1 then
                    this_obj.state="FULL"
                end
            end
        },
        fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.img.opacity=255*(1-p)
                if p == 1 then
                    this_obj.state="NONE"
                    this_obj.img:unparent()
                end
            end
        },
        half_to_full_opacity = {
            duration=500,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.opacity = 255*.5+255*.5*p
                if p == 1 then
                    this_obj.state="FULL"
                end
            end
        },
        full_to_half_opacity = {
            duration=500,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.img.opacity = 255*.5+255*.5*(1-p)
                if p == 1 then
                    this_obj.state="HALF"
                end
            end
        },
    }
}

local no_conditions = {
    sun       =  "SET",
    moon      =  "SET",
    tstorm    =  "OFF",
    wiper     = "NONE",
    clouds    = "NONE",
    fog       = "NONE",
    snow      = "NONE",
    chance_of = "NONE"
}

time_of_day = "DAY"
local set_states = function(t)
    
    for k,v in pairs(no_conditions) do
        if  t[k] == nil then
            t[k] =  v
        end
    end
    
    if t.sun ~= "SET" and time_of_day == "NIGHT" then
        t.sun = "SET"
        t.moon="RISEN"
    end
    
    if t.sun ~= nil and t.sun ~= sun.state then
        if t.sun == "SET" then
            --animate_list[sun.func_tbls.rise]=nil
            --animate_list[sun.func_tbls.set]=sun
            sun.group:animate{duration=2000,y=screen_h,on_completed=
                function()
                    sun.flare[1]:complete_animation()
                    sun.flare[2]:complete_animation()
                    sun.flare[3]:complete_animation()
                end
            }
        end
        if sun.state == "SET" then
            sun:setup()
            --animate_list[sun.func_tbls.set]=nil
            --animate_list[sun.func_tbls.rise]=sun
            if t.sun == "HALF" then
                sun.group.opacity=255*.5
            else
                sun.group.opacity=255
            end
        else
            if t.sun == "HALF" then
                --animate_list[sun.func_tbls.half_to_full_opacity]=nil
                --animate_list[sun.func_tbls.full_to_half_opacity]=sun
                sun.group:animate{duration=2000,opacity=255*.5}
            elseif t.sun == "FULL" then
                --animate_list[sun.func_tbls.full_to_half_opacity]=nil
                --animate_list[sun.func_tbls.half_to_full_opacity]=sun
                sun.group:animate{duration=2000,opacity=255}
            end
        end
        sun.state = t.sun
    end
    
    if t.moon ~= nil and t.moon ~= moon.state then
        if t.moon == "SET" then
            --animate_list[moon.func_tbls.set]=moon
            moon.group:animate{duration=2000,y=63 + (screen_h-709)}
            moon.stars:animate{duration=2000,opacity=0}
            moon.twinkle_timer:stop()
        else
            moon:setup()
            --animate_list[moon.func_tbls.rise]=moon
        end
        moon.state = t.moon
    end
    
    if t.tstorm ~= nil and t.tstorm ~= tstorm.state then
        print("oooo")
        if t.tstorm == "ON" then
            tstorm:setup()
            --animate_list[tstorm.func_tbls.fade_in]=tstorm
        else
            tstorm.l_timer:stop()
            tstorm.rain_timer:stop()
            tstorm.base_cloud:animate{duration=400,x=-this_obj.base_cloud.w}
            --animate_list[tstorm.func_tbls.fade_out]=tstorm
        end
        tstorm.state = t.tstorm
    end
    
    if t.clouds ~= nil and t.clouds ~= cloud_spawner.state then
        
        if cloud_spawner.state == "NONE" then
            --animate_list[cloud_spawner.func_tbls.spawn_loop] = cloud_spawner
            cloud_spawner:setup()
        end
        
        if t.clouds == "NONE" then
            cloud_spawner:remove()
        elseif t.clouds == "PARTLY" then
            cloud_spawner:rem_last_cloud()
            cloud_spawner.lg_cloud_timer.interval=60000
            cloud_spawner.sm_cloud_timer.interval=40000
        elseif t.clouds == "MOSTLY" then
            cloud_spawner.lg_cloud_timer.interval=40000
            cloud_spawner.sm_cloud_timer.interval=20000
        end
        cloud_spawner.state = t.clouds
    end

    if t.wiper ~= nil and t.wiper ~= wiper.state then
        if wiper.state == "NONE" then
            wiper:setup()
            wiper.wiper_rain:animate{duration=500,opacity=255}
            wiper.rain_timer:start()
        elseif wiper.state == "F_RAIN"
            wiper.wiper_freeze:animate{duration=500,opacity=0}
        elseif wiper.state == "SLEET"
            wiper.snow_blade:animate{duration=500,opacity=0}
            wiper.snow_timer:stop()
        elseif wiper.state == "RAIN"
        end
        
        wiper.state = t.wiper
        
        if wiper.state == "NONE" then
            wiper.wiper_rain:animate{duration=500,opacity=0}
            wiper.rain_timer:stop()
            if wiper.wiper_blade.opacity==255 then
                wiper.wiper_blade:animate{duration=500,opacity=0}
            end
        elseif wiper.state == "F_RAIN"
            wiper.wiper_freeze:animate{duration=500,opacity=255}
        elseif wiper.state == "SLEET"
            wiper.snow_timer:start()
            wiper.snow_blade:animate{duration=500,opacity=255}
        elseif wiper.state == "RAIN"
            wiper.wiper_blade:animate{duration=500,opacity=255}
        end
    end
    
    if t.fog ~= nil and t.fog ~= fog.state then
        
        if t.fog == "NONE" then
            --animate_list[fog.func_tbls.fade_out]=fog
            fog.img:animate{duration=500,opacity=0,on_completed=function fog:remove() end}
        end
        if fog.state == "NONE" then
            fog:setup()
            --animate_list[fog.func_tbls.fade_in]=fog
        end
        if t.fog == "HALF" then
            --animate_list[fog.func_tbls.full_to_half_opacity]=fog
            fog.img:animate{duration=500,opacity=255*.5}
        elseif t.fog == "FULL" then
            --animate_list[fog.func_tbls.half_to_full_opacity]=fog
            fog.img:animate{duration=500,opacity=255}
        end
    end
    if t.snow ~= nil and t.snow ~= snow.state then
        if snow.state == "NONE" then
            snow:setup()
            --animate_list[snow.func_tbls.fade_in] = snow
            snow.snow_corner:animate{duration=500,opacity=255}
        end
        
        snow.state = t.snow
        
        if snow.state == "NONE" then
            snow.snow_corner:animate{duration=500,opacity=0,
                on_completed=function()
                    snow:remove()
                end
            }
        end
        --[[
        if snow.state == "NONE" then
            snow:setup()
            animate_list[snow.func_tbls.fade_in] = snow
        elseif snow.state == "FLURRY" then
            animate_list[snow.func_tbls.flurry_loop] = nil
        elseif snow.state == "SNOW" then
            animate_list[snow.func_tbls.snow_loop]   = nil
        end
        
        snow.state = t.snow
        
        if snow.state == "NONE" then
            animate_list[snow.func_tbls.fade_out] = snow
        elseif snow.state == "FLURRY" then
            animate_list[snow.func_tbls.flurry_loop] = snow
        elseif snow.state == "SNOW" then
            animate_list[snow.func_tbls.snow_loop]   = snow
        end
        --]]
        
    end
    if t.chance_of ~= nil and t.chance_of ~= chance_of.state then
        if chance_of.state == "NONE" then
            chance_of:setup()
        elseif chance_of.state == "FLURRIES" then
            animate_list[chance_of.func_tbls.flurries_loop] = nil
        elseif chance_of.state == "RAIN" then
            animate_list[chance_of.func_tbls.rain_loop] = nil
        elseif chance_of.state == "F_RAIN" then
            animate_list[chance_of.func_tbls.rain_loop] = nil
            animate_list[chance_of.func_tbls.frost_loop] = nil
        elseif chance_of.state == "SLEET" then
            animate_list[chance_of.func_tbls.rain_loop] = nil
            animate_list[chance_of.func_tbls.snow_loop] = nil
        elseif chance_of.state == "SNOW" then
            animate_list[chance_of.func_tbls.snow_loop] = nil
        elseif chance_of.state == "TSTORMS" then
            animate_list[chance_of.func_tbls.rain_loop] = nil
            animate_list[chance_of.func_tbls.lightning_loop] = nil
        end
        
        chance_of.state = t.chance_of
        
        if chance_of.state == "NONE" then
            animate_list[chance_of.func_tbls.fade_out] = chance_of
        elseif chance_of.state == "FLURRIES" then
            animate_list[chance_of.func_tbls.flurries_loop] = chance_of
        elseif chance_of.state == "RAIN" then
            animate_list[chance_of.func_tbls.rain_loop] = chance_of
        elseif chance_of.state == "F_RAIN" then
            animate_list[chance_of.func_tbls.rain_loop] = chance_of
            animate_list[chance_of.func_tbls.frost_loop] = chance_of
        elseif chance_of.state == "SLEET" then
            animate_list[chance_of.func_tbls.rain_loop] = chance_of
            animate_list[chance_of.func_tbls.snow_loop] = chance_of
        elseif chance_of.state == "SNOW" then
            animate_list[chance_of.func_tbls.snow_loop] = chance_of
        elseif chance_of.state == "TSTORMS" then
            animate_list[chance_of.func_tbls.rain_loop] = chance_of
            animate_list[chance_of.func_tbls.lightning_loop] = chance_of
        end
    end
    
end

conditions = {
    ["Chance of Flurries"]       = function() set_states{sun="FULL",chance_of="FLURRIES"} end,
    ["Chance of Rain"]           = function() set_states{sun="FULL",chance_of="RAIN"     }end,
    ["Chance of Freezing Rain"]  = function() set_states{sun="FULL",chance_of="F_RAIN"} end,
    ["Chance of Sleet"]          = function() set_states{sun="FULL",chance_of="SLEET"} end,
    ["Chance of Snow"]           = function() set_states{sun="FULL",chance_of="SNOW"} end,
    ["Chance of Thunderstorms"]  = function() set_states{sun="FULL",chance_of="TSTORMS"} end,
    ["Chance of a Thunderstorm"] = nil,
    ["Clear"]                    = nil,
    ["Cloudy"]                   = nil,
    ["Flurries"]                 = function() set_states{snow="FLURRY"} end,
    ["Fog"]                      = function() set_states{sun="FULL",clouds="PARTLY",fog="FULL"} end,
    ["Haze"]                     = function() set_states{sun="FULL",fog="FULL"} end,
    ["Mostly Cloudy"]            = function() set_states{sun="FULL", clouds="MOSTLY"} end,
    ["Mostly Sunny"]             = nil,
    ["Partly Cloudy"]            = function() set_states{sun="FULL",clouds="PARTLY"} end,
    ["Partly Sunny"]             = nil,
    ["Freezing Rain"]            = function() set_states{wiper  = "F_RAIN"} end,
    ["Rain"]                     = function() set_states{wiper="RAIN"} end,
    ["Sleet"]                    = function() set_states{wiper="SLEET"} end,
    ["Snow"]                     = function() set_states{fog="HALF",snow="SNOW"} end,
    ["Sunny"]                    = function() set_states{sun="FULL"} end,
    ["Thunderstorms"]            = function() set_states{tstorm="ON"} end,
    ["Thunderstorm"]             = nil,
    ["Unknown"]                  = function() set_states{} end,
    ["Overcast"]                 = function() set_states{sun="HALF",clouds="MOSTLY",fog="FULL"} end,
    ["Scattered Clouds"]         = nil,
}

conditions["Clear"]                  = conditions["Sunny"]
--conditions["Chance of Sleet"]        = conditions["Chance of Freezing Rain"]
conditions["Partly Sunny"]           = conditions["Mostly Cloudy"]
conditions["Cloudy"]                 = conditions["Mostly Cloudy"]
conditions["Mostly Sunny"]           = conditions["Partly Cloudy"]
conditions["Scattered Clouds"]       = conditions["Partly Cloudy"]
conditions["Thunderstorm"]           = conditions["Thunderstorms"]
conditions["Chance of Thunderstorm"] = conditions["Chance of Thunderstorms"]

--conditions["Chance of Rain"]()