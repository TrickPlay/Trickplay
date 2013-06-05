
local column_width = screen_w/6
bar_height = 148
local channel_header_h = bar_height--200
local visible_height = screen_h - channel_header_h
local pixel_height_of_an_hour = 300
local pixel_height_of_a_second = pixel_height_of_an_hour/(60*60)
-------------------------------------------------------------------
epg_anim_in_duration = 1000
devtools:fps()
epg = Group()

local livetv_bg  = Sprite{
            sheet = ui_sprites,
            id = "channelbar/channel-bar.png",
            w      = screen_w,
            h      = channel_header_h,
        }

local layers = {
    channel_bg   = Group{name="Channel Background Layer",children={
        Sprite{
            sheet  = ui_sprites,
            id     = "epg/epg-behind-channel-bg.png",
            w      = screen_w,
            h      = channel_header_h,
        },
        livetv_bg
    }},
    channel_text = Group{name="Channel Text Layer"},
    time_column  = Group{name="Time Slots Layer"},
    time_bg      = Group{name="Time Background Layer"},
}
epg:add(
    layers.channel_bg,
    layers.time_bg,
    layers.channel_text,
    layers.time_column
)


local function y_from_time(t)

    return (os_time(t) - start_of_data__seconds)* pixel_height_of_a_second

end

local start_y = y_from_time(curr_time) - pixel_height_of_an_hour*1
local hard_y_limit_top = start_y - pixel_height_of_an_hour*3
local hard_y_limit_btm = start_y + pixel_height_of_an_hour*12
---------------------------------------------------------------
local dur_slide_up_down = 300
---------------------------------------------------------------
local old_show_tiles = {}
local function make_show_tile(show_data)
    local grey_color = "dedddd"
    local orange_color = "e0ba95"
    local darker_grey = "b5b5b4"



    local   focused_show_name_font = FONT_BOLD.." 24px"
    local unfocused_show_name_font = FONT.." 24px"

    local padding = 15
    local show_tile_txt = Group{
        name = "Show Tile: Text: "..show_data.show_name,
        y = y_from_time(show_data.start_time_t),
    }
    local show_tile_bg = Group{
        name = "Show Tile: BG: "..show_data.show_name,
        y = y_from_time(show_data.start_time_t),
    }
    local text_w = column_width-(2*padding)
    local show_name = Text{
        text  = show_data.show_name,
        font  = unfocused_show_name_font,
        color = grey_color,
        y     = padding-5,
        w     = text_w,
        ellipsize = "END"
    }
    local show_name_s = Text{
        text  = show_data.show_name,
        font  = unfocused_show_name_font,
        color = "black",
        opacity = 255*.25,
        x     = show_name.x+2,
        y     = show_name.y+2,
        w     = text_w,
        ellipsize = "END"
    }
    local unfocus = Sprite{
        sheet   = ui_sprites,
        id      = "epg/epg-non-focus.png",
        w       = column_width,
        h       = pixel_height_of_an_hour*show_data.duration/60,
    }
    local focus = Sprite{
        sheet   = ui_sprites,
        id      = "epg/epg-focus-blue.png",
        x       = 2,
        w       = column_width-2,
        h       = pixel_height_of_an_hour*show_data.duration/60,
        opacity = 0,
    }
    show_tile_txt.h = unfocus.h
    show_tile_bg.h = unfocus.h
    -----------------------------------------------------------
    local more_info = Group{name="More Info",y=show_name.y+show_name.h+10,opacity=0}
    local episode_name = show_data.episode_name ~= json_null and Text{
        w         = text_w,
        ellipsize = "END",
        color     = orange_color,
        font      = FONT_BOLD.." 18px",
        text      = show_data.episode_name,
    } or false
    local description = Text{
        y=episode_name and
            (episode_name.y+episode_name.h+10) or 0,
        wrap=true,
        wrap_mode = "WORD",
        ellipsize = "END",
        w=text_w,
        color = grey_color,
        font = FONT.." 18px",
        text = show_data.show_description,
    }
    description.h = show_tile_txt.h - description.y - more_info.y-padding
    if episode_name then
        more_info:add(episode_name,description)
    else
        more_info:add(description)
    end
    local text = Group{x=padding}
    text:add(--[[show_name_s,]]show_name)

    show_tile_txt:add(
        text
    )
    show_tile_bg:add(
        unfocus
        --Rectangle{w=column_width,h=2,color="red"},
        --Rectangle{w=column_width,h=2,color="red",y=show_tile.h},
    )
    -----------------------------------------------------------

    local anim = AnimationState {
                        duration = 250,
                        mode = "EASE_OUT_SINE",
                        transitions = {
                            {
                                source = "*",
                                target = "focus",
                                keys = {
                                    --{ show_name,    "color", "green" },
                                    { more_info,  "opacity",   255 },
                                    { focus,  "opacity",   255 },
                                },
                            },
                            {
                                source = "*",
                                target = "unfocus",
                                keys = {
                                    --{ show_name,    "color",   "white" },
                                    { more_info,  "opacity", 0 },
                                    { focus,  "opacity",     0 },
                                },
                            },
                        },
    }---[[
    local on_focus_change_completed
    function anim.timeline.on_started(self)
        if anim.state == "focus" then
            show_tile_bg:add(focus)
            text:add(more_info)
        end
    end
    function anim.timeline.on_completed(self)
        if anim.state == "unfocus" then
            more_info:unparent()
            focus:unparent()
        end
        return on_focus_change_completed and on_focus_change_completed()
    end
    --]]
    function show_tile_txt:move_text_to(y)--[[
        text:animate{
            duration = dur_slide_up_down,
            mode = "EASE_OUT_SINE",
            y = y,
        }--]]
        return {
            {
                source = text,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE", text.y},
                    {1.0,"EASE_OUT_SINE",      y},
                },
            },
        }
    end
    function show_tile_txt:unfocus(f)
        on_focus_change_completed = f
        anim.state = "unfocus"
        show_name.font = unfocused_show_name_font
        show_name_s.font = unfocused_show_name_font
    end
    function show_tile_txt:focus()
        on_focus_change_completed = nil
        anim.state = "focus"
        show_name.font = focused_show_name_font
        show_name_s.font = focused_show_name_font
    end
    function show_tile_txt:warp_unfocus()
        on_focus_change_completed = nil
        anim:warp("unfocus")
        show_name.font = unfocused_show_name_font
        show_name_s.font = unfocused_show_name_font
    end
    function show_tile_txt:warp_focus()
        on_focus_change_completed = nil
        anim:warp("focus")
        show_name.font = focused_show_name_font
        show_name_s.font = focused_show_name_font
    end
    -----------------------------------------------------------
    function show_tile_bg:animate_w( before,after )
        focus.w = before
        unfocus.w = before
        return {
            {
                source = focus,
                name   = "w",
                keys   = {
                    {0.0,"EASE_OUT_SINE",before},
                    {1.0,"EASE_OUT_SINE", after},
                },
            },
            {
                source = unfocus,
                name   = "w",
                keys   = {
                    {0.0,"EASE_OUT_SINE",before},
                    {1.0,"EASE_OUT_SINE", after},
                },
            },
        }
    end
    show_tile_txt.show_data = show_data
    return show_tile_txt, show_tile_bg
