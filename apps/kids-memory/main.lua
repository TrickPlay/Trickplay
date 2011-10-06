
local function main()

--Kid's Memory Game
--
-- main.lua - this file merely sets up a few globals, loads the files
-- and handles delegation of key presses


--display the screen
screen.perspective = {1,1,screen.perspective[3],100}

---------------------
---- Globals
--------------------

--reduce number of calls to get_w() and get_h()
screen_w = screen.w
screen_h = screen.h

math.randomseed(os.time())

--wrapper function for play_sound() to allow quick muting
play_sound_wrapper = function(sound)
    mediaplayer:play_sound(sound)
end

audio = {
    opening_song = "audio/Opening song.mp3",
    move_focus  = "audio/Effects/arrow press.mp3",
    blank_space = "audio/Effects/blank space.mp3",
    button      = "audio/Effects/button.mp3",
    card_flip   = "audio/Effects/card flip.mp3",
    match = {
        "audio/Events/match_yes/Ahhh - great Job.mp3",
        "audio/Events/match_yes/Keys - its a match.mp3",
        "audio/Events/match_yes/Snare - Perfect Match!.mp3",
    },
    no_match = {
        "audio/Events/match_no/Boing-Uh Oh!.mp3",
        "audio/Events/match_no/Honk - try again!.mp3",
    },
    win = {
        "audio/Events/win_game/Wooh - You're a winner.mp3",
        "audio/Events/win_game/Yay - Yippe you won!.mp3",
    },
    
    butterfly = "audio/Animals/butterfly.mp3",
    cat       = "audio/Animals/cat.mp3",
    chipmunk  = "audio/Animals/chipmunk.mp3",
    cow       = "audio/Animals/cow.mp3",
    duck      = "audio/Animals/duck.mp3",
    frog      = "audio/Animals/frog.mp3",
    ladybug   = "audio/Animals/ladybug.mp3",
    monkey    = "audio/Animals/monkey.mp3",
    mouse     = "audio/Animals/mouse.mp3",
    pig       = "audio/Animals/pig.mp3",
    toucan    = "audio/Animals/toucan.mp3",
    turtle    = "audio/Animals/turtle.mp3",
}

--holds important game information
game_state={in_game=false,board={}}


--index variable for key handlers
local curr_handler = nil
local key_handlers = {}
local fade_out_f   = {}
local fade_in_f    = {}
--wrapper function for assignment of a new key handler
give_keys = function(new_handler)
    assert(
        key_handlers[new_handler] ~= nil,
        "Invalid handler assignment, "..new_handler.." is not a key handler"
    )
    if mediaplayer.state == mediaplayer.PLAYING then
        mediaplayer:pause()
    end
    fade_out_f[curr_handler]()
    curr_handler = new_handler
    fade_in_f[curr_handler]()
end


---------------------------
---- Other Files
---------------------------

--my framework for animations within an app
dofile("App_Loop.lua")
--that file that defines "Class" in lua
dofile("Class.lua")
--file containing the various objects used
dofile("Objects.lua")
--file for managing the tiles faces
dofile("Tiles.lua")
--file for managing the splash screen
dofile("Splash_Screen.lua")
--file for managing the game screen
dofile("Game_Screen.lua")


splash_screen:raise_to_top()
---------------------------
---- Game Loop
---------------------------

idle.on_idle = idle_loop


---------------------------
---- Key Handler
---------------------------

--all valid key handlers
key_handlers["SPLASH"] = splash_on_key_down
key_handlers["GAME"]   = game_on_key_down

fade_out_f["SPLASH"] = splash_fade_out
fade_out_f["GAME"]   = game_fade_out

fade_in_f["SPLASH"] = splash_fade_in
fade_in_f["GAME"]   = game_fade_in
--delegate the key presses
function screen:on_key_down(key)
    assert(
        key_handlers[curr_handler] ~= nil,
        "Invalid handler call, "..curr_handler.." is not a key handler."
    )
    
    key_handlers[curr_handler](key)
end



-- if there is a save file load it
if settings.board ~= nil and #settings.board ~= 0 then
    
    print("Loading from save file")
    
    game_state.difficulty = settings.difficulty
    game_state.in_game    = true
    
    curr_handler = "GAME"
    game_fade_in(settings.board)
    splash_screen.opacity=0
    
-- otherwise just load splash screen
else
    print("No save file to load from")
    
    curr_handler = "SPLASH"
    --splash_fade_in()
    
end

---------------------------
---- Save the game
---------------------------

app.on_closing = function()
    
    --only save if you are in the middle of a game
    if game_state.in_game then
        print("Saving the game,",game_state.tot,"tiles remaining")
        -- build a temp table to save the tiles
        local board = {}
        for i = 1, #game_state.board do
            board[i] = {}
            for j = 1, #game_state.board[i] do
                -- 0 indicates that  spot is empty
                if game_state.board[i][j]==0 then
                    board[i][j] = 0
                else
                    board[i][j] = game_state.board[i][j].index
                end
            end
        end
        
        -- assigin it to the save file
        settings.board = board
        settings.difficulty = game_state.difficulty
    else
        --need to clear out the old game
        settings.board = nil
    end
    
    --reset the perspective
    screen.perspective = {60,1,screen.perspective[3],100}
end
function mediaplayer:on_loaded()
    if not game_state.in_game then
        mediaplayer:play()
    end
end
mediaplayer:load(audio.opening_song)

end

-------------------------------------------------------------------------------

Assets = dofile( "Assets" )

do

    local r = Rectangle
    {
        color = "00000099",
        size = { 0 , 20 },
        x = 10,
        y = screen.h - 26
    }
    local b = Image{ src = "splash.jpg" }
    b.scale = { screen.w / b.w , screen.h / b.h }
    screen:add( b , r )
    screen:show()
    
    local function progress( percent , src , failed )
        r.w = ( screen.w - 20 ) * percent
    end
    
    local function finished()
        screen:remove( r , b )
        r = nil
        b = nil
        main()
    end
    
    Assets:queue_app_contents()
    
    Assets:load( progress , finished )
end