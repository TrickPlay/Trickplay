
LIST = true

local default_constructor = function(obj,instance)
    if obj == nil then obj = "New Item" end
    if type(obj) ~= "string" then 
        error("Expected 'string' or 'nil'. Received: "..type(obj),2) 
    end
    obj = Text{text=obj}
end
local wrap_i = function(list,i)
    
    return (i - 1) % (# list) + 1
    
end

local default_parameters = {node_constructor=node_constructor}
List = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("MenuButton",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
    ----------------------------------------------------------------------------
	--The List Object inherits from Widget
	
    local instance = Widget()
    
    local node_constructor
    
    
    local items = ListManager{
        node_constructor = function(obj,r,c)
            node_constructor(obj,instance)
            instance:add(obj)
        end,
        node_initializer = function(obj,r,c)
        end,
        node_destructor = function(obj)
            obj:unparent()
        end,
    }
    
    local highlight = Rectangle{}
    
    local bg = Rectangle{}
    
    instance:add(bg,highlight)
    ----------------------------------------------------------------------------
	--The ButtonPicker Object inherits from LayoutManager
	
    local update = Timeline{
        duration = parameters.update_duration,
        on_completed = function()
            
        end
    }
end





local AppList = Group{name = "AppList"}

local item_spacing = 102
local frame_src,launcher_icons
--[[
local make_entry = function(app_id,app_name)
    
    local g = Group{name = app_name}
    
    local i = Clone{x=15}
    
    if launcher_icons[app_id] then
        i.source = launcher_icons[app_id]
    else
        i.source = launcher_icons["generic"]
    end
    
    
    i.w = 48*3.4
    i.h = 27*3.4
    
    i.anchor_point = {0,i.h/2}
    i.y = item_spacing/2
    
    local t   = Text{
        text  = app_name,
        color = "#ffffff",
        font  = "FreeSans Medium 28px",
        x     = i.w + 25,
        ellipsize = "END", w = 340
    }
    
    t.anchor_point = {0,t.h/2}
    
    t.y = i.y
    
    g:add(i,t,Clone{source=frame_src,position=i.position,anchor_point=i.anchor_point,size = i.size})
    
    g.anchor_point = {i.w/2,item_spacing/2}
    
    g.x = i.w/2
    function g:unfocus()
        
        --print("Unfocus "..app_name )
        
        --g:animate{
        --    duration = 100,
        --    scale    = {1,1}
        --}
        
    end
    
    function g:focus()
        
        --print("Focus "..app_name )
        
        
        --g:animate{
        --    duration = 100,
        --    scale    = {1.2,1.2}
        --}
        
    end
    
    g.icon = i
    g.text = t
    g.app_id = app_id
    
    return g
end
--]]
local list = {}


local exiting_item
local wrap_around_clone_ref = Clone{ x=48*3/2, anchor_point = {48*3/2,item_spacing/2}}

local hl_index = 2

local top_vis_i = 1

local vis_len = 5

local clip_table
local hl
--screen:add(hl)
function AppList:init(p)
    
    launcher_icons = p.launcher_icons or error("must pass 'launcher_icons'",2)
    frame_src = p.frame or error("must pass 'frame'",2)
    ---[[
    for k,v in pairs(p.app_list or error("must pass'app_list'",2)) do
        
        if not v.attributes.nolauncher    and
            k ~= "com.trickplay.launcher" and
            k ~= "com.trickplay.empty"    and
            k ~= "com.trickplay.app-shop" and
            k ~= "com.trickplay.editor"   then
            
            --print(k,"\t",v.id,"\t",v.name)
            
            list[ #list + 1 ] = make_entry(v.id,v.name)
            
            if #list <= p.max_vis_len then
                
                list[#list].y = item_spacing*(#list-1)+item_spacing/2
                
                self:add(list[#list])
                
            end
            
            --if #list > 3 then break end
            
        end
        
    end
    --]]
    
    if #list == 0 then
        
        list[ 1 ] = make_entry("com.trickplay.empty","No Apps")
        list[ 2 ] = make_entry("com.trickplay.empty","No Apps")
        list[ 3 ] = make_entry("com.trickplay.empty","No Apps")
        
        list[ 1 ].y = item_spacing*(1-1)+item_spacing/2
        list[ 2 ].y = item_spacing*(2-1)+item_spacing/2
        list[ 3 ].y = item_spacing*(3-1)+item_spacing/2
        
        self:add(list[1],list[2],list[3])
        
    elseif #list == 1 then
        
        list[ 2 ] = make_entry(list[ 1 ].app_id,list[ 1 ].text.text)
        list[ 3 ] = make_entry(list[ 1 ].app_id,list[ 1 ].text.text)
        
        list[ 2 ].y = item_spacing*(2-1)+item_spacing/2
        list[ 3 ].y = item_spacing*(3-1)+item_spacing/2
        
        self:add(list[2],list[3])
        
    elseif #list == 2 then
        
        list[ 3 ] = make_entry(list[ 1 ].app_id,list[ 1 ].text.text)
        list[ 4 ] = make_entry(list[ 2 ].app_id,list[ 2 ].text.text)
        
        list[ 3 ].y = item_spacing*(3-1)+item_spacing/2
        list[ 4 ].y = item_spacing*(4-1)+item_spacing/2
        
        self:add(list[3],list[4])
        
    end
    
    hl = p.slider
    hl.y = item_spacing
    hl:focus(list[hl_index].text.text,list[hl_index].icon,list[hl_index].app_id)
    hl.logical_parent = self
    vis_len = # list < p.max_vis_len and # list or p.max_vis_len
    
    clip_table = { 0,item_spacing/2,400,(vis_len - 1)*item_spacing}
    
    AppList.list_h = (vis_len - 1)*item_spacing
    
    --AppList.clip = clip_table
    
    return self
    
end

local regular_speed = 250
local fast_speed    = 100
local double_time   = false
local again         = false

local animating = false
local list_y = Interval(0,0)
local hl_y   = Interval(0,0)

local on_new_frame_hl_only = function(self,ms,p)
    
    hl.y      =     hl_y:get_value(p)
    
end

local hl_pump
local on_new_frame_all = function(self,ms,p)
    
    clip_table[2] = -list_y:get_value(p)+item_spacing/2
    --print(clip_table[2])
    AppList.y    = list_y:get_value(p) 
    --AppList.clip = clip_table 
    hl.y      = hl_y:get_value(math.cos(math.pi/2*p))
    
end

local move_up, move_dn

local update = Timeline{
    duration = regular_speed,
    on_completed = function(self)
        
        if self.on_new_frame == on_new_frame_all then
        if animating == "UP" then
            
            AppList.y = AppList.y-item_spacing
            
            AppList:foreach_child(function(c)
                c.y = c.y + item_spacing
            end)
            
        elseif  animating == "DOWN" then
            
            AppList.y = AppList.y+item_spacing
            
            AppList:foreach_child(function(c)
                c.y = c.y - item_spacing
            end)
            
        else
            
            error("IMPOSSIBRU!!")
            
        end
        clip_table[2] = item_spacing/2
        --AppList.clip = clip_table 
        end
        
        if exiting_item then
            
            exiting_item:unparent()
            
            --adjust y's of cliped list
            
        end
        
        if again then
            
            if animating == "UP" then
                
                move_up()
                
            elseif  animating == "DOWN" then
                
                move_dn()
                
            else
                
                error("IMPOSSIBRU!!")
                
            end
            
            again = false
            
        else
            self.duration = regular_speed
            double_time = false
            
            animating = false
        end
        
    end,
}

update.alpha = Alpha{
    mode     = "LINEAR",
    timeline = update,
}

local wrap_i = function(i)
    
    return (i - 1) % (# list) + 1
    
end


move_up = function()
    
        
        --list[hl_index]:unfocus()
        
        if hl_index == wrap_i(top_vis_i+1) then
            
            top_vis_i = wrap_i(top_vis_i - 1)
            
            if vis_len == # list then
                
                wrap_around_clone_ref.source = list[top_vis_i]
                
                AppList:add(wrap_around_clone_ref)
                
                wrap_around_clone_ref.y = wrap_around_clone_ref.source.y
                
                exiting_item = wrap_around_clone_ref
                
            else
                
                AppList:add(list[top_vis_i])
                
                exiting_item = list[
                    wrap_i(top_vis_i + vis_len)
                ]
                
            end
            
            list[top_vis_i].y = list[  wrap_i(top_vis_i + 1)  ].y - item_spacing
            
            list_y.from = AppList.y
            list_y.to   = AppList.y + item_spacing
            
            update.on_new_frame = on_new_frame_all
            
            hl_index = wrap_i(hl_index - 1)
            
            hl_y.from = hl.y
            hl_y.to   = hl.y-30
            
        else
            
            update.on_new_frame = on_new_frame_hl_only
            
            hl_index = wrap_i(hl_index - 1)
            
            hl_y.from = hl.y
            hl_y.to   = wrap_i(hl_index - top_vis_i)*item_spacing
            
        end
        
        --list[hl_index]:focus()
        hl:focus(list[hl_index].text.text,list[hl_index].icon,list[hl_index].app_id)
        
        update:start()
    
end

move_dn = function()
    
        
        --list[hl_index]:unfocus()
        
        if hl_index == wrap_i( top_vis_i + vis_len - 2 ) then
            
            top_vis_i = wrap_i(top_vis_i + 1)
            
            if vis_len == # list then
                
                wrap_around_clone_ref.source = list[ wrap_i( top_vis_i + vis_len - 1 ) ]
                
                AppList:add(wrap_around_clone_ref)
                
                wrap_around_clone_ref.y = wrap_around_clone_ref.source.y
                
                exiting_item = wrap_around_clone_ref
                
            else
                --print("yea",wrap_i( top_vis_i + vis_len - 1 ),list[ wrap_i( top_vis_i + vis_len - 1 ) ] )
                gl = list[ wrap_i( top_vis_i + vis_len - 1 ) ]
                dumptable(list)
                AppList:add(list[ wrap_i( top_vis_i + vis_len - 1 ) ])
                --print(top_vis_i,list[ wrap_i(top_vis_i) ].name)
                exiting_item = list[
                    wrap_i(top_vis_i-1)
                ]
                
            end
            
            list[     wrap_i( top_vis_i + vis_len - 1 ) ].y =
                list[ wrap_i( top_vis_i + vis_len - 2 ) ].y + item_spacing
            
            list_y.from = AppList.y
            list_y.to   = AppList.y - item_spacing
            
            update.on_new_frame = on_new_frame_all
            
            hl_index = wrap_i(hl_index + 1)
            
            hl_y.from = hl.y
            hl_y.to   = hl.y+30
            
        else
            
            update.on_new_frame = on_new_frame_hl_only
            
            hl_index = wrap_i(hl_index + 1)
            
            hl_y.from = hl.y
            hl_y.to   = wrap_i(hl_index - top_vis_i)*item_spacing
            
        end
        
        
        --list[hl_index]:focus()
        hl:focus(list[hl_index].text.text,list[hl_index].icon,list[hl_index].app_id)
        print(hl_index,top_vis_i)
        update:start()
end


local key_events = {
    [keys.Up] = function()
        
        if animating == "UP" then
            
            if not double_time then
                
                double_time = true
                
                update:pause()
                local p = update.progress
                update.duration = fast_speed
                
                update:start()
                update:advance(p*fast_speed)
                
            end
            
            again = true
            
            return true
            
        elseif animating == "DOWN" then
            --[[
            --tl.mode = "EASE_IN_BACK"
            if exiting_item then exiting_item = nil end
            update:pause()
            update.duration = regular_speed
            update:advance(0)
            double_time = false
            
            again = false
            --]]
            return true
        end
        
        animating = "UP"
        
        move_up()
        
        return true
    end,
    [keys.Down] = function()
        
        if animating == "DOWN" then
            
            if not double_time then
                
                double_time = true
                
                update:pause()
                local p = update.progress
                update.duration = fast_speed
                
                update:start()
                update:advance(p*fast_speed)
                
            end
            
            again = true
            
            return true
            
        elseif animating == "UP" then
            
            --[[
            if exiting_item then exiting_item = nil end
            update:pause()
            update.duration = regular_speed
            update:advance(0)
            double_time = false
            
            again = false
            --]]
            return true
        end
        
        animating = "DOWN"
        
        move_dn()
        
        return true
        
    end,
    [keys.YELLOW] = function()
        
        if not animating then
            
            hl:show_sub_menu()--selected = true
            --hl:grab_key_focus()
        end
        
        return true
    end,
    [keys.OK] = function()
        
        apps:launch(list[hl_index].app_id)
        
        return true
    end,
}

function AppList:on_key_down(k)
    
    return key_events[k] and key_events[k]()
    
end






return AppList