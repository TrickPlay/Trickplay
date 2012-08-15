local movies =
{
	{
		name = "Cars 2",
		poster=	"cars-2.jpg",
	},
	{
		name = "Scream 4",
		poster=	"scream-4.jpg",
	},
	{
		name = "Chipmunks Chipwrecked",
		poster=	"chipmunks-chipwrecked.jpg",
	},
	{
		name = "Hoodwinked 2",
		poster=	"hoodwinked.jpg",
	},
	{
		name = "Spy Kids 4D",
		poster=	"spy-kids-4d.jpg",
	},
	{
		name = "Chronicle",
		poster=	"chronicle.jpg",
	},
	{
		name = "Glee The Concert Movie",
		poster=	"glee-concert-movie.jpg",
	},
	{
		name = "Haywire",
		poster=	"haywire.jpg",
	},
	{
		name = "New Year's Eve",
		poster=	"new-years-eve.jpg",
	},
	{
		name = "Source Code",
		poster=	"source-code.jpg",
	},
	{
		name = "The Tree of Life",
		poster=	"tree-of-life.jpg",
	},
	{
		name = "The Ides of March",
		poster=	"ides-of-march.jpg",
	},
	{
		name = "MI: Ghost Protocol",
		poster=	"ghost-protocol.jpg",
	},
	{
		name = "Red Tails",
		poster=	"red-tail.jpg",
	},
	{
		name = "Ronin",
		poster=	"ronin.jpg",
	},
	{
		name = "X-Men: First Class",
		poster=	"x-men.jpg",
	},
	{
		name = "Happy Feet 2",
		poster=	"happy-feet-two.jpg",
	},
	{
		name = "Hugo",
		poster=	"hugo.jpg",
	},
	{
		name = "Battle: Los Angeles",
		poster=	"battle-los-angeles.jpg",
	},
	{
		name = "Beginners",
		poster=	"beginners.jpg",
	},
	{
		name = "A Very Harold & Kumar 3D Christmas",
		poster=	"harold-and-kumar-christmas.jpg",
	},
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


local function make_poster(item)
    local poster = Group {}
    local img = Image { src = "assets/movie_posters/"..item.poster, x = 2, y = 2 }
    local img_scrim = Rectangle { color = "black", opacity = 96, w = img.w + 4, h = img.h + 4 }
    poster:add(img_scrim, img)

    local title_grp = Group { w = img.w, x = -2 }
    local title  = Text { font = FONT_NAME.." 36px", color = "white", text = item.name, x = 3, y = 1, scale = { 1/2.5, 1/2.5 } }
    local title_scrim = Rectangle { color = "black", opacity = 96, w = math.max(img.w, title.w/2.5) + 4, h = (title.h/2.5) + 2 }
    title_grp:add(title_scrim, title)
    title_grp.w = img.w
    title_grp.y = -title_scrim.h
    title_grp.clip_to_size = true

    poster:add(title_grp)

    poster.anchor_point = { poster.w/2, poster.h }
    poster.y_rotation = { 0, poster.w/2, 0 }
    poster.extra.anim = AnimationState {
                                                    duration = 250,
                                                    mode = "EASE_OUT_SINE",
                                                    transitions = {
                                                        {
                                                            source = "*",
                                                            target = "focus",
                                                            keys = {
                                                                { poster, "opacity", 255 },
                                                                { poster, "y_rotation", 0 },
                                                                { title_grp, "opacity", 255 },
                                                                { poster, "scale", { 2.5, 2.5 } },
                                                            },
                                                        },
                                                        {
                                                            source = "*",
                                                            target = "unfocus",
                                                            keys = {
                                                                { poster, "opacity", 64 },
                                                                { poster, "y_rotation", -15 },
                                                                { title_grp, "opacity", 0 },
                                                                { poster, "scale", { 1, 1 } },
                                                            },
                                                        },
                                                    },
    }

    poster.extra.focus = function(self)
        title_grp.clip_to_size = false
        self.anim.state = "focus"
    end

    poster.extra.unfocus = function(self)
        title_grp.clip_to_size = true
        self.anim.state = "unfocus"
    end
    poster.anim:warp("unfocus")

    return poster
end

local menubar = Group {}
local movies_list = {}
local movie_offset = 0
local active_movie = 2

local function focus_movie(number, t)
    menubar:stop_animation()
    local the_movie = movies_list[number]
    the_movie:raise_to_top()
    the_movie:focus()
    local mode = "EASE_IN_OUT_SINE"
    menubar:animate({ duration = t, mode = mode, x = 400 - the_movie.x })
end

local function unfocus_movie(number)
    movies_list[number]:unfocus()
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

    menubar.y = 1150 - movies_group.h

    focus_movie(active_movie,10)
end

local function show_bar()
    menubar:show()
end

local function hide_bar()
    menubar:hide()
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

return {
            label = "On Demand",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
