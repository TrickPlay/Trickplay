
local icon_w = 480
local icon_h = 270
local unsel_scale = .75
local   sel_scale = 1.25
local launcher_icons = {}
generic_launcher_icon = Image{src="assets/generic-app-icon.jpg"}
screen:add( generic_launcher_icon )
generic_launcher_icon:hide()

local function pre_x(i)
    return (10+icon_w*unsel_scale)*(i-1)-icon_w*(sel_scale-unsel_scale)/2
end
local function sel_x(i)
    return (10+icon_w*unsel_scale)*(i-1)--icon_w*.25
end
local function post_x(i)
    return (10+icon_w*unsel_scale)*(i-1)+icon_w*(sel_scale-unsel_scale)/2
end

local padding=10
local function make_icon(v)

    local i = Image()
    if not(i:load_app_icon(v.id,"launcher-icon.png") or
        i:load_app_icon(v.id,"launcher-icon.jpg")) then

        i = Clone{source=generic_launcher_icon}
    end
    i.size = {icon_w,icon_h}
    local g = Group()
    local inner_g = Group()
    local title_grp = Group()
    local r = Rectangle{
        w=i.w,
        h=62,--t.h+padding,
        color="444444",
        --opacity = 200
    }
    local t = Text{
        x= 12,
        y=r.h/2-1,--padding/2,
        w=i.w-padding,
        ellipsize = "END",
        color = "white",
        text=v.name,
        font = FONT_NAME.." 34px"
    }
    t.anchor_point={0,t.h/2}
    local duration = 250
    local mode     = "EASE_OUT_SINE"
    g.slogan = v.long_name or v.name
    g.description = v.description or lorem_ipsum
    g.name = v.id
    inner_g:add(i,title_grp)
    g:add(inner_g)
    title_grp:add(r,t)
    --title_grp.y = -r.h
    i.y = r.h


    inner_g.position     = { inner_g.w/2*sel_scale, inner_g.h*sel_scale}
    inner_g.anchor_point = { inner_g.w/2, inner_g.h}
    --g.y_rotation = { 0, g.w/2, 0 }
    local anim = AnimationState {
        duration = duration,
        mode = mode,
        transitions = {
            {
                source = "*",
                target = "focus",
                keys = {
                    { title_grp, "opacity", 255 },
                    { inner_g, "scale", { sel_scale, sel_scale } },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { title_grp, "opacity", 0 },
                    { inner_g, "scale", { unsel_scale, unsel_scale } },
                },
            },
        },
    }

    g.extra.focus = function(self,x)
        --title_grp.clip_to_size = false
        anim.state = "focus"
        if x then
            g:stop_animation()
            g:animate{
                duration=duration,
                mode = mode,
                x = x,
            }
        end
    end

    g.extra.unfocus = function(self,x)
        --title_grp.clip_to_size = true
        anim.state = "unfocus"
        if x then
            g:stop_animation()
            g:animate{
                duration=duration,
                mode = mode,
                x = x,
            }
        end
    end
    anim:warp("unfocus")
    return g
end

local app_list = {}
do
    for k,v in pairs(apps:get_for_current_profile()) do

        if not v.attributes.nolauncher    and
            k ~= "com.trickplay.launcher" and
            k ~= "com.trickplay.empty"    and
            k ~= "com.trickplay.app-shop" and
            k ~= "com.trickplay.editor"   then

            --local g=make_icon(v)

            --table.insert(launcher_icons,g)
            table.insert(app_list,v)
        end

    end
end


local menubar = make_sliding_bar__expanded_focus{
    items = app_list,
    make_item = make_icon,
    unsel_offset = icon_w*(sel_scale-unsel_scale)/2,
    spacing = 30+icon_w*unsel_scale,
}
local app_offset = -icon_w*.25
local active_app = 2
local backing = Group()

local set_incoming_text, set_current_text

do
    local r = Rectangle{color="black",w=screen.w,opacity=155}
    backing:add(r)
    local hidden_y = icon_h/2-25
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
                                                                { r, "y", hidden_y - 423 },
                                                                { r, "h",            423 },
                                                            },
                                                        },
                                                    },
    }
    function backing.extra.anim.timeline.on_started()
        if backing.extra.anim.state ~= "full" then
            set_incoming_text({slogan="",description=""},"right")
        end
    end
    function backing.extra.anim.timeline.on_completed()
        if backing.extra.anim.state == "full" then
            set_incoming_text(menubar:curr(),"right")
        end
    end
end

do
    local text_w = 800
    local duration = 200
    local setup_text = function(g)
        g.description = Text{
            y=-270,
            wrap=true,
            wrap_mode = "WORD",
            w=text_w,
            color = "white",
            font = FONT_NAME.." 26px",
        }
        g:add( g.description )
        return g
    end

    local   incoming_text = setup_text( Group{ name=   "incoming_text" } )
    local displaying_text = setup_text( Group{ name= "displaying_text",x = 740 } )
    local next_text
    local animating = false
    local set_incoming_text__internal
    set_incoming_text__internal = function(curr_app,direction)

        next_text = nil
        incoming_text.description.text = curr_app.description

        if direction == "left" then
            incoming_text.x = displaying_text.x - screen.w
            displaying_text:animate{
                duration = duration,
                x = displaying_text.x + screen.w,
                opacity = 0,
            }
        elseif direction == "right" then
            incoming_text.x = displaying_text.x + screen.w
            displaying_text:animate{
                duration = duration,
                x = displaying_text.x - screen.w,
                opacity = 0,
            }
        else
            error("Direction must equal 'left' or 'right' . Received "..
                tostring(direction),2)
        end
        incoming_text:animate{
            duration = duration,
            x = displaying_text.x,
            opacity = 255,
            on_completed = function()
                displaying_text:stop_animation()
                displaying_text.x = incoming_text.x
                displaying_text.description.text = incoming_text.description.text
                displaying_text.opacity = 255
                if next_text then
                    dolater(set_incoming_text__internal,next_text[1],next_text[2])
                end
                animating = false
            end
        }
    end
    set_incoming_text = function(curr_app,direction)
        if animating then
            next_text = {curr_app,direction}
            return
        else
            animating = true
            set_incoming_text__internal(curr_app,direction)
        end
    end

    set_current_text = function(curr_app)
        displaying_text.description.text = curr_app.description
    end
    backing:add(displaying_text,incoming_text)

