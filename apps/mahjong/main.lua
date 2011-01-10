Components = {
    COMPONENTS_FIRST = 1,
    GAME = 1,
    MENU = 2,
    NO_MOVES_DIALOG = 3,
    NEW_MAP_DIALOG = 4,
    HELP = 5,
    COMPONENTS_LAST = 5
}

Events = {
    KEYBOARD = 1,
    TIMER = 2,
    NOTIFY = 3
}

dofile("DoFiles.lua")

local splash = Image{src = "assets/Mahjong_Splash.jpg"}
local start_button_focus = Image{
    src = "assets/StartGlow.png",
    opacity = 0,
    position = {800,650}
}
screen:add(splash, start_button_focus)
screen:show()

local timer = Timer()
timer.interval = 500
timer.on_timer = function(timer)
    timer:stop()
    screen.on_key_down = nil
    timer.on_timer = nil

    mediaplayer:play_sound("assets/audio/start-sound.mp3")

    start_button_focus:animate{duration = 1000, opacity = 255,
    on_completed = function()

        -- Router initialization
        router = Router()
        dofile("EventHandling.lua")
        disable_event_listeners()


        GridPositions = {}
        for i = 1,GRID_WIDTH do
            GridPositions[i] = {}
            for j = 1,GRID_HEIGHT do
                GridPositions[i][j] = {}
                for k = 1,GRID_DEPTH do
                    GridPositions[i][j][k] = 
                    {
                        47*(i-1) - (k-1)*16 + 460,
                        59*(j-1) - (k-1)*21 + 60
                    }
                end
            end
        end
        GridPositions.TOP = Utils.deepcopy(GridPositions[7][4][4])
        GridPositions.TOP[1] = GridPositions.TOP[1] + 40
        GridPositions.TOP[2] = GridPositions.TOP[2] + 40

        -- Animation loop initialization
        gameloop = GameLoop()

        -- View/Controller initialization
        game = GameControl(router, Components.GAME)
        game_menu = MenuView(router)
        game_menu:initialize()
        local no_moves_dialog = DialogBox("Sorry!\nThere are no\nmore moves.", Components.NO_MOVES_DIALOG, router)
        local new_map_dialog = DialogBox("Start a new game\non this layout?", Components.NEW_MAP_DIALOG, router)

        splash:unparent()
        start_button_focus:unparent()

        router:start_app(Components.GAME)
        --router:start_app(Components.NO_MOVES_DIALOG)
        --router:start_app(Components.NEW_MAP_DIALOG)

        timer.interval = 400
        timer.on_timer = function()
            enable_event_listeners()
            timer:stop()
            timer.on_timer = nil
        end
        timer:start()
    end}
end

timer:start()

screen.on_key_down = function()
    screen.on_key_down = nil
    timer:on_timer(timer)
end