end
---------------------------------------------------------------
--------- Constructor for Channel Columns ---------------------
---------------------------------------------------------------
local function make_channel(y,channel_data,channel_num)
    local channel_txt = Group{name = "Column Text: CH"..channel_num}
    local channel_bg  = Group{name = "Column BG: CH"  ..channel_num}
    -----------------------------------------------------------

    channel_txt.data = channel_data

    local header = Group{name = "Channel Header"}
    local header_channel_num = Text{
        color = "grey35",
        text  = channel_num,
        font = FONT .." 192px",
        x     = 15,
        y     = channel_header_h/2-8,
    }
    header_channel_num.anchor_point={
        0,header_channel_num.h/2}
    local logo = Sprite{
        sheet = ui_sprites,
        id = "channel-logos/"..channel_data.id..".png",
        scale = {.5,.5},
    }
    logo.position = {column_width,channel_header_h}
    logo.anchor_point = {logo.w,logo.h}
    local header_bg = Sprite{
        sheet  = ui_sprites,
        id     = "epg/epg-behind-channel-bg.png",
        w      = column_width+2,
        h      = channel_header_h,
    }
    local ch_divider = Sprite{
        sheet  = ui_sprites,
        id     = "epg-line-btwn-channels.png",
        y      = channel_header_h,
        x      = -1,
    }
    ch_divider.y = ch_divider.y - ch_divider.h
    header:add(
        --header_bg,
        header_channel_num,
        logo,
        ch_divider
    )

    local ch_anim = AnimationState {
                        duration = 250,
                        mode = "EASE_OUT_SINE",
                        transitions = {
                            {
                                source = "*",
                                target = "focus",
                                keys = {
                                    { header_channel_num,  "opacity",   255 },
                                    { logo,  "opacity",   255 },
                                },
                            },
                            {
                                source = "*",
                                target = "unfocus",
                                keys = {
                                    { header_channel_num,  "opacity", 64 },
                                    { logo,  "opacity",     64 },
                                },
                            },
                        },
    }
    -----------------------------------------------------------
    local bgs_group_offset = Group{name="offset",y=channel_header_h}
    local bgs_group = Group()
    bgs_group_offset:add(bgs_group,
        Rectangle{w=2,h=visible_height,color="black"})
    -----------------------------------------------------------
    local shows_group_offset = Group{name="offset",y=channel_header_h}
    local shows_group = Group()
    shows_group_offset:add(shows_group)
    -----------------------------------------------------------
    channel_txt:add(
        shows_group_offset,
        header
    )
    channel_bg:add(bgs_group_offset)

    local top_i,btm_i, sel_i, show_i_offset
    local top_y_limit = y
    local btm_y_limit = top_y_limit+visible_height
    local selected_y  = visible_height/2+top_y_limit- pixel_height_of_an_hour/2
    local curr_selected
    local n = #channel_data.schedule
    local shows = {}
    local function update_selected()
        local prev_selected = curr_selected
        for i,show in ipairs(shows) do
            if show.txt.y <= selected_y and selected_y <= (show.txt.y+show.txt.h) then
                sel_i = top_i-1+i

                if curr_selected ~= shows[i] then
                    if curr_selected then
                        curr_selected.txt:unfocus(
                            shows[i] and shows[i].txt.focus or nil
                        )
                    end
                    curr_selected = shows[i]
                end
                break
            end
        end
        if prev_selected == curr_selected then

        end
    end
    function channel_txt:selected()
        return curr_selected.txt.show_data
    end
    function channel_txt:focus_selected()
        return curr_selected.txt:focus()
    end
    function channel_txt:unfocus_selected()
        return curr_selected.txt:unfocus()
    end

    function channel_txt:prev_show_dy()
        for i,show in ipairs(shows) do
            if show == curr_selected then
                return i>1 and shows[i-1].bg.h
            end
        end
    end
    function channel_txt:next_show_dy()
        return curr_selected.bg.h
    end
    -----------------------------------------------------------
    function channel_txt:focus()
        ch_anim.state = "focus"
    end
    function channel_txt:unfocus()
        ch_anim.state = "unfocus"
    end
    ch_anim:warp("unfocus")
    -----------------------------------------------------------
    local function add_show(show_i,insert_i)
        local show_txt, show_bg =
            make_show_tile(
                channel_data.schedule[show_i]
            )
        if insert_i then
            table.insert(shows,insert_i, {txt=show_txt, bg=show_bg})
        else
            table.insert(shows, {txt=show_txt, bg=show_bg})
        end
        shows_group:add(show_txt)
        bgs_group:add(show_bg)
    end
    -----------------------------------------------------------
    function channel_txt:add_past_shows(dy)
        local new_limit = top_y_limit - dy
        selected_y  = selected_y  - dy
        while #shows==0 or (new_limit < shows[1].txt.y) do
            if (top_i-1) < 1 then break end
            top_i = top_i - 1

            add_show(top_i,1)
        end
        update_selected()
        local props = channel_txt:check_shift_selected_up(dy)
        top_y_limit = new_limit
        return props
    end
    function channel_txt:add_future_shows(dy)
        btm_y_limit = btm_y_limit + dy
        selected_y  = selected_y  + dy
        while #shows==0 or (btm_y_limit > (shows[#shows].txt.y+shows[#shows].txt.h)) do
            if (btm_i+1) > n then break end
            btm_i = btm_i + 1

            add_show(btm_i)
        end
        update_selected()

    end
    function channel_txt:remove_past_shows(dy)
        top_y_limit = top_y_limit + dy
        while #shows~=0 and (top_y_limit >= (shows[1].txt.y+shows[1].txt.h)) do
            if (top_i+1) > n then break end
            top_i = top_i + 1

            local t = table.remove(shows,1)
            t.txt:unparent()
            t.bg:unparent()

        end
    end
    function channel_txt:remove_future_shows(dy)
        btm_y_limit = btm_y_limit - dy
        while #shows~=0 and (btm_y_limit < shows[#shows].txt.y) do
            if (btm_i-1) < 1 then break end
            btm_i = btm_i - 1

            local t = table.remove(shows,#shows)
            t.txt:unparent()
            t.bg:unparent()

        end
    end
    -----------------------------------------------------------

    function channel_txt:find_text_on_edge(y)
        local i =1
        local s_t_top, s_t_btm
        while shows[i] do
            s_t_top = shows[i].txt.y
            s_t_btm = shows[i].txt.h + s_t_top
            if s_t_top == y then
                --the top edge of this show matches the edge

                --this means no show straddles the edge
                return false
            elseif s_t_top < y and s_t_btm > y then
                --this show straddles the edge
                if s_t_btm - y > pixel_height_of_an_hour*10/60 then
                    --the bottom of this show hangs far enough
                    --below the edge to warrant moving the text
                    return shows[i]
                else
                    --this means the show didn't hang low enough
                    return false
                end
            end
            i = i + 1
        end
        --this would only happen if no shows
        return false
    end
    function channel_txt:shift_text(old_y,new_y)
        local old_show = self:find_text_on_edge(old_y)
        local new_show = self:find_text_on_edge(new_y)

        local animator_properties = {}
        if  old_show and old_show ~= new_show then
            for i,t in ipairs(old_show.txt:move_text_to( 0 )) do
                table.insert(animator_properties,t)
            end
        end
        if  new_show then
            for i,t in ipairs(new_show.txt:move_text_to( new_y - new_show.txt.y )) do
                table.insert(animator_properties,t)
            end
        end
        return animator_properties
    end
    function channel_txt:check_shift_selected_up(dy)
        return self:shift_text(top_y_limit,top_y_limit - dy)
    end
    function channel_txt:check_shift_selected_down(dy)
        return self:shift_text(top_y_limit,top_y_limit + dy)
    end
    -----------------------------------------------------------
    function channel_txt:slide(dy,f)
        return{
            {
                source = shows_group,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",shows_group.y},
                    {1.0,"EASE_OUT_SINE",shows_group.y+dy},
                },
            },
            {
                source = shows_group,
                name   = "clip",
                keys   = {
                    {0.0,"EASE_OUT_SINE",shows_group.clip},
                    {1.0,"EASE_OUT_SINE",{
                            0,-(shows_group.y+dy),screen_w,
                            screen_h - channel_header_h
                        }
                    },
                },
            },
            {
                source = bgs_group,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",bgs_group.y},
                    {1.0,"EASE_OUT_SINE",bgs_group.y+dy},
                },
            },
            {
                source = bgs_group,
                name   = "clip",
                keys   = {
                    {0.0,"EASE_OUT_SINE",shows_group.clip},
                    {1.0,"EASE_OUT_SINE",{
                            0,-(shows_group.y+dy),screen_w,
                            screen_h - channel_header_h
                        }
                    },
                },
            },
        }
    end
    function channel_txt:pump(dy)
        return{
            {
                source = shows_group,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",shows_group.y},
                    {0.5,"EASE_OUT_SINE",shows_group.y+dy},
                    {1.0,"EASE_IN_SINE",shows_group.y},
                },
            },
            {
                source = shows_group,
                name   = "clip",
                keys   = {
                    {0.0,"EASE_OUT_SINE",shows_group.clip},
                    {0.5,"EASE_OUT_SINE",{
                            0,-(shows_group.y+dy),screen_w,
                            screen_h - channel_header_h
                        }
                    },
                    {1.0,"EASE_IN_SINE",shows_group.clip},
                },
            },
            {
                source = bgs_group,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",bgs_group.y},
                    {0.5,"EASE_OUT_SINE",bgs_group.y+dy},
                    {1.0,"EASE_IN_SINE",bgs_group.y},
                },
            },
            {
                source = bgs_group,
                name   = "clip",
                keys   = {
                    {0.0,"EASE_OUT_SINE",shows_group.clip},
                    {0.5,"EASE_OUT_SINE",{
                            0,-(shows_group.y+dy),screen_w,
                            screen_h - channel_header_h
                        }
                    },
                    {1.0,"EASE_IN_SINE",shows_group.clip},
                },
            },
        }
    end
    -----------------------------------------------------------
    function channel_txt:prep_column_for_anim_out()
        local logo_x = math.max(
            30+logo.w/2*logo.scale[1],
            header_channel_num.x+ header_channel_num.w/2
        )
        local st_x =  math.max(
            (logo_x + logo.w/2*logo.scale[1] + 15),
            (header_channel_num.x + header_channel_num.w + 5)
        )

        local show_text = Text {
            color = "white",
            text = channel_data.on_now.show_name,
            font = FONT.." 40px",
            opacity = 0,
        }
        show_text.anchor_point = { 0, show_text.h/2 }
        show_text.position = { st_x, bar_height/2 }
        local r_w =  math.max(header_channel_num.w,show_text.x +show_text.w) + 30
        channel_bg.targ_w = r_w
        local livetv_bg = Sprite{
            sheet = ui_sprites,
            id = "channelbar/channel-bar.png",
            size   = header_bg.size,
            opacity = 0,
        }
        header:add( show_text )
        local properties = {
            {
                source = ch_divider, name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",255},
                    {1.0,"EASE_OUT_SINE", 0},
                },
            },
            {
                source = header_channel_num, name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",255},
                    {1.0,"EASE_OUT_SINE", 64},
                },
            },
            {
                source = logo, name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",255},
                    {1.0,"EASE_OUT_SINE", 64},
                },
            },
            {
                source = show_text, name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",  0},
                    {1.0,"EASE_OUT_SINE", 64},
                },
            },
            {
                source = header_channel_num, name   = "color",
                keys   = {
                    {0.0,"EASE_OUT_SINE","505052"},
                    {1.0,"EASE_OUT_SINE","grey35"},
                },
            },
            {
                source = logo, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",column_width},
                    {1.0,"EASE_OUT_SINE",logo_x},
                },
            },
            {
                source = logo, name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",channel_header_h},
                    {1.0,"EASE_OUT_SINE",bar_height/2},
                },
            },
        }
        for i,show in ipairs(shows) do
            for j,t in ipairs(show.bg:animate_w( column_width+2,r_w )) do
                table.insert(properties,t)
            end
        end
        return properties, function()
            show_text:unparent()
        end
    end
    -----------------------------------------------------------
    function channel_txt:prep_column_for_anim_in()
        curr_selected.txt:warp_unfocus()
        header_channel_num.opacity = 64
        logo.opacity = 64
        logo.anchor_point = {logo.w/2, logo.h/2  }
        local logo_x = math.max(
            30+logo.w/2*logo.scale[1],
            header_channel_num.x+ header_channel_num.w/2
        )

        logo.position = { logo_x, bar_height/2 }
        local show_text = Text {
            color = "white",
            text = channel_data.on_now.show_name,
            font = FONT.." 40px",
            opacity = 64,
        }

        local st_x =  math.max(
            (logo.x + logo.w/2*logo.scale[1] + 15),
            (header_channel_num.x + header_channel_num.w + 5)
        )
        show_text.anchor_point = { 0, show_text.h/2 }
        show_text.position = { st_x, bar_height/2 }
        local r_w =  math.max(header_channel_num.w,show_text.x +show_text.w) + 30
        header_bg.opacity = 0
        header_bg.w = r_w
        header:add( show_text )

        ch_divider.opacity = 0
        local properties = {
            {
                source = ch_divider, name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",  0},
                    {1.0,"EASE_OUT_SINE",255},
                },
            },
            {
                source = show_text, name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", 64},
                    {1.0,"EASE_OUT_SINE",  0},
                },
            },
            {
                source = header_channel_num, name   = "color",
                keys   = {
                    {0.0,"EASE_OUT_SINE","grey35"},
                    {1.0,"EASE_OUT_SINE","505052"},
                },
            },
            {
                source = logo, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",logo.x},
                    {1.0,"EASE_OUT_SINE",column_width - logo.w/2*logo.scale[1]},
                },
            },
            {
                source = logo, name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",logo.y},
                    {1.0,"EASE_OUT_SINE",channel_header_h - logo.h/2*logo.scale[2]},
                },
            },
        }
        for i,show in ipairs(shows) do
            for j,t in ipairs(show.bg:animate_w( r_w,column_width+2 )) do
                table.insert(properties,t)
            end
        end
        return properties, function()
            show_text:unparent()
        end
    end
    -----------------------------------------------------------
    for i,show in ipairs(channel_data.schedule) do
        local y = y_from_time(show.start_time_t)
        local h = show.duration/60*pixel_height_of_an_hour
        --if the top of the show at index 'i' is below the
        --bottom of the epg window, then stop
        if y > btm_y_limit then
            btm_i = i-1
            break
        end
        if y+h > top_y_limit then
            top_i = top_i or i

            add_show(i)
            if y > selected_y and sel_i == nil then
                sel_i = i - 1
            end
        end
    end
    if sel_i == nil then sel_i = btm_i end
    show_i_offset = top_i-1
    if shows[sel_i- show_i_offset ] then
        shows[sel_i- show_i_offset ].txt:focus()
        curr_selected = shows[sel_i- show_i_offset ]
        local a = Animator{
            duration = 1,
            properties=channel_txt:check_shift_selected_up(0)
        }
        a:start()
        if channel_data.on_now ~= curr_selected.txt.show_data then
            --print("DOES NOT MATCH",channel_data.on_now.show_name,channel_data.on_now.duration)
            --dumptable(channel_data.on_now.start_time_t)
        end
    end


    shows_group.y = -top_y_limit
    shows_group.clip = {
        0,-(shows_group.y),screen_w,
        screen_h - channel_header_h
    }
    bgs_group.y = -top_y_limit
    bgs_group.clip = {
        0,-(bgs_group.y),screen_w,
        screen_h - channel_header_h
    }
    return channel_txt, channel_bg
