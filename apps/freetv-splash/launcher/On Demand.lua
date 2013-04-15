
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
local backing = make_MoreInfoBacking{
    info_x     = 200,
    expanded_h = 670,
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
            font = FONT_NAME.." Bold 28px",
            --text = "Hugo Cabret"
        }
        g.year = Text{
            y = g.title.y+10,
            x = g.title.x + g.title.w + 10,
            --w=text_w,
            --ellipsize = "END",
            color = grey_color,
            font = FONT_NAME.." 16px",
            --text = "(2011)"
        }
        g.description = Text{
            y=g.title.y+80,
            x=g.title.x,
            wrap=true,
            wrap_mode = "WORD",
            w=text_w,
            color = grey_color,
            font = FONT_NAME.." 20px",
            --text = lorem_ipsum,
        }
        g.rating = Text{
            y=g.title.y+g.title.h+10,
            x=g.title.x,
            --w=text_w,
            color = grey_color,
            font = FONT_NAME.." 16px",
            --text = "PG",
        }
        g.run_time = Text{
            y=g.rating.y,
            x=g.rating.x+g.rating.w+10,
            --w=text_w,
            color = grey_color,
            font = FONT_NAME.." 16px",
            --text = "126 min",
        }
        g:add(
            g.title,
            g.description,
            g.year,
            g.rating,
            g.run_time
        )
        return g
    end,
    populate = function(g,show)
            g.title.text       = show.title
            g.description.text = show.description
            g.year.text        = show.year
            g.year.x           = g.title.x + g.title.w + 10
            g.rating.text      = show.rating
            g.run_time.text    = show.run_time
            g.run_time.x       = g.rating.x + g.rating.w + 10
    end,
    empty_info = empty_vod_info,
    get_current = function() return default_vod_info end,
}

local catch_up = {
    {
        name = "Battle: Los Angeles",
        poster= "battle-los-angeles.jpg",
    },
    {
        name = "Beginners",
        poster= "beginners.jpg",
    },
    {
        name = "A Very Harold & Kumar 3D Christmas",
        poster= "harold-and-kumar-christmas.jpg",
    },
}
local new_releases = {
    {
        name = "The Tree of Life",
        poster= "tree-of-life.jpg",
    },
    {
        name = "The Ides of March",
        poster= "ides-of-march.jpg",
    },
    {
        name = "MI: Ghost Protocol",
        poster= "ghost-protocol.jpg",
    },
    {
        name = "Red Tails",
        poster= "red-tail.jpg",
    },
    {
        name = "Ronin",
        poster= "ronin.jpg",
    },
    {
        name = "X-Men: First Class",
        poster= "x-men.jpg",
    },
    {
        name = "Happy Feet 2",
        poster= "happy-feet-two.jpg",
    },
    {
        name = "Hugo",
        poster= "hugo.jpg",
    },
}
local top_picks = {
    {
        name = "Glee The Concert Movie",
        poster= "glee-concert-movie.jpg",
    },
    {
        name = "Haywire",
        poster= "haywire.jpg",
    },
    {
        name = "New Year's Eve",
        poster= "new-years-eve.jpg",
    },
    {
        name = "Source Code",
        poster= "source-code.jpg",
    },
}
local recommended = {
    {
        name = "Cars 2",
        poster= "cars-2.jpg",
    },
    {
        name = "Scream 4",
        poster= "scream-4.jpg",
    },
    {
        name = "Chipmunks Chipwrecked",
        poster= "chipmunks-chipwrecked.jpg",
    },
    {
        name = "Hoodwinked 2",
        poster= "hoodwinked.jpg",
    },
    {
        name = "Spy Kids 4D",
        poster= "spy-kids-4d.jpg",
    },
    {
        name = "Chronicle",
        poster= "chronicle.jpg",
    },
}
local movies =
{
	{
		name = "Harry Potter and the Deathly Hallows - Part 2",
		poster=	"harry-potter-death-hallows.jpg",
	},
	{
		name = "Horrible Bosses",
		poster=	"horrible-bosses.jpg",
	},
	{
		name = "Mr. Popper's Penguins",
		poster=	"mr-poppers-penguins.jpg",
	},
	{
		name = "Puss in Boots",
		poster=	"puss-n-boots.jpg",
	},
	{
		name = "Straw Dogs",
		poster=	"straw-dogs.jpg",
	},
	{
		name = "The Muppets",
		poster=	"the-muppets.jpg",
	},
	{
		name = "The Pool Boys",
		poster=	"the-pool-boys.jpg",
	},
	{
		name = "Water for Elephants",
		poster=	"water-for-elephants.jpg",
	},
	{
		name = "Your Highness",
		poster=	"your-highness.jpg",
	},
	{
		name = "The Green Hornet",
		poster=	"green-hornet.jpg",
	},
	{
		name = "Secretariat",
		poster=	"secretariat.jpg",
	},
	{
		name = "The Vow",
		poster=	"the-vow.jpg",
	},
	{
		name = "The Secret World of Arrietty",
		poster=	"arriettty.jpg",
	},
	{
		name = "The Iron Lady",
		poster=	"iron-lady.jpg",
	},
	{
		name = "One Day",
		poster=	"one-day.jpg",
	},
	{
		name = "One for the Money",
		poster=	"one-for-the-money.jpg",
	},
	{
		name = "The Grey",
		poster=	"the-grey.jpg",
	},
}

