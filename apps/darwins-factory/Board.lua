--Constructor
Board = class(function(board, kwargs)
    kwargs = kwargs or {}
    --A table which includes the four players
    board.numberOfPlayers = 4
    --The scores
    board.scores = {0, 0, 0, 0}
    --The players
    board.players = {}
    for i = 1, 4 do
        board.players[i] = Player()
        board.players[i].y = BarneyConstants.rows
        board.players[i].x = i*math.floor(BarneyConstants.cols/4)
        board.players[i].color = 0x000FFF*2^(4*(i-1))
        board.players[i].marker.x = board.players[i].x
        board.players[i].marker.y = board.players[i].y
        board.players[i].number = i
        ---[[
        if(i ~= 1) then
            board.players[i].personality = "AI"
        end
        --]]
    end
    --A queue of available rows of power ups
    board._rowsqueue = {first = 1, last = 0}
    for k,v in pairs(kwargs) do
        board[k] = v
    end
    --The grave yard
    board.graveYard = {}

    board.num =  {nuke = 0, 
                   saw = 0, 
                shield = 0,
                health = 0,  
                 laser = 0, 
                 water = 0, 
                 surge = 0,
               recycle = 0, 
                  tele = 0, 
                   jet = 0,
                bigred = 0,
                  null = 0,
                  acid = 0}


    board.max =  {nuke = 0, 
                   saw = 2, 
                shield = 2,
                health = 1,  
                 laser = 3, 
                 water = 3, 
                 surge = 2,
               recycle = 2, 
                  tele = 2, 
                   jet = 2,
                bigred = 1,
                  null = BarneyConstants.rows*
                         BarneyConstants.cols,
                  acid = 8}
end)

