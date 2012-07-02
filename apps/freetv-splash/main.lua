-- Based on demo video at https://www.dropbox.com/s/g37078405oxlnlm/OOBE%20Screen%205c.mp4

--[[

    This animation is split into phases (which overlap slightly):

    1. "Welcome to" "FREE TV!" zooms out from middle of TV and fades
    2. Movie posters accordion out from center of screen to the sides, growing and rotating slightly in y-axis
    3. "Hundreds of" "MOVIES" zooms out from middle of TV and fades
    4. TV show posters fly out from center of screen to all edges, growing as they go
    5. "Enjoy your favorite" "TV SHOWS" zooms out from middle of TV and fades
    6. "The Best" "MUSIC" zooms out from middle of TV and fades
    7. Album covers fly out from middle of TV, rotated at jaunty angles in x & y axes
    8. "Welcome to" "FREE TV!" zooms back in to middle of screen

]]--

dofile("widget_helper.lua")

local background = Image { src = "assets/background/bg-1.jpg" }
screen:add(background)

local movie_posters = assert(loadfile("posters.lua"))("assets/movie_posters/")
screen:add(unpack(movie_posters))

local welcome_to, free_tv, welcome_to_free_tv = assert(loadfile("small_text_big_text.lua"))("Welcome to", "FREE TV!")
screen:add(welcome_to_free_tv)

local hundreds_of, movies, hundreds_of_movies = assert(loadfile("small_text_big_text.lua"))("Hundreds of", "MOVIES")
screen:add(hundreds_of_movies)



local tv_posters = assert(loadfile("posters.lua"))("assets/tv_posters/")
screen:add(unpack(tv_posters))

local tv_logos = assert(loadfile("posters.lua"))("assets/tv_logos/")
screen:add(unpack(tv_logos))

local enjoy_your_favorite, tv_shows, enjoy_your_favorite_tv_shows = assert(loadfile("small_text_big_text.lua"))("Enjoy your favorite","TV SHOWS")
screen:add(enjoy_your_favorite_tv_shows)



local album_covers = assert(loadfile("posters.lua"))("assets/music_posters/")
screen:add(unpack(album_covers))

local the_best, music, the_best_music = assert(loadfile("small_text_big_text.lua"))("The Best","MUSIC")
screen:add(the_best_music)



local pb,pb_text,pb_text_bg = dofile("progress_bar.lua")
screen:add(pb)
screen:add(pb_text_bg)
screen:add(pb_text)

-- Now we'll build up the animation in stages, working one object/property at a time
local animator_properties = {}
local ANIMATION_DURATION = 20000


-- NOTE: I'm wrapping all of these in functions so my text editor will let me fold/unfold and jump to the right section easily

-- Welcome to FREE TV text bit
function welcome_to_free_tv_setup()
table.insert(animator_properties,
                {
                    source = free_tv,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0,   "LINEAR", 0 },                 -- Start transparent
                        { 0.025, "LINEAR", 255 },               -- Fade in over first 0.5s
                        { 0.15,  "LINEAR", 255 },               -- Fade in over first 0.5s
                        { 0.25,  "EASE_OUT_SINE", 0 },                 -- Fade out by 1/4 through
                    },
                }
            )
table.insert(animator_properties,
                {
                    source = welcome_to,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0,   "LINEAR", 0 },                 -- Start transparent
                        { 0.025, "LINEAR", 255 },               -- Fade in over first 0.5s
                        { 0.1,   "LINEAR", 255 },               -- Fade in over first 0.5s
                        { 0.15,  "EASE_OUT_SINE", 0 },                 -- Fade out by 15% through
                    },
                }
            )
table.insert(animator_properties,
                {
                    source = free_tv,
                    name = "scale",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", { 0.5, 0.5 } },        -- Start small
                        { 0.25, "EASE_OUT_SINE", { 2.0, 2.0 } },       -- Grow until 1/4 through
                    },
                }
            )
table.insert(animator_properties,
                {
                    source = welcome_to,
                    name = "scale",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", { 0.5, 0.5 } },        -- Start small
                        { 0.25, "EASE_OUT_SINE", { 2.0, 2.0 } },       -- Grow until 1/4 through
                    },
                }
            )
end

-- Movie posters
function movie_posters_setup()
for n,i in ipairs(movie_posters) do
    table.insert(animator_properties,
                    {
                        source = i,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                            { 0.15, "LINEAR", 0 },
                            { 0.2, "EASE_OUT_EXP", 255 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = i,
                        name = "x",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", screen.w/2 },
                            { 0.15, "LINEAR", screen.w/2 },
                            { 0.35, "EASE_IN_EXP", -i.w+i.w*n/2 },
                            { 0.4, "EASE_OUT_SINE", -i.w+i.w*n/2 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = i,
                        name = "y_rotation",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                            { 0.15, "LINEAR", 45 },
                            { 0.35, "EASE_OUT_SINE", 0 },
                            { 0.4, "EASE_OUT_SINE", 0 },
                        },
                    }
                )
end
end

-- Hundreds of MOVIES text
function hundreds_of_movies_setup()
table.insert(animator_properties,
                {
                    source = hundreds_of,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", 0 },
                    },
                }
            )
table.insert(animator_properties,
                {
                    source = movies,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", 0 },
                    },
                }
            )
end

-- TV show posters
function tv_posters_setup()
for _,i in ipairs(tv_posters) do
    table.insert(animator_properties,
                    {
                        source = i,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                        },
                    }
                )
end
end

-- TV logos
function tv_logos_setup()
for _,i in ipairs(tv_logos) do
    table.insert(animator_properties,
                    {
                        source = i,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                        },
                    }
                )
end
end

-- Enjoy your favorite TV SHOWS
function enjoy_your_favorite_tv_shows_setup()
table.insert(animator_properties,
                {
                    source = enjoy_your_favorite,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", 0 },
                    },
                }
            )
table.insert(animator_properties,
                {
                    source = tv_shows,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", 0 },
                    },
                }
            )
end

-- Album covers
function album_covers_setup()
for _,i in ipairs(album_covers) do
    table.insert(animator_properties,
                    {
                        source = i,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                        },
                    }
                )
end
end

-- The Best MUSIC
function the_best_music_setup()
table.insert(animator_properties,
                {
                    source = the_best,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", 0 },
                    },
                }
            )
table.insert(animator_properties,
                {
                    source = music,
                    name = "opacity",
                    ease_in = false,
                    keys = {
                        { 0.0, "LINEAR", 0 },
                    },
                }
            )
end


-- Call all the animator setup functions
welcome_to_free_tv_setup()
movie_posters_setup()
hundreds_of_movies_setup()
tv_posters_setup()
tv_logos_setup()
enjoy_your_favorite_tv_shows_setup()
album_covers_setup()
the_best_music_setup()

local my_animation = Animator {
                        duration = ANIMATION_DURATION,
                        properties = animator_properties,
                    }



my_animation:start()

screen:show()
