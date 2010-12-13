
--all hardcoded numbers are from the spec
local gutter_sides        = 50
local top_gutter          = 26
local bottom_gutter       = 20
local mediaplayer_w       = 1308
local mediaplayer_h       = 735
local mediaplayer_y       = 124
local banner_y            = mediaplayer_y + mediaplayer_h + 25







--the group for the show page
sp_group = Group{}
screen:add(sp_group)
sp_group:hide()

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
bg:fill()

bg:move_to(gutter_sides,              mediaplayer_y)
bg:line_to(gutter_sides+mediaplayer_w,mediaplayer_y)
bg:line_to(gutter_sides+mediaplayer_w,mediaplayer_y+mediaplayer_h)
bg:line_to(gutter_sides,              mediaplayer_y+mediaplayer_h)
bg:line_to(gutter_sides,              mediaplayer_y)

bg.op = "CLEAR"
bg:fill()

bg:finish_painting()
sp_group:add(bg)
end


--Load in the stationary assets for the Show Page
--using a do-end to toss the locals once they're loaded
do
    --Upper Left
    local logo          = Image{src="assets/logo.png",    x = gutter_sides,
                                                          y = top_gutter}
    local scale = (mediaplayer_y - top_gutter - 11)/logo.h
    logo.scale={scale,scale}
    --Upper Right
    local up_r_spacing = 16
    local up_r_top_gutter = 54

    local show_less = Image{ src="assets/show_less.png", y = up_r_top_gutter }
    local options   = Image{ src="assets/options.png",   y = up_r_top_gutter }
    local back      = Image{ src="assets/back.png",      y = up_r_top_gutter }
    local exit      = Image{ src="assets/exit.png",      y = up_r_top_gutter }
        
    exit.x      = screen_w  - gutter_sides - exit.w
    back.x      = exit.x    - up_r_spacing - back.w
    options.x   = back.x    - up_r_spacing - options.w
    show_less.x = options.x - up_r_spacing - show_less.w
    
    local border = Rectangle
    {
        w            = mediaplayer_w+4,
        h            = mediaplayer_h+4,
        y            = mediaplayer_y-2,
        x            = gutter_sides-2,
        border_width = 2,
        color        = "#00000000",
        border_color = "#B9B9B9FF"
    }

    mediaplayer:load("video/glee-1.mp4")
    mediaplayer.mute = true
    
    function mediaplayer:on_loaded()
        mediaplayer:play()
        
        mediaplayer.mute = true
        mediaplayer:set_viewport_geometry(
            gutter_sides  * screen.scale[1],
            mediaplayer_y * screen.scale[2],
            mediaplayer_w * screen.scale[1],
            mediaplayer_h * screen.scale[2]
        )
        mediaplayer:seek(3000)
        mediaplayer:pause()
    end
    function mediaplayer:on_end_of_stream()
        mediaplayer:seek(0)
        mediaplayer:play()
    end
    sp_group:add(logo,border, recents_title, show_less, options, back, exit)
end

local Banner = Class(function(self,...)
    local group = Group
    {
        x = gutter_sides,
        y = mediaplayer_y + mediaplayer_h + 25
    }
    local banner = Image{src="assets/img_glee_banner.png"}
    group:add(banner)
    sp_group:add(group)
    function self:display(show_obj)
        
    end
end)

