
enemies.final_boss = function(is_boss,o)

    --re-using tables for 'rotate_guns_and_fire'
    local mock_obj = {group={z_rotation={0,0,0}}}
    local targ = {x=0,y=0}
    local me = {
        rr={x=0,y=0},
        rl={x=0,y=0},
        lr={x=0,y=0},
        ll={x=0,y=0}
    }
    local z_rot = {0,0,0}
    --re-using collision boxes
    local coll_box = {
        ll={},
        lr={},
        rl={},
        rr={}
    }

    add_to_render_list({
        health_body = 10,
        salvage_func = {"enemies","final_boss"},
        salvage_params = {is_boss},
        approach_speed = 70,
        drop_speed  = 0,
        drop_thresh = .3,
        turn_speed = 5,
        x_speed = 15,
        y_speed = 5,
        group = Group{
            anchor_point={
                curr_lvl_imgs.final_boss.w/2,
                curr_lvl_imgs.final_boss.h/2
            },
            x =  screen_w/2,
            y = -curr_lvl_imgs.final_boss.h/2
        },
        image = Clone{source=curr_lvl_imgs.final_boss},
        shoot_time=4,
        last_shot_time={ll=0,lr=0,rl=2,rr=2},
        prop  = {
            
            broke_ll = false,
            broke_lr = false,
            broke_rl = false,
            broke_rr = false,
            --[[
            dead_ll = Clone{source=imgs.boss_prop_d},
            dead_lr = Clone{source=imgs.boss_prop_d},
            dead_rl = Clone{source=imgs.boss_prop_d},
            dead_rr = Clone{source=imgs.boss_prop_d},
            --]]
            img_ll = {
				Clone{source=curr_lvl_imgs.boss_prop[1],x=431,y=384},
				Clone{source=curr_lvl_imgs.boss_prop[2],x=431,y=384,opacity=0}
			},
            img_lr = {
				Clone{source=curr_lvl_imgs.boss_prop[1],x=583,y=363},
				Clone{source=curr_lvl_imgs.boss_prop[2],x=583,y=363,opacity=0}
			},
            img_rl = {
				Clone{source=curr_lvl_imgs.boss_prop[1],x=803,y=363},
				Clone{source=curr_lvl_imgs.boss_prop[2],x=803,y=363,opacity=0}
			},
            img_rr = {
				Clone{source=curr_lvl_imgs.boss_prop[1],x=959,y=384},
				Clone{source=curr_lvl_imgs.boss_prop[2],x=959,y=384,opacity=0}
			},
        },
        guns = {
            img_ll = Clone{
				source=curr_lvl_imgs.boss_turret,
				position={390,240},
				anchor_point={
					curr_lvl_imgs.boss_turret.w/2,
					curr_lvl_imgs.boss_turret.h/3
				}
			},
            img_lr = Clone{
				source=curr_lvl_imgs.boss_turret,
				position={550,190},
				anchor_point={
					curr_lvl_imgs.boss_turret.w/2,
					curr_lvl_imgs.boss_turret.h/3
				}
			},
            img_rl = Clone{
				source=curr_lvl_imgs.boss_turret,
				position={923,190},
				anchor_point={
					curr_lvl_imgs.boss_turret.w/2,
					curr_lvl_imgs.boss_turret.h/3
				}
			},
            img_rr = Clone{
				source=curr_lvl_imgs.boss_turret,
				position={1070,240},
				anchor_point={
					curr_lvl_imgs.boss_turret.w/2,
					curr_lvl_imgs.boss_turret.h/3
				}
			},--[[
            g_ll   = Group{x=390,y=240},
            g_lr   = Group{x=550,y=190},
            g_rl   = Group{x=923,y=190},
            g_rr   = Group{x=1070,y=240},
			--]]
        },
        dying = false,
		remove = function(self)
			--print("grrrr")
			self.group:unparent()
		end,
        stages = {
            function(self,secs)
                self.group.y = self.group.y + self.approach_speed * secs
                
                if self.group.y >= self.image.h/2 then
                    self.stage = self.stage+1
                end
            end,
            function(self,secs)
                
                self.group.x = self.group.x + self.x_speed * secs
                self.group.y = self.group.y + self.y_speed * secs
                
                if self.group.x >= (screen_w - self.image.w/2) or
                    self.group.x <= (self.image.w/2)then
                    self.x_speed = -self.x_speed
                end
                if self.group.y >= (screen_h*2/3 - self.image.h/2) or
                    self.group.y <= (self.image.h/2)then
                    self.y_speed = -self.y_speed
                end
            end,
            function(self,secs)
                if self.drop_speed < self.drop_thresh then
                    self.drop_speed = self.drop_speed +secs/10
                end
                local scale = self.group.scale[1] - self.drop_speed * secs
                self.group.scale={scale,scale}
                self.group.x_rotation={self.group.x_rotation[1]+self.turn_speed*secs,0,0}
				self.group.z_rotation={self.group.z_rotation[1]+self.turn_speed/2*secs,0,0}
                if scale <= .1 then
                    points(self.group.x,self.group.y,5000)
                    
                    remove_from_render_list(self)
                    add_to_render_list(
                    explosions.splash(
                        self.group.x,
                        self.group.y
                    )
                    )
                    ---[[
                    if is_boss then
                        levels[state.curr_level]:level_complete()
                    end
                    --]]
                    
                end
            end,
        },
        stage  = 1,
        overwrite_vars = {},
        special_check = function(self,other)
            if self.dying then return end
            local y_off = self.group.y - self.group.anchor_point[2]
            local x_off = self.group.x - self.group.anchor_point[1]
            
            local gg_sz = other.x2 - other.x1
            local wing_tip = 418
            local ass_hole = 272
            
            
            --left side
            if
                (other.x2 <= (self.group.x + gg_sz/2)) and
                (other.x2 >= (self.group.x - self.image.w/2)) then
                
                if
                    (other.y1 - y_off  < ((ass_hole - wing_tip)/( self.image.w/2)*(other.x1- x_off) + wing_tip)  and
                    (other.y1 - y_off) > ((         - wing_tip)/( self.image.w/2)*(other.x1- x_off) + wing_tip)) then
                
                    self:collision(other.obj,"gen",{other.x1,other.y1})
                    
                    return true
                
                elseif
                    (other.y2 - y_off  < ((ass_hole - wing_tip)/( self.image.w/2)*(other.x2- x_off) + wing_tip)  and
                    (other.y2 - y_off) > ((         - wing_tip)/( self.image.w/2)*(other.x2- x_off) + wing_tip)) then
                    
                    self:collision(other.obj,"gen",{other.x2,other.y2})
                    
                    return true
                    
                end
            --right side
            elseif
                other.x1 >= (self.group.x - gg_sz/2) and
                other.x1 <= (self.group.x + self.image.w/2) then
                
                if
                (other.y2 - y_off  < (wing_tip - ass_hole)/( self.image.w/2)*(other.x2- x_off) + wing_tip- 2*(wing_tip - ass_hole) and
                (other.y2 - y_off) > (wing_tip           )/( self.image.w/2)*(other.x2- x_off) - wing_tip) then
                
                    self:collision(other.obj,"gen",{other.x2,other.y2})
                    
                    return true
                
                elseif
                (other.y1 - y_off  < (wing_tip - ass_hole)/( self.image.w/2)*(other.x1- x_off) + wing_tip- 2*(wing_tip - ass_hole) and
                (other.y1 - y_off) > (wing_tip           )/( self.image.w/2)*(other.x1- x_off) - wing_tip) then
                    
                    self:collision(other.obj,"gen",{other.x1,other.y1})
                    
                    return true
                end
            end
            return false
        end,
        setup = function(self)
			--[[
            self.guns.g_ll:add(self.guns.img_ll)
            self.guns.g_lr:add(self.guns.img_lr)
            self.guns.g_rl:add(self.guns.img_rl)
            self.guns.g_rr:add(self.guns.img_rr)
            --]]
            self.group:add(
                self.image,
                
                self.prop.img_ll[1],self.prop.img_ll[2],
                self.prop.img_lr[1],self.prop.img_lr[2],
                self.prop.img_rl[1],self.prop.img_rl[2],
                self.prop.img_rr[1],self.prop.img_rr[2],
                
                self.guns.img_ll,
                self.guns.img_lr,
                self.guns.img_rl,
                self.guns.img_rr
            )
            layers.air_doodads_1:add(self.group)
            self.num_frames = 2
			self.index = 1
            table.insert(special_checks,{f=self.special_check,p=self})
            if type(o) == "table"  then
                recurse_and_apply(  self, o  )
            end
            
			if self.prop.broke_ll then
				 self.prop.img_ll[1].opacity=0
				 self.prop.img_ll[2].opacity=0
			end
			if self.prop.broke_lr then
				 self.prop.img_lr[1].opacity=0
				 self.prop.img_lr[2].opacity=0
			end
			if self.prop.broke_rl then
				 self.prop.img_rl[1].opacity=0
				 self.prop.img_rl[2].opacity=0
			end
			if self.prop.broke_rr then
				 self.prop.img_rr[1].opacity=0
				 self.prop.img_rr[2].opacity=0
			end
			
            coll_box.ll.obj=self
            coll_box.lr.obj=self
            coll_box.rl.obj=self
            coll_box.rr.obj=self
            
            coll_box.ll.p="prop_ll"
            coll_box.lr.p="prop_lr"
            coll_box.rl.p="prop_rl"
            coll_box.rr.p="prop_rr"

        end,
        
        rotate_guns_and_fire = function(self,secs)
			
			
			
			--these x,y values are used for rotations and
			--bullet trajectories
			
			--user plane is the target 
			targ.x = (my_plane.group.x+my_plane.img_w/2)
			targ.y = (my_plane.group.y+my_plane.img_h/2)
			
            --absolute position of the zeppelin's right gun
			me.ll.x = (self.guns.img_ll.x+self.group.x-self.group.anchor_point[1])
			me.ll.y = (self.guns.img_ll.y+self.group.y-self.group.anchor_point[2])
            --absolute position of the zeppelin's right gun
			me.lr.x = (self.guns.img_lr.x+self.group.x-self.group.anchor_point[1])
			me.lr.y = (self.guns.img_lr.y+self.group.y-self.group.anchor_point[2])
            --absolute position of the zeppelin's right gun
			me.rl.x = (self.guns.img_rl.x+self.group.x-self.group.anchor_point[1])
			me.rl.y = (self.guns.img_rl.y+self.group.y-self.group.anchor_point[2])
            --absolute position of the zeppelin's right gun
			me.rr.x = (self.guns.img_rr.x+self.group.x-self.group.anchor_point[1])
			me.rr.y = (self.guns.img_rr.y+self.group.y-self.group.anchor_point[2])
			
			for k,v in pairs(me) do
                self.last_shot_time[k] = self.last_shot_time[k] + secs
                z_rot[1] = 180/math.pi*math.atan2(
                        targ.y-me[k].y,
                        targ.x-me[k].x)-90
                self.guns["img_"..k].z_rotation = z_rot
				mock_obj.group.z_rotation[1] = self.guns["img_"..k].z_rotation[1]
				mock_obj.group.x = me[k].x
				mock_obj.group.y = me[k].y

                if self.last_shot_time[k] >= self.shoot_time then
					
					
					self.last_shot_time[k] = 0
					fire_bullet(mock_obj,curr_lvl_imgs.z_bullet)
					
				end
            end
		end,
		strip_thresh = .1,
        strip_time = 0,
        prop_w = curr_lvl_imgs.boss_prop[1].w/2,
        render = function(self,secs)
			self.strip_time = self.strip_time + secs
            if self.strip_time > self.strip_thresh then
                self.strip_time   = 0
				if not self.prop.broke_ll then
					self.prop.img_ll[self.index].opacity = 0
				end
				if not self.prop.broke_rl then
					self.prop.img_rl[self.index].opacity = 0
				end
				if not self.prop.broke_lr then
					self.prop.img_lr[self.index].opacity = 0
				end
				if not self.prop.broke_rr then
					self.prop.img_rr[self.index].opacity = 0
				end
                self.index      = self.index%self.num_frames + 1
				if not self.prop.broke_ll then
					self.prop.img_ll[self.index].opacity = 255
				end
				if not self.prop.broke_rl then
					self.prop.img_rl[self.index].opacity = 255
				end
				if not self.prop.broke_lr then
					self.prop.img_lr[self.index].opacity = 255
				end
				if not self.prop.broke_rr then
					self.prop.img_rr[self.index].opacity = 255
				end
            end
            
            
            if not self.dying then
                self:rotate_guns_and_fire(secs)
            end
            self.stages[self.stage](self,secs)
            local x = self.group.x-self.group.anchor_point[1]
            local y = self.group.y-self.group.anchor_point[2]
            if not self.dying and not self.prop.broke_ll then
                coll_box.ll.x1=self.prop.img_ll[1].x+x
                coll_box.ll.x2=self.prop.img_ll[1].x+x+self.prop.img_ll[1].w
                coll_box.ll.y1=self.prop.img_ll[1].y+y
                coll_box.ll.y2=self.prop.img_ll[1].y+y+self.prop.img_ll[1].h
                table.insert(b_guys_air,coll_box.ll)
            end
            if not self.dying and not self.prop.broke_lr then
                coll_box.lr.x1=self.prop.img_lr[1].x+x
                coll_box.lr.x2=self.prop.img_lr[1].x+x+self.prop.img_lr[1].w
                coll_box.lr.y1=self.prop.img_lr[1].y+y
                coll_box.lr.y2=self.prop.img_lr[1].y+y+self.prop.img_lr[1].h
                table.insert(b_guys_air,coll_box.lr)
            end
            if not self.dying and not self.prop.broke_rr then
                coll_box.rr.x1=self.prop.img_rr[1].x+x
                coll_box.rr.x2=self.prop.img_rr[1].x+x+self.prop.img_rr[1].w
                coll_box.rr.y1=self.prop.img_rr[1].y+y
                coll_box.rr.y2=self.prop.img_rr[1].y+y+self.prop.img_rr[1].h
                table.insert(b_guys_air,coll_box.rr)
            end
            if not self.dying and not self.prop.broke_rl then
                coll_box.rl.x1=self.prop.img_rl[1].x+x
                coll_box.rl.x2=self.prop.img_rl[1].x+x+self.prop.img_rl[1].w
                coll_box.rl.y1=self.prop.img_rl[1].y+y
                coll_box.rl.y2=self.prop.img_rl[1].y+y+self.prop.img_rl[1].h
                table.insert(b_guys_air,coll_box.rl)
            
            end
        end,
        health = {
            ["prop_ll"] = 10,
            ["prop_lr"] = 10,
            ["prop_rl"] = 10,
            ["prop_rr"] = 10,
            ["gen"]     = 50
        },
        damage_maxed = {
            ["gen"] = function(self)
                
            end,

            ["prop_ll"] = function(self)
                self.prop.broke_ll = true
                self.prop.img_ll[1].opacity=0
				self.prop.img_ll[2].opacity=0
                add_to_render_list(
                    explosions.small(
                        self.prop.img_ll[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2,
                        self.prop.img_ll[1].y+self.group.y-self.group.anchor_point[2]
                    )
                )
				local p = powerups.health(self.prop.img_ll[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2)
				p.image.y = self.prop.img_ll[1].y+self.group.y-self.group.anchor_point[2]
            end,
            ["prop_lr"] = function(self)
                self.prop.broke_lr = true
                self.prop.img_lr[1].opacity=0
				self.prop.img_lr[2].opacity=0
                add_to_render_list(
                    explosions.small(
                        self.prop.img_lr[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2,
                        self.prop.img_lr[1].y+self.group.y-self.group.anchor_point[2]
                    )
                )
				local p = powerups.health(self.prop.img_lr[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2)
				p.image.y = self.prop.img_lr[1].y+self.group.y-self.group.anchor_point[2]
            end,
            ["prop_rl"] = function(self)
                self.prop.broke_rl = true
                self.prop.img_rl[1].opacity=0
				self.prop.img_rl[2].opacity=0
                add_to_render_list(
                    explosions.small(
                        self.prop.img_rl[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2,
                        self.prop.img_rl[1].y+self.group.y-self.group.anchor_point[2]
                    )
                )
				local p = powerups.health(self.prop.img_rl[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2)
				p.image.y = self.prop.img_rl[1].y+self.group.y-self.group.anchor_point[2]
            end,
            ["prop_rr"] = function(self)
                self.prop.broke_rr = true
                self.prop.img_rr[1].opacity=0
				self.prop.img_rr[2].opacity=0
                add_to_render_list(
                    explosions.small(
                        self.prop.img_rr[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2,
                        self.prop.img_rr[1].y+self.group.y-self.group.anchor_point[2]
                    )
                )
				local p = powerups.health(self.prop.img_rr[1].x+self.group.x-self.group.anchor_point[1]+self.prop_w/2)
				p.image.y = self.prop.img_rr[1].y+self.group.y-self.group.anchor_point[2]
            end,
        },
        props_remaining = 4,
        collision = function(self,other,loc,pos)
            if  self.health[loc] - 1  == 0 then
                self.health[loc] = self.health[loc] - 1
                
                self.damage_maxed[loc](self)
                self.props_remaining = self.props_remaining - 1
                if self.props_remaining == 0 or  loc == "gen" then
                    self.dying = true
                    self.stage = self.stage + 1
                    dolater( function() table.remove(special_checks) end)
                    
                end
            else
                self.health[loc] = self.health[loc] - 1
                if loc == "gen" then
                    local x = self.group.x-self.group.anchor_point[1]
                    local y = self.group.y-self.group.anchor_point[2]
                    local i =math.random(1,7)
                    local dam = Clone{source = curr_lvl_imgs["z_d_"..i]}
                    self.group:add(dam)
                    if other.group ~= nil then
                        dam.x = pos[1]-x--other.group.x - x
                        dam.y = pos[2]-y - math.random(20,40)
                    elseif other.image ~= nil then
                        dam.x = pos[1]-x--other.image.x - x
                        dam.y = pos[2]-y - math.random(20,40)
                    else
                        error("unexpected location given for final_boss impact")
                    end 
                end
            end
            
        end,
        salvage = function( self, salvage_list )
            s = {
                func         = {},
                table_params = {},
            }
            
            for i = 1, #self.salvage_params do
                s.table_params[i] = self.salvage_params[i]
            end
            
            for i = 1, #self.salvage_func do
                s.func[i] = self.salvage_func[i]
            end
            
            table.insert(s.table_params,{
                is_boss         = self.is_boss,
                props_remaining = self.props_remaining,
                health          = {
                    prop_ll = self.health.prop_ll,
                    prop_lr = self.health.prop_lr,
                    prop_rl = self.health.prop_rl,
                    prop_rr = self.health.prop_rr,
                },
                dying = self.dying,
                stage          = self.stage,
                prop  = {
                    img_ll   = {
                        opacity = self.prop.img_ll.opacity
                    },
                    img_lr   = {
                        opacity = self.prop.img_lr.opacity
                    },
                    img_rl   = {
                        opacity = self.prop.img_rl.opacity
                    },
                    img_rr   = {
                        opacity = self.prop.img_rr.opacity
                    },
                    broke_ll = self.prop.broke_ll,
                    broke_lr = self.prop.broke_lr,
                    broke_rl = self.prop.broke_rl,
                    broke_rr = self.prop.broke_rr,
                },
                group = {
                    x = self.group.x,
                    y = self.group.y,
                    scale = {self.group.scale[1],self.group.scale[2]},
                    x_rotation = {self.group.x_rotation[1],0,0}
                },
                last_shot_time  =    --how long ago the ship last shot
                {
                    ll = self.last_shot_time.ll,
                    lr = self.last_shot_time.lr,
                    rl = self.last_shot_time.rl,
                    rr = self.last_shot_time.rr,
                },
                x_speed = self.x_speed,
                y_speed = self.y_speed,
                
                
            })
            if self.index then
                table.insert(s.table_params,self.index)
            end
            return s
        end,
    }
    )
end
