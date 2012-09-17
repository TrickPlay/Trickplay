NINESLICE = true

--make_canvas

local make_corner = function(self,state)
    local r = self.style.border.corner_radius
    local inset = self.style.border.width/2
    
    if r == 0 then 
        return Rectangle{w = inset*2,h = inset*2,color = self.style.border.colors[state]}
    end
    
    
    local c = Canvas(r,r)
    c.line_width = inset*2
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    -- wrap back around out of the visible bounds
    c:line_to(r+inset,  inset)
    c:line_to(r+inset,r+inset)
    c:line_to(  inset,r+inset)
    
    c:set_source_color( self.style.fill_colors[state] )     
    c:fill(true)
    
    c:set_source_color( self.style.border.colors[state] )   
    c:stroke(true)
    
    return c:Image()
end

local make_top = function(self,state)
    
    local r = self.style.border.corner_radius
    local inset = self.style.border.width/2
    if r == 0 then 
        return Rectangle{w = 1,h = inset*2,color = self.style.border.colors[state]}
    end
    local c = Canvas(1,r)
    c.line_width = inset*2
    c:move_to( -inset*2,  inset)
    c:line_to(  inset*2,  inset)
    c:line_to(  inset*2,r+inset*2)
    c:line_to( -inset*2,r+inset*2)
    c:line_to( -inset*2,  inset)
    
    c:set_source_color( self.style.fill_colors[state] )     
    c:fill(true)
    
    c:set_source_color( self.style.border.colors[state] )   
    c:stroke(true)
    
    return c:Image()
end
local make_side = function(self,state)
    
    local r = self.style.border.corner_radius
    local inset = self.style.border.width/2
    if r == 0 then 
        return Rectangle{w = inset*2,h = 1,color = self.style.border.colors[state]}
    end
    local c = Canvas(r,1)
    c.line_width = inset*2
    c:move_to(  inset, -inset*2)
    c:line_to(  inset,  inset*2)
    c:line_to(r+inset*2,  inset*2)
    c:line_to(r+inset*2, -inset*2)
    c:line_to(   inset,-inset*2)
    
    c:set_source_color( self.style.fill_colors[state] )     
    c:fill(true)
    
    c:set_source_color( self.style.border.colors[state] )   
    c:stroke(true)
    
    return c:Image()
end
local make_canvas = function(self, env, state)
    print(state,"NS CANVAS")
    if type(state) ~= "string" then error("Expected string. Recevied "..type(state),2) end
    local corner_canvas = make_corner(self,state)
    local top_canvas    = make_top(self,state)
    local side_canvas   = make_side(self,state)
    
    corner_canvas:hide()
    side_canvas:hide()
    top_canvas:hide()
    env.clear(self)
    env.add( self, corner_canvas,side_canvas,top_canvas)
    return {
        {
            Widget_Clone{source = corner_canvas},
            Widget_Clone{source =   top_canvas},
            Widget_Clone{source = corner_canvas,z_rotation = {90,0,0}},
        },
        {
            Widget_Clone{source =   side_canvas},
            Widget_Rectangle{color = self.style.fill_colors[state] },
            Widget_Clone{source =   side_canvas,z_rotation = {180,0,0}},
        },
        {
            Widget_Clone{source = corner_canvas,z_rotation = {270,0,0}},
            Widget_Clone{source =   top_canvas, z_rotation = {180,0,0}},
            Widget_Clone{source = corner_canvas,z_rotation = {180,0,0}},
        },
    }
end
local default_parameters = {}

