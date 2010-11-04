


water =
{
    speed  = 80, -- pixels per second
    strips = {},
    top_y  = 0,
    setup = function( self )
                
            local tile = imgs.water
            tile:set{ w = screen.w , tile = { true  , false } }
            for i = 1 , math.ceil( screen.h / tile.h ) + 1 do
                table.insert( self.strips , Clone{ source = tile } )
            end
            local top = - ( tile.h  )
            self.top_y = top
            for _ , strip in ipairs( self.strips ) do
                strip.position = { 0 , top }
                top = top + tile.h - 1
                layers.ground:add( strip )
            end
    end,
    add_start = function(self,type,side)
        add_to_render_list(
        {
            speed = self.speed,
            image = Clone{source=imgs["dock_"..type.."_4"]},
            setup = function(self)
                self.image.y = -imgs["dock_"..type.."_4"].h
                if side == 1 then
                    self.image.y_rotation = {180,0,0}
                    self.image.x = imgs["dock_"..type.."_4"].w  
                elseif side == -1 then
                    self.image.x = screen.w - imgs["dock_"..type.."_4"].w 
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
    end,
    add_end = function(self,type,side)
        add_to_render_list(
        {
            speed = self.speed,
            image = Clone{source=imgs["dock_"..type.."_3"]},
            setup = function(self)
                self.image.y = -imgs["dock_"..type.."_3"].h
                if side == 1 then
                    self.image.y_rotation = {180,0,0}
                    self.image.x = imgs["dock_"..type.."_3"].w  
                elseif side == -1 then
                    self.image.x = screen.w - imgs["dock_"..type.."_3"].w 
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
    end,
    empty_stretch = function(self,len,delay)
        return imgs["dock_1_1"].h*len/self.speed + delay
    end,
    add_stretch = function(self,type,side,len,delay)
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
    end,
    add_harbor_tile = function(self,type,side,tile_index,delay)
        
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
        return imgs["dock_"..type.."_"..tile_index].h/self.speed + delay
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
            -- reposition all the water strips
            local dy   = self.speed * seconds
            local maxy = screen.h
            self.top_y = self.top_y + dy    

            for _ , strip in ipairs( self.strips ) do
                strip.y = strip.y + dy
                if strip.y > maxy then
                    strip.y    = self.top_y - strip.h + 1   
                    self.top_y = strip.y
                end
            end
    end,        
}