end
--[=[]]
local function focus_app(number, t)
    menubar:stop_animation()
    local the_app = apps_list[number]
    the_app:raise_to_top()
    the_app:focus(sel_x(number))
    local mode = "EASE_IN_OUT_SINE"
    menubar:animate({ duration = t, mode = mode, x = 400 - sel_x(number) })
end

local function unfocus_app(number,direction)
    apps_list[number]:unfocus(direction==1 and pre_x(number) or post_x(number))
end

local function transfer_focus(curr_i,direction,dur)


    if curr_i == 1 and direction == -1 then
        transition_time = menubar:find_child("apps").count*50

        for i,app in ipairs(menubar:find_child("apps").children) do
            app.x = app.x - (post_x(1) - pre_x(1))
        end
        menubar.x = menubar.x + (post_x(1) - pre_x(1))

        unfocus_app(curr_i,1)
    elseif curr_i == menubar:find_child("apps").count and direction == 1 then
        transition_time = menubar:find_child("apps").count*50
        for i,app in ipairs(menubar:find_child("apps").children) do
            app.x = app.x + (post_x(1) - pre_x(1))
        end
        menubar.x = menubar.x - (post_x(1) - pre_x(1))

        unfocus_app(curr_i,-1)
    else
        unfocus_app(curr_i,direction)
    end
    curr_i = wrap_i(
        curr_i+direction,
        menubar:find_child("apps").count
    )


    focus_app( curr_i, dur )
end

local function build_bar()
    screen:add(backing,menubar)
    menubar:hide()

    local clip_group_outter = Group { name = "clip_outter" }
    menubar:add(clip_group_outter)
    local clip_group = Group { name = "clip_inner" }
    clip_group_outter:add(clip_group)

    local apps_group = Group { name = "apps" }
    clip_group:add(apps_group)

    for k,v in pairs(launcher_icons) do
        local new_movie = v
        v.x = pre_x(#apps_list+1)
        apps_group:add(v)
        apps_list[#apps_list+1] = v
    end
    for i,v in ipairs(apps_list) do
        v.x = (
            i == active_app and sel_x or
            i <  active_app and pre_x or
            i >  active_app and post_x)(i)
    end

    menubar.y = 812.5
    backing.y = menubar.y
    focus_app(active_app,10)
    --set_current_text(apps_list[active_app])
end
--]=]
local function show_bar()
    --menubar:show()
    backing.anim.state = "full"
    menubar:anim_in()
end

local function hide_bar()
    --menubar:hide()
    backing.anim.state = "hidden"
    menubar:anim_out()
end


local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    --if(menubar.count == 0) then build_bar() end
    if menubar.parent == nil then

        screen:add(backing,menubar)
        menubar:hide()
        menubar.x = -300
        menubar.y = 812.5-313
        backing.y = 812.5
    end
    hide_bar()
end

local function on_deactivate(label, new_active)
    label:animate{
        duration = 250,
        opacity = 128,
        on_completed = function()
            if(new_active) then new_active:activate() end
        end ,
    }
    hide_bar()
end

local function on_wake(label)
    show_bar()
end

local function on_sleep(label)
    hide_bar()
end

local prev_app
local key_events = {
    [keys.Left] = function()--[=[]]
        --unfocus_app(active_app)
        prev_app = active_app
        local transition_time = 250
        active_app = wrap_i(active_app-1,menubar:find_child("apps").count)--((active_app - 2) % menubar:find_child("apps").count) + 1
        if( active_app == menubar:find_child("apps").count ) then
            transition_time = menubar:find_child("apps").count*50
        end
        if backing.anim.state == "full" then
            set_incoming_text(apps_list[active_app],"left")
        end
        --focus_app(active_app, transition_time)
        transfer_focus(prev_app,-1,transition_time)
        --]=]
        menubar:press_left()
        if backing.anim.state == "full" then
            set_incoming_text(menubar:curr(),"left")
        end
        return true
    end,
    [keys.Right] = function()--[=[]]
        --unfocus_app(active_app)
        prev_app = active_app
        local transition_time = 250
        active_app = wrap_i(active_app+1,menubar:find_child("apps").count)--(active_app % menubar:find_child("apps").count) + 1
        if( active_app == 1 ) then
            transition_time = menubar:find_child("apps").count*50
        end
        if backing.anim.state == "full" then
            set_incoming_text(apps_list[active_app],"right")
        end
        --focus_app(active_app, transition_time)
        transfer_focus(prev_app,1,transition_time)
        --]=]
        menubar:press_right()
        if backing.anim.state == "full" then
            set_incoming_text(menubar:curr(),"right")
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
            label = "Apps",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
