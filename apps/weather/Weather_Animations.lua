--[==[
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
        if self.group.parent == nil then
            curr_condition:add(self.group)
        end
        animate_list[self.func_tbls.shine] = self
        
    end,
    
    
    
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
                    animate_list[this_obj.func_tbls.shine] = nil
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
            
        end
        
        if self.group.parent == nil then
            curr_condition:add(self.group)
            
            self.group:lower_to_bottom()
        end
    end,

    func_tbls = {
        rise  = {
            duration=2000,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.stars.opacity=255*p
                this_obj.moon.y = 63 + (screen_h-709) *(1-math.sin(math.pi/2*p))
                if p == 1 then
                    this_obj.state="RISEN"
                    animate_list[this_obj.func_tbls.twinkle] = this_obj
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
                    this_obj:remove()
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
    remove = function(self)
        self.group:unparent()
    end,
}


lg_cloud = function() return{
    
    setup = function(self)
        self.speed = math.random(4,6)
        local r = math.random(1,#imgs.reg_clouds.lg)
        --self.start = -imgs.reg_clouds.lg[r].w
        self.img = Clone{
            name="lg_cloud",
            source=imgs.reg_clouds.lg[r],
            x=40,--self.start,
            y=670+math.random(0,150),
            opacity=0
        }
        
        
        curr_condition:add(self.img)
    end,
    
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
    hurry_out = function(self)
        self.speed = 300
        animate_list[self.func_tbls.drift]=self
    end

}end

sm_cloud = function() return{
    
    setup = function(self)
        self.speed = math.random(4,8)
        local r = math.random(1,#imgs.reg_clouds.sm)
        --self.start = -imgs.reg_clouds.sm[r].w
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
    cloud_list = {},
    rem_last_cloud = function(self)
        if self.last_cloud == nil then return end
        self.last_cloud:hurry_out()
        self.last_cloud = nil
    end,
    remove = function(self)
        for k,v in pairs(self.cloud_list) do
            k:hurry_out()
        end
        animate_list[self.func_tbls.spawn_loop] = nil
        self.state = "NONE"
        self.last_cloud = nil
        self.lg_elapsed_1 = 60000
        self.lg_elapsed_2 = 90000
        self.sm_elapsed   = 40000
        
    end
    
}

rain_drops = function(x,y,clone_src,speed,flipped) return{
    
    setup = function(self)
        self.speed = speed
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
            --anchor_point = {imgs.snow_flake.lg[r].w/2,imgs.snow_flake.lg[r].h/2},
            scale = {0,0}
        }
        self.img.anchor_point = {self.img.w/2,self.img.h/2}
        curr_condition:add(self.img)
    end,
    check_wipe = function(self,deg_1,deg_2)
        if deg_2 < self.deg and self.deg < deg_1 then
            --animate_list[self.func_tbls.fade_out] = self
            --self.img.opacity=0
            self.img:unparent()
        end
    end,
    func_tbls={
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
    },

}end
local prev_drops = {}
window_drops = function(x,y,deg)

    if #prev_drops ~= 0 then
        local drop = table.remove(prev_drops)
        drop.setup = function(self)
            self.img.x =   x
            self.img.y =   y
            self.deg   = deg
            self.img.scale={0,0}
            self.img.opacity=255*.75
            if self.img.parent == nil then
                curr_condition:add(self.img)
            end
            self.func_tbls.stick.elapsed = 0
        end
        return drop
    end
    return{
        
        setup = function(self)
            self.deg = deg
            local r = math.random(1,#imgs.rain.drops)
            self.img = Clone{
                name="small",
                source=imgs.rain.drops[r],
                x=x,--+math.random(0,10)*10,
                y=y,
                opacity=255*.75,
                --anchor_point = {imgs.rain.drops[r].w/2,imgs.rain.drops[r].h/2},
                scale = {0,0}
            }
            self.img.anchor_point = {self.img.w/2,self.img.h/2}
            curr_condition:add(self.img)
        end,
        check_wipe = function(self,deg_1,deg_2)
            if deg_2 < self.deg and self.deg < deg_1 then
                self.img:unparent()
                table.insert(prev_drops,self)
                animate_list[self.func_tbls.stick] =nil
                return true
            end
            return false
        end,
        func_tbls={
            stick = {
                duration = 100,
                func=function(this_obj,this_func_tbl,secs,p)
                    this_func_tbl.s = .75*math.sin(math.pi/2*p)
                    this_obj.img.scale={this_func_tbl.s,this_func_tbl.s}
                end
            },
        },
    }
end

wiper = {
    drops    = {},
    rain_thresh   = 200,
    rain_elapsed  =   0,
    snow_thresh   = 200,
    snow_elapsed  =   0,
    state    = "NONE", -- "RAIN", "F_RAIN", "SLEET"
    
    remove   = function(self)
        self.wiper_rain:unparent()
        self.wiper_freeze:unparent()
        self.wiper_blade:unparent()
        self.snow_blade:unparent()
        
        --self.wiper_rain   = nil
        --self.wiper_freeze = nil
        --self.wiper_blade  = nil
        --self.snow_blade   = nil
        
        animate_list[self.func_tbls.rain_loop] = nil
        animate_list[self.func_tbls.snow_loop] = nil
    end,
    
    setup    = function(self)
        if self.wiper_blade == nil then
            self.snow_blade   = Clone{
                source=imgs.wiper.snow_blade,
                x=-124+50,
                y=screen_h+30,
                opacity=0
            }
            self.wiper_blade  = Clone{
                source=imgs.wiper.blade,
                x=-124+50,
                y=screen_h+30,
                opacity=0
            }
            self.wiper_rain   = Clone{
                source=imgs.wiper.corner,
                y=573,
                opacity=0
            }
            self.wiper_freeze = Clone{
                source=imgs.wiper.freezing,
                y=760,
                opacity=0
            }
            self.snow_blade.anchor_point = {50,self.snow_blade.h}
            self.snow_blade.anchor_point = {50,self.wiper_blade.h}
        end
        
        if self.wiper_blade.parent == nil then
            curr_condition:add(
                self.wiper_rain,
                self.wiper_freeze,
                self.wiper_blade,
                self.snow_blade
            )
        end
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
                    p = p*4 -- 0 - 1/4 goes to 0 - 1
                    for k,v in pairs(this_obj.drops) do
                        
                        if k:check_wipe(
                                this_obj.wiper_blade.z_rotation[1],
                                p*-100-5
                            ) then
                            
                            this_obj.drops[k] = nil
                        end
                    end
                    --this_obj.func_tbls.wipe_up(this_obj,p*4)
                    this_obj.wiper_blade.z_rotation={-100*p,0,0}
                elseif p < 2/4 then
                    p = 2-p*4 -- 1/4 - 2/4 goes to 1 - 0
                    for k,v in pairs(this_obj.drops) do
                        
                        if k:check_wipe(
                                p*-100+5,
                                this_obj.wiper_blade.z_rotation[1]
                            ) then
                            
                            this_obj.drops[k] = nil
                        end
                    end
                    --this_obj.func_tbls.wipe_up(this_obj,2-p*4)
                    this_obj.wiper_blade.z_rotation={-100*p,0,0}
                end
            end
        },
        snow_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.snow_elapsed = this_obj.snow_elapsed + secs*1000
                if this_obj.snow_elapsed > 100 then
                    
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
                    
                    this_obj.snow_elapsed = 0
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
                if p == 1 then
                    animate_list[this_obj.func_tbls.rain_loop] = nil
                    for k,v in pairs(this_obj.drops) do
                        k.img:unparent()
                    end
                    this_obj.drops = {}
                    this_obj:remove()
                end
            end,
        },
        frost_fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.wiper_freeze.opacity=255*(1-p)
                if p == 1 then
                    this_obj:remove()
                end
            end,
        },
        sleet_fade_out = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.snow_blade.opacity=255*(1-p)
                if p == 1 then
                    animate_list[this_obj.func_tbls.snow_loop]=nil
                    this_obj:remove()
                end
                
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
            --anchor_point = {imgs.snow_flake.sm[r].w/2,imgs.snow_flake.sm[r].h/2-20}
        }
        self.img.anchor_point={self.img.w/2,self.img.h/2-20}
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
                    animate_list[this_obj.func_tbls.seesaw]=nil
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
    
    lightning={},
    
    
    setup = function(self)
        
        if self.cloud_1 == nil then
            self.cloud_1   = Clone{source=imgs.reg_clouds.lg[2],y=802,}
            self.cloud_2   = Clone{source=imgs.reg_clouds.lg[1],y=812,}
            self.wiper_freeze   = Clone{name="wiper freeze",source=imgs.wiper.freezing, y=760,opacity=0}
            for i = 1,#imgs.lightning do
                self.lightning[i]   = Clone{source=imgs.lightning[i],opacity=0,y=850}
            end
            
            self.cloud_1.x=-self.cloud_1.w-50
            self.cloud_2.x=-self.cloud_2.w-20
        end
        
        if self.cloud_1.parent == nil then
            curr_condition:add(unpack(self.lightning))
            curr_condition:add(self.wiper_freeze,self.cloud_1,self.cloud_2)
        end
        self.wiper_freeze:lower_to_bottom()
        animate_list[self.func_tbls.fade_in] = self
    end,
    
    remove = function(self)
        self.cloud_1:unparent()
        self.cloud_2:unparent()
        self.wiper_freeze:unparent()
        
        --self.cloud_1 = nil
        --self.cloud_2 = nil
        --self.wiper_freeze = nil
        for i = 1, #self.lightning do
            self.lightning[i]:unparent()
            --self.lightning[i] = nil
        end
        
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
                this_obj.cloud_1.x = -50-this_obj.cloud_1.w*(p)
                --this_obj.cloud_2.x = -20-this_obj.cloud_2.w*(1-p)
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
                    this_obj.lightning[this_obj.l_index].opacity=0
                    return
                end
                this_obj.l_elapsed = this_obj.l_elapsed + secs*1000
                if this_obj.l_elapsed < this_obj.l_len or
                  (this_obj.l_elapsed > 3*this_obj.l_len and
                   this_obj.l_elapsed < 4*this_obj.l_len) then
                    this_obj.lightning[this_obj.l_index].opacity=255
                    --this_obj.glow_cloud.opacity=255
                elseif this_obj.l_elapsed > this_obj.l_thresh then
                    
                    this_obj.l_elapsed = 0
                    --self.l_index = self.l_index%#imgs.lightning+1
                    --self.lightning.source=imgs.lightning[self.l_index]
                    this_obj.lightning[this_obj.l_index].opacity=255
                    --this_obj.glow_cloud.opacity=255
                elseif this_obj.lightning[this_obj.l_index].opacity==255 then
                    this_obj.lightning[this_obj.l_index].opacity=0
                    --this_obj.glow_cloud.opacity=0
                    
                    this_obj.l_index = this_obj.l_index%#imgs.lightning+1
                end
            end
        },
    }
    
}

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
    
    lightning = {},


    setup = function(self)
        if self.glow_cloud == nil then
            self.glow_cloud = Clone{source=imgs.glow_cloud,y=650,opacity=0}
            self.base_cloud = Clone{source=imgs.rain_clouds.lg[1],y=650}
            self.base_cloud.x = -self.base_cloud.w
            for i = 1,#imgs.lightning do
                self.lightning[i]   = Clone{source=imgs.lightning[i],opacity=0}
                self.lightning[i].y = screen_h - self.lightning[i].h*2/3
            end
        end
        if self.glow_cloud.parent == nil then
            curr_condition:add(unpack(self.lightning))
            curr_condition:add(self.base_cloud,self.glow_cloud)
        end
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
                    this_obj.lightning[this_obj.l_index].opacity=255
                    this_obj.glow_cloud.opacity=255
                elseif this_obj.l_elapsed > this_obj.l_thresh then
                    
                    this_obj.l_elapsed = 0
                    --self.l_index = self.l_index%#imgs.lightning+1
                    --self.lightning.source=imgs.lightning[self.l_index]
                    this_obj.lightning[this_obj.l_index].opacity=255
                    this_obj.glow_cloud.opacity=255
                elseif this_obj.lightning[this_obj.l_index].opacity==255 then
                    this_obj.lightning[this_obj.l_index].opacity=0
                    this_obj.glow_cloud.opacity=0
                    
                    this_obj.l_index = this_obj.l_index%#imgs.lightning+1
                    --this_obj.lightning.source=imgs.lightning[this_obj.l_index]
                end
                this_obj.base_cloud:raise_to_top()
                --print("tis")
            end,
        },
        fade_out = {
            duration = 400,
            func = function(this_obj,this_func_tbl,secs,p)
                --[[
                if this_obj.glow_cloud.opacity < 255/200*secs then
                    this_obj.glow_cloud.opacity = 0
                else
                    this_obj.glow_cloud.opacity = this_obj.glow_cloud.opacity - 255/200*secs
                end
                --]]
                this_obj.base_cloud.x = -this_obj.base_cloud.w*(p)
                --[[
                if this_obj.lightning[this_obj.l_index].opacity < 255/200*secs then
                    this_obj.lightning[this_obj.l_index].opacity = 0
                else
                    this_obj.lightning[this_obj.l_index].opacity = this_obj.lightning[this_obj.l_index].opacity - 255/200*secs
                end
                --]]
                this_obj.lightning[this_obj.l_index].opacity = 255*(1-p)
                this_obj.glow_cloud.opacity= 255*(1-p)
                if p == 1 then
                    this_obj:remove()
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
        
        --self.glow_cloud = nil
        --self.base_cloud = nil
        
        for i = 1, #self.lightning do
            self.lightning[i]:unparent()
            --self.lightning[i] = nil
        end
    end
}

