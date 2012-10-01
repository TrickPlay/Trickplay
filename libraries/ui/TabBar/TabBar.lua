TABBAR = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local top_tabs = function(self,state)
	local c = Canvas(self.w,self.h)
    mesg("TABBAR",0,"TabBar make top_tab",self.gid,state)
	
	c.op = "SOURCE"
	
	c.line_width = self.style.border.width
	
	local r     = self.style.border.corner_radius
    local inset = c.line_width/2
    
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w - (inset+r), inset)
    --top-right corner
    c:arc( c.w - (inset+r), inset+r, r,270,360)
    c:line_to(c.w - inset,c.h + inset)
    --bottom-right corner
    c:line_to( inset, c.h + inset)
    --bottom-left corner
    c:line_to( inset, inset+r)
    
	c:set_source_color( self.style.fill_colors[state] or "00000000" )
	
	c:fill(true)
    
	c:set_source_color( self.style.border.colors[state] or "ffffff" )
	
	c:stroke(true)
	
	return c:Image()
	
end

local side_tabs = function(self,state)
	local c = Canvas(self.w,self.h)
    mesg("TABBAR",0,"TabBar make side_tab",self.gid,state)
	c.op = "SOURCE"
	
	c.line_width = self.style.border.width
	
	local r     = self.style.border.corner_radius
    local inset = c.line_width/2
    
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w + inset, inset)
    --top-right corner
    c:line_to(c.w + inset, c.h - inset)
    --bottom-right corner
    c:line_to( inset+r, c.h - inset)
    --bottom-left corner
    c:arc( inset+r, c.h - (inset+r), r,90,180)
    c:line_to( inset, inset+r)
    
    
	c:set_source_color( self.style.fill_colors[state] or "00000000" )
	
	c:fill(true)
    
	c:set_source_color( self.style.border.colors[state] or "ffffff" )
	
	c:stroke(true)
	
	return c:Image()
	
end

local default_parameters = {tab_w = 200,tab_h = 50,pane_w = 400,pane_h = 300, tab_location = "top"}



