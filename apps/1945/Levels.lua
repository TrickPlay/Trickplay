                
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
		level_dist     = 3000, --px
		time           = 0,
		launch_index   = 1,
		bg             = lvlbg[1],
        offset         = {},
        index          = {},
        add_list       = {},
        num_bosses     = 2,
		level_complete = function(self)
            self.num_bosses = self.num_bosses - 1
            if self.num_bosses == 0 then
                remove_from_render_list( self)
                add_to_render_list( lvlcomplete )
            end
		end,
		setup = function(self)
		--	add_to_render_list( self.bg )
            self.add_list = {
            --enemy
            {
                {t =    0, item = add_to_render_list,         params = { lvl1txt        }},
                
                
                
                {t =    2, item = formations.cluster,         params = {  1100 }},
                {t =    3, item = formations.cluster,         params = {  200 }},
                {t =   10, item = formations.cluster,         params = { 1700 }},
                {t =   12, item = formations.cluster,         params = {  500 }},
                {t =   17, item = formations.cluster,         params = { 1200 }},
                {t =   18, item = formations.cluster,         params = {  200 }},
                {t =   19, item = add_to_render_list,         params = {powerups.health(700)}},
                {t =   21, item = formations.cluster,         params = {  900 }},
                
                {t =   27, item = formations.zig_zag,         params = {  600, 300, 30 }},
                {t =   27, item = formations.zig_zag,         params = { 1300, 300, -30 }},
                {t =   29, item = formations.cluster,         params = { 1700 }},
                {t =   30, item = formations.cluster,         params = {  300 }},
                
                {t =   36, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   41, item = add_to_render_list,        params = {powerups.life(1400)}},
                {t =   41, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                {t =   46, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   51, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                {t =   52, item = formations.cluster,        params = {  125 }},
                {t =   52, item = formations.cluster,        params = { 1795 }},
                
                {t =   58, item = add_to_render_list,        params = {powerups.guns(950)}},
                {t =   60, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   60, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                {t =   70, item = formations.one_loop,       params = {2,150,100,200,300,-1}},
                {t =   70, item = formations.one_loop,       params = {2,150,screen.w-100,screen.w-200,300,1}},
                {t =   72, item = formations.cluster,        params = { 950 }},
                {t =   80, item = add_to_render_list,        params = {powerups.health(950)}},
                
                {t =   82, item = add_to_render_list,        params = {enemies.zeppelin(850)}},
                {t =   97, item = formations.zig_zag,         params = {  400, 300, -30 }},
                {t =   97, item = formations.zig_zag,         params = { 1520, 300,  30 }},
                {t =   112, item = formations.zig_zag,         params = {  400, 300, -30 }},
                {t =   112, item = formations.zig_zag,         params = { 1520, 300,  30 }},
                {t =   115, item = formations.zig_zag,         params = {  400, 300, -30 }},
                {t =   115, item = formations.zig_zag,         params = { 1520, 300,  30 }},
                {t =   122, item = formations.zig_zag,         params = {  400, 300, -30 }},
                {t =   122, item = formations.zig_zag,         params = { 1520, 300,  30 }},
                {t =   125, item = formations.zig_zag,         params = {  400, 300, -30 }},
                {t =   125, item = formations.zig_zag,         params = { 1520, 300,  30 }},
                {t =   135, item = formations.cluster,        params = { 400 }},
                {t =   135, item = formations.cluster,        params = { 1700 }},
                {t =   149, item = add_to_render_list,         params = {powerups.health(1700)}},
                --{t =   75, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  800}},
                {t =   152, item = formations.one_loop,       params = {3,300,900,200,300, 1}},
                {t =   153.5, item = formations.one_loop,       params = {3,300,900,200,300,-1}},
                
                
                {t =   175, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   178, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  350}},
                {t =   178, item = add_to_render_list,        params = {powerups.life(300)}},
                {t =   178, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                {t =   181, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  500}},
                {t =   184, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                
                {t =   192, item = formations.zig_zag,         params = {  400, 400, -45 }},
                {t =   192, item = formations.zig_zag,         params = { 1520, 400,  45 }},
                {t =   193.5, item = formations.zig_zag,         params = {  400, 400, 45 }},
                {t =   193.5, item = formations.zig_zag,         params = { 1520, 400, -45 }},
                {t =   195, item = formations.zig_zag,         params = {  400, 400, -45 }},
                {t =   195, item = formations.zig_zag,         params = { 1520, 400,  45 }},
                {t =   19, item = add_to_render_list,         params = {powerups.health(300)}},
                --{t =   5, item = formations.zig_zag,         params = {  800, 200, 30 }},
                --{t =   5, item = formations.zig_zag,         params = {  1120, 200, -30 }},
                {t =   197, item = formations.zig_zag,         params = {  300, 300, -30 }},
                {t =   197, item = formations.zig_zag,         params = {  1620, 300, 30 }},
                
                {t =   202, item = formations.zig_zag,         params = {  400, 300, -20 }},
                {t =   202, item = formations.zig_zag,         params = {  800, 300, 20 }},
                {t =   202, item = formations.zig_zag,         params = {  1200, 300, 20 }},
                {t =   202, item = formations.zig_zag,         params = {  1600, 300, -20 }},
                {t =   205, item = formations.cluster,         params = {  600 }},
                {t =   205, item = formations.cluster,         params = {  1400 }},
                {t =   210, item = formations.zepp_boss,         params = {1200}},
                {t =   210, item = formations.zepp_boss,         params = {400}},
                {t =   212, item = formations.cluster,         params = {  600 }},
                {t =   212, item = formations.cluster,         params = {  1400 }},
                {t =   300, item = self.level_complete,        params = {self}},
                {t =   300, item = self.level_complete,        params = {self}},
            },
            --island
            {
                {t =    40, item = self.bg.add_island, params = {self.bg,  2, 300, 0, 0,}},
                {t =  50, item = self.bg.add_island, params = {self.bg, 1, 1720,    0, }},
                {t =  60, item = self.bg.add_island, params = {self.bg, 2,    0,  180,  }},
                {t =  68, item = self.bg.add_island, params = {self.bg, 3,  600,    0,  }},
                {t =  75, item = self.bg.add_island, params = {self.bg, 1, 1500,    0, }},
                {t =  80, item = self.bg.add_island, params = {self.bg, 1,  200,  180,  }},
                {t =  82, item = self.bg.add_island, params = {self.bg, 3, 1800,  180,  }},
                {t =  100, item = self.bg.add_island, params = {self.bg, 2,  500,    0, }},
                {t =  110, item = self.bg.add_island, params = {self.bg, 1, 1500,  180, }},
                {t =  112, item = self.bg.add_island, params = {self.bg, 3,  200,  180, }},
                {t =  130, item = self.bg.add_island, params = {self.bg, 1,  500,    0, }},
                {t =  136, item = self.bg.add_island, params = {self.bg, 2, 1600,  180, }},
                {t =  150, item = self.bg.add_island, params = {self.bg, 1,  100,  180, }},
                {t =  160, item = self.bg.add_island, params = {self.bg, 3,  300,  180, }},
                {t =  167, item = self.bg.add_island, params = {self.bg, 3, 1700,  180, }},
                {t =  179, item = self.bg.add_island, params = {self.bg, 2, 1400,  180, }},
                {t =  200, item = self.bg.add_island, params = {self.bg, 1,  500,    0, }},
                {t =  220, item = self.bg.add_island, params = {self.bg, 2, 1800,    0, }},
                {t =  222, item = self.bg.add_island, params = {self.bg, 2, 1100,    0, }},
                {t =  236, item = self.bg.add_island, params = {self.bg, 2, 1600,  180, }},
                {t =  242, item = self.bg.add_island, params = {self.bg, 3, 1700,  180, }},
                {t =  260, item = self.bg.add_island, params = {self.bg, 2, 1400,  180, }},
                {t =  260, item = self.bg.add_island, params = {self.bg, 3,  300,  180, }},
                {t =  271, item = self.bg.add_island, params = {self.bg, 1,  500,    0, }},
                {t =  278, item = self.bg.add_island, params = {self.bg, 1,  100,  180, }},
                {t =  290, item = self.bg.add_island, params = {self.bg, 3, 1800,    0, }},
                {t =  300, item = self.bg.add_island, params = {self.bg, 2, 1100,    0, }},
            },
            --cloud
            {
                {t =   4, item = self.bg.add_cloud, params = {self.bg, 3,  1000, 0,   0,  0}},
                {t =  12, item = self.bg.add_cloud, params = {self.bg, 3,   300, 0,   0,  0}},
                {t =  15, item = self.bg.add_cloud, params = {self.bg, 3,  1200, 0,   0,  0}},
                {t =  20, item = self.bg.add_cloud, params = {self.bg, 3,   700, 0,   0,  0}},
                {t =  21, item = self.bg.add_cloud, params = {self.bg, 3,   900, 0,   0,  0}},
                {t =  30, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  31, item = self.bg.add_cloud, params = {self.bg, 1,            425/2, 0, 180,  0}},
                {t =  33, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  34, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2+200, 0,   0,  0}},
                
                {t =  42, item = self.bg.add_cloud, params = {self.bg, 3,   900, 0,   0,  0}},
                {t =  46, item = self.bg.add_cloud, params = {self.bg, 3,   500, 0,   0,  0}},
                {t =  50, item = self.bg.add_cloud, params = {self.bg, 3,  1200, 0,  180,  0}},
                {t =  52, item = self.bg.add_cloud, params = {self.bg, 3,   300, 0,   0,  0}},
                {t =  52, item = self.bg.add_cloud, params = {self.bg, 3,  1600, 0,   0,  0}},
                {t =  63, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0,   0,  0}},
                {t =  68, item = self.bg.add_cloud, params = {self.bg, 2,            484/2-100, 0, 180,  0}},
                {t =  72, item = self.bg.add_cloud, params = {self.bg, 3,   900, 0,   0,  0}},
                {t =  74, item = self.bg.add_cloud, params = {self.bg, 3,  1000, 0, 180,  0}},
                
                {t =  82, item = self.bg.add_cloud, params = {self.bg, 3,  1050, 0, 180,  0}},
                {t =  84, item = self.bg.add_cloud, params = {self.bg, 3,  950, 0,  0,  0}},
                {t =  85, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 170, 0,   0,  0}},
                {t =  90, item = self.bg.add_cloud, params = {self.bg, 1,            425/2, 0, 180,  0}},
                {t =  95, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  102, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 300, 0,   0,  0}},
                {t =  104, item = self.bg.add_cloud, params = {self.bg, 2,            484/2-220, 0, 180,  0}},
                {t =  108, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  120, item = self.bg.add_cloud, params = {self.bg, 1,            425/2-120, 0, 180,  0}},
                {t =  122, item = self.bg.add_cloud, params = {self.bg, 3,  1200, 0,   0,  0}},
                {t =  128, item = self.bg.add_cloud, params = {self.bg, 3,   700, 0,   180,  0}},
                {t =  135, item = self.bg.add_cloud, params = {self.bg, 3,   900, 0,   0,  0}},
                {t =  135, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  144, item = self.bg.add_cloud, params = {self.bg, 1,            425/2-50, 0, 180,  0}},
                {t =  150, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  150, item = self.bg.add_cloud, params = {self.bg, 3,  1200, 0,  180,  0}},
                {t =  152, item = self.bg.add_cloud, params = {self.bg, 3,   300, 0,   0,  0}},
                {t =  152, item = self.bg.add_cloud, params = {self.bg, 3,  1600, 0,   0,  0}},
                {t =  160, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  164, item = self.bg.add_cloud, params = {self.bg, 1,            425/2, 0, 180,  0}},
                {t =  164, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  170, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2+200, 0,   0,  0}},
                
                --copy pasted
                
                {t =  172, item = self.bg.add_cloud, params = {self.bg, 3,   900, 0,   0,  0}},
                {t =  174, item = self.bg.add_cloud, params = {self.bg, 3,  1000, 0, 180,  0}},
                
                {t =  182, item = self.bg.add_cloud, params = {self.bg, 3,  1050, 0, 180,  0}},
                {t =  184, item = self.bg.add_cloud, params = {self.bg, 3,  950, 0,  0,  0}},
                {t =  185, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 170, 0,   0,  0}},
                {t =  190, item = self.bg.add_cloud, params = {self.bg, 1,            425/2, 0, 180,  0}},
                {t =  195, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  202, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 300, 0,   0,  0}},
                {t =  204, item = self.bg.add_cloud, params = {self.bg, 2,            484/2-220, 0, 180,  0}},
                {t =  208, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  220, item = self.bg.add_cloud, params = {self.bg, 1,            425/2-120, 0, 180,  0}},
                {t =  222, item = self.bg.add_cloud, params = {self.bg, 3,  1200, 0,   0,  0}},
                {t =  228, item = self.bg.add_cloud, params = {self.bg, 3,   700, 0,   180,  0}},
                {t =  235, item = self.bg.add_cloud, params = {self.bg, 3,   900, 0,   0,  0}},
                {t =  235, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  244, item = self.bg.add_cloud, params = {self.bg, 1,            425/2-50, 0, 180,  0}},
                {t =  250, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  253, item = self.bg.add_cloud, params = {self.bg, 3,  1200, 0,  180,  0}},
                {t =  260, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  264, item = self.bg.add_cloud, params = {self.bg, 1,            425/2, 0, 180,  0}},
                {t =  264, item = self.bg.add_cloud, params = {self.bg, 2,            484/2, 0, 180,  0}},
                {t =  270, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2+200, 0,   0,  0}},
                --[[
                {t =  100, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  170, item = self.bg.add_cloud, params = {self.bg, 1,            425/2- 10, 0, 180,  0}},
                {t =  280, item = self.bg.add_cloud, params = {self.bg, 3,                  700, 0,   0,  0}},
                {t =  340, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2+200, 0,   0,  0}},
                {t =  380, item = self.bg.add_cloud, params = {self.bg, 1,            425/2-150, 0, 180,  0}},
                {t =  420, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+100, 0,   0,  0}},
                {t =  480, item = self.bg.add_cloud, params = {self.bg, 2,            484/2-220, 0, 180,  0}},
                {t =  580, item = self.bg.add_cloud, params = {self.bg, 3,              300, 0, 180,  0}},
                {t =  620, item = self.bg.add_cloud, params = {self.bg, 1, screen.w - 425/2+ 20, 0,   0,  0}},
                {t =  660, item = self.bg.add_cloud, params = {self.bg, 2, screen.w - 484/2+ 80, 0,   0,  0}},
                {t =  740, item = self.bg.add_cloud, params = {self.bg, 1,            425/2-111, 0, 180,  0}},
                {t =  790, item = self.bg.add_cloud, params = {self.bg, 3,              300, 0, 180,  0}},
                {t =  820, item = self.bg.add_cloud, params = {self.bg, 3,             1700, 0, 180,  0}},
                --]]
            }
            }
            for i = 1, #self.add_list do
                self.index[i] = 1
                self.offset[i] = 0
            end
            self.time = 0
		end,
		render = function(self,seconds)
			--if player is dead


			--local curr_dist = self.dist_travelled + self.speed*seconds
            self.time = self.time + seconds
            for i = 1,#self.add_list do
                local done = false
                while not done do
                	
                    if  self.index[i] > #self.add_list[i] then
                    --[[
                        if i ~= 1 then
                            self.index[i] = 1
                            self.offset[i] = curr_dist
                            print("aaa",i,self.offset[i])
                        end
                        --]]
                        done = true
                    elseif self.add_list[i][ self.index[i] ].t < (self.time - self.offset[i]) then
                        
                        self.add_list[i][self.index[i]].item(unpack(self.add_list[i][self.index[i]].params))
                        self.index[i] = self.index[i] + 1
                	else
                		done = true
                	end
                end
            end


	--		if self.dist_travelled > self.level_dist then
	--			remove_from_render_list( self )
	--		end
		end,


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
    },
    {
    	speed          = 80,   --px/s
		level_dist     = 3000, --px
		dist_travelled = 0,
		launch_index   = 1,
		bg             = lvlbg[3],
        offset         = {},
        index          = {},
        add_list       = {},
        wait           = {},
        w_q_index      = {},
        
		setup = function(self)
            
            --each func in the list returns the amount of time to wait before
            --calling the next one
            self.bg:append_to_queue(
                {
                    {Clone{source=imgs.road_diagonal,x=300-2*imgs.road_diagonal.w}},--y_rotation={180,imgs.road_diagonal.w/2,imgs.road_diagonal.h/2}}},
                    {Clone{source=imgs.road_diagonal,x=300-imgs.road_diagonal.w,x_rotation={180,imgs.road_diagonal.w/2,imgs.road_diagonal.h/2}}},
                    {Clone{source=imgs.road_diagonal,x=300-imgs.road_diagonal.w,y_rotation={180,imgs.road_diagonal.w/2,imgs.road_diagonal.h/2}}},
                    {Clone{source=imgs.road_diagonal,x=300-imgs.road_diagonal.w,x_rotation={180,imgs.road_diagonal.w/2,imgs.road_diagonal.h/2}}},
                    {Clone{source=imgs.road_diagonal,x=300,y_rotation={180,imgs.road_diagonal.w/2,imgs.road_diagonal.h/2}}},
                    {Clone{source=imgs.road_straight,x=400}},
                    {Clone{source=imgs.road_straight,x=300}},
                    {Clone{source=imgs.road_straight,x=400}},
                    {Clone{source=imgs.road_straight,x=300}},
                    {Clone{source=imgs.road_straight,x=400}},
                    {Clone{source=imgs.road_straight,x=300}},
                    {Clone{source=imgs.road_straight,x=400}},
                    {Clone{source=imgs.road_straight,x=300}},
                    {Clone{source=imgs.road_straight,x=400}},
                    {Clone{source=imgs.road_straight,x=300}},
                    {Clone{source=imgs.road_straight,x=400}},
                }
            )

			self.dist_travelled = 0
		end,
		render = function(self,seconds)
			--if player is dead


			local curr_dist = self.dist_travelled + self.speed*seconds
--[[
            for i = 1,#self.next_queues do
                --if you havent reached the end of the queue
                if self.w_q_index[i] <= #self.next_queues[i] then
                    self.wait[i] = self.wait[i] - seconds
                    --if your not still waiting
                    if self.wait[i] <=0 then
                        local t = self.next_queues[i][self.w_q_index[i] ].p
                        t[#t+1] = self.wait[i]
                        --call the next function in the wait queue
                        --it returns the next amount to wait by
                        local w = self.next_queues[i][self.w_q_index[i] ].f(
                            unpack(t)
                        )
                        --print(w,self.wait[i])
                        self.w_q_index[i] = self.w_q_index[i] + 1
                        if w ~= nil then self.wait[i] = w end
                    else
                    end
                end
            end
--]]

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