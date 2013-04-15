--[[
Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]

local clone_sources = Group()
screen:add(clone_sources)
clone_sources:hide()

local vert_line = Image{
    src = "assets/line-separator-vertical.png"
}
local et = Image{
    src = "assets/live-tv-et.png"
}
local showbiz = Image{
    src = "assets/live-tv-showbiz.png"
}
local tmz = Image{
    src = "assets/live-tv-tmz.png"
}
clone_sources:add(vert_line,et,tmz,showbiz)

local i = 1
local channel_data = {}
while i <= 100 do
    if type(channels[i]) == "number" then i = channels[i] end
    if channels[i] == nil then break end
    print(i)
    channel_data[i] = {
        channel = channels[i].name,
        show    = channels[i].schedule[1].show_name,
        show_ref = channels[i].schedule[1]
    }
    i = i + 1
end
local menubar
local channel_bar
local channel_bar_focus
local bar_height
local show_offset = 0
local active_show = 2

local function make_show_tile(channel_num, data,channel_bar,channel_bar_focus)
    local bar_height = channel_bar.h
    local show_group = Group { name = data.show }
    local logo = Image { src = "assets/channel_logos/logo-"..data.channel..".png" }
    logo.anchor_point = { 0, logo.h/2 }
    logo.position = { 30, bar_height/2 }
    local channel_num = Text { color = "grey35", text = ""..channel_num, font = FONT_NAME.." 192px" }
    local show_text = Text { color = "white", text = data.show, font = FONT_NAME.." 40px" }
    show_text.anchor_point = { 0, show_text.h/2 }
    show_text.position = { logo.x + logo.w + 15, bar_height/2 }
    channel_num.x = 15
    channel_num.y = -48

    local r_w = show_text.x + math.max(channel_num.w,show_text.w) + 30
    local bg_focus = Clone { source = channel_bar_focus, name = "bg-focus", x = 1, w = r_w }
    local bg_unfocus = Clone { source = channel_bar, name = "bg-unfocus", x = 1, w = r_w }

    show_group:add( Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height } },
                    bg_focus,
                    bg_unfocus,
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
                                                                { bg_unfocus,  "opacity",   0 },
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
                                                                { bg_unfocus,  "opacity", 255 },
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

local function ampm(hr,min)
    hr = tonumber(hr)
    min = min and (":"..min) or ""
    if hr < 12 then
        if hr == 0 then
            hr = 12
        end
        hr = hr..min.."AM"
    else
        if hr ~= 12 then
            hr = hr -12
        end
        hr = hr..min.."PM"
    end
    return hr
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
    get_current = function() return menubar:curr().show_ref end,
    create_more_info = function()
    local blue_color = "6fa4d3"
    local grey_color = "a0a9b0"
    local duration = 200
    local max_airings = 5
        local g = Group()
        g.image = Sprite{
            sheet = tv_show_sprites,
        }
        g.description_group = Group()
        g.slogan = Text{
            y = 400-375,
            w=text_w,
            ellipsize = "END",
            color = blue_color,
            font = FONT_NAME.." Bold 30px",
        }
        g.description = Text{
            y=400-300,
            wrap=true,
            wrap_mode = "WORD",
            w=text_w,
            color = grey_color,
            font = FONT_NAME.." 26px",
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
            font = FONT_NAME.." Bold 22px",
            text = "aired_on",
        }
        g.season_episode = Text{
            y=400-50,
            w=text_w,
            color = grey_color,
            font = FONT_NAME.."  24px",
            text = "season_episode",
        }


        g.next_airings = Group{
            x= 900,
            y= g.description.y-20,
            children={
                Text{
                    color = grey_color,
                    font = FONT_NAME.."  20px",
                    text = "Next Airings:",
                },
                Clone{ x = 150, source = vert_line },
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
                Clone{ y =  50, source = et,      },
                Clone{ y = 100, source = showbiz, },
                Clone{ y = 150, source = tmz,     },
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
            if show.show_description == json_null then
                dumptable(show)
            end
            --print(show.show_name,id,show.banner,show.cast,show.logo)
            g.image[id == "" and "hide" or "show"](g.image)
            g.image.id = id
            g.description_group.x = id ~= "" and (g.image.w+30) or 0
            --g.next_airings.x = g.description_group.x + text_w+300

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

            if show.series_id and series[show.series_id] and #series[show.series_id] > 1 then

                g.next_airings:show()
                local curr_show
                for i=1,#g.airings do
                    if i < (#series[show.series_id]) then
                        curr_show = series[show.series_id][i]

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

end

local function hide_bar()
    menubar:anim_out()
    backing.anim.state = "hidden"
end

local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    if menubar == nil then
        menubar = make_sliding_bar__highlighted_focus{
            make_stub = make_stub,
            make_item = make_show_tile,
            items     = channel_data,
        }
        screen:add(backing,menubar)
        menubar:hide()
        menubar.y = 925 - 150
        backing.y = 380
    end
    hide_bar()
end

local function on_deactivate(label, new_active)
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
end


local key_events = {
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
        backing.anim.state = "full"
        return true
    end,
}
local function on_key_down(label, key)

    return key_events[key] and key_events[key]()
end

return {
            label       = "Live TV",
            activate    = on_activate,
            deactivate  = on_deactivate,
            wake        = show_bar,
            sleep       = hide_bar,
            on_key_down = on_key_down,
        }
