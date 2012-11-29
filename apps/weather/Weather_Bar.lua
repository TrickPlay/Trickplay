local MINI_BAR_X = 110
local bar_side_w = 61
local bar_side_h = 195

local BAR_X = 166
local BAR_Y = 873
local CURR_TEMP_X = 74
local CURR_TEMP_Y = 71
local LOCATION_X  = 290
local LOCATION_Y  = 62
local HI_LO_X     = 290
local HI_LO_Y     = 104
local BLURB_X     = 775
local BLURB_Y     = 45
local BAR_SPACE   = 40
local MINI_BAR_MIN_W = 500
local FULL_BAR_W     = screen_w-MINI_BAR_X*2-bar_side_w*2--1478
local COLOR_BUTTON_SPACING = 19

local FONT          = "DejaVu Sans "
local LARGE_TEMP_SZ = "97px"
local LOCATION_SZ   = "40px"
local HI_LO_SZ      = "42px"
local BLURB_SZ      = "26px"
local DAY_SZ        = "24px"
local ZIP_SZ        = "36px"
local ZIP_PROMPT    = "18px"
local DAY_HI_LO_SZ  = "30px"
local DEG           = "°"

local HI_TEMP_COLOR  = {209,209,209}
local LO_TEMP_COLOR  = {117,117,117}
local TEXT_COLOR     = {187,187,187}
local SHADOW_COLOR   = {  0,  0,  0}
local SHADOW_OPACITY =  255   *  .4

local FULL_BAR_X = 166
local function make_five_day(fday)
    
    
    local c = Canvas(170*5,300)
    c:begin_painting()
    local icon 
    ---[[
    for i = 1,5 do
        
        c:new_path()
        c:move_to(39+170*(i-1),0)
        if i == 1 then
            c:text_path(FONT..DAY_SZ,fday[i+1] and fday[i+1].icon and "Tomorrow" or "")
        else
            c:text_path(FONT..DAY_SZ,fday[i+1] and fday[i+1].date and fday[i+1].date.weekday or "")
        end
        c:set_source_color(TEXT_COLOR)
        c:fill(true)
        
        icon = Bitmap(imgs.icons[fday[i+1] and fday[i+1].icon or "unknown"].src)
        
        c:new_path()
        c:move_to(7+170*(i-1),12)
        c:line_to(7+170*(i-1)+icon.w,12)
        c:line_to(7+170*(i-1)+icon.w,12+icon.h)
        c:line_to(7+170*(i-1),12+icon.h)
        c:line_to(7+170*(i-1),12)
        c:set_source_bitmap(icon,7+170*(i-1),12)
        c:fill(true)
        
        c:new_path()
        c:move_to(36+170*(i-1),73)
        c:text_path(FONT.."Bold normal "..DAY_HI_LO_SZ,(fday[i+1] and fday[i+1].high and fday[i+1].high.fahrenheit..DEG) or "")
        c:set_source_color(HI_TEMP_COLOR)
        c:fill(true)
        
        c:new_path()
        c:move_to(100+170*(i-1),73)
        c:text_path(FONT.."Bold normal "..DAY_HI_LO_SZ,(fday[i+1] and fday[i+1].low and fday[i+1].low.fahrenheit.. DEG) or "")
        c:set_source_color(LO_TEMP_COLOR)
        c:fill(true)
        
    end
    --]]
    c:finish_painting()
    return c:Image{name="5 day blit",x = 750,y = 45}

end

