                
                   lvl1txt    =     {
                                speed = 40,
                                text = Clone{ source = txt.level1 },
                                
                                setup = function( self )
                                        self.text.position = { screen_w/2,screen_h/2}
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        self.text.opacity = 255;
					self.text.scale = {1,1}
                                        layers.hud:add( self.text )
                                    end,
                                    
                                render = function( self , seconds )
                                        local o = self.text.opacity - self.speed * seconds
                                        local scale = self.text.scale
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        if o <= 0 then
                                            remove_from_render_list( self )
                                            self.text:unparent()
                                        else
                                            self.text.opacity = o
                                            self.text.scale = scale
                                        end
                                    end,
                            }
                   lvl2txt    =     {
                                speed = 40,
                                text = Clone{ source = txt.level2 },
                                
                                setup = function( self )
                                        self.text.position = { screen_w/2,screen_h/2}
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        self.text.opacity = 255;
					self.text.scale = {1,1}
                                        layers.hud:add( self.text )
                                    end,
                                    
                                render = function( self , seconds )
                                        local o = self.text.opacity - self.speed * seconds
                                        local scale = self.text.scale
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        if o <= 0 then
                                            remove_from_render_list( self )
                                            self.text:unparent()
                                        else
                                            self.text.opacity = o
                                            self.text.scale = scale
                                        end
                                    end,
                            }
lvlcomplete =      {
                                speed = 40,
                                text = Text{font = my_font , text = "Level Complete"  , color = "FFFFFF"},
                                
                                setup = function( self )
                                        self.text.position = { screen_w/2,screen_h/2}
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        self.text.opacity = 255;
                                        layers.hud:add( self.text )
                                    end,
                                    
                                render = function( self , seconds )
                                        local o = self.text.opacity - self.speed * seconds
                                        local scale = self.text.scale
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        if o <= 0 then
                                            remove_from_render_list( self )
                                            self.text:unparent()
                                        else
                                            self.text.opacity = o
                                            self.text.scale = scale
                                        end
                                    end,
                            }