end



local the_channels = {}
local time_column  = Group{}
do
    local time_header = Group()
    local time_header_bg = Rectangle{
        w = column_width+3,
        h = channel_header_h,
        color = "black",
    }
    time_header:add(time_header_bg)
    -----------------------------------------------------------
    local time_slots_group_offset = Group{y=channel_header_h}
    local time_slots_group = Group()
    time_slots_group_offset:add(time_slots_group)
    -----------------------------------------------------------
    time_column:add(time_slots_group_offset,time_header)
    local top_y_limit = start_y
    local btm_y_limit = top_y_limit+visible_height
    local selected_y  = visible_height/2+top_y_limit
    local slots = {}


    local focus_i = 3
    local function make_slot(y)
        local t = os.date(
            "*t",

            start_of_data__seconds+
                y/pixel_height_of_an_hour*60*60
        )
        local focused_font = FONT_BOLD.." 32px"
        local unfocused_font = FONT.." 32px"
        local g = Group{
                y         = y,}
        local txt =  Text{
                text      = ampm(t.hour,t.min),
                color     = "white",
                font      = FONT.." 32px",
                wrap      = true,
            }
            txt.anchor_point = {txt.w,txt.h/2}
            txt.position = {column_width-10,txt.h/2}
            g:add(txt)
        local anim = AnimationState {
                duration = dur_slide_up_down,
                mode = "EASE_OUT_SINE",
                transitions = {
                    {
                        source = "*",
                        target = "focus",
                        keys = {
                            { txt,  "scale",   {1.2,1.2} },
                        },
                    },
                    {
                        source = "*",
                        target = "unfocus",
                        keys = {
                            { txt,  "scale", {1,1}},
                        },
                    },
                },
        }

        function g:focus()
            anim.state = "focus"
            txt.font = focused_font
        end
        function g:unfocus()
            anim.state = "unfocus"
            txt.font = unfocused_font
        end

        return g
    end

    function time_column:add_past_shows(dy)
        slots[focus_i]:unfocus()

        slots[focus_i - 1]:focus()
        top_y_limit = top_y_limit - dy
        selected_y  = selected_y  - dy
        while #slots==0 or (top_y_limit < slots[1].y) do

            table.insert(slots,1,
                make_slot(
                    slots[1].y - (pixel_height_of_an_hour/2)
                )
            )
            time_slots_group:add(slots[1])

        end
    end
    function time_column:add_future_shows(dy)
        slots[focus_i]:unfocus()

        slots[focus_i + 1]:focus()
        btm_y_limit = btm_y_limit + dy
        selected_y  = selected_y  + dy
        while #slots==0 or (btm_y_limit > (slots[#slots].y+(pixel_height_of_an_hour/2))) do

            table.insert(slots,
                make_slot(
                    slots[#slots].y + (pixel_height_of_an_hour/2)
                )
            )
            time_slots_group:add(slots[#slots])

        end
    end
    function time_column:remove_past_shows(dy)
        top_y_limit = top_y_limit + dy
        while #slots~=0 and (top_y_limit >
            (slots[1].y+(pixel_height_of_an_hour/4))) do
            table.remove(slots,1):unparent()
        end
    end
    function time_column:remove_future_shows(dy)
        btm_y_limit = btm_y_limit - dy
        while #slots~=0 and (btm_y_limit < slots[#slots].y) do
            table.remove(slots,#slots):unparent()
        end
    end
    function time_column:slide(dy,f)
        return{
            {
                source = time_slots_group,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",time_slots_group.y},
                    {1.0,"EASE_OUT_SINE",time_slots_group.y+dy},
                },
            }
        }
    end
    function time_column:pump(dy)
        return{
            {
                source = time_slots_group,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE",time_slots_group.y},
                    {0.5,"EASE_OUT_SINE",time_slots_group.y+dy},
                    {1.0,"EASE_IN_SINE", time_slots_group.y},
                },
            }
        }
    end
    local hl = Sprite{
        sheet=ui_sprites,
        id="blue-glow.png",
        y=(screen_h-channel_header_h)/2+50-pixel_height_of_an_hour/2,
        h = pixel_height_of_an_hour,
    }
    hl.anchor_point = {hl.w,hl.h/2}
    hl:move_by(hl.w,hl.h/2)
    function time_column:no_hl()
        hl.opacity = 0
    end
    local fade_dur = 700
    function time_column:fade_out_hl(f)
        hl:animate{
            duration     = fade_dur,
            mode         = "EASE_IN_BACK",
            scale        =   {1,0},
            opacity      =   0,
            on_completed = f,
        }

    end
    function time_column:fade_in_hl(f)
        hl.scale = {1,0}
        hl:animate{
            duration     = fade_dur,
            mode         = "EASE_OUT_BACK",
            opacity      = 255*.8,
            scale        = {1,1},
            on_completed = f,
        }

    end
    local dur = .5
    function time_column:prep_anim_in_stagger()
        layers.time_bg.clip = {
            0,
            0,
            202,
            channel_header_h
        }
        layers.time_column.clip = {
            0,
            0,
            202,
            channel_header_h
        }
        layers.time_bg.opacity = 0
        layers.time_column.opacity = 0
        local props = {
            {
                source = layers.time_bg, name = "clip",
                keys   = {
                    {0.0,"EASE_OUT_SINE",layers.time_bg.clip},
                    {1.0,"EASE_OUT_SINE",{
                            0,
                            0,
                            column_width+3,
                            screen_h
                        }
                    },
                },
            },
            {
                source = layers.time_column, name = "clip",
                keys   = {
                    {0.0,"EASE_OUT_SINE",layers.time_column.clip},
                    {1.0,"EASE_OUT_SINE",{
                            0,
                            0,
                            column_width+3,
                            screen_h
                        }
                    },
                },
            },
            {
                source = layers.time_column, name = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",layers.time_column.opacity},
                    {1.0,"EASE_OUT_SINE",255 },
                },
            },
            {
                source = layers.time_bg, name = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE",layers.time_bg.opacity},
                    {1.0,"EASE_OUT_SINE",255 },
                },
            },
        }
        for i,slot in ipairs(slots) do
            local t_start = dur*((i-1)/#slots)
            slot.x = -column_width
            table.insert(props,{
                source = slot, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",-column_width},
                    {t_start,"EASE_OUT_SINE",-column_width},
                    {1.0,"EASE_OUT_SINE",0},
                    {1.0,"EASE_OUT_SINE",0},
                },
            })
        end
        return props
    end
    function time_column:reset()

        top_y_limit = start_y
        btm_y_limit = top_y_limit+visible_height
        selected_y  = visible_height/2+top_y_limit
        focus_i = 3
        time_slots_group:clear()
        slots = {}
        time_slots_group.y = -top_y_limit

        for y=top_y_limit,btm_y_limit, (pixel_height_of_an_hour/2) do
            table.insert(slots,make_slot(y))
        end
        time_slots_group:add(unpack(slots))
        slots[focus_i]:focus()
    end
    time_column:reset()

    layers.time_bg:add(
        Rectangle{w=column_width+3,h=screen_h,color="black"},hl
    )
    layers.time_column:add(
        time_column,
        Sprite{
            sheet=ui_sprites,
            id   = "epg/epg-overlay-black.png",
            z_rotation = {-90,0,0},
            y=470,
            h=column_width,
            x=0,
            w = screen_h/2,
            opacity =200,
        },
        Sprite{
            sheet=ui_sprites,
            id = "epg/epg-overlay-black.png",
            z_rotation = {90,0,0},
            y=470,
            h=column_width,
            x=column_width,
            w = screen_h/2+100,
            opacity =200,
        }
    )
