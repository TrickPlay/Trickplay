NINESLICE = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

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
local make_canvas = function(self, _ENV, state)
    print(state,"NS CANVAS")
    if type(state) ~= "string" then error("Expected string. Recevied "..type(state),2) end
    local corner_canvas = make_corner(self,state)
    local top_canvas    = make_top(self,state)
    local side_canvas   = make_side(self,state)
    
    corner_canvas:hide()
    side_canvas:hide()
    top_canvas:hide()
    clear(self)
    add( self, corner_canvas,side_canvas,top_canvas)
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
                on_entries_changed = function(instance,_ENV)
                    return nil,nil
                end,
                min_w = function(instance,_ENV)
                    return function(oldf,self) return left_col_w + right_col_w end,
                    function(oldf,self,v) error("Attempt to set 'min_w,' a read-only value",2) end
                end,
                min_h = function(instance,_ENV)
                    return function(oldf,self) return top_row_h + btm_row_h end,
                    function(oldf,self,v) error("Attempt to set 'min_w,' a read-only value",2) end
                end,
                w = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        new_sz = true
                    end
                end,
                width = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        new_sz = true
                    end
                end,
                h = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        new_sz = true
                    end
                end,
                height = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        new_sz = true
                    end
                end,
                size = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v) 
                        oldf(self,v)
                        new_sz = true
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "NineSlice" end
                end,
                cells = function(instance,_ENV)
                    return nil,
                    function(oldf,self,v) 
                        print("setting NS.cells = ",v)
                        mesg("DEBUG",{0,2},"setting cell",v)
                        if type(v) == "table" then
                            state = nil
                            flag_for_redraw = false
                            ns_cells = v
                        elseif type(v) == "nil" then
                            --update can redirect to here, might be problematic
                            --need to pull out old cells setter...
                            state = v
                            local mid_w, mid_h
                            if instance.cells[2][2] then
                                mid_w = instance.cells[2][2].w
                                mid_h = instance.cells[2][2].h
                            end
                            ns_cells = make_canvas(instance,_ENV,"default")
                            if mid_w then
                                set_inner_size( ns_cells,mid_w,mid_h)
                            end
                        else
                            error("Expected table or string. Received "..type(v),2)
                        end
                        oldf(self,ns_cells)
                        find_mins(ns_cells)
                        
                        new_sz = true
                    end
                end,
            },
            functions = {
            },
        },
        private = {
            find_mins = function(instance,_ENV)
                return function(self)
                    left_col_w  = 0
                    right_col_w = 0
                    top_row_h   = 0
                    btm_row_h   = 0
                    
                    for i = 1, 3 do
                        if left_col_w  < ns_cells[i][1].w then left_col_w  = ns_cells[i][1].w end
                        if right_col_w < ns_cells[i][3].w then right_col_w = ns_cells[i][3].w end
                        if top_row_h   < ns_cells[1][i].h then top_row_h   = ns_cells[1][i].h end
                        if btm_row_h   < ns_cells[3][i].h then btm_row_h   = ns_cells[3][i].h end
                    end
                    print("find_mins",left_col_w,right_col_w)
                end
            end,
            set_inner_size = function(instance,_ENV)
                return function(self,w,h)
                    print("set_inner_size",w,h)
                    for i = 1, 3 do  ns_cells[i][2].w = w  end
                    for i = 1, 3 do  ns_cells[2][i].h = h  end
                end
            end,
            update = function(instance,_ENV)
                return function()
                
                    
                    --print("start singleNS update", instance.gid,"sz",instance.w,instance.h)
                    if flag_for_redraw then
                        --print("\t redraw",state)
                        flag_for_redraw = false
                        
                        instance.cells = state
                    end
                    ---[[
                    if  not setting_size and new_sz then
                        print("\t resize, mis:",instance.min_w,instance.min_h)
                        new_sz = false
                        
                        setting_size = true
                        print(instance.w , instance.min_w)
                        set_inner_size( instance.cells,
                             instance.w >= instance.min_w and 
                            (instance.w  - instance.min_w) or 0,
                            
                             instance.h >= instance.min_h and 
                            (instance.h  - instance.min_h) or 0
                        )
                        print(instance.w , instance.min_w)
                        
                        setting_size = false
                    end
                    lm_update()
                    --print("end singleNS update", instance.gid,"sz",instance.w,instance.h)
                    --dumptable(instance.attributes)
                    --]]
                end
            end,
        },
        
        
        declare = function(self,parameters)
            print("SNS LM:declare()")
            local instance, _ENV = LayoutManager:declare{
                number_of_rows = 3,
                number_of_cols = 3,
                placeholder    = Widget_Clone(),
                vertical_spacing   = 0,
                horizontal_spacing = 0,
            }
            print("SNS LM:declare() after",instance.gid)
            
            style_flags = {
                border = "flag_for_redraw",
                fill_colors = "flag_for_redraw"
            }
            
            lm_update = update
            print("declared")
            on_entries_changed = function(self)
                --print(instance.gid,"on_entries_changed1")
                --if setting_size then return end
                --print("on_entries_changed2")
                --setting_size = true
                find_mins(self)
                print("eoc",left_col_w,right_col_w)
                --Call the user's on_entries_changed function
                --on_entries_changed(self)
                --setting_size = false
                new_sz=  true
                --call_update()
            end
            print("NS eoc",on_entries_changed)
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
        
            left_col_w  = 0
            right_col_w = 0
            top_row_h   = 0
            btm_row_h   = 0
            flag_for_redraw = true
            
            for name,f in pairs(self.private) do
                _ENV[name] = f(instance,_ENV)
            end
            
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,_ENV)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,_ENV) )
                
            end
            
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,_ENV))
            end
            
            return instance,_ENV
        end,
    }
)
external.NineSlice = NineSlice