--SingleNineSlice
NineSlice = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            self = self:declare()
            print("post-declare, pre-set")
            
            self:set(p or {})
            
            print("post-set, pre-return")
            return self
            
        end,
        subscriptions = {
        },
        public = {
            properties = {
                on_entries_changed = function(instance,env)
                    return nil,nil
                end,
                min_w = function(instance,env)
                    return function(oldf,self) return env.left_col_w + env.right_col_w end,
                    function(oldf,self,v) error("Attempt to set 'min_w,' a read-only value",2) end
                end,
                min_h = function(instance,env)
                    return function(oldf,self) return env.top_row_h + env.btm_row_h end,
                    function(oldf,self,v) error("Attempt to set 'min_w,' a read-only value",2) end
                end,
                w = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                width = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                h = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                height = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                size = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                cells = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        print("setting NS.cells = ",v)
                        mesg("DEBUG",{0,2},"setting cell",v)
                        if type(v) == "table" then
                            env.state = nil
                            env.flag_for_redraw = false
                            oldf(self,v)
                        elseif type(v) == "nil" then
                            --update can redirect to here, might be problematic
                            --need to pull out old cells setter...
                            env.state = v
                            oldf(self,make_canvas(instance,env,"default"))
                        else
                            error("Expected table or string. Received "..type(v),2)
                        end
                        env.new_sz = true
                    end
                end,
            },
            functions = {
            },
        },
        private = {
            set_inner_size = function(instance,env)
                return function(self,w,h)
                    print("set_inner_size",w,h)
                    for i = 1, 3 do  self[i][2].w = w  end
                    for i = 1, 3 do  self[2][i].h = h  end
                end
            end,
            update = function(instance,env)
                return function()
                
                    
                    print("start singleNS update", instance.gid,"sz",instance.w,instance.h)
                    if env.flag_for_redraw then
                        print("\t redraw",env.state)
                        env.flag_for_redraw = false
                        instance.cells = env.state
                        
                    end
                    ---[[
                    if  not env.setting_size and env.new_sz then
                        print("\t resize, mis:",instance.min_w,instance.min_h)
                        env.new_sz = false
                        
                        env.setting_size = true
                        --print(instance.w , instance.min_w)
                        env.set_inner_size( instance.cells,
                             instance.w >= instance.min_w and 
                            (instance.w  - instance.min_w) or 0,
                            
                             instance.h >= instance.min_h and 
                            (instance.h  - instance.min_h) or 0
                        )
                        
                        env.setting_size = false
                    end
                    env.lm_update()
                    print("end singleNS update", instance.gid,"sz",instance.w,instance.h)
                    --dumptable(instance.attributes)
                    --]]
                end
            end,
        },
        
        
        declare = function(self,parameters)
            print("SNS LM:declare()")
            local instance, env = LayoutManager:declare{
                number_of_rows = 3,
                number_of_cols = 3,
                vertical_spacing   = 0,
                horizontal_spacing = 0,
            }
            print("SNS LM:declare() after",instance.gid)
            
            env.style_flags = {
                border = "flag_for_redraw",
                fill_colors = "flag_for_redraw"
            }
            
            env.lm_update = env.update
            print("declared")
            instance.on_entries_changed = function(self)
                print(instance.gid,"on_entries_changed1")
                --if env.setting_size then return end
                print("on_entries_changed2")
                --env.setting_size = true
                env.left_col_w  = 0
                env.right_col_w = 0
                env.top_row_h   = 0
                env.btm_row_h   = 0
                
                for i = 1, 3 do
                    if env.left_col_w  < self[i][1].w then env.left_col_w  = self[i][1].w end
                    if env.right_col_w < self[i][3].w then env.right_col_w = self[i][3].w end
                    if env.top_row_h   < self[1][i].h then env.top_row_h   = self[1][i].h end
                    if env.btm_row_h   < self[3][i].h then env.btm_row_h   = self[3][i].h end
                end
                
                --Call the user's on_entries_changed function
                --on_entries_changed(self)
                --setting_size = false
                env.new_sz=  true
                --env.call_update()
            end
            --[[
            do
                local mt = getmetatable(instance.cells)
                
                mt.functions.insert       = function() end
                mt.functions.remove       = function() end
                mt.setters.size           = function() end
                mt.setters.number_of_rows = function() end
                mt.setters.number_of_cols = function() end
            end
            --]]
            
            local getter, setter
        
            env.left_col_w  = 0
            env.right_col_w = 0
            env.top_row_h   = 0
            env.btm_row_h   = 0
            env.flag_for_redraw = true
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            
            return instance,env
        end,
    }
)

