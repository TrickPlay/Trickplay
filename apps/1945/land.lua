


lvlbg = {


--Level 1
{
    salvage_func  = {"lvlbg",1},
    salvage_params = {},
    table_params   = {},
    overwrites     = {},
    speed         = 50, -- pixels per second
    doodad_list   = {},
    img_h         = nil,
    image         = nil, 
    setup         = function( self )
        
        self.image = Clone{source=base_imgs.water1} --Image{src = "assets/lvls/bg_tiles/water1.png" }
        self.img_h = tilesize
        
        layers.ground:add(self.image)
        
    end,
    add_cloud = function(index, xxx, x_rot, y_rot, z_rot, overwrite_vars)
        local cloud =
        
        {
            salvage_func   = {"lvlbg",1,"add_cloud"},
            salvage_params = {index, xxx, x_rot, y_rot, z_rot},
            overwrites     = {},
            speed_y = lvlbg[1].speed+10,
            speed_x = 10,
            x       = 0,
            y       = 0,

            index   = 0,
            image   = Clone{ 
                source       = curr_lvl_imgs[ "cloud"..tostring( index ) ] ,
                anchor_point =
                {
                    curr_lvl_imgs[ "cloud"..tostring( index ) ].w/2,
                    curr_lvl_imgs[ "cloud"..tostring( index ) ].h/2
                },
                x_rotation   = { x_rot , 0, 0},
                y_rotation   = { y_rot , 0, 0},
                z_rotation   = { z_rot , 0, 0},
                opacity      = 255 ,
            },
            setup = function( self )
                if xxx <= self.image.w / 2 then
                    xxx = xxx-5*92;
                end
                layers.air_doodads_2:add( self.image )
                self.image:lower_to_bottom()
                self.image.anchor_point = {  self.image.w / 2 ,  self.image.h / 2 }
                -----self.x = xxx
                self.image.x = xxx
                self.image.y = -self.image.h / 2
                -----self.y = offset-self.image.h--self.image.h / 2
                -----self.image.y = math.ceil(self.y/4)*4
                -----self.image.x = math.ceil(self.x/4)*4
                self.img_h = self.image.h
                lvlbg[1].doodad_list[self] = true
                if type(overwrite_vars) == "table"  then
                    --print("self.overwrite_vars", overwrite_vars)
                    recurse_and_apply(  self, overwrite_vars  )
                end
            end,
            remove = function(self)
                    self.image:unparent()
                end,
            render = function( self , seconds )
                self.image.x = self.image.x + self.speed_x * seconds
                self.image.y = self.image.y + self.speed_y * seconds
                if self.image.y > (screen_h+self.img_h) then
                    remove_from_render_list( self )
                    self.image:unparent()
                    if lvlbg[1].doodad_list[self] then
                        lvlbg[1].doodad_list[self] = nil
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
                overwrites   = {
                    image = {
                        x = self.image.x,
                        y = self.image.y,
                    },
                }
                
                table.insert(s.table_params,overwrites)
                
                
                return s
            end,
        }
        
        add_to_render_list(cloud)
    end,
    add_island = function(index, xxx, y_rot, overwrite_vars)
        --local offset = self.offset
        local island =
            
            {
                salvage_func   = {"lvlbg",1,"add_island"},
                salvage_params = {index, xxx, y_rot, },
                speed = lvlbg[1].speed,

                index = 0,
                image = Clone{ 
					source       = curr_lvl_imgs[ "island"..tostring( index ) ] ,
                    anchor_point =
                    {
                        curr_lvl_imgs[ "island"..tostring( index ) ].w/2,
                        curr_lvl_imgs[ "island"..tostring( index ) ].h/2
                    },
					y_rotation   = { y_rot , 0, 0},
					z_rotation   = { z_rot , 0, 0},
					opacity      = 255 ,
				},
                setup = function( self )
                        layers.land_doodads_1:add( self.image )
						--self.image:lower_to_bottom()
						self.image.anchor_point = {  self.image.w / 2 ,  self.image.h / 2 }
                        self.image.position     = {               xxx , -self.image.h/2 }
                        -----self.y = self.g_off-self.image.h
                        -----self.image.y = math.ceil(self.y/4)*4
                        self.img_h = self.image.h                        
                        lvlbg[1].doodad_list[self] = true
                        if type(overwrite_vars) == "table"  then
                            recurse_and_apply(  self, overwrite_vars  )
                        end
                end,
                remove = function(self)
                    self.image:unparent()
                end,
                render = function( self , seconds )
                        -----if self.p_off > lvlbg[1].offset then
                        -----    self.index = self.index + 1
                        -----end
                        -----self.p_off = lvlbg[1].offset
                        -----self.y = self.p_off+(self.index-1)*240-- + self.speed * seconds
                        -----self.image.y = math.ceil(self.y/4)*4
                        self.image.y = self.image.y + self.speed * seconds
                        if self.image.y > (screen_h+self.img_h) then
                            remove_from_render_list( self )
                            self.image:unparent()
                            if lvlbg[1].doodad_list[self] then
                                lvlbg[1].doodad_list[self] = nil
                            end
                        end
                        
                end,
                salvage = function( self, salvage_list )
                
                    s = {
                        func         = {},
                        table_params = {},
                        setup_params = {},
                    }
                    
                    for i = 1, #self.salvage_params do
                        s.table_params[i] = self.salvage_params[i]
                    end

                    for i = 1, #self.salvage_func do
                        s.func[i] = self.salvage_func[i]
                    end
                    overwrites   = {
                        image = {
                            x = self.image.x,
                            y = self.image.y,
                        },
                    }
                    
                    table.insert(s.table_params,overwrites)
                    
                    
                    return s
                end,
            }
	    add_to_render_list( island )
	end,
            
    render = function( self , seconds )
        self.image.y = self.image.y + self.speed*seconds
        if self.image.y > 0 then
            self.image.y = self.image.y - self.img_h
            --print(self)
        end
    end,
    remove = function(self)
        self.image:unparent()
        self.image = nil
        for k,v in pairs(self.doodad_list) do
            k.image:unparent()
        end
    end,
    saaalvage = function( self, salvage_list )
        s = {
            func         = {},
            table_params = {},
            setup_params = {},
        }
        
        overwrites   = {
            g = {
                y = self.g.y,
            },
        }
        
        table.insert(s.table_params,overwrites)
        
        for i = 1, #self.salvage_params do
            s.table_params[i] = self.salvage_params[i]
        end

        for i = 1, #self.salvage_func do
            s.func[i] = self.salvage_func[i]
        end
        return s
    end,
},



--Level 2
{
    speed         = 80, -- pixels per second
    doodad_frames = {},
    doodad_h      = 0,
    top_doodad    = 0,
    q_i           = 0,
    append_i      = 0,
    queues        = {},
    enemies       = {},
    repeating     = false,
    image         = nil, --Image{src = "assets/lvls/bg_tiles/water2.png" },
    setup         = function( self,o, top_doodad )
        self.image    = Clone{source=curr_lvl_imgs.water2}
        self.doodad_h = curr_lvl_imgs.dock_1_1.h
        self.img_h    = tilesize
        
        self.image:set{
            tile   = {true, true},
            w      = screen_w,
            h      = screen_h+self.img_h,
            y      = -self.img_h
        }
        
        layers.ground:add(self.image)
        if o ~= nil then
            --dumptable(o)
        end
        local g
        local num_frames = math.ceil(screen_h/self.doodad_h)+1
        --setup the doodad frames
        if top_doodad then
            self.top_doodad = top_doodad
        else
            self.top_doodad = -self.doodad_h
        end
        for i = 1, num_frames do
            g   =  Group{y=(num_frames - i )*(self.doodad_h-1)+self.top_doodad}
            table.insert( self.doodad_frames , g)
            layers.land_doodads_1:add(g)
            
            self.q_i = self.q_i + 1
            
            if o ~= nil and o[self.q_i] ~= nil then
                --print(type(o[self.q_i]),#o[self.q_i])
                for j = 1, #o[self.q_i] do
                    g:add(Clone{
                        source     =  _G[ o[self.q_i][j].source[1] ][ o[self.q_i][j].source[2] ],
                        x          =  o[self.q_i][j].x,
                        y          =  self.doodad_h/2,
                        y_rotation = {o[self.q_i][j].y_rotation,0,0}
                    })
                    if self.queues[self.q_i] == nil then
                        self.queues[self.q_i] = {}
                    end
                    
                    table.insert(self.queues[self.q_i],o[self.q_i][j])
                end
            end
            
            
        end
        if o ~= nil then
            --print("num o",#o)
            for i = (self.q_i+1), #o do
                self.queues[i] = {}
                --print(#o[i])
                for j = 1, #o[i] do
                    table.insert(self.queues[i],o[i][j])
                end
                if o[i].enemies ~= nil then
                --print("rite hurr")
                    if  self.enemies[i] == nil then
                        self.enemies[i] = {}
                    end
                    for j = 1, #o[i].enemies do
                        table.insert(self.enemies[i], o[i].enemies[j])
                    end
                end
            end
            self.append_i = #o+1
        else
            self.append_i =self.q_i + 1
        end
        
        
    end,
    append_to_queue = function(self,q)
        local qq_i = 0
        for k = 1, #q do
        local q_i = 1
        local c
        for i = 1,   #q[k] do
            
            if q[k][i].enemies ~= nil then
                if  self.enemies[self.append_i+q_i] == nil then
                    self.enemies[self.append_i+q_i] = {}
                end
                for j = 1, #q[k][i].enemies do
                    table.insert(self.enemies[self.append_i+q_i], q[k][i].enemies[j])
                end
            end
            if q[k][i].times ~= nil then
                assert(q[k][i][1] ~= nil and q[k][i][2] == nil)
                --print(q[k][i].times)
                
                for j = 1, q[k][i].times do
                    if  self.queues[self.append_i+q_i] == nil then
                        self.queues[self.append_i+q_i] = {}
                    end
                    --[[
                    c = Clone
                    {
                        source=q[k][i][1].source,
                        x = q[k][i][1].x,
                        y = q[k][i][1].source.h/2,
                        y_rotation = {q[k][i][1].y_rotation[1],0,0},
                        --anchor_point={q[k][i][1].w/2,q[k][i][1].h/2}
                    }--]]
                    table.insert(self.queues[self.append_i+q_i], q[k][i][1])
                    q_i = q_i+1
                end
            else
                if  self.queues[self.append_i+q_i] == nil then
                    self.queues[self.append_i+q_i] = {}
                end
                for j = 1, #q[k][i] do
                    --q[k][i][j].anchor_point = {q[k][i][j].w/2,q[k][i][j].h/2}
                    --q[k][i][j].y = q[k][i][j].h/2
                    table.insert(self.queues[self.append_i+q_i], q[k][i][j])
                end
                q_i = q_i+1
            end
            
        end
        if qq_i < q_i then qq_i = q_i end
        end
        self.append_i = self.append_i + qq_i
    end,
    
    begin_to_repeat = function()
        lvlbg[2].repeating = true
    end,
    render = function( self , seconds )
            
            local dy   = self.speed * seconds
            local f
            
            self.image.y = self.image.y + dy
            if self.image.y > 0 then
                self.image.y = self.image.y - self.img_h
            end
            self.top_doodad = self.top_doodad + dy
            
            --print("next")
            --reposition all the doodads
            for _ , frame in ipairs( self.doodad_frames ) do
                frame.y = frame.y + dy
                --if dropped below the bottom of the screen...
                
                if frame.y > screen_h then
                    
                    --move it to the top
                    frame.y = self.top_doodad - self.doodad_h+1  
                    self.top_doodad = frame.y
                    
                    --clear out the frame
                    if not self.repeating then
                    frame:clear()
                    self.queues[self.q_i - #self.doodad_frames-1] = nil
                    
                    --update the position
                    self.q_i = self.q_i + 1
                    if self.q_i >= self.append_i then
                        self.append_i = self.q_i + 1
                    end
                    
                    
                    --load the next doodads
                    if self.queues[self.q_i] ~= nil then
                        for _,new_child in ipairs(self.queues[self.q_i]) do
                            --dumptable(new_child)
                            frame:add(Clone{
                                source     =  _G[new_child.source[1]][new_child.source[2]],
                                x          =  new_child.x,
                                y          =  self.doodad_h/2,
                                y_rotation = {new_child.y_rotation,0,0}
                            })
                        end
                    end
                    if self.enemies[self.q_i] ~= nil then
                        for _,e in ipairs(self.enemies[self.q_i]) do
                            f = _G
                            for j = 1,#e.f do
                                --print(e.f[j])
                                f = f[ e.f[j] ]
                            end
                            --print("done\n\n")
                            f(unpack(e.p))
                        end
                    end
                    end
                end
            end
    end, 
    remove = function(self)
        self.image:unparent()
        local n = #self.doodad_frames
        for i=1,n do
            self.doodad_frames[i]:clear()
            self.doodad_frames[i]:unparent()
            self.doodad_frames[i] = nil
        end
    end,
    salvage = function(self)
        s = {
            func = {"salvage_level_2"},
            table_params = {{ queues={}, top_doodad = self.top_doodad, num_bosses = levels[2].num_bosses, repeating = lvlbg[2].repeating }}
        }
        local iii = 0
        for i = (self.q_i - #self.doodad_frames), self.append_i do
            s.table_params[1].queues[iii] = {}
            if type(self.queues[i]) == "table" then
                for j = 1, #self.queues[i] do
                    s.table_params[1].queues[iii][j] = {}
                    s.table_params[1].queues[iii][j].x = self.queues[i][j].x
                    s.table_params[1].queues[iii][j].y_rotation = self.queues[i][j].y_rotation
                    s.table_params[1].queues[iii][j].source = {
                        self.queues[i][j].source[1],
                        self.queues[i][j].source[2]
                    }
                end
                
                if self.enemies[i] ~= nil then
                    s.table_params[1].queues[iii].enemies = {}
                    for j = 1, #self.enemies[i] do
                        s.table_params[1].queues[iii].enemies[j] = {}
                        s.table_params[1].queues[iii].enemies[j].f ={}
                        for k = 1, #self.enemies[i][j].f do
                            s.table_params[1].queues[iii].enemies[j].f[k] = self.enemies[i][j].f[k]
                        end
                        s.table_params[1].queues[iii].enemies[j].p ={}
                        for k = 1, #self.enemies[i][j].p do
                            s.table_params[1].queues[iii].enemies[j].p[k] = self.enemies[i][j].p[k]
                        end
                    end
                end
            end
            iii = iii + 1
        end
            
        return s
    end
},



--Level 3
{
    speed         = 80, -- pixels per second
    trees         = {},
    tree_i = 1,
    doodad_frames = {},
    doodad_h      = 144,--imgs.dirt_full.h,
    top_doodad    = 0,
    q_i           = 0,
    append_i      = 0,
    queues        = {},
    enemies       = {},
    image         = nil, --Image{src = "assets/lvls/bg_tiles/grass1.png" },
    setup         = function( self, o, top_doodad  )
	self.image = Clone{source=curr_lvl_imgs.grass1}
	self.trees.l={Clone{source=curr_lvl_imgs.trees,x=-curr_lvl_imgs.trees.w/2},
               Clone{source=curr_lvl_imgs.trees,x=-curr_lvl_imgs.trees.w/2,y=-curr_lvl_imgs.trees.h}
            }
	self.trees.r={Clone{source=curr_lvl_imgs.trees,x=screen_w-curr_lvl_imgs.trees.w/2},
               Clone{source=curr_lvl_imgs.trees,x=screen_w-curr_lvl_imgs.trees.w/2,y=-curr_lvl_imgs.trees.h}
            }
        self.img_h = tilesize
        self.image:set{
            tile   = {true, true},
            w      = screen_w,
            h      = screen_h+self.img_h,
            y      = -self.img_h
        }
        layers.ground:add(self.image)
        
        local g
        local num_frames =  math.ceil(screen_h/self.doodad_h)+1
        --setup the doodad frames
        if top_doodad then
            self.top_doodad = top_doodad
        else
            self.top_doodad = -self.doodad_h
        end
        for i = 1, num_frames do
            g   =  Group{y=(num_frames - i)*(self.doodad_h-1)+self.top_doodad, name="level 3 conveyor group"}
            table.insert( self.doodad_frames , g)
            layers.land_doodads_1:add(g)
            
            self.q_i = self.q_i + 1
            
            if o ~= nil and o[self.q_i] ~= nil then
                --print(type(o[self.q_i]),#o[self.q_i])
                for j = 1, #o[self.q_i] do
                    g:add(Clone{
                        source     =  _G[ o[self.q_i][j].source[1] ][ o[self.q_i][j].source[2] ],
                        x          =  o[self.q_i][j].x,
                        y          =  _G[ o[self.q_i][j].source[1] ][ o[self.q_i][j].source[2] ].h/2,
                        z_rotation = {o[self.q_i][j].z_rotation,0,0},
                        ---[[
                        anchor_point =
                                    {
                                        _G[ o[self.q_i][j].source[1] ][ o[self.q_i][j].source[2] ].w/2,
                                        _G[ o[self.q_i][j].source[1] ][ o[self.q_i][j].source[2] ].h/2
                                    }
                        --]]
                    })
                    if self.queues[self.q_i] == nil then
                        self.queues[self.q_i] = {}
                    end
                    
                    table.insert(self.queues[self.q_i],o[self.q_i][j])
                end
            end
        end
        if o ~= nil then
            --print("num o",#o)
            for i = (self.q_i+1), #o do
                self.queues[i] = {}
                --print(#o[i])
                for j = 1, #o[i] do
                    table.insert(self.queues[i],o[i][j])
                end
                if o[i].enemies ~= nil then
                --print("rite hurr")
                    if  self.enemies[i] == nil then
                        self.enemies[i] = {}
                    end
                    for j = 1, #o[i].enemies do
                        table.insert(self.enemies[i], o[i].enemies[j])
                    end
                end
            end
            self.append_i = #o+1
        else
            self.append_i =self.q_i + 1
        end
        layers.land_doodads_2:add(self.trees.l[1],self.trees.l[2],self.trees.r[1],self.trees.r[2])
    end,
    ---[[
    add_building = function(building,x,y,z_rot, big_explo,o)
    --print(building,x,y,z_rot, big_explo,o)
        add_to_render_list( {
                image = Clone{source=curr_lvl_imgs[building],x=x,y=y,z_rotation={z_rot,0,0}},
                dead = false,
                setup=function(s)
                    layers.land_doodads_1:add(s.image)
                    if type(o) == "table"  then
                        recurse_and_apply(  s, o  )
                        --s.image:raise_to_top()
                    end
                    if s.dead then
                        local c = Clone{
                            source     = curr_lvl_imgs[building.."_d"],
                            x          =  s.image.x,
                            y          =  s.image.y,
                            z_rotation = {s.image.z_rotation[1],0,0}
                        }
                        layers.land_doodads_1:add(c)
                        s.image:unparent()
                        s.image = c
                    end
                end,
                render = function(s,secs)
                    s.image.y = s.image.y + lvlbg[3].speed*secs
                    if s.image.y > (screen_h + 2*curr_lvl_imgs.building_1_1.h) then
                        s.image:unparent()
                        remove_from_render_list(s)
                    end
                    if not s.dead then
                        if s.image.z_rotation[1] == -90 then
                            table.insert(b_guys_land,
                                {
                                    obj = s,
                                    x1  = s.image.x,--/2,
                                    x2  = s.image.x+s.image.h,--/2,
                                    y1  = s.image.y-s.image.w,--/2,
                                    y2  = s.image.y,--/2,
                                }
                            )
                        elseif s.image.z_rotation[1] == 90 then
                            table.insert(b_guys_land,
                                {
                                    obj = s,
                                    x1  = s.image.x-s.image.h,--/2,
                                    x2  = s.image.x,--/2,
                                    y1  = s.image.y,--/2,
                                    y2  = s.image.y+s.image.w,--/2,
                                }
                            )
                        else
                            table.insert(b_guys_land,
                                {
                                    obj = s,
                                    x1  = s.image.x,--/2,
                                    x2  = s.image.x+s.image.w,--/2,
                                    y1  = s.image.y,--/2,
                                    y2  = s.image.y+s.image.h,--/2,
                                }
                            )
                        end
                    end
                end,
                collision = function( self , other )
                    local c = Clone{
                        source     = curr_lvl_imgs[building.."_d"],
                        x          =  self.image.x,
                        y          =  self.image.y,
                        z_rotation = {self.image.z_rotation[1],0,0}
                    }
                    layers.land_doodads_1:add(c)
                    self.image:unparent()
                    self.image = c
                    
                    self.dead = true
                	-- Explode
                    if big_explo then
                        add_to_render_list(
                            explosions.big(
                                self.image.x+self.image.w/2,
                                self.image.y+self.image.h/2
                            )
                        )
                        points(self.image.x,self.image.y,300)
                    else
                        add_to_render_list(
                            explosions.small(
                                self.image.x+self.image.w/2,
                                self.image.y+self.image.h/2
                            )
                        )
                        points(self.image.x,self.image.y,200)
                    end
                    
                end,
                salvage = function(self)
                    s = {
                        func         = {"lvlbg",3,"add_building"},
                        table_params = {building,x,y,z_rot, big_explo},
                    }
                    
                    
                    table.insert(s.table_params,
                        {
                            image = {
                                y          =  self.image.y,
                                z_rotation = {self.image.z_rotation[1],0,0}
                            },
                            dead = self.dead
                        }
                    )
                    
                return s
            end,
            } )
    end,
    add_dirt = function(dirt_i,x,o)
        add_to_render_list( {
            c = Clone{
                source = curr_lvl_imgs["dirt_area_"..dirt_i],
                x      = x,
                y      =-curr_lvl_imgs["dirt_area_"..dirt_i].h
            },
            setup = function(s)
                layers.ground:add(s.c)
                if type(o) == "table"  then
                    recurse_and_apply(  s, o  )
                end
            end,
            render = function(s,secs)
                s.c.y = s.c.y + lvlbg[3].speed*secs
                if s.c.y > (screen_h + curr_lvl_imgs.dirt_area_1.h) then
                    s.c:unparent()
                    remove_from_render_list(s)
                end
                
            end,
            salvage = function(self)
                s = {
                    func         = {"lvlbg",3,"add_dirt"},
                    table_params = {dirt_i,x},
                }
                
                
                table.insert(s.table_params,
                    {
                        c = {
                            y = self.c.y
                        }
                    }
                )
                
                return s
            end,
            
        } )
    end,
    --]]
    append_to_queue = function(self,q)
        
        local q_i = 1
        local c
        for i = 1,   #q do
            
            if q[i].enemies ~= nil then
                if  self.enemies[self.append_i+q_i] == nil then
                    self.enemies[self.append_i+q_i] = {}
                end
                for j = 1, #q[i].enemies do
                    table.insert(self.enemies[self.append_i+q_i], q[i].enemies[j])
                end
            end
            if q[i].times ~= nil then
                assert(q[i][1] ~= nil and q[i][2] == nil)
                --print(q[i].times)
                
                for j = 1, q[i].times do
                    if  self.queues[self.append_i+q_i] == nil then
                        self.queues[self.append_i+q_i] = {}
                    end
                    --[[
                    c = Clone
                    {
                        source=q[i][1].source,
                        x = q[i][1].x,
                        y = q[i][1].h/2,
                        z_rotation={q[i][1].z_rotation[1],0,0},
                        anchor_point={q[i][1].w/2,q[i][1].h/2}
                    }
                    --]]
                    table.insert(self.queues[self.append_i+q_i], q[i][1])
                    q_i = q_i+1
                end
            else
                if  self.queues[self.append_i+q_i] == nil then
                    self.queues[self.append_i+q_i] = {}
                end
                for j = 1, #q[i] do
                    --q[i][j].anchor_point = {q[i][j].w/2,q[i][j].h/2}
                    --q[i][j].y = q[i][j].h/2
                    table.insert(self.queues[self.append_i+q_i], q[i][j])
                end
                q_i = q_i+1
            end
            
        end
        self.append_i = self.append_i + q_i
    end,
    empty_stretch = function(self,len,delay)
        return curr_lvl_imgs["dock_1_1"].h*len/self.speed + delay
    end,
    add_stretch = function(self,type,side,len,delay)
        local c
        
        for i = 1,len do
            c = Clone {source =  curr_lvl_imgs["dock_"..type.."_1"]}
            if side == 1 then
                c.y_rotation = {180,0,0}
                c.x = curr_lvl_imgs["dock_"..type.."_1"].w  
            elseif side == -1 then
                c.x = screen_w - curr_lvl_imgs["dock_"..type.."_1"].w 
            else
                error("unexpected value for SIDE received, expected 1 or -1, got "..side)
            end
            if self.queues[self.q_i+i] == nil then self.queues[self.q_i+i] = {} end
            table.insert(self.queues[self.q_i+i],c)
        end
        
        return self.doodad_h*len/self.speed + delay
    end,

    render = function( self , seconds )
            
            local dy   = self.speed * seconds
            
            --self.top_strip  = self.top_strip  + dy
            self.top_doodad = self.top_doodad + dy
            
            self.trees.l[1].y = self.trees.l[1].y + dy
            self.trees.l[2].y = self.trees.l[2].y + dy
            self.trees.r[1].y = self.trees.r[1].y + dy
            self.trees.r[2].y = self.trees.r[2].y + dy
            
            if self.trees.l[self.tree_i].y >= screen_h then
                self.trees.l[self.tree_i].y = self.trees.l[self.tree_i].y - 2*self.trees.l[self.tree_i].h
                self.trees.r[self.tree_i].y = self.trees.r[self.tree_i].y - 2*self.trees.r[self.tree_i].h
                self.tree_i = self.tree_i % 2 + 1
            end
            
            self.image.y = self.image.y + dy
            if self.image.y > 0 then
                self.image.y = self.image.y - self.img_h
            end
            
            --print("next")
            --reposition all the doodads
            for _ , frame in ipairs( self.doodad_frames ) do
                frame.y = frame.y + dy
                --print(frame.y)
                
                --if dropped below the bottom of the screen...
                if frame.y > screen_h then
                    
                    --move it to the top
                    frame.y = self.top_doodad - self.doodad_h+1--frame.y - screen.h - self.doodad_h  
                    self.top_doodad = frame.y
                    
                    --clear out the frame
                    frame:clear()
                    self.queues[self.q_i - #self.doodad_frames] = nil
                    
                    --update the position
                    self.q_i = self.q_i + 1
                    if self.q_i >= self.append_i then
                        self.append_i = self.q_i + 1
                    end
                    
                    
                    --load the next doodads
                    if self.queues[self.q_i] ~= nil then
                        --[[
                        for _,new_child in ipairs(self.queues[self.q_i]) do
                            frame:add(new_child)
                        end
                        --]]
                        for _,new_child in ipairs(self.queues[self.q_i]) do
                            --dumptable(new_child)
                            if new_child.z_rotation == nil then
                                new_child.z_rotation = 0
                            end
                            frame:add(Clone{
                                source       = _G[new_child.source[1]][new_child.source[2]],
                                x            = new_child.x,
                                y            = _G[new_child.source[1]][new_child.source[2]].h/2,
                                z_rotation   = {new_child.z_rotation,0,0},
                                anchor_point =
                                    {
                                        _G[new_child.source[1]][new_child.source[2]].w/2,
                                        _G[new_child.source[1]][new_child.source[2]].h/2
                                    }
                            })
                        end
                    end
                    if self.enemies[self.q_i] ~= nil then
                        --for _,e in ipairs(self.enemies[self.q_i]) do
                        --    e.f(unpack(e.p))
                        --end
                        
                        
                        for _,e in ipairs(self.enemies[self.q_i]) do
                            f = _G
                            for j = 1,#e.f do
                                --print(e.f[j])
                                f = f[ e.f[j] ]
                            end
                            --print("done\n\n")
                            f(unpack(e.p))
                        end
                    end
                end
            end
    end,
    remove = function(self)
        self.image:unparent()
        local n = #self.doodad_frames
        for i=1,n do
            self.doodad_frames[i]:clear()
            self.doodad_frames[i]:unparent()
            self.doodad_frames[i] = nil
        end
        self.trees.l[1]:unparent()
        self.trees.l[2]:unparent()
        self.trees.r[1]:unparent()
        self.trees.r[2]:unparent()

    end,
    salvage = function(self)
        s = {
            func = {"salvage_level_3"},
            table_params = {{ queues={}, top_doodad = self.top_doodad }}
        }
        local iii = 0
        for i = (self.q_i - #self.doodad_frames), self.append_i do
            s.table_params[1].queues[iii] = {}
            if type(self.queues[i]) == "table" then
                for j = 1, #self.queues[i] do
                    s.table_params[1].queues[iii][j] = {}
                    s.table_params[1].queues[iii][j].x = self.queues[i][j].x
                    s.table_params[1].queues[iii][j].z_rotation = 0-- self.queues[i][j].z_rotation
                    s.table_params[1].queues[iii][j].source = {
                        self.queues[i][j].source[1],
                        self.queues[i][j].source[2]
                    }
                end
                
                if self.enemies[i] ~= nil then
                    s.table_params[1].queues[iii].enemies = {}
                    for j = 1, #self.enemies[i] do
                        s.table_params[1].queues[iii].enemies[j] = {}
                        s.table_params[1].queues[iii].enemies[j].f ={}
                        for k = 1, #self.enemies[i][j].f do
                            s.table_params[1].queues[iii].enemies[j].f[k] = self.enemies[i][j].f[k]
                        end
                        s.table_params[1].queues[iii].enemies[j].p ={}
                        for k = 1, #self.enemies[i][j].p do
                            s.table_params[1].queues[iii].enemies[j].p[k] = self.enemies[i][j].p[k]
                        end
                    end
                end
            end
            iii = iii + 1
        end
            
        return s
    end
},

--Level 4
{
    speed = 80, -- pixels per second
    image = nil, --Image{src = "assets/lvls/bg_tiles/water2.png" },
    grass = nil, --Image{src = "assets/lvls/bg_tiles/grass1.png"},
    beach = nil, --Image{src = "assets/lvls/bg_tiles/beach.png"},
    land  = Group{},
    setup = function( self,o)
        self.image = Clone{source=curr_lvl_imgs.water2}
        self.land:add(
            Clone{source=curr_lvl_imgs.grass},
            Clone{source=curr_lvl_imgs.beach,y=-curr_lvl_imgs.beach.h}
        )
        --self.grass = Clone{source=curr_lvl_imgs.grass}
        --self.beach = Clone{source=curr_lvl_imgs.beach}
        self.img_h = tilesize--self.image.h
        --[[
        self.image:set{
            tile   = {true, true},
            w      = screen_w,
            h      = screen_h+self.img_h,
            y      = -self.img_h
        }
        self.grass:set{
            tile   = {true, true},
            w      = screen_w,
            h      = screen_h+self.img_h,
            y      = -self.img_h
        }
        --]]
        --self.grass.y = -self.img_h
        --self.beach.y = -curr_lvl_imgs.beach.h--self.beach.h-self.img_h
        self.land.y = -self.img_h
        layers.ground:add(self.image,self.land)
        if type(o) == "table"  then
            recurse_and_apply(  self, o  )
        end
    end,
    
    
    render = function( self , seconds )
            
        local dy   = self.speed * seconds
        if self.land.parent ~= nil then
            self.land.y = self.land.y + dy
            if self.land.y > (screen_h+curr_lvl_imgs.beach.h) then
                self.land:unparent()
                self.land.parent = nil
            end
        end
        --[[
        if self.beach.parent ~= nil then
            self.beach.y = self.beach.y + dy
            if self.beach.y > screen_h then
                self.beach:unparent()
                self.beach.parent = nil
            end
        end
        if self.grass.parent ~= nil then
            self.grass.y = self.grass.y + dy
            if self.grass.y > screen_h then
                self.grass:unparent()
                self.grass.parent = nil
            end
        end--]]
        self.image.y = self.image.y + dy
        if self.image.y > 0 then
            self.image.y = self.image.y - self.img_h
        end
        
        
    end, 
    remove = function(self)
        self.image:unparent()
        --[[
        if self.beach.parent ~= nil then
            self.beach:unparent()
        end
        if self.grass.parent ~= nil then
            self.grass:unparent()
        end
        --]]
        if self.land.parent ~= nil then
            self.land:unparent()
        end
    end,
    salvage = function(self)
        s = {
            func = {"salvage_level_4"},
            table_params = {}
        }
        
        table.insert(s.table_params,{
        --[[
            grass ={
                y= self.grass.y
            },
            --]]
            land = {
                y = self.land.y
            }
        })
        
        return s
    end
},
}

function salvage_level_2(o)
    levels[2].num_bosses = o.num_bosses
    lvlbg[2].repeating  = o.repeating
    add_to_render_list(lvlbg[2],o.queues,o.top_doodad)
end
function salvage_level_3(o)
--print("o shit")
    add_to_render_list(lvlbg[3],o.queues,o.top_doodad)
end
function salvage_level_4(o)
dumptable(o)
    add_to_render_list(lvlbg[4],o)
end
