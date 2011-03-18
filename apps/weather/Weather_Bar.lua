local MINI_BAR_X = 110

local BAR_X = 166
local BAR_Y = 873
local CURR_TEMP_X = 74
local CURR_TEMP_Y = 71
local LOCATION_X  = 290
local LOCATION_Y  = 62
local HI_LO_X     = 290
local HI_LO_Y     = 104
local BLURB_X     = 775
local BLURB_Y     = 58
local BAR_SPACE   = 40
local MINI_BAR_MIN_W = 500
local FULL_BAR_W     = screen_w-MINI_BAR_X*2-imgs.bar.side.w*2--1478
local COLOR_BUTTON_SPACING = 19

local FONT          = "DejaVuSans "
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

function Make_Bar(loc,index)
    local bar_index = index
    local mini_width = MINI_BAR_MIN_W 

    local bar = Group{
        name = loc.." Weather Bar",
        opacity = 0,
        x = MINI_BAR_X,
        y = BAR_Y,
        children={
            Clone{
                name       = "left",
                source     = imgs.bar.side,
                y_rotation = {180,0,0},
                x          = imgs.bar.side.w
            },
            Clone{
                name   = "mid",
                source = imgs.bar.mid,
                tile   = {true,false},
                --scale  = {408,1},
                x      = imgs.bar.side.w,
                w      = 408,
            },
            Clone{
                name   = "right",
                source = imgs.bar.side,
                x      = imgs.bar.side.w + 408
            },
        }
    }
    bar.curr_condition = "Unknown"
    bar.local_time_of_day = "DAY"
    bar.get_mini_w = function(self)
        return mini_width
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
    local arrow_l = Clone{
        source = imgs.arrows.left,
        x=34-imgs.arrows.left.w/2,
        y=imgs.bar.side.h/2-imgs.arrows.left.h/2,
    }
    local arrow_r = Clone{
        source = imgs.arrows.right,
        y=imgs.bar.side.h/2-imgs.arrows.right.h/2,
    }
    local curr_temp = Shadow_Text{
        name  = "Curr Temp",
        x     = CURR_TEMP_X,
        y     = CURR_TEMP_Y-30,
        font  = FONT.."Bold Condensed "..LARGE_TEMP_SZ,
        color = HI_TEMP_COLOR,
        text  = ""
    }
    local err_msg = Shadow_Text{
        name  = "Error Message",
        x     = LOCATION_X,
        y     = LOCATION_Y-10,
        font  = FONT..DAY_HI_LO_SZ,
        color = HI_TEMP_COLOR,
        text  = ""
    }
    local hi_temp = Shadow_Text{
        name  = "High Temp",
        x     = HI_LO_X,
        y     = HI_LO_Y-10,
        font  = FONT.."Bold Condensed "..HI_LO_SZ,
        color = HI_TEMP_COLOR,
        text  = ""
    }
    local lo_temp = Shadow_Text{
        name  = "Low Temp",
        x     = HI_LO_X+80,
        y     = HI_LO_Y-10,
        font  = FONT.."Bold Condensed "..HI_LO_SZ,
        color = LO_TEMP_COLOR,
        text  = ""
    }
    local location = Shadow_Text{
        name  = "Location",
        x     = LOCATION_X,
        y     = LOCATION_Y-10,
        font  = FONT..LOCATION_SZ,
        color = TEXT_COLOR,
        text  = "Getting Weather..."
    }
    
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
        name   = "blurb",
        source = imgs.color_button.blue_5_day,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33+40,
        
    }
    local blue_button_5_day = Clone{
        name   = "5 day",
        source = imgs.color_button.blue_today,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33+40,
        opacity=0
    }
    local yellow_button = Clone{
        source = imgs.color_button.yellow,
        x      = MINI_BAR_X+FULL_BAR_W-83,
        y      = 33+40*2
    }
    
    --Full Bar Elements
    local blurb_txt = Text{
        x     = BLURB_X,
        y     = BLURB_Y-10,
        w     = FULL_BAR_W - BLURB_X + 40,
        font  = FONT..BLURB_SZ,
        color = TEXT_COLOR,
        wrap  = true,
        text  = "",
    }

    local days = {}
    for i = 1,5 do
        days[i] = Group{
            name = "Day "..i,
            x = 170*(i-1)
        }
        days[i]:add(
            Clone{
                name = "icon",
                y    = 7,
                x    = 12,
            },
            Text{
                name  = "day",
                x     = 39,
                y     = -5,
                font  = FONT..DAY_SZ,
                text  = "",
                color = TEXT_COLOR,
            },
            Text{
                name  = "hi",
                x     = 36,
                y     = 73,
                font  = FONT.."Bold "..DAY_HI_LO_SZ,
                text  = "",
                color = HI_TEMP_COLOR,
            },
            Text{
                name  = "lo",
                x     = 100,
                y     = 73,
                font  = FONT.."Bold "..DAY_HI_LO_SZ,
                text  = "",
                color = LO_TEMP_COLOR,
            }
        )
        five_day:add(days[i])
    end
    
    local sun_b   = Clone{source=imgs.load.sun_base}
    local flare_l = Clone{source=imgs.load.light_flare, x=-10+imgs.load.light_flare.w/2,y=-10+imgs.load.light_flare.h/2,anchor_point={imgs.load.light_flare.w/2,imgs.load.light_flare.h/2}}
    local flare_d = Clone{source=imgs.load.dark_flare,  x= -8+imgs.load.dark_flare.w/2, y=-10+imgs.load.dark_flare.h/2,anchor_point={ imgs.load.dark_flare.w/2, imgs.load.dark_flare.h/2}}
    local loading_sun = Group{
        x=100,
        y=50,
    }
    local loading_error = Clone{source=imgs.load.error,opacity=0,x=100,y=50}
    loading_sun:add(flare_d,sun_b,flare_l)
    
    mini_width = location.x+location.w-bar.x+75
    if mini then
        --bar:find_child("mid").scale={mini_width,1}
        bar:find_child("mid").w=mini_width
        bar:find_child("right").x=imgs.bar.side.w + mini_width
    end
    
    green_button_mini.x = MINI_BAR_X + mini_width -imgs.bar.side.w/2- green_button_mini.w
    arrow_r.x = MINI_BAR_X + mini_width -imgs.bar.side.w/2+1
    
    
    local zip_code_prompt = Text{
        name  = "Zip Prompt",
        x     = 1098+(41+6),
        y     = 61,
        font  = FONT.."Bold "..ZIP_PROMPT,
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
            font=FONT.."Bold Condensed "..ZIP_SZ,
            color={0,0,0},
        }
        digits[i].anchor_point = {digits[i].w/2,digits[i].h/2}
        digits[i].x = zip_code_prompt.x+(41+6)*(i-1) + 35/2
        digits[i].y = 89 + 41/2
        zip_entry:add(zip_backing[i],digits[i])
    end
    zip_backing[1].color = {140,140,140}
    
    --Hierarchy of groups
    zip_entry:add(zip_code_prompt,us_only,ok_backing)
    zip_entry:hide()
    
    full_bar:add(blurb_txt,five_day,green_button_full,blue_button_5_day,yellow_button,blue_button_today,zip_entry)
    full_bar:hide()

    five_day:hide()
    mini_bar:add(green_button_mini)
    
    bar:add(arrow_l,arrow_r,curr_temp,hi_temp,lo_temp,location,full_bar,err_msg,mini_bar,loading_sun,loading_error)
    
    --Callback to the Weather query
    bar.update = function(curr_temp_tbl,fcast_tbl,error_str)
        if curr_temp_tbl ~= nil then
            curr_temp.text  = string.format("%d",curr_temp_tbl.current_observation.temp_f)..DEG
            ---[[
            location.text   = curr_temp_tbl.current_observation.location.city..
                    ", "..curr_temp_tbl.current_observation.location.state
            --]]
            
            
            mini_width = location.x+location.w-MINI_BAR_X+100
            if mini then
                --bar:find_child("mid").scale = {mini_width,1}
                bar:find_child("mid").w = mini_width
                bar:find_child("right").x   = imgs.bar.side.w + mini_width
            end
            green_button_mini.x = MINI_BAR_X+mini_width -83--+ mini_width -imgs.bar.side.w/2- green_button_mini.w
            arrow_r.x = MINI_BAR_X + mini_width -imgs.bar.side.w/2+1
        end
        
        if fcast_tbl ~= nil then
            local fday = fcast_tbl.forecast.simpleforecast.forecastday[1]
            blurb_txt.text      = fcast_tbl.forecast.txt_forecast.forecastday[1].fcttext
            
            hi_temp.text = fday.high.fahrenheit..DEG
            lo_temp.text = fday.low.fahrenheit.. DEG
            bar.curr_condition = fcast_tbl.forecast.simpleforecast.forecastday[1].conditions
            local time_str = fcast_tbl.forecast.txt_forecast.forecastday[1].title
            if string.match(time_str,"night") == "night" or string.match(time_str,"Night") == "Night" then
                bar.local_time_of_day = "NIGHT"
            else
                bar.local_time_of_day = "DAY"
            end
            if bar_i == bar_index then
                time_of_day = bar.local_time_of_day
                conditions[bar.curr_condition]()
            end
            animate_list[bar.func_tbls.loading_sun_fade_out] = bar
            --[[
            flare_l:animate{
                duration   = 8000,
                z_rotation = 360,
            }--]]
            for i = 1,5 do
                fday = fcast_tbl.forecast.simpleforecast.forecastday[i+1]
                if i == 1 then
                    days[i]:find_child("day").text = "Tomorrow"
                else
                    days[i]:find_child("day").text = fday.date.weekday
                end
                days[i]:find_child("hi").text = fday.high.fahrenheit..DEG
                days[i]:find_child("lo").text = fday.low.fahrenheit.. DEG
                days[i]:find_child("icon").source = imgs.icons[fday.icon]
            end
            
        end
        if error_str then
            location.text =""
            err_msg.text=error_str
             
        end
    end
    
    local bar_dist = 1905-imgs.bar.side.w-MINI_BAR_X
    local next_i = bar_index
    
    bar.func_tbls = {
        mini_move_left = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                
                --[[
                if p < 200/500 then
                    p = p * 700/200
                    arrow_l.opacity=255*(1-math.sin(math.pi*p))
                else
                    p = (p - 200/700)*700/500
                    --]]
                    
                    bar.x = MINI_BAR_X + bar_dist/2*p
                    bar.opacity=255*(1-p)
                    
                    bars[next_i].x = MINI_BAR_X - bar_dist/2 + bar_dist/2*p
                --end
                if p == 1 then
                    bars[next_i]:grab_key_focus()
                    bar:hide()
                end
            end
        },
        full_move_left = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                --[[
                if p < 200/500 then
                    p = p * 700/200
                    arrow_l.opacity=255*(1-math.sin(math.pi*p))
                else
                    p = (p - 200/700)*700/500
                    --]]
                    
                    bar.x = MINI_BAR_X + bar_dist*p
                    
                    bars[next_i].x = MINI_BAR_X - bar_dist + bar_dist*p
                    
                    right_faux_bar.x = bar_dist + bar_dist*p
                    
                    left_faux_bar.x = -bar_dist  + bar_dist*p
                --end
                if p == 1 then
                    bar.opacity=0
                    bar:hide()
                    right_faux_bar.x = 0
                    left_faux_bar.x  = 0
                    bars[next_i]:grab_key_focus()
                end
            end
        },
        mini_move_right = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                --[[
                if p < 200/500 then
                    p = p * 700/200
                    arrow_r.opacity=255*(1-math.sin(math.pi*p))
                else--]]
                    --p = (p - 200/700)*700/500
                    bar.x = MINI_BAR_X - bar_dist/2*p
                    bars[next_i].opacity=255*(p)
                    
                    bars[next_i].x = MINI_BAR_X + bar_dist/2 - bar_dist/2*p
                --end
                if p == 1 then
                    bars[next_i]:grab_key_focus()
                    bar:hide()
                end
            end
        },
        full_move_right = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                --[[if p < 200/500 then
                    p = p * 700/200
                    arrow_r.opacity=255*(1-math.sin(math.pi*p))
                else--]]
                    --p = (p - 200/700)*700/500
                    bar.x = MINI_BAR_X - bar_dist*p
                    
                    bars[next_i].x = MINI_BAR_X + bar_dist - bar_dist*p
                    
                    right_faux_bar.x = bar_dist - bar_dist*p
                    
                    left_faux_bar.x = - bar_dist*p
                --end
                
                if p == 1 then
                    bar.opacity=0
                    bar:hide()
                    right_faux_bar.x = 0
                    left_faux_bar.x = 0
                    bars[next_i]:grab_key_focus()
                end
            end
        },
        xfade_to_full = {
            duration=200,
            func = function(this_obj,this_func_tbl,secs,p)
                full_bar.opacity = 255*p
                mini_bar.opacity = 255*(1-p)
                if p == 1 then
                    mini_bar:hide()
                    bar:grab_key_focus()
                end
            end
        },
        expand_to_full = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                local w = mini_width + (FULL_BAR_W-mini_width)*math.sin(math.pi/2*p)
                
                --bar:find_child("mid").scale={w,1}
                bar:find_child("mid").w=w
                bar:find_child("right").x=imgs.bar.side.w + w
                arrow_r.x = MINI_BAR_X + w -imgs.bar.side.w/2+1
                
                f_grad.opacity=255*p
                left_faux_bar.x =(-faux_len-imgs.bar.side.w)*(1-1.05*math.sin((math.pi/2+.30984)*p))
                right_faux_bar.x=( faux_len+imgs.bar.side.w)*(1-1.05*math.sin((math.pi/2+.30984)*p))
                
                if p == 1 then
                    animate_list[bar.func_tbls.xfade_to_full]=bar
                end
            end
        },
        xfade_to_mini = {
            duration=200,
            func = function(this_obj,this_func_tbl,secs,p)
                full_bar.opacity = 255*(1-p)
                mini_bar.opacity = 255*(p)
                if p == 1 then
                    full_bar:hide()
                    blurb_txt.opacity = 255
                    blurb_txt:show()
                    blue_button_today.opacity = 255
                    blue_button_5_day.opacity = 0
                    five_day.opacity = 0
                    five_day:hide()
                    zip_entry.opacity = 0
                    zip_entry:hide()
                    animate_list[bar.func_tbls.expand_to_mini]=bar
                end
            end
        },
        expand_to_mini = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                local w = FULL_BAR_W + (mini_width-FULL_BAR_W)*math.sin(math.pi/2*p)
                
                --bar:find_child("mid").scale={w,1}
                bar:find_child("mid").w=w
                bar:find_child("right").x=imgs.bar.side.w + w
                arrow_r.x = MINI_BAR_X + w -imgs.bar.side.w/2+1
                f_grad.opacity=255*(1-p)
            	
                left_faux_bar.x=(-faux_len-imgs.bar.side.w)*p
                right_faux_bar.x=(faux_len+imgs.bar.side.w)*p
                if p == 1 then
                    bar:grab_key_focus()
                end
            end
        },
        xfade_in_5_day = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                blurb_txt.opacity = 255*(1-p)
                blue_button_today.opacity = 255*(1-p)
                blue_button_5_day.opacity = 255*(p)
                five_day.opacity = 255*p
                if p == 1 then
                    blurb_txt:hide()
                    bar:grab_key_focus()
                end
            end
        },
        xfade_in_blurb = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                blurb_txt.opacity = 255*(p)
                blue_button_today.opacity = 255*(p)
                blue_button_5_day.opacity = 255*(1-p)
                five_day.opacity = 255*(1-p)
                if p == 1 then
                    five_day:hide()
                    bar:grab_key_focus()
                end
            end
        },
        xfade_in_zip_from_blurb = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                blurb_txt.opacity = 255*(1-p)
                blue_button_today.opacity = 255*(p)
                blue_button_5_day.opacity = 255*(1-p)
                zip_entry.opacity = 255*p
                if p == 1 then
                    blurb_txt:hide()
                    bar:grab_key_focus()
                end
            end
        },
        xfade_in_zip_from_5_day = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                five_day.opacity = 255*(1-p)
                zip_entry.opacity = 255*p
                if p == 1 then
                    five_day:hide()
                    bar:grab_key_focus()
                end
            end
        },
        xfade_in_blurb_from_zip = {
            duration=600,
            func = function(this_obj,this_func_tbl,secs,p)
                blurb_txt.opacity = 255*(p)
                blue_button_today.opacity = 255*(1-p)
                blue_button_5_day.opacity = 255*(p)
                zip_entry.opacity = 255*(1-p)
                if p == 1 then
                    zip_entry:hide()
                    bar:grab_key_focus()
                end
            end
        },
        zip_ellipsis = {
            duration=1500,
            loop=true,
            func = function(this_obj,this_func_tbl,secs,p)
                if p < 1/4 then
                    zip_code_prompt.text = "Searching"
                elseif p < 2/4 then
                    zip_code_prompt.text = "Searching."
                elseif p < 3/4 then
                    zip_code_prompt.text = "Searching.."
                else
                    zip_code_prompt.text = "Searching..."
                end
            end
        },
        loading_sun = {
            duration = 8000,
            loop=true,
            func = function(this_obj,this_func_tbl,secs,p)
                flare_l.z_rotation = {360*p,0,0}
                flare_d.z_rotation = {360*p,0,0}
            end
        },
        loading_sun_fade_out = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                loading_sun.opacity = 255*(1-p)
                if p == 1 then
                    animate_list[this_func_tbl] = nil
                    animate_list[this_obj.func_tbls.loading_sun] = nil
                end
            end
        },
        error_fade_in = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                loading_error.opacity = 255*(p)
            end
        },
        error_fade_out = {
            duration=500,
            func = function(this_obj,this_func_tbl,secs,p)
                loading_error.opacity = 255*(1-p)
            end
        }
    }
    
    
    --animate_list[bar.func_tbls.spin_zip_loading]=bar
    --Key Handler
    local bar_keys = {
        [keys.Up]     = function()
        end,
        [keys.Down]   = function()
        end,
        [keys.Left]   = function()
            
            if zip_entry.opacity~=0 then
                if zip_focus <= #zip_backing then
                    zip_backing[zip_focus].color={255,255,255}
                end
                zip_focus = zip_focus - 1
                if zip_focus == 0 then
                    zip_focus = #zip_backing
                end
                zip_backing[zip_focus].color = {140,140,140}
                return
            end
            
            next_i = bar_i-1
            if  next_i < 1 then
                next_i = #bars
            end
            screen:grab_key_focus()
            bars[next_i]:show()
            if mini then
                bars[next_i].x = MINI_BAR_X - bar_dist/2
                bars[next_i].opacity = 255
                bars[next_i]:go_mini()
                animate_list[bar.func_tbls.mini_move_left] = bar
            else
                bars[next_i].x = MINI_BAR_X - bar_dist
                bars[next_i].opacity = 255
                bars[next_i]:go_full()
                left_faux_bar.x = -bar_dist
                animate_list[bar.func_tbls.full_move_left] = bar
            end
            time_of_day = bars[next_i].local_time_of_day
            conditions[bars[next_i].curr_condition]()
            print("switching to "..next_i)
            bar_i = next_i
        end,
        [keys.Right]  = function()
            
            if zip_entry.opacity~=0 then
                if zip_focus <= 5 then
                    zip_backing[zip_focus].color={255,255,255}
                end
                zip_focus = zip_focus + 1
                if zip_focus == #zip_backing + 1 then
                    zip_focus = 1
                    
                end
                zip_backing[zip_focus].color = {140,140,140}
                return
            end
            
            
            next_i = bar_index+1
            if  next_i > #bars then
                next_i = 1
            end
            
            screen:grab_key_focus()
            bars[next_i]:show()
            if mini then
                bars[next_i].x = MINI_BAR_X + bar_dist/2
                bars[next_i].opacity = 0
                bars[next_i]:go_mini()
                animate_list[bar.func_tbls.mini_move_right] = bar
            else
                bars[next_i].x = MINI_BAR_X + bar_dist
                bars[next_i].opacity = 255
                bars[next_i]:go_full()
                right_faux_bar.x = bar_dist
                animate_list[bar.func_tbls.full_move_right] = bar
            end
            time_of_day = bars[next_i].local_time_of_day
            conditions[bars[next_i].curr_condition]()
            print("switching to "..next_i)
            bar_i = next_i
        end,
        
        [keys.OK]     = function()
            if zip_entry.opacity~=0 and zip_focus == 6 then
                local zip = digits[1].text..digits[2].text..digits[3].text..digits[4].text..digits[5].text
                print(zip)
                table.insert(locations,zip)
                table.insert(bars,Make_Bar(zip,#locations))
                screen:add(bars[#bars])
                digits[1].text = ""
                digits[2].text = ""
                digits[3].text = ""
                digits[4].text = ""
                digits[5].text = ""
                zip_focus      = 1
                
                next_i = #bars
                
                bars[next_i].x = MINI_BAR_X + bar_dist
                bars[next_i].opacity = 255
                bars[next_i]:go_full()
                right_faux_bar.x = bar_dist
                animate_list[bar.func_tbls.full_move_right] = bar
                bar_i = next_i
                
            end
        end,
        
        [keys.BLUE]   = function()
            if mini then return end
            
            screen:grab_key_focus()
            
            if zip_entry.opacity~=0 then
                blurb_txt:show()
                animate_list[bar.func_tbls.xfade_in_blurb_from_zip] = bar
            elseif five_day.opacity == 0 then
                five_day:show()
                animate_list[bar.func_tbls.xfade_in_5_day] = bar
            else
                blurb_txt:show()
                animate_list[bar.func_tbls.xfade_in_blurb] = bar
            end
        end,
        [keys.RED]    = function()
        end,
        [keys.GREEN]  = function()
            screen:grab_key_focus()
            if mini then
                full_bar:show()
                animate_list[bar.func_tbls.expand_to_full]=bar
            else
                mini_bar:show()
                animate_list[bar.func_tbls.xfade_to_mini]=bar
            end
            mini = not mini
            
        end,
        [keys.YELLOW] = function()
            if mini then return end
            
            screen:grab_key_focus()
            if zip_entry.opacity == 0 then
                for i = 1,5 do
                    digits[i].text = ""
                    zip_backing[i].color={255,255,255}
                end
                zip_backing[1].color={140,140,140}
                
                zip_focus      = 1
                zip_code_prompt.text = "Enter a Zip Code"
                us_only.text="(US only)"
                zip_entry:show()
                if five_day.opacity == 0 then 
                    animate_list[bar.func_tbls.xfade_in_zip_from_blurb] = bar
                else
                    animate_list[bar.func_tbls.xfade_in_zip_from_5_day] = bar
                end
            else
                blurb_txt:show()
                animate_list[bar.func_tbls.xfade_in_blurb_from_zip] = bar
            end
        end,
    }
    
    bar.on_key_down = function(self,key)
        if zip_entry.opacity~=0 and key >= keys["0"] and key <= keys["9"] and zip_focus < 6 then
            local num = key - keys["0"]
            digits[zip_focus].text = num
            digits[zip_focus].anchor_point = {digits[zip_focus].w/2,digits[zip_focus].h/2}
            digits[zip_focus].x = zip_code_prompt.x+(41+6)*(zip_focus-1) + 35/2
            digits[zip_focus].y = 89 + 41/2
            zip_backing[zip_focus].color={255,255,255}
            zip_focus = zip_focus + 1
            if zip_focus == #zip_backing + 1  then
                zip_focus = 1
                
                local zip = digits[1].text..digits[2].text..digits[3].text..digits[4].text..digits[5].text
                
                zip_focus      = 1
                
                next_i = #bars
                
                us_only.text=""
                zip_code_prompt.text = "Searching"
                animate_list[bar.func_tbls.zip_ellipsis]=bar
                --[[
                bars[next_i].x = MINI_BAR_X + bar_dist
                bars[next_i].opacity = 255
                bars[next_i]:go_full()
                right_faux_bar.x = bar_dist
                --]]
                --animate_list[bar.func_tbls.full_move_right] = bar
                bar_i = next_i
                geo_query(zip,
                    function(response_tbl)
                        animate_list[bar.func_tbls.zip_ellipsis]=nil
                        if response_tbl.wui_error ~= nil or response_tbl.locations ~= nil then
                            zip_code_prompt.text = "No Search Result. Try again."
                        elseif response_tbl.location ~= nil then
                            zip_code_prompt.text = "Success"
                            table.insert(locations,zip)
                            table.insert(bars,Make_Bar(zip,#locations))
                            screen:add(bars[#bars])
                            bars[#bars].x = MINI_BAR_X + bar_dist
                            bars[#bars].opacity = 255
                            bars[#bars]:go_full()
                            bars[#bars]:show()
                            right_faux_bar.x = bar_dist
                             next_i = #bars
                             
                            animate_list[bar.func_tbls.full_move_right] = bar
                        else
                            dumptable(response_tbl)
                            error("Received unexpected response from Wunderground")
                        end
                    end
                )
                
                
            end
            zip_backing[zip_focus].color={140,140,140}
        elseif bar_keys[key] then bar_keys[key]() end
    end
    
    bar.go_full = function()
        full_bar.opacity=255
        full_bar:show()
        mini_bar.opacity=0
        mini_bar:hide()
        --bar:find_child("mid").scale={FULL_BAR_W,1}
        bar:find_child("mid").w=FULL_BAR_W
        bar:find_child("right").x=imgs.bar.side.w + FULL_BAR_W
        arrow_r.x = MINI_BAR_X + FULL_BAR_W -imgs.bar.side.w/2+1
        blurb_txt.opacity=255
        blurb_txt:show()
        zip_entry.opacity=0
        zip_entry:hide()
        five_day.opacity=0
        five_day:hide()
        
    end
    bar.go_mini = function()
        full_bar.opacity=0
        full_bar:hide()
        mini_bar.opacity=255
        mini_bar:show()
        --bar:find_child("mid").scale={mini_width,1}
        bar:find_child("mid").w = mini_width
        bar:find_child("right").x=imgs.bar.side.w + mini_width
        arrow_r.x = MINI_BAR_X + mini_width -imgs.bar.side.w/2+1
    end
    
    --send weather query
    curr_conditions_query(loc, bar.update)
    
    forecast_query(loc, bar.update)
    
    animate_list[bar.func_tbls.loading_sun] = bar
    bar:hide()
    return bar
end
