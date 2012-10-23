local make_row = function()
    local bg = Clone{
        source = screen:find_child("epg_row_bg"),
        scale  = 1080/720,
    }
    local icon = Rectangle{ w = 50, h=50, x = -120}
    local instance = Group{
        children = {
            bg,icon
        }
    }
    instance.bg   = bg
    instance.icon = icon
    
    return instance
end
local wrap_i = function(i,list)
    
    return (i - 1) % (# list) + 1
    
end

--------------------------------------------------------------------
local instance = Group()

local channel_list = {}

local margin = 425
local heading_h = 285
local heading_txt_y = 65
--------------------------------------------------------------------
local top_left = Group{
    name = "top-left date/time",
    y = heading_txt_y,
}
local curr_time = Text{
    x    = 50,
    text = "12:14",
    font = "InterstateProRegular 40px",
    color = "white",
}
local curr_day = Text{
    x    = margin + 10,
    text = "MON 22 SEP",
    font = "InterstateProRegular 40px",
    color = "white",
}
top_left:add(
    curr_time,
    Rectangle{
        x = margin - 5,
        w = 5,
        h = heading_h - heading_txt_y - 15,
        color = "white",
    },
    curr_day
)
--------------------------------------------------------------------
local timeline_header = Group{
    name = "timeline header",
    x = margin,
}
local timeline_bg = Rectangle{
    w=screen_w,
    x=-margin,
    h = heading_h,
    color = "black",
}
local intervals = Image{
    src = "assets/epg/timeline-interval.png",
    tile = {true,false},
    y = 195,
    w = (screen_w-margin)*720/1080,
    scale = 1080/720,
}
timeline_header:add(timeline_bg,intervals)
--------------------------------------------------------------------

local curr_channel = 1

local top_i = curr_channel
local bottom_i = curr_channel

local show_grid = Group{
    name = "show grid",
    x = margin,
    y = heading_h,
}
local row_h = 70*1080/720
local rows = {}
-- -1 because its looking at the next one to be added,
-- -2 more for wrap-around

local middle_row = 5
while (#rows-3)*row_h + margin < screen_h do
    table.insert(rows,make_row():set{y=(#rows-1)*row_h})
    if #rows > middle_row then rows[#rows].y = rows[#rows].y + row_h end
    if #rows == middle_row then rows[middle_row].bg.scale = {1,2*1080/720} end
    rows[#rows].icon.y = rows[#rows].bg.h/2 * rows[#rows].bg.scale[2]
end
show_grid:add(unpack(rows))
--------------------------------------------------------------------
function instance:setup_icons(t)
    ---[[
    --TODO setup wrap around stuff here
    for i,channel in ipairs(t) do
        channel_list[i] = clone_proxy(channel.Name)
    end
    
    top_i    = wrap_i(curr_channel-middle_row,        channel_list)
    bottom_i = wrap_i(curr_channel+(#rows+middle_row),channel_list)
    
    for i = 1,#rows do
        rows[i].icon:unparent()
        rows[i].icon = channel_list[
            
            wrap_i(curr_channel+i-middle_row,channel_list)
            
        ]:set{y=rows[i].icon.y,x=rows[i].icon.x}
        rows[i]:add(rows[i].icon)
    end
    --]]
end
function instance:load_schedule(t)
    
end

--------------------------------------------------------------------
local animating_back_to_prev_menu = false
local keypresses = {
    [keys.Up] = function()
        if #channel_list == 0 or show_grid.is_animating then return end
        show_grid:animate{
            duration = 200,
            y = heading_h+row_h,
            on_completed = function()
                show_grid.y = heading_h
                --consolidated all the other on_completed's
                if rows[middle_row-1].bg.is_animating   then rows[middle_row-1].bg:stop_animation()   end
                if rows[middle_row-1].icon.is_animating then rows[middle_row-1].icon:stop_animation() end
                if rows[middle_row].is_animating        then rows[middle_row]:stop_animation()        end
                if rows[middle_row].bg.is_animating     then rows[middle_row].bg:stop_animation()     end
                if rows[middle_row].icon.is_animating   then rows[middle_row].icon:stop_animation()   end
                
                for i = 1,#rows do
                    rows[i].icon:unparent()
                end
                for i = #rows,2,-1 do
                    rows[i].icon = rows[i-1].icon
                    rows[i]:add(rows[i-1].icon)
                end
                
                rows[middle_row-1].bg.scale = {1,1080/720}
                rows[middle_row-1].icon.y   = row_h/2
                rows[middle_row].y          = (middle_row-2)*row_h
                rows[middle_row].bg.scale   = {1,2*1080/720}
                rows[middle_row].icon.y     = row_h
                
                top_i        = wrap_i(top_i-1,        channel_list)
                curr_channel = wrap_i(curr_channel-1, channel_list)
                bottom_i     = wrap_i(bottom_i-1,     channel_list)
                
                
                local top_x = rows[1].icon.x
                local top_y = rows[1].icon.y
                rows[1].icon = channel_list[top_i]
                rows[1].icon.x = top_x
                rows[1].icon.y = top_y
                rows[1]:add(rows[1].icon)
            end
        }
        --expand the next column
        rows[middle_row-1].bg:animate{   duration = 200, scale = {1,2*1080/720}, }
        rows[middle_row-1].icon:animate{ duration = 200, y = row_h, }
        --contract the previously selected column
        rows[middle_row]:animate{      duration = 200, y = (middle_row-1)*row_h, }
        rows[middle_row].bg:animate{   duration = 200, scale = {1,1080/720}, }
        rows[middle_row].icon:animate{ duration = 200, y = row_h/2, }
    end,
    [keys.Down] = function()
        if #channel_list == 0 or show_grid.is_animating then return end
        show_grid:animate{
            duration = 200,
            y = heading_h-row_h,
            on_completed = function()
                show_grid.y = heading_h
                --consolidated all the other on_completed's
                if rows[middle_row].bg.is_animating     then rows[middle_row].bg:stop_animation()     end
                if rows[middle_row].icon.is_animating   then rows[middle_row].icon:stop_animation()   end
                if rows[middle_row+1].is_animating      then rows[middle_row+1]:stop_animation()      end
                if rows[middle_row+1].bg.is_animating   then rows[middle_row+1].bg:stop_animation()   end
                if rows[middle_row+1].icon.is_animating then rows[middle_row+1].icon:stop_animation() end
                
                
                for i = 1,#rows do
                    rows[i].icon:unparent()
                end
                for i = 1,#rows-1 do
                    rows[i].icon = rows[i+1].icon
                    rows[i]:add(rows[i+1].icon)
                end
                
                rows[middle_row].icon.y     = row_h
                rows[middle_row].bg.scale   = {1,2*1080/720}
                rows[middle_row+1].y        = middle_row*row_h
                rows[middle_row+1].bg.scale = {1,1080/720}
                rows[middle_row+1].icon.y   = row_h/2
                --[[
                rows[1].icon:unparent()
                
                
                for i = 1,#rows-1 do
                    rows[i+1].icon.y = rows[i].icon.y
                    rows[i].icon:unparent()
                    rows[i]:add(
                    rows[i].icon     = rows[i+1].icon
                end
                --]]
                top_i        = wrap_i(top_i+1,        channel_list)
                curr_channel = wrap_i(curr_channel+1, channel_list)
                bottom_i     = wrap_i(bottom_i+1,     channel_list)
                
                local last_x = rows[#rows].icon.x
                local last_y = rows[#rows].icon.y
                rows[#rows].icon = channel_list[bottom_i]
                rows[#rows].icon.x = last_x
                rows[#rows].icon.y = last_y
                rows[#rows]:add(rows[#rows].icon)
            end
        }
        
        
        --expand the next column
        rows[middle_row+1]:animate{      duration = 200, y = (middle_row-1)*row_h, }
        rows[middle_row+1].bg:animate{   duration = 200, scale = {1,2*1080/720}, }
        rows[middle_row+1].icon:animate{ duration = 200, y = row_h, }
        --contract the previously selected column
        rows[middle_row].bg:animate{   duration = 200, scale = {1,1080/720}, }
        rows[middle_row].icon:animate{ duration = 200, y = row_h/2, }
    end,
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
        main_menu:grab_key_focus()
        main_menu:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
        
    end,
}

function instance:on_key_down(k)

    return keypresses[k] and keypresses[k]()
end
--------------------------------------------------------------------
function instance:on_key_focus_in(self)
    instance:animate{
        duration = 300,
        z = 0,
        opacity = 255,
    }
end
--------------------------------------------------------------------
instance:add(
    Rectangle{
        name = "epg_bg",
        w = screen_w,
        h = screen_h,
        color = "707070",
    },
    Rectangle{
        name = "left margin",
        w = margin-5,
        h = screen_h,
        color = "black",
    },
    show_grid,
    timeline_header,
    top_left,
    Rectangle{
        name = "rule",
        w = screen_w,
        h = 7,
        y = heading_h - 7,
        color = "b0b0b0",
    }
)

instance.opacity = 0
instance.z = -300

return instance