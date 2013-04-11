
local movie_w = 180
    local grey_color = "a0a9b0"
local curr_menu
local function pre_x(i)
    return (10+movie_w)*(i-1)-movie_w*2/2+30
end
local function sel_x(i)
    return (10+movie_w)*(i-1)--icon_w*.25
end
local function post_x(i)
    return (10+movie_w)*(i-1)+movie_w*2/2-30
end

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
                                                                { r, "y", hidden_y - 820 },
                                                                { r, "h",            820 },
                                                            },
                                                        },
                                                    },
    }---[[
    function backing.extra.anim.timeline.on_started()
        if backing.extra.anim.state ~= "full" then
            print("shit")
            --set_incoming_show(empty_vod_info,"right")
            hide_current_show()
        end
    end
    function backing.extra.anim.timeline.on_completed()
        if backing.extra.anim.state == "full" then
            print("happenin")
            set_incoming_show(
                default_vod_info,
                "right"
            )
        end
    end
    --]]
end


do
    local text_w = 800
    local duration = 200
    local max_airings = 5
    local setup_info = function(g)
        g.title = Text{
            y = -620,x=500,
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
        local curr_show
        function g:get_show()
            return curr_show
        end
        function g:set_show(show)
            if show == nil then error("nil show",2) end

            curr_show = show
            g.title.text       = show.title
            g.description.text = show.description
            g.year.text        = show.year
            g.year.x           = g.title.x + g.title.w + 10
            g.rating.text      = show.rating
            g.run_time.text    = show.run_time
            g.run_time.x       = g.rating.x + g.rating.w + 10
            --[[
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
            if show.series_id and series[show.series_id] and #series[show.series_id] > 1 then
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
                            tonumber(curr_show.start_time_t.hour).."\n"
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
    local displaying_show = setup_info( Group{ name= "displaying_show", opacity = 0,
        x = 200 } )
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
                displaying_show:set_show(incoming_show:get_show() or empty_vod_info)
                displaying_show.opacity = 255
                animating = false
            end
        }
    end

    hide_current_show = function()
        displaying_show:animate{
            duration=200,
            opacity=0,
            y=displaying_show.y+800,
            on_completed = function()
                displaying_show.y = displaying_show.y -800
            end
        }
    end
    set_current_show = function(curr_show)
        displaying_show:set_show(curr_show)
    end
    backing:add(displaying_show,incoming_show)

end

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
--[[
local menubar = Group {}
local movies_list = {}
local movie_offset = 0
local active_movie = 2

local function focus_movie(number, t)
    menubar:stop_animation()
    local the_movie = movies_list[number]
    the_movie:raise_to_top()
    the_movie:focus(sel_x(number))
    local mode = "EASE_IN_OUT_SINE"
    menubar:animate({ duration = t, mode = mode, x = 400 - sel_x(number) })
end

local function unfocus_movie(number,direction)
    movies_list[number]:unfocus(direction==1 and pre_x(number) or post_x(number))
end

local function transfer_focus(curr_i,direction,dur)
    local n = #movies_list

    if curr_i == 1 and direction == -1 then
        transition_time = n*50

        for i,movie in ipairs(menubar:find_child("movies").children) do
            movie.x = movie.x - (post_x(1) - pre_x(1))
        end
        menubar.x = menubar.x + (post_x(1) - pre_x(1))

        unfocus_movie(curr_i,1)
    elseif curr_i == n and direction == 1 then
        transition_time = n*50
        for i,movie in ipairs(menubar:find_child("movies").children) do
            movie.x = movie.x + (post_x(1) - pre_x(1))
        end
        menubar.x = menubar.x - (post_x(1) - pre_x(1))

        unfocus_movie(curr_i,-1)
    else
        unfocus_movie(curr_i,direction)
    end
    curr_i = wrap_i(
        curr_i+direction,
        n
    )


    focus_movie( curr_i, dur )
end

local function build_bar()
    screen:add(menubar)
    menubar:hide()

    local clip_group_outter = Group { name = "clip_outter" }
    menubar:add(clip_group_outter)
    local clip_group = Group { name = "clip_inner" }
    clip_group_outter:add(clip_group)

    local movies_group = Group { name = "movies" }
    clip_group:add(movies_group)

    for k,v in pairs(movies) do
        local new_movie = make_poster(v)
        new_movie.x = movie_offset
        movie_offset = movie_offset + new_movie.w
        movies_group:add(new_movie)
        movies_list[#movies_list+1] = new_movie
    end
    for i,v in ipairs(movies_list) do
        v.x = (
            i == active_movie and sel_x or
            i <  active_movie and pre_x or
            i >  active_movie and post_x)(i)
    end

    menubar.y = 1150 - movies_group.h

    focus_movie(active_movie,10)
end
--]]
---[[
local sub_menu = make_sliding_bar__expanded_focus{
    items = movies,
    make_item = make_poster,
    unsel_offset = movie_w*2/2-30,
    spacing = 10+movie_w,
}
--]]

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
                    set_incoming_show(
                        default_vod_info,--self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    set_incoming_show(
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
                    set_incoming_show(
                        default_vod_info,--self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    set_incoming_show(
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
                    set_incoming_show(
                        default_vod_info,--self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    set_incoming_show(
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
                    set_incoming_show(
                        default_vod_info,--self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    set_incoming_show(
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
                    set_incoming_show(
                        default_vod_info,--self:curr(),
                        "left"
                    )
                end,
                press_right = function( self )
                    set_incoming_show(
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
        backing.y = menubar.y
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

local prev_movie
local key_events = {
    [keys.Left] = function()--[=[]]
        --unfocus_app(active_movie)
        prev_movie = active_movie
        local transition_time = 250
        active_movie = wrap_i(active_movie-1,menubar:find_child("movies").count)--((active_app - 2) % menubar:find_child("apps").count) + 1
        if( active_movie == menubar:find_child("movies").count ) then
            transition_time = menubar:find_child("movies").count*50
        end
        --[[
        if backing.anim.state == "full" then
            set_incoming_text(apps_list[active_movie],"left")
        end
        --]]
        --focus_app(active_movie, transition_time)
        transfer_focus(prev_movie,-1,transition_time)
        --]=]
        return curr_menu.press_left  and curr_menu:press_left()--true
    end,
    [keys.Right] = function()--[=[]]
        --unfocus_app(active_movie)
        prev_movie = active_movie
        local transition_time = 250
        active_movie = wrap_i(active_movie+1,menubar:find_child("movies").count)--(active_app % menubar:find_child("apps").count) + 1
        if( active_movie == 1 ) then
            transition_time = menubar:find_child("movies").count*50
        end
        --[[
        if backing.anim.state == "full" then
            set_incoming_text(apps_list[active_movie],"right")
        end
        --]]
        --focus_app(active_movie, transition_time)
        transfer_focus(prev_movie,1,transition_time)
        --]=]
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
    --[[
    [keys.Up] = function()
        backing.anim.state = "full"
        return true
    end,
    --]]
}

local function on_key_down(label, key)
    return key_events[key] and key_events[key]()
end
--[[
local function on_key_down(label, key)
    if( keys.Left == key or keys.Right == key ) then
        unfocus_movie(active_movie)

        local transition_time = 250
        if(keys.Left == key) then
            active_movie = ((active_movie - 2) % menubar:find_child("movies").count) + 1
            if( active_movie == menubar:find_child("movies").count ) then transition_time = menubar:find_child("movies").count*50 end
        else
            active_movie = (active_movie % menubar:find_child("movies").count) + 1
            if( active_movie == 1 ) then transition_time = menubar:find_child("movies").count*50 end
        end

        focus_movie(active_movie, transition_time)
        return true
    end
end
--]]
return {
            label = "On Demand",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
