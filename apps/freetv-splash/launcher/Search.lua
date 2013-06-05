local Search_g = Group{name="Search Sub Menu"}
screen:add(Search_g)

local alpha = {}

local A = "A"
for i=1,26 do
    alpha[i] = string.char(A:byte() + i-1)
end

-----------------------------------------------------------------------------
local nums = {}
for i=0,9 do  nums[i] = ""..i   end
-----------------------------------------------------------------------------
local spc = {"_","!","@","#","$","%","^","&","*",}
-----------------------------------------------------------------------------

local backing_h = 550

local backing = Group{
    name = "Search Backing",
    y    = 925 - backing_h,
    clip = {0,0,screen_w,backing_h}
}
local backing_clip_contents = Group{y=backing_h}
backing:add(backing_clip_contents)
backing_clip_contents:add(
    Rectangle{size=screen.size,color = "000000",opacity = 155}
)
local left_margin = 200

local no_results = Text{
    x       = left_margin,
    y       = 200,
    text    = "No Results.",
    color   = "white",
    opacity = 190,
    font    = FONT.." 32px",
}
no_results:hide()

local cursor = Text{
    x     = left_margin,
    y     = 300,
    text  = "_",
    color = "white",
    font  = FONT.." 32px",
}
local query_string = Text{
    x     = left_margin,
    y     = 300,
    text  = "",
    color = "white",
    font  = FONT.." 32px",
    on_text_changed = function(self)
        cursor.x = left_margin+self.w
    end,
}
local cursor_blink = Timer{
    interval = 500,
    on_timer = function()
        cursor[cursor.is_visible and "hide" or "show"](cursor)
    end,
}
cursor_blink:stop()
backing_clip_contents:add(query_string,cursor,no_results)


--local last_search_was_bad = false
local function search(query)
    query = query:upper()
    local start_i, end_i
    local result = {}
    for upper_case_name,name in pairs(movie_hash) do
        start_i, end_i = upper_case_name:find(query,1,true)
        if start_i then
            table.insert(result,
                {
                    name    = name,
                    start_i = start_i,
                    end_i   = end_i
                }
            )
        end
    end
    table.sort(result,function(a,b) return a.name < b.name end)
    return result
end

local menubar, curr_menu
local result_g
local result_g_t = {}
local function add_char(c)
    local query = query_string.text
    if query:len() >= 20 then return end
    query = query..c.label
    query_string.text = query
    --if last_search_was_bad then return end
    if query:len() <= 2 then return end
    local result = search(query)

    if result_g then
        table.insert(result_g_t, result_g)
        result_g:unparent()
    end
    if #result > 0 then
        no_results:hide()
        result_g = make_windowed_list{
            items         = result,
            orientation   = "vertical",
            bg_is_separate = true,
            make_item     = function(i,entry)
                local y_padding = 10
                local g   = Group{name=entry.name}
                local t   = Text{
                    color = "white",
                    text  = entry.name,
                    font  = FONT.." 32px",
                    x     = left_margin,
                    anchor_point = {0,-y_padding}
                }
                local r  = Sprite {
                    sheet = ui_sprites,
                    id = "channelbar/channel-bar-focus.png",
                }
                r.x = t.x+t:position_to_coordinates(entry.start_i-1)[1]
                r.w = t.x+t:position_to_coordinates(entry.end_i    )[1]-r.x
                r.h = t.h+y_padding*2
                g:add(r,t)
                local bg  = Sprite{
                    sheet=ui_sprites,
                    id="channelbar/channel-bar.png",
                    w = screen_w,
                    h=t.h+y_padding*2,
                }
                --local instance = Group{ children = { t } }

                return bg,g
            end,
            visible_range = 260,
            hl = Sprite{sheet=ui_sprites,name="HL",id = "channelbar/channel-bar-focus.png",w=screen_w},
        }
        result_g.y = 0--query_string.y - 300
        backing_clip_contents:add( result_g )
        result_g:warp_focus_to_end()--result_g:len())

        function result_g:press_left()
            return true
        end
        function result_g:press_right()
            return true
        end
        function result_g:press_up()
            return self:press_backward()
        end
        function result_g:press_down()
            if not self:press_forward() then
                self:anim_hl_out()
                menubar:focus()
                curr_menu = menubar
            end
            return true
        end
    else
        no_results:show()
    end
