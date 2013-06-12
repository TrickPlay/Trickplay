--[[
Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]
local live_tv_menu_G = Group{name="Live TV"}


local i = 1
local channel_data = {}
while i <= 100 do
    if type(channels[i]) == "number" then i = channels[i] end
    if channels[i] == nil then break end
    table.insert(channel_data,{
        num      = i,
        channel  = channels[i].name,
        show     = channels[i].on_now.show_name,
        show_ref = channels[i].on_now,
        orig     = channels[i],
    })
    i = i + 1
end
local menubar
local bar_height
local show_offset = 0
local active_show = 2

local function make_show_tile(data)
    local bar_height = 148--channel_bar.h
    print("bar_height",bar_height)
    local show_group = Group { name = data.show }
    local logo = Sprite {
        sheet = ui_sprites,
        id    = "channel-logos/"..data.orig.id..".png",
        scale = {.5,.5},
    }
    logo.anchor_point = { logo.w/2, logo.h/2 }
    local channel_num = Text { color = "grey35", text = ""..data.num, font = FONT_NAME.." 192px" }

    channel_num.x = 15
    channel_num.y = -48
    local logo_x = math.max(
        30+logo.w/2*logo.scale[1],
        channel_num.x+ channel_num.w/2
    )
    logo.position = { logo_x, bar_height/2 }
    local show_text = Text { color = "white", text = data.show, font = FONT_NAME.." 40px" }
    show_text.anchor_point = { 0, show_text.h/2 }
    local st_x =  math.max(
        (logo.x + logo.w/2*logo.scale[1] + 15),
        (channel_num.x + channel_num.w + 5)
    )
    show_text.position = { st_x, bar_height/2 }

    local r_w = math.max(channel_num.w,show_text.x + show_text.w) + 30
    local bg_focus = Sprite {
        sheet = ui_sprites,
        id = "channelbar/channel-bar-focus.png",
        name = "bg-focus",
        x = 1,
        w = r_w
    }

    local bg_unfocus = Sprite {
        sheet = ui_sprites,
        id = "channelbar/channel-bar.png",
        name = "bg-unfocus",
        x = 1,
        w = r_w
    }

    show_group:add( Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height } },
                    --bg_unfocus,
                    bg_focus,
                    Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height }, x = 1 + r_w },
                    channel_num, logo, show_text )

    show_group.extra.anim = AnimationState {
                                                    duration = 250,
                                                    mode = "EASE_OUT_SINE",
                                                    transitions = {
                                                        {
                                                            source = "*",
                                                            target = "focus",
                                                            keys = {
                                                                { bg_focus,    "opacity", 255 },
                                                                --{ bg_unfocus,  "opacity",   0 },
                                                                { logo,        "opacity", 255 },
                                                                { channel_num, "opacity", 255 },
                                                                { show_text,   "opacity", 255 },
                                                            },
                                                        },
                                                        {
                                                            source = "*",
                                                            target = "unfocus",
                                                            keys = {
                                                                { bg_focus,    "opacity",   0 },
                                                                --{ bg_unfocus,  "opacity", 255 },
                                                                { logo,        "opacity",  64 },
                                                                { channel_num, "opacity",  64 },
                                                                { show_text,   "opacity",  64 },
                                                            },
                                                        },
                                                    },
    }

    show_group.extra.focus = function(self)
        self.anim.state = "focus"
    end

    show_group.extra.unfocus = function(self)
        self.anim.state = "unfocus"
    end
    show_group.anim:warp("unfocus")

    show_group.show_ref = data.show_ref
    return show_group
end

local function get_sprite( uri )
    if type(uri)~="string" then return false end
    uri = uri:sub(uri:len()-uri:reverse():find("/")+2)
    return(uri)
