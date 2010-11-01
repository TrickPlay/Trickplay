                
                   lvl1txt    =     {
                                speed = 40,
                                text = Clone{ source = txt.level1 },
                                
                                setup = function( self )
                                        self.text.position = { screen.w/2,screen.h/2}
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        self.text.opacity = 255;
					self.text.scale = {1,1}
                                        screen:add( self.text )
                                    end,
                                    
                                render = function( self , seconds )
                                        local o = self.text.opacity - self.speed * seconds
                                        local scale = self.text.scale
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        if o <= 0 then
                                            remove_from_render_list( self )
                                            screen:remove( self.text )
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
                                        self.text.position = { screen.w/2,screen.h/2}
                                        self.text.anchor_point = { self.text.w / 2 , self.text.h / 2 }
                                        self.text.opacity = 255;
                                        screen:add( self.text )
                                    end,
                                    
                                render = function( self , seconds )
                                        local o = self.text.opacity - self.speed * seconds
                                        local scale = self.text.scale
                                        scale = { scale[ 1 ] + ( 2 * seconds ) , scale[ 2 ] + ( 2 * seconds ) }
                                        if o <= 0 then
                                            remove_from_render_list( self )
                                            screen:remove( self.text )
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
		bg             = water,
		enemy_list     =
		{
---[[
			{y =    0, item = add_to_render_list,                     params = { lvl1txt        }},
			{y =   80, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
			{y =  300, item = formations.row_from_side, params = { 5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200 }},
			{y =  400, item = formations.row_from_side, params = { 5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200 }},
			{y =  550, item = formations.one_loop,   params = {2,150,200,200,300,-1}},
			{y =  700, item = formations.one_loop,  params = {2,150,screen.w-200,screen.w-200,300,1}},
			{y = 1050, item = formations.one_loop,   params = {2,150,200,200,300,-1}},
			{y = 1050, item = formations.one_loop,  params = {2,150,screen.w-200,screen.w-200,300,1}},
            
            {y = 1300, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
            {y = 1300, item = formations.row_from_side,  params = {5,150,  screen.w+100,1000,  screen.w-50,300,  screen.w-200}},
            
			{y = 1600, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  200}},
			{y = 1660, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  350}},
			{y = 1660, item = formations.one_loop,  params = {2,150,screen.w-200,screen.w-200,300,1}},
			{y = 1720, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  500}},
			{y = 1780, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
                        
			{y = 2000, item = formations.row_from_side,  params = {5,150,  -100,1000,  50,300,  650}},
			{y = 2000, item = formations.one_loop,   params = {2,150,200,200,300,-1}},
			--]]
			{y = 2300, item = formations.zepp_boss,             params = { 150 }},	
			
		},
		doodad_list  = {
		--   y_pos          asset#  x_pos x_rot y_rot z_rot
			{y =    0, params = {2, 300, 0, 0, 0}},
			{y =    0, params = {5, 1620, 0, 180, 0}},
                        
			{y =  180, params = {6, 1720,   0, 0,   0}},
			{y =  220, params = {6,  0, 0, 180,   0}},
			{y =  280, params = {8,  600,   0,   0,  0}},
			{y =  280, params = {1, 1500, 180,   0, -260}},
			{y =  380, params = {1,  200,   0, 180,   50}},
			{y =  420, params = {3, 1800, 180, 180,   90}},
			{y =  460, params = {2,  500,   0,   0,  150}},
			{y =  480, params = {1, 1500, 180, 180, -250}},
			{y =  580, params = {3,  200,   0, 180,  280}},
			{y =  620, params = {1,  500, 180,   0,  320}},
			{y =  660, params = {2, 1600,   0, 180,  150}},
			{y =  740, params = {5,  100, 180, 180,   10}},
			{y =  790, params = {3,  300,   0, 180,  300}},
			{y =  820, params = {3, 1700, 180, 180, -170}},
			{y =  860, params = {2, 1400,   0, 180,  -60}},
			{y =  890, params = {1,  500, 180,   0,   70}},
			{y =  940, params = {4, 1800, 180,   0,  130}},
			{y = 1090, params = {2, 1100,   0,   0,  190}},
			--got lazy and copy pasted
			{y = 1180, params = {1,  200,   0, 180,   50}},
			{y = 1220, params = {5,  800, 180, 180,   50}},
			{y = 1280, params = {3,  600,   0,   0,  170}},
			{y = 1280, params = {1, 1500, 180,   0, -260}},
			{y = 1380, params = {1,  200,   0, 180,   50}},
			{y = 1420, params = {3, 1800, 180, 180,   90}},
			{y = 1460, params = {2,  500,   0,   0,  150}},
			{y = 1480, params = {5, 1500, 180, 180, -250}},
			{y = 1580, params = {3,  200,   0, 180,  280}},
			{y = 1620, params = {1,  500, 180,   0,  320}},
			{y = 1660, params = {2, 1600,   0, 180,  150}},
			{y = 1740, params = {5,  100, 180, 180,   10}},
			{y = 1790, params = {3,  300,   0, 180,  300}},
			{y = 1820, params = {4, 1700, 180, 180, -170}},
			{y = 1860, params = {2, 1400,   0, 180,  -60}},
			{y = 1890, params = {5,  500, 180,   0,   70}},
			{y = 1940, params = {2, 1800, 180,   0,  130}},
			{y = 2090, params = {2, 1100,   0,   0,  190}},
			--got lazy and copy pasted...again
			{y = 2180, params = {1,  200,   0, 180,   50}},
			{y = 2220, params = {3,  800, 180, 180,   50}},
			{y = 2280, params = {5,  600,   0,   0,  170}},
			{y = 2280, params = {1, 1500, 180,   0, -260}},
			{y = 2380, params = {4,  200,   0, 180,   50}},
			{y = 2420, params = {3, 1800, 180, 180,   90}},
			{y = 2460, params = {2,  500,   0,   0,  150}},
			{y = 2480, params = {5, 1500, 180, 180, -250}},
			{y = 2580, params = {3,  200,   0, 180,  280}},
			{y = 2620, params = {1,  500, 180,   0,  320}},
			{y = 2660, params = {4, 1600,   0, 180,  150}},
			{y = 2740, params = {1,  100, 180, 180,   10}},
			{y = 2790, params = {5,  300,   0, 180,  300}},
			{y = 2820, params = {3, 1700, 180, 180, -170}},
			{y = 2860, params = {2, 1400,   0, 180,  -60}},
			{y = 2890, params = {1,  500, 180,   0,   70}},
			{y = 2940, params = {2, 1800, 180,   0,  130}},
		},
		doodad_index = 1,
		setup = function(self)
		--	add_to_render_list( self.bg )
			self.launch_index = 1
			self.doodad_index = 1
			self.dist_travelled = 0
		end,
		render = function(self,seconds)
			--if player is dead


			local curr_dist = self.dist_travelled + self.speed*seconds



			while self.launch_index <= #self.enemy_list do
				if self.enemy_list[self.launch_index].y < curr_dist and
				   self.enemy_list[self.launch_index].y >=
				   self.dist_travelled then
--print(unpack(self.launch_list[self.launch_index].params))
					--add_to_render_list(self.enemy_list[self.launch_index].item,
						 --unpack(self.enemy_list[self.launch_index].params))
					--self.launch_index = self.launch_index + 1
                    self.enemy_list[self.launch_index].item(unpack(self.enemy_list[self.launch_index].params))
                    self.launch_index = self.launch_index + 1
				else
					break
				end
			end

			while self.doodad_index <= #self.doodad_list do
				
				if self.doodad_list[self.doodad_index].y < curr_dist and
				   self.doodad_list[self.doodad_index].y >=
				   self.dist_travelled then
--print(unpack(self.launch_list[self.launch_index].params))
					add_to_render_list(self.bg:add_doodad(
						unpack(self.doodad_list[self.doodad_index].params)) )
					self.doodad_index = self.doodad_index + 1
				else
					break
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
}
levels[0] = {level_complete = function(self) print("Level 0 has no level_complete function") end }