water =
{
    speed = 100, -- pixels per second
    
    strips = {},
    
    top_y = 0,
    
    time = 0,
    
    island_time = 0.5, -- seconds
    
    setup =
    
        function( self )
                
            local tile = assets.water
            
            --tile:set{ w = screen.w , tile = { false  , false } }
                        
            for i = 1 , math.ceil( screen.h / tile.h ) + 3 do
                   
                table.insert( self.strips , Clone{ source = tile } )
                
            end
            
            local top = - ( tile.h * 2 )
            
            self.top_y = top
            
            for _ , strip in ipairs( self.strips ) do
            
                strip.position = { 0 , top }
                
                top = top + tile.h - 1
            
                screen:add( strip )
                
            end

        end,
            
    render =
    
        function( self , seconds )

                
            -- reposition all the water strips
            
            local dy = self.speed * seconds
            
            local maxy = screen.h
            
            self.top_y = self.top_y + dy    
            
            for _ , strip in ipairs( self.strips ) do

            
                strip.y = strip.y + dy

                if strip.y > maxy then
                
                    strip.y = self.top_y - strip.h + 1   
                    
                    self.top_y = strip.y
                
                end
            
            end
            
            -- see if we should drop an island
            
            self.time = self.time + seconds
            
            if false then

--self.time >= self.island_time then
            
                self.time = self.time - self.island_time
                
                if math.random( 100 ) < 50 then
                               
                    local island =
                        
                        {
                            speed = self.speed,
                            
                            image = Clone{ source = assets[ "island"..tostring( math.random( 1 , 3 ) ) ] , opacity = 255 },
                            
                            setup =
                            
                                function( self )
                                
                                    self.image.position = { math.random( 0 , screen.w ) , - self.image.h }
                                    
                                    if math.random( 100 ) > 50 then
                                    
                                        self.image.y_rotation = { 180 , self.image.w / 2 , 0 }
                                    
                                    end
                                    
                                    if math.random( 100 ) < 50 then
                                    
                                        self.image.x_rotation = { 180 , self.image.h / 2 , 0 }
                                    
                                    end
                                    
                                    self.image.z_rotation = { math.random( 180 ) , self.image.w / 2 , self.image.h / 2 }
                                    
                                    screen:add( self.image )
                                
                                end,
                                
                            render =
                            
                                function( self , seconds )
                                
                                    local y = self.image.y + self.speed * seconds
                                    
                                    if y > screen.h then
                                    
                                        remove_from_render_list( self )
                                        
                                        screen:remove( self.image )
                                        
                                    else
                                    
                                        self.image.y = y
                                        
                                    end
                                    
                                end,
                        }
                        
                    add_to_render_list( island )
                
                end
            
            end
            
        end,        
}