end
---------------------------------------------------------------
---------------------------------------------------------------
local animating = false
local curr_y = start_y
local function scroll_up()
    if animating then return end
    animating = true
    local dy = math.min(
        pixel_height_of_an_hour/2,
        the_channels[1].txt:prev_show_dy() or pixel_height_of_an_hour/2
    )
    if curr_y - dy < hard_y_limit_top then
        local a = MyAnimator( time_column:pump( 40 ) )
        a.on_completed = function() animating = false end
        for i,channel_obj in ipairs(the_channels) do
            a:add_properties( channel_obj.txt:pump( 40 ) )
        end
        a:start{duration = 250}
        return
    end
    curr_y = curr_y - dy
    time_column:add_past_shows(dy)
    local a = MyAnimator( time_column:slide(dy) )
    for i,channel_obj in ipairs(the_channels) do
        a:add_properties(
            channel_obj.txt:add_past_shows(dy)
        )
        a:add_properties(channel_obj.txt:slide(dy))
    end
    a.on_completed = function()
        for i,channel_obj in ipairs(the_channels) do
            channel_obj.txt:remove_future_shows(dy)
        end
        time_column:remove_future_shows(dy)
        animating = false
    end
    a:start{duration = dur_slide_up_down}
end
local function scroll_down()
    if animating then return end
    animating = true
    local dy = math.min(
        pixel_height_of_an_hour/2,
        the_channels[1].txt:next_show_dy() or pixel_height_of_an_hour/2
    )
    if curr_y + dy > hard_y_limit_btm then
        local a = MyAnimator( time_column:pump( -40 ) )
        a.on_completed = function() animating = false end
        for i,channel_obj in ipairs(the_channels) do
            a:add_properties( channel_obj.txt:pump( -40 ) )
        end
        a:start{duration = 250}
        return
    end
    --print("\nscroll_down")
    curr_y = curr_y + dy
    local a = MyAnimator( time_column:slide(-dy) )
    time_column:add_future_shows(dy)
    for i,channel_obj in ipairs(the_channels) do
        a:add_properties(
            channel_obj.txt:check_shift_selected_down(dy)
        )
        channel_obj.txt:add_future_shows(dy)
        a:add_properties(channel_obj.txt:slide(-dy))
    end
    a.on_completed = function()
        for i,channel_obj in ipairs(the_channels) do
            channel_obj.txt:remove_past_shows(dy)
        end
        time_column:remove_past_shows(dy)
        animating = false
    end
    a:start{duration = dur_slide_up_down}
