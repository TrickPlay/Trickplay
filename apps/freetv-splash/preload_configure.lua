local posterize = loadfile("posters.lua")
local textize = loadfile("small_text_big_text.lua")

movie_posters = posterize("assets/movie_posters/")
welcome_to, free_tv, welcome_to_free_tv = textize("Welcome to", "FREE TV!")
hundreds_of, movies, hundreds_of_movies = textize("Hundreds of", "MOVIES")
enjoy_your_favorite, tv_shows, enjoy_your_favorite_tv_shows = textize("Enjoy your favorite","TV SHOWS")
the_best, music, the_best_music = textize("The Best","MUSIC")
tv_posters = posterize("assets/tv_posters/")
tv_logos = posterize("assets/tv_logos/")
album_covers = posterize("assets/music_posters/")

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
