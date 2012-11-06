
local item_spacing = 200
local wrap_i = function(i,list)
    
    return (i - 1) % (# list) + 1
    
end
local h = screen_h
local create = function(text)
    
    local instance    = Group{}
    local inner_group = Group()
    instance:add(inner_group)
    
    local sel_scale = 1.7
    --create text elements
    local items = {}
    local curr_i = 1
    local new_i
    
    instance.is_ready = false
    
    local top_i  = 1
    local bottom_i = 1
    local i = 1
    
    local curr_item
    local vis_len = 1
    local middle_i = 1
    local place_on_the_top
    local place_on_the_bottom
    function instance:populate(t)
    --if there are not enough items to cover the width of the screen, duplicate the list
    while #items < 4 or (#items-1)*item_spacing < screen_h do
        for _,t in ipairs(t) do
            table.insert(items,  clone_proxy(t.Name)  )
            items[#items].orig_w = items[#items].w
            --items[#items].anchor_point = { items[#items].w/2, items[#items].h/2}
            inner_group:add(items[#items])
            items[#items]:hide()
        end
    end
    place_on_the_top = function(top_i,curr_i)
        items[curr_i]:show()
        items[curr_i].y  = items[top_i].y - item_spacing
    end
    place_on_the_bottom = function(bottom_i,curr_i)
        items[curr_i]:show()
        items[curr_i].y  = items[bottom_i].y + item_spacing
    end
    
    
    
    items[1]:show()
    items[1].y = h/2
    --position from middle to the right
    while items[bottom_i].y + item_spacing + items[bottom_i].h/2 <= h do
        
        curr_item = wrap_i(bottom_i + 1,items)
        place_on_the_bottom(bottom_i,curr_item)
        bottom_i = curr_item
        vis_len = vis_len + 1
        
    end
    --position from middle to the left
    while items[top_i].y - item_spacing - items[top_i].h/2 >= 0 do
        
        curr_item = wrap_i(top_i - 1,items)
        place_on_the_top(top_i,curr_item)
        top_i = curr_item
        vis_len = vis_len + 1
        
        middle_i = middle_i + 1
    end
    
    instance.is_ready = true
    items[curr_i ].scale = {sel_scale,sel_scale}
    
    end
    instance.move_up = function()
        if #items == 0 or inner_group.is_playing then return end
        
        curr_item = wrap_i(top_i - 1,items)
        if items[curr_item].is_visible then error("woops") end
        place_on_the_top(top_i,curr_item)
        top_i = curr_item
        
        new_i = wrap_i(curr_i - 1,items)
        
        inner_group:animate{
            duration = 300,
            y = inner_group.y+ item_spacing,
            on_completed = function()
                items[bottom_i]:hide()
                bottom_i = wrap_i(bottom_i - 1,items)
                inner_group.y = 0
                for i = 1,vis_len do
                    ii = items[wrap_i(top_i + i-1,items)]
                    ii.y = ii.y + item_spacing
                end
                curr_i = new_i
            end
        }
        items[curr_i ]:animate{
            duration = 300,
            scale = {1,1},
        }
        items[new_i ]:animate{
            duration = 300,
            scale = {sel_scale,sel_scale},
        }
        
    end
    
    instance.move_down = function()
        if #items == 0 or inner_group.is_playing then return end
        
        curr_item = wrap_i(bottom_i + 1,items)
        if items[curr_item].is_visible then error("woops") end
        place_on_the_bottom(bottom_i,curr_item)
        bottom_i = curr_item
        
        new_i = wrap_i(curr_i + 1,items)
        
        inner_group:animate{
            duration = 300,
            y = inner_group.y- item_spacing,
            on_completed = function()
                items[top_i]:hide()
                top_i = wrap_i(top_i + 1,items)
                inner_group.y = 0
                for i = 1,vis_len do
                    ii = items[wrap_i(top_i + i-1,items)]
                    ii.y = ii.y - item_spacing
                end
                curr_i = new_i
            end
        }
        items[curr_i ]:animate{
            duration = 300,
            scale = {1,1},
        }
        items[new_i ]:animate{
            duration = 300,
            scale = {sel_scale,sel_scale},
        }
        
    end
    function instance:on_key_focus_in(self)
        instance:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
    end
    
    local animating_back_to_prev_menu = false
    local key_presses
    key_presses = {
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
            currently_playing_content:grab_key_focus()
            backdrop:set_horizon(700)
            backdrop:set_bulb_x(screen_w/2)
            backdrop:anim_x_rot(90)
        end,
    }
    
    function instance:on_key_down(k,...)
        return key_presses[k] and key_presses[k]()
    end
    --[[
    function curr_icon:on_key_down(...) 
        if curr_icon.source.on_key_down then 
            curr_icon.source:on_key_down(...)
        end 
    end
    --]]
    instance.opacity = 0
    instance.z  = - 300
    return instance
    
end

return create