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
        effect = BarneyConstants.effects[math.random(BarneyConstants.numberOfEffects+1) - 1]
        if(effect == nil or effect.name == "0") then
            effectsRow[i] = 0
        else
            effectsRow[i] = effectConstructor[effect]()
            assert(effectsRow[i].name)
        end
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
    return 0
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
    --remove the player from the game
    self.players[playerNumber] = nil
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
