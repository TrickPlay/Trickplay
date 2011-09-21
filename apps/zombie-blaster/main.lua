Components = {
    COMPONENTS_FIRST = 1,
    GAME = 1,
    GAME_OVER = 2,
    COMPONENTS_LAST = 2
}

Events = {
    KEYBOARD = 1,
    TIMER = 2,
    NOTIFY = 3
}

dofile("DoFiles.lua")

local splash = Group{
    children = {
        Image{src = "assets/start_screen/start-screen-half.jpg", size = {1920, 1080}},
        Image{
            src = "assets/start_screen/btn-start-on.png",
            position = {765, 711}
        }
    }
}
screen:add(splash)
screen:show()

start_game = function()
    screen.on_key_down = nil

    -- Router initialization
    router = Router()
    dofile("EventHandling.lua")

    -- Animation loop initialization
    gameloop = GameLoop()

    -- View/Controller initialization
    game = GameControl(router, Components.GAME)
    splash:unparent()

    router:start_app(Components.GAME)
end

function screen:on_key_down() end
local key_consumer = Timer()
key_consumer.interval = 400
function key_consumer:on_timer()
    key_consumer:stop()
    key_consumer.on_timer = nil
    key_consumer = nil

    screen.on_key_down = function()
        screen.on_key_down = nil
        start_game()
    end
end
key_consumer:start()
