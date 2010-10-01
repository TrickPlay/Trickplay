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
router = Router()
dofile("EventHandling.lua")


GridPositions = {}
for i = 1,30 do
    GridPositions[i] = {}
    for j = 1,16 do
        GridPositions[i][j] = {}
        for k = 1,5 do
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

router:start_app(Components.GAME)
