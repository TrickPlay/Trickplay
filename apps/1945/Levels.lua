                
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
                                time  = 0,
                                speed = 40,
                                text = {
                                    Text{font = my_font , text = "L"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "e"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "v"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "e"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "l"  , color = "FFFFFF"},
                                    Text{font = my_font , text = " "  , color = "FFFFFF"},
                                    Text{font = my_font , text = "C"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "o"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "m"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "p"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "l"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "e"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "t"  , color = "FFFFFF"},
                                    Text{font = my_font , text = "e"  , color = "FFFFFF"},
                                },
                                stage=1,
                                rect = Rectangle{color="000000",w=screen_w,h=screen_h},
                                
                                setup = function( self )
                                    layers.hud:add( self.rect)
                                    self.rect:lower_to_bottom()
                                    self.rect.y = -screen_h
                                    for i,t in ipairs(self.text) do
                                        layers.hud:add( t )
                                        t.x = screen_w/2
                                        t.y = -100
                                        t.extra.targ_x = screen_w/2 + (i-#self.text/2)*50
                                    end
                                    
                                    self.stage = 1
                                    self.time = 0
                                    
                                    
                                    local rep = "Points from Level: "..state.counters[state.curr_level].lvl_points.."\n\n"
                                    for k,v in pairs(state.counters[state.curr_level]) do
                                        if type(v) == "table" then
                                            rep = rep .. k .. ":  "..v.killed .. "/"..v.spawned.."\n"
                                        end
                                    end
                                    
                                    layers.splash:find_child("level report").text=rep
                                    
                                    layers.splash:find_child("arrow").y = screen_h/2+240
                                    
                                    lvl_end_i = 1
                                end,
                                factor = 6,
                                stages = {
                                    function(self)
                                        self.rect.y = -screen_h*(1-self.time)
                                        if self.time >= 1 then
                                            self.rect.y = 0
                                            self.stage  = self.stage + 1
                                            self.time   = 0
                                        end
                                    end,
                                    function(self)
                                        for i = 1, #self.text do
                                            if i < (self.factor*self.time-1) then
                                                self.text[i].x = self.text[i].extra.targ_x
                                                self.text[i].y = 100
                                            elseif i < (self.factor*self.time) then
                                                self.text[i].x = screen_w/2 + (self.text[i].extra.targ_x - screen_w/2)* (self.factor*self.time-i)
                                                self.text[i].y = -100 + (100 - -100)*(self.factor*self.time-i)
                                            else
                                            end
                                            x = self.text
                                        end
                                        if self.factor*self.time >= #self.text then
                                            for i = 1, #self.text do
                                                self.text[i].x = self.text[i].extra.targ_x
                                                self.text[i].y = 100
                                            end
                                            self.stage  = self.stage + 1
                                            self.time   = 0
                                        end
                                    end,
                                    function(self)
                                        layers.splash:find_child("level report").opacity = 255
                                        layers.splash:find_child("arrow").opacity        = 255
                                        layers.splash:find_child("Next Level").opacity   = 255
                                        layers.splash:find_child("Replay Level").opacity = 255
                                        self.stage  = self.stage + 1
                                        state.curr_mode = "LEVEL_END"
                                    end,
                                    function(self) end
                                },
                                
                                render = function( self , seconds )
                                        
                                        self.time = self.time + seconds
                                        
                                        self.stages[self.stage](self)
                                        
                                end,
                                remove = function (self)
                                    layers.splash:find_child("level report").opacity = 0
                                    layers.splash:find_child("arrow").opacity        = 0
                                    layers.splash:find_child("Next Level").opacity   = 0
                                    layers.splash:find_child("Replay Level").opacity = 0
                                    for i = 1, #self.text do
                                        self.text[i]:unparent()
                                    end
                                    self.rect:unparent()
                                end
                            }