levels = 
{
	--level 1
	{
		speed          = 20,   --px/s
		level_dist     = 3000, --px
		dist_travelled = 0,
		launch_index   = 1,
		bg             = lvlbg[1],
        offset         = {},
        index          = {},
        add_list       = {},

		setup = function(self)
		--	add_to_render_list( self.bg )
            self.add_list = {
            --enemy
            {
                {y =    0, item = add_to_render_list,        params = { lvl1txt        }},
                {y =   80, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {y =  300, item = formations.row_from_side,  params = { 5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200 }},
                {y =  400, item = formations.row_from_side,  params = { 5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200 }},
                {y =  550, item = formations.one_loop,       params = {2,150,200,200,300,-1}},
                {y =  700, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                {y = 1050, item = formations.one_loop,       params = {2,150,200,200,300,-1}},
                {y = 1050, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                
                {y = 1300, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {y = 1300, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                
                {y = 1600, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {y = 1660, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  350}},
                {y = 1660, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                {y = 1720, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  500}},
                {y = 1780, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                            
                {y = 2000, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                {y = 2000, item = formations.one_loop,       params = {2,150,200,200,300,-1}},
                --]]
                {y = 2320, item = formations.cluster,         params = {200}},
                {y = 2350, item = formations.cluster,         params = {1200}},
                {y = 2450, item = formations.cluster,         params = {900}},
                {y = 2550, item = formations.cluster,         params = {500}},
                {y = 2600, item = formations.cluster,         params = {1700}},
                
                {y = 2700, item = formations.cluster,         params = {240}},
                {y = 2750, item = formations.zepp_boss,      params = { 120 }}
            },
            --island
            {
                {y =    50, item = self.bg.add_island, params = {self.bg,  2, 300, 0, 0, 0}},
                
                {y =  180, item = self.bg.add_island, params = {self.bg, 1, 1720,   0,   0, -123}},
                {y =  220, item = self.bg.add_island, params = {self.bg, 2,    0, 180, 180,   67}},
                {y =  280, item = self.bg.add_island, params = {self.bg, 3,  600,   0,   0,   45}},
                {y =  280, item = self.bg.add_island, params = {self.bg, 1, 1500, 180,   0, -260}},
                {y =  380, item = self.bg.add_island, params = {self.bg, 1,  200,   0, 180,   50}},
                {y =  420, item = self.bg.add_island, params = {self.bg, 3, 1800, 180, 180,   90}},
                {y =  460, item = self.bg.add_island, params = {self.bg, 2,  500,   0,   0,  150}},
                {y =  480, item = self.bg.add_island, params = {self.bg, 1, 1500, 180, 180, -250}},
                {y =  580, item = self.bg.add_island, params = {self.bg, 3,  200,   0, 180,  280}},
                {y =  620, item = self.bg.add_island, params = {self.bg, 1,  500, 180,   0,  320}},
                {y =  660, item = self.bg.add_island, params = {self.bg, 2, 1600,   0, 180,  150}},
                {y =  740, item = self.bg.add_island, params = {self.bg, 5,  100, 180, 180,   10}},
                {y =  790, item = self.bg.add_island, params = {self.bg, 3,  300,   0, 180,  300}},
                {y =  820, item = self.bg.add_island, params = {self.bg, 3, 1700, 180, 180, -170}},
                {y =  860, item = self.bg.add_island, params = {self.bg, 2, 1400,   0, 180,  -60}},
                {y =  890, item = self.bg.add_island, params = {self.bg, 1,  500, 180,   0,   70}},
                {y =  940, item = self.bg.add_island, params = {self.bg, 4, 1800, 180,   0,  130}},
                {y = 1090, item = self.bg.add_island, params = {self.bg, 2, 1100,   0,   0,  190}},
            },
            --cloud
            {
                {y =  100, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2,   0,   0, 0}},
                {y =  170, item = self.bg.add_cloud, params = {self.bg, 1,  425/2, 0, 180,    0}},
                {y =  280, item = self.bg.add_cloud, params = {self.bg, 3,  700,   0,   0,    0}},
                {y =  340, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2, 0,   0,    0}},
                {y =  380, item = self.bg.add_cloud, params = {self.bg, 1, 425/2,   0, 180,    0}},
                {y =  420, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0, 0,    0}},
                {y =  480, item = self.bg.add_cloud, params = {self.bg, 2, 484/2, 0, 180, 0}},
                {y =  580, item = self.bg.add_cloud, params = {self.bg, 3,  300,   0, 180,  0}},
                {y =  620, item = self.bg.add_cloud, params = {self.bg, 1,  screen.w - 425/2, 0,   0,  0}},
                {y =  660, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2,   0, 0,  0}},
                {y =  740, item = self.bg.add_cloud, params = {self.bg, 1,  425/2, 0, 180,   0}},
                {y =  790, item = self.bg.add_cloud, params = {self.bg, 3,  300,   0, 180,  0}},
                {y =  820, item = self.bg.add_cloud, params = {self.bg, 3, 1700, 0, 180, 0}},
            }
            }
            for i = 1, #self.add_list do
                self.index[i] = 1
                self.offset[i] = 0
            end
			self.dist_travelled = 0
		end,
		render = function(self,seconds)
			--if player is dead


			local curr_dist = self.dist_travelled + self.speed*seconds
            for i = 1,#self.add_list do
                local done = false
                while not done do
                	
                    if  self.index[i] > #self.add_list[i] then
                        if i ~= 1 then
                            self.index[i] = 1
                            self.offset[i] = curr_dist
                            print("aaa",i,self.offset[i])
                        end
                        done = true
                    elseif self.add_list[i][ self.index[i] ].y < (curr_dist - self.offset[i]) and
                	   self.add_list[i][ self.index[i] ].y >=
                	   (self.dist_travelled - self.offset[i]) then
                        
                        self.add_list[i][self.index[i]].item(unpack(self.add_list[i][self.index[i]].params))
                        self.index[i] = self.index[i] + 1
                	else
                		done = true
                	end
                end
            end


			self.dist_travelled = curr_dist
	--		if self.dist_travelled > self.level_dist then
	--			remove_from_render_list( self )
	--		end
		end,
		level_complete = function(self)
			remove_from_render_list( self)
			add_to_render_list( lvlcomplete )
		end

	},
    {
    		speed          = 80,   --px/s
		level_dist     = 3000, --px
		dist_travelled = 0,
		launch_index   = 1,
		bg             = lvlbg[2],
        offset         = {},
        index          = {},
        add_list       = {},
        wait           = {},
        w_q_index      = {},
        
		setup = function(self)
            
            local h_reg   = 1
            local h_cleat = 2
            local h_close = 3
            local h_open  = 4
            local h_pier1 = 5
            local h_pier2 = 6
            local h_piert = 7
            
		--	add_to_render_list( self.bg )
            self.add_list = {
            --enemy
            {
            --[[
                {y =    0, item = add_to_render_list,        params = { lvl2txt }},
                {y =   75, item = formations.zig_zag,  params = { 400,400, -30}},
                {y =   75, item = formations.zig_zag,  params = {1520,400,  30}},
                {y =  200, item = formations.zig_zag,  params = { 400,400,  30}},
                {y =  200, item = formations.zig_zag,  params = {1520,400, -30}},
                {y =  800, item = formations.zig_zag,  params = { 400,400, -30}},
                {y =  800, item = formations.zig_zag,  params = {1520,400,  30}},
                {y =  925, item = formations.zig_zag,  params = { 400,400,  30}},
                {y =  925, item = formations.zig_zag,  params = {1520,400, -30}},
                
                {y = 1300, item = formations.cluster,  params = {screen.w/2 - 150}},
                {y = 1300, item = formations.cluster,  params = {screen.w/2 + 150}},
                {y = 1400, item = add_to_render_list,  params = { powerups.guns( screen.w/2 )}},
                
                --]]
                
                --[[
                {y =  300, item = formations.row_from_side,  params = { 5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200 }},
                {y =  400, item = formations.row_from_side,  params = { 5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200 }},
                {y =  550, item = formations.one_loop,       params = {2,150,200,200,300,-1}},
                {y =  700, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                {y = 1050, item = formations.one_loop,       params = {2,150,200,200,300,-1}},
                {y = 1050, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                
                {y = 1300, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {y = 1300, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                
                {y = 1600, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {y = 1660, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  350}},
                {y = 1660, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                {y = 1720, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  500}},
                {y = 1780, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                            
                {y = 2000, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                {y = 2000, item = formations.one_loop,       params = {2,150,200,200,300,-1}},

                {y = 2320, item = formations.cluster,         params = {200}},
                {y = 2350, item = formations.cluster,         params = {1200}},
                {y = 2450, item = formations.cluster,         params = {900}},
                {y = 2550, item = formations.cluster,         params = {500}},
                {y = 2600, item = formations.cluster,         params = {1700}},
                
                {y = 2700, item = formations.cluster,         params = {240}},
                {y = 2750, item = formations.zepp_boss,      params = { 120 }}
                --]]
            },
            --left harbor
            {
                --{y =   0, item = self.bg.add_start, params = {self.bg,  2,  1}},
                --{y =   imgs.dock_1_1.h, item = self.bg.add_stretch, params = {self.bg,  2,  1,20}}
            --[[
                {y =   0, item = self.bg.add_dock, params = {self.bg,  2,  1}},
                {y =  imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  2,  1}},
                {y =  2*imgs.dock_1_1.h*9,   item = self.bg.add_dock, params = {self.bg,  2,  1}},
                {y =  3*imgs.dock_1_1.h*9,   item = self.bg.add_dock, params = {self.bg,  2,  1}},
                {y =  4*imgs.dock_1_1.h*9,  item = self.bg.add_dock, params = {self.bg,  2,  1}},
                
                {y =  5*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  1,  1}},
                {y =  6*imgs.dock_1_1.h*9,   item = self.bg.add_dock, params = {self.bg,  1,  1}},
                {y =  7*imgs.dock_1_1.h*9,   item = self.bg.add_dock, params = {self.bg,  1,  1}},
                {y =  8*imgs.dock_1_1.h*9,  item = self.bg.add_dock, params = {self.bg,  1,  1}},
                --]]
            },
            --right harbor
            {
            --[[
                {y =  280, item = self.bg.add_dock, params = {self.bg,  2, -1}},
                {y =  280+imgs.dock_1_1.h*9, item = self.bg.add_dock, params =   {self.bg,  2, -1}},
                {y =  280+2*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  2, -1}},
                {y =  280+3*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  2, -1}},
                {y =  280+4*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  2, -1}},
                
                {y =  280+5*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  1, -1}},
                {y =  280+6*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  1, -1}},
                {y =  280+7*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  1, -1}},
                {y =  280+8*imgs.dock_1_1.h*9, item = self.bg.add_dock, params = {self.bg,  1, -1}},
                --]]
            },
            --cloud
            --[[{
                {y =  100, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2,   0,   0, 0}},
                {y =  170, item = self.bg.add_cloud, params = {self.bg, 1,  425/2, 0, 180,    0}},
                {y =  280, item = self.bg.add_cloud, params = {self.bg, 3,  700,   0,   0,    0}},
                {y =  340, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2, 0,   0,    0}},
                {y =  380, item = self.bg.add_cloud, params = {self.bg, 1, 425/2,   0, 180,    0}},
                {y =  420, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0, 0,    0}},
                {y =  480, item = self.bg.add_cloud, params = {self.bg, 2, 484/2, 0, 180, 0}},
                {y =  580, item = self.bg.add_cloud, params = {self.bg, 3,  300,   0, 180,  0}},
                {y =  620, item = self.bg.add_cloud, params = {self.bg, 1,  screen.w - 425/2, 0,   0,  0}},
                {y =  660, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2,   0, 0,  0}},
                {y =  740, item = self.bg.add_cloud, params = {self.bg, 1,  425/2, 0, 180,   0}},
                {y =  790, item = self.bg.add_cloud, params = {self.bg, 3,  300,   0, 180,  0}},
                {y =  820, item = self.bg.add_cloud, params = {self.bg, 3, 1700, 0, 180, 0}},
            }--]]
            }
            --each func in the list returns the amount of time to wait before
            --calling the next one
            self.next_queues =
            {
                {   --left harbor
                    {f = add_to_render_list,        p = { lvl2txt        }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_open,false,false  }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2,  1,      2}},
                    --{f = add_to_render_list,      p = {enemies.turret(), 350, -imgs.dock_1_1.h*2/3 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_piert,true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2,  1,      4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),400-imgs.b_ship.w, -imgs.dock_1_1.h*2/3, self.bg.speed }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2,  1,      4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2,  1,      7 }},
                    --{f = add_to_render_list,      p = {enemies.turret(), 350 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_piert,true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2,  1,      7 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),400-imgs.b_ship.w, -imgs.dock_1_1.h*2/3, self.bg.speed }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2,  1,      4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,false }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_close,false,false  }},
                    
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_open ,false,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,      6 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_pier1,false,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),400-imgs.b_ship.w, -imgs.dock_1_1.h*2/3, self.bg.speed}},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_pier1,false,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(),    350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(),    350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,      4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(),    350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    {f = add_to_render_list,      p = {powerups.health(300)}},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,      4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(),    350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,      7 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_close ,false,false }},
                    
                    {f = self.bg.empty_stretch,   p = {self.bg,   6 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_open ,false,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,      6 }},
                    --{f = add_to_render_list,      p = {enemies.turret(), 350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),400-imgs.b_ship.w, -imgs.dock_1_1.h*2/3, self.bg.speed}},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(), 350 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),400-imgs.b_ship.w, -imgs.dock_1_1.h*2/3, self.bg.speed}},
                    {f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(), 350, -imgs.dock_1_1.h*2/3 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    
                },
                {   --right harbor
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_open,false,false  }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      2 }},
                    --{f = add_to_render_list,      p = {enemies.turret(), screen.w -350, -imgs.dock_1_1.h*2/3 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert, true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier1,false,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      10 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),1520, -imgs.dock_1_1.h*2/3, self.bg.speed }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      10 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_close,false,false  }},
                    
                    {f = self.bg.empty_stretch,   p = {self.bg,   4 }},
                    {f = add_to_render_list,      p = {powerups.health(1300)}},
                    
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_open,false,false  }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1, -1,      2 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_pier2,false,true }},
                    --{f = add_to_render_list,      p = {enemies.battleship(),1520, -imgs.dock_1_1.h*2/3, self.bg.speed }},
                    {f = self.bg.add_stretch,     p = {self.bg,  1, -1,      4 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_pier1,false,false }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_close ,false,false }},
                    
                    {f = self.bg.empty_stretch,   p = {self.bg,   2 }},
                    {f = add_to_render_list,      p = {powerups.life(1800)}},
                    {f = add_to_render_list,      p = {enemies.battleship(),1200, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3 }},
                    {f = self.bg.empty_stretch,   p = {self.bg,   13 }},
                    
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_open,false,false  }},
                    --{f = add_to_render_list,      p = {enemies.turret(), screen.w -350, -imgs.dock_1_1.h*2/3 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert,true,false }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      2 }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,false }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,true}},
                    --{f = add_to_render_list,      p = {enemies.battleship(),1520, -imgs.dock_1_1.h*2/3, self.bg.speed }},
                    {f = self.bg.add_stretch,     p = {self.bg,  2, -1,      4 }},
                    --{f = add_to_render_list,      p = {enemies.turret(), screen.w -350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert,true,false }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_close,false,false }},
                    
                    {f = self.bg.empty_stretch,   p = {self.bg,   6 }},
                    {f = add_to_render_list,      p = {powerups.health(1800)}},
                    {f = self.bg.empty_stretch,   p = {self.bg,   10 }},
                    
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_open ,false,false }},
                    --{f = add_to_render_list,      p = {enemies.turret(), screen.w -350 , -imgs.dock_1_1.h*2/3}},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert,true,false }},
                    {f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_close,false,false }},
                    
                    {f = self.bg.empty_stretch,   p = {self.bg,   6 }},
                    {f = add_to_render_list,      p = {powerups.life(1800)}},
                    {f = self.bg.empty_stretch,   p = {self.bg,   4 }},
                }
            }
            for i = 1, #self.add_list do
                self.index[i] = 1
                self.offset[i] = 0
            end
            for i = 1, #self.next_queues do
                self.w_q_index[i] = 1
                self.wait[i] = 0
            end
			self.dist_travelled = 0
		end,
		render = function(self,seconds)
			--if player is dead


			local curr_dist = self.dist_travelled + self.speed*seconds

            for i = 1,#self.next_queues do
                --if you havent reached the end of the queue
                if self.w_q_index[i] <= #self.next_queues[i] then
                    self.wait[i] = self.wait[i] - seconds
                    --if your not still waiting
                    if self.wait[i] <=0 then
                        local t = self.next_queues[i][self.w_q_index[i]].p
                        t[#t+1] = self.wait[i]
                        --call the next function in the wait queue
                        --it returns the next amount to wait by
                        local w = self.next_queues[i][self.w_q_index[i]].f(
                            unpack(t)
                        )
                        --print(w,self.wait[i])
                        self.w_q_index[i] = self.w_q_index[i] + 1
                        if w ~= nil then self.wait[i] = w end
                    else
                    end
                end
            end


			self.dist_travelled = curr_dist
	--		if self.dist_travelled > self.level_dist then
	--			remove_from_render_list( self )
	--		end
		end,
		level_complete = function(self)
			remove_from_render_list( self)
			add_to_render_list( lvlcomplete )
		end
    }
}
levels[0] = {level_complete = function(self) print("Level 0 has no level_complete function") end }