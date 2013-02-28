--[[
Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]

local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,#(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end


local i = 1
local channel_data = {}
while i <= 100 do
    if type(channels[i]) == "number" then i = channels[i] end
    print(i)
    channel_data[i] = {
        channel = channels[i].name,
        show    = channels[i].schedule[1].show_name,
        show_ref = channels[i].schedule[1]
    }
    i = i + 1
end
--[[
local channel_data = {
    [2] = {
                channel = "fox", -- missing logo
                show = "The Big Bang Theory",
                hd = true,
            },
    [3] = {
                channel = "nbc",
                show = "Access Hollywood",
                hd = true,
            },
    [4] = {
                channel = "mytv", -- missing logo
                show = "The Insider",
                hd = false,
            },
    [5] = {
                channel = "cbs",
                show = "Eye on the Bay",
                hd = false,
            },
    [6] = {
                channel = "kicu", -- missing logo
                show = "Bay Area News",
                hd = false,
            },
    [7] = {
                channel = "abc",
                show = "Jeopardy!",
                hd = false,
            },
    [9] = {
                channel = "pbs", -- missing logo
                show = "Nightly Business Report",
                hd = false,
            },
    [12] = {
                channel = "cw", -- missing log
                show = "Two and a Half Men",
                hd = true,
            },
    [34] = {
                channel = "food", -- missing logo
                show = "Cupcake Wars",
                hd = true,
            },
    [35] = {
                channel = "tbs", -- missing logo
                show = "Seinfeld",
                hd = false,
            },
    [36] = {
                channel = "fx", -- missing logo
                show = "Two and a Half Men",
                hd = true,
            },
    [37] = {
                channel = "tnt",
                show = "Rizzoli & Isles",
                hd = true,
            },
    [38] = {
                channel = "espn",
                show = "Baseball Tonight",
                hd = true,
            },
    [42] = {
                channel = "usa",
                show = "Law & Order: Special Victims Unit",
                hd = true,
            },
    [47] = {
                channel = "a&e",
                show = "Mad Men",
                hd = true,
            },
}
--]]
local menubar = Group { }
local channel_bar
local channel_bar_focus
local bar_height
local show_offset = 0
local active_show = 2

local function make_show_tile(channel_num, data)
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

    local bg_focus = Clone { source = channel_bar_focus, name = "bg-focus", x = 1, w = show_text.x + show_text.w + 30 }
    local bg_unfocus = Clone { source = channel_bar, name = "bg-unfocus", x = 1, w = show_text.x + show_text.w + 30 }

    show_group:add( Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height } },
                    bg_focus,
                    bg_unfocus,
                    Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height }, x = 1 + show_text.x + show_text.w + 30 },
                    channel_num, logo, show_text )

    show_group.extra.anim = AnimationState {
                                                    duration = 250,
                                                    mode = "EASE_OUT_SINE",
                                                    transitions = {
                                                        {
                                                            source = "*",
                                                            target = "focus",
                                                            keys = {
                                                                { bg_focus, "opacity", 255 },
                                                                { bg_unfocus, "opacity", 0 },
                                                                { logo, "opacity", 255 },
                                                                { channel_num, "opacity", 255 },
                                                                { show_text, "opacity", 255 },
                                                            },
                                                        },
                                                        {
                                                            source = "*",
                                                            target = "unfocus",
                                                            keys = {
                                                                { bg_focus, "opacity", 0 },
                                                                { bg_unfocus, "opacity", 255 },
                                                                { logo, "opacity", 64 },
                                                                { channel_num, "opacity", 64 },
                                                                { show_text, "opacity", 64 },
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
    show_group.slogan = "Burberry Shopping App"
    show_group.description = [[The greatest app since sliced bread. Just ask Arnold. buy some cool stuff and pay lots n lots for it. Just press OK now!]]
    show_group.start_time = "8pm"
    show_group.aired_on = "8pm"
    show_group.season = 2
    show_group.episode = 3
    show_group.episode = 3
    return show_group
end

local function unfocus_show(number)
    menubar:find_child("tv_shows").children[number]:unfocus()
end

local function focus_show(number, t)
    menubar:stop_animation()
    local the_show = menubar:find_child("tv_shows").children[number]
    the_show:focus()
    local mode = "EASE_IN_OUT_SINE"
    menubar:animate({ duration = t, mode = mode, x = 200 - the_show.x })
end

local function make_stub(w)
    local stub = Group { name = "stub" }

    stub:add( Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height } },
                Clone { source = channel_bar, name = "bg-unfocus", x = 1, w = w - 2 },
                Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height }, x = w - 1 }
            )

    return stub
end

local backing = Group()

local set_incoming_show, set_current_show, hide_current_show

