
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
    local focus   = Image{src="assets/tile-focus.png",y=clip.y-14,x=-14}
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
                focus.x = (vis_loc-1)*(title_card_w+title_card_spacing) -14
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
                focus.x = (vis_loc-1)*(title_card_w+title_card_spacing) - 14
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
        bar_items[list_i].tweetstream:receive_focus()
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
   
    local bg = make_bg(704,592,   0,title.h+5)
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
    
    local Show_Name_Font  = "Helvetica bold 26px"
    local Show_Name_Color = "#FFFFFF"

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
    function self:add(show_obj)
        local index = #listings + 1
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
                    text  = show_obj.show_time,
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
        
        if index%2 == 0 then
            listings_bg:add(Clone{source=grey_rect,y=listing_h*(index-1)})
        end
        
        table.insert(listings,
            {
                obj        = show_obj,
                show_name  = show_name,
                show_time  = show_time,
                tv_station = tv_station
            }
        )
        
        listings_g:add(show_name, show_time, tv_station)
        if #listings > max_on_screen then
            arrow_dn.opacity=255
        end
    end
    
    
    function self:receive_focus()
        --bg_sel.opacity   = 255
        --bg_unsel.opacity = 0
        
        if #listings > 0 then
            focus_o.opacity=255
            listings[list_i].show_name.color  = "#000000"
            listings[list_i].show_time.color  = "#000000"
            listings[list_i].tv_station.color = "#000000"
        end
        fp.tweetstream:display(listings[list_i].obj)
    end
    function self:lose_focus()
        --bg_sel.opacity   = 0
        --bg_unsel.opacity = 255
        
        if #listings > 0 then
            focus_o.opacity=0
            listings[list_i].show_name.color  = Show_Name_Color
            listings[list_i].show_time.color  = Show_Time_Color
            listings[list_i].tv_station.color = TV_Station_Color
        end
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
        function highlight_timeline:on_new_frame(msecs,prog)
            to_max  = 255*(prog)
            to_zero = 255*(1-prog)
            listings[new_i].show_name.color  = {to_zero,to_zero,to_zero}
            listings[new_i].show_time.color  = {to_zero,to_zero,to_zero}
            listings[new_i].tv_station.color = {to_zero,to_zero,to_zero}
            listings[old_i].show_name.color  = {to_max,to_max,to_max}
            listings[old_i].show_time.color  = {to_max,to_max,to_max}
            listings[old_i].tv_station.color = {to_max,to_max,to_max}
            focus_n.opacity = to_max
            focus_o.opacity = to_zero
        end
        function highlight_timeline:on_completed()
            focus_n.opacity = 0
            focus_o.opacity = 255
            focus_o.y = focus_n.y
            listings[new_i].show_name.color  = {0,0,0}
            listings[new_i].show_time.color  = {0,0,0}
            listings[new_i].tv_station.color = {0,0,0}
            listings[old_i].show_name.color  = {255,255,255}
            listings[old_i].show_time.color  = {255,255,255}
            listings[old_i].tv_station.color = {255,255,255}
            highlight_timeline = nil
            fp.tweetstream:display(listings[new_i].obj)
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
            print(list_i)
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
    function self:move_x_by(x)
        group.x = group.x + x
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
        fp.focus = prev_f
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
    local bg = make_bg(1086,592,   0,title.h+22)
    --local bg = Canvas{size={1086,592},x=0,y=title.h+22}
    local wallpaper = Image{src="assets/fp_tweetstream_container.png",y=title.h+22}
    
    --local tweet_clip = Group{clip={0,0,bg.w-368,bg.h-127},x=366,y=bg.y+125}
    local top_rule    = Image{src="assets/object_tweetstream_top_Shadow.png",x = 366, y=bg.y+123}
    local bottom_rule = Image{src="assets/object_tweetstream_bottom_Shadow.png",x=346}
    bottom_rule.y = bg.y + bg.h - bottom_rule.h-2
    
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
    group:add(bg,wallpaper,title,show_name,show_desc,tv_station,show_time,top_rule,bottom_rule)
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
        show_time.text  = show_obj.show_time
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
                curr_obj.tweetstream:set_w(bg.w-368)
                curr_obj.tweetstream:set_h(bg.h-127-20)
                curr_obj.tweetstream:set_pos(366,bg.y+125+15)
                group:add( curr_obj.tweetstream:get_group() )
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
                curr_obj.tweetstream:set_w(bg.w-30)
                curr_obj.tweetstream:set_h(bg.h-127-30)
                curr_obj.tweetstream:set_pos(15,bg.y+125+15)
                group:add( curr_obj.tweetstream:get_group() )
                --for i = 1,#curr_obj.tweet_g_cache do
                --    tweet_clip:add(curr_obj.tweet_g_cache[i].group)
                --end
                curr_obj.tweetstream:in_view()
            end
        end
    end
end)


fp={
    title_card_bar     = Titlecards_Bar(),
    listings_container = Listings(),
    tweetstream        = TweetStream_Container(),
    options            = Options(),
    focus              = "TITLECARDS",
    keys = {
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
            [keys.F10] = function()
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
}