snow_flake_flurry = function(speed_x,speed_y,x,y) return{
    
    setup = function(self)
        local s  = math.random(12,20)/20*math.random(12,20)/20
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
        }
        self.img.anchor_point = {self.img.w/2-math.random(10,60),self.img.h/2}
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
                    snow.flakes[this_obj]=nil
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
            self.img.y   = y,
            
            curr_condition:add(self.img)
        end
        return flake
    else
        num = num+1
        
        return{
            setup = function(self)
                local s = math.random(12,20)/20*math.random(12,20)/20
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
                }
                self.img.anchor_point = {self.img.w/2-math.random(60,120),self.img.h/2}
                curr_condition:add(self.img)
            end,
            hurry_out = function(self)
                self.speed_y=200
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
                            snow.flakes[this_obj]=nil
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

snow = {
    thresh   = 689,
    elapsed  = 2000,
    sm_elapsed  = 2000,
    flakes = {},
    
    state="NONE",
    remove=function(self)
        self.snow_corner:unparent()
        --self.snow_corner = nil
    end,
    setup = function(self)
        if self.snow_corner == nil then
            self.snow_corner = Clone{source=imgs.snow_corner,x=-10,opacity=0}
            self.snow_corner.y=screen_h-self.snow_corner.h+30
        end
        
        if self.snow_corner.parent == nil then
            curr_condition:add(self.snow_corner)
        end
    end,
    hurry_out_flakes = function(self)
        for k,v in pairs(self.flakes) do
            k:hurry_out()
        end
    end,
    func_tbls = {
        flurry_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.elapsed = this_obj.elapsed + secs*1000
                
                if this_obj.elapsed > this_obj.thresh then
                    
                    local r = snow_flake_flurry(
                        math.random(50,100),20,
                        math.random(-100,-10),math.random(750,950)
                    )
                    this_obj.flakes[r] = r
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
                if p == 1 then
                    this_obj:remove()
                end
            end
        },
        snow_loop = {
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.elapsed = this_obj.elapsed + secs*1000
                this_obj.sm_elapsed = this_obj.sm_elapsed + secs*1000
                ---[[
                if this_obj.elapsed > this_obj.thresh/16 then
                    
                    local r = snow_flake_lg(
                        math.random(500,600),
                        200,
                        -math.random(30,100),
                        math.random(600,950)
                    )
                    r:setup()
                    this_obj.flakes[r] = r
                    animate_list[r.func_tbls.drop] = r
                    
                    
                    animate_list[r.func_tbls.whirl] = r
                    this_obj.elapsed = 0
                    
                end
                
                this_obj.snow_corner:raise_to_top()
            end,
        },
    }
}


fog = {
    state="NONE",
    setup = function(self)
        if self.img == nil then
            self.img = Clone{source=imgs.fog,opacity=0}
            self.img.y=screen_h-self.img.h
        end
        
        if self.img.parent == nil then
            curr_condition:add(self.img)
        end
    end,
    func_tbls ={
        fade_in = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                if this_obj.img == nil then
                    this_obj:setup()
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
                    --this_obj.img=nil
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
--]==]
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
            curr_condition:add(sun_g)
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
        if sun_state.state ~= "SET" then
            print("herer")
            curr_condition:add(moon_g)
            moon_g.twinkle:start()
        end
    end
    
    moon_state.timeline.on_completed = function()
        if sun_state.state == "SET" then
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
    
    local rain_launcher = Timer{
        interval = 100,
        on_timer = function(self)
            if launch_i > #rain then
                self:stop()
            else
                curr_condition:add(rain[launch_i])
                rain[launch_i]:lower_to_bottom()
                rain[launch_i].y = rain_y
                rain[launch_i]:animate{
                    duration = self.interval*#rain,
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
    print("rainsss",#rain)
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
    
    function tstorm_g:stop_rain()
        for i = 1, #rain do
            if rain[i].parent then
                rain[i]:stop_animation()
                rain[i]:animate{
                    duration = rain_launcher.interval*#rain * ((screen_h-rain[i].y)/(screen_h-rain_y)),
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
    
    tstorm_state.state = "SET"
    
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
    
    wiper_state.state = "OFF"
    
    local add_to_screen = function()
        
        curr_condition:add(
            snow_blade,
            wiper_blade,
            wiper_rain
        )
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
					print(flake.duration)
                    self:animate{
						duration   = flake.duration,
						--loop       = true,
						x          = self.x + flake.speed_x*flake.duration/1000,--math.random(screen_w/5,screen_h/2),
						y          = screen_h+100,
						z_rotation = (flake.duration/(math.random(900,1100)*10))*360,
                        on_completed = function(self)
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
        
        curr_condition:add(flake)
        
        flake:drift()
        
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
        if curr_state ~= next_state then
            
            if next_state == "OFF" then
                intermittent_rain_timer:stop()
                rain_drops_timer:stop()
            else
                intermittent_rain_timer:begin()
            end
            curr_state = next_state
        end
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
        rain_on = false
        self:start()
    end
    intermittent_timer:stop()
    local curr_state = "OFF"
    function chance_snow_state:next_state(next_state)
        if curr_state ~= next_state then
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
        end
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
    --print("\n")
    for k,default_state in pairs(no_conditions) do
        --print(k,t[k] or default_state )
        condition_states[k]:next_state(t[k] or default_state)
        
    end
    print("\n")
    
end
    
--[[ 
    
    for k,v in pairs(no_conditions) do
        if  t[k] == nil then
            t[k] =  v
        end
    end
    
    
    
    if t.sun ~= nil and t.sun ~= sun.state then
        if t.sun == "SET" then
            animate_list[sun.func_tbls.rise]=nil
            animate_list[sun.func_tbls.set]=sun
        end
        if sun.state == "SET" then
            sun:setup()
            animate_list[sun.func_tbls.set]=nil
            animate_list[sun.func_tbls.rise]=sun
        end
        if t.sun == "HALF" then
            animate_list[sun.func_tbls.half_to_full_opacity]=nil
            animate_list[sun.func_tbls.full_to_half_opacity]=sun
        elseif t.sun == "FULL" then
            animate_list[sun.func_tbls.full_to_half_opacity]=nil
            animate_list[sun.func_tbls.half_to_full_opacity]=sun
        end
        sun.state = t.sun
    end
    
    if t.moon ~= nil and t.moon ~= moon.state then
        if t.moon == "SET" then
            animate_list[moon.func_tbls.rise]=nil
            animate_list[moon.func_tbls.set]=moon
            moon.state = "SET"
        else
            moon:setup()
            animate_list[moon.func_tbls.set]=nil
            animate_list[moon.func_tbls.rise]=moon
            moon.state = "RISEN"
        end
    end
    
    if t.tstorm ~= nil and t.tstorm ~= tstorm.state then
        if t.tstorm == "ON" then
            tstorm:setup()
            animate_list[tstorm.func_tbls.fade_in]=tstorm
        else
            animate_list[tstorm.func_tbls.tstorm_loop]=nil
            animate_list[tstorm.func_tbls.fade_out]=tstorm
        end
        tstorm.state = t.tstorm
    end
    
    if t.clouds ~= nil and t.clouds ~= cloud_spawner.state then
        
        if cloud_spawner.state == "NONE" then
            animate_list[cloud_spawner.func_tbls.spawn_loop] = cloud_spawner
        end
        
        if t.clouds == "NONE" then
            cloud_spawner:remove()
        elseif t.clouds == "PARTLY" then
            cloud_spawner:rem_last_cloud()
            --cloud_spawner.state="PARTLY"
        elseif t.clouds == "MOSTLY" then

            --cloud_spawner.state="MOSTLY"
        end
        cloud_spawner.state = t.clouds
    end

    if t.wiper ~= nil and t.wiper ~= wiper.state then
        if wiper.state == "NONE" then
            wiper:setup()
            animate_list[wiper.func_tbls.reg_fade_in]=wiper
        end
        
        if t.wiper == "NONE" then
            animate_list[wiper.func_tbls.reg_fade_out]=wiper
            if wiper.state == "F_RAIN" then
                animate_list[wiper.func_tbls.frost_fade_out]=wiper
            elseif wiper.state == "SLEET" then
                animate_list[wiper.func_tbls.sleet_fade_out]=wiper
            end
        elseif t.wiper == "F_RAIN" then
            if wiper.state == "SLEET" then
                animate_list[wiper.func_tbls.sleet_fade_out]=wiper
            end
            animate_list[wiper.func_tbls.frost_fade_in]=wiper
        elseif t.wiper == "SLEET" then
            if wiper.state == "F_RAIN" then
                animate_list[wiper.func_tbls.frost_fade_out]=wiper
            end
            animate_list[wiper.func_tbls.sleet_fade_in]=wiper
        elseif t.wiper == "RAIN" then
            if wiper.state == "F_RAIN" then
                animate_list[wiper.func_tbls.frost_fade_out]=wiper
            elseif wiper.state == "SLEET" then
                animate_list[wiper.func_tbls.sleet_fade_out]=wiper
            end
        end
        wiper.state = t.wiper
    end
    
    if t.fog ~= nil and t.fog ~= fog.state then
        
        animate_list[fog.func_tbls.fade_out] = nil
        animate_list[fog.func_tbls.fade_in]  = nil
        animate_list[fog.func_tbls.full_to_half_opacity] = nil
        animate_list[fog.func_tbls.half_to_full_opacity] = nil
        
        if t.fog == "NONE" then
            animate_list[fog.func_tbls.fade_out]=fog
        end
        if fog.state == "NONE" then
            fog:setup()
            animate_list[fog.func_tbls.fade_in]=fog
        end
        if t.fog == "HALF" then
            animate_list[fog.func_tbls.full_to_half_opacity]=fog
        elseif t.fog == "FULL" then
            animate_list[fog.func_tbls.half_to_full_opacity]=fog
        end
    end
    if t.snow ~= nil and t.snow ~= snow.state then
        
        if snow.state == "NONE" then
            snow:setup()
            animate_list[snow.func_tbls.fade_in] = snow
        elseif snow.state == "FLURRY" then
            animate_list[snow.func_tbls.flurry_loop] = nil
        elseif snow.state == "SNOW" then
            animate_list[snow.func_tbls.snow_loop]   = nil
        end
        
        snow.state = t.snow
        snow:hurry_out_flakes()
        
        if snow.state == "NONE" then
            animate_list[snow.func_tbls.fade_out] = snow
        elseif snow.state == "FLURRY" then
            animate_list[snow.func_tbls.flurry_loop] = snow
        elseif snow.state == "SNOW" then
            animate_list[snow.func_tbls.snow_loop]   = snow
        end
        
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
--]]
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
    table.insert(all_anims,k)
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
conditions["Snow Grains"]         = conditions["Snow"]
conditions["Ice Crystals"]        = conditions["Snow"]
conditions["Ice Pellets"]         = conditions["Snow"]
conditions["Hail"]                = conditions["Snow"]
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










--conditions["Chance of Rain"]()