MultiNineSlice = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            return self:declare():set(p or {})
            
        end,
        subscriptions = {
        },
        public = {
            properties = {--[[
                style = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        
                        env.subscribe_to_sub_styles()
                        
                        env.flag_for_redraw = true 
                    end
                end,
                --]]
                w = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                width = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                h = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        print("set h")
                        env.new_sz = true
                    end
                end,
                height = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                size = function(instance,env)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        env.new_sz = true
                    end
                end,
                cells = function(instance,env)
                    return function(oldf,self) return env.states end,
                    function(oldf,self,v) 
                        --clear out the existing 9slices
                        print("NS CELLS")
                        for state,cells in pairs(env.states) do
                            cells:unparent()
                            rawset(env.states,state,nil)
                        end
                        env.canvas = false
                        --if passed nil, this will trigger canvases
                        if v == nil then 
                            
                            env.flag_for_redraw = true
                            env.canvas = true
                        elseif type(v) == "table" then
                            if v.default then
                                for state,cells in pairs(v) do
                                    env.states[state] = cells
                                end
                            elseif v[1] and v[2] and v[3] then
                                env.states.default = v
                            else
                                error("Expected a 3x3 table, or a table of 3x3 tables (Default is required)",2)
                            end
                        else
                            error("Expected table or nil. Received "..type(v),2)
                        end
                        
                        instance.state = env.curr_state
                    end
                end,
                state = function(instance,env)
                    return function(oldf,self) return env.curr_state end,
                    function(oldf,self,v) 
                        for state,cells in pairs(env.states) do
                            if cells.state then
                                if state == v then
                                    cells.state.state = "ON"
                                else
                                    cells.state.state = "OFF"
                                end
                            end
                        end
                        env.curr_state = v
                    end
                end,
            },
            functions = {
            },
        },
        private = {--[[
            subscribe_to_sub_styles = function(instance,env)
                return function()
                    instance.style.border:subscribe_to( nil, function()
                        if env.canvas then 
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                    instance.style.fill_colors:subscribe_to( nil, function()
                        if env.canvas then 
                            print("do it",env.updating)
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                    instance.style:subscribe_to(  nil,  function()
                        if env.canvas then 
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                end
            end,
            --]]
            define_obj_animation = function(instance,env)
                return function(obj)
                    
                    obj.state = AnimationState{
                        duration    = 100,
                        transitions = {
                            {
                                source = "*", target = "OFF",
                                keys   = {  {obj, "opacity",  0},  },
                            },
                            {
                                source = "*", target = "ON",
                                keys   = {  {obj, "opacity",255},  },
                            },
                        }
                    }
                    
                end
            end,
            update = function(instance,env)
                return function()
                    print("============================================================")
                    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    print("NS update start",instance.w,instance.h)
                    if env.flag_for_redraw and env.canvas then
                        print("NS redraw")
                        env.flag_for_redraw = false
                        print("one")
                        env.clear(instance)
                        env.states.default    = nil
                    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                        env.states.focus      = nil
                    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                        env.states.activation = nil
                    end
                    
                    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    if  not env.setting_size and env.new_sz then
                        print("NS resize")
                        env.new_sz = false
                        
                        env.setting_size = true
                        
                        for state, obj in pairs(env.states) do
                            obj.size = instance.size
                        end
                        env.setting_size = false
                    end
                    print("NS update end",instance.w,instance.h)
                    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    print("============================================================")
                    
                end
            end,
        },
        
        
        declare = function(self,parameters)
            
            parameters = parameters or {}
            local instance, env = Widget()
            
            env.style_flags = {
                border = "flag_for_redraw",
                fill_colors = "flag_for_redraw"
            }
            
            env.left_col_w  = 0
            env.right_col_w = 0
            env.top_row_h   = 0
            env.btm_row_h   = 0
            
            env.states = {}
            env.canvas = true
            env.flag_for_redraw = true
            env.states_mt = {
                __newindex = function(t,k,v)
                    print("here",v)
                    --remove the existing 9slice
                    if t[k] then t[k]:unparent() end
                    
                    --make the new one (if v == nil then a canvas one is made)
                    if env.canvas == false or v == nil then
                        print("SingleNineSlice",v,k)
                        
                        v = SingleNineSlice{ 
                            name = k, 
                            cells = v or k 
                        }--make_single_nine_slice(v,k)
                        
                        v.size = instance.size
                        
                        env.add( instance, v)
                        
                            print("w")
                        if k ~= "default" then
                            
                            env.define_obj_animation(v)
                            v.state:warp("OFF")
                        end
                        print("h")
                        rawset(t,k, v )
                    end
                    
                end
            }
            
            setmetatable(env.states,env.states_mt)
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            
            env.updating = true
            instance.cells = parameters.cells
            parameters.cells = nil
            env.updating = false
            
            
            --env.subscribe_to_sub_styles()
            
            return instance, env
        end,
    }
)








