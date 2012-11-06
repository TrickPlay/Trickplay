
local main_menu

local item_spacing = 220
local wrap_i = function(i,list)
    
    return (i - 1) % (# list) + 1
    
end
local create = function(items)
    
    local instance = Group()
    
    local text_items = Group()
    local icon_sources = Group()
    icon_sources:hide()
    instance:add(icon_sources,text_items)
    
    
    --create text elements
    local text = {}
    local icons = {}
    local next_x = 0
    
    --for _,t in ipairs(items) do icon_sources:add(t.icon) end
    
    --if there are not enough items to cover the width of the screen, duplicate the list
    while #text < 4 or (#text-1)*item_spacing < screen_w*3/2 do
        for _,t in ipairs(items) do
            table.insert(icons,
                Clone{
                    source  = t.icon,
                    size = {(items.w or t.icon.w),(items.h or t.icon.h)},
                    anchor_point = {(items.w or t.icon.w)/2,(items.h or t.icon.h)/2},
                    y = -65-(items.h or t.icon.h)/2
                }
            )
            table.insert(text,
                Text{
                    text  = t.label,
                    opacity = 0,
                    font  = STORE_MENU_FONT_FOCUS,
                    color = STORE_MENU_COLOR,
                }
            )
            text[#text].icon = icons[#icons].icon
            text[#text].anchor_point = { text[#text].w/2, text[#text].h/2}
            text_items:add(text[#text],icons[#icons])
            icons[#icons]:hide()
            text[#text]:hide()
        end
    end
    local place_on_the_right = function(right_i,curr_i)
        
        text[curr_i]:show()
        icons[curr_i]:show()
        text[curr_i].x  = text[right_i].x  + item_spacing
        icons[curr_i].x = text[curr_i].x
    end
    local place_on_the_left = function(left_i,curr_i)
        
        text[curr_i]:show()
        icons[curr_i]:show()
        text[curr_i].x  = text[left_i].x  - item_spacing
        icons[curr_i].x = text[curr_i].x
    end
    
    
    local left_i  = 1
    local right_i = 1
    local i = 1
    
    local curr_item
    
    text[1]:show()
    icons[1]:show()
    text[1].x = screen_w/2
    icons[1].x = screen_w/2
    --position from middle to the right
    while text[right_i].x + item_spacing <= screen_w*5/4 do
        curr_item = wrap_i(right_i + 1,text)
        place_on_the_right(right_i,curr_item)
        right_i = curr_item
    end
    --position from middle to the left
    while text[left_i].x - item_spacing >= -screen_w/4 do
        curr_item = wrap_i(left_i - 1,text)
        place_on_the_left(left_i,curr_item)
        left_i = curr_item
    end
    
    local new_icon = function(source,x)
        prev_icon:set{
            source       = curr_icon.source,
            anchor_point = curr_icon.anchor_point,
            position     = curr_icon.position,
            opacity      = 255,
        }
        curr_icon.source = source
        curr_icon.anchor_point = {source.w/2,source.h}
        curr_icon.x = x
        curr_icon.opacity = 0
    end
    local curr_i = 1
    local animating, new_i
    instance.move_left = function()
        if animating then return end
        animating = true
        new_i = wrap_i(curr_i + 1,text)
        text[curr_i]:animate{duration=290,opacity = 0}--.font = STORE_MENU_FONT
        text[new_i]:animate{duration=290,opacity = 255}--.font  = STORE_MENU_FONT_FOCUS
        icons[curr_i]:animate{duration=290,scale = {  1,  1}}
        icons[new_i]:animate{ duration=290,scale = {1.1,1.1}}
        local dx = text[new_i].x - text[curr_i].x
        
        --new_icon(text[new_i].icon,screen_w - 100)
        
        --while text[right_i].x + text[right_i].w/2 <= screen_w+dx do
            --print("adding 1 from the right")
            curr_item = wrap_i(right_i + 1,text)
            if text[curr_item].is_visible then error("woops") end
            place_on_the_right(right_i,curr_item)
            right_i = curr_item
        --end
        --[[
        curr_icon:animate{
            mode = "EASE_OUT_QUAD",
            duration = 300,
            x = screen_w/2,
            opacity      = 255,
        }
        prev_icon:animate{
            mode = "EASE_OUT_QUAD",
            duration = 300,
            x = 100,
            opacity      = 0,
        }
        --]]
        --prev_icon.source:on_key_focus_out()
        --curr_icon.source:on_key_focus_in()
        text_items:animate{
            mode = "EASE_IN_OUT_CUBIC",
            duration = 300,
            x = text_items.x - dx,
            on_completed = function()
                --while text[left_i].x + text[left_i].w/2 < dx do
                    --print("hiding 1 from the left")
                    text[left_i]:hide()
                    icons[left_i]:hide()
                    left_i = wrap_i(left_i + 1,text)
                --end
                text_items.x = text_items.x + dx
                text_items:foreach_child(function(child)
                    if child.is_visible then
                        child.x = child.x - dx
                    end
                end)
                curr_i = new_i
                animating = false
            end
        }
        
        backdrop:cycle_left()
        
    end
    
    instance.move_right = function()
        if animating then return end
        animating = true
        new_i = wrap_i(curr_i - 1,text)
        text[curr_i]:animate{duration=290,opacity = 0}--.font = STORE_MENU_FONT
        text[new_i]:animate{duration=290,opacity = 255}--.font  = STORE_MENU_FONT_FOCUS
        icons[curr_i]:animate{duration=290,scale = {  1,  1}}
        icons[new_i]:animate{ duration=290,scale = {1.1,1.1}}
        local dx = text[curr_i].x - text[new_i].x
        
        --new_icon(text[new_i].icon, 100)
        --print(text[new_i].icon,text[new_i].icon.gid)
        --local item = text[new_i].icon
        
        --while text[left_i].x + text[left_i].w/2 >= -dx do
            --print("adding 1 from the left")
            curr_item = wrap_i(left_i - 1,text)
            if text[curr_item].is_visible then error("woops") end
            place_on_the_left(left_i,curr_item)
            left_i = curr_item
        --end
        --[[
        curr_icon:animate{
            mode = "EASE_OUT_QUAD",
            duration = 300,
            x = screen_w/2,
            opacity      = 255,
        }
        prev_icon:animate{
            mode = "EASE_OUT_QUAD",
            duration = 300,
            x = screen_w - 100,
            opacity      = 0,
        }
        --]]
        --prev_icon.source:on_key_focus_out()
        --print(curr_icon.source,curr_icon.source.gid)
        --curr_icon.source:on_key_focus_in()
        text_items:animate{
            mode = "EASE_IN_OUT_CUBIC",
            duration = 300,
            x = text_items.x + dx,
            on_completed = function()
                --while text[right_i].x - text[right_i].w/2 > screen_w-dx do
                    --print("hiding 1 from the right")
                    text[right_i]:hide()
                    icons[right_i]:hide()
                    right_i = wrap_i(right_i - 1,text)
                --end
                text_items.x = text_items.x - dx
                text_items:foreach_child(function(child)
                    if child.is_visible then
                        child.x = child.x + dx
                    end
                end)
                curr_i = new_i
                animating = false
            end
        }
        
        backdrop:cycle_right()
        
    end
    --.font  = STORE_MENU_FONT_FOCUS
    --text[1].icon:grab_key_focus()
    
    local key_presses = {
        [keys.Right]  = instance.move_left,
        [keys.Left]  = instance.move_right,
        [keys.OK] = items.next_menu,
    }
    
    function instance:on_key_down(k,...)
        return key_presses[k] and key_presses[k]() or icons[curr_i].source.on_key_down and icons[curr_i].source:on_key_down(k,...)
    end
    icons[1].x = screen_w/2
    function instance:on_key_focus_in(self)
        text[curr_i]:animate{duration=290,opacity = 255}
        icons[curr_i]:animate{duration=290,scale = {1.1,1.1}}
    end
    function instance:on_key_focus_out(self)
        text[curr_i]:animate{duration=290,opacity = 0}
        icons[curr_i]:animate{duration=290,scale = {1,1}}
    end
    
    return instance
    
end

return create