--Container for the Options
local Options = Class(function(self,...)

    local listing_h           = 69
    
    local group = Group
    {
        x = screen_w,
        y = bottom_containers_y
    }
    local title    = Image{src="assets/options_tit.png"}
   
    local bg = make_bg(504,592,   0,title.h+5)
    local border_w = 1
    
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
    local grey_rect = Canvas{size={bg.w,listing_h},opacity=0}
          grey_rect:begin_painting()
          grey_rect:move_to(0,0)--border_w,         border_w)
          grey_rect:line_to(grey_rect.w-border_w, border_w)
          grey_rect:line_to(grey_rect.w-border_w, grey_rect.h-border_w)
          grey_rect:line_to(border_w,             grey_rect.h-border_w)
          grey_rect:line_to(0,0)
          grey_rect:set_source_color( "181818" )
	      grey_rect:fill( true )
          grey_rect:set_source_color( "2D2D2D" )
          grey_rect:set_line_width(   border_w )
	      grey_rect:stroke( true )
          grey_rect:finish_painting()
    screen:add(grey_rect)
    
    local focus_o = Image{src="assets/listing_focus.png",opacity=0}
    local focus_n = Clone{source=focus_o,opacity=0}
    
    local Option_Name_Font  = "Helvetica 24px"
    local Option_Name_Color = "#a6a6a6"
    local Option_Sel_Font   = "Helvetica bold 26px"
    local Option_Sel_Color  = "#FFFFFF"

    local listings = {}
    local listings_clip = Group
    {
        y    = bg.y+23,
        clip = { 2, 0,  bg.w-5, bg.h-23*2}
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
        bg,
        title,
        listings_clip,
        arrow_dn,
        arrow_up,
        rules
    )
    
    fp_group:add(group)
    ----------------------------------------------------------------------------
    
    local list_i = 1
    local vis_loc = 1
    local max_on_screen = 8
    function self:add(option)
        local index = #listings + 1
        local opt_name = Text
                {
                    text  = option.name,
                    font  = Option_Name_Font,
                    color = Option_Name_Color,
                    x     = 15,
                    y     = listing_h*(index-.5)
                }
                opt_name.anchor_point={
                    0,--show_name.w/2,
                    opt_name.h/2
                }
        local opt_selection = Text
                {
                    text  = option.default,
                    font  = Option_Sel_Font,
                    color = Option_Sel_Color,
                    x     = bg.x+bg.w-15,
                    y     = listing_h*(index-.5)
                }
                opt_selection.anchor_point={
                    opt_selection.w,
                    opt_selection.h/2
                }

        
            listings_bg:add(Clone{source=grey_rect,y=listing_h*(index-1)})
        
        table.insert(listings,
            {
                opt        = option,
                name  = opt_name,
                opt_selection  = opt_selection,
            }
        )
        
        listings_g:add(opt_name, opt_selection)
        if #listings > max_on_screen then
            arrow_dn.opacity=255
        end
    end
    
    self:add({name="Scroll Speed", default="Medium"})
    self:add({name="Filter Tweets", default="Celebrities"})
    self:add({name="Zip Code", default="94109"})
    self:add({name="Cable Provider", default="Cox"})
    self:add({name="Twitter Account", default="JohnnyApples"})
    local prev = nil
    local prev_f = nil
    
    
    function self:receive_focus(p,f)
        prev = p
        prev_f = f
        --bg_sel.opacity   = 255
        --bg_unsel.opacity = 0
        if #listings > 0 then
            focus_o.opacity=255
            listings[list_i].name.color  = "#000000"
            listings[list_i].opt_selection.color  = "#000000"
        end
        fp.listings_container:move_x_by(-(bg.w+50))
        fp.tweetstream:move_x_by(-(bg.w+50))
        group.x = group.x - (bg.w+50)
        --fp.tweetstream:display(listings[list_i].obj)
    end
    function self:lose_focus()
        --bg_sel.opacity   = 0
        --bg_unsel.opacity = 255
        if #listings > 0 then
            focus_o.opacity=0
            listings[list_i].name.color  = Option_Name_Color
            listings[list_i].opt_selection.color  = Option_Sel_Color
        end
        fp.listings_container:move_x_by((bg.w+50))
        fp.tweetstream:move_x_by((bg.w+50))
        group.x = group.x + (bg.w+50)
    end
    
    local highlight_timeline = nil
    function self:move_highlight_to(old_i,new_i)
        focus_n.y = (new_i-1)*listing_h
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
        local to_a6   = 166
        function highlight_timeline:on_new_frame(msecs,prog)
            to_max  = 255*(prog)
            to_zero = 255*(1-prog)
            to_a6   = 166*(prog)
            listings[new_i].name.color  = {to_zero,to_zero,to_zero}
            listings[new_i].opt_selection.color  = {to_zero,to_zero,to_zero}
            listings[old_i].name.color  = {to_a6,to_a6,to_a6}
            listings[old_i].opt_selection.color  = {to_max,to_max,to_max}
            focus_n.opacity = to_max
            focus_o.opacity = to_zero
        end
        function highlight_timeline:on_completed()
            focus_n.opacity = 0
            focus_o.opacity = 255
            focus_o.y = focus_n.y
            listings[new_i].name.color  = {0,0,0}
            listings[new_i].opt_selection.color  = {0,0,0}
            listings[old_i].name.color  = {166,166,166}
            listings[old_i].opt_selection.color  = {255,255,255}
            highlight_timeline = nil
        end
        highlight_timeline:start()
        list_i = new_i
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
            if vis_loc == 1 then
                self:move_list(-(list_i -1)*(grey_rect.h))
                arrow_dn.opacity=255
                if list_i == 1 then
                    arrow_up.opacity=0
                end
            else
                vis_loc = vis_loc - 1
                
                if vis_loc == 1 then
                    self:move_list(-(list_i -1)*(grey_rect.h))
                end
            end
        else
        --[[
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
            --]]
        end
    end
    
    function self:down()
        if list_i + 1 <= #listings then
            self:move_highlight_to(list_i,list_i + 1)
            if vis_loc == max_on_screen then
                self:move_list(-(list_i -max_on_screen)*(grey_rect.h))
                arrow_up.opacity=255
                if list_i == #listings then
                    arrow_dn.opacity=0
                end
            else
                vis_loc = vis_loc + 1
                
                if vis_loc == max_on_screen then
                    self:move_list(-(list_i -max_on_screen)*(grey_rect.h))
                end
            end
        end
    end
    function self:return_to_prev()
        self:lose_focus()
        prev:receive_focus()
        sp.focus = prev_f
    end
