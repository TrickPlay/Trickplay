local clipped_list = {}

local entry_h, hl

function clipped_list:init(t)
    
    hl      = t.img_srcs.mm_focus
    entry_h = t.entry_h or 48
    
end

local function hl_to_index(i) return entry_h*(i-1)+2 end
function clipped_list:make(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter", 2) end
    
    local x = t.x or error("must pass x",2)
    local y = t.y or error("must pass y",2)
    local w = t.w or error("must pass w",2)
    local h = t.h or error("must pass h",2)
    
    -- upvals
    local vis_range = math.floor(h/entry_h)
    
    local mid_align = (h - vis_range*entry_h)/2
    
    local clip_table = { 0,0,w,h}
    
    ----------------------------------------------------------------------------
    -- The Object                                                             --
    ----------------------------------------------------------------------------
    local list = Group{ name = t.name.." list", x = x, y = y, clip = { 0,0,w,h}}
    
    --visual pieces
    ----------------------------------------------------------------------------
    local hl = Clone{source = hl, opacity = 0}
    
    local no_sessions_text_s = Text{
        text    = t.empty_string or error("must pass empty_string",2),
        alignment = "CENTER",
        font    = g_font.." 30px",
        color   = "000000",
        x       = 10,--w/2,
        wrap    = true,
        w       = w - 20-2,
        y       = 10-2,
    }
    
    local no_sessions_text = Text{
        text    = t.empty_string or error("must pass empty_string",2),
        alignment = "CENTER",
        font    = g_font.." 30px",
        color   = "aaaaaa",
        x       = 10,--w/2,
        wrap    = true,
        w       = w - 20,
        y       = 10,
    }
    --no_sessions_text.anchor_point = {no_sessions_text.w/2,no_sessions_text.h/2}
    list:add(hl,no_sessions_text_s,no_sessions_text)
    
    --attributes
    ----------------------------------------------------------------------------
    local curr_i, top_vis_i, animating
    local list_data = {}
    local q = {}
    
    local focus = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*", target = "UNFOCUSED", duration = 300,
                keys = { {hl, "opacity",   0} }
            },
            {
                source = "*", target = "FOCUSED",  duration = 300,
                keys = { {hl, "opacity", 255} }
            }
        }
    }
    
    function list:set_state(new_state)
        
        if new_state == "FOCUSED" then
            
            if # list_data == 0 then
                print("heeer")
                return false
                
            else
                
                focus.state = "FOCUSED"
                
                list:grab_key_focus()
                
                if not t.on_focus(list_data[curr_i]) then
                    
                    print(curr_i.. "is a bad index")
                    
                end
                
            end
            
        elseif new_state == "UNFOCUSED" then
            
            focus.state = "UNFOCUSED"
            
        else
            print( new_state )
            error("received invalid state",2)
            
        end
        
    end
    
    function list:reset()
        
        for i = #list_data,1,-1 do
            
            list_data[i]:delete()
            print("deleting",i)
            list_data[i] = nil
            
        end
        no_sessions_text.opacity = 255
        no_sessions_text_s.opacity = 255
        curr_i    = 1
        top_vis_i = 1
        hl_to_index(curr_i)
        clip_table[2] = 0
        list.y    = y
        list.clip = clip_table 
        animating = false
        
    end
    ----------------------------------------------------------------------------
    -- List Traversal Animations                                              --
    ----------------------------------------------------------------------------
    
    local clip_y = Interval(0,0)
    local hl_y   = Interval(0,0)
    
    local on_new_frame_hl_only = function(self,ms,p)
        
        hl.y      =     hl_y:get_value(p)
        
    end
    
    local on_new_frame_all = function(self,ms,p)
        
        clip_table[2] = -clip_y:get_value(p)
        --print(clip_table[2])
        list.y    = clip_y:get_value(p) +y
        list.clip = clip_table 
        hl.y      = hl_y:get_value(p)
        
    end
    
    local end_of_animation = function()
        
        animating = false
        
        if # q ~= 0 then
            
            table.remove(q,1)()
            
        end
        
    end
    
    local move_hl = Timeline{
        
        duration = 200,
        
        on_completed = end_of_animation
        
    }
    ----------------------------------------------------------------------------
    -- Method                                                                 --
    ----------------------------------------------------------------------------
    
    
    
    function list:set_up(entries)
        
        list:reset()
        
        list_data = entries
        
        for i = 1, # list_data do
            
            list_data[i].y = entry_h * (i - 1)
            list:add(list_data[i])
        end
        
    end
    
    function list:add_entry(entry,animate)
        
        no_sessions_text.opacity = 0
        no_sessions_text_s.opacity = 0
        
        if app_state.state == "MAIN_PAGE" and top_vis_i <= 2 then
            
            if animating then
                
                q[#q + 1] = function()
                    
                    list:add_entry(entry)
                    
                end
                
                return
                
            end
            animating = true
            dumptable(list.clip)
            --print(list.clip[2] - entry_h)
            
            clip_y.from = list.y-y
            clip_y.to   = list.clip[2] + entry_h
            
            hl_y.from = hl.y
            hl_y.to   = hl.y
            move_hl.on_new_frame = on_new_frame_all
            move_hl.on_completed = function()
                entry.opacity = 0
                
                list:add(entry)
                
                table.insert(list_data,1,entry)
                
                entry:animate{
                    duration = 100,
                    opacity  = 255,
                    on_completed = end_of_animation
                }
                
                list.y    = list.y - entry_h
                --dumptable(list.clip)
                list.clip = { 0,list.clip[2] + entry_h,w,h}
                --dumptable(list.clip)
                
                
                for i = 1, # list_data do
                    
                    list_data[i].y = entry_h * (i - 1)
                    
                end
                
                --curr_i = curr_i + 1
                
                if list_data[curr_i] == nil then curr_i = #list_data end
                
                hl.y =  hl_to_index(curr_i)--list_data[curr_i].y
            end
            move_hl:start()
            
        else
            
            list:add(entry)
            
            table.insert(list_data,1,entry)
            
            for i = 1, # list_data do
                
                list_data[i].y = entry_h * (i - 1)
                --print(i,entry_h)
            end
            
            --[[
            list.y = list.y - entry_h
            
            clip_table[2] = clip_table[2] + entry_h
            list.clip = clip_table
            --]]
            
            
        end
        
    end
    
    
    function list:remove_entry(entry, callback)
        
        print(t.name..":remove_entry")
        local remove_i
        
        for i,e in pairs(list_data) do
            
            if e == entry then
                
                remove_i = i
                
            end
            
        end
        
        if remove_i == nil then
            print("no entry")
            if callback then callback() end
            return
        end
        
        if app_state.state == "MAIN_PAGE" and top_vis_i-1 <= remove_i and top_vis_i+vis_range+1 >= remove_i then
            
            if animating then
                
                q[#q + 1] = function()
                    
                    list:remove_entry(entry)
                    
                end
                
                return
                
            end
            
            animating = true
            
            local tl =Timeline{
                duration = 300,
                on_completed = function()
                    
                    table.remove(list_data,remove_i)
                    
                    entry:unparent()
                    
                    end_of_animation()
                    if #list_data == 0 then
                        no_sessions_text:animate{duration = 100, opacity = 255}
                        no_sessions_text_s:animate{duration = 100, opacity = 255}
                    end
                    curr_i = curr_i - 1
                    if curr_i < 1 then curr_i = 1 end
                    if callback then callback() end
                    
                end
            }
            --if removing the last item
            if remove_i == #list_data then
                
                --if removing the only item
                if focus.state == "FOCUSED" then
                    if remove_i == 1 then
                        
                        list.parent:on_key_down(keys.Right)
                        
                    else
                        
                        tl.on_new_frame = function(self,ms,p)
                            
                            hl.y = hl_to_index(curr_i-p)--entry_h * (curr_i - 1 - p)
                            
                            entry.opacity = 255*(1-p)
                            
                        end
                        
                    end
                else
                    tl.on_new_frame = function(self,ms,p)
                        
                        entry.opacity = 255*(1-p)
                        
                    end
                end
                
            ---------------------------------
            --if the highlight is invisible
            elseif focus.state == "UNFOCUSED" then
                    
                tl.on_new_frame = function(self,ms,p)
                    
                    for i = remove_i + 1, # list_data do
                        
                        list_data[i].y = entry_h * (i - 1 - p)
                        
                    end
                    
                    entry.opacity = 255*(1-p)
                    
                end
            ---------------------------------
            --if the highlight is on the item
            --move towards the center
            elseif remove_i == curr_i then
                
                if curr_i < top_vis_i + vis_range/2 then
                    
                    tl.on_new_frame = function(self,ms,p)
                        
                        for i = remove_i + 1, # list_data do
                            
                            list_data[i].y = entry_h * (i - 1 - p)
                            
                        end
                        
                        entry.opacity = 255*(1-p)
                        
                    end
                    
                else
                    
                    tl.on_new_frame = function(self,ms,p)
                        
                        for i = remove_i + 1, # list_data do
                            
                            list_data[i].y = entry_h * (i - 1 - p)
                            
                        end
                        
                        hl.y = hl_to_index(curr_i-p)--entry_h * (curr_i - 1 - p)
                        
                        entry.opacity = 255*(1-p)
                        
                    end
                    
                end
            -----------------------------------------
            --if not then just hl tracks current item
            else
                
                tl.on_new_frame = function(self,ms,p)
                    
                    for i = remove_i + 1, # list_data do
                        
                        list_data[i].y = entry_h * (i - 1 - p)
                        
                    end
                    
                    --if curr_i > remove_i, then the hl doesn't move
                    hl.y = hl_to_index(curr_i)--list_data[curr_i].y
                    
                    entry.opacity = 255*(1-p)
                    
                end
                
            end
            
            tl:start()
            
            
            
            
            
            
            
            
            
            --[[
            if remove_i == #list_data then
                
                list_data[remove_i] = nil
                
                print("1")
                if remove_i == curr_i then
                    
                    if focus.state == "UNFOCUSED" then
                        
                        hl.y   = list_data[curr_i-1].y
                        
                    else
                        if curr_i == 1 then
                            
                            list.parent:on_key_down(keys.Right)
                            
                        else
                            
                            hl:animate{
                                duration = 150,
                                y        = list_data[curr_i-1].y
                            }
                            
                        end
                    end
                    
                end
                
                curr_i = curr_i - 1
                
                entry:animate{
                    duration     = 200,
                    opacity      = 0,
                    on_completed = function()
                        animating = false
                        
                        entry:unparent()
                        if callback then callback() end
                        
                    end
                }
                
            else
                print("2")
                entry:animate{
                    duration     = 200,
                    opacity      = 0,
                }
                Timeline{
                    duration = 300,
                    on_new_frame = curr_i == remove_i and (
                    
                        curr_i == # list_data and
                        function(tl,ms,p)
                            
                            for i = remove_i + 1, # list_data do
                                
                                list_data[i].y = entry_h * (i - 1 - p)
                                
                            end
                            
                            hl.y = entry_h * (remove_i - 1 + p)
                            
                        end or
                        function(tl,ms,p)
                            
                            for i = remove_i + 1, # list_data do
                                
                                list_data[i].y = entry_h * (i - 1 - p)
                                
                            end
                            
                            hl.y = entry_h * (remove_i - 1 - p)
                            
                        end
                    ) or
                    
                    function(tl,ms,p)
                        
                        for i = remove_i + 1, # list_data do
                            
                            list_data[i].y = entry_h * (i - 1 - p)
                            
                        end
                        
                    end,
                    on_completed = function()
                        
                        table.remove(list_data,remove_i)
                        
                        entry:unparent()
                        
                        end_of_animation()
                        if #list_data == 0 then
                            no_sessions_text:animate{duration = 100, opacity = 255}
                        end
                        curr_i = curr_i - 1
                        if callback then callback() end
                        
                    end
                }:start()
                
            end
            --]]
            
        else
            print(3)
            table.remove(list_data,remove_i)
            
            for i = remove_i, # list_data do
                
                list_data[i].y = entry_h * (i - 1)
                
            end
            
            entry:unparent()
            curr_i = curr_i - 1
            if curr_i < 1 then curr_i = 1 end
            hl.y = list_data[curr_i] ~= nil and hl_to_index(curr_i)--[[list_data[curr_i].y]] or  1
            if remove_i < curr_i then
                
                list.y = list.y + entry_h
                
                clip_table[2] = clip_table[2] - entry_h
                list.clip = clip_table
                
                top_vis_i = top_vis_i - 1
                
            end
            if #list_data == 0 then
                no_sessions_text.opacity = 255
                no_sessions_text_s.opacity = 255
            end
            
            if callback then callback() end
            
        end
        
    end
    
    
    
    
    
    ----------------------------------------------------------------------------
    -- Key Events                                                             --
    ----------------------------------------------------------------------------
    
    
    local key_events = {
        [keys.Up] = function()
            
            if curr_i <= 1 or animating then return end
            
            animating = true
            move_hl.on_completed = function() animating = false end
            
            
            if top_vis_i == curr_i then
                
                top_vis_i = top_vis_i - 1
                
                move_hl.on_new_frame = on_new_frame_all
                
                clip_y.from = list.y-y
                clip_y.to   = -entry_h*(top_vis_i-1)--clip.y + entry_h
                
                if top_vis_i == 1 then
                elseif (top_vis_i + vis_range - 1) == # list_data then
                    
                    clip_y.to = clip_y.to + mid_align*2
                else
                    
                    clip_y.to = clip_y.to + mid_align
                end
                
            else
                
                move_hl.on_new_frame = on_new_frame_hl_only
                
            end
            
            curr_i = curr_i - 1
            
            hl_y.from = hl.y
            hl_y.to   = hl_to_index(curr_i)--entry_h*(curr_i-1)+2
            
            move_hl:start()
            t.on_focus(list_data[curr_i])
        end,
        [keys.Down] = function()
            
            if curr_i >= # list_data or animating then return end
            
            animating = true
            move_hl.on_completed = function() animating = false end
            
            
            if top_vis_i+vis_range - 1 == curr_i then
                
                top_vis_i = top_vis_i + 1
                
                move_hl.on_new_frame = on_new_frame_all
                
                clip_y.from = list.y-y
                clip_y.to   = -entry_h*(top_vis_i-1)-10--clip.y - entry_h
                
                if top_vis_i == 1 then
                elseif (top_vis_i + vis_range - 1) == # list_data then
                    
                    clip_y.to = clip_y.to + mid_align*2
                else
                    
                    clip_y.to = clip_y.to + mid_align
                end
                
                
            else
                
                move_hl.on_new_frame = on_new_frame_hl_only
                
            end
            
            curr_i = curr_i +1
            
            hl_y.from = hl.y
            hl_y.to   = hl_to_index(curr_i)--entry_h*(curr_i-1)+2
            
            move_hl:start()
            t.on_focus(list_data[curr_i])
            
        end,
        [keys.OK] = function()
            
            list_data[curr_i]:select()
            
        end,
        
    }
    function list:on_key_down(k)
        
        if key_events[k] then key_events[k]() end
        
    end
    
    list:reset()
    
    return list
    
end

return clipped_list