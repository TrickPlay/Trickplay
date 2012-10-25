local make_row = function()
    --[[
    local bg = Clone{
        source = screen:find_child("epg_row_bg"),
        scale  = 1080/720,
    }
    local icon = Rectangle{ w = 50, h=50, x = -120}
    --]]
    local instance = Clone{
        source = screen:find_child("epg_row_bg"),
        scale  = 1080/720,
    }
    instance.icon = Clone()
    
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
local channel_logo_x = -120
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
    scale = 1080/720,
}
local half_hour_len = intervals.w*intervals.scale[1]
intervals.w = (screen_w-margin)*720/1080

local curr_time = os.date('*t')

local refresh = Timer{
    interval = ((curr_time.min > 30 and 60 or 30) - curr_time.min) * 1000*60,
    on_timer = function(self)
        self.interval = 30*60*1000
        --TODO: reload the schedule data
    end
}
local start_at_0 = curr_time.min < 30
curr_time.min = start_at_0 and 0 or 30
curr_time.sec = 0
local time_slots = {}
print("start_at_0",start_at_0)
timeline_header:add(timeline_bg,intervals)
for i = (start_at_0 and 0 or 1),(start_at_0 and 5 or 6) do
    timeline_header:add(Text{
        x = (i+(start_at_0 and 1 or 0)-1)*half_hour_len,
        y = 195,
        color = "white",
        font = "InterstateProRegular 50px",
        text = 
            (curr_time.hour+math.floor((i)/2))..":"..
            ((i%2 == 0) and "00" or "30"),
    }) 
    time_slots[i] = curr_time.hour
