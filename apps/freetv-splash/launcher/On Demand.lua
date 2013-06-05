local category_max = 20
local t_new_releases = {}
local t_top_picks    = {}
local t_movies       = {}
local t_tv_catchup   = {}
local t_recommended  = {}

movie_hash = {}
for i=1,25 do
    local m = table.remove(movie_data,1)

    movie_hash[m.name:upper()] = m.name
    if #t_top_picks < category_max then table.insert(t_top_picks,m) end
    if m.year > 2010 then
        if #t_new_releases < category_max then table.insert(t_new_releases,m) end
    end
end
while #movie_data > 0 do
    local m = table.remove(movie_data,1)

    movie_hash[m.name:upper()] = m.name
    if m.year >= 2010 then
        if #t_new_releases < category_max then table.insert(t_new_releases,m) end
    end
    local r = math.random(1,3)
    if r == 1 then
        if #t_movies < category_max then table.insert(t_movies,m) end
    elseif r == 2 then
        if #t_tv_catchup < category_max then table.insert(t_tv_catchup,m) end
    else
        if #t_recommended < category_max then table.insert(t_recommended,m) end
    end
end


local movie_w = 180
local grey_color = "a0a9b0"
local curr_menu

local default_vod_info = {
    title       = "Hugo Cabret",
    description = lorem_ipsum_longer,
    year        = "(2011)",
    rating      = "PG",
    run_time    = "126 min",
}

local empty_vod_info = {
    title       = "",
    description = "",
    year        = "",
    rating      = "",
    run_time    = "",
}
local VOD_G = Group{name="On Demand"}
screen:add(VOD_G)
local backing = make_MoreInfoBacking{
    info_x     = 200,
    expanded_h = 830,
    parent     = VOD_G,
    create_more_info = function()
        local text_w = 800
        local duration = 200
        local max_airings = 5
        local g = Group()
        g.title = Text{
            y = 30,x=500,
            --w=text_w,
            --ellipsize = "END",
            color = "white",
            font = "Lato Bold 40px",
            --text = "Hugo Cabret"
        }
        g.year = Text{
            y = g.title.y+20,
            x = g.title.x + g.title.w + 15,
            --w=text_w,
            --ellipsize = "END",
            color = grey_color,
            font = FONT_NAME.." 18px",
            --text = "(2011)"
        }
        g.description = Text{
            y=g.title.y+120,
            x=g.title.x,
            wrap=true,
            wrap_mode = "WORD",
            w = text_w,
            h = 170,
            ellipsize = "END",
            color = grey_color,
            font = FONT_NAME.." 24px",
            --text = lorem_ipsum,
        }
        g.rating = Text{
            y=g.title.y+g.title.h+20,
            x=g.title.x+4,
            --w=text_w,
            color = grey_color,
            font = "Lato Bold 18px",
            --text = "PG",
        }
        g.rating_box = Rectangle{
            color = "00000000",
            border_width = 1,
            border_color = g.rating.color,
            y = g.rating.y,
            x = g.rating.x-4,
            h = g.rating.h+1,
        }
        g.run_time = Text{
            y=g.rating.y,
            x=g.rating.x+g.rating.w+10,
            --w=text_w,
            color = grey_color,
            font = FONT_NAME.." 18px",
            --text = "126 min",
        }
        g:add(
            g.title,
            g.description,
            g.year,
            g.rating_box,
            g.rating,
            g.run_time
        )
        return g
    end,
    populate = function(g,show)
            show = show.data
            --dumptable(show)
            g.title.text       = show.name or "Hugo Cabret"
            g.description.text = show.plot or show.plot_simple or lorem_ipsum
            g.year.text        = show.year or "2002"
            g.year.x           = g.title.x + g.title.w + 10
            g.rating.text      = string.gsub(show.rated or "NOT_RATED","_"," ")
            g.rating_box.w     = g.rating.w+8
            g.run_time.text    = show.runtime and show.runtime[1] or "120 min"
            g.run_time.x       = g.rating.x + g.rating.w + 30
    end,
    empty_info = empty_vod_info,
    get_current = function() return curr_menu:curr() end,
}