--Methods
--[[
    Generates an effectsRow for the board using a random number generator.

    @param seed The seed to the generator, outputs a number between 1 and
    this value. Must be >= 1.

    @return effectsRow The effectsRow to be enQed to the rowsqueue
--]]
function Board:generateRow()
    local effectsRow = {}
    local effect

    for i = 1, BarneyConstants.cols do
        --nil/zero means no power up/weapon
        local effect = math.random(1,2)
        if effect == 1 then
            while true do
                effect = BarneyConstants.effects[math.random(#BarneyConstants.effects)]
                if board.num[string.lower(effect)] < board.max[string.lower(effect)] then break end
            end
            board.num[string.lower(effect)] = board.num[string.lower(effect)] + 1
            effectsRow[i] = effectConstructor[effect]()
        else
            board.num["null"] = board.num["null"] + 1
            effectsRow[i] = effectConstructor["Null"]()
        end
        assert(effectsRow[i].name)
    end
    return effectsRow
end

--[[
    Pushes a effectsRow to the rowsqueue. This puts rows of power
    ups/weapons onto the board.

    @param effectsRow The row of power ups/weapons to enQ onto the board from
    the top
--]]
function Board:enQRow(effectsRow)
    self._rowsqueue.first = self._rowsqueue.first - 1
    self._rowsqueue[self._rowsqueue.first] = effectsRow
end

--[[
    DQ's an effectsRow from the queue, use for deleting rows from the bottom.
    However, still returns the effectsRow if needed.

    @return effectsRow The bottom row of the rowsqueue
--]]
function Board:DQRow()
    local last = self._rowsqueue.last
    if last < self._rowsqueue.first then
        error("queue is empty")
    end
    local effectsRow = self._rowsqueue[last]
    for i=1,#effectsRow do
        board.num[string.lower(effectsRow[i].name)] = 
                               board.num[string.lower(effectsRow[i].name)] - 1
        assert(board.num[string.lower(effectsRow[i].name)] >= 0, 
          "decremented effect counter below zero, effect: "..effectsRow[i].name.." at "..i)
    end
    self._rowsqueue[last] = nil
    self._rowsqueue.last = last - 1
    return effectsRow
end

--[[
    @return the next row in the queue of rows past currentRowIndex. The first
    item in the queue may be retrieved via getFirstRow()
--]]
function Board:getNextRow(currentRowIndex)
    if currentRowIndex < self._rowsqueue.last then
        return self._rowsqueue[currentRowIndex+1]
    else
        return nil
    end
end

--[[
    Returns the index of the first row of Effect objects on the Board.

    @return the index of the first item of the queue (Last In) so the caller may
    walk down the queue to an appropriate row via getNextRow.
--]]
function Board:getFirstRowIndex()
    if(self._rowsqueue.first > self._rowsqueue.last) then
        error("queue is empty")
    end

    return self._rowsqueue.first
end

--[[
    Returns the number of rows of Effect objects currently queued to the Board

    @return the number of rows currently queued.
--]]
function Board:getQSize()
    return self._rowsqueue.last - self._rowsqueue.first + 1
end

--[[
    Returns the Effect object at the specified row and column of the Board

    @return the Effect at the row, col of the Board.
--]]
function Board:getEffectAt(row, col)
    local row = self._rowsqueue.first + row - 1
    if(self._rowsqueue[row]) then
        return self._rowsqueue[row][col]
    end
    return effectConstructor["Null"]()
end

--[[
    Removes the designated player specified by playerNumber from the game. Also
    decreases Board.numberOfPlayers by 1 and shifts all player numbers down one
    to respect of table Board.players. Thus, if player 1 is removed, player 2 can
    now be accessed via Board.players[1].

    @parameter playerNumber The player (i.e. player '1') to remove from the game
--]]
function Board:removePlayer(playerNumber)
    assert(playerNumber >= 1 and playerNumber <= self.numberOfPlayers)
    local player = self.players[playerNumber]
    --remove the player from the game
        --Logical
    self.players[playerNumber] = nil
        --View
    boardView:animateKillPlayer(player.number, player.y, player.x)
    --Play death sound
    if(player.number == 1) then     --human
        mediaplayer:play_sound("sounds/human_death.wav")
    else
        mediaplayer:play_sound("sounds/ai_death.wav")
    end
    
    --change ordering of player linked list
    for i = playerNumber+1, self.numberOfPlayers do
        self.players[i-1] = self.players[i]
        self.players[i] = nil
    end
    self.numberOfPlayers = self.numberOfPlayers - 1
end

function Board:tieGame()
    board:reapZombies()
    states.current = states.tally
    stateMachine[states.current]()
end

function Board:gameOver()
    board:reapZombies()
    --Give the remaining player maximum points
    local player = board.players[1]
    self.scores[player.number] = self.scores[player.number] + 400 + player.score
    states.current = states.tally
    stateMachine[states.current]()
end

function Board:reapZombies()
    --assign a score, if first to die get +0, second then +100, ...
    --also gain points for how the game was played
    for k,player in pairs(self.graveYard) do
        self.scores[player.number] = self.scores[player.number] + (4-self.numberOfPlayers)*100 + player.score
    end
    --reset grave yard
    board.graveYard = {}
end

function Board:playersMoved(player)
    textScreen[player.y][player.x] = string.sub(textScreen[player.y][player.x],1,1)
    --set player to new position
    player.x = player.marker.x
    player.y = player.marker.y
    if(self:getEffectAt(player.y, player.x).name == "acid") then
        player:getsHit()
        player.hit = false
    end
    --update in textScreen
    textScreen[player.y][player.x] = textScreen[player.y][player.x]..player.number
    
    --Check for all players have moved
    if(movedFlag >= board.numberOfPlayers - 1) then
        movedFlag = 0
        textShow()
        if(gameTimer.counter < BarneyConstants.intervals) then
            playersMovedState = true
            states.current = states.checkWinner
            --states.current = states.pickPosition
            --states.current = states.populateBoard
        else
            states.current = states.stopTimer
        end
        stateMachine[states.current]()
    else
        movedFlag = movedFlag + 1 
    end
end

function Board:movePlayersDown()
    for i = 1, self.numberOfPlayers do
        self.players[i].y = self.players[i].y + 1
        --Check for player falling off the board
        if(self.players[i].y > BarneyConstants.rows) then
            self.players[i].y = BarneyConstants.rows
            self.players[i]:getsHit()
        end
        self.players[i].marker.y = self.players[i].y
    end
end
