--Includes
dofile("class.lua")
dofile("ImageLoader.lua")
dofile("BoardView.lua")
dofile("StateMachine.lua")
dofile("Player.lua")
dofile("Board.lua")
dofile("Effect.lua")
dofile("PlayerView.lua")
dofile("Utils.lua")

BarneyConstants = {
    rows = 5,
    cols = 14,
    players = 4,
    board_height = 1080,
    board_width  = 1920,
    effects = {"Nuke", "Health", "Laser", "Acid", "Surge", "Water", "Saw",
               "BigRed", "Shield", "Recycle", "Tele", "Jet", "Null"},
    numberOfHearts = 5,
    numberOfEffects = 12,
    clockLength = 5
}

function start_game()
    paused = false
    if(boadView) then
        boardView:clear()
    end
    screen:clear()
    Images = ImageLoader()
    boardView = BoardView()
    --transfer scores to next game
    if(board) then
        local scores = board.scores
        board = Board()
        board.scores = scores
    else
        board = Board()
    end
    stateMachine = StateMachine()
end

function main() 
    start_game()
    stateMachine[states.splash]()
end

main()
