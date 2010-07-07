states = {
    splash = 0,
    init = 1,
    populateBoard = 2,
    setTimer = 3,
    move = 4,
    setEffects = 5,
    applyEffects = 6,
    checkWinner = 7,
    tally = 8,
    reset = 9
}
states.current = states.splash

function StateMachine()

    local state = {
        [states.splash] = function()
            splashScreen = {"Play Game", "Instructions", "Go Away"}
            splashScreen.marker = 1
            printSplash()
            screen.on_key_down = function(screen, key)
                
                if(key == keys.Up) then
                    splashScreen.marker = splashScreen.marker - 1
                    splashScreen.marker = Utils.clamp(1, splashScreen.marker, 3)
                    printSplash()
                elseif(key == keys.Down) then
                    splashScreen.marker = splashScreen.marker + 1
                    splashScreen.marker = Utils.clamp(1, splashScreen.marker, 3)
                    printSplash()
                elseif(key == keys.Return) then
                    if(splashScreen[splashScreen.marker] == "Play Game") then
                        screen.on_key_down = nil
                        splashScreen = nil
                        states.current = states.init
                        stateMachine[states.current]()
                    end
                end
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
            states.current = states.populateBoard
            stateMachine[states.current]()
        end,


        [states.populateBoard] = function()
            --Update effects plane in view
            local newRow = board:generateRow()
            boardView:update_board(board, newRow)
            --enQ the new row, DQ an old one
            board:enQRow(newRow)
            if(board:getQSize() > BarneyConstants.rows) then
                board:DQRow()
            end

            --Add all information to textBoard
            clearTextScreen()
            local currentRowIndex = board:getFirstRowIndex() - 1
            assert(board:getNextRow(currentRowIndex))
            local currentRow = board:getNextRow(currentRowIndex)
            --put effects on the board
            while(currentRow) do
                currentRowIndex = currentRowIndex + 1
                for i = 1, BarneyConstants.cols do
                    if(currentRow[i] ~= 0) then
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
                boardView:movePlayer(board.players[i].number, board.players[i].y, board.players[i].x, board.players[i].marker.y, board.players[i].marker.x)
            end
            textShow()
            states.current = states.setTimer
            --[[Set Pause Game
            screen.on_key_down = function(screen, key)
                if(key = keys.Return) then
                    if(paused) then
                        paused = not paused
                        states.current = states.previous
                    else
                        paused = not paused

                    end
                end
            end
            --]]
            --states.current = states.setEffects
            stateMachine[states.current]()
        end,


        [states.setTimer] = function()
            print("Setting Timer")
            local timer = Timer()

            timer.interval = BarneyConstants.clockLength
            function timer.on_timer(timer)
                screen.on_key_down = nil
                for i = 1, board.numberOfPlayers do
                    --Clear the text where the player(s) were previously
                    --to not overload textScreen
                    textScreen[board.players[i].y][board.players[i].x] = 0
                    --Set players to the new position
                        --Set Movement Pattern
                    --local pattern = board.players[i]:setMovePattern()
                        --in View
                    boardView:movePlayer(board.players[i].number, board.players[i].y, board.players[i].x, board.players[i].marker.y, board.players[i].marker.x)
                        --in Model
                    board.players[i].x = board.players[i].marker.x
                    board.players[i].y = board.players[i].marker.y
                end
                boardView:clear_selection()
                timer:stop()
                --states.current = states.populateBoard
                states.current = states.setEffects
                stateMachine[states.current]()
            end
            timer:start()
            boardView:startClock(BarneyConstants.clockLength)
            states.current = states.move
            stateMachine[states.current]()
        end,


        [states.move] = function()
            print("Player Moves")
            ---[[
            for i = 1, board.numberOfPlayers do
                if(board.players[i].personality == "AI") then
                    --Move AI characters
                    board.players[i]:randomMove()
                else
                    --Move Player characters
                    board.players[i]:normalMove()
                end
            end
            --]]
            --[[
            --Move AI characters
            for i = 2, board.numberOfPlayers do
                board.players[i]:randomMove()
            end

            --Move Player characteres
            if(board.players[1].number == 1) then
                board.players[1]:normalMove()
            end
            --]]
        end,


        [states.setEffects] = function()
            for i = 1, board.numberOfPlayers do
                local x = board.players[i].x
                local y = board.players[i].y
                local localRow = board._rowsqueue[board:getFirstRowIndex()+y-1]
                    if(localRow) then
                        local localEffect = localRow[x]
                        if(localEffect ~= 0) then
                            board.players[i]:addEffect(localEffect)
                            board._rowsqueue[board:getFirstRowIndex()+y-1][x] = 0
                    end
                end
            end
            states.current = states.applyEffects
            stateMachine[states.current]()
        end,


        [states.applyEffects] = function()
            print("STATE: apply effects")
            --[[
            board.players[1]:useEffects()
            --]]
            ---[[
            for i = 1, board.numberOfPlayers do
                board.players[i]:useEffects()
            end
            states.current = states.checkWinner
            stateMachine[states.current]()
            --]]
        end,


        [states.checkWinner] = function()
            print("STATE: check winner")
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
                board:gameOver()
            elseif(board.numberOfPlayers <= 0) then
                board:tieGame()
            else
                board:reapZombies()
                --states.current = states.setTimer
                states.current = states.populateBoard
                stateMachine[states.current]()
            end
        end,


        [states.tally] = function()
            print("STATE: tally")
            printScores()
            screen.on_key_down  = function(screen, key)
                if(key == keys.Return) then
                    states.current = states.reset
                    screen.on_key_down = nil
                    stateMachine[states.current]()
                end
            end
        end,


        [states.reset] = function()
            print("STATE: reset")
            while(board:getQSize() > 0) do 
                board:DQRow()
            end
            Images = nil
            boardView = nil
            --board = nil
            timer = nil
            textScreen = nil
            stateMachine = nil
            states.current = states.init
            main()
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
    for i = 1, 3 do
        if(splashScreen.marker == i) then
            splashText = splashText.."#"
        end
        splashText = splashText..splashScreen[i].." "
    end
    print("\n"..splashText.."\n")
end