local   sel_scale = 2.5
local unsel_scale = 1
local function make_poster(item)
    local grey = "444444"
    local duration = 250
    local mode = "EASE_OUT_SINE"
    local poster  = Group()
    local inner_g = Group()
    local img = Sprite { sheet=imdb_sprites, id = item.poster:sub(1+("assets/imdb_posters/"):len()), x = 2,w=180,h=240 }
    local img_scrim = Rectangle { color = grey, w = img.w + 4, h = img.h + 4 }

    local title_grp = Group { w = img.w }
    local title   = Text {
        font      = FONT_NAME.." 40px",
        color     = "white",
        text      = item.name,
        x         = 6,
        y         = 1,
        scale     = { 1/sel_scale, 1/sel_scale },
        ellipsize = "END",
        w         =  img.w*sel_scale-6,
    }
    local title_scrim = Rectangle {
        color = grey,
        w = img.w + 4,
        h = (title.h/sel_scale)+4
    }
    title_grp:add(title_scrim, title)
    title_grp.w = img.w
    img_scrim.y = title_scrim.h-1
    img.y = img_scrim.y+2
    --title_grp.clip_to_size = true
    inner_g:add(img_scrim, img,title_grp)
    poster:add(inner_g)
    inner_g.position     = { inner_g.w/2*sel_scale, inner_g.h*sel_scale}
    inner_g.anchor_point = { inner_g.w/2, inner_g.h}

    --poster.anchor_point = { poster.w/2, poster.h }
    --poster.y_rotation = { 0, poster.w/2, 0 }
    poster.extra.anim = AnimationState {
                        duration = duration,
                        mode = mode,
                        transitions = {
                            {
                                source = "*",
                                target = "focus",
                                keys = {
                                    { poster, "opacity", 255 },
                                    --{ poster, "y_rotation", 0 },
                                    { title_grp, "opacity", 255 },
                                    { inner_g, "scale", { sel_scale, sel_scale } },
                                },
                            },
                            {
                                source = "*",
                                target = "unfocus",
                                keys = {
                                    { poster, "opacity", 64 },
                                    --{ poster, "y_rotation", -15 },
                                    { title_grp, "opacity", 0 },
                                    { inner_g, "scale", { unsel_scale, unsel_scale } },
                                },
                            },
                        },
    }

    poster.extra.focus = function(self,x)
        --title_grp.clip_to_size = false
        self.anim.state = "focus"
        if x then
            self:complete_animation()
            self:animate{
                duration=duration,
                mode = mode,
                x = x,
            }
        end
    end

    poster.extra.unfocus = function(self,x)
        --title_grp.clip_to_size = true
        self.anim.state = "unfocus"
        if x then
            self:complete_animation()
            self:animate{
                duration=duration,
                mode = mode,
                x = x,
            }
        end
    end
    poster.anim:warp("unfocus")
    poster.data = item
    poster.h = poster.h + 150
    return poster
