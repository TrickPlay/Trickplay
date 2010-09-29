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
        GridPositions[i][j] = {}
        for k = 1,4 do
            GridPositions[i][j][k] = {94*(i-1) - (k-1)*16, 118*(j-1) - (k-1)*20}
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

router:start_app(Components.GAME)
