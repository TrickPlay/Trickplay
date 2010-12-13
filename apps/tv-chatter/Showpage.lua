
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

end)
sp = {
    tweetstream = TweetStream_Container(),
    banner      = Banner(),
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
            [keys.BackSpace] = function()
                sp.tweetstream:going_back()
            end,
            [keys.YELLOW] = function()
                sp.tweetstream:go_to_minimized()
            end,
            [keys.F11] = function()
                sp.tweetstream:go_to_minimized()
            end,
        }
    }
}