end

local function entries_add_char(t)
    for i,v in ipairs(t) do
        t[i] = {label=v,press_ok = add_char}
    end
    return t
end
local function delete_char(   )
    local s = query_string.text
    if s:len() == 0 then return end
    s = s:sub(1,-2)
    query_string.text = s
    no_results:hide()
    if result_g then
        result_g:unparent()
        result_g = table.remove(result_g_t)
        backing_clip_contents:add( result_g )
    elseif s:len() > 2 then
        no_results:show()
    end
end
local function clear_query()
    query_string.text = ""
    no_results:hide()
    if result_g then
        result_g:unparent()
        result_g = nil
        result_g_t = {}
    end
end

function backing:anim_in(f)
    backing_clip_contents:stop_animation()
    backing_clip_contents:animate{
        duration = 200, y = 0,
    }
    cursor_blink:start()
    cursor_blink.x=left_margin
end
function backing:anim_out(f)
    backing_clip_contents:stop_animation()
    backing_clip_contents:animate{
        duration = 200, y = backing_h,
        on_completed = function()
            backing:unparent()
            clear_query()
            return f and f()
        end,
    }
    cursor_blink:stop()
end

-----------------------------------------------------------------------------

local function make_category(data,channel_bar,channel_bar_focus)
    local padding = 10
    local bar_height = 148--channel_bar.h
    local category = Group {
        name = data.label
    }
    local label = Text {
        color = "white",
        text = data.label,
        font = FONT.." 32px"
    }
    label.anchor_point = { 0, label.h/2 }
    label.position = { padding, bar_height/2 }
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
                    --{ bg_unfocus, "opacity", 0 },
                    { label, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { bg_focus, "opacity", 0 },
                    --{ bg_unfocus, "opacity", 255 },
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
    category.press_ok = data.press_ok
    return category
end

menubar       = make_sliding_bar__highlighted_focus{
    make_item = make_category,
    items     = {
        entries_add_char(alpha),
        {
            {label="DEL",press_ok=delete_char},
            {label="SPC",press_ok=function ()
                add_char{label=" "}
            end
            },
            {label="CLR",press_ok=clear_query}
        },
        entries_add_char(nums),
        entries_add_char(spc),
    },
    space_on_sub_tables = true,
    no_edges_on_stubs   = true,
}
menubar.y = 925 - 150

curr_menu = menubar
function menubar:press_up()
    if result_g then
        self:remove_focus()
        curr_menu = result_g
        result_g:anim_hl_in()
    end
end

local function show_bar()
    menubar:anim_in()
    backing:anim_in()
    Search_g:add(backing,menubar)
end

local function hide_bar()
    dolater(150,menubar.anim_out)
    backing:anim_out()
end

local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })

    hide_bar()
end

local function on_deactivate(label, new_active)
    label:animate({
        duration = 250,
        opacity = 128,
        on_completed = function()
            if  new_active then
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
        return curr_menu == menubar  and menubar:curr_entry():press_ok()--add_char(menubar:curr_entry())
    end,
    [keys.RED] = function()
        return curr_menu == menubar  and delete_char()
    end,
    [keys.YELLOW] = function()
        return curr_menu == menubar  and clear_query()
    end,
}

local function on_key_down(label, key)
    return key_events[key] and key_events[key]()
end

return {
            label       = "Search",
            activate    = on_activate,
            deactivate  = on_deactivate,
            wake        = on_wake,
            sleep       = on_sleep,
            on_key_down = on_key_down,
        }
