-- Based on demo video at https://www.dropbox.com/s/g37078405oxlnlm/OOBE%20Screen%205c.mp4

--[[

    This animation is split into phases (which overlap slightly):

    1. "Welcome to" "FREE TV!" zooms out from middle of TV and fades   0.0 through 0.25
    2. Movie posters accordion out from center of screen to the sides, growing and rotating slightly in y-axis  0.15 through 0.4
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
print("bg")

local movie_posters = assert(loadfile("posters.lua"))("assets/movie_posters/")
for i = #movie_posters, 1, -1 do screen:add( movie_posters[i] ) end
print("movies")

local welcome_to, free_tv, welcome_to_free_tv = assert(loadfile("small_text_big_text.lua"))("Welcome to", "FREE TV!")
screen:add(welcome_to_free_tv)
print("freetv")

local hundreds_of, movies, hundreds_of_movies = assert(loadfile("small_text_big_text.lua"))("Hundreds of", "MOVIES")
screen:add(hundreds_of_movies)
print("hundreds")



local tv_posters = assert(loadfile("posters.lua"))("assets/tv_posters/")
for i = #tv_posters, 1, -1 do screen:add( tv_posters[i] ) end
print("tv_poster")

local tv_logos = assert(loadfile("posters.lua"))("assets/tv_logos/")
for i = #tv_logos, 1, -1 do screen:add( tv_logos[i] ) end
print("tv_logo")

local enjoy_your_favorite, tv_shows, enjoy_your_favorite_tv_shows = assert(loadfile("small_text_big_text.lua"))("Enjoy your favorite","TV SHOWS")
screen:add(enjoy_your_favorite_tv_shows)
print("enjoy")



local album_covers = assert(loadfile("posters.lua"))("assets/music_posters/")
for i = #album_covers, 1, -1 do screen:add( album_covers[i] ) end
print("album")

local the_best, music, the_best_music = assert(loadfile("small_text_big_text.lua"))("The Best","MUSIC")
screen:add(the_best_music)
print("best music")



local pb,pb_text,pb_text_bg = dofile("progress_bar.lua")
screen:add(pb)
screen:add(pb_text_bg)
screen:add(pb_text)

-- Now we'll build up the animation in stages, working one object/property at a time
local animator_properties = {}
local ANIMATION_DURATION = 20000

-- NOTE: I'm wrapping all of these in functions so my text editor will let me fold/unfold and jump to the right section easily

-- Welcome to FREE TV
function welcome_to_free_tv_setup()
    table.insert(animator_properties,
                    {
                        source = welcome_to,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0,   "LINEAR", 255 },
                            { 0.70/17,  "LINEAR", 255 },
                            { 1.20/17,  "EASE_IN_SINE", 0 },
                            { 12.83/17, "LINEAR", 0 },
                            { 13.90/17, "EASE_IN_SINE", 255 },
                            { 14.73/17, "EASE_OUT_SINE", 0 },
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
                            { 2.06/17, "EASE_IN_SINE", { 1.0, 1.0 } },       -- Grow until 1/4 through
                            { 12.83/17, "LINEAR", { 1.0, 1.0 } },
                            { 1.0, "EASE_OUT_SINE", { 0.5, 0.5 } },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = free_tv,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0,   "LINEAR", 255 },
                            { 0.70/17,  "LINEAR", 255 },
                            { 2.06/17,  "EASE_IN_SINE", 0 },
                            { 13.50/17, "LINEAR", 0 },
                            { 1.0, "EASE_OUT_SINE", 255 },
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
                            { 2.06/17, "EASE_IN_SINE", { 1.0, 1.0 } },       -- Grow until 1/4 through
                            { 12.83/17, "LINEAR", { 1.0, 1.0 } },
                            { 1.0, "EASE_OUT_SINE", { 0.5, 0.5 } },
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
                                { 0.04, "LINEAR", 0 },
                                { 0.05 + 0.13 * n / #movie_posters, "EASE_OUT_SINE", 255 },
                            },
                        }
                    )

        -- Half of them move to the left, half to the right
        if(n % 2 == 1) then
            table.insert(animator_properties,
                            {
                                source = i,
                                name = "x",
                                ease_in = false,
                                keys = {
                                    { 0.0, "LINEAR", screen.w/2 },
                                    { 0.04 + 0.13 * n / #movie_posters, "LINEAR", screen.w/2 },
                                    { 0.17 + 0.13 * n / #movie_posters, "EASE_OUT_SINE", -2*i.w },
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
                                    { 0.04 + 0.13 * n / #movie_posters, "LINEAR", 10 },
                                    { 0.17 + 0.13 * n / #movie_posters, "EASE_IN_EXPO", 45 },
                                },
                            }
                        )
        else
            table.insert(animator_properties,
                            {
                                source = i,
                                name = "x",
                                ease_in = false,
                                keys = {
                                    { 0.0, "LINEAR", screen.w/2 },
                                    { 0.04 + 0.13 * n / #movie_posters, "LINEAR", screen.w/2 },
                                    { 0.17 + 0.13 * n / #movie_posters, "EASE_OUT_SINE", screen.w + 2*i.w },
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
                                    { 0.04 + 0.13 * n / #movie_posters, "LINEAR", -10 },
                                    { 0.17 + 0.13 * n / #movie_posters, "EASE_IN_EXPO", -45 },
                                },
                            }
                        )
        end
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "scale",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", { 1.0, 1.0 } },
                                { 0.04 + 0.13 * n / #movie_posters, "LINEAR", { 1.0, 1.0 } },
                                { 0.17 + 0.13 * n / #movie_posters, "EASE_OUT_SINE", { 2.0, 2.0 } },
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
                            { 0.17, "LINEAR", 0 },
                            { 0.20, "EASE_IN_SINE", 255 },
                            { 0.235, "EASE_OUT_SINE", 0 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = hundreds_of,
                        name = "scale",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", { 0.5, 0.5 } },
                            { 0.17, "LINEAR", { 0.5, 0.5 } },
                            { 0.235, "EASE_OUT_SINE", { 1.0, 1.0 } },
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
                            { 0.17, "LINEAR", 0 },
                            { 0.20, "EASE_IN_SINE", 255 },
                            { 0.3, "EASE_OUT_SINE", 0 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = movies,
                        name = "scale",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", { 0.5, 0.5 } },
                            { 0.17, "LINEAR", { 0.5, 0.5 } },
                            { 0.3, "EASE_OUT_SINE", { 1.0, 1.0 } },
                        },
                    }
                )
end

function get_target_x_y(i)
    -- Pick an angle to fly out on
    local my_angle = math.random(0,359) - 45
    local target_x, target_y
    if(my_angle < 45) then
        target_x = (1 + math.tan(math.rad(my_angle))) * (screen.w+2*i.w)/2
        target_y = -i.h
    elseif(my_angle < 135) then
        target_x = screen.w+i.w
        target_y = (1 + math.tan(math.rad(my_angle-90))) * (screen.h+2*i.h)/2
    elseif(my_angle < 225) then
        target_x = (1 + math.tan(math.rad(180-my_angle))) * (screen.w+2*i.w)/2
        target_y = screen.h+i.h
    else
        target_x = -i.w
        target_y = (1 + math.tan(math.rad(270-my_angle))) * (screen.h+2*i.h)/2
    end
    return target_x, target_y
end

-- TV show posters
function tv_posters_setup()
    -- First one appears at 3.86/17
    -- First one is fully appeared at 4.13/17
    -- First one vanishes at 5.36/17
    -- Last one appears at 9.13/17
    for n,i in ipairs(tv_posters) do
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "opacity",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", 0 },
                                { ((9.13-3.86) * n/#tv_posters + 3.86)/17, "LINEAR", 0 },
                                { ((9.13-3.86) * n/#tv_posters + 4.13)/17, "EASE_IN_EXPO", 255 },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "scale",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", { 1.0, 1.0 } },
                                { ((9.13-3.86) * n/#tv_posters + 3.86)/17, "LINEAR", { 1.0, 1.0 } },
                                { ((9.13-3.86) * n/#tv_posters + 5.36)/17, "EASE_OUT_SINE", { 1.4, 1.4 } },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "x_rotation",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", 0 },
                                { ((9.13-3.86) * n/#tv_posters + 3.86)/17, "LINEAR", 0 },
                                { ((9.13-3.86) * n/#tv_posters + 5.36)/17, "EASE_OUT_SINE", math.random(-20,20) },
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
                                { ((9.13-3.86) * n/#tv_posters + 3.86)/17, "LINEAR", 0 },
                                { ((9.13-3.86) * n/#tv_posters + 5.36)/17, "EASE_OUT_SINE", math.random(-20,20) },
                            },
                        }
                    )
        -- Pick an angle to fly out on
        local target_x, target_y = get_target_x_y(i)
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "x",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", screen.w/2 },
                                { ((9.13-3.86) * n/#tv_posters + 3.86)/17, "LINEAR", screen.w/2 },
                                { ((9.13-3.86) * n/#tv_posters + 5.36)/17, "EASE_IN_EXPO", target_x },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "y",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", screen.h/2 },
                                { ((9.13-3.86) * n/#tv_posters + 3.86)/17, "LINEAR", screen.h/2 },
                                { ((9.13-3.86) * n/#tv_posters + 5.36)/17, "EASE_IN_EXPO", target_y },
                            },
                        }
                    )
    end
end

-- TV logos
function tv_logos_setup()
    -- First one appears at 8.53/17
    -- First one is fully appeared at 8.56/17
    -- First one vanishes at 9.56/17
    -- Last one appears at 10.23/17
    for n,i in ipairs(tv_logos) do
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "opacity",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", 0 },
                                { ((10.23-8.53) * n/#tv_logos + 8.53)/17, "LINEAR", 0 },
                                { ((10.23-8.53) * n/#tv_logos + 8.56)/17, "EASE_IN_EXPO", 255 },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "scale",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", { 1.0, 1.0 } },
                                { ((10.23-8.53) * n/#tv_logos + 8.53)/17, "LINEAR", { 1.0, 1.0 } },
                                { ((10.23-8.53) * n/#tv_logos + 9.56)/17, "EASE_OUT_SINE", { 1.4, 1.4 } },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "x_rotation",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", 0 },
                                { ((10.23-8.53) * n/#tv_logos + 8.53)/17, "LINEAR", 0 },
                                { ((10.23-8.53) * n/#tv_logos + 9.56)/17, "EASE_OUT_SINE", math.random(-20,20) },
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
                                { ((10.23-8.53) * n/#tv_logos + 8.53)/17, "LINEAR", 0 },
                                { ((10.23-8.53) * n/#tv_logos + 9.56)/17, "EASE_OUT_SINE", math.random(-20,20) },
                            },
                        }
                    )
        -- Pick an angle to fly out on
        local target_x, target_y = get_target_x_y(i)
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "x",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", screen.w/2 },
                                { ((10.23-8.53) * n/#tv_logos + 8.53)/17, "LINEAR", screen.w/2 },
                                { ((10.23-8.53) * n/#tv_logos + 9.56)/17, "EASE_IN_EXPO", target_x },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "y",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", screen.h/2 },
                                { ((10.23-8.53) * n/#tv_logos + 3.86)/17, "LINEAR", screen.h/2 },
                                { ((10.23-8.53) * n/#tv_logos + 9.56)/17, "EASE_IN_EXPO", target_y },
                            },
                        }
                    )
    end
end

-- Enjoy your favorite TV SHOWS
function enjoy_your_favorite_tv_shows_setup()
    -- Fade in at 6.60/17
    -- In by 7.23/17
    -- "Enjoy your favorite" out at 7.76/17
    -- "TV SHOWS" out at 8.63
    table.insert(animator_properties,
                    {
                        source = enjoy_your_favorite,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                            { 6.60/17, "LINEAR", 0 },
                            { 7.23/17, "EASE_OUT_SINE", 255 },
                            { 7.76/17, "EASE_IN_SINE", 0 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = enjoy_your_favorite,
                        name = "scale",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", { 0.5, 0.5 } },
                            { 6.60/17, "LINEAR", { 0.5, 0.5 } },
                            { 7.76/17, "EASE_IN_SINE", { 1.0, 1.0 } },
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
                            { 6.60/17, "LINEAR", 0 },
                            { 7.23/17, "EASE_OUT_SINE", 255 },
                            { 8.63/17, "EASE_IN_SINE", 0 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = tv_shows,
                        name = "scale",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", { 0.5, 0.5 } },
                            { 6.60/17, "LINEAR", { 0.5, 0.5 } },
                            { 8.63/17, "EASE_IN_SINE", { 1.0, 1.0 } },
                        },
                    }
                )
end

-- Album covers
function album_covers_setup()
    -- First one starts at 10.16/17
    -- First one visible by 10.63/17
    -- First one vanished by 12.23
    -- Last one appears at 12.30
    for n,i in ipairs(album_covers) do
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "opacity",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", 0 },
                                { ((12.30-10.16) * n/#album_covers + 10.16)/17, "LINEAR", 0 },
                                { ((12.30-10.16) * n/#album_covers + 10.63)/17, "EASE_IN_EXPO", 255 },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "scale",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", { 1.0, 1.0 } },
                                { ((12.30-10.16) * n/#album_covers + 10.16)/17, "LINEAR", { 1.0, 1.0 } },
                                { ((12.30-10.16) * n/#album_covers + 12.23)/17, "EASE_OUT_SINE", { 1.4, 1.4 } },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "x_rotation",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", 0 },
                                { ((12.30-10.16) * n/#album_covers + 10.16)/17, "LINEAR", 0 },
                                { ((12.30-10.16) * n/#album_covers + 12.23)/17, "EASE_OUT_SINE", math.random(-20,20) },
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
                                { ((12.30-10.16) * n/#album_covers + 10.16)/17, "LINEAR", 0 },
                                { ((12.30-10.16) * n/#album_covers + 12.23)/17, "EASE_OUT_SINE", math.random(-20,20) },
                            },
                        }
                    )
        -- Pick an angle to fly out on
        local target_x, target_y = get_target_x_y(i)
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "x",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", screen.w/2 },
                                { ((12.30-10.16) * n/#album_covers + 10.16)/17, "LINEAR", screen.w/2 },
                                { ((12.30-10.16) * n/#album_covers + 12.23)/17, "EASE_IN_SINE", target_x },
                            },
                        }
                    )
        table.insert(animator_properties,
                        {
                            source = i,
                            name = "y",
                            ease_in = false,
                            keys = {
                                { 0.0, "LINEAR", screen.h/2 },
                                { ((12.30-10.16) * n/#album_covers + 10.16)/17, "LINEAR", screen.h/2 },
                                { ((12.30-10.16) * n/#album_covers + 12.23)/17, "EASE_IN_SINE", target_y },
                            },
                        }
                    )
    end
end

-- The Best MUSIC
function the_best_music_setup()
    -- Fade in at 10.90/17
    -- In by 11.50/17
    -- "The best" out at 12.06/17
    -- "MUSIC" out at 12.70
    table.insert(animator_properties,
                    {
                        source = the_best,
                        name = "opacity",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", 0 },
                            { 10.90/17, "LINEAR", 0 },
                            { 11.50/17, "EASE_OUT_SINE", 255 },
                            { 12.06/17, "EASE_IN_SINE", 0 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = the_best,
                        name = "scale",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", { 0.5, 0.5 } },
                            { 10.90/17, "LINEAR", { 0.5, 0.5 } },
                            { 12.70/17, "EASE_IN_SINE", { 1.0, 1.0 } },
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
                            { 10.90/17, "LINEAR", 0 },
                            { 11.50/17, "EASE_OUT_SINE", 255 },
                            { 12.70/17, "EASE_IN_SINE", 0 },
                        },
                    }
                )
    table.insert(animator_properties,
                    {
                        source = music,
                        name = "scale",
                        ease_in = false,
                        keys = {
                            { 0.0, "LINEAR", { 0.5, 0.5 } },
                            { 10.90/17, "LINEAR", { 0.5, 0.5 } },
                            { 12.70/17, "EASE_IN_SINE", { 1.0, 1.0 } },
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

local t = my_animation.timeline
function t:on_marker_reached(marker, ms)
    -- pb.progress should be updated in on_new_frame, but progressbar is leaking badly, so can't
    pb.progress = ms/ANIMATION_DURATION
    pb_text_bg.markup = "<span weight='600'>"..marker.."</span>"
    pb_text.markup = "<span weight='600'>"..marker.."</span>"
end
t:add_marker("Updating Guide Data...", ANIMATION_DURATION * 1/10)
t:add_marker("Updating Guide Data... ", ANIMATION_DURATION * 2/10)
t:add_marker("Updating Guide Data...  ", ANIMATION_DURATION * 3/10)
t:add_marker("Updating Guide Data...   ", ANIMATION_DURATION * 4/10)
t:add_marker("Calibrating Capacitors...", ANIMATION_DURATION * 5/10)
t:add_marker("Calibrating Capacitors... ", ANIMATION_DURATION * 6/10)
t:add_marker("Calibrating Capacitors...  ", ANIMATION_DURATION * 7/10)
t:add_marker("Going to Warp Speed...", ANIMATION_DURATION * 8/10)
t:add_marker("Going to Warp Speed... ", ANIMATION_DURATION * 9/10)
t:add_marker("Done", ANIMATION_DURATION)
my_animation:start()

screen:show()