end
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
while (#rows-2)*row_h + margin < screen_h do
    table.insert(rows,make_row():set{y=(#rows-1)*row_h})
    if #rows > middle_row then rows[#rows].y = rows[#rows].y + row_h end
    if #rows == middle_row then rows[middle_row].scale = {1,2*1080/720} end
    rows[#rows].icon.y = rows[#rows].h/2 * rows[#rows].scale[2]
end
show_grid:add(unpack(rows))
--------------------------------------------------------------------

--------------------------------------------------------------------
local scheduling = nil

local function build_schedule_row(parent)
    
    local prev,show_name,show_time, sep
    parent.schedule_is_loaded = true
    for j,show in ipairs(parent.scheduling) do
        
        if show.x > screen_w - margin then break end
        
        if show.x <= 0 and prev then prev:unparent() end
        if show.x > 0 and prev and prev.x < 0 then 
            prev.show_name.w = prev.show_name.w + prev.x
            prev.show_time.w = prev.show_time.w + prev.x
            prev.x = 0
        end
        show_name = Text{
            color = "white",
            font = "InterstateProBold 40px",
            text = show.name,
            x=5,
            w = show.w-10,
            --y = 10,
            ellipsize = "END",
        }
        show_name.anchor_point = {0,show_name.h/2}
        show_time = Text{
            color = "white",
            font = "InterstateProLight 40px",
            text = 
                show.start.hour .. ":" ..
                show.start.min  .." - "..
                show.stop.hour  .. ":" ..
                show.stop.min,
            x=5,
            w = show.w-10,
            y = -row_h/2,
            opacity = 0,--(i==middle_row) and 255 or 0,
            ellipsize = "END",
        }
        show_time.anchor_point = {0,show_time.h/2}
        prev = Group{
            x = show.x,
            children = { show_name}--, show_time }
        }
        prev.show_name = show_name
        prev.show_time = show_time
        if show.x > 0 then
            sep = Clone{
                source = hidden_assets_group:find_child("show_border"),
                x = show.x,
                h = row_h,
            }
            sep.anchor_point = {0,sep.h/2}
            parent:add(sep)
        end
        parent:add(prev)
    end
    if prev and prev.x < 0 then 
        prev.x = 0
    end
    if prev == nil then
        show_name = Text{
            color = "white",
            font = "InterstateProBold 40px",
            text = "No Programming Information",
        }
        show_name.anchor_point = {0,show_name.h/2}
        show_time = Rectangle()
        prev = Group{
            children = { show_name}--, show_time }
        }
        prev.show_name = show_name
        prev.show_time = show_time
        parent:add(prev)
    end
end
local function integrate_schedule()
    
    for i,channel_icon in ipairs(channel_list) do
        --print(channel_icon.name,scheduling[channel_icon.name])
        channel_icon.scheduling = scheduling[channel_icon.name] or {}
        build_schedule_row(channel_icon)
    end
    --[[
    local prev
    for i = 2,#rows-1 do
        build_schedule_row(rows[i].icon)
    end
    --]]
end

function instance:setup_icons(t)
    ---[[
    --TODO setup wrap around stuff here
    
    if type(t) ~= "table" or #t == 0 then return end
    for i,channel in ipairs(t) do
        channel_list[i] = Group{children={clone_proxy(channel.Name):set{x=channel_logo_x}}}
        channel_list[i].name = channel.Name
    end
    
    top_i    = wrap_i(curr_channel-middle_row,        channel_list)
    bottom_i = wrap_i(curr_channel+(#rows-middle_row),channel_list)
    
    for i = 1,#rows do
        rows[i].icon:unparent()
    end
    for i = 2,#rows-1 do
        rows[i].icon = channel_list[
            
            wrap_i(curr_channel+i-middle_row,channel_list)
            
        ]:set{y=rows[i].y+((i == middle_row) and row_h or row_h/2)}
        show_grid:add(rows[i].icon)
    end
    if scheduling ~= nil then
        integrate_schedule()
    end
    --]]
end
local function extract_time(s)
    --expected input
    --"2012-10-23T17:50:00Z"
    local t = {}
    
    t.year,
    t.month,
    t.day,
    t.hour,
    t.min,
    t.second = 
        string.match(s,"(%d*)-(%d*)-(%d*)T(%d*):(%d*):(%d*)")
    
    return t
end
local function x_from_time(t)
    --[[
    local delta = {}
    
    delta.sec = 0
    delta.min  = t.min - curr_time.min
    if delta.min < 0 then
        delta.min = 60 + delta.min
        delta.hour = t.hour - curr_time.hour - 1
    else
        delta.hour = t.hour - curr_time.hour
    end
    if delta.hour < 0 then
        delta.hour = 24 + delta.hour
        delta.day = t.day - curr_time.day - 1
    else
        delta.day = t.day - curr_time.day
    end
    --]]
    
    --assumes that there won't be more that 1 day difference
    return 2*half_hour_len*(
        (t.day  - curr_time.day)  *24 + 
        (t.hour - curr_time.hour)     + 
        (t.min  - curr_time.min)  /60
    )
end
function instance:load_scheduling(t)
    print("s")
    t = t.Channels.Channel
    
    scheduling = {}
    
    local slot
    for _,channel in pairs(t) do
        --print("-------------------------")
        --dumptable(channel)
        scheduling[channel.Name] = {}
        if channel.Events then
            for i, e in ipairs(channel.Events.Event) do
                if e.Titles.Title[1].Name == nil then
                    print("no name")
                    dumptable(e.Titles.Title)
                end
                slot = {
                    name  = e.Titles.Title[1].Name,
                    start = extract_time(e.AvailabilityStart),
                    stop  = extract_time(e.AvailabilityEnd  ),
                }
                
                slot.x = x_from_time(slot.start)--i~=1 and scheduling[t.Name][i-1].x + scheduling[t.Name][i-1].w or 0
                slot.w = e.DurationInSeconds/60/60 * 2*half_hour_len
                --dumptable(slot.start)
                --print(slot.x/(2*half_hour_len),slot.x)
                scheduling[channel.Name][i] = slot
                
            end
        end
    end
    
    if #channel_list ~= 0 then
        integrate_schedule()
    end
    
end

--------------------------------------------------------------------
local animating_back_to_prev_menu = false
local animating_show_grid = false
local keypresses = {
    [keys.Up] = function()
        if #channel_list == 0 or animating_show_grid then return end
        animating_show_grid = true
        local top_x = rows[1].icon.x
        local top_y = rows[1].icon.y
        rows[1].icon = channel_list[top_i]
        rows[1].icon.x = 0
        rows[1].icon.y = rows[1].y+row_h/2
        show_grid:add(rows[1].icon)
        if not rows[1].icon.schedule_is_loaded then 
            --build_schedule_row(rows[1].icon)
        end
        --dolater(function()
        show_grid:animate{
            duration = 200,
            y = heading_h+row_h,
            on_completed = function()
                animating_show_grid = false
                show_grid.y = heading_h
                --consolidated all the other on_completed's
                if rows[middle_row-1].is_animating   then rows[middle_row-1]:stop_animation()   end
                if rows[middle_row-1].icon.is_animating then rows[middle_row-1].icon:stop_animation() end
                if rows[middle_row].is_animating        then rows[middle_row]:stop_animation()        end
                if rows[middle_row].icon.is_animating   then rows[middle_row].icon:stop_animation()   end
                
                --[[
                for i = 1,#rows do
                    rows[i].icon:unparent()
                end
                for i = #rows,2,-1 do
                    rows[i].icon = rows[i-1].icon
                    rows[i]:add(rows[i-1].icon)
                end
                --]]
                rows[middle_row-1].scale = {1,1080/720}
                --rows[middle_row-1].icon.y   = row_h/2
                rows[middle_row].y          = (middle_row-2)*row_h
                rows[middle_row].scale   = {1,2*1080/720}
                --rows[middle_row].icon.y     = row_h
                for i = #rows,2,-1 do
                    rows[i].icon   = rows[i-1].icon
                    rows[i].icon.y = rows[i].y+ ((i == middle_row) and row_h or row_h/2)
                end
                
                top_i        = wrap_i(top_i-1,        channel_list)
                curr_channel = wrap_i(curr_channel-1, channel_list)
                bottom_i     = wrap_i(bottom_i-1,     channel_list)
                
                rows[#rows].icon:unparent()
                --rows[1].icon:unparent()
                
            end
        }
        --expand the next column
        rows[middle_row-1]:animate{   duration = 200, scale = {1,2*1080/720}, }
        rows[middle_row-1].icon:animate{ duration = 200, y = (middle_row-2)*row_h, }
        --rows[middle_row-1].icon:animate{ duration = 200, y = rows[middle_row-1].icon.y+row_h/2, }
        --contract the previously selected column
        --rows[middle_row]:animate{      duration = 200, y = (middle_row-1)*row_h, }
        rows[middle_row]:animate{   duration = 200, scale = {1,1080/720}, y = (middle_row-1)*row_h,}
        rows[middle_row].icon:animate{ duration = 200, y = (middle_row-1)*row_h+row_h/2, }
        --end)
    end,
    [keys.Down] = function()
        if #channel_list == 0 or animating_show_grid then return end
        animating_show_grid = true
        
        local last_x = rows[#rows].icon.x
        local last_y = rows[#rows].icon.y
        rows[#rows].icon = channel_list[bottom_i]
        rows[#rows].icon.x = 0
        rows[#rows].icon.y = rows[#rows].y+row_h/2
        show_grid:add(rows[#rows].icon)
        
        if not rows[#rows].icon.schedule_is_loaded then 
            --build_schedule_row(rows[#rows].icon)
        end
        
        --dolater(function()
        show_grid:animate{
            duration = 200,
            y = heading_h-row_h,
            on_completed = function()
                animating_show_grid = false
                show_grid.y = heading_h
                --consolidated all the other on_completed's
                if rows[middle_row].is_animating     then rows[middle_row]:stop_animation()     end
                if rows[middle_row].icon.is_animating   then rows[middle_row].icon:stop_animation()   end
                if rows[middle_row+1].is_animating      then rows[middle_row+1]:stop_animation()      end
                if rows[middle_row+1].icon.is_animating then rows[middle_row+1].icon:stop_animation() end
                
                --[[
                for i = 1,#rows do
                    rows[i].icon:unparent()
                end
                for i = 1,#rows-1 do
                    rows[i].icon = rows[i+1].icon
                    rows[i]:add(rows[i+1].icon)
                end
                --]]
                rows[middle_row].icon.y     = row_h
                rows[middle_row].scale   = {1,2*1080/720}
                rows[middle_row+1].y        = middle_row*row_h
                rows[middle_row+1].scale = {1,1080/720}
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
                for i = 1,#rows-1 do
                    rows[i].icon   = rows[i+1].icon
                    --rows[i].icon.y = rows[i].y+row_h/2
                    rows[i].icon.y = rows[i].y+ ((i == middle_row) and row_h or row_h/2)
                end
                rows[1].icon:unparent()
                
            end
        }
        
        
        --expand the next column
        rows[middle_row+1]:animate{   duration = 200, scale = {1,2*1080/720}, y = (middle_row-1)*row_h}
        rows[middle_row+1].icon:animate{ duration = 200, y = (middle_row-1)*row_h+row_h, }
        --contract the previously selected column
        rows[middle_row]:animate{   duration = 200, scale = {1,1080/720}, }
        rows[middle_row].icon:animate{ duration = 200, y = (middle_row-2)*row_h+row_h/2, }
        --end)
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