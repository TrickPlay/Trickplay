
--all hardcoded numbers are from the spec
local gutter_sides        = 50
local top_gutter          = 26
local bottom_gutter       = 20
local title_card_h        = 180
local title_card_w        = 352
local title_card_y        = 202
local title_card_spacing  = 15

local bottom_containers_y = title_card_y + title_card_h + 33




--the group for the front page
fp_group = Group{}
screen:add(fp_group)
--[[
do
local bg = Canvas{size={screen_w,screen_h},x=0,y=0}
bg:begin_painting()
bg:move_to(0,0)
bg:line_to(screen_w,0)
bg:line_to(screen_w,screen_h)
bg:line_to(0,screen_h)
bg:line_to(0,0)

bg:set_source_linear_pattern(
	bg.w/2,0,
	bg.w/2,bg.h
)
bg:add_source_pattern_color_stop( 0 , "000000" )
bg:add_source_pattern_color_stop( 1 , "1A1A1A" )
bg:fill(true)
bg:finish_painting()
fp_group:add(bg)
end
--]]


--Load in the stationary assets for the Front Page
--using a do-end to toss the locals once they're loaded
do
    --Upper Left
    local logo          = Image{src="assets/logo.png",    x = gutter_sides,
                                                          y = top_gutter}

    title_card_y = logo.y + logo.h+10
    --Upper Right
    local up_r_spacing = 16
    local up_r_top_gutter = 16

    local options = Image{ src="assets/options.png", y = up_r_top_gutter }
    local back    = Image{ src="assets/back.png",    y = up_r_top_gutter }
    local exit    = Image{ src="assets/exit.png",    y = up_r_top_gutter }
        
    exit.x    = screen_w - gutter_sides - exit.w
    back.x    = exit.x   - up_r_spacing - back.w
    options.x = back.x   - up_r_spacing - options.w
    
    fp_group:add(logo, recents_title, options, back, exit)
end




--Container for the Title Cards
local Titlecards_Bar = Class(function(self,parent,...)
    local group   = Group{x=gutter_sides, y = title_card_y}
    local title   = Image{src="assets/recents.png"}
    local tiles   = Group{}
    
    
    local max_on_screen = 5
    
    local bar_items = {}
    local clip      = Group{y = 21+title.h,clip=
        {
            0,
            0,
            max_on_screen*title_card_w+(max_on_screen-1)*title_card_spacing,
            title_card_h
        }
    }
    local focus   = make_focus(title_card_w,title_card_h,0,clip.y) --Image{src="assets/focus-shows.png",y=clip.y-19,x=-19}
    --Rectangle{w=title_card_w+20,h=title_card_h+20,color="#FFFFFF",y=clip.y-10,x=-10}
    clip:add(tiles)
    group:add(focus,title,clip)
    fp_group:add(group)
    local imgs      = {}
    local list_i  = 1
    local vis_loc = 1
    --need to init the bar_items here
    function self:add(show_obj)
        
        tiles:add(Image{
            src = show_obj.title_card,
            x   = #bar_items*(title_card_w+title_card_spacing)
        })
        table.insert(bar_items,show_obj)
    end
    function self:receive_focus()
        focus.opacity   = 255
        fp.tweetstream:display(bar_items[list_i])
    end
    function self:lose_focus()
        focus.opacity   = 0
    end
    function self:left()
        if list_i - 1 >= 1 then
            list_i = list_i - 1
            if vis_loc == 1 then
                tiles.x = -(list_i -1)*(title_card_w+title_card_spacing)
            else
                vis_loc = vis_loc - 1
                focus.x = (vis_loc-1)*(title_card_w+title_card_spacing) -19
            end
            fp.tweetstream:display(bar_items[list_i])
        end
            --print(list_i)
    end
    function self:right()
        if list_i + 1 <= #bar_items then
            list_i = list_i + 1
            if vis_loc == max_on_screen then
                tiles.x = -(list_i - max_on_screen)*(title_card_w+title_card_spacing)
            else
                vis_loc = vis_loc + 1
                focus.x = (vis_loc-1)*(title_card_w+title_card_spacing) - 19
            end
            fp.tweetstream:display(bar_items[list_i])
        end
            --print(list_i)
    end
    function self:down()
        fp.focus = "LISTINGS"
        self:lose_focus()
        fp.listings_container:receive_focus()
    end
    function self:enter()
        page = "sp"
        fp_group:hide()
        sp_group:show()
        bar_items[list_i].tweetstream:get_group():unparent()
        bar_items[list_i].tweetstream:out_view()
        sp.tweetstream:display(bar_items[list_i])
        --bar_items[list_i].tweetstream:receive_focus()
    end
    
    function self:go_to_options()
        if highlight_timeline ~= nil then
            highlight_timeline:stop()
            highlight_timeline:on_completed()
        end
        if move_timeline ~= nil then
            move_timeline:stop()
            move_timeline:on_completed()
        end
        fp.focus = "OPTIONS"
        self:lose_focus()
        fp.options:receive_focus(fp.title_card_bar,"TITLECARDS")
    end
end)