do
    local r = Rectangle{color="black",w=screen.w,opacity=155}
    backing:add(r)
    local hidden_y = 150
    backing.extra.anim = AnimationState {
                                                    duration = 250,
                                                    mode = "EASE_OUT_SINE",
                                                    transitions = {
                                                        {
                                                            source = "*",
                                                            target = "hidden",
                                                            keys = {
                                                                { r, "y", hidden_y },
                                                                { r, "h",        0 },
                                                            },
                                                        },
                                                        {
                                                            source = "*",
                                                            target = "full",
                                                            keys = {
                                                                { r, "y", hidden_y - 500 },
                                                                { r, "h",            500 },
                                                            },
                                                        },
                                                    },
    }
    function backing.extra.anim.timeline.on_started()
        if backing.extra.anim.state ~= "full" then
            --set_incoming_show({slogan="",description=""},"right")
            hide_current_show()
        end
    end
    function backing.extra.anim.timeline.on_completed()
        if backing.extra.anim.state == "full" then
            print("happenin")
            set_incoming_show(
                menubar:find_child("tv_shows").children[
                    active_show].show_ref,
                "right"
            )
        end
    end
end

do
    local text_w = 600
    local duration = 200
    local max_airings = 5
    local setup_info = function(g)
        g.slogan = Text{
            y = -350,
            w=text_w,
            ellipsize = "END",
            color = "white",
            font = FONT_NAME.." Bold 20px",
        }
        g.description = Text{
            y=-300,
            wrap=true,
            wrap_mode = "WORD",
            w=text_w,
            color = "white",
            font = FONT_NAME.." 20px",
            text = "description",
        }
        g.start_time = Text{
            y=-150,
            w=text_w,
            color = "white",
            font = FONT_NAME.." Bold 20px",
            text = "start_time",
        }
        g.aired_on = Text{
            y=-120,
            w=text_w,
            color = "white",
            font = FONT_NAME.." Bold 20px",
            text = "aired_on",
        }
        g.season_episode = Text{
            y=-90,
            w=text_w,
            color = "white",
            font = FONT_NAME.."  20px",
            text = "season_episode",
        }
        g.related = Text{
            x= 800,
            y=-350,
            text = "Related",
            color = "white",
            font = FONT_NAME.."  20px",
            text = "related",
        }
        g.next_airings = Text{
            x= g.related.x,
            y=-150,
            color = "white",
            font = FONT_NAME.."  20px",
            text = "next_airings",
        }
        g:add(
            g.slogan,
            g.description,
            g.start_time,
            g.aired_on,
            g.season_episode,
            g.related,
            g.next_airings
        )
        local airings = {}
        for i=1,max_airings do
            airings[i] = Text{
                x = g.next_airings.x+150*(i-1),
                y = g.next_airings.y+60,
                color = "white",
                font =  FONT_NAME.."  20px",
            }
            g:add(airings[i])
        end
        local curr_show
        function g:get_show()
            return curr_show
        end
        function g:set_show(show)
            if show == nil then error("nil show",2) end
            curr_show = show
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
            g.start_time.text =
                show.start_time ~= json_null and
                show.start_time_t.hour..":"..show.start_time_t.min or ""
            ---[[
            if show.series_id and #series[show.series_id] > 1 then
                --print("num in series",#series[show.series_id])
                g.next_airings.text =
                    show.show_name ~= json_null and
                    "Next Airings of "..show.show_name..":" or
                    "Next Airings:"

                local curr_show
                for i=1,#airings do
                    --print(i, (#series[show.series_id]))
                    if i < (#series[show.series_id]) then
                        curr_show = series[show.series_id][i]
                        airings[i].text =
                            curr_show.start_time_t.wkdy.." "..
                            curr_show.start_time_t.hour.."\n"
                        airings[i].text = airings[i].text..(
                            (curr_show.season_number  ~= json_null) and
                            (curr_show.episode_number ~= json_null) and
                            ("S "   ..curr_show.season_number..
                            " : Ep "..curr_show.episode_number) or
                            (curr_show.season_number ~= json_null) and
                            "S "..curr_show.season_number
                            (curr_show.episode_number ~= json_null) and
                            "Ep "..curr_show.episode_number or "")
                    else
                        airings[i].text = "b"
                    end
                end
            else
                g.next_airings.text = ""
            end
            --]]
        end
        return g
    end

    local   incoming_show = setup_info( Group{ name=   "incoming_show", opacity = 0 } )
    local displaying_show = setup_info( Group{ name= "displaying_show", opacity = 0, x = 200 } )
    local next_show
    local animating = false

    set_incoming_show = function(curr_show,direction)
        if curr_show == nil then error("nil show",2) end

        if animating then
            next_show = {curr_show,direction}
            return
        end
        animating = true
        print("incoming")
        incoming_show:set_show(curr_show)

        if direction == "left" then
            incoming_show.x = displaying_show.x - screen.w
            displaying_show:animate{
                duration = duration,
                x = displaying_show.x + screen.w,
                opacity = 0,
            }
        elseif direction == "right" then
            incoming_show.x = displaying_show.x + screen.w
            displaying_show:animate{
                duration = duration,
                x = displaying_show.x - screen.w,
                opacity = 0,
            }
        else
            error("Direction must equal 'left' or 'right' . Received "..
                tostring(direction),2)
        end
        incoming_show:animate{
            duration = duration,
            x = displaying_show.x,
            opacity = 255,
            on_completed = function()
                incoming_show.opacity = 0
                displaying_show:stop_animation()
                displaying_show.x = incoming_show.x
                displaying_show:set_show(incoming_show:get_show())
                displaying_show.opacity = 255
                animating = false
            end
        }
    end

    hide_current_show = function()
        displaying_show:animate{
            duration=200,
            opacity=0,
            y=displaying_show.y+500,
            on_completed = function()
                displaying_show.y = displaying_show.y -500
            end
        }
    end
    set_current_show = function(curr_show)
        displaying_show:set_show(curr_show)
    end
    backing:add(displaying_show,incoming_show)

end

local function build_bar()
    screen:add(backing,menubar)
    menubar:hide()
    local clone_src = Group { name = "Clone sources" }
    menubar:add(clone_src)
    clone_src:hide()

    channel_bar = Image { src = "assets/channelbar/channel-bar.png" }
    channel_bar_focus = Image { src = "assets/channelbar/channel-bar-focus.png" }
    bar_height = channel_bar.h
    clone_src:add(channel_bar, channel_bar_focus)

    local clip_group_outter = Group { name = "clip_outter" }
    menubar:add(clip_group_outter)
    local clip_group = Group { name = "clip_inner" }
    clip_group_outter:add(clip_group)

    local shows_group = Group { name = "tv_shows" }
    clip_group:add(shows_group)

    for k,v in orderedPairs(channel_data) do
        local new_show = make_show_tile(k,v)
        new_show.x = show_offset
        show_offset = show_offset + new_show.w
        shows_group:add(new_show)
    end

    local stubs_group = Group { name = "stubs" }
    clip_group:add(stubs_group)

    local stub = make_stub( 205 )
    stub.x = -205
    stubs_group:add(stub)

    stub = make_stub( screen.w - ( shows_group.children[shows_group.count].w + 200 ) )
    stub.x = shows_group.children[shows_group.count].w + shows_group.children[shows_group.count].x
    stubs_group:add(stub)

    clip_group_outter.clip = { -205, 0, 205+stub.x+stub.w, bar_height }

    menubar.y = 925 - channel_bar.h
    backing.y = menubar.y

    focus_show(active_show,10)
end

local function show_bar()
    menubar:find_child("clip_inner"):stop_animation()
    menubar:show()
    menubar:find_child("clip_inner"):animate({ duration = 250, y = 0, mode = "EASE_OUT_SINE" })
--    menubar:raise_to_top()
end

local function hide_bar()
    menubar:find_child("clip_inner"):stop_animation()
    menubar:find_child("clip_inner"):animate({ duration = 250, y = bar_height, mode = "EASE_OUT_SINE", on_completed = function() menubar:hide() end })
    backing.anim.state = "hidden"
end

local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    if(menubar.count == 0) then build_bar() end
    hide_bar()
end

local function on_deactivate(label, new_active)
    label:animate({ duration = 250, opacity = 128, on_completed = function() if(new_active) then new_active:activate() end end } )
    hide_bar()
end

local function on_wake(label)
    show_bar()
end

local function on_sleep(label)
    hide_bar()
end

local function on_key_down(label, key)
    if( keys.Left == key or keys.Right == key ) then
        unfocus_show(active_show)

        local transition_time = 250
        if(keys.Left == key) then
            active_show = ((active_show - 2) % menubar:find_child("tv_shows").count) + 1
            if( active_show == menubar:find_child("tv_shows").count ) then transition_time = menubar:find_child("tv_shows").count*50 end
            if backing.anim.state == "full" then
                set_incoming_show(
                    menubar:find_child("tv_shows").children[
                        active_show].show_ref,
                    "left"
                )
            end
        else
            active_show = (active_show % menubar:find_child("tv_shows").count) + 1
            if( active_show == 1 ) then transition_time = menubar:find_child("tv_shows").count*50 end
            if backing.anim.state == "full" then
                set_incoming_show(
                    menubar:find_child("tv_shows").children[
                        active_show].show_ref,
                    "right"
                )
            end
        end

        focus_show(active_show, transition_time)
        return true
    elseif( keys.Up == key ) then
        backing.anim.state = "full"
        return true
    end
end

return {
            label = "Live TV",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