--[[
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
        listings[list_i].obj.tweetstream:receive_focus()
    end
    --]]
end)

--Container for the TweetStream
local TweetStream_Container = Class(function(self,...)
    
    local group = Group
    {
        x = gutter_sides + mediaplayer_w + 25,
        y = mediaplayer_y
    }
    local title   = Image{src="assets/tweetstream.png"}
    
    local Show_Name_Font  = "Helvetica bold 26px"
    local Show_Name_Color = "#FFFFFF"
    
    local bg = make_bg(
        screen_w - group.x - gutter_sides,
        screen_h - (group.y + title.h+22+bottom_gutter),
        0,title.h+22
    )
    
    
    local show_name = Text{
        text  = "show_name",
        font  = Show_Name_Font,
        color = Show_Name_Color,
        x     = 15,
        y     = bg.y+19
    }
    local tv_station = Text{
        text  = "tv_station",
        font  = TV_Station_Font,
        color = TV_Station_Color,
        x     = bg.w-15,
        y     = bg.y+19
    }
    tv_station.x = tv_station.x - tv_station.w
    local show_time = Text{
        text  = "show_time",
        font  = Show_Time_Font,
        color = Show_Time_Color,
        x     = tv_station.x -30,
        y     = bg.y+19
    }
    
    
    local top_rule    = Image{src="assets/sp_top_rule.png",x = 15, y=show_name.y+show_name.h+19}
    local bottom_rule = Image{src="assets/sp_shadow.png"}
    bottom_rule.y = bg.y + bg.h - bottom_rule.h-2
    bottom_rule.x = bg.w-bottom_rule.w
    local wallpaper = Image{src="assets/sp_tweetstream_container.png",x=3,y=top_rule.y, w = bg.w-6}
    show_time.x = show_time.x - show_time.w
    group:add(bg,wallpaper,title,show_name,tv_station,show_time,top_rule,bottom_rule)
    sp_group:add(group)
    
    local curr_obj = nil
    
    function self:going_back()
        page = "fp"
        sp_group:hide()
        fp_group:show()
        curr_obj.tweetstream:get_group():unparent()
        curr_obj.tweetstream:lose_focus()
        curr_obj.tweetstream:out_view()
        fp.tweetstream:display(curr_obj)
        curr_obj = nil
    end
    function self:go_to_minimized()
        page = "mp"
        sp_group:hide()
        mp_group:show()
        curr_obj.tweetstream:get_group():unparent()
        curr_obj.tweetstream:lose_focus()
        curr_obj.tweetstream:out_view()
        mp.tweetstream:display(curr_obj)
        curr_obj = nil
    end
    function self:display(show_obj)
        
        curr_obj = show_obj
        
        show_name.text  = show_obj.show_name
        
        tv_station.x    = tv_station.x + tv_station.w
        tv_station.text = show_obj.tv_station
        tv_station.x    = tv_station.x - tv_station.w
        
        show_time.x     = show_time.x + show_time.w
        show_time.text  = show_obj.show_time
        show_time.x     = show_time.x - show_time.w
        
        
        curr_obj.tweetstream:set_h(bg.h-(top_rule.y-bg.y)-10)
        curr_obj.tweetstream:set_w(bg.w-30)
        curr_obj.tweetstream:set_pos(15,top_rule.y)
        group:add( curr_obj.tweetstream:get_group() )
        --for i = 1,#curr_obj.tweet_g_cache do
        --    tweet_clip:add(curr_obj.tweet_g_cache[i].group)
        --end
        curr_obj.tweetstream:in_view()
        
    end
    function self:up()
        if curr_obj ~= nil then
            curr_obj.tweetstream:move_up()
        end
    end
    function self:down()
        if curr_obj ~= nil then
            curr_obj.tweetstream:move_down()
        end
    end

    function self:go_to_options()
        fp.focus = "OPTIONS"
        self:lose_focus()
        fp.options:receive_focus(fp.title_card_bar,"TITLECARDS")
    end
end)
sp = {
    tweetstream = TweetStream_Container(),
    banner      = Banner(),
    --options    = Options(),
    focus       = "TWEETSTREAM",
    keys        = {
    --[[
        ["BANNER"] = {
            [keys.Down] = function()
                sp.banner:down()
            end,
            [keys.Up] = function()
                sp.banner:up()
            end,
            [keys.Return] = function()
                sp.banner:enter()
            end,
        },
        ["OPTIONS"] = {
            [keys.Down] = function()
                sp.options:down()
            end,
            [keys.Up] = function()
                sp.options:up()
            end,
            [keys.Return] = function()
                sp.options:enter()
            end,
            [keys.F10] = function()
                sp.options:return_to_prev()
            end,
        },
        --]]
        ["TWEETSTREAM"] = {
            [keys.Down] = function()
                sp.tweetstream:down()
            end,
            [keys.Up] = function()
                sp.tweetstream:up()
            end,
            [keys.Return] = function()
                --sp.tweetstream:enter()
            end,
            --[[
            [keys.BackSpace] = function()
                sp.tweetstream:going_back()
            end,
            --]]
            [keys.BACK] = function()
                sp.tweetstream:going_back()
            end,
            [keys.F9] = function()
                sp.tweetstream:going_back()
            end,
            [keys.YELLOW] = function()
                sp.tweetstream:go_to_minimized()
            end,
            [keys.F7] = function()
                sp.tweetstream:go_to_minimized()
            end,
            [keys.F8] = function()
                sp.tweetstream:go_to_options()
            end,
            [keys.p] = function()
                if mediaplayer.state == mediaplayer.PAUSED then
                    mediaplayer:play()
                else
                    mediaplayer:pause()
                end
            end,
        }
    }
}