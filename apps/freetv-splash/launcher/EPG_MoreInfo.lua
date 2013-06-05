
local cast_srcs = {
    "cast1.png",
    "cast2.png",
    "cast3.png",
    "cast4.png",
    "cast5.png",
    "cast6.png",
    "cast7.png",
}

local tabs_text = {
    "Watch",
    "Record",
    "Preview",
    "Catchup",
    "Add to Favs",
}
local text_w = 900
local  tab_w = 900/(#tabs_text)
local left_spacing = 60
local       blue_color = "6fa4d3"
local     yellow_color = "e0ba95"
local dark_gray_color  = "b5b5b4"
local      gray_color  = "dedddd"
local function make_tab(i,text)
    local label  = Text{
        color = "white",
        text = text,
        font = FONT_NAME.." 24px",
        alignment = "CENTER",
    }
    local tab_h = label.h*2.5
    label.anchor_point = {label.w/2,label.h/2}
    label.position = {tab_w/2,tab_h/2}
    local tab    = Group{
        name     = text,
        w        = tab_w,
        h        = tab_h,
        --x        = tab_w*(i-1),
        children = {
            --unfocused,
            --focused,
            label,
        }
    }
    return tab
end
local function make_actor(data,i)

    local hl    = Sprite{
        sheet   = ui_sprites,
        id      = "epg-cast-focus.png",
        w       = 118+20,
        h       = 118+20,
        opacity = 0,
    }
    local actor = Group{
        x = (i-1)*200,
        children = {
            hl,
            Sprite{sheet=ui_sprites,x=10,y=10,id=data.cast_src},
            Text{
                x     = 10,
                y     = 118+30,
                text  = data.first_name.." "..data.last_name,
                color = blue_color,
                font  = FONT_NAME.." 18px",
            },--[[
            Text{
                y     = 70+40+10,
                text  = data.role,
                color = "888888",
                font  = FONT_NAME.." 18px",
            },--]]
        }
    }

    actor.anim = AnimationState{
        duration = 250,
        mode = "EASE_OUT_SINE",
        transitions = {
            {
                source = "*",
                target = "focus",
                keys = {
                    { hl, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { hl, "opacity", 0 },
                },
            },
        },
    }
    actor.anim:warp("unfocus")
    return actor
end
local set_up_list_functions = function(t)
    local i = 1
    function t:focus(new_i)
        i = new_i or i
        t[i].anim.state = "focus"
        return true
    end
    function t:unfocus()
        t[i].anim.state = "unfocus"
        return true
    end
    function t:left()
        if i == 1 then return end
        t[i].anim.state = "unfocus"
        i = i - 1
        t[i].anim.state = "focus"
        return true
    end
    function t:right()
        if i == #t then return end
        t[i].anim.state = "unfocus"
        i = i + 1
        t[i].anim.state = "focus"
        return true
    end
    function t:press()
        return t[i].press and t[i]:press()
    end
end

local function make( )
    local more_info = Group()


    local bg = Rectangle{
        h=screen_h,
        w=screen_w,
        color="black",
        opacity=210,
        border_width=2,
        border_color="2d414e",
    }
    more_info:add(bg)
    ------------------------------------------------------------------
    local show_banner = Sprite{sheet=banner_sprites,x = left_spacing,y=40,w=900,h=200}
    --Rectangle{x = left_spacing,y=40,w=900,h=200}
    --Clone{}
    more_info:add(show_banner)
    ------------------------------------------------------------------
    --[[
    local tabs = {}
    local tabs_g = Group{x = left_spacing}
    for i,t in ipairs(tabs_text) do
        tabs[i] = make_tab(t,i)
    end--]]
    --==========================================
            local tabs_g_hl = Sprite{sheet=ui_sprites,id = "epg-episode-blue-focus.png"}
            local tabs_g = make_windowed_list{
                items         = tabs_text,
                make_item     = make_tab,
                visible_range = 1220,--4,
                parent        = more_info,
                hl = tabs_g_hl,
            }
            tabs_g_hl.h = tabs_g:current().h
            local tabs_bg = Sprite{
                y = tabs_g.y,
                size = tabs_g.size,
                sheet = ui_sprites,
                id = "channelbar/channel-bar.png",
            }
            tabs_g:add(tabs_bg)
            tabs_bg:lower_to_bottom()
            local tabs_g_interface = {

                focus = function (new_i)
                    return tabs_g:anim_hl_in()
                end,
                unfocus = function()
                    return tabs_g:anim_hl_out()
                end,
                left = function()
                    return tabs_g:press_backward()
                end,
                right = function()
                    return tabs_g:press_forward()
                end,
                press = function() end,
            }
    --==========================================



    tabs_g.x = left_spacing
    text_w = tabs_g.w--tabs[#tabs].w + tabs[#tabs].x
    --set_up_list_functions(tabs)
    --tabs_g:add(unpack(tabs))
    more_info:add(tabs_g)
    ------------------------------------------------------------------
    local episode_description = Group{x = left_spacing}--{y=tabs[1].y+tabs[1].h+50}
    local stars = Group{}
    local episode_name = Text{
        color = yellow_color,
        ellipsize = "END",
        w = text_w - stars.w - 10,
        --text = text,
        font = "Lato Bold 32px",
    }
    local ep_seas_num___dur___air_date = Text{
        color = dark_gray_color,
        y = episode_name.y+episode_name.h+20,
        --text = text,
        font = FONT_NAME.." 20px",
    }
    local description = Text{
        color = gray_color,
        w = text_w,
        wrap_mode = "WORD",
        wrap = true,
        y = ep_seas_num___dur___air_date.y+
            ep_seas_num___dur___air_date.h+15,
        --text = text,
        font = FONT_NAME.." 24px",
    }

    episode_description:add(
        episode_name,
        ep_seas_num___dur___air_date,
        description
    )
    more_info:add(episode_description)
    ------------------------------------------------------------------
    local seasons = Group{x = left_spacing}


    more_info:add(seasons)

    ------------------------------------------------------------------
    local cast = Group{x = left_spacing}


    more_info:add(cast)

    ------------------------------------------------------------------
    local selectable_rows
    function more_info:populate(show)
        print(show.show_name..".jpg")
        show_banner.id = show.show_name..".jpg"
        print(show.show_name..".jpg",show_banner.loaded)
        if show_banner.loaded then
            show_banner:show()
            tabs_g.y = show_banner.y + show_banner.h + 34
        else
            show_banner:hide()
            tabs_g.y = show_banner.y+35
        end
        episode_description.y = tabs_g.y + tabs_g.h + 30
        --Name of the Episode or Show
        episode_name.text = show.episode_name ~= json_null and
            show.episode_name or show.show_name

        -- Make:
        -- Episode 7, Season 2 | Length: 1:00:00 | Air Date: 03-19-2013
        local t =
            (show.season_number  ~= json_null) and
            (show.episode_number ~= json_null) and
            ("Season "   ..show.season_number..
            ", Episode "..show.episode_number) or
            (show.season_number ~= json_null) and
            ("Season "..show.season_number)
            (show.episode_number ~= json_null) and
            ("Episode "..show.episode_number) or ""

        if show.duration  ~= json_null then

            t = (t=="") and t or (t.." | ")

            local hrs  = math.floor(show.duration/60)
            local mins = show.duration%60

            t = t .. "Length: "..
                ((hrs>0) and (hrs..":") or "")..mins..":00"
        end

        if show.original_air_date ~= json_null then

            t = (t=="") and t or (t.." | ")

            t = t.."Air Date: "..show.original_air_date
        end

        ep_seas_num___dur___air_date.text = t

        --Episode Description
        description.y = (t=="") and ep_seas_num___dur___air_date.y or
            (ep_seas_num___dur___air_date.y+
             ep_seas_num___dur___air_date.h+10)

        description.text = show.show_description~= json_null and
            show.show_description or ""

        seasons.y = episode_description.y + episode_description.h+50

        --------------------------------------------------------------
        -- The tabs and lists of Seasons/Episodes
        seasons:clear()
        local season_tabs, season_tabs_g_g
        if show.series_id ~= json_null and series[show.series_id] and
            #series[show.series_id] > 1 then
--dumptable(series[show.series_id])
            seasons:show()
            seasons:clear()
            local season_tabs_g = Group{ name = "Season Tabs"}
            seasons:add(season_tabs_g)
            season_tabs_g:add(Text{
                text  = "Episodes",
                color = dark_gray_color,
                y     = 4,
                font  = "Lato Bold 32px",
            })

            season_tabs = {}

            local season_bg = Sprite{sheet=ui_sprites,w=1220,id = "channelbar/channel-bar.png",opacity=255*.6,y=90,h = 115}
            seasons:add(season_bg)
            season_bg:lower_to_bottom()

            local s_num = 1
            local seasons_array = {}
            while s_num <= series[show.series_id].max_season_number do
                --if season 's_num' is absent, short-cut to the next
                --season that we have
                if  type(   series[show.series_id][s_num] ) == "number" then
                    s_num = series[show.series_id][s_num]
                end
                seasons_array[#seasons_array+1] = series[show.series_id][s_num]
                s_num = s_num + 1
            end
            do

                local t = season_tabs
                local vert_i = 1
                local horz_i = 1
                local ep_horz_i = 1

                local left_x  = col
                --local right_x = screen_w
                function t:focus(new_i)
                    horz_i = new_i or horz_i
                    if vert_i == 2 then
                        season_tabs_g_g:current().episodes_g:anim_hl_in()--t[ep_horz_i].anim.state = "focus"
                    else
                        if #seasons_array > 1 then
                            --t[horz_i].anim.state = "focus"
                            season_tabs_g_g:anim_hl_in()
                        else
                            vert_i = 2
                            season_tabs_g_g:current().episodes_g:anim_hl_in()
                        end
                    end
                    return true
                end
                function t:unfocus()
                    if vert_i == 2 then
                        season_tabs_g_g:current().episodes_g:anim_hl_out()--t[ep_horz_i].anim.state = "unfocus"
                    else
                        --t[horz_i].anim.state = "unfocus"
                        season_tabs_g_g:anim_hl_out()
                    end
                    return true
                end
                function t:left()
                    if vert_i == 2 then

                        return season_tabs_g_g:current().episodes_g:press_backward()
                    else
                        season_tabs_g_g:current().episodes_g:anim_out()
                        season_tabs_g_g:current().anim.state = "unfocus"
                        local r = season_tabs_g_g:press_backward()
                        season_tabs_g_g:current().episodes_g:anim_in()
                        season_tabs_g_g:current().anim.state = "focus"
                        season_bg:animate{
                            duration = 100,
                            w = math.min(1220,season_tabs_g_g:current().episodes_g.w)
                        }
                        return r
                    end
                end
                function t:right()
                    if vert_i == 2 then
                        --if ep_horz_i == #season_tabs_g_g:current().episodes_t then return end
                        season_tabs_g_g:current().episodes_g:press_forward()
                        return true
                    else
                        season_tabs_g_g:current().episodes_g:anim_out()
                        season_tabs_g_g:current().anim.state = "unfocus"
                        season_tabs_g_g:press_forward()
                        season_tabs_g_g:current().episodes_g:anim_in()
                        season_tabs_g_g:current().anim.state = "focus"
                        season_bg:animate{
                            duration = 100,
                            w = math.min(1220,season_tabs_g_g:current().episodes_g.w)
                        }
                        return true
                    end
                end
                function t:press()
                    return vert_i == 1 and
                        (season_tabs_g_g.press and season_tabs_g_g:press()) or
                        (
                            season_tabs_g_g:current().episodes_g.press and
                            season_tabs_g_g:current().episodes_g:press()
                        )
                end
                function t:up_f()
                    if vert_i == 1 then return false end
                    if #seasons_array <= 1 then return false end
                    season_tabs_g_g:current().episodes_g:anim_hl_out()
                    --t[horz_i].episodes_t[ep_horz_i].anim.state = "unfocus"
                    vert_i = vert_i - 1
                    --t[horz_i].anim.state = "focus"
                    season_tabs_g_g:anim_hl_in()
                    return true
                end
                function t:down_f()
                    if vert_i == 2 then return false end
                    ep_horz_i = 1
                    --t[horz_i].anim.state = "unfocus"
                    season_tabs_g_g:anim_hl_out()
                    vert_i = vert_i + 1
                    season_tabs_g_g:current().episodes_g:anim_hl_in()--[ep_horz_i].anim.state = "focus"
                    return true
                end
            end
            function make_season(i,s) print("make season")
            --[[
            local s_num = 1
            while s_num <= series[show.series_id].max_season_number do
                --if season 's_num' is absent, short-cut to the next
                --season that we have
                if  type(   series[show.series_id][s_num] ) == "number" then
                    s_num = series[show.series_id][s_num]
                end
                --]]
                local season = s

                local e_num = 1

                local eps = {}
                while e_num <= season.max_episode_number do
                    --if episode 's_num' is absent, short-cut to the next
                    --episode that we have
                    if  type(   season[e_num] ) == "number" then
                        e_num = season[e_num]
                    end
                    eps[#eps+1] = season[e_num]
                    e_num = e_num + 1
                end

                local x_padding = 20
                local y_padding =  5
                local season_label_t = Text{
                    text  = "Season "..eps[1].season_number,
                    color = "white",
                    font  = "Lato Bold 20px",
                    x     = x_padding,
                    y     = y_padding,
                }
                local season_label = Group{
                    w        =  season_label_t.x+season_label_t.w+x_padding,
                    h        =  season_label_t.y+season_label_t.h+y_padding,
                    children = {season_label_t},
                    extra    = { episodes_t = {}, },
                }
                season_label.anim = AnimationState{
                    duration = 250,
                    mode = "EASE_OUT_SINE",
                    transitions = {
                        {
                            source = "*", target = "focus",
                            keys = { { season_label_t, "opacity", 255 }, },
                        },
                        {
                            source = "*", target = "unfocus",
                            keys = { { season_label_t, "opacity", 150 }, },
                        },
                    },
                }
                --seasons:add(season_label.episodes_g)
                --season_tabs_g:add(season_label)
                --table.insert(season_tabs,season_label)

---[=[
                local function make_ep(i,p)
                    local padding = 20
                    local txt_w = 250
                    local ep_name =
                            p.episode_name ~= json_null and
                            p.episode_name or
                            p.show_name

                    local title =
                            Text{
                                x     = padding,
                                y     = 20,
                                color = blue_color,
                                font  = "Lato Bold 20px",
                                text  = ep_name,
                            }
                    if title.w > txt_w then
                        title:set{
                                w     = txt_w,
                                wrap  = true,
                                wrap_mode = "WORD",
                                ellipsize = "END",
                                h = 55,
                        }
                    end
                    local episode = Group{
                        name      = ep_name,
                        children  = {
                            title,
                            Text{
                                x     = padding,
                                y     = 80,
                                color = "white",
                                font  = FONT_NAME.." 18px",
                                text  =
                                       "Season "..p.season_number..
                                    ", Episode "..p.episode_number
                            }
                        },
                        extra = {show_data = p}
                    }
                    episode.anchor_point = {0,episode.h/2}
                    episode.y = 115/2-5
                    episode.w = episode.w + padding
                    episode.h = 115 + 10
                    return episode
                end
                season_label.episodes_g = make_windowed_list{
                    items         = eps,
                    make_item     = make_ep,
                    visible_range = 1220,--4,
                    parent        = seasons,
                    hl = Sprite{name="HL",sheet=ui_sprites,id = "epg-episode-blue-focus.png",y=10},
                }--]=]
                if i > 1 then
                    season_label.episodes_g.opacity = 0
                    season_label.anim:warp("unfocus")
                else
                    seasons:add(season_label.episodes_g)
                    season_label.anim:warp("focus")
                end
                season_label.episodes_g.y = season_label.h+45

                return season_label
            end
            local season_tab_hl =Sprite{name="HL",sheet=ui_sprites,id = "epg-episode-blue-focus.png",}
            season_tabs_g_g = make_windowed_list{
                items         = seasons_array,
                make_item     = make_season,
                passive_focus = 255*.6,
                visible_range = 1220,--4,
                parent        = seasons,
                hl = season_tab_hl,
            }
            season_tabs_g_g.y = season_tabs_g.children[1].h+15
            season_tab_hl.h = season_tabs_g_g.current().h
            seasons:add(
                Sprite{
                    sheet=ui_sprites,
                    id = "channelbar/channel-bar.png",
                    opacity=255*.6,
                    y = season_tabs_g_g.y,
                    h = season_tabs_g_g.current().h,
                    w = season_tabs_g_g.w,
                },
                season_tabs_g_g
            )

            cast.y = seasons.y+seasons.h+30

            tabs_g_interface.down = season_tabs
            season_tabs.up = tabs_g_interface
        else
            tabs_g_interface.down = nil
            cast.y = seasons.y
        end
        --------------------------------------------------------------
        -- The list of cast members
        cast:clear()
        local cast_list = {}
        if show.cast ~= json_null and #show.cast > 0 then
            cast:add(Text{
                    text  = "Cast",
                    color = dark_gray_color,
                    font  = "Lato Bold 32px",
                })
            --cast
            local cast_srcs_c = {}
            for i,v in ipairs(cast_srcs) do
                cast_srcs_c[i] = v
            end
            for i,v in ipairs(show.cast) do
                if i > 6 then break end
                v.cast_src = #cast_srcs_c ~=0 and
                    table.remove(cast_srcs_c,math.random(1,#cast_srcs_c)) or
                    cast_srcs[math.random(1,#cast_srcs)]
                cast_list[i] = make_actor(v,i):set{y=cast.children[1].h}
                cast:add(cast_list[i])
            end

            set_up_list_functions(cast_list)
            if show.series_id ~= json_null and series[show.series_id]  and
                #series[show.series_id] > 1 then

                season_tabs.down = cast_list
                cast_list.up = season_tabs
            else
                tabs_g_interface.down = cast_list
                cast_list.up = tabs_g_interface
            end
        end
    end
    local curr_table
    function more_info:display( show, x )

        epg.more_info:populate(show)
        epg.more_info:show()
        epg.more_info.x = screen_w
        dolater(function()
            epg.more_info:animate{
                x = x,
                duration = 200,
                mode = "EASE_OUT_SINE",
                on_completed = function(self)
                    self:grab_key_focus()
                    curr_table = tabs_g_interface
                    curr_table:focus(1)
                end,
            }
        end)
        screen:add(epg.more_info)
    end
    function more_info:dismiss( )

        dolater(function()
            epg.more_info:animate{
                x = screen_w,
                duration = 200,
                on_completed = function(self)
                    epg:grab_key_focus()
                    self:unparent()
                end,
            }
        end)
        --screen:add(epg.more_info)
    end
    local button_mash_timeout = false
    local button_mash_timer = Timer{
        interval = 700,
        on_timer = function(self)
            self:stop()
            button_mash_timeout = false
        end,
    }
    local key_events = {
        [keys.Up]    = function()
            if curr_table.up_f and curr_table.up_f() then
            elseif curr_table.up then
                curr_table:unfocus()
                curr_table = curr_table.up
                curr_table:focus()
            end
        end,
        [keys.Down]  = function()
            if curr_table.down_f and curr_table.down_f() then
            elseif curr_table.down then
                curr_table:unfocus()
                curr_table = curr_table.down
                curr_table:focus()
            end
        end,
        [keys.Left]  = function()
            if not curr_table:left() then
                if not button_mash_timeout then
                    more_info:dismiss()
                end
            else
                button_mash_timer:stop()
                button_mash_timer:start()
                button_mash_timeout = true
            end
        end,
        [keys.Right] = function()
            curr_table:right()
        end,
        [keys.OK]  = function()
            if curr_table.press then
                curr_table:press()
            end
        end,
        [keys.BACK]  = function()
            more_info:dismiss()
        end,
    }
    function more_info:on_key_down(k)
        return key_events[k] and key_events[k]() or true
    end
    return more_info
end


return make()