save_highscore =      {
                                time  = 0,
                                text = {
                                    Text{font = my_font , text = "G" , color = "FFFFFF"},
                                    Text{font = my_font , text = "A" , color = "FFFFFF"},
                                    Text{font = my_font , text = "M" , color = "FFFFFF"},
                                    Text{font = my_font , text = "E" , color = "FFFFFF"},
                                    Text{font = my_font , text = " " , color = "FFFFFF"},
                                    Text{font = my_font , text = "O" , color = "FFFFFF"},
                                    Text{font = my_font , text = "V" , color = "FFFFFF"},
                                    Text{font = my_font , text = "E" , color = "FFFFFF"},
                                    Text{font = my_font , text = "R" , color = "FFFFFF"},
                                },
                                initials = {
                                    Text{font = my_font , text = "" , color = "FFFFFF",x=screen_w/2-50},
                                    Text{font = my_font , text = "" , color = "FFFFFF",x=screen_w/2},
                                    Text{font = my_font , text = "" , color = "FFFFFF",x=screen_w/2+50},
                                },
                                stage=1,
                                rect = Rectangle{color="000000",w=screen_w,h=screen_h},
                                
                                setup = function( self )
                                    layers.splash:add( self.rect)
                                    self.rect:lower_to_bottom()
                                    self.rect.y = -screen_h
                                    for i,t in ipairs(self.text) do
                                        layers.splash:add( t )
                                        t.x = screen_w/2
                                        t.y = -100
                                        t.extra.targ_x = screen_w/2 + (i-#self.text/2)*50
                                    end
                                    
                                    for _,i in ipairs(self.initials) do
                                        layers.splash:add( i )
                                        i.text = "_"
                                    end
                                    
                                    
                                    self.stage = 1
                                    self.time = 0
                                    
                                    
                                    
                                    
                                    
                                    
                                    layers.splash:find_child("arrow").y = screen_h/2+240
                                    
                                    lvl_end_i = 1
                                end,
                                factor = 6,
                                stages = {
                                    function(self)
                                        self.rect.y = -screen_h*(1-self.time)
                                        if self.time >= 1 then
                                            self.rect.y = 0
                                            self.stage  = self.stage + 1
                                            self.time   = 0
                                        end
                                    end,
                                    function(self)
                                        for i = 1, #self.text do
                                            if i < (self.factor*self.time-1) then
                                                self.text[i].x = self.text[i].extra.targ_x
                                                self.text[i].y = 100
                                            elseif i < (self.factor*self.time) then
                                                self.text[i].x = screen_w/2 + (self.text[i].extra.targ_x - screen_w/2)* (self.factor*self.time-i)
                                                self.text[i].y = -100 + (100 - -100)*(self.factor*self.time-i)
                                            else
                                            end
                                            x = self.text
                                        end
                                        if self.factor*self.time >= #self.text then
                                            for i = 1, #self.text do
                                                self.text[i].x = self.text[i].extra.targ_x
                                                self.text[i].y = 100
                                            end
                                            self.stage  = self.stage + 1
                                            self.time   = 0
                                        end
                                    end,
                                    function(self)
                                        layers.splash:find_child("arrow").opacity = 255
                                        layers.splash:find_child("save").opacity  = 255
                                        layers.splash:find_child("exit").opacity  = 255
                                        self.stage  = self.stage + 1
                                        state.curr_mode = "LEVEL_END"
                                    end,
                                    function(self) end
                                },
                                
                                render = function( self , seconds )
                                        
                                        self.time = self.time + seconds
                                        
                                        self.stages[self.stage](self)
                                        
                                end,
                                remove = function (self)
                                    layers.splash:find_child("arrow").opacity = 0
                                    layers.splash:find_child("save").opacity  = 0
                                    layers.splash:find_child("exit").opacity  = 0
                                    for i = 1, #self.text do
                                        self.text[i]:unparent()
                                    end
                                    for i = 1, #self.initials do
                                        self.initials[i]:unparent()
                                    end
                                    self.rect:unparent()
                                end
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
                --add_to_render_list( lvlcomplete )
                
                
                --state.curr_mode = "LEVEL_END"
                level_completed:animate_in(string.format("%06d",state.counters[state.curr_level].lvl_points))
            end
		end,
		setup = function(self,o)
            state.counters[1].lvl_points = 0
            my_plane.bombing_mode = false
		--	add_to_render_list( self.bg )
            self.add_list = {
            --enemy
            {
            ---[[
                {t =    0, item = add_to_render_list,         params = { lvl1txt        }},
                
                
                
                {t =    2, item = formations.cluster,         params = {  1100 }},
                {t =    3, item = formations.cluster,         params = {  200 }},
                {t =   10, item = formations.cluster,         params = { 1700 }},
                {t =   12, item = formations.cluster,         params = {  500 }},
                {t =   17, item = formations.cluster,         params = { 1200 }},
                {t =   18, item = formations.cluster,         params = {  200 }},
                {t =   19, item = powerups.health,            params = {700}},
                {t =   21, item = formations.cluster,         params = {  900 }},
                
                {t =   27, item = formations.zig_zag,         params = {  600, 300, 30 }},
                {t =   27, item = formations.zig_zag,         params = { 1300, 300, -30 }},
                {t =   29, item = formations.cluster,         params = { 1700 }},
                {t =   30, item = formations.cluster,         params = {  300 }},
                
                {t =   36, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   41, item = powerups.life,             params = {1400}},
                {t =   41, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                {t =   46, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   51, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                {t =   52, item = formations.cluster,        params = {  125 }},
                {t =   52, item = formations.cluster,        params = { 1795 }},
                
                {t =   58, item = powerups.guns,             params = {950}},
                {t =   60, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   60, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
                {t =   70, item = formations.one_loop,       params = {2,150,100,200,300,-1}},
                {t =   70, item = formations.one_loop,       params = {2,150,screen.w-100,screen.w-200,300,1}},
                {t =   72, item = formations.cluster,        params = { 950 }},
                {t =   80, item = powerups.health,           params = {950}},
                
                {t =   82, item = enemies.zeppelin,          params = {850}},
                {t =   91, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   91, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   94, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   94, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   97, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   97, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   100, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   112, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   112, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   115, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   115, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   122, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   122, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   125, item = formations.zig_zag,         params = {  500, 300, -30 }},
                {t =   125, item = formations.zig_zag,         params = { 1420, 300,  30 }},
                {t =   128, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,screen.w-50,300,  screen.w-200}},
                {t =   135, item = formations.cluster,        params = { 400 }},
                {t =   135, item = formations.cluster,        params = { 1700 }},
                {t =   138, item = formations.cluster,        params = { 1100 }},
                {t =   142, item = formations.cluster,        params = { 1300 }},
                {t =   144, item = formations.cluster,        params = { 300 }},
                {t =   147, item = formations.cluster,        params = { 1700 }},
                {t =   149, item = powerups.health,         params = {1700}},
                --{t =   75, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  800}},
                {t =   152, item = formations.one_loop,       params = {3,300,900,200,300, 1}},
                {t =   153.5, item = formations.one_loop,       params = {3,300,900,200,300,-1}},
                {t =   162, item = formations.one_loop,       params = {2,150,100,200,300,-1}},
                {t =   162, item = formations.one_loop,       params = {2,150,screen.w-100,screen.w-200,300,1}},
                
                {t =   175, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
                {t =   178, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  350}},
                {t =   178, item = powerups.life,             params = {300}},
                {t =   178, item = formations.one_loop,       params = {2,150,screen.w-200,screen.w-200,300,1}},
                {t =   181, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  500}},
                {t =   184, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                
                {t =   192, item = formations.zig_zag,         params = {  400, 400, -45 }},
                {t =   192, item = formations.zig_zag,         params = { 1520, 400,  45 }},
                {t =   193.5, item = formations.zig_zag,         params = {  400, 400, 45 }},
                {t =   193.5, item = formations.zig_zag,         params = { 1520, 400, -45 }},
                {t =   195, item = formations.zig_zag,         params = {  400, 400, -45 }},
                {t =   195, item = formations.zig_zag,         params = { 1520, 400,  45 }},
                {t =   19, item = powerups.health,             params = {300}},
                --{t =   5, item = formations.zig_zag,         params = {  800, 200, 30 }},
                --{t =   5, item = formations.zig_zag,         params = {  1120, 200, -30 }},
                {t =   197, item = formations.zig_zag,         params = {  300, 300, -30 }},
                {t =   197, item = formations.zig_zag,         params = {  1620, 300, 30 }},
                --]]
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
                {t =   40, item = self.bg.add_island, params = {  2,  300, 0, }},
                {t =   50, item = self.bg.add_island, params = {  1, 1720,    0, }},
                {t =   60, item = self.bg.add_island, params = {  2,    0,  180,  }},
                {t =   68, item = self.bg.add_island, params = {  3,  600,    0,  }},
                {t =   75, item = self.bg.add_island, params = {  1, 1500,    0, }},
                {t =   80, item = self.bg.add_island, params = {  1,  200,  180,  }},
                {t =   82, item = self.bg.add_island, params = {  3, 1800,  180,  }},
                {t =  100, item = self.bg.add_island, params = { 2,  500,    0, }},
                {t =  110, item = self.bg.add_island, params = { 1, 1500,  180, }},
                {t =  112, item = self.bg.add_island, params = { 3,  200,  180, }},
                {t =  130, item = self.bg.add_island, params = { 1,  500,    0, }},
                {t =  136, item = self.bg.add_island, params = { 2, 1600,  180, }},
                {t =  150, item = self.bg.add_island, params = { 1,  100,  180, }},
                {t =  160, item = self.bg.add_island, params = { 3,  300,  180, }},
                {t =  167, item = self.bg.add_island, params = { 3, 1700,  180, }},
                {t =  179, item = self.bg.add_island, params = { 2, 1400,  180, }},
                {t =  200, item = self.bg.add_island, params = { 1,  500,    0, }},
                {t =  220, item = self.bg.add_island, params = { 2, 1800,    0, }},
                {t =  222, item = self.bg.add_island, params = { 2, 1100,    0, }},
                {t =  236, item = self.bg.add_island, params = { 2, 1600,  180, }},
                {t =  242, item = self.bg.add_island, params = { 3, 1700,  180, }},
                {t =  260, item = self.bg.add_island, params = { 2, 1400,  180, }},
                {t =  260, item = self.bg.add_island, params = { 3,  300,  180, }},
                {t =  271, item = self.bg.add_island, params = { 1,  500,    0, }},
                {t =  278, item = self.bg.add_island, params = { 1,  100,  180, }},
                {t =  290, item = self.bg.add_island, params = { 3, 1800,    0, }},
                {t =  300, item = self.bg.add_island, params = { 2, 1100,    0, }},
            },
            --cloud
            {
                {t =   4, item = self.bg.add_cloud, params = { 3,  1000, 0,   0,  0}},
                {t =  12, item = self.bg.add_cloud, params = { 3,   300, 0,   0,  0}},
                {t =  15, item = self.bg.add_cloud, params = { 3,  1200, 0,   0,  0}},
                {t =  20, item = self.bg.add_cloud, params = { 3,   700, 0,   0,  0}},
                {t =  21, item = self.bg.add_cloud, params = { 3,   900, 0,   0,  0}},
                {t =  30, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  31, item = self.bg.add_cloud, params = { 1,            425/2, 0, 180,  0}},
                {t =  33, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  34, item = self.bg.add_cloud, params = { 2, screen.w - 484/2+200, 0,   0,  0}},
                
                {t =  42, item = self.bg.add_cloud, params = { 3,   900, 0,   0,  0}},
                {t =  46, item = self.bg.add_cloud, params = { 3,   500, 0,   0,  0}},
                {t =  50, item = self.bg.add_cloud, params = { 3,  1200, 0,  180,  0}},
                {t =  52, item = self.bg.add_cloud, params = { 3,   300, 0,   0,  0}},
                {t =  52, item = self.bg.add_cloud, params = { 3,  1600, 0,   0,  0}},
                {t =  63, item = self.bg.add_cloud, params = { 1, screen.w - 425/2, 0,   0,  0}},
                {t =  68, item = self.bg.add_cloud, params = { 2,            484/2-100, 0, 180,  0}},
                {t =  72, item = self.bg.add_cloud, params = { 3,   900, 0,   0,  0}},
                {t =  74, item = self.bg.add_cloud, params = { 3,  1000, 0, 180,  0}},
                
                {t =  82, item = self.bg.add_cloud, params = { 3,  1050, 0, 180,  0}},
                {t =  84, item = self.bg.add_cloud, params = { 3,  950, 0,  0,  0}},
                {t =  85, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 170, 0,   0,  0}},
                {t =  90, item = self.bg.add_cloud, params = { 1,            425/2, 0, 180,  0}},
                {t =  95, item = self.bg.add_cloud, params = { 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  102, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 300, 0,   0,  0}},
                {t =  104, item = self.bg.add_cloud, params = { 2,            484/2-220, 0, 180,  0}},
                {t =  108, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  120, item = self.bg.add_cloud, params = { 1,            425/2-120, 0, 180,  0}},
                {t =  122, item = self.bg.add_cloud, params = { 3,  1200, 0,   0,  0}},
                {t =  128, item = self.bg.add_cloud, params = { 3,   700, 0,   180,  0}},
                {t =  135, item = self.bg.add_cloud, params = { 3,   900, 0,   0,  0}},
                {t =  135, item = self.bg.add_cloud, params = { 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  144, item = self.bg.add_cloud, params = { 1,            425/2-50, 0, 180,  0}},
                {t =  150, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  150, item = self.bg.add_cloud, params = { 3,  1200, 0,  180,  0}},
                {t =  152, item = self.bg.add_cloud, params = { 3,   300, 0,   0,  0}},
                {t =  152, item = self.bg.add_cloud, params = { 3,  1600, 0,   0,  0}},
                {t =  160, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  164, item = self.bg.add_cloud, params = { 1,            425/2, 0, 180,  0}},
                {t =  164, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  170, item = self.bg.add_cloud, params = { 2, screen.w - 484/2+200, 0,   0,  0}},
                
                --copy pasted
                
                {t =  172, item = self.bg.add_cloud, params = { 3,   900, 0,   0,  0}},
                {t =  174, item = self.bg.add_cloud, params = { 3,  1000, 0, 180,  0}},
                
                {t =  182, item = self.bg.add_cloud, params = { 3,  1050, 0, 180,  0}},
                {t =  184, item = self.bg.add_cloud, params = { 3,  950, 0,  0,  0}},
                {t =  185, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 170, 0,   0,  0}},
                {t =  190, item = self.bg.add_cloud, params = { 1,            425/2, 0, 180,  0}},
                {t =  195, item = self.bg.add_cloud, params = { 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  202, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 300, 0,   0,  0}},
                {t =  204, item = self.bg.add_cloud, params = { 2,            484/2-220, 0, 180,  0}},
                {t =  208, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  220, item = self.bg.add_cloud, params = { 1,            425/2-120, 0, 180,  0}},
                {t =  222, item = self.bg.add_cloud, params = { 3,  1200, 0,   0,  0}},
                {t =  228, item = self.bg.add_cloud, params = { 3,   700, 0,   180,  0}},
                {t =  235, item = self.bg.add_cloud, params = { 3,   900, 0,   0,  0}},
                {t =  235, item = self.bg.add_cloud, params = { 1, screen.w - 425/2, 0,   0,  0}},
                
                {t =  244, item = self.bg.add_cloud, params = { 1,            425/2-50, 0, 180,  0}},
                {t =  250, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  253, item = self.bg.add_cloud, params = { 3,  1200, 0,  180,  0}},
                {t =  260, item = self.bg.add_cloud, params = { 1, screen.w - 425/2+ 70, 0,   0,  0}},
                {t =  264, item = self.bg.add_cloud, params = { 1,            425/2, 0, 180,  0}},
                {t =  264, item = self.bg.add_cloud, params = { 2,            484/2, 0, 180,  0}},
                {t =  270, item = self.bg.add_cloud, params = { 2, screen.w - 484/2+200, 0,   0,  0}},
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
            end
            self.time = 200
            self.num_bosses = 2
            if type(o) == "table"  then
                print("self.overwrite_vars", o)
                recurse_and_apply(  self, o  )
            end
            
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
                    elseif self.add_list[i][ self.index[i] ].t < (self.time ) then
                        
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
        salvage = function( self, salvage_list )
            
            s = {
                func         = {"levels",1,"add_to_render_list"},
                table_params = {},
                setup_params = {},
            }
            
            table.insert(s.table_params,{
                num_bosses     = selfnum_bosses,
                time           = self.time,
                index          = {},
                
                
            })
            for i = 1, #self.index do
                s.table_params[#s.table_params].index[i] = self.index[i]
            end
            table.insert(s.table_params,self.index)
            return s
        end,

	
        add_to_render_list = function(o)
            add_to_render_list(levels[1],o)
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
        num_bosses     = 4,
        
        pier_turret = function(side)
            local x= 960
            if side == 1 then
                x = imgs.dock_1_7.w - 70
            elseif side == -1 then
                x = screen_w - imgs.dock_1_7.w + 70
            else
            end
            enemies.turret(x,0)
        end,
        
        docked_b_ship = function(side)
            local x=960
            if side == 1 then
                x = 250-imgs.b_ship.w
            elseif side == -1 then
                x = 1670
            else
            end
            enemies.battleship( x, -100, 80, false )
        end,
        
        add_harbor_tile = function(
                self,
                type,
                side,
                tile_index)
            --[[
            local c = Clone {source =  imgs["dock_"..type.."_"..tile_index]}
            
            if side == 1 then
                c.y_rotation = {180,0,0}
                c.x = imgs["dock_"..type.."_"..tile_index].w  
            elseif side == -1 then
                c.x = screen_w - imgs["dock_"..type.."_"..tile_index].w 
            else
                error("unexpected value for SIDE received, expected 1 or -1, got "..side)
            end
            
            return c
            --]]
            local c =  { source = {"imgs","dock_"..type.."_"..tile_index} }
            if side == 1 then
                c.y_rotation = 180
                c.x = imgs["dock_"..type.."_"..tile_index].w 
            elseif side == -1 then
                c.y_rotation = 0
                c.x = screen_w - imgs["dock_"..type.."_"..tile_index].w 
            else
                error("unexpected value for SIDE received, expected 1 or -1, got "..side)
            end
            return c
        end,
        
		setup = function(self)
            state.counters[2].lvl_points = 0
            local h_reg   = 1
            local h_cleat = 2
            local h_close = 3
            local h_open  = 4
            local h_pier1 = 5
            local h_pier2 = 6
            local h_piert = 7
            
            self.num_bosses     = 4
            my_plane.bombing_mode = true
		--	add_to_render_list( self.bg )
            --calling the next one
            self.bg:append_to_queue(
            {
                {   --left harbor
                ---[[
                    { enemies={{f = {"add_to_render_list"},        p = { lvl2txt } }} },
                    { self:add_harbor_tile(2,  1, h_open)},
                    { self:add_harbor_tile(2,  1, h_reg), times=2},
                    { self:add_harbor_tile(2,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(2,  1, h_reg), times=4},
                    { self:add_harbor_tile(2,  1, h_pier1),
                        enemies = {
                            {f={"levels",2,"docked_b_ship"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(2,  1, h_reg), times=4},
                    { self:add_harbor_tile(2,  1, h_pier1)},
                    { self:add_harbor_tile(2,  1, h_reg), times=7},
                    { self:add_harbor_tile(2,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(2,  1, h_reg), times=7},
                    { self:add_harbor_tile(2,  1, h_pier1),
                        enemies = {
                            {f={"levels",2,"docked_b_ship"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(2,  1, h_reg), times=4},
                    { self:add_harbor_tile(2,  1, h_pier1)},
                    { self:add_harbor_tile(2,  1, h_close)},
                          
                          
                          
                    { self:add_harbor_tile(1,  1, h_open)},
                    { self:add_harbor_tile(1,  1, h_reg), times=6},
                    { self:add_harbor_tile(1,  1, h_pier1),
                        enemies = {
                            {f={"levels",2,"docked_b_ship"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=4},
                    { self:add_harbor_tile(1,  1, h_pier1)},
                    { self:add_harbor_tile(1,  1, h_reg), times=4},
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=4},
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=4},
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=4,
                        enemies = {
                            {f = {"powerups","health"},      p = {300}},
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=7},
                    { self:add_harbor_tile(1,  1, h_close)},
                    
                    {},{},{},{},{},{},
                    
                    { self:add_harbor_tile(1,  1, h_open)},
                    { self:add_harbor_tile(1,  1, h_reg), times=6},
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}},
                            {f={"levels",2,"docked_b_ship"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=4},
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}},
                            {f={"levels",2,"docked_b_ship"}, p={1}}
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=4},
                    { self:add_harbor_tile(1,  1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={1}},
                        }
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=10},
                    
                    { self:add_harbor_tile(1,  1, h_reg), times=10,
                        enemies = {
                            {f = {"powerups","health"},      p = {300}},
                        }
                    },
                    --]]
                    { self:add_harbor_tile(1,  1, h_reg),
                        enemies={{f = {"formations","b_ship_bosses"}, p = {} }}
                    },
                    { self:add_harbor_tile(1,  1, h_reg), times=25},
                },
                
                
                {   --right harbor
                ---[[
                    {},
                    { self:add_harbor_tile(2,  -1, h_open)},
                    { self:add_harbor_tile(2,  -1, h_reg), times=2},
                    { self:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={-1}},
                        }
                    },
                    { self:add_harbor_tile(2,  -1, h_reg), times=4},
                    { self:add_harbor_tile(2,  -1, h_pier1)},
                    { self:add_harbor_tile(2,  -1, h_reg), times=10},
                    { self:add_harbor_tile(2,  -1, h_pier2),
                        enemies = {
                            {f={"levels",2,"docked_b_ship"}, p={-1}}
                        }
                    },
                    { self:add_harbor_tile(2,  -1, h_reg), times=4},
                    { self:add_harbor_tile(2,  -1, h_pier2)},
                    { self:add_harbor_tile(2,  -1, h_reg), times=10},
                    { self:add_harbor_tile(2,  -1, h_close)},
                    
                    {},{},{},{},
                    
                    { self:add_harbor_tile(1,  -1, h_open),
                        enemies=
                        {
                            {f = {"powerups","health"},      p = {1300}}
                        }
                    },
                    { self:add_harbor_tile(1,  -1, h_reg), times=2},
                    { self:add_harbor_tile(1,  -1, h_pier2),
                        enemies = {
                            {f={"levels",2,"docked_b_ship"}, p={-1}}
                        }
                    },
                    { self:add_harbor_tile(1,  -1, h_reg), times=4},
                    { self:add_harbor_tile(1,  -1, h_pier1),},
                    { self:add_harbor_tile(1,  -1, h_close)},
                    {},{},

                    { enemies =
                        {
                            {f = {"powerups","life"},     p = {1800}},
                            {f = {"enemies","destroyer"},      p = {1000, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true  }},
                        }
                    },
                    {},{},{},{},{},

                    { enemies =
                        {
                            {f = {"enemies","destroyer"},      p = {800, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true  }},
                        }
                    },
                    {},{},

                    {enemies =
                        {
                            {f = {"enemies","destroyer"},      p = {1200, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true  }},
                        }
                    },
                    {},{},{},{},{},{},
                    
                    { self:add_harbor_tile(2,  -1, h_open)},
                    { self:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={-1}},
                        }
                    },
                    { self:add_harbor_tile(2,  -1, h_reg), times=2},
                    { self:add_harbor_tile(2,  -1, h_pier2)},
                    { self:add_harbor_tile(2,  -1, h_pier2),
                        enemies = {
                            {f={"levels",2,"docked_b_ship"}, p={-1}}
                        }
                    },
                    { self:add_harbor_tile(2,  -1, h_reg), times=4},
                    { self:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={-1}},
                        }
                    },
                    { self:add_harbor_tile(2,  -1, h_close)},
                    {},{},{},{},
                    {enemies={
                    {f = {"enemies","destroyer"},      p = {1000, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true }},
                    {f = {"enemies","destroyer"},      p = {1200, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true }},
                    {f = {"enemies","destroyer"},      p = {1400, -imgs.dock_1_1.h*2/3, self.bg.speed*2/3,true }},
                    }},
                    {},{},
                    {enemies={{f = {"powerups","health"},      p = {1800} }} },
                    {},{},{},{},{},  {},{},{},{},{},
                    
                    { self:add_harbor_tile(2,  -1, h_open)},
                    { self:add_harbor_tile(2,  -1, h_piert),
                        enemies = {
                            {f={"levels",2,"pier_turret"}, p={-1}},
                        }
                    },
                    { self:add_harbor_tile(2,  -1, h_close)},
                    
                    {},{},{},{},{},{},
                    {enemies={{f = {"powerups","life"},      p = {1800} }} },
                    {},{},{},{},
                    { self:add_harbor_tile(1,  -1, h_open)},
                    --]]
                    { self:add_harbor_tile(1,  -1, h_reg), times=30},
                    { self:add_harbor_tile(1,  -1, h_reg), times=3, enemies={{f = {"lvlbg",2,"begin_to_repeat"},      p = {} }} }
                    
                    
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
            self.num_bosses = 4--1
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
                
                level_completed:animate_in(string.format("%06d",state.counters[state.curr_level].lvl_points))

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
            state.counters[3].lvl_points = 0
            my_plane.bombing_mode = true
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
                            {f = powerups.health,      p = {1800}},
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
                            {f = powerups.life,      p = {200}},
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
                            {f = powerups.health,      p = {1600}},
                            
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
                            {f = powerups.health,      p = {1800}},
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