local   sel_scale = 2.5
local unsel_scale = 1
local function make_poster(item)
    local grey = "444444"
    local duration = 250
    local mode = "EASE_OUT_SINE"
    local poster  = Group()
    local inner_g = Group()
    local img = Image { src = "assets/movie_posters/"..item.poster, x = 2 }
    local img_scrim = Rectangle { color = grey, w = img.w + 4, h = img.h + 4 }

    local title_grp = Group { w = img.w }
    local title   = Text {
        font      = FONT_NAME.." 38px",
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
            poster:stop_animation()
            poster:animate{
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
            poster:stop_animation()
            poster:animate{
                duration=duration,
                mode = mode,
                x = x,
            }
        end
    end
    poster.anim:warp("unfocus")

    return poster
end
local sub_menu = make_sliding_bar__expanded_focus{
    items = movies,
    make_item = make_poster,
    unsel_offset = movie_w*2/2-30,
    spacing = 10+movie_w,
}

local function make_category(_, data,channel_bar,channel_bar_focus)
    local bar_height = channel_bar.h
    local category = Group { name = data.label }
    local logo = Clone{source=data.logo}
    logo.anchor_point = { 0, logo.h/2 }
    logo.position = { 30, bar_height/2 }
    --local channel_num = Text { color = "grey35", text = ""..channel_num, font = FONT_NAME.." 192px" }
    local label = Text { color = "white", text = data.label, font = FONT_NAME.." 40px" }
    label.anchor_point = { 0, label.h/2 }
    label.position = { logo.x + logo.w - 80, bar_height/2 }
    --channel_num.x = 15
    --channel_num.y = -48

    local bg_focus = Clone {
        source = channel_bar_focus,
        name = "bg-focus",
        x = 1,
        w = label.x + label.w + 30
    }
    local bg_unfocus = Clone {
        source = channel_bar,
        name = "bg-unfocus",
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
        bg_unfocus,
        Rectangle {
            name = "edge",
            color = "#2d414e",
            size = { 1, bar_height },
            x = 1 + label.x + label.w + 30
        },
        --channel_num,
        logo,
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
                    { bg_unfocus, "opacity", 0 },
                    { logo, "opacity", 255 },
                    --{ channel_num, "opacity", 255 },
                    { label, "opacity", 255 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { bg_focus, "opacity", 0 },
                    { bg_unfocus, "opacity", 255 },
                    { logo, "opacity", 64 },
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
local clone_src = Group { name = "Clone sources" }
screen:add(clone_src)
clone_src:hide()
local catchup_tv_icon   = Image { src = "assets/VOD_icons/icon-catchup-tv.png"   }
local movies_icon       = Image { src = "assets/VOD_icons/icon-movies.png"       }
local new_releases_icon = Image { src = "assets/VOD_icons/icon-new-releases.png" }
local recommended_icon  = Image { src = "assets/VOD_icons/icon-recommended.png"  }
local top_picks_icon    = Image { src = "assets/VOD_icons/icon-top-picks.png"    }
clone_src:add(
    catchup_tv_icon,
    movies_icon,
    new_releases_icon,
    recommended_icon,
    top_picks_icon
)
local ppv_menu = Group()
do
    local button_group = Group{name="Buttons",x=700,y=550}
    local poster = Clone{y=105,x=200}
    local right_side = Group()
    local buttons = {
        "Free\nPreview",
        "$4.99\nTV (2 day)",
        "$3.99\nNetflix",
        "$4.95\nHulu",
    }
    local genre = Text{
        color = grey_color,
        text = "Adventure | Drama | Family | Mystery",
        font = FONT_NAME.." 20px",
        y = 400,
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
        local focused = Clone{w=w,source = channel_bar_focus}
        local unfocused = Clone{w=w,source = channel_bar}
        local label  = Text{
            color = "white",
            text = v,
            font = FONT_NAME.." 30px",
            alignment = "CENTER",
        }
        label.anchor_point = {label.w/2,label.h/2}
        label.position = {w/2,channel_bar.h/2}
        buttons[i]   = Group{
            name     = v,
            x        = w*(i-1),
            children = {
                unfocused,
                focused,
                Rectangle { name = "edge", color = "#2d414e", size = { 2, channel_bar.h } },
                Rectangle { name = "edge", color = "#2d414e", size = { 2, channel_bar.h },x=w },
                label,
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
                        --{ unfocused, "opacity", 0 },
                    },
                },
                {
                    source = "*",
                    target = "unfocus",
                    keys = {
                        { focused, "opacity", 0 },
                        --{ unfocused, "opacity", 255 },
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
        if i == 1 then return true end
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
    ppv_menu.poster = poster
end
local function show_movie_details(sub_menu)
    ppv_menu.prev = sub_menu
    ppv_menu:fade_in()
    sub_menu:fade_out()
    screen:add(ppv_menu)
    curr_menu = ppv_menu
    ppv_menu.poster.source = sub_menu:curr()
end
local menubar
menubar       = make_sliding_bar__highlighted_focus{
    make_item = make_category,
    items     = {
        {
            label    = "Movies",
            logo     = movies_icon,
            sub_menu = make_sliding_bar__expanded_focus{
                items        = movies,
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
            },
        },
        {
            label    = "TV Catch Up",
            logo     = catchup_tv_icon,
            sub_menu = make_sliding_bar__expanded_focus{
                items        = catch_up,
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
            },
        },
        {
            label    = "New Releases",
            logo     = new_releases_icon,
            sub_menu = make_sliding_bar__expanded_focus{
                items        = new_releases,
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
            },
        },
        {
            label    = "Top Picks",
            logo     = top_picks_icon,
            sub_menu = make_sliding_bar__expanded_focus{
                items        = top_picks,
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
            },
        },
        {
            label    = "Recommened",
            logo     = recommended_icon,
            sub_menu = make_sliding_bar__expanded_focus{
                items        = recommended,
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
            },
        },
    },
    press_up = function(self)
        --print(self,curr_menu)
        screen:add(self:curr().sub_menu)
        --self:curr().sub_menu:hide()
        self:curr().sub_menu.x = -200
        self:curr().sub_menu.y = 105
        self:curr().sub_menu:anim_in()
        curr_menu = self:curr().sub_menu
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
end

local function hide_bar()
    menubar:anim_out()
    backing.anim.state = "hidden"
end



local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    if(menubar.count == 0) then build_bar() end
    if menubar.parent == nil then
        screen:add(backing,menubar)
        --sub_menu:hide()
        menubar:hide()
        menubar.y = 925 - 150
        --sub_menu.y = 400
        backing.y = 105--menubar.y
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
