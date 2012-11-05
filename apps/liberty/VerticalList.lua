
local item_spacing = 85
local wrap_i = function(i,list)
    
    return (i - 1) % (# list) + 1
    
end
local h = 800
local create = function(text)
    
    local instance    = Group{w = screen_w,h = h,clip_to_size = true}
    local inner_group = Group()
    instance:add(inner_group)
    
    local r = Rectangle{h=50,color = "ff0000"}
    
    --create text elements
    local items = {}
    
    --if there are not enough items to cover the width of the screen, duplicate the list
    while #items < 4 or (#items-1)*item_spacing < h do
        for _,t in ipairs(text) do
            table.insert(items, make_bolding_text{text = t,color=RECORDING_MENU_COLOR,sz=RECORDING_MENU_SIZE,duration = 200})
            
            items[#items].anchor_point = { 0, items[#items].h/2}
            inner_group:add(items[#items])
            items[#items]:hide()
        end
    end
    local place_on_the_top = function(top_i,curr_i)
        items[curr_i]:show()
        items[curr_i].y  = items[top_i].y - item_spacing
    end
    local place_on_the_bottom = function(bottom_i,curr_i)
        items[curr_i]:show()
        items[curr_i].y  = items[bottom_i].y + item_spacing
    end
    
    
    local top_i  = 1
    local bottom_i = 1
    local i = 1
    
    local curr_item
    local vis_len = 1
    local middle_i = 1
    
    items[1]:show()
    items[1].y = h/2
    --position from middle to the right
    while items[bottom_i].y + item_spacing + items[1].h/2 <= h do
        
        curr_item = wrap_i(bottom_i + 1,items)
        place_on_the_bottom(bottom_i,curr_item)
        bottom_i = curr_item
        vis_len = vis_len + 1
        
    end
    --position from middle to the left
    while items[top_i].y - item_spacing - items[1].h/2 >= 0 do
        
        curr_item = wrap_i(top_i - 1,items)
        place_on_the_top(top_i,curr_item)
        top_i = curr_item
        vis_len = vis_len + 1
        
        middle_i = middle_i + 1
    end
    
    local curr_i = 1
    local new_i
    
    local o
    local opacity_at = function(i)
        o = (vis_len/2 - math.abs(middle_i - i))*255/(vis_len/2)
        return o > 0 and o or 0
    end
    for i = 1,vis_len do
        ii = items[wrap_i(top_i + i-1,items)]
        ii.opacity = opacity_at(i)
    end
    
    
    local animate_list = Timeline{ duration = 200 }
    on_new_frame__animate_down = function(tl,ms,p)
        inner_group.y =  item_spacing*p
        for i = 1,vis_len+1 do
            ii = items[wrap_i(top_i + i-1,items)]
            ii.opacity = opacity_at(i+p-1)
        end
    end
    on_new_frame__animate_up = function(tl,ms,p)
        inner_group.y = -item_spacing*p
        for i = 1,vis_len+1 do
            ii = items[wrap_i(top_i + i-1,items)]
            ii.opacity = opacity_at(i-p)
        end
    end
    local ii
    on_completed__animate_down = function(tl)
        curr_i = new_i
        items[bottom_i]:hide()
        bottom_i = wrap_i(bottom_i - 1,items)
        inner_group.y = 0
        for i = 1,vis_len do
            ii = items[wrap_i(top_i + i-1,items)]
            ii.y = ii.y + item_spacing
            ii.opacity = opacity_at(i)
        end
    end
    on_completed__animate_up = function(tl)
        curr_i = new_i
        items[top_i]:hide()
        top_i = wrap_i(top_i + 1,items)
        inner_group.y = 0
        for i = 1,vis_len do
            ii = items[wrap_i(top_i + i-1,items)]
            ii.y = ii.y - item_spacing
            ii.opacity = opacity_at(i)
        end
    end
    
    instance.move_up = function()
        if animate_list.is_playing then return end
        
        animate_list.on_new_frame = on_new_frame__animate_up
        animate_list.on_completed = on_completed__animate_up
        
        curr_item = wrap_i(bottom_i + 1,items)
        if items[curr_item].is_visible then error("woops") end
        place_on_the_bottom(bottom_i,curr_item)
        bottom_i = curr_item
        
        new_i = wrap_i(curr_i + 1,items)
        
        items[curr_i].contract:start()
        items[new_i ].expand:start()
        animate_list:start()
        
    end
    
    instance.move_down = function()
        if animate_list.is_playing then return end
        
        animate_list.on_new_frame = on_new_frame__animate_down
        animate_list.on_completed = on_completed__animate_down
        
        curr_item = wrap_i(top_i - 1,items)
        if items[curr_item].is_visible then error("woops") end
        place_on_the_top(top_i,curr_item)
        top_i = curr_item
        
        new_i = wrap_i(curr_i - 1,items)
        
        items[curr_i].contract:start()
        items[new_i ].expand:start()
        animate_list:start()
        
    end
    function instance:on_key_focus_in(self)
        instance:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
    end
    
    items[1].font = RECORDING_MENU_FONT_FOCUS
    
    local animating_back_to_prev_menu = false
    local key_presses = {
        [keys.Up]   = instance.move_up,
        [keys.Down] = instance.move_down,
        [keys.BACK] = function()
            if animating_back_to_prev_menu then return end
            animating_back_to_prev_menu = true
            
            instance:animate{
                duration = 300,
                z = -300,
                opacity = 0,
                on_completed = function() 
                    instance:unparent() 
                    animating_back_to_prev_menu = false 
                end
            }
            my_dvr_menu:grab_key_focus()
            my_dvr_menu:animate{
                duration = 300,
                z = 0,
                opacity = 255,
            }
            
        end,
        [keys.VOL_UP]   = raise_volume,
        [keys.VOL_DOWN] = lower_volume,
    }
    
    function instance:on_key_down(k,...)
        return key_presses[k] and key_presses[k]()
    end
    
    instance.opacity = 0
    return instance
    
end

return create