local function make_curr_temps(curr_temp_tbl,fday,w,zip,city_name,state)

    local c = Canvas(w,300)
    c:begin_painting()
    
    
    --Curr temp
    c:new_path()
    c:move_to(0+2,CURR_TEMP_Y-30+2)
    c:text_path(
        FONT.."Condensed Bold normal "..LARGE_TEMP_SZ,
        (
            curr_temp_tbl.current_observation and
            curr_temp_tbl.current_observation.temp_f and
            string.format("%d",curr_temp_tbl.current_observation.temp_f) or "--"
        )..DEG
    )
    c:set_source_color({0,0,0,255*.4})
    c:fill(true) 
    
    c:new_path()
    c:move_to(0,CURR_TEMP_Y-30)
    c:text_path(
        FONT.."Condensed Bold normal "..LARGE_TEMP_SZ,
        (
            curr_temp_tbl.current_observation and
            curr_temp_tbl.current_observation.temp_f and
            string.format("%d",curr_temp_tbl.current_observation.temp_f) or "--"
        )..DEG
    )
    c:set_source_color(HI_TEMP_COLOR)
    c:fill(true)
    
    
    --Hi temp
    c:new_path()
    c:move_to(HI_LO_X-CURR_TEMP_X+2,HI_LO_Y-10+2)
    c:text_path(FONT.."Condensed Bold normal "..HI_LO_SZ,(fday.high and fday.high.fahrenheit or "--")..DEG)
    c:set_source_color({0,0,0,255*.4})
    c:fill(true)
    
    c:new_path()
    c:move_to(HI_LO_X-CURR_TEMP_X,HI_LO_Y-10)
    c:text_path(FONT.."Condensed Bold normal "..HI_LO_SZ,(fday.high and fday.high.fahrenheit or "--")..DEG)
    c:set_source_color(HI_TEMP_COLOR)
    c:fill(true)
    
    
    --Lo temp
    c:new_path()
    c:move_to(HI_LO_X-CURR_TEMP_X+80+2,HI_LO_Y-10+2)
    c:text_path(FONT.."Condensed Bold normal "..HI_LO_SZ,(fday.low and fday.low.fahrenheit or "--").. DEG)
    c:set_source_color({0,0,0,255*.4})
    c:fill(true)
    
    c:new_path()
    c:move_to(HI_LO_X-CURR_TEMP_X+80,HI_LO_Y-10)
    c:text_path(FONT.."Condensed Bold normal "..HI_LO_SZ,(fday.low and fday.low.fahrenheit or "--").. DEG)
    c:set_source_color(LO_TEMP_COLOR)
    c:fill(true)
    
    
    
    local regexed_name = ""
    for i = 1, # city_name do
        
        if i == 1 or city_name:sub(i-1,i-1) == " " then
            
            regexed_name = regexed_name .. city_name:sub(i,i):upper()
            
        else
            
            regexed_name = regexed_name .. city_name:sub(i,i):lower()
            
        end
        
    end
    
    --Location
    c:new_path()
    c:move_to(LOCATION_X-CURR_TEMP_X+2,LOCATION_Y-10+2)
    c:text_path(
        FONT..LOCATION_SZ,
        regexed_name..", "..state
    )
    c:set_source_color({0,0,0,255*.4})
    c:fill(true)
    
    c:new_path()
    c:move_to(LOCATION_X-CURR_TEMP_X,LOCATION_Y-10)
    c:text_path(
        FONT..LOCATION_SZ,
        regexed_name..", "..state
    )
    c:set_source_color(TEXT_COLOR)
    c:fill(true)
    
    c:finish_painting()
    return c:Image{name="Curr Temp Info",x = CURR_TEMP_X,y = 0}

end