--Container for the Listings
local Listings = Class(function(self,...)

    local listing_h           = 69
    local group = Group
    {
        x = gutter_sides,
        y = bottom_containers_y
    }
    local title    = Image{src="assets/listings.png"}
   
    local bg,big_focus = make_bg(704,592,   0,title.h+5,true)
    --local big_focus = Image{src="assets/focus-listings.png",opacity=0,x=bg.x-20,y=bg.y-20}
    F = big_focus:find_child("F")
    local focus_tl = nil
    local border_w = 1
    --[[
    local rules = Canvas{size={bg.w,bg.h-23*2},x=0,y=bg.y+23}
          rules:begin_painting()
          rules:move_to(0,0)--border_w,         border_w)
          rules:line_to(rules.w-border_w, border_w)
          rules:move_to(border_w,         rules.h-border_w)
          rules:line_to(rules.w-border_w, rules.h-border_w)
          rules:set_source_color( "505050" )
          rules:set_line_width(   border_w )
          rules:stroke( true )
          rules:finish_painting()
          --]]
    --local rules = Rectangle{size={bg.w,bg.h-23*2},x=0,y=bg.y+23}
    --[[
    local grey_rect = Canvas{size={bg.w,listing_h},opacity=0}
          grey_rect:begin_painting()
          grey_rect:move_to(border_w,0)--border_w,         border_w)
          grey_rect:line_to(grey_rect.w-border_w, 0)
          grey_rect:line_to(grey_rect.w-border_w, grey_rect.h-border_w)
          grey_rect:line_to(border_w,             grey_rect.h-border_w)
          grey_rect:line_to(border_w,0)
          grey_rect:set_source_color( "181818" )
	      grey_rect:fill( true )
          grey_rect:set_source_color( "2D2D2D" )
          grey_rect:set_line_width(   border_w )
	      grey_rect:stroke( true )
          grey_rect:finish_painting()
          --]]
    --local grey_rect = Rectangle{size={bg.w,listing_h},opacity=0}
    --screen:add(grey_rect)
    --[[
    local focus_o = Canvas{size={bg.w,listing_h},opacity=0}
          focus_o:begin_painting()
          focus_o:move_to(border_w,0)--border_w,         border_w)
          focus_o:line_to(focus_o.w-border_w, 0)
          focus_o:line_to(focus_o.w-border_w, focus_o.h-border_w)
          focus_o:line_to(border_w,           focus_o.h-border_w)
          focus_o:line_to(border_w,0)
          focus_o:set_source_linear_pattern(
            focus_o.w/2,0,
            focus_o.w/2,focus_o.h
          )
          focus_o:add_source_pattern_color_stop( 0 , "8D8D8D" )
          focus_o:add_source_pattern_color_stop( 1 , "727272" )
	      focus_o:fill( true )
          focus_o:finish_painting()
          --]]
    local focus_o = Clone{source = focus_strip,scale={bg.w,1},opacity=0}
    local focus_n = Clone{source = focus_strip,scale={bg.w,1},opacity=0}
    
    local Show_Name_Font  = "Helvetica bold 26px"
    local Show_Name_Color = "#FFFFFF"

    local listings = {}
    local listings_clip = Group
    {
        y    = bg.y+23,
        clip = { 1, 0,  bg.w-2, bg.h-23*2}
    }
    local listings_g = Group{}
    local listings_bg = Group{}
    listings_clip:add(listings_bg,listings_g)
    listings_g:add(focus_o,focus_n)
    local arrow_dn = Image{src="assets/arrow.png",x=bg.w/2,y=bg.y+bg.h-12,opacity=0}
    arrow_dn.anchor_point={arrow_dn.w/2,arrow_dn.h/2}
    local arrow_up = Clone
    {
        source       = arrow_dn,
        z_rotation   = {180,0,0},
        anchor_point = {arrow_dn.w/2,arrow_dn.h/2},
        opacity=0,
        x=bg.w/2,y=bg.y+12
    }
    group:add(
        --bg_unsel,
        big_focus,
        bg,
        title,
        listings_clip,
        arrow_dn,
        arrow_up
        --rules
    )
    
    fp_group:add(group)
    ----------------------------------------------------------------------------
    
    local list_i = 1
    local vis_loc = 1
    local max_on_screen = 8
    local days_r = {
        "Sunday"    ,
        "Monday"    ,
        "Tuesday"   ,
        "Wednesday" ,
        "Thursday"  ,
        "Friday"    ,
        "Saturday"  
    }
    local curr_date = os.date("*t",os.time())
    local today     = days_r[curr_date.wday]
    local curr_time
    local curr_ampm
    if curr_date.hour+1 < 12  or (curr_date.hour+1 < 12 and curr_date.min == 0 )then
        curr_time = curr_date.hour+1
        curr_ampm = "am"
    else
        curr_time = curr_date.hour+1 - 12
        curr_ampm = "pm"
    end
    
    print(today,curr_time,curr_ampm,curr_date.hour)
    local days = {
        Sunday    = 1,
        Monday    = 2,
        Tuesday   = 3,
        Wednesday = 4,
        Thursday  = 5,
        Friday    = 6,
        Saturday  = 7
    }
    
    local prev = days[today]
    for k,v in pairs(days) do
        days[k] = v-(prev-1)
        if days[k] < 1 then
            days[k] = days[k] + 7
        end
    end--[[
    days[today] = 1
    print(prev)
    for i = 2,7 do
        prev = prev+1
        for k,v in pairs(days) do
            if v == prev then
                print(k,i)
                days[k]=i
                dumptable(days)
                break
            end
        end
        if prev == 7  then
            prev = 0
        end
    end--]]
    dumptable(days)
    function self:add(show_obj)
        
        local index = #listings + 1
        for i = 1, #listings do
            if   days[show_obj.show_day]<days[listings[i].obj.show_day] or
                (days[show_obj.show_day]==days[listings[i].obj.show_day] and
                 ((show_obj.show_ampm == "am" and listings[i].obj.show_ampm == "pm") or
                   (show_obj.show_ampm == listings[i].obj.show_ampm and
                    show_obj.show_time <  listings[i].obj.show_time))) then
                
                index = i
                break
                
            end
        end
        
        for i = #listings,index,-1 do
            listings[i+1] = {
                obj        = listings[i].obj,
                show_name  = listings[i].show_name,
                show_time  = listings[i].show_time,
                tv_station = listings[i].tv_station
            }
            listings[i].show_name.y  = listing_h*(i+1-.5)
            listings[i].show_time.y  = listing_h*(i+1-.5)
            listings[i].tv_station.y = listing_h*(i+1-.5)
        end
        --[[
        local time = show_obj.show_time-math.floor(show_obj.show_time)
        if time == 0 then
            time = show_obj.show_time
        else
            time = math.floor(show_obj.show_time)..":"..(time*60)
        end
        local tot_time
        if days[show_obj.show_day]==days[today] then
            if show_obj.show_ampm == curr_ampm and
                show_obj.show_time ==  curr_time then
                
                tot_time = "Now Playing"
            else
                tot_time = "Tonight at "..time..show_obj.show_ampm
            end
        else
            tot_time = show_obj.show_day.." "..time..show_obj.show_ampm
        end
        --]]
        local show_name = Text
                {
                    text  = show_obj.show_name,
                    font  = Show_Name_Font,
                    color = Show_Name_Color,
                    x     = 15,
                    y     = listing_h*(index-.5)
                }
                show_name.anchor_point={
                    0,--show_name.w/2,
                    show_name.h/2
                }
        local show_time = Text
                {
                    text  = show_obj.show_time_text,
                    font  = Show_Time_Font,
                    color = Show_Time_Color,
                    x     = 378,
                    y     = listing_h*(index-.5)
                }
                show_time.anchor_point={
                    0,--show_time.w/2,
                    show_time.h/2
                }
        local tv_station = Text
                {
                    text  = show_obj.tv_station,
                    font  = TV_Station_Font,
                    color = TV_Station_Color,
                    x     = 593,
                    y     = listing_h*(index-.5)
                }
                tv_station.anchor_point={
                    0,--tv_station.w/2,
                    tv_station.h/2
                }
        
        
        
        listings[index]=
            {
                obj        = show_obj,
                show_name  = show_name,
                show_time  = show_time,
                tv_station = tv_station
            }
        if #listings%2 == 0 then
            listings_bg:add(Clone{source=base_grey_rect,y=listing_h*(#listings-1),scale={bg.w,1}})
        end
        
        listings_g:add(show_name, show_time, tv_station)
        if #listings > max_on_screen then
            arrow_dn.opacity=255
        end
    end
    
    local highlight_timeline = nil
    function self:receive_focus()
        --bg_sel.opacity   = 255
        --bg_unsel.opacity = 0
        
        if #listings > 0 then
            self:move_highlight_to(nil,list_i)
            --[[
            focus_o.opacity=255
            listings[list_i].show_name.color  = "#000000"
            listings[list_i].show_time.color  = "#000000"
            listings[list_i].tv_station.color = "#000000"
            --]]
        end
        --big_focus.opacity=255
    end
    function self:lose_focus()
        --bg_sel.opacity   = 0
        --bg_unsel.opacity = 255
        --big_focus.opacity=0
        if #listings > 0 then
            self:move_highlight_to(list_i,nil)
            --[[
            focus_o.opacity=0
            listings[list_i].show_name.color  = Show_Name_Color
            listings[list_i].show_time.color  = Show_Time_Color
            listings[list_i].tv_station.color = TV_Station_Color
            --]]
        end
    end
    
    
    function self:move_highlight_to(old_i,new_i)
        if new_i ~= nil then
            focus_n.y = (new_i-1)*listing_h
        end
        focus_n.opacity = 0
        if highlight_timeline ~= nil then
            highlight_timeline:stop()
            highlight_timeline:on_completed()
        end
        highlight_timeline = Timeline{
            loop     = false,
            duration = 100
        }
        
        local to_zero = 255
        local to_max  = 0
        function highlight_timeline:on_new_frame(msecs,prog)
            to_max  = 255*(prog)
            to_zero = 255*(1-prog)
            if new_i ~= nil then
                listings[new_i].show_name.color  = {to_zero,to_zero,to_zero}
                listings[new_i].show_time.color  = {to_zero,to_zero,to_zero}
                listings[new_i].tv_station.color = {to_zero,to_zero,to_zero}
                focus_n.opacity = to_max
            else
                big_focus.opacity=to_zero
            end
            if old_i ~= nil then
                listings[old_i].show_name.color  = {to_max,to_max,to_max}
                listings[old_i].show_time.color  = {to_max,to_max,to_max}
                listings[old_i].tv_station.color = {to_max,to_max,to_max}
                focus_o.opacity = to_zero
            else
                big_focus.opacity=to_max
            end
        end
        function highlight_timeline:on_completed()
            focus_n.opacity = 0
            if new_i ~= nil then
                focus_o.opacity = 255
                focus_o.y = focus_n.y
                listings[new_i].show_name.color  = {0,0,0}
                listings[new_i].show_time.color  = {0,0,0}
                listings[new_i].tv_station.color = {0,0,0}
                fp.tweetstream:display(listings[new_i].obj)
            else
                big_focus.opacity=to_zero
            end
            if old_i ~= nil then
                listings[old_i].show_name.color  = {255,255,255}
                listings[old_i].show_time.color  = {255,255,255}
                listings[old_i].tv_station.color = {255,255,255}
            else
                big_focus.opacity=to_max
            end
            highlight_timeline = nil
        end
        highlight_timeline:start()
        if new_i ~= nil then
            list_i = new_i
        end
    end
    local move_timeline = nil
    function self:move_list(new_loc)
        --local delta = new_loc - listings_bg.y
        local old_loc = listings_bg.y
        if move_timeline ~= nil then
            move_timeline:stop()
            move_timeline:on_completed()
        end
        move_timeline = Timeline{
            loop     = false,
            duration = 100
        }
        function move_timeline:on_new_frame(msecs,prog)
            listings_bg.y = old_loc + (new_loc - old_loc)*prog
            listings_g.y  = old_loc + (new_loc - old_loc)*prog
        end
        function move_timeline:on_completed()
            listings_bg.y = new_loc
            listings_g.y  = new_loc
            move_timeline = nil
        end
        move_timeline:start()
    end
    
    function self:up()
        if list_i - 1 >= 1 then
            self:move_highlight_to(list_i,list_i - 1)
            print(list_i)
            if vis_loc == 1 then
                self:move_list(-(list_i -1)*(listing_h))
                arrow_dn.opacity=255
                if list_i == 1 then
                    arrow_up.opacity=0
                end
            else
                vis_loc = vis_loc - 1
                
                if vis_loc == 1 then
                    self:move_list(-(list_i -1)*(listing_h))
                end
            end
        else
            if highlight_timeline ~= nil then
                highlight_timeline:stop()
                highlight_timeline:on_completed()
            end
            if move_timeline ~= nil then
                move_timeline:stop()
                move_timeline:on_completed()
            end
            fp.focus = "TITLECARDS"
            self:lose_focus()
            fp.title_card_bar:receive_focus()
        end
    end
    
    function self:down()
        print("down")
        if list_i + 1 <= #listings then
            self:move_highlight_to(list_i,list_i + 1)
            print(list_i)
            if vis_loc == max_on_screen then
                self:move_list(-(list_i -max_on_screen)*(listing_h))
                arrow_up.opacity=255
                if list_i == #listings then
                    arrow_dn.opacity=0
                end
            else
                vis_loc = vis_loc + 1
                
                if vis_loc == max_on_screen then
                    self:move_list(-(list_i -max_on_screen)*(listing_h))
                end
            end
        end
    end

    function self:enter()
        if highlight_timeline ~= nil then
            highlight_timeline:stop()
            highlight_timeline:on_completed()
        end
        if move_timeline ~= nil then
            move_timeline:stop()
            move_timeline:on_completed()
        end
        page = "sp"
        fp_group:hide()
        sp_group:show()
        listings[list_i].obj.tweetstream:get_group():unparent()
        listings[list_i].obj.tweetstream:out_view()
        sp.tweetstream:display(listings[list_i].obj)
        --listings[list_i].obj.tweetstream:receive_focus()
    end
    function self:move_x_by(x)
        group.x = group.x + x
    end
    function self:get_group()
        return group
    end
    function self:go_to_options()
        if highlight_timeline ~= nil then
            highlight_timeline:stop()
            highlight_timeline:on_completed()
        end
        if move_timeline ~= nil then
            move_timeline:stop()
            move_timeline:on_completed()
        end
        fp.focus = "OPTIONS"
        self:lose_focus()
        fp.options:receive_focus(fp.listings_container,"LISTINGS")
        
    end
    
end)


--Container for the TweetStream
local TweetStream_Container = Class(function(self,...)
    
    local group = Group
    {
        x = gutter_sides + 2*title_card_w + 2*title_card_spacing,
        y = bottom_containers_y
    }
    local title   = Image{src="assets/tweetstream.png"}
    
    local Show_Name_Font  = "Helvetica bold 40px"
    local Show_Name_Color = "#FFFFFF"
    local Show_Desc_Font  = Show_Time_Font
    local Show_Desc_Color = Show_Time_Color
    local Curr_Tweet_List = {}
    --local max_tweets_in_list = 4
    
    function self:move_x_by(x)
        group.x = group.x + x
    end
    function self:get_group()
        return group
    end
    local bg = make_bg(1086,592,   0,title.h+22)
    --local bg = Canvas{size={1086,592},x=0,y=title.h+22}
    local wallpaper = Image{src="assets/tweetstream_bg_tile.png",tile={true,true},x=346,y=bg.y+123,w=1086-346-1,h=592-(bg.y+72)}
    --= Image{src="assets/fp_tweetstream_container.png",y=title.h+22}
    
    --local tweet_clip = Group{clip={0,0,bg.w-368,bg.h-127},x=366,y=bg.y+125}
    local top_rule    = Image{src="assets/object_tweetstream_top_Shadow.png",x = 366, y=bg.y+123}
    local bottom_rule = Image{src="assets/object_tweetstream_bottom_Shadow.png",x=346}
    bottom_rule.y = bg.y + bg.h - bottom_rule.h-2
    
    local poster = Image{src="assets/posters/banner_side_shadow_tile.png",x=348,y=bg.y+2,tile={false,true},h=588}
    local show_name = Text{
        text  = "show_name",
        font  = Show_Name_Font,
        color = Show_Name_Color,
        x     = 366,
        y     = bg.y+19
    }
    local show_desc = Text{
        text  = "show_desc",
        font  = Show_Desc_Font,
        color = Show_Desc_Color,
        x     = 366,
        y     = show_name.y+show_name.h+5
    }
    local tv_station = Text{
        text  = "tv_station",
        font  = TV_Station_Font,
        color = TV_Station_Color,
        x     = bg.w-15,
        y     = bg.y+41
    }
    tv_station.x = tv_station.x - tv_station.w
    local show_time = Text{
        text  = "show_time",
        font  = Show_Time_Font,
        color = Show_Time_Color,
        x     = tv_station.x -30,
        y     = bg.y+41
    }
    local add_image = nil
    show_time.x = show_time.x - show_time.w
    group:add(bg,wallpaper,title,show_name,show_desc,tv_station,show_time,top_rule,bottom_rule,poster)
    fp_group:add(group)
    
    local curr_obj = nil
    function self:display(show_obj)
        --[[
        if curr_obj ~= nil then
            for i = 1,#curr_obj.tweet_g_cache do
                curr_obj.tweet_g_cache[i].group:unparent()
            end
        end
        --]]
        if curr_obj ~= nil then
            curr_obj.tweetstream:get_group():unparent()
            curr_obj.tweetstream:out_view()
        end
        curr_obj = show_obj
        --[[
        if curr_obj ~= nil then
            for i = 1,#curr_obj.tweet_g_cache do
                tweet_clip:add(curr_obj.tweet_g_cache[i].group)
            end
        end
        --]]
        show_name.text  = show_obj.show_name
        show_desc.text  = show_obj.show_desc
        
        tv_station.x    = tv_station.x + tv_station.w
        tv_station.text = show_obj.tv_station
        tv_station.x    = tv_station.x - tv_station.w
        
        show_time.x     = show_time.x + show_time.w
        show_time.text  = show_obj.show_time_text
        show_time.x     = show_time.x - show_time.w
        
        if add_image ~= nil then
            add_image:unparent()
            add_image = nil
        end
        
        if show_obj.add_image ~= nil then
            add_image = show_obj.add_image
            add_image.y = bg.y+1
            add_image.x = 1
            group:add(add_image)
            --tweet_clip.clip = {0,0,bg.w-368,bg.h-127}
            --tweet_clip.x    = 366
            show_name.x     = 366
            show_desc.x     = 366
            top_rule.x      = 366
            if curr_obj ~= nil then
                curr_obj.tweetstream:resize(bg.w-366,bg.h-127,true)
                curr_obj.tweetstream:set_pos(366,bg.y+125)
                group:add( curr_obj.tweetstream:get_group() )
                top_rule:raise_to_top()
                bottom_rule:raise_to_top()
                --for i = 1,#curr_obj.tweet_g_cache do
                --    tweet_clip:add(curr_obj.tweet_g_cache[i].group)
                --end
                curr_obj.tweetstream:in_view()
                
            end
        else
            --tweet_clip.clip = {0,0,bg.w-30,bg.h-127}
            --tweet_clip.x    = 15
            show_name.x     = 15
            show_desc.x     = 15
            top_rule.x      = 150
            if curr_obj ~= nil then
                curr_obj.tweetstream:resize(bg.w,bg.h-127,true)
                curr_obj.tweetstream:set_pos(0,bg.y+125)
                group:add( curr_obj.tweetstream:get_group() )
                top_rule:raise_to_top()
                bottom_rule:raise_to_top()
                --for i = 1,#curr_obj.tweet_g_cache do
                --    tweet_clip:add(curr_obj.tweet_g_cache[i].group)
                --end
                curr_obj.tweetstream:in_view()
            end
        end
    end
end)

fp = {}

    fp.title_card_bar     = Titlecards_Bar()
    fp.listings_container = Listings()
    fp.tweetstream        = TweetStream_Container()
    fp.options_anim       = function(prog)
        fp.listings_container:get_group().x =
            gutter_sides + prog
        fp.tweetstream:get_group().x =
            gutter_sides + 2*title_card_w + 2*title_card_spacing + prog
    end
    fp.options            = Options(screen_w,bottom_containers_y,fp)
    fp.focus              = "TITLECARDS"
    fp.keys = {
        ["LISTINGS"] = {
            [keys.Down] = function()
                fp.listings_container:down()
            end,
            [keys.Up] = function()
                fp.listings_container:up()
            end,
            [keys.Return] = function()
                fp.listings_container:enter()
            end,
            [keys.F8] = function()
                fp.listings_container:go_to_options()
            end,
            [keys.BLUE] = function()
                fp.listings_container:go_to_options()
            end,
        },
        ["OPTIONS"] = {
            [keys.Down] = function()
                fp.options:down()
            end,
            [keys.Up] = function()
                fp.options:up()
            end,
            [keys.Return] = function()
                fp.options:enter()
            end,
            [keys.F8] = function()
                fp.options:return_to_prev()
            end,
            [keys.BLUE] = function()
                fp.options:return_to_prev()
            end,
            [keys.Left] = function()
                fp.options:return_to_prev()
            end,
            [keys.F9] = function()
                fp.options:return_to_prev()
            end,
            [keys.BACK] = function()
                fp.options:return_to_prev()
            end,
            [keys.BackSpace] = function()
                fp.options:return_to_prev()
            end,
        },
        ["TITLECARDS"] = {
            [keys.Down] = function()
                fp.title_card_bar:down()
            end,
            [keys.Left] = function()
                fp.title_card_bar:left()
            end,
            [keys.Right] = function()
                fp.title_card_bar:right()
            end,
            [keys.Return] = function()
                fp.title_card_bar:enter()
            end,
            [keys.F8] = function()
                fp.title_card_bar:go_to_options()
            end,
            [keys.BLUE] = function()
                fp.title_card_bar:go_to_options()
            end,
        }
    }
