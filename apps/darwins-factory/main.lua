BarneyConstants = {
    rows = 5,
    cols = 14,
    players = 4,
    board_height = 1080,
    board_width  = 1920,
    effects = {"BigRed", "Recycle", "Shield", "Saw", "Tele", "Jet",
               "Water", "Laser", "Surge", "Health", "Acid", "Null"},
    numberOfHearts = 5,
    numberOfEffects = 12,
    clockLength = 1,
    intervals = 5
}

--Includes
dofile("utils/Utils.lua")
dofile("view/View.lua")
dofile("utils/move.lua")
dofile("Audio.lua")


dofile("StateMachine.lua")
dofile("Player.lua")
dofile("Board.lua")
dofile("Effect.lua")
dofile("view/HandView.lua")


function start_game()
    movedFlag = 0
    paused = false
    if(boardView) then
        boardView:clear()
    end
    screen:clear()
    Images = ImageLoader()
    boardView = BoardView()
    menuView = MenuView()
    --transfer scores to next game
    if(board) then
        local scores = board.scores
        board = Board()
        board.scores = scores
    else
        board = Board()
    end
    stateMachine = StateMachine()
    stateMachine[states.current]()
end

function main() 
    start_game()
end

main()
