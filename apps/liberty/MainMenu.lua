
local item_spacing = 100
local wrap_i = function(i,list)
    
    return (i - 1) % (# list) + 1
    
end
local create = function(items)
    
    local instance = Group()
    
    local text_items = Group()
    local icon_sources = Group()
    local curr_icon = Clone{name = "curr icon", y = -50}
    local prev_icon = Clone{name = "prev icon", y = -50}
    icon_sources:hide()
    instance:add(icon_sources,text_items,prev_icon, curr_icon)
    
    
    --create text elements
    local text = {}
    local next_x = 0
    
    local total_w = 0
    local largest_w = 0
    for _,t in ipairs(items) do icon_sources:add(t.icon) end
    --if there are not enough items to cover the width of the screen, duplicate the list
    while #text < 4 or total_w - (largest_w+item_spacing)*3 < screen_w do
        print("looping once",total_w , largest_w , screen_w)
        for _,t in ipairs(items) do
            print("a",#text)
            table.insert(text,
                Text{
                    text  = t.label,
                    font  = MAIN_MENU_FONT,
                    color = MAIN_MENU_COLOR,
                }
            )
            total_w   = total_w + text[#text].w+item_spacing
            largest_w = largest_w > text[#text].w and largest_w or text[#text].w
            text[#text].icon = t.icon
            text[#text].anchor_point = { text[#text].w/2, text[#text].h/2}
            text_items:add(text[#text])
            
            text[#text]:hide()
        end
        if largest_w == 0 then  error("bad developer, this will infinite loop")  end
    end
    
    local place_on_the_right = function(right_i,curr_item)
        
        curr_item:show()
        curr_item.x = text[right_i].x + text[right_i].w/2 + item_spacing + curr_item.w/2
    end
    local place_on_the_left = function(left_i,curr_item)
        
        curr_item:show()
        curr_item.x = text[left_i].x - text[left_i].w/2 - item_spacing - curr_item.w/2
    end
    
    
    local left_i  = 1
    local right_i = 1
    local i = 1
    
    local curr_item
    
    text[1]:show()
    text[1].x = screen_w/2
    --position from middle to the right
    print(text[right_i].x + text[right_i].w/2, screen_w)
    while text[right_i].x + text[right_i].w/2 <= screen_w do
        print("r")
        curr_item = wrap_i(right_i + 1,text)
        place_on_the_right(right_i,text[curr_item])
        right_i = curr_item
    end
    --position from middle to the left
    while text[left_i].x - text[left_i].w/2 >= 0 do
        curr_item = wrap_i(left_i - 1,text)
        place_on_the_left(left_i,text[curr_item])
        left_i = curr_item
    end
    
    
    
    --[[
    local first_item = true
    repeat
        
        curr_item = text[i]
        if not first_item then
            next_x = next_x + curr_item.w/2 
        else
            first_item = false
        end
        curr_item:show()
        curr_item.x = next_x
        next_x = next_x + curr_item.w/2 + item_spacing
        print("l",i,curr_item.x)
        i = wrap_i(i + 1,text)
        if i == 1 then
            error("this shouldnt be able to happen")
        end
    until curr_item.x + curr_item.w/2 > screen_w
    right_i = i
    next_x = screen_w/2 - text[1].w/2 - item_spacing
    i = #text
    while next_x > 0 do
        
        curr_item = text[i]
        curr_item:show()
        next_x = next_x - curr_item.w/2
        curr_item.x = next_x
        next_x = next_x - curr_item.w/2 - item_spacing
        print("r",i,curr_item.x)
        i = wrap_i(i - 1,text)
        print(i,right_i)
        if i<right_i then
            error("this shouldnt be able to happen")
        end
    end
    
    left_i = i
    --]]
    
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
        text[curr_i].font = MAIN_MENU_FONT
        text[new_i].font  = MAIN_MENU_FONT_FOCUS
        text[new_i].anchor_point = { text[new_i].w/2, text[new_i].h/2}
        local dx = text[new_i].x - text[curr_i].x
        
        new_icon(text[new_i].icon,screen_w - 100)
        
        while text[right_i].x + text[right_i].w/2 <= screen_w+dx do
            print("adding 1 from the right")
            curr_item = wrap_i(right_i + 1,text)
            if text[curr_item].is_visible then error("woops") end
            place_on_the_right(right_i,text[curr_item])
            right_i = curr_item
        end
        
        curr_icon:animate{
            mode = "EASE_IN_OUT_QUAD",
            duration = 300,
            x = screen_w/2,
            opacity      = 255,
        }
        prev_icon:animate{
            mode = "EASE_IN_OUT_QUAD",
            duration = 300,
            x = 100,
            opacity      = 0,
        }
        prev_icon.source:on_key_focus_out()
        curr_icon.source:on_key_focus_in()
        text_items:animate{
            mode = "EASE_IN_OUT_QUAD",
            duration = 300,
            x = text_items.x - dx,
            on_completed = function()
                while text[left_i].x + text[left_i].w/2 < dx do
                    print("hiding 1 from the left")
                    text[left_i]:hide()
                    left_i = wrap_i(left_i + 1,text)
                end
                text_items.x = text_items.x + dx
                text_items:foreach_child(function(child)
                    if child.is_visible then
                        child.x = child.x - dx
                    end
                end)
                print("old = ",curr_i,text[curr_i].text,"new = ",new_i,text[new_i].text)
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
        text[curr_i].font = MAIN_MENU_FONT
        text[new_i].font  = MAIN_MENU_FONT_FOCUS
        text[new_i].anchor_point = { text[new_i].w/2, text[new_i].h/2}
        local dx = text[curr_i].x - text[new_i].x
        
        new_icon(text[new_i].icon, 100)
        print(text[new_i].icon,text[new_i].icon.gid)
        local item = text[new_i].icon
        
        while text[left_i].x + text[left_i].w/2 >= -dx do
            print("adding 1 from the left")
            curr_item = wrap_i(left_i - 1,text)
            if text[curr_item].is_visible then error("woops") end
            place_on_the_left(left_i,text[curr_item])
            left_i = curr_item
        end
        
        curr_icon:animate{
            mode = "EASE_IN_OUT_QUAD",
            duration = 300,
            x = screen_w/2,
            opacity      = 255,
        }
        prev_icon:animate{
            mode = "EASE_IN_OUT_QUAD",
            duration = 300,
            x = screen_w - 100,
            opacity      = 0,
        }
        prev_icon.source:on_key_focus_out()
        print(curr_icon.source,curr_icon.source.gid)
        curr_icon.source:on_key_focus_in()
        text_items:animate{
            mode = "EASE_IN_OUT_QUAD",
            duration = 300,
            x = text_items.x + dx,
            on_completed = function()
                while text[right_i].x - text[right_i].w/2 > screen_w-dx do
                    print("hiding 1 from the right")
                    text[right_i]:hide()
                    right_i = wrap_i(right_i - 1,text)
                end
                text_items.x = text_items.x - dx
                text_items:foreach_child(function(child)
                    if child.is_visible then
                        child.x = child.x + dx
                    end
                end)
                print("old = ",curr_i,text[curr_i].text,"new = ",new_i,text[new_i].text)
                curr_i = new_i
                animating = false
            end
        }
        
        backdrop:cycle_right()
        
    end
    
    curr_icon.source = text[i].icon
    curr_icon.anchor_point = {text[i].icon.w/2,text[i].icon.h}
    curr_icon.x = screen_w/2
    text[1].font  = MAIN_MENU_FONT_FOCUS
    text[1].anchor_point = { text[1].w/2, text[1].h/2}
    text[1].icon:grab_key_focus()
    
    local key_presses = {
        [keys.Right]  = instance.move_left,
        [keys.Left]  = instance.move_right,
    }
    
    function instance:on_key_down(k,...)
        return key_presses[k] and key_presses[k]()
    end
    
    function instance:on_key_focus_in(self)
        curr_icon:grab_key_focus()
    end
    
    function curr_icon:on_key_down(...) 
        if curr_icon.source.on_key_down then 
            curr_icon.source:on_key_down(...)
        end 
    end
    
    return instance
    
end

local store_icon = make_4movies_icon()
function store_icon:on_key_down(k) 
    if keys.OK == k then
        print("doit")
        main_menu:animate{
            duration = 300,
            z = 300,
            opacity = 0,
        }
        store_menu:grab_key_focus()
    end
end
return create{
    {label = "STORE",      icon = store_icon },
    {label = "MY LIBRARY", icon = make_4movies_icon()},
    {label = "CHANNELS",   icon = Rectangle{w = 100,h = 150,color = {255,0,255}, on_key_focus_in = function() print("in") end,on_key_focus_out = function() print("out") end }},
    {label = "GUIDE",      icon = Image{src = "assets/epg.png", on_key_focus_in = function() print("in") end,on_key_focus_out = function() print("out") end }},
    {label = "TOOLBOX",    icon = make_sub_menu{"Telenet Self Care","Profiles","Settings"}},
    {label = "SEARCH",     icon = make_sub_menu{"History","Advanced","Most Popular","Keyword"}},
}