end
local channels_txt_g = Group()
local channels_bg_g  = Group()
local  left_channel = channels.first
local right_channel



local function child_x(i)
    return (i-1)*(column_width)+column_width
end
local function scroll_left()
    if animating then return end
    animating = true
    left_channel = left_channel.prev
    local c_txt, c_bg = make_channel(
            curr_y,
            left_channel,
            left_channel.number
        )
    c_txt.x = the_channels[1].txt.x-(column_width)
    c_bg.x  = c_txt.x
    channels_txt_g:add(c_txt)
    channels_bg_g:add(c_bg)
    the_channels[1].txt:unfocus()
    table.insert(the_channels,1,{txt=c_txt,bg=c_bg,data=left_channel})
    the_channels[1].txt:focus()

    local a = Animator{

        duration = 300,
        properties = {
            {
                source = channels_bg_g,
                name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",channels_bg_g.x},
                    {1.0,"EASE_OUT_SINE",column_width},
                },
            },
            {
                source = channels_txt_g,
                name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",channels_bg_g.x},
                    {1.0,"EASE_OUT_SINE",column_width},
                },
            },
        }
    }
    function a.timeline.on_completed()
        channels_bg_g.x = 0
        channels_txt_g.x = 0
        local c = table.remove(the_channels,#the_channels)
        c.bg:unparent()
        c.txt:unparent()
        right_channel = right_channel.prev
        for i,child in ipairs(the_channels) do
            child.bg.x = child_x(i)
            child.txt.x = child_x(i)
        end
        animating = false
    end
    dolater(function() a:start() end)
end
local function scroll_right()
    if animating then return end
    animating = true
    right_channel = right_channel.next
    local c_txt, c_bg = make_channel(
            curr_y,
            right_channel,
            right_channel.number
        )
    c_txt.x = the_channels[#the_channels].txt.x+(column_width)
    c_bg.x  = c_txt.x
    channels_txt_g:add(c_txt)
    channels_bg_g:add(c_bg)
    the_channels[#the_channels+1] = {txt=c_txt,bg=c_bg}
    the_channels[1].txt:unfocus()
    the_channels[2].txt:focus()
    --if

    local a = Animator{

        duration = 300,
        properties = {
            {
                source = channels_bg_g,
                name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",channels_bg_g.x},
                    {1.0,"EASE_OUT_SINE",-column_width},
                },
            },
            {
                source = channels_txt_g,
                name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",channels_bg_g.x},
                    {1.0,"EASE_OUT_SINE",-column_width},
                },
            },
        }
    }
    function a.timeline.on_completed()
        channels_bg_g.x = 0
        channels_txt_g.x = 0
        local c = table.remove(the_channels,1)
        c.bg:unparent()
        c.txt:unparent()
        left_channel = left_channel.next
        for i,child in ipairs(the_channels) do
            child.bg.x = child_x(i)
            child.txt.x = child_x(i)
        end
        animating = false
    end
    dolater(function() a:start() end)
end
---------------------------------------------------------------
---------------------------------------------------------------


local i = 1
local num_c = 0
local curr_channel = channels.first

    local overlay = Sprite{
            sheet = ui_sprites,
            id = "epg/epg-overlay-black.png",
            h=screen_h,
            x=column_width*2,
            w = screen_w-column_width*2,
            opacity =0,
        }
    local channel_txt_clip = Group()
    channel_txt_clip:add(channels_txt_g)
    local channel_bg_clip = Group()
    channel_bg_clip:add(channels_bg_g)
    layers.channel_bg:add(channel_bg_clip)
    layers.channel_text:add(channel_txt_clip)
    local side_glow = Sprite{sheet=ui_sprites,id="epg-glow-left-side.png",h=screen_h,x=column_width}
    channel_bg_clip:add(side_glow)
local anim_in_out = false
function epg:anim_out()
    if animating then return end
    animating = true
    anim_in_out = true

    side_glow.x = column_width
    the_channels[1].txt:unfocus()
    local properties= {
        {
            source = livetv_bg, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",  0},
                {1.0,"EASE_OUT_SINE",255},
            },
        },
        {
            source = side_glow, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",255},
                {1.0,"EASE_OUT_SINE",  0},
            },
        },
        {
            source = side_glow, name = "x",
            keys   = {
                {0.0,"EASE_OUT_SINE",column_width},
                {1.0,"EASE_OUT_SINE",200
                },
            },
        },
        {
            source = channel_bg_clip, name = "clip",
            keys   = {
                {0.0,"EASE_OUT_SINE",channel_bg_clip.clip},
                {1.0,"EASE_OUT_SINE",{
                        0, 0, screen_w, channel_header_h
                    }
                },
            },
        },
        {
            source = channel_txt_clip, name = "clip",
            keys   = {
                {0.0,"EASE_OUT_SINE",channel_txt_clip.clip},
                {1.0,"EASE_OUT_SINE",{
                        0, 0, screen_w, channel_header_h
                    }
                },
            },
        },
        {
            source = layers.time_bg, name = "clip",
            keys   = {
                {0.0,"EASE_OUT_SINE",layers.time_bg.clip},
                {1.0,"EASE_OUT_SINE",{
                        0, 0, 202, channel_header_h
                    }
                },
            },
        },
        {
            source = layers.time_column, name = "clip",
            keys   = {
                {0.0,"EASE_OUT_SINE",layers.time_column.clip},
                {1.0,"EASE_OUT_SINE",{
                        0, 0, 202, channel_header_h
                    }
                },
            },
        },
        {
            source = layers.time_column, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",layers.time_column.opacity},
                {1.0,"EASE_OUT_SINE",0 },
            },
        },
        {
            source = layers.time_bg, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",layers.time_bg.opacity},
                {1.0,"EASE_OUT_SINE",0 },
            },
        },
        {
            source = epg, name = "y",
            keys   = {
                {0.0,"EASE_OUT_SINE",0},
                {1.0,"EASE_OUT_SINE",775 },
            },
        },
        {
            source = overlay, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",255},
                {1.0,"EASE_OUT_SINE",0 },
            },
        },
        {
            source = root_bar, name = "opacity",
            keys   = {
                {0.0,"EASE_IN_CIRC",  0},
                {1.0,"EASE_IN_CIRC",255},
            },
        },
    }
    local i = 1
    local check_channel = channels.first
    while left_channel ~= check_channel do
        check_channel = check_channel.next
        i = i+1
        if check_channel == channels.first then
            error("wrapped around")
        end
    end

    for _,props in ipairs(live_tv_bar:prep_anim_from_epg(i)) do
        table.insert( properties, props )
    end
    local on_completed_functions = {}
    local fade_out_the_rest = false
    for i,ch in ipairs(the_channels) do
        local t, on_completed = ch.txt:prep_column_for_anim_out()
        table.insert(on_completed_functions,on_completed)
        for i,props in ipairs(t) do
            table.insert( properties, props )
        end
        local targ_x = (i == 1) and 200 or
            (the_channels[i-1].bg.targ_x+the_channels[i-1].bg.targ_w)
        ch.bg.targ_x = targ_x
        --if you were at the end of the live_tv channel list, then
        --some of the channels are not visible since and need to
        --be faded in
        if  fade_out_the_rest or ch.data == channels.first then
            fade_out_the_rest = true
            table.insert(
                properties,
                {
                    source = ch.bg, name   = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",255},
                        {1.0,"EASE_OUT_SINE",0},
                    },
                }
            )
            table.insert(
                properties,
                {
                    source = ch.txt, name   = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",255},
                        {1.0,"EASE_OUT_SINE",0},
                    },
                }
            )
        end
        ch.txt.x = ch.bg.x
        table.insert(
            properties,
            {
                source = ch.bg, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",ch.bg.x},
                    {1.0,"EASE_OUT_SINE",targ_x},
                },
            }
        )
        table.insert(
            properties,
            {
                source = ch.txt, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",ch.txt.x},
                    {1.0,"EASE_OUT_SINE",targ_x},
                },
            }
        )
        ch.txt:unfocus_selected()
    end
    local a = Animator{
        duration = epg_anim_in_duration,
        properties = properties,
    }

    time_column:fade_out_hl(function()
        layers.time_bg.clip = {
            0,
            0,
            column_width+3,
            screen_h
        }
        layers.time_column.clip = {
            0,
            0,
            column_width+3,
            screen_h
        }
        a:start()
    end)
    function a.timeline.on_completed()

        for i,f in ipairs(on_completed_functions) do
            f()
        end
        screen:grab_key_focus()
        channels_txt_g:clear()
        channels_bg_g:clear()
        the_channels  = {}
        curr_channel  = nil
        left_channel  = nil
        right_channel = nil
        live_tv_bar:focus()
        epg:unparent()
        animating = false
        anim_in_out = false

        time_column:reset()
        curr_y = start_y
    end

