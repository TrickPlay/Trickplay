
local icon_w = 480
local icon_h = 270
local unsel_scale = .75
local   sel_scale = 1.25
local launcher_icons = {}
generic_launcher_icon = Image{src="assets/generic-app-icon.jpg"}
screen:add( generic_launcher_icon )
generic_launcher_icon:hide()


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

local backing = make_MoreInfoBacking{
    info_x     = 740,
    expanded_h = 423,
    get_current = function() return menubar:curr() or {description=lorem_ipsum} end,
    create_more_info = function()
        local g = Group()
        local text_w = 800
        g.description = Text{
            y=313-270,
            wrap=true,
            wrap_mode = "WORD",
            w=text_w,
            color = "white",
            font = FONT_NAME.." 26px",
        }
        g:add( g.description )
        return g
    end,
    populate = function(g,show)
        g.description.text = show.description
    end,
    empty_info = {description=""},
}
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
        backing.y = 812.5-313
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
    [keys.Left] = function()
        menubar:press_left()
        if backing.anim.state == "full" then
            backing:set_incoming(menubar:curr(),"left")
        end
        return true
    end,
    [keys.Right] = function()
        menubar:press_right()
        if backing.anim.state == "full" then
            backing:set_incoming(menubar:curr(),"right")
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