end--[[
local sub_menu = make_sliding_bar__expanded_focus{
    items = movies,
    make_item = make_poster,
    unsel_offset = movie_w*2/2-30,
    spacing = 10+movie_w,
}
--]]
local function make_category(data,channel_bar,channel_bar_focus)
    local bar_height = 148--channel_bar.h
    local category = Group { name = data.label }
    local logo = Sprite {
        sheet=ui_sprites,
        id = data.logo,
    }
    logo.anchor_point = { 0, logo.h/2 }
    logo.position = { 30, bar_height/2 }
    local logo_f = Sprite {
        sheet=ui_sprites,
        id = data.logo_f,
    }
    logo_f.anchor_point = { 0, logo_f.h/2 }
    logo_f.position = { 30, bar_height/2 }
    --local channel_num = Text { color = "grey35", text = ""..channel_num, font = FONT_NAME.." 192px" }
    local label = Text { color = "white", text = data.label, font = FONT_NAME.." 40px" }
    label.anchor_point = { 0, label.h/2 }
    label.position = { logo.x + logo.w - 80, bar_height/2 }
    --channel_num.x = 15
    --channel_num.y = -48

    local bg_focus = Sprite {
        sheet=ui_sprites,
        id = "channelbar/channel-bar-focus.png",
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
        --channel_num,
        logo,
        logo_f,
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
                    { logo, "opacity", 0 },
                    { logo_f, "opacity", 255 },
                    --{ channel_num, "opacity", 255 },
                    { label, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { bg_focus, "opacity", 0 },
                    { logo, "opacity", 255 },
                    { logo_f, "opacity", 0 },
                    --{ channel_num, "opacity", 64 },
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
local ppv_menu = Group()
do
    local button_group = Group{name="Buttons",x=700,y=630-105}
    local poster = Clone {x=200}
    local right_side = Group()
    local buttons = {
        {"Free","Preview"},
        {"$4.99","TV (2 day)"},
        {"$3.99","Netflix"},
        {"$4.95","Hulu"},
    }
    local genre = Text{
        color = grey_color,
        text = "Adventure | Drama | Family | Mystery",
        font = FONT_NAME.." 20px",
        y = 440-105,
        x = button_group.x,
    }
    local director = Text{
        color = "white",
        text = "Director",
        font = FONT_NAME.." Bold 20px",
        y = genre.y+genre.h+20,
        x = genre.x,
    }
    local director_name = Text{
        color = grey_color,
        text = "Martin Scorsese",
        font = FONT_NAME.." 20px",
        y = director.y+director.h,
        x = director.x,
    }
    local writers = Text{
        color = "white",
        text = "Writers",
        font = FONT_NAME.." Bold 20px",
        y = director.y,
        x = director.x+300,
    }
    local writer_names = Text{
        color = grey_color,
        text  = "John Logan (screen play)\nBrian Selznick (book)",
        font  = FONT_NAME.." 20px",
        y = director_name.y,
        x = writers.x,
    }
    local stars = Text{
        color = "white",
        text = "Stars",
        font = FONT_NAME.." Bold 20px",
        y = writers.y,
        x = writers.x+300,
    }
    local star_names = Text{
        color = grey_color,
        text  = "Asa Butterfield\nChloe Grace Moretz\nChristopher Lee",
        font  = FONT_NAME.." 20px",
        y = director_name.y,
        x = stars.x,
    }
    local i = 1
    for i,v in ipairs(buttons) do
        local w = 210
        local h = 148/2--channel_bar.h/2
        local focused = Sprite{sheet=ui_sprites,w=w,h=h,id = "channelbar/channel-bar-focus.png"}
        local unfocused = Sprite{sheet=ui_sprites,w=w,h=h,id = "channelbar/channel-bar.png"}
        local line1  = Text{
            color = "white",
            text = v[1],
            font = "Lato Bold 20px",
            alignment = "CENTER",
        }
        line1.anchor_point = {line1.w/2,line1.h}
        local line2  = Text{
            color = "white",
            text = v[2],
            font = FONT_NAME.." 20px",
            alignment = "CENTER",
        }
        line2.anchor_point = {line2.w/2,0}
        line1.position = {w/2,h/2}
        line2.position = {w/2,h/2}
        buttons[i]   = Group{
            name     = v[1].." "..v[2],
            x        = w*(i-1),
            children = {
                unfocused,
                focused,
                Rectangle {
                    name = "edge",
                    color = "#2d414e",
                    size = { 2, h }
                },
                Rectangle {
                    name = "edge",
                    color = "#2d414e",
                    size = { 2, h },
                    x=w
                },
                line2,line1
            }
        }
        buttons[i].anim = AnimationState{
            duration = 250,
            mode = "EASE_OUT_SINE",
            transitions = {
                {
                    source = "*",
                    target = "focus",
                    keys = {
                        { focused, "opacity", 255 },
                    },
                },
                {
                    source = "*",
                    target = "unfocus",
                    keys = {
                        { focused, "opacity", 0 },
                    },
                },
            },
        }
        buttons[i].anim:warp("unfocus")
    end
    button_group:add(unpack(buttons))
    right_side:add(button_group,genre,director,director_name,writers,writer_names,stars,star_names)
    ppv_menu:add(right_side,poster)
    buttons[i].anim.state = "focus"
    function ppv_menu.press_left(self)
        if i == 1 then return self:press_down() end
        buttons[i].anim.state = "unfocus"
        i = i - 1
        buttons[i].anim.state = "focus"
        return true
    end
    function ppv_menu.press_right(self)
        if i == #buttons then return true end
        buttons[i].anim.state = "unfocus"
        i = i + 1
        buttons[i].anim.state = "focus"
        return true
    end
    function ppv_menu.press_down(self)
        self:fade_out()
        self.prev:fade_in(function()
            self:unparent()
            curr_menu = self.prev
        end)
        return true
    end
    ppv_menu.press_back = ppv_menu.press_down
    function ppv_menu:fade_out(f)
        button_group:animate{
            duration = 100,
            opacity  = 0,
            on_completed = f,
        }
    end
    function ppv_menu:fade_in(f)
        button_group:animate{
            duration = 100,
            opacity  = 255,
            on_completed = f,
        }
    end
    function ppv_menu:populate(show_data)
        -----------------------------------------------------------
        director_name.text = ""
        for i,director in ipairs(show_data.directors) do
            if i > 3 then break end
            director_name.text = director_name.text..
                director.."\n"
        end
        -----------------------------------------------------------
        writer_names.text = ""
        for i,writer in ipairs(show_data.writers) do
            if i > 3 then break end
            writer_names.text = writer_names.text..
                writer.."\n"
        end
        -----------------------------------------------------------
        star_names.text = ""
        for i,actor in ipairs(show_data.actors) do
            if i > 3 then break end
            star_names.text = star_names.text..
                actor.."\n"
        end
        -----------------------------------------------------------
        --star_names
    end
    ppv_menu.poster = poster
end
local function show_movie_details(sub_menu)
    ppv_menu.prev = sub_menu
    ppv_menu:fade_in()
    sub_menu:fade_out()
    ppv_menu:populate(curr_menu:curr().data)
    backing:add_over_contents(ppv_menu)
    curr_menu = ppv_menu
    ppv_menu.poster.source = sub_menu:curr()
end

local menubar
menubar       = make_sliding_bar__highlighted_focus{
    make_item = make_category,
    items     = {
        {
            label    = "TV Catch Up",
            logo     = "VOD_icons/icon-catchup-tv.png",
            logo_f   = "VOD_icons/icon-catchup-tv-focus.png",
            sub_menu = make_sliding_bar__expanded_focus{
                items        = t_tv_catchup,
                make_item    = make_poster,
                unsel_offset = movie_w*2/2-30,
                spacing      = 10+movie_w,
                press_down   = function(self)
                    --self:unparent()
                    curr_menu = menubar
                    backing.anim.state = "hidden"
                    self:anim_out(function() self:unparent() end)
                    return true
                end,
                press_ok = function(self)
                    show_movie_details(self)
                    return true
                end,
                press_left = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "right"
                    )
                end,
            },
        },
        {
            label    = "Movies",
            logo     = "VOD_icons/icon-movies.png",
            logo_f   = "VOD_icons/icon-movies-focus.png",
            sub_menu = make_sliding_bar__expanded_focus{
                items        = t_movies,
                make_item    = make_poster,
                unsel_offset = movie_w*2/2-30,
                spacing      = 10+movie_w,
                press_down   = function(self)
                    --self:unparent()
                    curr_menu = menubar
                    backing.anim.state = "hidden"
                    self:anim_out(function() self:unparent() end)
                    return true
                end,
                press_ok = function(self)
                    show_movie_details(self)
                    return true
                end,
                press_left = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "right"
                    )
                end,
            },
        },
        {
            label    = "New Releases",
            logo     = "VOD_icons/icon-new-releases.png",
            logo_f   = "VOD_icons/icon-new-releases-focus.png",
            sub_menu = make_sliding_bar__expanded_focus{
                items        = t_new_releases,
                make_item    = make_poster,
                unsel_offset = movie_w*2/2-30,
                spacing      = 10+movie_w,
                press_down   = function(self)
                    --self:unparent()
                    curr_menu = menubar
                    backing.anim.state = "hidden"
                    self:anim_out(function() self:unparent() end)
                    return true
                end,
                press_ok = function(self)
                    show_movie_details(self)
                    return true
                end,
                press_left = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "right"
                    )
                end,
            },
        },
        {
            label    = "Top Picks",
            logo     = "VOD_icons/icon-top-picks.png",
            logo_f   = "VOD_icons/icon-top-picks-focus.png",
            sub_menu = make_sliding_bar__expanded_focus{
                items        = t_top_picks,
                make_item    = make_poster,
                unsel_offset = movie_w*2/2-30,
                spacing      = 10+movie_w,
                press_down   = function(self)
                    --self:unparent()
                    curr_menu = menubar
                    backing.anim.state = "hidden"
                    self:anim_out(function() self:unparent() end)
                    return true
                end,
                press_ok = function(self)
                    show_movie_details(self)
                    return true
                end,
                press_left = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "right"
                    )
                end,
            },
        },
        {
            label    = "Recommended",
            logo     = "VOD_icons/icon-recommended.png",
            logo_f   = "VOD_icons/icon-recommended-focus.png",
            sub_menu = make_sliding_bar__expanded_focus{
                items        = t_recommended,
                make_item    = make_poster,
                unsel_offset = movie_w*2/2-30,
                spacing      = 10+movie_w,
                press_down   = function(self)
                    --self:unparent()
                    curr_menu = menubar
                    backing.anim.state = "hidden"
                    self:anim_out(function() self:unparent() end)
                    return true
                end,
                press_ok = function(self)
                    show_movie_details(self)
                    return true
                end,
                press_left = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    backing:set_incoming(
                        self:curr(),
                        "right"
                    )
                end,
            },
        },
    },
    press_up = function(self)
        --print(self,curr_menu)
        local sub_menu = self:curr().sub_menu
        VOD_G:add(sub_menu)
        sub_menu:lower_to_bottom()
        --self:curr().sub_menu:hide()
        sub_menu.x = -200
        sub_menu.y = 105
        sub_menu:anim_in()
        curr_menu = sub_menu
        backing.anim.state = "full"
        return true
    end,
    press_ok = function(self)
        self:press_up()
    end,
}
curr_menu = menubar

local function show_bar()
    menubar:anim_in()
    VOD_G:add(menubar)
end

local function hide_bar()

    dolater(150,menubar.anim_out)
    if curr_menu == ppv_menu then
        ppv_menu.prev:anim_out(function()
            ppv_menu:unparent()
            ppv_menu.prev.opacity = 255
        end)
        --ppv_menu:fade_out()
    elseif curr_menu ~= menubar then
        curr_menu:anim_out()
    end
    curr_menu = menubar
    backing.anim.state = "hidden"
end



local function on_activate(label)
    label:stop_animation()
    label:animate({ duration = 250, opacity = 255 })
    if(menubar.count == 0) then build_bar() end
    if menubar.parent == nil then
        --screen:add(menubar)
        --sub_menu:hide()
        --menubar:hide()
        menubar.y = 925 - 150
        --sub_menu.y = 400
        backing.y = 105--menubar.y
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
end

local function on_wake(label)
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
    [keys.BACK] = function()
        return curr_menu.press_back    and curr_menu:press_back()--true
    end,
}

local function on_key_down(label, key)
    return key_events[key] and key_events[key]()
end
return {
            label = "On Demand",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
