local posterize = loadfile("posters.lua")
local textize = loadfile("small_text_big_text.lua")

local all_posters_list = {}
movie_posters = posterize("assets/movie_posters/", all_posters_list)
welcome_to, free_tv, welcome_to_free_tv = textize("Welcome to", "FREE TV!")
hundreds_of, movies, hundreds_of_movies = textize("Hundreds of", "MOVIES")
enjoy_your_favorite, tv_shows, enjoy_your_favorite_tv_shows = textize("Enjoy your favorite","TV SHOWS")
the_best, music, the_best_music = textize("The Best","MUSIC")
tv_posters = posterize("assets/tv_posters/", all_posters_list)
tv_logos = posterize("assets/tv_logos/", all_posters_list)
album_covers = posterize("assets/music_posters/", all_posters_list)

local load_next_image = nil
local my_image = nil
local function load_next_image()
    if(my_image) then
        local nine_slice = NineSlice{
            x = screen.w/2,
            y = screen.h/2,
            w = my_image.w + 1 + 1,
            h = my_image.h + 1 + 1,
            cells = {
                default = {
                    {
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    },
                    {
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                        my_image,
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    },
                    {
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                        Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    },
                },
            }
        }
        nine_slice.anchor_point = { nine_slice.w/2, nine_slice.h/2 }

        -- Insert the completed nine-slice into the list of nine-slices
        table.insert(all_posters_list[1].dest, nine_slice)

        -- Remove it from the queue
        table.remove(all_posters_list, 1)
    end

    local next_image = all_posters_list[1]
    if(next_image) then
        my_image = Widget_Image { src = next_image.file, async = true }
        my_image.on_size_changed = function() load_next_image() end
    else
        print("Pre-load completed")
    end
end

-- Now start loading the images
load_next_image()

function unload_configuration()
    unload_configuration = nil
    movie_posters = nil
    welcome_to, free_tv, welcome_to_free_tv = nil, nil, nil
    hundreds_of, movies, hundreds_of_movies = nil, nil, nil
    enjoy_your_favorite, tv_shows, enjoy_your_favorite_tv_shows = nil, nil, nil
    the_best, music, the_best_music = nil, nil, nil
    tv_posters = nil
    tv_logos = nil
    album_covers = nil
    collectgarbage()
end
