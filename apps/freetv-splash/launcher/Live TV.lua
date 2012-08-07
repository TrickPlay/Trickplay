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
    local channel_num = Text { color = "grey85", text = ""..channel_num, font = "FreeFont Sans 40px" }
    channel_num.anchor_point = { 0, channel_num.baseline }
    channel_num.x = logo.x + logo.w + 5
    local show_text = Text { color = "white", text = data.show, font = "FreeFont Sans 50px" }
    show_text.anchor_point = { 0, show_text.h/2 }
    show_text.position = { channel_num.x + channel_num.w + 15, bar_height/2 }
    channel_num.y = show_text.y - show_text.h/2 + show_text.baseline

    local bg_focus = Clone { source = channel_bar_focus, name = "bg-focus", x = 1, w = show_text.x + show_text.w + 30 }
    local bg_unfocus = Clone { source = channel_bar, name = "bg-unfocus", x = 1, w = show_text.x + show_text.w + 30 }

    show_group:add( Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height } },
                    bg_focus,
                    bg_unfocus,
                    Rectangle { name = "edge", color = "#2d414e", size = { 1, bar_height }, x = 1 + show_text.x + show_text.w + 30 },
                    logo, channel_num, show_text )

    show_group.extra.anim = AnimationState {
                                                    duration = 250,
                                                    mode = EASE_IN_OUT_SINE,
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
    return show_group
end

local function unfocus_show(number)
    menubar:find_child("tv_shows").children[number]:unfocus()
end

local function focus_show(number)
    local the_show = menubar:find_child("tv_shows").children[number]
    the_show:focus()
    menubar:animate({ duration = 250, x = 200 - the_show.x })
end

local function build_bar()
    screen:add(menubar)
    local clone_src = Group { name = "Clone sources" }
    menubar:add(clone_src)
    clone_src:hide()

    channel_bar = Image { src = "assets/channelbar/channel-bar.png" }
    channel_bar_focus = Image { src = "assets/channelbar/channel-bar-focus.png" }
    bar_height = channel_bar.h
    clone_src:add(channel_bar, channel_bar_focus)

    local shows_group = Group { name = "tv_shows" }
    menubar:add(shows_group)

    for k,v in orderedPairs(channel_data) do
        local new_show = make_show_tile(k,v)
        new_show.x = show_offset
        show_offset = show_offset + new_show.w
        shows_group:add(new_show)
    end

    menubar.y = 925 - channel_bar.h

    focus_show(active_show)
end

local function show_bar()
    menubar:show()
    menubar:raise_to_top()
end

local function hide_bar()
    menubar:hide()
end

local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    print("Live TV on")
    if(menubar.count == 0) then build_bar() end
    hide_bar()
end

local function on_deactivate(label, new_active)
    label:animate({ duration = 250, opacity = 128, on_completed = function() if(new_active) then new_active:activate() end end } )
    hide_bar()
    print("Live TV off")
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

        if(keys.Left == key) then
            active_show = ((active_show - 2) % menubar:find_child("tv_shows").count) + 1
        else
            active_show = (active_show % menubar:find_child("tv_shows").count) + 1
        end

        focus_show(active_show)
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
