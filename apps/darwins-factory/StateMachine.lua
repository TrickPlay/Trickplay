states = {
    splash = 0,
    init = 1,
    moveBoard = 2,
    populateBoard = 3,
    setTimer = 4,
    stopTimer = 5,
    pickPosition = 6,
    interval = 7,
    setEffects = 8,
    applyEffects = 9,
    checkWinner = 10,
    tally = 11,
    reset = 12,
    menu = 13,
    tutorial = 14
}
states.current = states.splash

function StateMachine()

    local state = {
        [states.splash] = function()
            splashScreen = {"Play Game", "Instructions", "Go Away"}
            splashScreen.marker = 1
            printSplash()
            menuView:showStart()
            screen.on_key_down = function(screen, key)
                if(key == keys.Up) then
                    splashScreen.marker = splashScreen.marker - 1
                    splashScreen.marker = Utils.clamp(1, splashScreen.marker, #splashScreen)
                    printSplash()
                    menuView:selectOption(splashScreen.marker)
                elseif(key == keys.Down) then
                    splashScreen.marker = splashScreen.marker + 1
                    splashScreen.marker = Utils.clamp(1, splashScreen.marker, #splashScreen)
                    printSplash()
                    menuView:selectOption(splashScreen.marker)
                elseif(key == keys.Return) then
                    screen.on_key_down = nil
                    menuView:clear()
                    if(splashScreen.marker == MenuViewConstants.PLAY) then
                        states.current = states.init
                    elseif(splashScreen.marker == MenuViewConstants.DIRECTIONS) then
                        menuView:directions()
                        states.current = states.tutorial
                    else
                        states.current = states.init
                        exit()
                    end
                    splashScreen = nil
                    stateMachine[states.current]()
                end
            end
        end,

        [states.tutorial] = function()
            screen.on_key_down = function(screen, key)
                    print("\n\nreading")
                    if(key == keys.Down) then
                         print("\n\n\n\nDOWNNNNN")
                        menuView.tut:hide()
                        menuView.tut = nil
                        states.current = states.init
                    else
                        states.current = states.tutorial
                    end
                    stateMachine[states.current]()
            end
        end,

        --This state initializes everything
        [states.init] = function()
            print("Initializing Game")
            --initialize text based game
            textScreen = {}
            clearTextScreen()
            --put weapons and power-ups onto the board
            for i = 1, 2 do
                board:enQRow(board:generateRow())
            end
            init = true
            states.current = states.moveBoard
            boardView:showArrow()
            stateMachine[states.current]()
        end,

        
        [states.moveBoard] = function()
            print("STATE: move board")
            --move players down with board
            if(not init) then
                board:movePlayersDown()
            end
            init = nil
            --Update effects plane in view
            local newRow = board:generateRow()
            boardView:updateBoard(board, newRow,
                function ()
                    --enQ the new row, DQ an old one
                    board:enQRow(newRow)
                    if(board:getQSize() > BarneyConstants.rows) then
                        board:DQRow()
                    end
                    moveBoard = true
                    states.current = states.checkWinner
                    stateMachine[states.current]()
                end)
        end,


        [states.populateBoard] = function()
            print("STATE: populate board")
            --Add all information to textBoard
            clearTextScreen()
            local currentRowIndex = board:getFirstRowIndex() - 1
            assert(board:getNextRow(currentRowIndex))
            local currentRow = board:getNextRow(currentRowIndex)
            --put effects on the board
            while(currentRow) do
                currentRowIndex = currentRowIndex + 1
                for i = 1, BarneyConstants.cols do
                    if(currentRow[i].name ~= "null") then
                        textScreen[currentRowIndex-board:getFirstRowIndex()+1][i] = currentRow[i].name
                    end
                end
                currentRow = board:getNextRow(currentRowIndex)
            end
            --set players onto board
            for i = 1, board.numberOfPlayers do
                local node = textScreen[board.players[i].y][board.players[i].x]
                local x = board.players[i].x
                local y = board.players[i].y
                if(node == 0 or node == "0") then
                    textScreen[board.players[i].y][board.players[i].x] = board.players[i].number
                else
                    textScreen[board.players[i].y][board.players[i].x] = node..board.players[i].number
                end
                --set players to boardView
                boardView:movePlayer(board.players[i].number, board.players[i].y,
                    board.players[i].x, board.players[i].marker.y,
                    board.players[i].marker.x, nil)
            end
            textShow()
            if(gameTimer) then
                states.current = states.pickPosition
            else
                states.current = states.setTimer
            end
            --states.current = states.setEffects
            stateMachine[states.current]()
        end,


        [states.setTimer] = function()
            print("STATE: Set Timer")
            --timer and timer counter
            gameTimer = {timer = Timer(), counter = 0}

            gameTimer.timer.interval = BarneyConstants.clockLength
            gameTimer.timer.on_timer = function(timer)
                print("clock tick")
                screen.on_key_down = nil
                gameTimer.counter = gameTimer.counter + 1
                timer:stop()
                boardView:clockTock()
                states.current = states.interval
                stateMachine[states.current]()
            end
            --boardView:startClock(BarneyConstants.clockLength)
            states.current = states.pickPosition
            stateMachine[states.current]()
        end,


        [states.interval] = function()
            print("STATE: interval")
            --Players actually move on the board
            for i = 1, board.numberOfPlayers do
                boardView:movePlayer(board.players[i].number, board.players[i].y,
                    board.players[i].x, board.players[i].marker.y,
                    board.players[i].marker.x,
                    function()
                        board:playersMoved(board.players[i])
                    end)
            end
        end,

        
        [states.stopTimer] = function()
            boardView:clockReset()
            screen.on_key_down = nil
            gameTimer.timer = nil
            gameTimer = nil
            boardView:clearFocus()
            --states.current = states.populateBoard
            states.current = states.setEffects
            --states.current = states.pickPosition
            stateMachine[states.current]()
        end,


        [states.pickPosition] = function()
            print("STATE:pick position")
            gameTimer.timer:start()
            --generate a table of taken positions to avoid collisions
            local positions = {}
            for i = 1, BarneyConstants.rows do
                positions[i] = {}
                for j = 1, BarneyConstants.cols do
                    positions[i][j] = false
                end
            end

            for i = 1, board.numberOfPlayers do
                positions[board.players[i].y][board.players[i].x] = true
            end
            --randomize turn selection
            local moved = {}
            for i = 1, board.numberOfPlayers do
                local number = math.random(board.numberOfPlayers)
                --check to see if person already chose position to move to
                while(moved[number]) do
                    number = math.random(board.numberOfPlayers)
                end
                --mark off player as already chosen their position
                moved[number] = true
                --player chooses position to move to
                if(board.players[i].personality == "AI") then
                    print("AI moves")
                    --Move AI characters
                    board.players[i]:aiMove(positions)
                else
                    --Set on_key_down for player
                    board.players[i]:normalMove(positions)
                end
            end
        end,


        [states.setEffects] = function()
            for i = 1, board.numberOfPlayers do
                local x = board.players[i].x
                local y = board.players[i].y
                local localRow = board._rowsqueue[board:getFirstRowIndex()+y-1]
                if(localRow) then
                    local localEffect = localRow[x]
                    --delete from text screen
                    textScreen[y][x] = board.players[i].number
                    --absorb power
                    if(localEffect.name ~= "null") then
                        board.players[i]:addEffect(localEffect)

                        --increments/decrements appropriate effect tallys
                        board.num[string.lower(localEffect.name)] = 
                               board.num[string.lower(localEffect.name)] - 1
                        board.num["null"] = board.num["null"] + 1

                        board._rowsqueue[board:getFirstRowIndex()+y-1][x] = effectConstructor["Null"]()
                    end
                end
            end
            states.current = states.applyEffects
            stateMachine[states.current]()
        end,


        [states.applyEffects] = function()
            print("STATE: apply effects")
            board.players[1]:useEffects(nil, 1)
        end,


        [states.checkWinner] = function()
            print("STATE: check winner")
            --make sure players can get hit next round
            for i = 1, board.numberOfPlayers do
                board.players[i].hit = false
            end

            local i = 1
            while(i <= board.numberOfPlayers) do
                if(board.players[i].health <= 0) then
                    --add player to the graveyard
                    board.graveYard[board.players[i]] = board.players[i]
                    --player x removed and player x+1 takes its place
                    board:removePlayer(i)
                    i = i - 1
                end
                i = i + 1
            end
            if(board.numberOfPlayers == 1) then
                board.players[1]:PlayerWins()
                board:gameOver()
            elseif(board.numberOfPlayers <= 0) then
                board:tieGame()
            else
                board:reapZombies()
                if(moveBoard) then
                    moveBoard = nil
                    states.current = states.populateBoard
                elseif(playersMovedState) then
                    playersMovedState = nil
                    states.current = states.pickPosition
                else
                    states.current = states.moveBoard
                end
                stateMachine[states.current]()
            end
        end,


        [states.tally] = function()
            print("STATE: tally")
            print("\n\n\nplayers: "..board.numberOfPlayers.."\n\n\n")
            printScores()
            screen.on_key_down = nil
            local timer = Timer{interval = 5,
            on_timer = function(timer)
            timer:stop()
            --states.current = states.reset
            states.current = states.menu
            stateMachine[states.current]()
            end}
        end,


        [states.reset] = function()
            print("STATE: reset")
            while(board:getQSize() > 0) do 
                board:DQRow()
            end
            Images = nil
            boardView = nil
            timer = nil
            textScreen = nil
            stateMachine = nil
            states.current = states.init
            start_game()
        end,

        [states.menu] = function()
            splashScreen = {"Play Game", "Go Away"}
            splashScreen.marker = 1
            printSplash()
            menuView:showMenu()
            screen.on_key_down = function(screen, key)
                if(key == keys.Up) then
                    splashScreen.marker = splashScreen.marker - 1
                    splashScreen.marker = Utils.clamp(1, splashScreen.marker, #splashScreen)
                    assert(splashScreen)
                    printSplash()
                    menuView:selectOption(splashScreen.marker)
                elseif(key == keys.Down) then
                    splashScreen.marker = splashScreen.marker + 1
                    splashScreen.marker = Utils.clamp(1, splashScreen.marker, #splashScreen)
                    assert(splashScreen)
                    printSplash()
                    menuView:selectOption(splashScreen.marker)
                elseif(key == keys.Return) then
                    screen.on_key_down = nil
                    menuView:clear()
                    if(splashScreen.marker == MenuViewConstants.PLAY) then
                        states.current = states.reset
                    else
                        states.current = states.reset
                        exit()
                    end
                    splashScreen = nil
                    stateMachine[states.current]()
                end
            end
        end
    }

    return state

end

function textShow()
    local textBoard = "\n"
    for i = 1, BarneyConstants.rows do
        textBoard = textBoard.."\n"..string.format(string.rep("%8s", #textScreen[i]), unpack(textScreen[i]))
    end 
    print(textBoard.."\n")
end

function clearTextScreen()
    for i = 1, BarneyConstants.rows do
        textScreen[i] = {}
        for j = 1, BarneyConstants.cols do
            textScreen[i][j] = "0"
        end
    end
end

function printScores()
    for i = 1, 4 do
        print("player "..i.." score: "..board.scores[i])
    end
end

function printSplash()
    local splashText = "\n"
    for i = 1, #splashScreen do
        if(splashScreen.marker == i) then
            splashText = splashText.."#"
        end
        splashText = splashText..splashScreen[i].." "
    end
    print("\n"..splashText.."\n")
end
