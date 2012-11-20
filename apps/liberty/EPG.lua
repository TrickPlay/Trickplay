
local dur = 200
local curr_time = os.date('*t')

local make_row = function()
    
    local instance = Clone{
        source = screen:find_child("epg_row_bg"),
        scale  = {1,.5},
    }
    instance.icon  = Group{name="icon placeholder"}
    instance.shows = Group{name="show placeholder"}
    instance.icon.shows = shows
    instance.icon.scheduling = {} -- stupid edge case
    
    return instance
end
local wrap_i = function(i,list)
    
    return (i - 1) % (# list) + 1
    
end

--------------------------------------------------------------------
local instance = Group()

local channel_list = {}
local integrating_schedule_i = 1

local margin = 425
local heading_h = 285
local heading_txt_y = 65
local channel_logo_x = -50
--------------------------------------------------------------------
local mesg = Text{
    x    = (screen_w - margin)/2,
    y    = (screen_h - heading_h)/2,
    text = "Fetching Data",
    font = "InterstateProRegular 40px",
    color = "white",
}
mesg.anchor_point = {mesg.w/2, mesg.h/2}
mesg.base = "Fetching Data"
mesg.num = 0

local ellipsis = function(self)
    if mesg == nil then 
        self:stop() 
        return
    end
    
    mesg.num = mesg.num%4+1
    
    local t = mesg.base
    for i=1,mesg.num do t = t.."." end
    mesg.text = t
end
local progress = function(self)
    if mesg == nil then 
        self:stop() 
        return
    end
    
    mesg.text = mesg.base.." "..string.format("%02d",100*(integrating_schedule_i / #channel_list)).."%"
end

local mesg_timer = Timer{
    interval = 500,
    on_timer = ellipsis
}
--------------------------------------------------------------------
local top_left = Group{
    name = "top-left date/time",
    y = heading_txt_y,
}
local curr_time_disp = Text{
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
local days_r = {
    "SUN",
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT"  
}
local months_r = {
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"
}


local update_curr_time_disp__on_timer = function(self)
    local t = os.date('*t')
    curr_time_disp.text = 
        string.format("%02d",t.hour) ..":"..
        string.format("%02d",t.min)  
    curr_day.text = days_r[t.wday]  .." "..
        string.format("%02d",t.day) .." "..
        months_r[t.month]  
end
local update_curr_time_disp = Timer{
    interval = curr_time.sec*1000,
    on_timer = function(self)
        
        self.interval = 60*1000
        self.on_timer = update_curr_time_disp__on_timer
        
        update_curr_time_disp__on_timer(self)
    end
}
update_curr_time_disp__on_timer()
top_left:add(
    curr_time_disp,
    Rectangle{
        x = margin - 10,
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
local intervals_g = Group{
    name = "timeline"
}
local intervals = Image{
    src = "assets/epg/timeline-interval.png",
    tile = {true,false},
    y = 195,
    --scale = 1080/720,
}
local half_hour_len = intervals.w
intervals_g.x = -4*half_hour_len
intervals.w = (screen_w-margin) + 8*half_hour_len

--[[
local refresh = Timer{
    interval = ((curr_time.min > 30 and 60 or 30) - curr_time.min) * 1000*60,
    on_timer = function(self)
        self.interval = 30*60*1000
        --TODO: reload the schedule data
    end
}
--]]
local start_at_0 --= curr_time.min < 30
--curr_time.min = start_at_0 and 0 or 30
--curr_time.sec = 0
local time_slots = {}
intervals_g:add(intervals)
timeline_header:add(timeline_bg,intervals_g)

local len = 6 + 4 + 4
local time_slots = {}
for i = 1,len do--(start_at_0 and 0 or 1),(start_at_0 and (len-1) or len) do
    
    table.insert(time_slots, Text{
        name = "time slot "..tostring(i),
        x = (i-1)*half_hour_len,
        y = 195,
        color = "white",
        font = "InterstateProRegular 50px",
    })
    
end
local zone_offset = -4

local setup_curr_time = function(t)
    curr_time = os.date('*t',t)
    start_at_0 = curr_time.min < 30
    curr_time.min = start_at_0 and 0 or 30
    curr_time.sec = 0
    for i,ts in ipairs(time_slots) do
        i = (start_at_0 and (i-1) or i)+zone_offset
        ts.text = ((curr_time.hour+math.floor((i)/2))%24)..":"..
            ((i%2 == 0) and "00" or "30")
    end
end
setup_curr_time(os.time())
intervals_g:add(unpack(time_slots))
function intervals_g:move_x_by(dx)
    intervals_g:animate{
        duration = dur,
        x=intervals_g.x + dx,
        on_completed = function(self)
            local num_zones =0
            if intervals_g.x> -2* half_hour_len then
                while intervals_g.x >  -half_hour_len do
                    intervals_g.x = intervals_g.x - half_hour_len
                    num_zones = num_zones - 1
                end
            elseif intervals_g.x< -2*half_hour_len then
                while intervals_g.x < -4*half_hour_len do
                    intervals_g.x = intervals_g.x + half_hour_len
                    num_zones = num_zones + 1
                end
            end
            --[[
            while 
            
            if intervals_g.x> 0 then
                num_zones= -math.floor(intervals_g.x / (half_hour_len))-4
            elseif intervals_g.x< 0 then
                num_zones= -math.ceil(intervals_g.x / (half_hour_len))-4
            end
            intervals_g.x = (intervals_g.x % half_hour_len)-4*half_hour_len
            --]]
            zone_offset = zone_offset + num_zones
            for i,ts in ipairs(time_slots) do
                i = (start_at_0 and (i-1) or i) + zone_offset
                ts.text = ((curr_time.hour+math.floor((i)/2))%24)..":"..
                    ((i%2 == 0) and "00" or "30")
            end
        end,
    }
end
--------------------------------------------------------------------

local row_h = 70*1080/720
local middle_row = 5
local curr_channel = 1
local row_i = 1

local top_i = curr_channel
local bottom_i = curr_channel

local show_grid = Group{
    name = "show grid",
    x = margin,
    y = heading_h,
}
local show_grid_text = Group{
    name = "show_grid_text",
    --x = margin,
    --y = heading_h,
}
local show_grid_separators = Group{
    name = "show_grid_separators",
    --x = margin,
    --y = heading_h,
}
local show_grid_bg = Group{
    name = "show_grid_bg",
    --x = margin,
    --y = heading_h,
}
local show_grid_icons = Group{
    name = "show_grid_icons",
    --x = margin,
    --y = heading_h,
}


local chb = Clone {source = screen:find_child("epg_glow"),--Rectangle{
    x = 330,
    y = -120,
    opacity = 255*.8,
    --w = margin*2-20,
    --h = row_h/2,
    --scale = {1,2},
    --anchor_point = {0,45},
    --color = "a0a0a0",
}
--[[
local chl1 = Clone {source = screen:find_child("horizonline"),--Rectangle{
    w = margin*2-20,
    --h = row_h/2,
    --scale = {1,2},
    anchor_point = {0,45},
    --color = "a0a0a0",
}
local chl2 = Clone {source = screen:find_child("horizonline"),--Rectangle{
    w = margin*2-20,
    --h = row_h/2,
    --scale = {1,2},
    anchor_point = {0,45},
    --color = "a0a0a0",
}
--]]
local channel_hl = Group{
    name = "channel_hl",
    x = -830,
    y = row_h*(middle_row-2),
    children = {chl1,chl2,chb}
}
local sel_scale = 1.5

show_grid:add(show_grid_bg,Rectangle{color="black",x=-margin,w=margin,h=screen_h*2,y = -screen_h/2},channel_hl,show_grid_icons,mesg)
local rows = {}
-- -1 because its looking at the next one to be added,
-- -2 more for wrap-around

while (#rows-2)*row_h + margin < screen_h do
    table.insert(rows,make_row():set{y=(#rows-1)*row_h})
    if #rows > middle_row then rows[#rows].y = rows[#rows].y + row_h end
    if #rows == middle_row then rows[middle_row].scale = 1 end
    rows[#rows].icon.y = rows[#rows].h/2 * rows[#rows].scale[2]
    rows[#rows].shows.y = rows[#rows].h/2 * rows[#rows].scale[2]
    show_grid_bg:add(rows[#rows])
end

local curr_hl = Clone{
    source = hidden_assets_group:find_child("epg_row_hl"),
    h = row_h*2,
    w = screen_w,
    y = rows[middle_row].y
}
local prev_hl = Clone{
    source  = curr_hl.source,
    h       = curr_hl.h,
    w       = curr_hl.w,
    y       = curr_hl.y,
    opacity = 0
}
show_grid_text:add(prev_hl,curr_hl)
--------------------------------------------------------------------
--------------------------------------------------------------------

local function truncate_show_to_x(s,x)
    
    if x > s.x + s.w then error("you silly goose") end
    
    s.show_name.w = s.w + s.x - x
    s.show_name.x = x + margin
    s.show_time.x = s.show_name.x
    s.show_time.w = s.show_name.w
end
local function reset_show_x_w(s)
   s.show_name.w = s.w - margin*2
   s.show_name.x = x + margin
   s.show_time.x = s.show_name.x
   s.show_time.w = s.show_name.w
end

local get_separator,add_separator_to_pool
local sep_src = hidden_assets_group:find_child("show_border")
do
    local pool = {}
    get_separator = function(x)
        return (
            #pool > 0 and table.remove(pool) or
            Clone{ source = sep_src }
        ):set{x=x}
    end
    add_separator_to_pool = function(s) table.insert(pool,s) end
    
    for i=1,100 do
        
        add_separator_to_pool(Clone{ source = sep_src })
        
    end
end



local show_name_margin = 10

--------------------------------------------------------------------
--called when a user presses left, the gird will shift to the right, new shows coming in from the left

local show_grid__right_edge=screen_w - margin
local pull_in_right_to = function(new_x)
    if new_x >= show_grid__right_edge then return end
    --for i,r in ipairs(rows) do
    local s,r_i,i,r
    for i = 2,#rows-1 do
        r = rows[i]
        s = r.icon.scheduling
        if #s >= 1 then
        r_i = r.icon.right_i
        while r_i >r.icon.left_i and new_x <= s[r_i].x do
            s[r_i].show_time:unparent()
            s[r_i].show_name:unparent()
            s[r_i].sep:unparent()
            add_separator_to_pool(s[r_i].sep)
            r_i = r_i-1
        end
        r.icon.right_i = r_i
        end
    end
    show_grid__right_edge = new_x
end
local pre_pull_in_left_to
local push_out_right_to = function(new_x)
    if new_x <= show_grid__right_edge then return end
    --for i,r in ipairs(rows) do
    local s,r_i,i,r
    for i = 2,#rows-1 do
        r = rows[i]
        s = r.icon.scheduling
        if #s >= 1 then
        --dumptable(s)
        r_i = r.icon.right_i
        while r_i < #s and new_x >= s[r_i].x+s[r_i].w do
            r_i = r_i+1
            --add the next show to screen
            r.icon.show_times:add( s[r_i].show_time )
            r.icon.show_names:add( s[r_i].show_name )
            s[r_i].sep = get_separator(s[r_i].x)
            r.icon.separators:add( s[r_i].sep       )
        end
        r.icon.right_i = r_i
        end
    end
    show_grid__right_edge = new_x
    pre_pull_in_left_to(new_x - (screen_w-margin))
end

show_grid__left_edge=0
pre_pull_in_left_to = function(new_x)
    if new_x <= show_grid__left_edge then return end
    local ls = {}
    --for i,r in ipairs(rows) do
    local s,l_i,i,r
    for i = 2,#rows-1 do
        r = rows[i]
        s = r.icon.scheduling
        
        if #s == 0 then
            r.icon.no_prog:animate{
                duration = dur,
                x = new_x + show_name_margin,
            }
        else
            --reset_show_x_w(s[r.left_i])
            l_i = r.icon.left_i
            while l_i < r.icon.right_i and new_x >= s[l_i].x+s[l_i].w do
                --add the next show to screen
                --s[l_i].show_time:unparent()
                --s[l_i].show_name:unparent()
                --s[l_i].sep:unparent()
                l_i = l_i+1
            end
            ls[i] = l_i
            if s[l_i].x < new_x then
                dx = new_x - s[l_i].x
                dx = dx < 0 and 0 or dx
                s[l_i].show_name:animate{
                    duration = dur,
                    x = new_x + show_name_margin,
                    w = s[l_i].w - dx - 2*show_name_margin,
                }
                s[l_i].show_time:animate{
                    duration = dur,
                    x = new_x + show_name_margin,
                    w = s[l_i].w - dx - 2*show_name_margin,
                }
            end
        end
        --truncate the new first show to fit if needed
        --truncate_show_to_x(s[r.left_i],new_x)
    end
end
pull_in_left_to = function(new_x)
    if new_x <= show_grid__left_edge then return end
    --for i,r in ipairs(rows) do
    local s,l_i,i,r
    for i = 2,#rows-1 do
        r = rows[i]
        s = r.icon.scheduling
        if #s >= 1 then
        --reset_show_x_w(s[r.left_i])
        l_i = r.icon.left_i
        while l_i < r.icon.right_i and new_x >= s[l_i].x+s[l_i].w do
            --add the next show to screen
            s[l_i].show_time:unparent()
            s[l_i].show_name:unparent()
            s[l_i].sep:unparent()
            add_separator_to_pool(s[l_i].sep)
            l_i = l_i+1
        end
        r.icon.left_i = l_i
        end
        --truncate the new first show to fit if needed
        --truncate_show_to_x(s[r.left_i],new_x)
    end
    --[[
    --animate out x's & w's of current left most shows
    for i,r in ipairs(rows) do
        s = r.icon.scheduling
        i = r.icon.left_i
        --if "No Programming information"
        if #s == 0 then
            --move the "No Programming information" to the Left
        --truncate show name
        elseif s[i].x < new_x then
            dx = new_x - s[i].x
            s[i].show_name:animate{
                duration = dur,
                x = show_grid__left_edge + show_name_margin,
                w = s[i].w - dx - 2*show_name_margin,
            }
            s[i].show_time:animate{
                duration = dur,
                x = show_grid__left_edge + show_name_margin,
                w = s[i].w - dx - 2*show_name_margin,
            }
        end
    end
    --]]
    show_grid__left_edge = new_x
end


local push_out_left_to = function(new_x)
    if new_x >= show_grid__left_edge then return end
    ---[[
    local s,i,dx
    --animate out x's & w's of current left most shows
    --for i,r in ipairs(rows) do
    for r_i = 2,#rows-1 do
        r = rows[r_i]
        s = r.icon.scheduling
        i = r.icon.left_i
        --if "No Programming information"
        if #s == 0 then
            --move the "No Programming information" to the Left
            r.icon.no_prog:animate{
                duration = dur,
                x = new_x + show_name_margin,
            }
        --re-truncate show name
        elseif s[i].x < new_x then
            dx = new_x - s[i].x
            dx = dx < 0 and 0 or dx
            s[i].show_name:animate{
                duration = dur,
                x = new_x + show_name_margin,
                w = s[i].w - dx - 2*show_name_margin,
            }
            s[i].show_time:animate{
                duration = dur,
                x = new_x + show_name_margin,
                w = s[i].w - dx - 2*show_name_margin,
            }
        --if show x is equal to or the right of the new left edge
        --expand out the name if it isnt alreay expanded out
        elseif s[i].x ~= (s[i].show_name.x-show_name_margin) then
            s[i].show_name:animate{
                duration = dur,
                x = s[i].x +   show_name_margin,
                w = s[i].w < (2*show_name_margin) and 0 or s[i].w - 2*show_name_margin,
            }
            s[i].show_time:animate{
                duration = dur,
                x = s[i].x +   show_name_margin,
                w = s[i].w < (2*show_name_margin) and 0 or s[i].w - 2*show_name_margin,
            }
        end
    end
    --]]
    --add new shows
    --for i,r in ipairs(rows) do
    for i = 2,#rows-1 do
        r = rows[i]
        s = r.icon.scheduling
        if #s >= 1 then
        --reset_show_x_w(s[r.left_i])
        l_i = r.icon.left_i
        while l_i > 1 and new_x < s[l_i].x do
            l_i = l_i-1
            --add the next show to screen
            r.icon.show_times:add( s[l_i].show_time )
            r.icon.show_names:add( s[l_i].show_name )
            s[l_i].sep = get_separator(s[l_i].x)
            r.icon.separators:add( s[l_i].sep )
            if s[l_i].x < new_x then
                dx = new_x - s[l_i].x
                dx = dx < 0 and 0 or dx
                s[l_i].show_name:set{
                    --duration = dur,
                    x = new_x + show_name_margin,
                    w = s[l_i].w - dx - 2*show_name_margin,
                }
                s[l_i].show_time:set{
                    --duration = dur,
                    x = new_x + show_name_margin,
                    w = s[l_i].w - dx - 2*show_name_margin,
                }
            else 
                s[l_i].show_name:set{
                    --duration = dur,
                    x = s[l_i].x + show_name_margin,
                    w = s[l_i].w < (2*show_name_margin) and 0 or s[l_i].w - 2*show_name_margin,
                }
                s[l_i].show_time:set{
                    --duration = dur,
                    x = s[l_i].x + show_name_margin,
                    w = s[l_i].w < (2*show_name_margin) and 0 or s[l_i].w - 2*show_name_margin,
                }
            end
        end
        r.icon.left_i = l_i
        end
        --truncate the new first show to fit if needed
        --truncate_show_to_x(s[r.left_i],new_x)
    end
    show_grid__left_edge = new_x
end

local populate_row = function(r)
    local s = r.icon.scheduling
    if r.icon.no_prog then
        r.icon.show_names:add(r.icon.no_prog)
        r.icon.no_prog.x = show_grid__left_edge + show_name_margin
        return
    end
    r.icon.left_i  = #s
    r.icon.right_i = 1
    for i,show in ipairs(s) do
    
        if not (
                show_grid__left_edge  >= (show.x+ show.w) or 
                show_grid__right_edge <=  show.x
            ) then
            
            r.icon.show_times:add( show.show_time )
            r.icon.show_names:add( show.show_name )
            show.sep = get_separator(show.x)
            r.icon.separators:add( show.sep )
            
            show.show_name:set{
                --duration = dur,
                x = show.x + show_name_margin,
                w = show.w < (2*show_name_margin) and 0 or show.w - 2*show_name_margin,
            }
            show.show_time:set{
                --duration = dur,
                x = show.x + show_name_margin,
                w = show.w < (2*show_name_margin) and 0 or show.w - 2*show_name_margin,
            }
            r.icon.left_i  = r.icon.left_i  < i and r.icon.left_i  or i
            r.icon.right_i = r.icon.right_i > i and r.icon.right_i or i
        end
    end
    
    
    if rows[middle_row] == r then r.icon.separators.scale={1,2*row_h/sep_src.h} end
    
    dx = show_grid__left_edge - s[r.icon.left_i].x
    dx = dx < 0 and 0 or dx
    if s[r.icon.left_i].x < show_grid__left_edge then
        s[r.icon.left_i].show_name:set{
            --duration = dur,
            x = show_grid__left_edge + show_name_margin,
            w = s[r.icon.left_i].w - dx - 2*show_name_margin,
        }
        s[r.icon.left_i].show_time:set{
            --duration = dur,
            x = show_grid__left_edge + show_name_margin,
            w = s[r.icon.left_i].w - dx - 2*show_name_margin,
        }
    end
end
--------------------------------------------------------------------
local scheduling = nil
local show_name_h = Text{
            color = "white",
            font = "InterstateProBold 40px",
            text = "h",
        }.h 
        
local build_schedule_row, reset_build_row
local num_shows_created = 0
local num_shows_created_per_frame = 10
do
    
    local separators,show_names,show_times, show_name,show_time, sep, show, start_i
    function reset_build_row(parent)
        parent.scheduling = scheduling[parent.name] or {}
        
        start_i = 1
        
        separators = Group{name = "separators",anchor_point = {0,sep_src.h/2},scale={1,row_h/sep_src.h}}
        show_names = Group{name = "show_names"}
        show_times = Group{name = "show_times",opacity = 0}
        
        parent.shows      = Group{name = parent.name}
        parent.separators = separators
        parent.show_names = show_names
        parent.show_times = show_times
        parent.left_i     = 1
        parent.right_i    = 1
        
        parent.shows:add(show_names,separators)
        
        show_name = nil
        show_time = nil
        sep       = nil
        show      = nil
    end
    function build_schedule_row(parent)
        
        for j = start_i,#parent.scheduling do
            --print(j)
            num_shows_created = num_shows_created + 1
            if num_shows_created > num_shows_created_per_frame then
                start_i = j
                return false
            end
        --for j,show in ipairs(parent.scheduling) do
            show = parent.scheduling[j]
            
            show_name = Text{
                color = "white",
                font = "InterstateProBold 40px",
                text = show.name,
                x=show.x+show_name_margin,
                w =  show.w>(show_name_margin*2) and show.w-show_name_margin*2 or 0,
                --y = 10,
                ellipsize = "END",
            }
            show_name.anchor_point = {0,show_name_h/2}
            
            show_time = Text{
                color = "white",
                font = "InterstateProLight 40px",
                text = 
                    show.start.hour .. ":" ..
                    show.start.min  .." - "..
                    show.stop.hour  .. ":" ..
                    show.stop.min,
                x=show.x+show_name_margin,
                w = show.w>(show_name_margin*2) and show.w-show_name_margin*2 or 0,
                y = -row_h/2,
                --(i==middle_row) and 255 or 0,
                ellipsize = "END",
            }
            show_time.anchor_point = {0,show_name_h/2}
            --[[
            sep = Clone{
                source = sep_src,
                x = show.x,
                --h = row_h,
            }
            --]]
            parent.scheduling[j].show_name = show_name
            parent.scheduling[j].show_time = show_time
        end
        --[[
        if show_name and show_name.x < 0 then 
            show_name.x = show_name_margin
            show_time.x = show_name_margin
            --sep.x = 0
        end
        --]]
        if #parent.scheduling == 0 then
            num_shows_created = num_shows_created + 1
            if num_shows_created > num_shows_created_per_frame then
                return false
            end
            show_name = Text{
                color = "white",
                font  = "InterstateProBold 40px",
                text  = "No Programming Information",
                x     = show_name_margin,
                w     = 2*2*half_hour_len,
            }
            parent.no_prog = show_name
            show_name.anchor_point = {0,show_name.h/2}
            --show_names:add(show_name)
        end
        return true
    end
end
local integrating_schedule = false
local finished_integrating_schedule = false
local complete_integrate_schedule
local step_integrate_schedule
step_integrate_schedule= function()
    num_shows_created = 0
    
    while true do
        
        --if finished building the current row
        if build_schedule_row(channel_list[integrating_schedule_i]) then
            channel_list[integrating_schedule_i].schedule_is_loaded = true
            --increment to the next one
            integrating_schedule_i = integrating_schedule_i+1
            --if out of rows, display
            if integrating_schedule_i > #channel_list then
                dolater(complete_integrate_schedule)
                return
            --set up the table for the next one
            else
                reset_build_row(channel_list[integrating_schedule_i])
            end
        else
            dolater(step_integrate_schedule)
            return
        end
    end
    
end
local function integrate_schedule()
    if integrating_schedule then return end
    print("Begin building EPG")
    
    integrating_schedule_i = 1
    reset_build_row(channel_list[integrating_schedule_i])
    
    
    dolater(step_integrate_schedule)
    mesg.base = "Creating Grid"
    mesg_timer.on_timer = progress
end

complete_integrate_schedule= function()
    local r
    for i = 1,#rows do
        rows[i].shows:unparent()
    end
    for i = 2,#rows-1 do
        r = rows[i]
        r.shows = r.icon.shows
        r.shows.y=r.y+((i == middle_row) and row_h or row_h/2)
        show_grid_text:add(r.icon.shows)
        populate_row(r)
    end
    rows[middle_row].shows:add(rows[middle_row].icon.show_times)
    --rows[middle_row].icon:add(rows[middle_row].icon.show_times)
    
    if #rows[middle_row].icon.scheduling == 0 then
            curr_hl:set{
                x       = show_grid__left_edge,-- -show_name_margin,
                y       = rows[middle_row].y,
                w       = screen_w - margin,-- +show_name_margin*2,
            }
    else
        rows[middle_row].icon.show_times.opacity = 255
        row_i = rows[middle_row].icon.left_i
        curr_hl:set{
            x       = rows[middle_row].icon.scheduling[row_i].x,
            y       = rows[middle_row].y,
            w       = rows[middle_row].icon.scheduling[row_i].w,
            opacity = 255
        }
    end
    print("Finished building EPG")
    finished_integrating_schedule = true
    mesg:unparent()
    mesg = nil
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
    local item
    for i,channel in ipairs(t) do
        item = clone_proxy(channel.Name)
        item.x = channel_logo_x
        item.anchor_point = {item.w,item.h/2}
        channel_list[i] = item--Group{children={item}}
        channel_list[i].name = channel.Name
    end
    
    top_i    = wrap_i(curr_channel-middle_row+1,        channel_list)
    bottom_i = wrap_i(curr_channel+(#rows-middle_row),channel_list)
    
    for i = 1,#rows do
        rows[i].icon:unparent()
    end
    for i = 2,#rows-1 do
        rows[i].icon = channel_list[
            
            wrap_i(curr_channel+i-middle_row,channel_list)
            
        ]:set{  y=rows[i].y+((i == middle_row) and row_h or row_h/2)  }
        
        show_grid_icons:add(rows[i].icon)
    end
    rows[middle_row].icon.scale = {sel_scale,sel_scale}
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
function instance:load_scheduling(t,old_time)
    if old_time then 
        setup_curr_time(old_time) 
    end
    t = t.Channels.Channel
    
    scheduling = {}
    local slot
    for _,channel in pairs(t) do
        scheduling[channel.Name] = {}
        if channel.Events then
            for i, e in ipairs(channel.Events.Event) do
                if e.Titles.Title[1].Name == nil then
                    dumptable(e.Titles.Title)
                end
                slot = {
                    name  = e.Titles.Title[1].Name,
                    start = extract_time(e.AvailabilityStart),
                    stop  = extract_time(e.AvailabilityEnd  ),
                }
                
                slot.x = x_from_time(slot.start)--i~=1 and scheduling[t.Name][i-1].x + scheduling[t.Name][i-1].w or 0
                slot.w = e.DurationInSeconds/60/60 * 2*half_hour_len
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
---[==[
    [keys.Left] = function()
        if  not finished_integrating_schedule or #channel_list == 0 or 
            animating_show_grid or show_grid__left_edge <= -half_hour_len then 
            
            return 
        end
        animating_show_grid = true
        
        local dx
        --if at the left-most show, and but not at the left edge
        if row_i == 1 then 
            dx = (show_grid__left_edge >= (-2*half_hour_len)) and 
                (2*half_hour_len) or 
                (-show_grid__left_edge)
            print("hehehe",dx,show_grid__left_edge,-2*half_hour_len,(show_grid__left_edge <= (-2*half_hour_len)))
            push_out_left_to(show_grid__left_edge - dx)
            --move_left_vis_x(show_grid__left_edge - half_hour_len )
            show_grid_text:animate{
                duration = dur,
                x = show_grid_text.x + dx,
            }
            curr_hl:animate{duration = dur,
                x = curr_hl.x - dx,
                w = (curr_hl.w == (screen_w - margin) and (screen_w - margin) or curr_hl.w + dx),
                on_completed = function() 
                    pull_in_right_to(show_grid__left_edge + (screen_w - margin) )
                    animating_show_grid = false
                end
            }
            intervals_g:move_x_by(dx)
            return 
        end
        prev_hl:set{
            x       = curr_hl.x,
            y       = curr_hl.y,
            w       = curr_hl.w,
            h       = curr_hl.h,
            opacity = 255
        }
        local channel = rows[middle_row].icon
        local scheduling = rows[middle_row].icon.scheduling
        --[[if  row_i == rows[middle_row].icon.left_i then
            row_i = row_i - 1
            channel.separators:add(scheduling[row_i].sep)
            channel.show_names:add(scheduling[row_i].show_name)
            channel.show_times:add(scheduling[row_i].show_time)
            show_grid:animate{duration = dur,x=scheduling[row_i].x }
        else--]]
        if rows[middle_row].icon.scheduling[row_i].x < show_grid__left_edge then
            next_i = row_i
        else
            next_i = row_i==1 and 1 or row_i - 1
        end
        dx = show_grid__left_edge - rows[middle_row].icon.scheduling[next_i].x
        if dx >= 2*half_hour_len then
            push_out_left_to(show_grid__left_edge - 2*half_hour_len)
            --move_left_vis_x(show_grid__left_edge - 2*half_hour_len )
            --next_i = row_i
            show_grid_text:animate{
                duration = dur,
                x = show_grid_text.x + 2*half_hour_len,
            }
            intervals_g:move_x_by(2*half_hour_len)
        elseif dx > 0 then
            push_out_left_to(show_grid__left_edge - dx)
            --move_left_vis_x(show_grid__left_edge - dx )
            show_grid_text:animate{
                duration = dur,
                x = show_grid_text.x + dx,
            }
            intervals_g:move_x_by(dx)
        end
        curr_hl:set{
            x       = rows[middle_row].icon.scheduling[next_i].x,
            y       = rows[middle_row].y,
            w       = rows[middle_row].icon.scheduling[next_i].w,
            opacity = 0
        }
        prev_hl:animate{duration = dur,opacity = 0}
        curr_hl:animate{duration = dur,opacity = 255,
            on_completed = function() 
                pull_in_right_to(show_grid__left_edge + (screen_w - margin) )
                animating_show_grid = false
            end
        }
        row_i = next_i
        --end
    end,
    [keys.Right] = function()
        if not finished_integrating_schedule or #channel_list == 0 or animating_show_grid or show_grid__left_edge >= 24*half_hour_len then return end
        animating_show_grid = true
        --row_i == #rows[middle_row].icon.scheduling then return end
        
        local len = #rows[middle_row].icon.scheduling
        if row_i >= len then
            
            push_out_right_to(show_grid__right_edge + 2*half_hour_len )
            show_grid_text:animate{
                duration = dur,
                x = show_grid_text.x - 2*half_hour_len,
            }
            curr_hl:animate{duration = dur,x = curr_hl.x + 2*half_hour_len,
                on_completed = function() 
                    pull_in_left_to(show_grid__right_edge - (screen_w - margin))
                    --move_left_vis_x(show_grid__right_edge - (screen_w - margin) )
                    animating_show_grid = false
                end
            }
            intervals_g:move_x_by(-2*half_hour_len)
            return
        end
        
        
        prev_hl:set{
            x       = curr_hl.x,
            y       = curr_hl.y,
            w       = curr_hl.w,
            h       = curr_hl.h,
            opacity = 255
        }
        prev_hl:animate{duration = dur,opacity = 0}
        next_i = row_i==len and len or row_i + 1
        local dx = rows[middle_row].icon.scheduling[next_i].x - show_grid__left_edge--show_grid.x
        --if trying to jump by 2 hours, then only jump by an hour, staying on the same show
        if dx >= 4*half_hour_len then
            push_out_right_to(show_grid__right_edge + 2*half_hour_len )
            next_i = row_i
            show_grid_text:animate{
                duration = dur,
                x = show_grid_text.x - 2*half_hour_len,
            }
            intervals_g:move_x_by(-2*half_hour_len)
        elseif dx >= half_hour_len then
            push_out_right_to(show_grid__right_edge + dx )
            show_grid_text:animate{
                duration = dur,
                x = show_grid_text.x - dx,
            }
            intervals_g:move_x_by(-dx)
        end
        curr_hl:set{
            x       = rows[middle_row].icon.scheduling[next_i].x,
            y       = rows[middle_row].y,
            w       = rows[middle_row].icon.scheduling[next_i].w,
            opacity = 0,
        }
        prev_hl:animate{duration = dur,opacity = 0}
        curr_hl:animate{duration = dur,opacity = 255,
            on_completed = function() 
                pull_in_left_to(show_grid__right_edge - (screen_w - margin))
                --move_left_vis_x(show_grid__right_edge - (screen_w - margin) )
                animating_show_grid = false
            end
        }
        
        row_i = next_i
        --[=[
        local channel = rows[middle_row].icon
        local scheduling = rows[middle_row].icon.scheduling
        --[[if  row_i == rows[middle_row].icon.right_i then
            row_i = row_i + 1
            channel.separators:add(scheduling[row_i].sep)
            channel.show_names:add(scheduling[row_i].show_name)
            channel.show_times:add(scheduling[row_i].show_time)
            show_grid:animate{duration = dur,x=(scheduling[row_i].x+scheduling[row_i].w)-(screen_w-margin) }
        else--]]
            row_i = row_i==1 and 1 or row_i - 1
            curr_hl:set{
                x       = rows[middle_row].icon.show_names.children[row_i].x-show_name_margin,
                y       = rows[middle_row].y,
                w       = rows[middle_row].icon.show_names.children[row_i].w+show_name_margin*2,
                opacity = 255
            }
            curr_hl:animate{duration = dur,opacity = 255,
                on_completed = function() 
                    animating_show_grid = false
                end
            }
        --end--]=]
    end,
    --]==]
    [keys.Up] = function()
        if not finished_integrating_schedule or #channel_list == 0 or animating_show_grid then return end
        animating_show_grid = true
        rows[1].icon = channel_list[top_i]
        rows[1].shows = channel_list[top_i].shows
        --rows[1].icon.x = 0
        rows[1].icon.y = rows[1].y+row_h/2
        rows[1].shows.y = rows[1].y+row_h/2
        show_grid_text:add(rows[1].shows)
        show_grid_icons:add(rows[1].icon)
        populate_row(rows[1])
        if not rows[1].icon.schedule_is_loaded then 
            --build_schedule_row(rows[1].icon)
        end
        
        
        prev_hl:set{
            x       = curr_hl.x,
            y       = curr_hl.y,
            w       = curr_hl.w,
            h       = curr_hl.h,
            opacity = 255
        }
        --local len = #rows[middle_row-1].icon.scheduling
        row_i = rows[middle_row-1].icon.left_i--row_i>len and len or row_i
        if #rows[middle_row-1].icon.scheduling == 0 then
            curr_hl:set{
                x       = show_grid__left_edge,-- -show_name_margin,
                y       = rows[middle_row-1].y,
                w       = screen_w - margin,-- +show_name_margin*2,
                h       = row_h,
                opacity = 0
            }
        else
            curr_hl:set{
                x       = rows[middle_row-1].icon.scheduling[row_i].x,-- -show_name_margin,
                y       = rows[middle_row-1].y,
                w       = rows[middle_row-1].icon.scheduling[row_i].w,-- +show_name_margin*2,
                h       = row_h,
                opacity = 0
            }
        end
        --dolater(function()
        show_grid:animate{
            duration = dur,
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
                rows[middle_row-1].scale = {1,.5}--{1,1080/720}
                --rows[middle_row-1].icon.y   = row_h/2
                rows[middle_row].y          = (middle_row-2)*row_h
                rows[middle_row].scale   = 1--{1,2*1080/720}
                --rows[middle_row].icon.y     = row_h
                curr_hl.y = rows[middle_row].y 
                for i = #rows,2,-1 do
                    rows[i].icon   = rows[i-1].icon
                    rows[i].shows   = rows[i-1].shows
                    rows[i].icon.y  = rows[i].y+ ((i == middle_row) and row_h or row_h/2)
                    rows[i].shows.y = rows[i].y+ ((i == middle_row) and row_h or row_h/2)
                end
                
                top_i        = wrap_i(top_i        - 1, channel_list)
                curr_channel = wrap_i(curr_channel - 1, channel_list)
                bottom_i     = wrap_i(bottom_i     - 1, channel_list)
                
                rows[#rows].icon:unparent()
                rows[#rows].shows:unparent()
                rows[#rows].icon.show_names:clear()
                rows[#rows].icon.show_times:clear()
                rows[#rows].icon.separators:clear()
                --rows[1].icon:unparent()
                rows[middle_row+1].icon.show_times:unparent()
                
                channel_hl.y = row_h*(middle_row-2)
                
            end
        }
        prev_hl:animate{duration = dur,opacity =   0,h=  row_h, y = (middle_row-1)*row_h}
        curr_hl:animate{duration = dur,opacity = 255,h=2*row_h}
        --expand the next column
        rows[middle_row-1].shows:add(rows[middle_row-1].icon.show_times)
        rows[middle_row-1].icon.show_times:animate{   duration = dur, opacity = 255,mode="EASE_IN_QUAD" }
        rows[middle_row-1].icon.separators:animate{   duration = dur,scale={1,2*row_h/sep_src.h} }
        rows[middle_row-1]:animate{   duration = dur, scale = {1,1}}--{1,2*1080/720}, }
        rows[middle_row-1].icon:animate{ duration = dur, y = (middle_row-2)*row_h, scale = {sel_scale,sel_scale} }
        rows[middle_row-1].shows:animate{ duration = dur, y = (middle_row-2)*row_h, }
        --rows[middle_row-1].icon:animate{ duration = dur, y = rows[middle_row-1].icon.y+row_h/2, }
        --contract the previously selected column
        --rows[middle_row]:animate{      duration = dur, y = (middle_row-1)*row_h, }
        rows[middle_row]:animate{   duration = dur, scale = {1,.5}, y = (middle_row-1)*row_h,}
        rows[middle_row].icon:animate{ duration = dur, y = (middle_row-1)*row_h+row_h/2, scale = {1,1} }
        rows[middle_row].shows:animate{ duration = dur, y = (middle_row-1)*row_h+row_h/2, }
        rows[middle_row].icon.show_times:animate{   duration = dur, opacity = 0,mode="EASE_OUT_QUAD" }
        rows[middle_row].icon.separators:animate{   duration = dur,scale={1,row_h/sep_src.h} }
        channel_hl:animate{   duration = dur,y=row_h*(middle_row-3) }
        
        --end)
    end,
    [keys.Down] = function()
        if not finished_integrating_schedule or #channel_list == 0 or animating_show_grid then return end
        animating_show_grid = true
        
        rows[#rows].icon  = channel_list[bottom_i]
        rows[#rows].shows = channel_list[bottom_i].shows
        --rows[#rows].icon.x = 0
        rows[#rows].icon.y  = rows[#rows].y+row_h/2
        rows[#rows].shows.y = rows[#rows].y+row_h/2
        show_grid_text:add( rows[#rows].shows)
        show_grid_icons:add(rows[#rows].icon)
        populate_row(rows[#rows])
        
        if not rows[#rows].icon.schedule_is_loaded then 
            --build_schedule_row(rows[#rows].icon)
        end
        
        prev_hl:set{
            x       = curr_hl.x,
            y       = curr_hl.y,
            w       = curr_hl.w,
            h       = curr_hl.h,
            opacity = 255
        }
        --local len = #rows[middle_row+1].icon.show_names.children
        row_i = rows[middle_row+1].icon.left_i--row_i>len and len or row_i
        
        if #rows[middle_row+1].icon.scheduling < 1 then
            curr_hl:set{
                x       = show_grid__left_edge,-- -show_name_margin,
                y       = rows[middle_row+1].y,
                w       = screen_w - margin,-- +show_name_margin*2,
                h       = row_h,
                opacity = 0
            }
        else
        if row_i > #rows[middle_row+1].icon.scheduling then error("not possible "..tostring(row_i).." "..tostring(#rows[middle_row-1].icon.scheduling)) end
            curr_hl:set{
                x       = rows[middle_row+1].icon.scheduling[row_i].x,-- -show_name_margin,
                y       = rows[middle_row+1].y,
                w       = rows[middle_row+1].icon.scheduling[row_i].w,-- +show_name_margin*2,
                h       = row_h,
                opacity = 0
            }
        end
        --dolater(function()
        show_grid:animate{
            duration = dur,
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
                --rows[middle_row].icon.y     = row_h
                rows[middle_row].scale   = 1--{1,2*1080/720}
                rows[middle_row+1].y        = middle_row*row_h
                rows[middle_row+1].scale = {1,.5}--{1,1080/720}
                --rows[middle_row+1].icon.y   = row_h/2
                curr_hl.y = rows[middle_row].y
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
                    rows[i].icon    = rows[i+1].icon
                    rows[i].shows   = rows[i+1].shows
                    --rows[i].icon.y = rows[i].y+row_h/2
                    rows[i].icon.y  = rows[i].y+ ((i == middle_row) and row_h or row_h/2)
                    rows[i].shows.y = rows[i].y+ ((i == middle_row) and row_h or row_h/2)
                end
                rows[1].icon:unparent()
                rows[1].shows:unparent()
                rows[1].icon.show_names:clear()
                rows[1].icon.show_times:clear()
                rows[1].icon.separators:clear()
                
                rows[middle_row-1].icon.show_times:unparent()
                
                channel_hl.y = row_h*(middle_row-2)
                
            end
        }
        
        
        prev_hl:animate{duration = dur,opacity = 0,h=row_h}
        curr_hl:animate{duration = dur,opacity = 255,h=2*row_h, y = (middle_row-1)*row_h}
        --expand the next column
        rows[middle_row+1].shows:add(rows[middle_row+1].icon.show_times)
        rows[middle_row+1].icon.show_times:animate{   duration = dur, opacity = 255,mode="EASE_IN_QUAD" }
        rows[middle_row+1]:animate{   duration = dur, scale = {1,1}, y = (middle_row-1)*row_h}
        rows[middle_row+1].icon:animate{ duration = dur, y = (middle_row-1)*row_h+row_h, scale = {sel_scale,sel_scale} }
        rows[middle_row+1].shows:animate{ duration = dur, y = (middle_row-1)*row_h+row_h, }
        rows[middle_row+1].icon.separators:animate{   duration = dur,scale={1,2*row_h/sep_src.h} }
        --contract the previously selected column
        rows[middle_row]:animate{   duration = dur, scale = {1,.5}}--{1,1080/720}, }
        rows[middle_row].icon:animate{ duration = dur, y = (middle_row-2)*row_h+row_h/2, scale = {1,1} }
        rows[middle_row].shows:animate{ duration = dur, y = (middle_row-2)*row_h+row_h/2, }
        rows[middle_row].icon.show_times:animate{   duration = dur, opacity = 0,mode="EASE_OUT_QUAD" }
        rows[middle_row].icon.separators:animate{   duration = dur,scale={1,row_h/sep_src.h} }
        channel_hl:animate{   duration = dur, y=row_h*(middle_row-1) }
        --end)
    end,
    [keys.BACK] = function()
        if animating_back_to_prev_menu then return end
        animating_back_to_prev_menu = true
        menu_layer:add(main_menu)
        instance:animate{
            duration = 300,
            z = 300,
            opacity = 0,
            on_completed = function() 
                instance:unparent() 
                animating_back_to_prev_menu = false 
                show_grid_text:unparent()
            end
        }
        main_menu:grab_key_focus()
        main_menu:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
        backdrop:animate_dots()
        
    end,
    [keys.VOL_UP]   = raise_volume,
    [keys.VOL_DOWN] = lower_volume,
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
        on_completed = function()
            
            show_grid:add(show_grid_text)
            show_grid_text:lower_to_bottom()
            show_grid_bg:lower_to_bottom()
        end
    }
end
--------------------------------------------------------------------
instance:add(
    Rectangle{
        name = "epg_bg",
        w = screen_w,
        h = screen_h,
        color = "808080",
    },
    show_grid,
    timeline_header,
    Rectangle{
        name = "top_left bg",
        w = margin-5,
        h = heading_h,
        color = "black",
    },
    top_left,
    Rectangle{
        name = "rule",
        w = screen_w,
        h = 7,
        y = heading_h - 7,
        color = "b0b0b0",
    }
)

return instance