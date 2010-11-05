


water =
{
    speed         = 80, -- pixels per second
    strips        = {},
    top_strip     = 0,
    doodad_frames = {},
    doodad_h      = imgs.dock_1_1.h,
    strip_h       = imgs.water.h,
    top_doodad    = 0,
    q_i           = 0,
    append_i      = 0,
    queues        = {},
    setup         = function( self )
        --base water strip
        self.base_tile = imgs.water
        self.base_tile:set{ w = screen.w, tile = { true  , false } }
        for i = 1 , math.ceil( screen.h / self.base_tile.h ) + 1 do
            table.insert( self.strips , Clone{name="water", source = self.base_tile } )
        end
        
        --set up the water strips
        local top = - ( self.base_tile.h  )
        self.top_strip = top
        for _ , strip in ipairs( self.strips ) do
            strip.position = { 0 , top }
            top = top + self.base_tile.h - 1
            layers.ground:add( strip )
        end
        
        local g
        --setup the doodad frames
        self.top_doodad = -self.doodad_h+1
        for i = 1, math.ceil(screen.h/self.doodad_h)+1 do
            g   =  Group{y=(i-2)*(self.doodad_h-1)}
            table.insert( self.doodad_frames , g)
            layers.land_doodads_1:add(g)
        end
    end,
    append_to_queue = function(q)
        for i = 1,   #q do
            self.queues[self.append_i+i] = q[i]
        end
    end,
    empty_stretch = function(self,len,delay)
        return imgs["dock_1_1"].h*len/self.speed + delay
    end,
    add_stretch = function(self,type,side,len,delay)
    --[[
        add_to_render_list(
        {
            speed = self.speed,
            recirc = false,
            group = Group{},
            
            setup = function(self)
                
                local h = imgs["dock_"..type.."_1"].h
                
                for i = 1,len do
                    self.group:add(Clone{source=imgs["dock_"..type.."_1"],y = i*h})
                end
                
                self.group.y = -(len+1)*h-self.speed*delay
                if side == 1 then
                    self.group.y_rotation = {180,0,0}
                    self.group.x = imgs["dock_"..type.."_1"].w 
                elseif side == -1 then
                    self.group.x = screen.w - imgs["dock_"..type.."_1"].w 
                else
                    error("unexpected value for side received, expected 1 or -1, got "..side)
                end
                layers.land_doodads_1:add(self.group)
            end,
            render = function(self,secs)
                self.group.y = self.group.y + self.speed*secs
                if self.group.y > screen.h then
                    self.group:unparent()
                    remove_from_render_list(self)
                end
            end,
        }        )
        return imgs["dock_"..type.."_1"].h*len/self.speed + delay
        --]]
        local c
        
        for i = 1,len do
            c = Clone {source =  imgs["dock_"..type.."_1"]}
            if side == 1 then
                c.y_rotation = {180,0,0}
                c.x = imgs["dock_"..type.."_1"].w  
            elseif side == -1 then
                c.x = screen.w - imgs["dock_"..type.."_1"].w 
            else
                error("unexpected value for SIDE received, expected 1 or -1, got "..side)
            end
            if self.queues[self.q_i+i] == nil then self.queues[self.q_i+i] = {} end
            table.insert(self.queues[self.q_i+i],c)
        end
        
        return self.doodad_h*len/self.speed + delay
    end,
    add_harbor_tile = function(self,type,side,tile_index,turret, b_ship, delay)
        --[[
        add_to_render_list(
        {
            speed = self.speed,
            image = Clone{source=imgs["dock_"..type.."_"..tile_index]},
            setup = function(self)
                self.image.y = -imgs["dock_"..type.."_"..tile_index].h-self.speed*delay
                if side == 1 then
                    self.image.y_rotation = {180,0,0}
                    self.image.x = imgs["dock_"..type.."_"..tile_index].w  
                elseif side == -1 then
                    self.image.x = screen.w - imgs["dock_"..type.."_"..tile_index].w 
                else
                    error("unexpected value for SIDE received, expected 1 or -1, got "..side)
                end
                layers.land_doodads_1:add(self.image)
            end,
            render = function(self,secs)
                self.image.y = self.image.y + self.speed*secs
                if self.image.y > screen.h then
                    self.image:unparent()
                    remove_from_render_list(self)
                end
            end,
        }        )
        --]]
        local c = Clone {source =  imgs["dock_"..type.."_"..tile_index]}
        
        if side == 1 then
            c.y_rotation = {180,0,0}
            c.x = imgs["dock_"..type.."_"..tile_index].w  
        elseif side == -1 then
            c.x = screen.w - imgs["dock_"..type.."_"..tile_index].w 
        else
            error("unexpected value for SIDE received, expected 1 or -1, got "..side)
        end
        
        local x
        if b_ship then
            if side == 1 then
                x = 400-imgs.b_ship.w
            elseif side == -1 then
                x = 1520
            else
            end
            add_to_render_list(enemies.battleship(), x, self.top_doodad-self.doodad_h, self.speed)
        end
        
        if turret then
            if side == 1 then
                x = 350
            elseif side == -1 then
                x = screen.w -350
            else
            end
            add_to_render_list(enemies.turret(), x, self.top_doodad-10)
        end
        
        if self.queues[self.q_i+1] == nil then self.queues[self.q_i+1] = {} end
        table.insert(self.queues[self.q_i+1],c)
        return self.doodad_h/self.speed + delay
    end,
    add_dock = function(self,type, side)
        local h = imgs.dock_1_1.h
        local x = imgs.dock_1_5.w - imgs.dock_1_1.w
        local dock = {
            speed = self.speed,
            group = Group{},
            setup = function(self)
                self.group:add(
                    Clone{source=imgs["dock_"..type.."_3"], y =   0, x = x},
                    Clone{source=imgs["dock_"..type.."_6"], y =   h       },
                    Clone{source=imgs["dock_"..type.."_1"], y = 2*h, x = x},
                    Clone{source=imgs["dock_"..type.."_1"], y = 3*h, x = x},
                    Clone{source=imgs["dock_"..type.."_2"], y = 4*h, x = x},
                    Clone{source=imgs["dock_"..type.."_1"], y = 5*h, x = x},
                    Clone{source=imgs["dock_"..type.."_1"], y = 6*h, x = x},
                    Clone{source=imgs["dock_"..type.."_5"], y = 7*h,      },
                    Clone{source=imgs["dock_"..type.."_4"], y = 8*h, x = x}
                    --Clone{source=imgs.battleship,y = 5/2*h,x=x - imgs.battleship.w-20}
                )
                self.group.y = -9*h
                if side == 1 then
                    self.group.y_rotation = {180,0,0}
                    self.group.x = imgs.dock_1_5.w 
                elseif side == -1 then
                    self.group.x = screen.w - imgs.dock_1_5.w 
                else
                    error("unexpected value for side received, expected 1 or -1, got "..side)
                end
                layers.land_doodads_1:add(self.group)
            end,
            render = function(self,secs)
                self.group.y = self.group.y + self.speed*secs
                if self.group.y > screen.h then
                    self.group:unparent()
                    remove_from_render_list(self)
                end
            end,
        }
        add_to_render_list(dock)
    end,

    add_cloud = function(self,index, xxx, x_rot, y_rot, z_rot)
        local cloud =
            
            {
                speed = self.speed,
                image = Clone{ 
					source       = imgs[ "cloud"..tostring( index ) ] , 
					x_rotation   = { x_rot , 0, 0},
					y_rotation   = { y_rot , 0, 0},
					z_rotation   = { z_rot , 0, 0},
					opacity      = 255 ,
				},
                setup = function( self )
                        layers.air_doodads_2:add( self.image )
						self.image:lower_to_bottom()
						self.image.anchor_point = {  self.image.w / 2 ,  self.image.h / 2 }
						self.image.position     = {               xxx , -self.image.h / 2 }


                end,
                    
                render = function( self , seconds )
                        self.image.y = self.image.y + self.speed * seconds
                        if self.image.y > (screen.h+self.image.h) then
                            remove_from_render_list( self )
                            self.image:unparent()
                        end
                        --self.image:raise_to_top()
                end,
            }
        add_to_render_list(cloud)
    end,
    add_island = function(self,index, xxx, x_rot, y_rot, z_rot)

        local island =
            
            {
                speed = self.speed,
                image = Clone{ 
					source       = imgs[ "island"..tostring( index ) ] , 
					x_rotation   = { x_rot , 0, 0},
					y_rotation   = { y_rot , 0, 0},
					z_rotation   = { z_rot , 0, 0},
					opacity      = 255 ,
				},
                setup = function( self )
                        layers.land_doodads_1:add( self.image )
						--self.image:lower_to_bottom()
						self.image.anchor_point = {  self.image.w / 2 ,  self.image.h / 2 }
						self.image.position     = {               xxx , -self.image.h / 2 }
                        
                        for _ , strip in ipairs( water.strips ) do
    				    --    strip:lower_to_bottom()
    					end
                end,
                    
                render = function( self , seconds )
                        self.image.y = self.image.y + self.speed * seconds
                        if self.image.y > (screen.h+self.image.h) then
                            remove_from_render_list( self )
                            self.image:unparent()
                        end
                        
                end,
            }
	    add_to_render_list( island )
	end,
            
    render = function( self , seconds )
            
            local dy   = self.speed * seconds
            
            self.top_strip  = self.top_strip  + dy
            self.top_doodad = self.top_doodad + dy
            
            --reposition all the water strips
            for _ , strip in ipairs( self.strips ) do
                strip.y = strip.y + dy
                --if dropped below the bottom of the screen move it to the top
                if strip.y > screen.h then
                    strip.y    = self.top_strip - self.strip_h+1--strip.y - screen.h - strip.h
                    self.top_strip = strip.y
                end
            end
            
            --print("next")
            --reposition all the doodads
            for _ , frame in ipairs( self.doodad_frames ) do
                frame.y = frame.y + dy
                --print(frame.y)
                
                --if dropped below the bottom of the screen...
                if frame.y > screen.h then
                    
                    --move it to the top
                    frame.y = self.top_doodad - self.doodad_h+1--frame.y - screen.h - self.doodad_h  
                    self.top_doodad = frame.y
                    
                    --clear out the frame
                    frame:clear()
                    self.queues[self.q_i] = nil
                    
                    --update the position
                    self.q_i = self.q_i + 1
                    if self.q_i >= self.append_i then
                        self.append_i = self.q_i + 1
                    end
                    
                    print("inc",self.q_i,frame.y)
                    
                    --load the next doodads
                    if self.queues[self.q_i] ~= nil then
                        for _,new_child in ipairs(self.queues[self.q_i]) do
                            frame:add(new_child)
                        end
                    end
                    
                end
            end
    end,        
}

