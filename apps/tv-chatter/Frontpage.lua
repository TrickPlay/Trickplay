
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
local fp_group = Group{}
screen:add(fp_group)



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
Titlecards_Bar = Class(function(self,parent,...)
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
    local focus   = Rectangle{w=title_card_w+20,h=title_card_h+20,color="#FFFFFF",y=clip.y-10,x=-10}
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
                focus.x = (vis_loc-1)*(title_card_w+title_card_spacing) - 10
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
                focus.x = (vis_loc-1)*(title_card_w+title_card_spacing) - 10
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
end)

--Container for the Listings
Listings = Class(function(self,...)

    local listing_h           = 69
    
    local group = Group
    {
        x = gutter_sides,
        y = bottom_containers_y
    }
    local title    = Image{src="assets/listings.png"}
   
    local bg = make_bg(704,592,   0,title.h+5)
    
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
        y    = bg_unsel.y+23,
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
        bg_sel.opacity   = 255
        bg_unsel.opacity = 0
        
        if #listings > 0 then
            focus_o.opacity=255
            listings[list_i].show_name.color  = "#000000"
            listings[list_i].show_time.color  = "#000000"
            listings[list_i].tv_station.color = "#000000"
        end
        fp.tweetstream:display(listings[list_i].obj)
    end
    function self:lose_focus()
        bg_sel.opacity   = 0
        bg_unsel.opacity = 255
        
        if #listings > 0 then
            focus_o.opacity=0
            listings[list_i].show_name.color  = Show_Name_Color
            listings[list_i].show_time.color  = Show_Time_Color
            listings[list_i].tv_station.color = TV_Station_Color
        end
    end
    function rgb(r,g,b)
        return
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

    
    
end)

--Container for the TweetStream
TweetStream = Class(function(self,...)
    
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
    local streams = {}
    
    local bg = make_bg(1086,592,   0,title.h+22)
    local bg = Canvas{size={1086,592},x=0,y=title.h+22}

    
    local top_rule    = Image{src="assets/object_tweetstream_top_Shadow.png",x = 366, y=bg.y+123}
    local side_shadow = Image{src="assets/object_tweetstream_side_Shadow.png",x = 348, y=bg.y+1}
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
    group:add(bg,title,show_name,show_desc,tv_station,show_time,top_rule,side_shadow,bottom_rule)
    fp_group:add(group)
    
    
    function self:display(show_obj)
        
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
            add_image.x = 2
            group:add(add_image)
        end
    end
end)


fp={
    title_card_bar     = Titlecards_Bar(),
    listings_container = Listings(),
    tweetstream        = TweetStream(),
    focus              = "TITLECARDS",
    keys = {
        ["LISTINGS"] = {
            [keys.Down] = function()
                fp.listings_container:down()
            end,
            [keys.Up] = function()
                fp.listings_container:up()
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
        }
    }
}
