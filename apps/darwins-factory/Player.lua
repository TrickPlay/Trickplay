Player = class(function(player, kwargs) 
    kwargs = kwargs or {}

    player.health = 100 
    player.x = 0
    player.y = 0
    player.color = 0xFFFFFF
    player.personality = "Player"
    player._effects = {}
    player.marker = {x = 0, y = 0}
    player.range = 2
    player.number = 1
    player.score = 0
    player.shield = false

    for k,v  in pairs(kwargs) do
        player[k] = v
    end

end)

function Player:getsHit()
    if(not self.shield) then
        self.health = self.health - 100/BarneyConstants.numberOfHearts
        boardView:setPlayerHealth(self.number, self.health)
    else
        self.shield = false
    end
    print("player "..self.number.." health: "..self.health)
end

--[[
    Adds an Effect object to the Player. Adds it to the table of currently triggered
    power-ups, weapons, etc.

    @param effect The Effect object to add to the Player.
--]]
function Player:addEffect(effect)
    assert(effect)

    self._effects[effect] = effect
    print(self._effects[effect].name.." added to player")
end

--[[
    Deletes the specified Effect object from the Player's currently instilled Effects.
    
    @param effect The Effect object to delete. Must have the same address as the effect
    added. effect is used as a key in the Player's table of effects to access and
    delete the effect.
--]]
function Player:deleteEffect(effect)
    assert(effect)
    self._effects[effect] = nil
end

--[[
    Applys all of the Player's current Effects!
--]]
function Player:useEffects()--k, currentPlayer)
--[[
    k,v = next(self._effects, k)
    if k then
        self._effects[k]:apply(self)    --logical apply
        boardView:doAnimate(self:useEffects(k, currentPlayer))
    elseif(currentPlayer < board.numberOfPlayers) then
        board.players[currentPlayer+1]:useEffects(nil, currentPlayer+1)
    else
        --change state
        states.current = states.checkWinner
        stateMachine[states.current]()
    end
--]]
---[[
    for k,v in pairs(self._effects) do
        self._effects[k]:apply(self)
        self._effects[k].numberOfUses = self._effects[k].numberOfUses - 1
        --If no uses left delete effect
        if(self._effects[k].numberOfUses <= 0) then
            self:deleteEffect(self._effects[k])
        end
    end
    --]]
end

--[[
    Selects a random position for the Player to move to
--]]
function Player:randomMove()
    local validPositions = {}
    for y = self.y-self.range, self.y+self.range do
        for x = self.x-self.range, self.x+self.range do
            if(y >= 1 and y <= BarneyConstants.rows
            and x >= 1 and x <= BarneyConstants.cols) then
                validPositions[#validPositions+1] = {y, x}
            end
        end
    end

    local position = math.random(#validPositions)
    self.marker.y = validPositions[position][1]
    self.marker.x = validPositions[position][2]
    self.y = validPositions[position][1]
    self.x = validPositions[position][2]
end

--[[
    Gives the player the ability to move the marker across the map.
--]]
function Player:normalMove()
    local marker = {x = board.players[1].marker.x, y = board.players[1].marker.y}
    textScreen[marker.y][marker.x] = textScreen[marker.y][marker.x].."#"

    --Place possible markers for player to proper nodes on board view
    boardView:make_selection(marker.y, marker.x, board.players[1].range)


    --Set functionality for moving player 1
    screen.on_key_down = function(screen, key)
        local marker = {x = board.players[1].marker.x, y = board.players[1].marker.y}
        if(key == keys.Left) then
            if(marker.x > 1 and not (marker.x - 1 < board.players[1].x - board.players[1].range)) then
                textScreen[marker.y][marker.x-1] = textScreen[marker.y][marker.x-1].."#"
                textScreen[marker.y][marker.x] = string.sub(textScreen[marker.y][marker.x], 1, 1)
                board.players[1].marker.x = marker.x-1
            end
        end
        if(key == keys.Right) then
            if(marker.x < BarneyConstants.cols and not (marker.x + 1 > board.players[1].x + board.players[1].range)) then
                textScreen[marker.y][marker.x+1] = textScreen[marker.y][marker.x+1].."#"
                textScreen[marker.y][marker.x] = string.sub(textScreen[marker.y][marker.x], 1, 1)
                board.players[1].marker.x = marker.x+1
            end
        end
        if(key == keys.Up) then
            if(marker.y > 1 and not (marker.y - 1 < board.players[1].y - board.players[1].range)) then
                textScreen[marker.y-1][marker.x] = textScreen[marker.y-1][marker.x].."#"
                textScreen[marker.y][marker.x] = string.sub(textScreen[marker.y][marker.x], 1, 1)
                board.players[1].marker.y = marker.y-1
            end
        end
        if(key == keys.Down) then
            if(marker.y < BarneyConstants.rows and not (marker.y + 1 > board.players[1].y + board.players[1].range)) then
                textScreen[marker.y+1][marker.x] = textScreen[marker.y+1][marker.x].."#"
                textScreen[marker.y][marker.x] = string.sub(textScreen[marker.y][marker.x], 1, 1)
                board.players[1].marker.y = marker.y+1
            end
        end

        --Set the marker in the view
        boardView:set_focus(board.players[1].marker.y, board.players[1].marker.x)
        textShow()
    end
end

--[[
    Discovers a pattern to move throughout the board.

    @return a table beginning with index 1 that defines the row, column pairs the
    player should move through in the View
--]]
function Player:setMovePattern()
    local pattern = {}
    pattern[1] = {self.y, self.x}
    local rowsLeft = self.marker.y - self.y
    local colsLeft = self.marker.x - self.x
    local row = self.y
    local col = self.x
    local i = 2

    while(colsLeft ~= 0 and rowsLeft ~= 0) do
        local ratio = rowsLeft/colsLeft
        ratio = ratio * ratio   --cancel out negative values
        if(ratio > 1) then
            if(rowsLeft < 1) then
                row = row - 1
                rowsLeft = rowsLeft + 1
            elseif(rowsLeft > 1) then
                row = row + 1
                rowsLeft = rowsLeft - 1
            end
            pattern[i] = {row, col}
        elseif(ratio < 1) then
            if(colsLeft < 1) then
                col = col - 1
                colsLeft = colsLeft + 1
            elseif(colsLeft > 1) then
                col = col + 1
                colsLeft = colsLeft - 1
            end
            pattern[i] = {row, col}
        end
        i = i + 1
    end
end