end
local text_w = 600
local backing = make_MoreInfoBacking{
    info_x     = 200,
    expanded_h = 550,
    parent      = live_tv_menu_G,
    get_current = function() return menubar:curr().show_ref end,
    create_more_info = function()
        local blue_color = "6fa4d3"
        local grey_color = "a0a9b0"
        local duration = 200
        local max_airings = 5
        local g = Group()
        g.image = Sprite{
            name = "Show Poster",
            sheet = tv_show_sprites,
        }
        g.description_group = Group()
        g.slogan = Text{
            y = 400-375,
            w=text_w,
            ellipsize = "END",
            color = blue_color,
            font = FONT_NAME.." Bold 32px",
        }
        g.description = Text{
            y=400-300,
            wrap=true,
            wrap_mode = "WORD",
            w=text_w,
            color = grey_color,
            font = FONT_NAME.." 24px",
            text = "description",
        }
        g.start_time = Text{
            y=400-100,
            w=text_w,
            color = blue_color,
            font = FONT_NAME.." Bold 24px",
            text = "start_time",
        }
        g.duration = Text{
            y=400-100,
            x= 150,
            w=text_w,
            color = grey_color,
            font = FONT_NAME.." Bold 24px",
            text = "duration",
        }
        g.aired_on = Text{
            y=400-50,
            w=text_w,
            color = grey_color,
            font = FONT_NAME.." Bold 20px",
            text = "aired_on",
        }
        g.season_episode = Text{
            y=400-50,
            w=text_w,
            color = grey_color,
            font = FONT_NAME.."  24px",
            text = "season_episode",
        }

        g.vert_line = Sprite{ sheet=ui_sprites, x = 150, id = "line-separator-vertical.png" }
        g.vert_line.orig_h = g.vert_line.h
        g.next_airings = Group{
            x= 900,
            y= g.description.y-20,
            children={
                Text{
                    color = grey_color,
                    font = FONT_NAME.."  20px",
                    text = "Next Airings:",
                },
                g.vert_line
            }
        }
        g.related = Group{
            x= 1050,
            y= g.next_airings.y,
            children = {
                Text{
                    text  = "Related",
                    color = grey_color,
                    font  = FONT_NAME.."  20px",
                    text  = "Related:",
                },
                Sprite{sheet=ui_sprites, y =  50, id = "live-tv-et.png",      },
                Sprite{sheet=ui_sprites, y = 100, id = "live-tv-showbiz.png", },
                Sprite{sheet=ui_sprites, y = 150, id = "live-tv-tmz.png",     },
            }
        }
        g.description_group:add(
            g.slogan,
            g.description,
            g.start_time,
            g.aired_on,
            g.duration
        )
        g:add(
            g.image,
            g.description_group,
            --g.season_episode,
            g.related,
            g.next_airings
        )
        g.airings = {}
        for i=1,max_airings do
            g.airings[i] = Text{
                --g.next_airings.x+150*(i-1),
                y = 30*(i-1)+50,
                color = grey_color,
                font =  FONT_NAME.."  20px",
            }
            g.next_airings:add(g.airings[i])
        end
        return g
    end,
    populate = function(g,show)
            if show == nil then error("nil show",2) end
            curr_show = show
            local id =
                get_sprite(show.banner) or
                get_sprite(show.cast)   or
                get_sprite(show.logo)   or
                ""
            --print(show.show_name,id,show.banner,show.cast,show.logo)
            g.image[id == "" and "hide" or "show"](g.image)
            g.image.id = id
            g.description_group.x = id ~= "" and (g.image.w+30) or 0
            --g.next_airings.x = g.description_group.x + text_w+300

            g.vert_line.h =
                show.show_description ~= json_null and
                g.vert_line.orig_h or 200

            g.next_airings.x =
                show.show_description ~= json_null and
                g.description_group.x + text_w+300 or g.description_group.x
            g.related.x = g.next_airings.x+230
            g.image.anchor_point = {0,g.image.h/2}
            g.image.y = 400-200
            g.season_episode.text =
                (show.season_number  ~= json_null) and
                (show.episode_number ~= json_null) and
                ("Season "   ..show.season_number..
                " : Episode "..show.episode_number) or
                (show.season_number ~= json_null) and
                "Season "..show.season_number
                (show.episode_number ~= json_null) and
                "Episode "..show.episode_number or ""
            g.slogan.text =
                show.series_description ~= json_null and
                show.series_description or
                show.show_name ~= json_null and
                show.show_name or ""
            g.description.text =
                show.show_description ~= json_null and
                show.show_description or ""
            g.aired_on.text =
                show.original_air_date ~= json_null and
                ("AIRED ON "..show.original_air_date) or ""
            g.duration.text =
                show.duration.." min"
            g.start_time.text =
                (show.start_time ~= json_null) and
                ampm(show.start_time_t.hour,show.start_time_t.min) or ""

            if show.series_id and series[show.series_id] and #series[show.series_id].all_shows > 1 then

                g.next_airings:show()
                local curr_show
                for i=1,#g.airings do
                    if i < (#series[show.series_id].all_shows) then
                        curr_show = series[show.series_id].all_shows[i]

                        g.airings[i].text =
                            curr_show.start_time_t.wkdy.."\t"..
                            ampm(curr_show.start_time_t.hour)
                    end
                end
            else
                g.next_airings:hide()
                g.related.x = g.next_airings.x
            end
    end,
    empty_info = nil,
    default_info = nil,
}

local function show_bar()
    menubar:anim_in()
    live_tv_menu_G:add(menubar)
end

local function hide_bar()
    dolater(150,menubar.anim_out)
    backing.anim.state = "hidden"
end

local show_poster_cache = Group{name="Live TV Cache"}
screen:add(show_poster_cache)
show_poster_cache:hide()

local function on_activate(label)
    label:stop_animation()
    label:animate({ duration = 250, opacity = 255 })

    if menubar == nil then
        for i,show in ipairs(channel_data) do
            show = show.show_ref
            local id =
                get_sprite(show.banner) or
                get_sprite(show.cast)   or
                get_sprite(show.logo)   or
                ""
            print(show.banner,id)
            if id ~= "" then
                show_poster_cache:add(
                    Sprite{
                        sheet = tv_show_sprites,
                        id = id,
                    }
                )
            end
        end
        menubar = make_sliding_bar__highlighted_focus{
            make_stub = make_stub,
            make_item = make_show_tile,
            items     = channel_data,
        }
        screen:add(live_tv_menu_G)
        menubar.y = 925 - 150
        backing.y = 380
        live_tv_bar = menubar




        function menubar:prep_anim_to_epg()
            return {
                {
                    source = menubar, name = "y",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",menubar.y},
                        {1.0,"EASE_OUT_SINE", 0},
                    },
                },
                {
                    source = menubar, name = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",255},
                        {1.0,"EASE_OUT_SINE",0},
                    },
                },
            }
        end
        function menubar:finish_anim_to_epg()
            self:unparent()
        end
        function menubar:prep_anim_from_epg(i)
            live_tv_menu_G:add(menubar)
            menubar:warp_to(i)
            menubar.y = 0
            return {
                {
                    source = menubar, name = "y",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",0},
                        {1.0,"EASE_OUT_SINE",925 - 150 },
                    },
                },
                {
                    source = menubar, name = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",  0},
                        {1.0,"EASE_OUT_SINE",255},
                    },
                },
            }
        end
    end
    hide_bar()
