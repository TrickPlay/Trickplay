Components = {
    COMPONENTS_FIRST = 1,
    GAME = 1,
    MENU = 2,
    COMPONENTS_LAST = 2
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
timer.interval = 6000
timer.on_timer = function(timer)
    timer:stop()
    timer.on_timer = nil

    start_button_focus:animate{duration = 2000, opacity = 255,
    on_completed = function()

        -- Router initialization
        router = Router()
        dofile("EventHandling.lua")


        GridPositions = {}
        for i = 1,GRID_WIDTH do
            GridPositions[i] = {}
            for j = 1,GRID_HEIGHT do
                GridPositions[i][j] = {}
                for k = 1,GRID_DEPTH do
                    GridPositions[i][j][k] = {47*(i-1) - (k-1)*16, 59*(j-1) - (k-1)*20}
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
        local menu = MenuView(router)
        menu:initialize()

        splash:unparent()

        router:start_app(Components.GAME)
    end}
end

timer:start()

screen.on_key_down = function()
    screen.on_key_down = nil
    timer:on_timer(timer)
end
