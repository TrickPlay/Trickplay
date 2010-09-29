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

-- Router initialization
local router = Router()
dofile("EventHandling.lua")


GridPositions = {}
for i = 1,15 do
    GridPositions[i] = {}
    for j = 1,8 do
        GridPositions[i][j] = {94*i, 118*j}
    end
end

-- Animation loop initialization
gameloop = GameLoop()

-- View/Controller initialization
game = GameControl(router, Components.GAME)

router:start_app(Components.GAME)