end

local function on_deactivate(label, new_active)
    label:stop_animation()
    label:animate{
        duration = 250,
        opacity = 128,
        on_completed = function()
            if(new_active) then
                new_active:activate()
            end
        end
    }
    hide_bar()
    --show_poster_cache:clear() TODO: cache should be cleared and reloaded every time this menu is entered and exited
end

local anim_to_epg = false
local key_events
key_events = {
    [keys.Left] = function()
        menubar:press_left()
        if  backing.anim.state == "full" then
            backing:set_incoming(
                menubar:curr().show_ref,
                "left"
            )
        end
        return true
    end,
    [keys.Right] = function()
        menubar:press_right()
        if  backing.anim.state == "full" then
            backing:set_incoming(
                menubar:curr().show_ref,
                "right"
            )
        end
        return true
    end,
    [keys.Up] = function()
        if backing.anim.state ~= "full" then
            backing.anim.state = "full"
        else
            key_events[keys.RED]()
        end
        return true
    end,
    [keys.Down] = function()
        if backing.anim.state == "full" then
            backing.anim.state = "hidden"
            return true
        end
    end,
    [keys.OK] = function()
        if backing.anim.state ~= "full" then
            backing.anim.state = "full"
        else
            key_events[keys.RED]()
        end
        return true
    end,
    [keys.RED] = function()
        anim_to_epg = true
        menubar:remove_focus()
        if backing.anim.state ~= "hidden" then
            backing.anim.state = "hidden"
        end
        --menubar:unparent()
        --backing:unparent()
        --root_bar:unparent()
        --[[
        root_bar:stop_animation()
        root_bar:animate{
            duration=200,
            opacity=0,
            on_completed=function(self)
                self:unparent()
            end,
        }--]]
        dolater(200,function()
            anim_to_epg = false
            epg:anim_in(
                channel_data[menubar:current()].orig,
                menubar:entries(),
                menubar:current()
            )

            epg:grab_key_focus()
            menubar:unparent()
        end)
    end,
}
local function on_key_down(label, key)

    return anim_to_epg or key_events[key] and key_events[key]()
end

return {
            label       = "Live TV",
            activate    = on_activate,
            deactivate  = on_deactivate,
            wake        = show_bar,
            sleep       = hide_bar,
            on_key_down = on_key_down,
        }
