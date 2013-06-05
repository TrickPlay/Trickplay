local channel_names = {}
local i = 1
while i <= 100 do
    if type(channels[i]) == "number" then i = channels[i] end
    if channels[i] == nil then break end
    table.insert(channel_names,{
        num      = i,
        channel  = channels[i].id,
    })
    i = i + 1
end


-----------------------------------------------------------------------------
local nums = {}
for i=0,9 do
    nums[i] = ""..i
end
-----------------------------------------------------------------------------
local spc = {"!","@","#","$","%","^","&","*",}
-----------------------------------------------------------------------------

local Settings_G = Group{name="Settings"}
screen:add(Settings_G)
local function make_chan(data,channel_bar,channel_bar_focus)
    local bar_height = 148/2--channel_bar.h/2
    local padding  = 40
    local category = Group {
        name = data.label
    }
    local check = Sprite{
        sheet   = ui_sprites,
        id      = "check-mark-orange.png",
        x       = padding,
        opacity = 0,
        y     = bar_height/2,
    }
    check.x = check.x - check.w
    check.anchor_point = { 0, check.h/2 }
    local num = Text {
        color = "white",
        text  = data.num,
        font  = FONT_NAME.." 24px",
        x     = check.x+check.w+10,
        y     = bar_height/2,
    }
    num.anchor_point = { 0, num.h/2 }
    local label = Text {
        color = "white",
        text  = data.channel,
        font  = FONT_NAME.." 24px",
        x     = num.x+num.w+10,
        y     = bar_height/2,
    }
    label.anchor_point = { 0, label.h/2 }
    --channel_num.x = 15
    --channel_num.y = -48

    local bg_focus = Sprite {
        sheet  = ui_sprites,
        id     = "channelbar/channel-bar-focus.png",
        name   = "bg-focus",
        w      = label.x + label.w + padding,
        h      = bar_height,
    }
    category:add(
        bg_focus,
        num,
        check,
        label
    )

    category.extra.anim = AnimationState {
        duration = 250,
        mode = "EASE_OUT_SINE",
        transitions = {
            {
                source = "*",
                target = "focus",
                keys = {
                    { bg_focus, "opacity", 255 },
                    --{ label, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { bg_focus, "opacity", 0 },
                    --{ label, "opacity", 64 },
                },
            },
        },
    }

    category.extra.focus = function(self)
        self.anim.state = "focus"
    end

    category.extra.unfocus = function(self)
        self.anim.state = "unfocus"
    end
    category.anim:warp("unfocus")
    category.check = check
    return category
end

local function make_setting(data,channel_bar,channel_bar_focus)
    local bar_height = 148/2--channel_bar.h/2
    local padding  = 40
    local category = Group {
        name = data
    }
    local label = Text {
        color = "white",
        text  = data,
        font  = FONT_NAME.." 24px",
        x     = padding,
        y     = bar_height/2,
    }
    label.anchor_point = { 0, label.h/2 }
    --channel_num.x = 15
    --channel_num.y = -48

    local bg_focus = Sprite {
        sheet = ui_sprites,
        id = "channelbar/channel-bar-focus.png",
        name = "bg-focus",
        w = label.x + label.w + padding,
        h = bar_height,
    }

    category:add(
        bg_focus,
        label
    )

    category.extra.anim = AnimationState {
        duration = 250,
        mode = "EASE_OUT_SINE",
        transitions = {
            {
                source = "*",
                target = "focus",
                keys = {
                    { bg_focus, "opacity", 255 },
                    --{ label, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { bg_focus, "opacity", 0 },
                    --{ label, "opacity", 64 },
                },
            },
        },
    }

    category.extra.focus = function(self)
        self.anim.state = "focus"
    end

    category.extra.unfocus = function(self)
        self.anim.state = "unfocus"
    end
    category.anim:warp("unfocus")
    return category
end
local function make_category(data,channel_bar,channel_bar_focus)
    local bar_height = 148--channel_bar.h
    local category = Group {
        name = data.label
    }
    local label = Text {
        color = "white",
        text = data.label,
        font = FONT_NAME.." 40px"
    }
    label.anchor_point = { 0, label.h/2 }
    label.position = { 30, bar_height/2 }
    --channel_num.x = 15
    --channel_num.y = -48

    local bg_focus = Sprite {
        sheet = ui_sprites,
        id    = "channelbar/channel-bar-focus.png",
        name = "bg-focus",
        x = 1,
        w = label.x + label.w + 30
    }
    category:add(
        Rectangle {
            name = "edge",
            color = "#2d414e",
            size = { 1, bar_height }
        },
        bg_focus,
        Rectangle {
            name = "edge",
            color = "#2d414e",
            size = { 1, bar_height },
            x = 1 + label.x + label.w + 30
        },
        label
    )

    category.extra.anim = AnimationState {
        duration = 250,
        mode = "EASE_OUT_SINE",
        transitions = {
            {
                source = "*",
                target = "focus",
                keys = {
                    { bg_focus, "opacity", 255 },
                    { label, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { bg_focus, "opacity", 0 },
                    { label, "opacity", 64 },
                },
            },
        },
    }

    category.extra.focus = function(self)
        self.anim.state = "focus"
    end

    category.extra.unfocus = function(self)
        self.anim.state = "unfocus"
    end
    category.anim:warp("unfocus")

    category.sub_menu   = data.sub_menu
    return category
end

local menubar, curr_menu
local function sub_menu_press_down(self)
                    --self:unparent()
                    curr_menu = menubar
                    --backing.anim.state = "hidden"
                    self:anim_out()
                    return true
end
local chan_menu = make_sliding_bar__highlighted_focus{
                items        = channel_names,
                make_item    = make_chan,
                press_ok = function(self)
                    self:curr().check.opacity =
                        self:curr().check.opacity == 0 and
                        255 or 0
                    return true
                end,
                press_down   = sub_menu_press_down,
                --[[
                press_left = function( self )
                    backing:set_incoming(
                        default_vod_info,--self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    backing:set_incoming(
                        default_vod_info,--self:curr(),
                        "right"
                    )
                end,
                --]]
            }
            chan_menu:anim_out()
menubar       = make_sliding_bar__highlighted_focus{
    make_item = make_category,
    items     = {
        {
            label    = "Channels",
            sub_menu = chan_menu,--]]
        },
        {
            label    = "Audio",
            sub_menu = make_sliding_bar__highlighted_focus{
                items        = {"Stereo","Mono","HDMI Out"},
                make_item    = make_setting,
                press_down   = sub_menu_press_down,
            },
        },
        {
            label    = "Network",
            sub_menu = make_sliding_bar__highlighted_focus{
                items        = {"Wifi","Wired","Proxy","DNS"},
                make_item    = make_setting,
                press_down   = sub_menu_press_down,
            },
        },
        {
            label    = "Remote Devices",
            sub_menu = make_sliding_bar__highlighted_focus{
                items        = {"DLNA","Web","SuperConnect","WiDi"},
                make_item    = make_setting,
                press_down   = sub_menu_press_down,
            },
        },
        {
            label    = "Language",
            sub_menu = make_sliding_bar__highlighted_focus{
                items        = {
                    "Español",
                    "English",
                    "조선말, 한국어",
                    "Deutsch",
                    "Français",
                },
                make_item    = make_setting,
                press_down   = sub_menu_press_down,
            },
        },
    },---[[
    press_up = function(self)
        --print(self,curr_menu)
        Settings_G:add(self:curr().sub_menu)
        --self:curr().sub_menu:hide()
        self:curr().sub_menu.y = 700
        self:curr().sub_menu:anim_in()
        curr_menu = self:curr().sub_menu
        --backing.anim.state = "full"
        return true
    end,
    press_ok = function(self)
        self:press_up()
    end,--]]
}
menubar.y = 925 - 150
curr_menu = menubar

local function show_bar()
    menubar:anim_in()
    Settings_G:add(menubar)
end

local function hide_bar()
    dolater(150,menubar.anim_out)
    if curr_menu ~= menubar then
        curr_menu:anim_out()
        curr_menu = menubar
    end
    --backing.anim.state = "hidden"
end

local function on_activate(label)
    label:stop_animation()
    label:animate({ duration = 250, opacity = 255 })
    --if(menubar.count == 0) then build_bar() end

    hide_bar()
end

local function on_deactivate(label, new_active)
    label:stop_animation()
    label:animate({
        duration = 250,
        opacity = 128,
        on_completed = function()
            if(new_active) then
                new_active:activate()
            end
        end
    } )
    hide_bar()
end

local function on_wake(label)
    -- Since search is not implemented, use this as a cheat shortcut to resetting the service
    show_bar()
end

local function on_sleep(label)
    hide_bar()
end

local key_events = {
    [keys.Left] = function()
        return curr_menu.press_left  and curr_menu:press_left()--true
    end,
    [keys.Right] = function()
        return curr_menu.press_right and curr_menu:press_right()--true
    end,
    [keys.Up] = function()
        return curr_menu.press_up    and curr_menu:press_up()--true
    end,
    [keys.Down] = function()
        return curr_menu.press_down  and curr_menu:press_down()--true
    end,
    [keys.OK] = function()
        return curr_menu.press_ok    and curr_menu:press_ok()--true
    end,
}

local function on_key_down(label, key)
    return key_events[key] and key_events[key]()
end

return {
            label = "Settings",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