end
function epg:anim_in(ch,entries,entry_i)
    anim_in_out = true
    curr_channel = ch
    channels_txt_g:clear()
    channels_bg_g:clear()
    left_channel = nil
    num_c = 0
    while num_c < 5 do
        left_channel  = left_channel or curr_channel
        right_channel = curr_channel
        local c_txt, c_bg =
            make_channel(
                curr_y,
                curr_channel,
                curr_channel.number
            )

        channels_txt_g:add(c_txt)
        channels_bg_g:add(c_bg)

        table.insert(the_channels,{txt=c_txt,bg=c_bg,data=curr_channel})

        curr_channel = curr_channel.next
        num_c = num_c + 1
    end
    for i,child in ipairs(the_channels) do
        child.bg.x = child_x(i)
        child.txt.x = child_x(i)
    end
    channel_txt_clip.clip = {
        0,
        0,
        screen_w,
        channel_header_h
    }
    channel_bg_clip.clip = {
        0,
        0,
        screen_w,
        channel_header_h
    }


    epg.y = 775
    side_glow.x = 200
    side_glow.opacity = 0
    local properties= {
        {
            source = livetv_bg, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",255},
                {1.0,"EASE_OUT_SINE",  0},
            },
        },
        {
            source = side_glow, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",0},
                {1.0,"EASE_OUT_SINE",255},
            },
        },
        {
            source = side_glow, name = "x",
            keys   = {
                {0.0,"EASE_OUT_SINE",200},
                {1.0,"EASE_OUT_SINE",column_width},
            },
        },
        {
            source = channel_bg_clip, name = "clip",
            keys   = {
                {0.0,"EASE_OUT_SINE",channel_bg_clip.clip},
                {1.0,"EASE_OUT_SINE",{
                        column_width,
                        0,
                        (screen_w-column_width),
                        screen_h
                    }
                },
            },
        },
        {
            source = channel_txt_clip, name = "clip",
            keys   = {
                {0.0,"EASE_OUT_SINE",channel_txt_clip.clip},
                {1.0,"EASE_OUT_SINE",{
                        column_width,
                        0,
                        (screen_w-column_width),
                        screen_h
                    }
                },
            },
        },
        {
            source = epg, name = "y",
            keys   = {
                {0.0,"EASE_OUT_SINE",channel_bg_clip.y},
                {1.0,"EASE_OUT_SINE",0 },
            },
        },
        {
            source = overlay, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_SINE",0},
                {1.0,"EASE_OUT_SINE",255 },
            },
        },
        {
            source = root_bar, name = "opacity",
            keys   = {
                {0.0,"EASE_OUT_EXPO",255},
                {1.0,"EASE_OUT_EXPO",  0},
            },
        },
    }
    for _,props in ipairs(time_column:prep_anim_in_stagger()) do
        table.insert( properties, props )
    end
    for i,props in ipairs(live_tv_bar:prep_anim_to_epg()) do
        table.insert( properties, props )
    end
    local on_completed_functions = {}
    for i,ch in ipairs(the_channels) do
        local t,on_completed = ch.txt:prep_column_for_anim_in()

        table.insert(on_completed_functions,on_completed)

        for i,props in ipairs(t) do
            table.insert( properties, props )
        end
        local targ_x = ch.bg.x
        ch.bg.x = (i == 1) and 200 or
            (the_channels[i-1].bg.x+the_channels[i-1].bg.w)
        --if you were at the end of the live_tv channel list, then
        --some of the channels are not visible since and need to
        --be faded in
        if entries[entry_i+i-1] == nil then
            ch.bg.opacity  = 0
            ch.txt.opacity = 0
            table.insert(
                properties,
                {
                    source = ch.bg, name   = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",0},
                        {1.0,"EASE_OUT_SINE",255},
                    },
                }
            )
            table.insert(
                properties,
                {
                    source = ch.txt, name   = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",0},
                        {1.0,"EASE_OUT_SINE",255},
                    },
                }
            )
        end
        ch.txt.x = ch.bg.x
        table.insert(
            properties,
            {
                source = ch.bg, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",ch.bg.x},
                    {1.0,"EASE_OUT_SINE",targ_x},
                },
            }
        )
        table.insert(
            properties,
            {
                source = ch.txt, name   = "x",
                keys   = {
                    {0.0,"EASE_OUT_SINE",ch.txt.x},
                    {1.0,"EASE_OUT_SINE",targ_x},
                },
            }
        )
    end
    local a = Animator{
        duration = epg_anim_in_duration,
        properties = properties,
    }
    function a.timeline.on_completed()

        for i,f in ipairs(on_completed_functions) do
            f()
        end

        layers.time_bg.clip = {
                0,
                0,
                screen_w,
                screen_h,
            }
        time_column:fade_in_hl()
        for i,ch in ipairs(the_channels) do
            ch.txt:focus_selected()
        end
        live_tv_bar:finish_anim_to_epg()
        the_channels[1].txt:focus()
        anim_in_out = false
    end
    time_column:no_hl()
    dolater(function() a:start() end)
    screen:add(epg)

end




local key_events = {
    [keys.Up]    = scroll_up,
    [keys.Down]  = scroll_down,
    [keys.Left]  = scroll_left,
    [keys.Right] = scroll_right,
    [keys.BACK]  = epg.anim_out,
    [keys.OK]    = function()
        epg.more_info:display(
            the_channels[1].txt:selected(),
            the_channels[1].txt.x+column_width
            )
    end,
}

function epg:on_key_down(k)
    return not anim_in_out and key_events[k] and key_events[k]() or true
end