function Make_Bar(loc,wu_data,index, master)
    --local curr_state = "1_DAY"
    local bar_index = index
    local mini_width = MINI_BAR_MIN_W
    local master_i = nil
    if master then
        master_i = 1
    end
    
    --Visual Components
    local bar = Group{
        name = loc .." Weather Bar",
        opacity = 0,
        x = MINI_BAR_X,
        y = BAR_Y,
        children={
            Clone{
                name       = "left",
                source     = imgs.bar.side,
                y_rotation = {180,0,0},
                x          = bar_side_w
            },
            Clone{
                name   = "mid",
                source = imgs.bar.mid,
                tile   = {true,false},
                x      = bar_side_w,
                w      = 408,
            },
            Clone{
                name   = "right",
                source = imgs.bar.side,
                x      = bar_side_w + 408
            },
        }
    }
    bar.base_name = bar.name
    bar.curr_condition = "Unknown"
    bar.local_time_of_day = "DAY"
    bar.get_mini_w = function(self)
        return mini_width
    end
    function bar.set_bar_index(i)
        bar_index=i
    end
    
    local full_bar  = Group{name="Full Bar",opacity=0}
    local mini_bar  = Group{name="Mini Bar"}
    local zip_entry = Group{name="zip_group",opacity=0}
    local five_day  = Group{
        name        = "Five Day",
        x           = 750,
        y           = 45,
        opacity     = 0
    }
    
    --Base Bar Elements
    local arrow_l = Clone{source = imgs.arrows.left}
    arrow_l.x=34-arrow_l.w/2
    arrow_l.y=bar_side_h/2-arrow_l.h/2
    local arrow_r = Clone{source = imgs.arrows.right}
    arrow_r.y=bar_side_h/2-arrow_r.h/2
    
    
    local mesg = Shadow_Text{
        name  = "Location",
        x     = LOCATION_X,
        y     = LOCATION_Y-10,
        font  = FONT..DAY_HI_LO_SZ,
        color = HI_TEMP_COLOR,
        text  = "Getting Weather..."
    }
    if master then
        mesg.text="TEST BAR"
    end
    
    --Color Buttons
    local green_button_mini = Clone{
        name    = "green button",
        source  = imgs.color_button.green_more,
        x       = MINI_BAR_X+MINI_BAR_MIN_W-83,
        y       = 33,
    }
    local green_button_full = Clone{
        name   = "green button",
        source = imgs.color_button.green_less,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33
    }
    local blue_button_today = Clone{
        name   = "1 day",
        source = imgs.color_button.blue_5_day,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33+40,
        
    }
    local blue_button_5_day = Clone{
        name   = "5 day",
        source = imgs.color_button.blue_today,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33+40,
        --opacity=0
    }
    local yellow_button = Clone{
        source = imgs.color_button.yellow,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33+40*2
    }
    
    --Full Bar Elements
    local blurb_txt = Text{
        name  = "Blurb Text",
        x     = BLURB_X,
        y     = BLURB_Y-10,
        w     = FULL_BAR_W - BLURB_X + 20,
        font  = FONT..BLURB_SZ,
        color = TEXT_COLOR,
        wrap  = true,
        text  = "",
    }
    
    local sun_b   = Clone{source=imgs.load.sun_base}
    local flare_l = Clone{source=imgs.load.light_flare}
    flare_l.position={-10+flare_l.w/2,-10+flare_l.h/2}
    flare_l.anchor_point={flare_l.w/2,flare_l.h/2}
    local flare_d = Clone{source=imgs.load.dark_flare}
    flare_d.position={-8+flare_d.w/2,-10+flare_d.h/2}
    flare_d.anchor_point={flare_d.w/2,flare_d.h/2}
    local loading_sun = Group{
        x=100,
        y=50,
    }
    local loading_error = Clone{source=imgs.load.error,opacity=0,x=100,y=50}
    loading_sun:add(flare_d,sun_b,flare_l)
    
    mini_width = mesg.x+mesg.w-bar.x+75
    --[[
    if curr_state == "MINI" then
        --bar:find_child("mid").scale={mini_width,1}
        bar:find_child("mid").w=mini_width
        bar:find_child("right").x=bar_side_w + mini_width
    end
    --]]
    
    green_button_mini.x = MINI_BAR_X + mini_width -bar_side_w/2- green_button_mini.w
    arrow_r.x = MINI_BAR_X + mini_width -bar_side_w/2+1
    
    
    local zip_code_prompt = Text{
        name  = "Zip Prompt",
        x     = 1098+(41+6),
        y     = 61,
        font  = FONT.."Bold normal "..ZIP_PROMPT,
        color = TEXT_COLOR,
        text  = "Enter a Zip Code"
    }
    local us_only = Text{
        name  = "us only",
        x     = zip_code_prompt.x+zip_code_prompt.w+10,
        y     = 61,
        font  = FONT.."Oblique "..ZIP_PROMPT,
        color = TEXT_COLOR,
        text  = "(US only)"
    }
    
    local zip_backing = {}
    local digits = {}
    local zip_focus = 1
    
    for i = 1,5 do
        zip_backing[i] = Rectangle{
            size={35,41},
            position={zip_code_prompt.x+(41+6)*(i-1),89},
            color={255,255,255}
        }
        digits[i] = Text{
            text="",
            font=FONT.."Condensed Bold normal "..ZIP_SZ,
            color={0,0,0},
        }
        digits[i].anchor_point = {digits[i].w/2,digits[i].h/2}
        digits[i].x = zip_code_prompt.x+(41+6)*(i-1) + 35/2
        digits[i].y = 89 + 41/2
        zip_entry:add(zip_backing[i],digits[i])
    end
    zip_backing[1].color = {140,140,140}
    
    --Hierarchy of groups
    zip_entry:add(zip_code_prompt,us_only)
    zip_entry:hide()
    
    full_bar:add(blurb_txt,five_day,green_button_full,blue_button_5_day,yellow_button,blue_button_today,zip_entry)
    full_bar:hide()

    five_day:hide()
    mini_bar:add(green_button_mini)
    
    bar:add(arrow_l,arrow_r,mesg,--[[curr_temp,hi_temp,lo_temp,location,]]full_bar,mini_bar,loading_sun,loading_error)
    local pws_tbl
    local f_tbl
    
    local bar_mid = bar:find_child("mid")
    local bar_right = bar:find_child("right")
    
    local anim_state
    local zip_on_key_down,general_on_key_down
    local make_state = function()
        
        local prev_state = anim_state ~= nil and anim_state.state or "1_DAY"
        
        if anim_state then
            
            anim_state.timeline:pause()
            
        end
        
        local on_started = {
            ["MINI"] = function()
                mini_bar:show()
                bar.on_key_down = general_on_key_down
            end,
            ["1_DAY"] = function()
                full_bar:show()
                blurb_txt:show()
                bar.on_key_down = general_on_key_down
            end,
            ["5_DAY"] = function()
                full_bar:show()
                five_day:show()
                bar.on_key_down = general_on_key_down
            end,
            ["ZIP_ENTRY"] = function()
                full_bar:show()
                zip_entry:show()
                
                for i = 1,5 do
                    digits[i].text       = ""
                    zip_backing[i].color = {255,255,255}
                end
                zip_backing[1].color = {140,140,140}
                
                zip_focus            = 1
                zip_code_prompt.text = "Enter a Zip Code"
                us_only.text         = "(US only)"
                
                bar.on_key_down = zip_on_key_down
            end,
        }
        local on_completed = {
            ["MINI"] = function()
                full_bar:hide()
                blurb_txt:hide()
                five_day:hide()
                zip_entry:hide()
            end,
            ["1_DAY"] = function()
                mini_bar:hide()
                five_day:hide()
                zip_entry:hide()
            end,
            ["5_DAY"] = function()
                mini_bar:hide()
                blurb_txt:hide()
                zip_entry:hide()
            end,
            ["ZIP_ENTRY"] = function()
                mini_bar:hide()
                blurb_txt:hide()
                five_day:hide()
            end,
        }
        
        
        
        local trans_to_full = {
            {full_bar,"opacity","LINEAR", 255, 0.9, 0.0},
            {mini_bar,"opacity","LINEAR",   0, 0.0, 0.9},
            {bar_mid,"w",FULL_BAR_W},
            {bar_right,"x",bar_side_w + FULL_BAR_W},
            {arrow_r,"x",MINI_BAR_X + FULL_BAR_W -bar_side_w/2+1},
            --{left_faux_bar,"x","EASE_OUT_BACK",0},
            --{right_faux_bar,"x","EASE_OUT_BACK",0},
        }
        
        anim_state= AnimationState{
            duration = 600,
            transitions = {
                {
                    source = "*",
                    target = "MINI",
                    keys = {
                        {full_bar,"opacity","LINEAR",   0, 0.0, 0.9},
                        {mini_bar,"opacity","LINEAR", 255, 0.9, 0.0},
                        {bar_mid,  "w",mini_width},
                        {bar_right,"x",bar_side_w + mini_width},
                        {arrow_r,  "x",MINI_BAR_X + mini_width -bar_side_w/2+1},
                        --{left_faux_bar,"x",-faux_len-bar_side_w},
                        --{right_faux_bar,"x",faux_len+bar_side_w},
                    },
                },
                {
                    source = "*",
                    target = "1_DAY",
                    keys = {
                        {five_day, "opacity",   0},
                        {blurb_txt,"opacity", 255},
                        {blue_button_today,"opacity", 255},
                        {zip_entry,"opacity",   0},
                        unpack(trans_to_full)
                    },
                },
                {
                    source = "*",
                    target = "5_DAY",
                    keys = {
                        {five_day, "opacity", 255},
                        {blurb_txt,"opacity",   0},
                        {blue_button_today,"opacity", 0},
                        {zip_entry,"opacity",   0},
                        unpack(trans_to_full)
                    },
                },
                {
                    source = "*",
                    target = "ZIP_ENTRY",
                    keys = {
                        {five_day, "opacity",   0},
                        {blurb_txt,"opacity",   0},
                        {blue_button_today,"opacity", 255},
                        {zip_entry,"opacity", 255},
                        unpack(trans_to_full)
                    },
                },
            }
        }
        
        anim_state.timeline.on_started = function()
            bar.name = bar.base_name.." - "..anim_state.state
            on_started[anim_state.state]()
        end
        
        anim_state.timeline.on_completed = function()
            on_completed[anim_state.state]()
        end
        --anim_state:warp("MINI")
        anim_state.state = prev_state
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    --Callback to the Weather query
    bar.update = function(response)
        
        
        if type(response) == "string" then
            
            mesg.text = response
            
        elseif type(response) == "table" then
            
            --dumptable(response)
            
            if response.response.error then
                
                mesg.text = "Experiencing problems with Weather Underground."
                bar.loading_sun:stop()
                return
            end
            
            local fday = type(response.forecast) == "table" and
                type(response.forecast.txt_forecast) == "table" and
                type(response.forecast.txt_forecast.forecastday) == "table" and
                type(response.forecast.txt_forecast.forecastday[1]) == "table" and
                response.forecast.txt_forecast.forecastday[1] or {}
            
            if type(response.current_observation) == "table" and type(response.current_observation.observation_time) == "string" then
                local t = {string.match( response.current_observation.observation_time ,
                    "^.* (%d*):%d* (%u%u) .*" )}
                
                
                t[1] = tonumber(t[1])
                
                if t[1] >= 7 and t[2] =="PM" and t[1] ~= 12 or (t[1] <= 5 or t[1] == 12) and t[2] =="AM" then
                    
                    bar.local_time_of_day = "NIGHT"
                    
                else
                    
                    bar.local_time_of_day = "DAY"
                    
                end
            else
                bar.local_time_of_day = "DAY"
            end
            
            blurb_txt.text =fday.fcttext or "No forecast for today"
            
            if blurb_txt.h > yellow_button.y+yellow_button.h-blurb_txt.y then
                blurb_txt.clip = {0,0,blurb_txt.w,100}--yellow_button.y+yellow_button.h-blurb_txt.y}
                
                bar.blurb_scroll.dy = blurb_txt.h-blurb_txt.clip[4]
                bar.blurb_scroll.duration = bar.blurb_scroll.dy/8*1000
                
                bar.blurb_scroll:start()
                
            end
            
            bar.curr_condition = type(response.current_observation) == "table" and response.current_observation.weather
            
            five_day:unparent()
            
            five_day = make_five_day(
                type(response.forecast) == "table" and
                type(response.forecast.simpleforecast) == "table" and
                response.forecast.simpleforecast.forecastday or
                {}
            )
            
            full_bar:add(five_day)
            if anim_state and anim_state.state ~= "5_DAY" then
                five_day.opacity=0
                five_day:hide()
            end
            
            local city_name = (type(response.current_observation) == "table" and
                    type(response.current_observation.display_location) == "table" and
                    response.current_observation.display_location.city or loc)
            
            local state = (type(response.current_observation) == "table" and
                    type(response.current_observation.display_location) == "table" and
                    response.current_observation.display_location.state or "USA")
            
            
            
            mini_width = Text{
                font=FONT.."Condensed Bold normal "..LOCATION_SZ,
                text=city_name..", "..state
            }.w + LOCATION_X - MINI_BAR_X + 100
            
            if mini_width > BLURB_X-40 then
                city_name = string.sub(city_name,1,10).."... "
                mini_width = Text{
                    font=FONT.."Condensed Bold normal "..LOCATION_SZ,
                    text=city_name..", "..state
                }.w + LOCATION_X - MINI_BAR_X + 100
            end
            if mesg then
                mesg:unparent()
                mesg=nil
            end
            bar:add(
                make_curr_temps(
                    response,
                    type(response.forecast) == "table" and
                    type(response.forecast.simpleforecast) == "table" and
                    response.forecast.simpleforecast.forecastday[1] or {},
                    mini_width,
                    loc,
                    city_name,
                    state
                )
            )
            if anim_state and anim_state.state == "MINI" then
                
                --bar:find_child("mid").scale = {mini_width,1}
                bar:find_child("mid").w   = mini_width
                bar:find_child("right").x = bar_side_w + mini_width
                
                arrow_r.x = MINI_BAR_X + mini_width -bar_side_w/2+1
            else
                arrow_r.x = MINI_BAR_X + FULL_BAR_W -bar_side_w/2+1
            end
            green_button_mini.x = MINI_BAR_X+mini_width -83
            
            if bar_i == bar_index then
                time_of_day = bar.local_time_of_day
                
                conditions[bar.curr_condition]()
                
                if blurb_txt.has_clip and full_bar.opacity ~= 0 and blurb_txt.opacity ~= 0 then
                    --animate_list[bar.func_tbls.blurb] = bar
                    bar.blurb_scroll:start()
                end
            end
            
            --animate_list[bar.func_tbls.loading_sun_fade_out] = bar
            bar.loading_sun_fade_out:start()
            
            make_state()--"mini_width" probably changed, need to remake the animation state
            
        else
        end
        
    end
    
    local bar_dist = 1905-bar_side_w-MINI_BAR_X
    local next_i = bar_index
    
    local flag_for_deletion = false
    
    local function delete_me()
        
        table.remove(bars,bar_index)
        table.remove(locations,bar_index)
        
        for i,v in ipairs(bars) do
            bars[i].set_bar_index(i)
        end
        
        bar:unparent()
        
        
    end
    
    local moving_to_new_bar = function()
        bar_i  = next_i
        screen:grab_key_focus()
        current_bar:show()
        current_bar.warp_to_state(anim_state.state)
        time_of_day = current_bar.local_time_of_day
        conditions[current_bar.curr_condition]()
    end
    
    
    bar.mini_move_left = Timeline{
        duration = 500,
        on_started = function()
            current_bar = bars[next_i]
            current_bar.x = MINI_BAR_X - bar_dist/2
            current_bar.opacity = 255
            
            moving_to_new_bar()
        end,
        on_new_frame = function(tl,ms,p)
            
            bar.x = MINI_BAR_X + bar_dist/2*p
            bar.opacity=255*(1-p)
            
            bars[next_i].x = MINI_BAR_X - bar_dist/2 + bar_dist/2*p
            
        end,
        on_completed = function()
            bars[next_i]:grab_key_focus()
            bar:hide()
        end
    }
    bar.full_move_left = Timeline{
        duration = 500,
        on_started = function()
            current_bar = bars[next_i]
            current_bar.x = MINI_BAR_X + bar_dist
            current_bar.opacity = 255
            --left_faux_bar.x = -bar_dist
            
            moving_to_new_bar()
        end,
        on_new_frame = function(tl,ms,p)
            
            bar.x = MINI_BAR_X + (bar_dist+150)*p
            
            bars[next_i].x = MINI_BAR_X - (bar_dist+150) + (bar_dist+150)*p
            
            --right_faux_bar.x = bar_dist + bar_dist*p
            
            --left_faux_bar.x = -bar_dist  + bar_dist*p
            
        end,
        on_completed = function()
            bar.opacity=0
            bar:hide()
            --right_faux_bar.x = 0
            --left_faux_bar.x  = 0
            bars[next_i]:grab_key_focus()
        end
    }
    bar.mini_move_right = Timeline{
        duration = 500,
        on_started = function()
            current_bar = bars[next_i]
            current_bar.x = MINI_BAR_X + bar_dist/2
            current_bar.opacity = 0
            
            moving_to_new_bar()
        end,
        on_new_frame = function(tl,ms,p)
            bar.x = MINI_BAR_X - bar_dist/2*p
            bars[next_i].opacity=255*(p)
            
            bars[next_i].x = MINI_BAR_X + bar_dist/2 - bar_dist/2*p
        end,
        on_completed = function()
            bars[next_i]:grab_key_focus()
            bar:hide()
            
            if flag_for_deletion then delete_me() end
            
        end
    }
    bar.full_move_right = Timeline{
        duration = 500,
        on_started = function()
            current_bar = bars[next_i]
            current_bar.x = MINI_BAR_X + bar_dist
            current_bar.opacity = 255
            --right_faux_bar.x = bar_dist
            
            moving_to_new_bar()
        end,
        on_new_frame = function(tl,ms,p)
            bar.x = MINI_BAR_X - (bar_dist+150)*p
            
            bars[next_i].x = MINI_BAR_X + (bar_dist+150) - (bar_dist+150)*p
            
            --right_faux_bar.x = bar_dist - bar_dist*p
            
            --left_faux_bar.x = - bar_dist*p
        end,
        on_completed = function()
            bar.opacity=0
            bar:hide()
            --right_faux_bar.x = 0
            --left_faux_bar.x = 0
            bars[next_i]:grab_key_focus()
            
            if flag_for_deletion then delete_me() end
            
        end
    }
    local s
    local zip_ellipsis_base_text
    local zip_ellipsis_count = 0 
    local zip_ellipsis_max = 5
    bar.zip_ellipsis = Timer{
        interval = 1500/4,
        on_timer = function(self)
            
            s = zip_ellipsis_base_text
            
            zip_ellipsis_count = (zip_ellipsis_count+1)%zip_ellipsis_max
            
            for i = 0, zip_ellipsis_count do s = s.."." end
            
            zip_code_prompt.text = s
            
        end
    }
    bar.zip_ellipsis:stop()
    
    bar.loading_sun = Timeline{
        duration = 8000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            flare_l.z_rotation = {360*p,0,0}
            flare_d.z_rotation = {360*p,0,0}
        end
    }
    bar.loading_sun_fade_out = Timeline{
        duration = 500,
        on_new_frame = function(tl,ms,p)
            loading_sun.opacity = 255*(1-p)
        end,
        on_completed = function()
            bar.loading_sun:stop()
            loading_sun:unparent()
            loading_sun = nil
            flare_d = nil
            flare_l = nil
            sun_b   = nil
            bar.loading_sun = nil
            bar.loading_sun_fade_out = nil
        end
    }
    bar.blurb_scroll = Timeline{
        duration = 30000,
        loop = true,
        on_new_frame = function(tl,ms,p)
            if p < .9 then
                p = p/.9
                blurb_txt.y = BLURB_Y-tl.dy*(.5-.5*math.cos(math.pi*p))
                blurb_txt.clip = {
                    0,
                    tl.dy*(.5-.5*math.cos(math.pi*p)),
                    blurb_txt.w,
                    100--yellow_button.y+yellow_button.h-blurb_txt.y
                }
            else
                p = (p-.9)/.1
                blurb_txt.y = BLURB_Y-tl.dy*(.5-.5*math.cos(math.pi*p+math.pi))
                blurb_txt.clip = {
                    0,
                    tl.dy*(.5-.5*math.cos(math.pi*p+math.pi)),
                    blurb_txt.w,
                    90--yellow_button.y+yellow_button.h-blurb_txt.y
                }
                
            end
        end
    }
    
    --Key Handler
    local bar_keys
    bar_keys = {
        [keys.Up]     = function()
            
            if master_i ~= nil then
                screen:grab_key_focus()
                master_i = (master_i-2)%(#all_anims) + 1
                bar.curr_condition = all_anims[master_i]
                conditions[bar.curr_condition]()
                mesg.text = bar.curr_condition..", USA"
                --animate_list[bar.func_tbls.wait_500]=bar
                dolater(500,function() bar:grab_key_focus() end)
                mini_width = mesg.w + mesg.x - MINI_BAR_X + 100
                if "MINI" == anim_state.state then
                    --bar:find_child("mid").scale = {mini_width,1}
                    bar:find_child("mid").w   = mini_width
                    bar:find_child("right").x = bar_side_w + mini_width
                    green_button_mini.x = MINI_BAR_X+mini_width -83
                    arrow_r.x = MINI_BAR_X + mini_width -bar_side_w/2+1
                end
                
            end
            
        end,
        [keys.Down]   = function()
            
            if  master_i ~= nil then
                screen:grab_key_focus()
                master_i = master_i%(#all_anims) + 1
                bar.curr_condition = all_anims[master_i]
                conditions[bar.curr_condition]()
                mesg.text = bar.curr_condition..", USA"
                --animate_list[bar.func_tbls.wait_500]=bar
                dolater(500,function() bar:grab_key_focus() end)
                
                mini_width = mesg.w + mesg.x - MINI_BAR_X + 100
                if "MINI" == anim_state.state then
                    --bar:find_child("mid").scale = {mini_width,1}
                    bar:find_child("mid").w   = mini_width
                    bar:find_child("right").x = bar_side_w + mini_width
                    green_button_mini.x = MINI_BAR_X+mini_width -83
                    arrow_r.x = MINI_BAR_X + mini_width -bar_side_w/2+1
                end
                
            end
            
        end,
        [keys.Left]   = function()
            if #bars == 1 then return end
            
            next_i = (bar_index-2) % (# bars) + 1
            
            
            if anim_state.state == "MINI" then
                bar.mini_move_left:start()
            else
                bar.full_move_left:start()
            end
        end,
        [keys.Right]  = function()
            
            if #bars == 1 then return end
            
            next_i = (bar_index) % (# bars) + 1
            
            
            if anim_state.state == "MINI" then
                bar.mini_move_right:start()
            else
                bar.full_move_right:start()
            end
        end,
        [keys.BLUE]   = function()
            
            --if bar_state is MINI, then pressing BLUE is ignored
            if anim_state.state == "MINI" then
                
                return
                
            --if bar_state is 5_DAY, then go to 1_DAY
            elseif anim_state.state == "5_DAY" then
                
                --bar_state:change_state_to("1_DAY")
                anim_state.state = "1_DAY"
                
            --if bar_state is 1_DAY, then go to 5_DAY
            elseif anim_state.state == "1_DAY" then
                
                --bar_state:change_state_to("5_DAY")
                anim_state.state = "5_DAY"
                
            --if bar_state is ZIP_ENTRY, then go to 1_DAY
            elseif anim_state.state == "ZIP_ENTRY" then
                
                --bar_state:change_state_to("1_DAY")
                anim_state.state = "1_DAY"
                
            end
        end,
        [keys.RED]    = function()
            if #bars == 1 then return end
            
            flag_for_deletion = true
            
            bar_keys[keys.Right]()
            --[[
            table.remove(bars,bar_index)
            table.remove(locations,bar_index)
            
            for i,v in ipairs(bars) do
                bars[i].set_bar_index(i)
            end
            
            next_i = 1
            
            
            if mini then
                bar.mini_move_right:start()
            else
                bar.full_move_right:start()
            end
            --]]
        end,
        [keys.GREEN]  = function()
            
            --if bar_state is MINI, then pressing BLUE is ignored
            if "MINI" == anim_state.state  then
                
                --bar_state:change_state_to("1_DAY")
                anim_state.state = "1_DAY"
                
            --if bar_state is anything else, then go to MINI
            else
                
                --bar_state:change_state_to("MINI")
                anim_state.state = "MINI"
                
            end
        end,
        [keys.YELLOW] = function()
            
            --if bar_state is MINI, then pressing BLUE is ignored
            if "MINI" == anim_state.state  then
                
                return
                
            --if bar_state is anything else then go to ZIP_ENTRY
            else
                
                --bar_state:change_state_to("ZIP_ENTRY")
                anim_state.state = "ZIP_ENTRY"
                
            end
        end,
    }
    
    general_on_key_down = function(self,k)
        return bar_keys[k] and bar_keys[k]()
    end
    
    local zip_search_cancel_obj
    local zip_keys = {
        [keys.GREEN]  = function()
            
            anim_state.state = "1_DAY"
            
        end,
        [keys.BLUE]  = function()
            
            anim_state.state = "5_DAY"
            
        end,
        [keys.RED]    = function()
            
            zip_backing[zip_focus].color={255,255,255}
            zip_focus = zip_focus - 1
            if zip_focus == 0 then
                zip_focus = #zip_backing
                
            end
            digits[zip_focus].text = ""
            
            
            zip_backing[zip_focus].color = {140,140,140}
            
        end,
        [keys.Right]  = function()
            
            if zip_focus <= 5 then zip_backing[zip_focus].color={255,255,255} end
            
            zip_focus = (zip_focus) % (# zip_backing) + 1
            
            zip_backing[zip_focus].color = {140,140,140}
            
        end,
        [keys.Left]   = function()
            
            if zip_focus <= #zip_backing then
                zip_backing[zip_focus].color={255,255,255}
            end
            
            zip_focus = (zip_focus-2) % (# zip_backing) + 1
            
            zip_backing[zip_focus].color = {140,140,140}
            
        end,
        
    }
    local zip_entry_make_bar = function(zip,make_bar_param,master_i)
        zip_code_prompt.text = "Success"
        table.insert(locations,zip)
        table.insert(bars,Make_Bar(zip,make_bar_param,#locations,master_i))
        next_i = #bars
        screen:add(bars[next_i])
        bar.go_to_state("1_DAY")
        bar_state:change_state_to("1_DAY")
        bar.full_move_right:start()
    end
    for i = 0,9 do
        zip_keys[keys[i..""]] = function()
            
            --enter the digit
            digits[zip_focus]:set{
                text = i,
                x = zip_code_prompt.x+(41+6)*(zip_focus-1) + 35/2,
                y = 89 + 41/2,
            }
            digits[zip_focus].anchor_point = {digits[zip_focus].w/2,digits[zip_focus].h/2}
            zip_backing[zip_focus].color={255,255,255}
            
            --inc
            zip_focus = zip_focus + 1
            
            --if entered the last digit
            if zip_focus == #zip_backing + 1  then
                zip_focus = 1
                
                local zip =
                    digits[1].text..
                    digits[2].text..
                    digits[3].text..
                    digits[4].text..
                    digits[5].text
                
                us_only.text=""
                
                if zip == "00000" then
                    
                    --create the new bar
                    zip_entry_make_bar(zip,zip,true)
                    
                else
                    
                    zip_ellipsis_base_text = "Searching"
                    
                    bar.zip_ellipsis:start()
                    
                    zip_search_cancel_obj = lookup_zipcode(zip,function(response)
                        
                        if type(response) == "table" then
                            
                            zip_search_cancel_obj = nil
                            
                            bar.zip_ellipsis:stop()
                            
                            if response.response.error and response.response.error.type == "querynotfound" then
                                
                                zip_code_prompt.text = "No Search Result. Try again."
                                
                                return
                                
                            elseif response.response.error then
                                
                                zip_code_prompt.text = "Having probelms with Weather Underground."
                                
                                return
                            else
                                
                                zip_entry_make_bar(zip,response)
                                
                            end
                            
                        else
                            zip_ellipsis_base_text = "Networking Issues"
                        end
                        
                    end)
                end
            end
            
            zip_backing[zip_focus].color={140,140,140}
            
        end
    end
    
    zip_on_key_down = function(self,k)
        
        if zip_search_cancel_obj then
            
            zip_code_prompt.text = "Canceled"
            
            zip_search_cancel_obj:cancel()
            
            zip_search_cancel_obj= nil
            
            bar.zip_ellipsis:stop()
            
        end
        
        return zip_keys[k] and zip_keys[k]()
    end
    
    bar.on_key_down = general_on_key_down
    
    function bar.get_state()
        
        return anim_state.state
        
    end
    
    function bar.warp_to_state(s)
        
        anim_state:warp(s)
        anim_state.timeline:on_started()
        anim_state.timeline:on_completed()
        
    end
    
    function bar.go_to_state(s)
        
        anim_state.state = s
        
    end
    
    
    --send weather query
    if master_i == nil then
        
        if wu_data then
            
            bar.update(wu_data)
            
        else
            
            lookup_zipcode(loc,bar.update)
            
            --animate_list[bar.func_tbls.loading_sun] = bar
            bar.loading_sun:start()
            
        end
        
    else
        
        bar.curr_condition="Sunny"
        
        blurb_txt.text = "Testing bar, Press up and down to view all the animations"
        
    end
    
    bar:hide()
    
    make_state()
    return bar
end
