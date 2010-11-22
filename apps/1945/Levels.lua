                
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
                {t =  40, item = self.bg.add_island, params = {self.bg,  2, 300, 0, 0,}},
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
        num_bosses     = 4,
        
        pier_turret = function(side)
            local x= 960
            if side == 1 then
                x = imgs.dock_1_7.w - 70
            elseif side == -1 then
                x = screen_w - imgs.dock_1_7.w + 70
            else
            end
            add_to_render_list(enemies.turret(), x, 0)
        end,
        
        docked_b_ship = function(side)
            local x=960
            if side == 1 then
                x = 250-imgs.b_ship.w
            elseif side == -1 then
                x = 1670
            else
            end
            add_to_render_list(enemies.battleship(), x, -100, 80,false)
        end,
        
		setup = function(self)
            
            local h_reg   = 1
            local h_cleat = 2
            local h_close = 3
            local h_open  = 4
            local h_pier1 = 5
            local h_pier2 = 6
            local h_piert = 7
            
		--	add_to_render_list( self.bg )
            --calling the next one
            self.bg:append_to_queue(
            {
                {   --left harbor
                ---[[
                    --{f = add_to_render_list,        p = { lvl2txt        }},
                    { enemies={{f = add_to_render_list,        p = { lvl2txt } }} },
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_open,false,false  }},
                    { self.bg:add_harbor_tile(2,  1, h_open)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  2,  1,      2}},
                    { self.bg:add_harbor_tile(2,  1, h_reg), times=2},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(2,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2,  1,      4 }},
                    { self.bg:add_harbor_tile(2,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,true }},
                    { self.bg:add_harbor_tile(2,  1, h_pier1),
                        enemies = {
                            {f=self.docked_b_ship, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2,  1,      4 }},
                    { self.bg:add_harbor_tile(2,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,false }},
                    { self.bg:add_harbor_tile(2,  1, h_pier1)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  2,  1,      7 }},
                    { self.bg:add_harbor_tile(2,  1, h_reg), times=7},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(2,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2,  1,      7 }},
                    { self.bg:add_harbor_tile(2,  1, h_reg), times=7},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,true }},
                    { self.bg:add_harbor_tile(2,  1, h_pier1),
                        enemies = {
                            {f=self.docked_b_ship, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2,  1,      4 }},
                    { self.bg:add_harbor_tile(2,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_pier1,false,false }},
                    { self.bg:add_harbor_tile(2,  1, h_pier1)},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2,  1, h_close,false,false  }},
                    { self.bg:add_harbor_tile(2,  1, h_close)},
                    
                    
                    
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_open ,false,false }},
                    { self.bg:add_harbor_tile(1,  1, h_open)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      6 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=6},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_pier1,false,true }},
                    { self.bg:add_harbor_tile(1,  1, h_pier1),
                        enemies = {
                            {f=self.docked_b_ship, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_pier1,false,false }},
                    { self.bg:add_harbor_tile(1,  1, h_pier1)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}}
                        }
                    },
                    --{f = add_to_render_list,      p = {powerups.health(300)}},
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4,
                        enemies = {
                            {f = add_to_render_list,      p = {powerups.health(300)}},
                        }
                    },
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      7 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=7},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_close ,false,false }},
                    { self.bg:add_harbor_tile(1,  1, h_close)},
                    
                    --{f = self.bg.empty_stretch,   p = {self.bg,   6 }},
                    {},{},{},{},{},{},
                    
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_open ,false,false }},
                    { self.bg:add_harbor_tile(1,  1, h_open)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      6 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=6},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,true }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}},
                            {f=self.docked_b_ship, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4},
                    --]]
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,true }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}},
                            {f=self.docked_b_ship, p={1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,       4 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1,  1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={1}},
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      10 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=10},
                    --{f = add_to_render_list,      p = {powerups.health(300)}},
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      3 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=10,
                        enemies = {
                            {f = add_to_render_list,      p = {powerups.health(300)}},
                        }
                    },
                    --[[
                    {f = add_to_render_list,      p = {enemies.battleship(),300, 1600, -15 }},
                    {f = add_to_render_list,      p = {enemies.battleship(),700, 1600, -15 }},
                    {f = add_to_render_list,      p = {enemies.battleship(),1100, 1600, -15 }},
                    {f = add_to_render_list,      p = {enemies.battleship(),1500, 1600, -15 }},
                    --]]
                    { self.bg:add_harbor_tile(1,  1, h_reg),
                        enemies={{f = formations.b_ship_bosses, p = {} }}
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1,  1,      25 }},
                    { self.bg:add_harbor_tile(1,  1, h_reg), times=25},
                },
                
                
                {   --right harbor
                ---[[
                    {},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_open,false,false  }},
                    { self.bg:add_harbor_tile(2,  -1, h_open)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      2 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=2},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert, true,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={-1}},
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      4 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier1,false,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_pier1)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      10 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=10},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,true }},
                    { self.bg:add_harbor_tile(2,  -1, h_pier2),
                        enemies = {
                            {f=self.docked_b_ship, p={-1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      4 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_pier2)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      10 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=10},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_close,false,false  }},
                    { self.bg:add_harbor_tile(2,  -1, h_close)},
                    
                    --{f = self.bg.empty_stretch,   p = {self.bg,   4 }},
                    {},{},{},{},
                    
                    --{f = add_to_render_list,      p = {powerups.health(1300)}},
                    
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_open,false,false  }},
                    { self.bg:add_harbor_tile(1,  -1, h_open),
                        enemies=
                        {
                            {f = add_to_render_list,      p = {powerups.health(1300)}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1, -1,      2 }},
                    { self.bg:add_harbor_tile(1,  -1, h_reg), times=2},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_pier2,false,true }},
                    { self.bg:add_harbor_tile(1,  -1, h_pier2),
                        enemies = {
                            {f=self.docked_b_ship, p={-1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  1, -1,      4 }},
                    { self.bg:add_harbor_tile(1,  -1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_pier1,false,false }},
                    { self.bg:add_harbor_tile(1,  -1, h_pier1),},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_close ,false,false }},
                    { self.bg:add_harbor_tile(1,  -1, h_close)},
                    
                    --{f = self.bg.empty_stretch,   p = {self.bg,   2 }},
                    {},{},
                    
                    --{f = add_to_render_list,      p = {powerups.life(1800)}},
                    --{f = add_to_render_list,      p = {enemies.destroyer(),1000, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3 }},
                    --{f = self.bg.empty_stretch,   p = {self.bg,   5 }},
                    { enemies =
                        {
                            {f = add_to_render_list,      p = {powerups.life(1800)}},
                            {f = add_to_render_list,      p = {enemies.destroyer(),1000, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true  }},
                        }
                    },
                    {},{},{},{},{},
                    
                    --{f = add_to_render_list,      p = {enemies.destroyer(),800, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3 }},
                    --{f = self.bg.empty_stretch,   p = {self.bg,   2 }},
                    { enemies =
                        {
                            {f = add_to_render_list,      p = {enemies.destroyer(),800, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true  }},
                        }
                    },
                    {},{},
                    --{f = add_to_render_list,      p = {enemies.destroyer(),1200, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3 }},
                    --{f = self.bg.empty_stretch,   p = {self.bg,   6 }},
                    {enemies =
                        {
                            {f = add_to_render_list,      p = {enemies.destroyer(),1200, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true  }},
                        }
                    },
                    {},{},{},{},{},{},
                    
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_open,false,false  }},
                    { self.bg:add_harbor_tile(2,  -1, h_open)},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={-1}},
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      2 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=2},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_pier2)},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_pier2,false,true}},
                    { self.bg:add_harbor_tile(2,  -1, h_pier2),
                        enemies = {
                            {f=self.docked_b_ship, p={-1}}
                        }
                    },
                    --{f = self.bg.add_stretch,     p = {self.bg,  2, -1,      4 }},
                    { self.bg:add_harbor_tile(2,  -1, h_reg), times=4},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={-1}},
                        }
                    },
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_close,false,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_close)},
                    --{f = self.bg.empty_stretch,   p = {self.bg,   4 }},
                    {},{},{},{},
                    {enemies={
                    {f = add_to_render_list,      p = {enemies.destroyer(),1000, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true }},
                    {f = add_to_render_list,      p = {enemies.destroyer(),1200, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true }},
                    {f = add_to_render_list,      p = {enemies.destroyer(),1400, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true }},
                    }},
                    --{f = self.bg.empty_stretch,   p = {self.bg,   2 }},
                    {},{},
                    --{f = add_to_render_list,      p = {powerups.health(1800)}},
                    {enemies={{f = add_to_render_list,      p = {powerups.health(1800)} }} },
                    --{f = self.bg.empty_stretch,   p = {self.bg,   10 }},
                    {},{},{},{},{},  {},{},{},{},{},
                    
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_open ,false,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_open)},
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_piert,true,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f=self.pier_turret, p={-1}},
                        }
                    },
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  2, -1, h_close,false,false }},
                    { self.bg:add_harbor_tile(2,  -1, h_close)},
                    
                    --{f = self.bg.empty_stretch,   p = {self.bg,   6 }},
                    {},{},{},{},{},{},
                    {enemies={{f = add_to_render_list,      p = {powerups.life(1800)} }} },
                    --{f = self.bg.empty_stretch,   p = {self.bg,   4 }},
                    {},{},{},{},
                    --]]
                    --{f = self.bg.add_harbor_tile, p = {self.bg,  1, -1, h_open,false,false  }},
                    { self.bg:add_harbor_tile(1,  -1, h_open)},
                    --{f = self.bg.add_stretch,     p = {self.bg,  1, -1,     30}},
                    { self.bg:add_harbor_tile(1,  -1, h_reg), times=30},
                    {self.bg:add_harbor_tile(1,  -1, h_reg), times=3, enemies={{f = self.bg.begin_to_repeat,      p = {self.bg} }} }
                    
                    
                }
            }
            )
            --[[
            for i = 1, #self.add_list do
                self.index[i] = 1
                self.offset[i] = 0
            end
            for i = 1, #self.next_queues do
                self.w_q_index[i] = 1
                self.wait[i] = 0
            end
			self.dist_travelled = 0
            --]]
            remove_from_render_list( self )
		end,
		render = function(self,seconds)
        --[[
			--if player is dead


			local curr_dist = self.dist_travelled + self.speed*seconds

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


			self.dist_travelled = curr_dist
	--		if self.dist_travelled > self.level_dist then
	--			remove_from_render_list( self )
	--		end
    --]]
		end,
		level_complete = function(self)
            self.num_bosses = self.num_bosses - 1
            if self.num_bosses == 0 then
                remove_from_render_list( self)
                add_to_render_list( lvlcomplete )
            end
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
            
            
            self.bg:append_to_queue(
                {---[[
                    {
                        Clone{source=imgs.trench_l, x=1300+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=1300+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=1300+3*imgs.trench_l.w},
                        enemies={
                            {f=add_to_render_list,p={enemies.trench(),1300+2*imgs.trench_l.w,-144-imgs.trench_l.h/2-10}},
                        }
                    },
                    {
                        Clone{source=imgs.trench_l, x=500+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=500+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=500+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=500+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=500+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=500+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=500+7*imgs.trench_l.w},
                        enemies={
                            {f=add_to_render_list,p={enemies.trench(),500+2*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),500+5*imgs.trench_l.w,-100, 40,true}},
                        }
                    },
                    {

                        Clone{source=imgs.road_hor, x=300-5*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300-4*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300-3*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300-2*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300-imgs.road_hor.w},
                        Clone{source=imgs.road_left,x=300},
                    },
                    {Clone{source=imgs.road_ver,x=300},times=5},
                    {Clone{source=imgs.road_ver,x=300},times=3,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {1,-200,3,150 }},
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300}, times   = 2,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {1,-200,3,150 }},
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.dirt_area_1,x=500,y=-imgs.dirt_area_1.h},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.dirt_area_1.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300}, times=2,
                        enemies = {
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_sm,x=1150,y=-imgs.building_sm.h,z_rotation={90}},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_sm.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_sm,x=850,y=-imgs.building_sm.h+50,z_rotation={-90}},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_sm.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300},times=3},
                    {Clone{source=imgs.road_ver,x=300},times=2,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {1200,-1,3,150}},
                            {f = add_to_render_list,      p = {powerups.health(1800)}},
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300},times=3,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {400,-1,3,150}},
                        }
                    },

                    {
                        Clone{source=imgs.road_right,x=300},
                        Clone{source=imgs.road_hor, x=300+  imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300+2*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300+3*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300+4*imgs.road_hor.w},
                        Clone{source=imgs.road_hor, x=300+5*imgs.road_hor.w},
                        Clone{source=imgs.road_left,x=300+6*imgs.road_hor.w},
                    },
                    {Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w},times=2},
                    {
                        Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w},
                        Clone{source=imgs.trench_l, x=50+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=50+8*imgs.trench_l.w},
                        
                        Clone{source=imgs.trench_l,  x=1250},
                        Clone{source=imgs.trench_reg,x=1250+1*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=1250+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=1250+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=1250+4*imgs.trench_l.w},
                        enemies={
                            {f=add_to_render_list,p={enemies.trench(),50+2*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),50+4*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),50+7*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),1250+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),1250+3*imgs.trench_l.w,-100, 40,true}},
                            
                            
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w},times=3},
                    {
                        Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=50},
                        Clone{source=imgs.trench_reg,x=50+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=50+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=50+8*imgs.trench_l.w},
                        
                        Clone{source=imgs.trench_l,  x=1250},
                        Clone{source=imgs.trench_reg,x=1250+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=1250+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=1250+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=1250+4*imgs.trench_l.w},
                        enemies={
                            
                            {f=add_to_render_list,p={enemies.trench(),50+2*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),50+4*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),50+6*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),1250+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),1250+3*imgs.trench_l.w,-100, 40,true}},
                            {f = add_to_render_list,      p = {powerups.life(200)}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w},times=3},
                    {Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w},times=3,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {-1,-200,5,150 }},
                            {f = add_to_render_list,            p = {enemies.jeep(false),270+6*imgs.road_hor.w,-100}},
                            
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w}, times   = 3,
                        enemies = {
                            
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.dirt_area_2,x=100,y=-imgs.dirt_area_2.h},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.dirt_area_2.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+6*imgs.road_ver.w}, times=6,
                        enemies = {
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_big,x=700,y=-imgs.building_big.h},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_big.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p = {enemies.tank(false),700, -400}},
                            {f = add_to_render_list,      p = {enemies.tank(false),800, -400}},
                            {f = add_to_render_list,      p = {enemies.tank(false),900, -400}}
                            
                        }
                    },

                    
                    {
                        Clone{source=imgs.road_right,x=300+6*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+7*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+8*imgs.road_hor.w},
                        Clone{source=imgs.road_left,x=300+9*imgs.road_hor.w},
                        enemies = { {f = add_to_render_list,      p = {powerups.health(200)}},}
                    },
                    {
                        
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=100},
                        Clone{source=imgs.trench_reg,x=100+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+8*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+9*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=100+10*imgs.trench_l.w},
                        
                        
                        enemies={
                            
                            {f=add_to_render_list,p={enemies.trench(),100+2*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+5*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+8*imgs.trench_l.w,-100, 40,true}},
                            
                            
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w}},
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=100},
                        Clone{source=imgs.trench_reg,x=100+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+8*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+9*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=100+10*imgs.trench_l.w},
                        
                        
                        enemies={
                            {f=add_to_render_list,p={enemies.trench(),100+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+3*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+5*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+7*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+9*imgs.trench_l.w,-100, 40,true}},
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},
                        enemies={
                            {f = add_to_render_list,      p = {enemies.tank(false),200,  -150}},
                            {f = add_to_render_list,      p = {enemies.tank(false),400,  -150}},
                            {f = add_to_render_list,      p = {enemies.tank(false),1650, -150}},
                            {f = add_to_render_list,      p = {enemies.jeep(true),2000,100}},
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=100},
                        Clone{source=imgs.trench_reg,x=100+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+8*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+9*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=100+10*imgs.trench_l.w},
                        
                        
                        enemies={
                            {f=add_to_render_list,p={enemies.trench(),100+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+4*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+6*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+9*imgs.trench_l.w,-100, 40,true}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=2},
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w}, times   = 7,
                        enemies = {
                            
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.dirt_area_3,x=100,y=-imgs.dirt_area_3.h},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.dirt_area_3.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{
                                    source=imgs.dirt_area_2,
                                    x=800,
                                    y=-imgs.dirt_area_2.h/2,
                                    z_rotation={180,0,0},
                                    anchor_point={imgs.dirt_area_2.w/2,imgs.dirt_area_2.h/2}
                                },
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.dirt_area_2.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_sm,x=600,y=-imgs.building_sm.h-100},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_sm.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_big,x=500,y=-imgs.building_big.h-300},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_big.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p = {enemies.tank(false),400, -200}},
                            {f = add_to_render_list,      p = {enemies.tank(false),400, -600}},
                            {f = add_to_render_list,      p = {enemies.tank(false),800, -600}},
                            {f = add_to_render_list,      p = {enemies.tank(false),800, -200}},
                            {f = add_to_render_list,      p = {enemies.tank(false),400, -400}},
                            {f = add_to_render_list,      p = {enemies.tank(false),800, -400}}
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=100},
                        Clone{source=imgs.trench_reg,x=100+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+8*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+9*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=100+10*imgs.trench_l.w},
                        
                        
                        enemies={
                            {f=add_to_render_list,p={enemies.trench(),100+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+3*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+5*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+7*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+9*imgs.trench_l.w,-100, 40,true}},
                        }
                    },
                    
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=3,
                        enemies = {
                            --{f = add_to_render_list,      p = {powerups.health(600)}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=10,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {-1,-300,6,150 }},
                            {f = formations.hor_row_tanks,      p = {1,-450,6,150 }},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=3,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {300,1,4,150}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=10,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {300,1,4,150}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=5,
                        enemies = {
                            {f = add_to_render_list,p = {enemies.jeep(false),300+9*imgs.road_ver.w-20,-100}},
                            
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=3,
                        enemies = {
                            {f = add_to_render_list,      p = {powerups.health(1600)}},
                            
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=10,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {1,-450,6,150 }},
                        }
                    },
                    
                    {Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},times=10,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {1,-450,6,150 }},
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300+9*imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=100},
                        Clone{source=imgs.trench_reg,x=100+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+8*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=100+9*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=100+10*imgs.trench_l.w},
                        enemies = {
                            {f=add_to_render_list,p={enemies.trench(),100+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+3*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+5*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+7*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),100+9*imgs.trench_l.w,-100, 40,true}},
                        }
                    },
                    {
                        Clone{source=imgs.road_left,x=300+9*imgs.road_hor.w,z_rotation={-90,0,0}},
                        Clone{source=imgs.road_hor,x=300+8*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+7*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+6*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+5*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+4*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+3*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+2*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+1*imgs.road_hor.w},
                        Clone{source=imgs.road_hor,x=300+0*imgs.road_hor.w},
                        Clone{source=imgs.road_right,x=300-imgs.road_ver.w,z_rotation={-90,0,0}},
                    },
                    {
                        Clone{source=imgs.road_ver,x=300-imgs.road_ver.w},
                        Clone{source=imgs.trench_l,  x=300},
                        Clone{source=imgs.trench_reg,x=300+  imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+2*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+3*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+4*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+5*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+6*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+7*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+8*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+9*imgs.trench_l.w},
                        Clone{source=imgs.trench_reg,x=300+10*imgs.trench_l.w},
                        Clone{source=imgs.trench_r,  x=300+11*imgs.trench_l.w},
                        enemies = {
                            {f=add_to_render_list,p={enemies.trench(),300+1*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),300+3*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),300+5*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),300+7*imgs.trench_l.w,-100, 40,true}},
                            {f=add_to_render_list,p={enemies.trench(),300+9*imgs.trench_l.w,-100, 40,true}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300-imgs.road_ver.w},times=3,
                        enemies = {
                            {f = formations.hor_row_tanks,      p = {1,-150,3,150 }},
                            {f = formations.hor_row_tanks,      p = {1,-400,3,150 }},
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300-imgs.road_ver.w}, times   = 2,
                        enemies = {
                            
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.dirt_area_1,x=500,y=-imgs.dirt_area_1.h},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.dirt_area_1.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.dirt_area_3,x=200,y=-imgs.dirt_area_3.h},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.dirt_area_3.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                        }
                    },
                    {
                        Clone{source=imgs.road_ver,x=300-imgs.road_ver.w}, times=2,
                        enemies = {
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_sm,x=1150,y=-imgs.building_sm.h,z_rotation={90}},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_sm.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                            {f = add_to_render_list,      p =
                            {
                            {
                                c = Clone{source=imgs.building_big,x=500,y=-imgs.building_big.h-300},
                                setup=function(s) layers.ground:add(s.c) end,
                                render = function(s,secs)
                                    s.c.y = s.c.y + self.bg.speed*secs
                                    if s.c.y > (screen_h + imgs.building_big.h) then
                                        s.c:unparent()
                                        remove_from_render_list(s)
                                    end
                                end,
                            }
                            }
                            },
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300-imgs.road_ver.w},times=3},
                    {Clone{source=imgs.road_ver,x=300-imgs.road_ver.w},times=2,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {1200,-1,3,150}},
                            {f = add_to_render_list,      p = {powerups.health(1800)}},
                        }
                    },
                    {Clone{source=imgs.road_ver,x=300-imgs.road_ver.w},times=2,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {300,-1,3,150}},
                        }
                    },
                    --]]
                    {Clone{source=imgs.road_ver,x=300-imgs.road_ver.w},times=2,
                        enemies = {
                            {f = formations.vert_row_tanks,      p = {500,-1,3,150}},
                        }
                    },
                    {
                        Clone{source=imgs.road_left,x=300-1*imgs.road_hor.w,z_rotation={-90,0,0}},
                        enemies = {
                            {f = formations.hor_row_tanks,      p = { 1,-150,4,200 }},
                            {f = formations.hor_row_tanks,      p = { 1,-400,4,200 }},
                            {f = formations.hor_row_tanks,      p = { 1,-650,4,200 }},
                            {f = formations.hor_row_tanks,      p = {-1,-275,4,200 }},
                            {f = formations.hor_row_tanks,      p = {-1,-525,4,200 }},
                            {f = formations.hor_row_tanks,      p = {-1,-775,4,200 }},
                        }
                    },
                    {},{},{},{},{},{},
                    {
                        enemies = {
                            {f = formations.hor_row_tanks,      p = { 1,-150,4,200 }},
                            {f = formations.hor_row_tanks,      p = { 1,-400,4,200 }},
                            {f = formations.hor_row_tanks,      p = { 1,-650,4,200 }},
                            {f = formations.hor_row_tanks,      p = {-1,-275,4,200 }},
                            {f = formations.hor_row_tanks,      p = {-1,-525,4,200 }},
                            {f = formations.hor_row_tanks,      p = {-1,-775,4,200 }},
                        }
                    },
                    {},{},{},{},{},{},{},{},{},{},{},{},
                    {
                        enemies = {
                            {f = self.level_complete,      p = {self}},
                        }
                    }
                }
            )

			self.dist_travelled = 0
            remove_from_render_list(self)
		end,
		render = function(self,seconds)

		end,
		level_complete = function(self)
			add_to_render_list( lvlcomplete )
		end
    }
}
levels[0] = {level_complete = function(self) print("Level 0 has no level_complete function") end }