-----------------------------------------------------------------------------
-- TabBar's base is a ListManager, this allows for easier alignment when
--         switching the location of the tabs
-- This ListManager contains 2 items: an ArrowPane and a Group
-- The ArrowPane contains a ListManager of ToggleButtons, linked with a 
-- RadioButtonGroup
-----------------------------------------------------------------------------
TabBar = setmetatable(
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
            properties = {
                enabled = function(instance,env)
                    return nil,
                    function(oldf,self,v)  
                        oldf(self,v)
                        for i = 1,env.tabs_lm.length do
                            env.tabs_lm.cells[i].enabled = v
                        end
                        env.tab_pane.enabled = v
                    end
                end,
                pane_w = function(instance,env) -- TODO check need for these upvals
                    return function(oldf) return   env.pane_w     end,
                    function(oldf,self,v)  
                        env.pane_w = v 
                        env.panes_obj.w = v
                        if env.tab_location == "top" then
                            env.tab_pane.pane_w    = env.pane_w
                        end
                    end
                end,
                pane_h = function(instance,env)
                    return function(oldf) return   env.pane_h     end,
                    function(oldf,self,v)   
                        env.pane_h = v 
                        env.panes_obj.h = v
                        if env.tab_location == "left" then
                            env.tab_pane.pane_h    = env.pane_h
                        end
                    end
                end,
                tab_w = function(instance,env)
                    return function(oldf) return   env.tab_w     end,
                    function(oldf,self,v)          
                        env.tab_w = v 
                        env.resize_tabs = true
                    end
                end,
                tab_images = function(instance,env)
                    return function(oldf) return   env.tab_images     end, -- TODO either return clone, or metatable for changes
                    function(oldf,self,v)          
                        local old_images = env.tab_images or {}
                        env.tab_images = v
                        
                        for k,v in pairs(v) do
                            env.add(instance,v)
                            v:hide()
                        end
                        
                        for i = 1,env.tabs_lm.length do
                            
                            local clones = {}
                            
                            for k,v in pairs(v) do
                                clones[k] = Clone{source=v}
                            end
                            
                            env.tabs_lm.cells[i].images = clones
                            
                        end
                        
                        for k,v in pairs(old_images) do
                            v:unparent()
                        end
                    end
                end,
                tab_h = function(instance,env)
                    return function(oldf) return   env.tab_h     end,
                    function(oldf,self,v)          
                        env.tab_h = v 
                        env.resize_tabs = true
                    end
                end,
                widget_type = function(instance,env)
                    return function() return "TabBar" end, nil
                end,
                selected_tab = function(instance,env)
                    return function(oldf) return env.new_selection or env.rbg.selected end,
                    function(oldf,self,v)        env.new_selection = v  end
                end,
                tabs = function(instance,env)
                    return function(oldf)  return   env.tabs_interface      end,
                    function(oldf,self,v)    
                        if type(v) ~= "table" then error("Expected table. Received: ",2) end
                        env.new_tabs = v  
                        env.resize_tabs = true
                    end
                end,
                tab_location = function(instance,env)
                    return function(oldf) return   env.tab_location     end,
                    function(oldf,self,v)  
                        mesg("TABBAR",0,"TabBar.tab_location =",v)
                        if tab_location == v then return end
                        env.new_tab_location = true
                        --[[
                        if v == "top" then
                            env.updating = true --TODO need a better way to do a non-updating set of this
                            instance.direction  = "vertical"
                            env.updating = false
                            env.tabs_lm.direction  = "horizontal"
                            --TODO set??
                            print("oreo\n\n\n\n",env.pane_w,env.tabs_lm.w)
                            env.tab_pane.pane_w    = env.pane_w
                            env.tab_pane.pane_h    = env.tab_h
                            env.tab_pane.virtual_w = env.tabs_lm.w
                            env.tab_pane.virtual_h = env.tab_h
                            env.tab_pane.arrow_move_by   = env.tab_w + env.tabs_lm.spacing
                            for _,tab in env.tabs_lm.cells.pairs() do
                                tab.create_canvas = top_tabs
                                tab.w = 200
                            end
                        elseif v == "left" then
                            env.updating = true --TODO need a better way to do a non-updating set of this
                            instance.direction  = "horizontal"
                            env.updating = false
                            env.tabs_lm.direction  = "vertical"
                            --TODO set??
                            print("env.pane_h = "..env.pane_h)
                            env.tab_pane.pane_w    = env.tab_w
                            env.tab_pane.pane_h    = env.pane_h
                            env.tab_pane.virtual_w = env.tab_w
                            env.tab_pane.virtual_h = env.tabs_lm.h
                            env.tab_pane.arrow_move_by   = env.tab_h + env.tabs_lm.spacing
                            for _,tab in env.tabs_lm.cells.pairs() do
                                tab.create_canvas = side_tabs
                            end
                        else
                            error("Expected 'top' or 'left'. Received "..v,2)
                        end
                        --]]
                        env.tab_location = v
                    end
                end,
    
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.length               = nil
                        t.number_of_cols       = nil
                        t.number_of_rows       = nil
                        t.vertical_alignment   = nil
                        t.horizontal_alignment = nil
                        t.vertical_spacing     = nil
                        t.horizontal_spacing   = nil
                        t.cell_h = nil
                        t.cell_w = nil
                        t.cells  = nil
                        
                        t.style = instance.style
                        
                        t.tab_w  = instance.tab_w
                        t.tab_h  = instance.tab_h
                        t.pane_w = instance.pane_w
                        t.pane_h = instance.pane_h
                        t.tabs   = instance.tabs
                        t.tab_location = instance.tab_location
                        
                        t.tabs = {}
                        
                        for i = 1,env.tabs_lm.length do
                            t.tabs[i]    = {
                                label    = env.tabs_lm.cells[i].label,
                                contents = env.tabs_lm.cells[i].contents.attributes
                            }
                        end
                        
                        t.type = "TabBar"
                        
                        return t
                    end
                end,
                
    
            },
            functions = {
            },
        },  
        
        private = {
        
            update = function(instance,env)
                return function()
                    mesg("TABBAR",{0,5},"TabBar update called")
                    if env.restyle_tabs then
                        env.restyle_tabs = false
                        for i = 1,env.tabs_lm.length do
                                
                            env.tabs_lm.cells[i].style:set(instance.style.attributes)
                            
                        end
                    end
                    if env.restyle_arrows then
                        env.restyle_arrows = false
                        
                        env.tab_pane.style.arrow:set(instance.style.arrow.attributes)
                    end
                    if env.resize_tabs then
                        env.resize_tabs = false
                        if not env.new_tabs then
                            for i = 1,env.tabs_lm.length do
                                
                                env.tabs_lm.cells[i].size = {env.tab_w,env.tab_h}
                                
                            end
                        end
                        if env.tab_location == "top" then
                            
                            env.tab_pane.pane_h        = env.tab_h
                            env.tab_pane.virtual_h     = env.tab_h
                            env.tab_pane.arrow_move_by = env.tab_w + env.tabs_lm.spacing
                        elseif env.tab_location == "left" then
                            env.tab_pane.pane_w        = env.tab_w
                            env.tab_pane.virtual_w     = env.tab_w
                            env.tab_pane.arrow_move_by = env.tab_h + env.tabs_lm.spacing
                        end
                    end
                    if env.new_tabs then
                        mesg("TABBAR",0,"TabBar:update() setting new_tabs")
                        env.tabs_lm.cells = env.new_tabs
                        if env.tab_location == "top" then
                            env.tab_pane.virtual_w = env.tabs_lm.w
                        else
                            env.tab_pane.virtual_h = env.tabs_lm.h
                        end
                        env.new_tabs = false
                    end
                    if env.new_tab_location then
                        env.new_tab_location = false
                        if env.tab_location == "top" then
                            instance.direction  = "vertical"
                            env.tabs_lm.direction  = "horizontal"
                            --TODO set??
                            env.tab_pane.pane_w    = env.pane_w
                            env.tab_pane.pane_h    = env.tab_h
                            env.tab_pane.virtual_w = env.tabs_lm.w
                            env.tab_pane.virtual_h = env.tab_h
                            env.tab_pane.arrow_move_by   = env.tab_w + env.tabs_lm.spacing
                            for _,tab in env.tabs_lm.cells.pairs() do
                                tab.create_canvas = top_tabs
                                tab.w = 200
                            end
                        elseif env.tab_location == "left" then
                            instance.direction  = "horizontal"
                            env.tabs_lm.direction  = "vertical"
                            --TODO set??
                            env.tab_pane.pane_w    = env.tab_w
                            env.tab_pane.pane_h    = env.pane_h
                            env.tab_pane.virtual_w = env.tab_w
                            env.tab_pane.virtual_h = env.tabs_lm.h
                            env.tab_pane.arrow_move_by   = env.tab_h + env.tabs_lm.spacing
                            for _,tab in env.tabs_lm.cells.pairs() do
                                tab.create_canvas = side_tabs
                            end
                        else
                            error("Expected 'top' or 'left'. Received "..v,2)
                        end
                        
                    end
                    
                    env.old_update()
                    print("here")
                    if  env.new_selection then
                        print("DQDQQQDQDDQ")
                        env.rbg.selected = env.new_selection
                        env.new_selection = false
                    end
                    
                    --env.tabs_lm_env:call_update()
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance,env = ListManager:declare{vertical_alignment = "top",spacing=0}
            env.style_flags = {
                border      = "restyle_tabs",
                text        = "restyle_tabs",
                fill_colors = "restyle_tabs",
                arrow       = "restyle_arrows",
            }
            env.panes = {}
            env.tabs = {}
            env.rbg= RadioButtonGroup{name = "TabBar",
                on_selection_change = function()
                    mesg("TABBAR",0,"TabBar.rbg.on_selection_change")
                    for i = 1,env.tabs_lm.length do
                        local t = env.tabs_lm.cells[i]
                        if t.selected then
                            t.contents:show()
                            t:grab_key_focus()
                        else
                            t.contents:hide()
                        end
                    end
                end
            }
            
            env.old_update = env.update
            
            env.panes_obj = Widget_Group{name = "Panes",clip_to_size = true}
            env.pane_w = 400
            env.pane_h = 300
            env.tab_w = 200
            env.tab_h = 50
            env.tab_images   = nil 
            env.tab_style    = nil
            env.tab_location = "top"
            env.resize_tabs = true
            env.new_selection = 1
            
            local function make_tab_interface(tb)
                --prevents the user from getting/setting any of the other fields of the ToggleButtons
                local setter = {
                    label    = function(v) tb.label = v end,
                    contents = function(v) 
                        tb.contents:unparent()
                        tb.contents = v
                        env.panes_obj:add(v)
                        if not tb.selected then v:hide() end
                    end,
                }
                local getter = {
                    label    = function() return tb.label end,
                    contents = function() return tb.contents end,
                }
                return setmetatable({},{
                    __index = function(_,k)
                        return getter[k] and getter[k]()
                    end,
                    __newindex = function(_,k,v)
                        return setter[k] and setter[k](v)
                    end,
                })
            end
            env.tab_to_interface_map = {}
            
            env.tabs_lm = ListManager:declare{
                name = "Tabs ListManager",
                spacing = 0,
                vertical_alignment = "top",
                direction = "horizontal",
                node_constructor = function(obj)
                    
                    
                    
                    mesg("TABBAR",{0,3},"New Tab Button")
                    if obj == nil then 
                        obj = {label = "Tab",contents = Widget_Group()}
                    elseif type(obj) ~= "table" then
                        error("Expected tab entry to be a string. Received "..type(obj),2)
                    elseif type(obj.label) ~= "string" then
                        error("Received a tab without a label",2)
                    end
                    if type(obj.contents) == "table" and obj.contents.type then 
                        
                        obj.contents = _ENV[obj.contents.type](obj.contents)
                        
                    elseif type(obj.contents) ~= "userdata" and obj.contents.__types__.actor then 
                        
                        error("Must be a UIElement or nil. Received "..obj.contents,2) 
                    end
                    local pane = obj.contents
                    
                    local style = instance.style.attributes
                    style.name = style
                    style.border.colors.selection = style.border.colors.selection or "ffffff"
                    local clones
                    if env.tab_images then
                        clones = {}
                        
                        for k,v in pairs(env.tab_images) do
                            clones[k] = Clone{source=v}
                        end
                    end
                    local sel = env.rbg.selected
                    obj = ToggleButton{
                        label  = obj.label,
                        w      = env.tab_w,
                        h      = env.tab_h,
                        style  = style,
                        group  = env.rbg,
                        images = clones,
                        reactive = true,
                        create_canvas = env.tab_location == "top" and top_tabs or side_tabs,
                        --images = tab_images,
                    }
                    obj.contents = pane
                    mesg("TABBAR",0,"button made")
                    ---[[
                    if env.tab_style then
                        obj.style:set(env.tab_style.attributes) -- causes extra redraw
                    end
                    --]]
                    
                    env.tab_to_interface_map[obj] = make_tab_interface(obj)
                    --table.insert(tabs,obj)
                    --obj.pane = pane
                    --table.insert(panes,pane)
                    obj.contents:hide()
                    env.panes_obj:add(obj.contents)
                    obj.contents.w = env.pane_w
                    obj.contents.h = env.pane_h
                    
                    if sel then env.new_selection = sel end
                    return obj
                end
            }
            
            env.tabs_interface = setmetatable({},{
                __index = function(_,k)
                    local v = env.tabs_lm.cells[k]
                    return type(k) == "number" and v and 
                        env.tab_to_interface_map[v] or 
                        v
                end,
                --pass through to the ListManager
                __newindex = function(_,k,v)
                    env.tabs_lm = v
                end,
            })
            
            env.tabs_lm_env = get_env(env.tabs_lm)
            
            --TODO roll into a single set
            env.tab_pane = ArrowPane{name = "ArrowPane",style = false,arrow_move_by = tab_w}
            env.tab_pane.style.arrow.offset = -env.tab_pane.style.arrow.size
            env.tab_pane.style.border.colors.default = "00000000"
            env.tab_pane.style.fill_colors.default   = "00000000"
            env.tab_pane:add(env.tabs_lm)
            
            instance.cells = {env.tab_pane,env.panes_obj}
            
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
            --[[
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)
external.TabBar = TabBar