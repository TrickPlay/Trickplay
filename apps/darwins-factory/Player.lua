Player = class(function(player, kwargs) 
    kwargs = kwargs or {}

    player.health = 100 
    player.x = 0
    player.y = 0
    player.color = 0xFFFFFF
    player.personality = "Player"
    player._effects = {}
    player.marker = {x = 0, y = 0}
    player.range = 1
    player.number = 1
    player.score = 0
    player.shield = 0
    player.jetpack = false
    player.hit = false

    for k,v  in pairs(kwargs) do
        player[k] = v
    end

end)

function Player:getsHit()
    if(not self.hit) then
        if(self.shield <= 0) then
            self.health = self.health - 100/BarneyConstants.numberOfHearts
            boardView:setPlayerHealth(self.number, self.health)
        else
            self.shield = self.shield - 1
            boardView:setPlayerShield(self.number, self.shield)
        end
        self.hit = true
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
function Player:useEffects(k, currentPlayer)
    ---[[
    k,v = next(self._effects, k)
    if k then
        local attackedPlayers, targets = self._effects[k]:apply(self)    --logical apply
        local effect = self._effects[k].name

        self._effects[k].numberOfUses = self._effects[k].numberOfUses - 1
        --If no uses left delete effect
        if(self._effects[k].numberOfUses <= 0) then
            --if jetpack then turn off flag
            if(self._effects[k].name == "jet") then
                self.jetpack = false
            end
            self:deleteEffect(self._effects[k])
        end
        --tele is a special case
        if(effect == "tele") then
            boardView:doTeleAnimate(currentPlayer, self.marker.y,
                self.marker.x, self.y, self.x,
                function()
                    self:useEffects(k, currentPlayer)
                end)
            self.marker.x = self.x
            self.marker.y = self.y
        --recycle
        elseif(effect == "recycle") then
            boardView:animateStamp(board,
                function()
                    self:useEffects(k, currentPlayer)
                end)
        elseif effect == "water" then
            boardView:doWaterAnimate(targets,self.marker.y,self.marker.x,
                function()
                    self:useEffects(k, currentPlayer)
                end)
        else
            boardView:doAnimate(effect, self, attackedPlayers,
                function()
                    self:useEffects(k, currentPlayer)
                end)
        end
    elseif(currentPlayer < board.numberOfPlayers) then
        board.players[currentPlayer+1]:useEffects(nil, currentPlayer+1)
    else
        --change state
        states.current = states.checkWinner
        stateMachine[states.current]()
    end
end

--[[
    AI logic
--]]
function Player:aiMove(positions)
    timestep = BarneyConstants.intervals - gameTimer.counter
    assert(timestep >  0, "negative timestep")
    assert(timestep <= BarneyConstants.intervals,"timestep over limit")
   print("AI Player",self.number,"   timestep",timestep)

    --if player has a jetpack, total range is doubled
    if self.jetpack == true then timestep = timestep * 2 end

    self.has_been_hit = false

    --associates a priority value to each powerup (lower means better)
    local pick = {nuke = 1, 
                   saw = 1, 
                shield = 1,
                health = 1,  
                 laser = 3, 
                 water = 3, 
                 surge = 3,
                   jet = 3,
               recycle = 4, 
                  tele = 4, 
                bigRed = 5,
                  null = 5,
                  acid = 6} 

    --if you're low on hearts aim for healths, de-prioritize nuke and saw
    if self.health <= 40 then
        pick.nuke = 2
        pick.saw = 2
    --otherwise, make the health items secondary
    else
        pick.health = 2
        pick.shield = 2
    end

    --if health is maxed out, don't go after hearts
    if self.health == 100 then pick.health = 5 end
    --if shields are maxed out, don't go after them
    if self.shield*20 >= self.health then pick.shield = 5 end
    --if you have a jetpack, lower its priority
    if self.jetpack == true then pick.jet = 5 end


    --constants, reduce lookups
    local board_width  = BarneyConstants.cols
    local board_height = BarneyConstants.rows
    local max_dist = board_width+board_height

    --make the list of enemy locations
    local enemies = {}
    local index = 1
    for i=1,board.numberOfPlayers do
        --skip yourself
        if board.players[i] ~= self then
            enemies[index] = {board.players[i].x, board.players[i].y}
            index = index + 1
        end
    end

    --list of all the power-ups
    local powup_list = {}
    local powup

    --use distance to the power-up as well as distance from the enemies
    --to these powerups to determine if a powerup is worth going after
    local my_dist = 1
    local their_dist = max_dist+1
    local curr_dist = 1

    local effect = {} --table that stores the power-up, its x and its y

    --iterate through a window based on the amount of timesteps left
    local row_start = self.y - timestep
    local row_end   = self.y + timestep
    local col_start = self.x - timestep
    local col_end   = self.x + timestep
    
    --bound the window to the edges of the game board, don't aim for the
    --last row since it will shift into the lava at the end of the
    --interval
    if row_start < 1            then row_start = 1            end
    if row_end > board_height-1 then row_end = board_height-1 end

    if col_start < 1            then col_start = 1            end
    if col_end > board_width    then col_end = board_width    end


    --create  the powerup list
    for row     = row_start , row_end do
        for col = col_start , col_end do
            --need to reset the tables, otherwise errors arise
            effect = {}
            powup = {}

            powup = board:getEffectAt(row,col)
            my_dist = math.abs(row-self.y) +
                      math.abs(col-self.x)
            
            --add the powerups to the list according to distance and
            --skip the corners that were iterated over
            if   my_dist  <= timestep and 
               powup.name ~= "null"  and 
               powup.name ~= "acid"   and 
               powup.name ~= "bigRed" then

                --need to reset this before the less than check below
                their_dist = max_dist + 1 

                --find out if enemies are closer to the power-up
                for i=1,(board.numberOfPlayers-1) do

                    curr_dist = math.abs(col-enemies[i][1]) + 
                                math.abs(row-enemies[i][2])

                    if curr_dist < their_dist then 
                        their_dist = curr_dist 
                    end
                end
                --distance matters less with jetpack
                if self.jetpack == true then
                    their_dist = their_dist * 2
                end
                --if no one else is closer then add it to the list
                --but if, the 'power-up choosing' interval is about to
                --disregard enemy distances (as long as they aren't
                --on top of the powerup)
                if (my_dist <= their_dist) or (math.floor(timestep/2) <
                   their_dist) then
                    --print("\t",powup.name,"at dist",my_dist,"added")
                    --initialize list if it hasnt been already
                    if  powup_list[my_dist] == nil then
                        powup_list[my_dist] = {}
                    end
                    effect.powup = powup
                    effect.c = col
                    effect.r = row
                    effect.nearest = their_dist
                    powup_list[my_dist][#powup_list[my_dist]+1] = effect
                --else
                    --print("\t",powup.name,"at dist",my_dist,"not added")
                end
            end
        end
    end

    local current_option = {}
    --init the comparer value to the worst power-up, acid
    current_option.priority = pick["acid"]


    --chooses the best power-up found from the powerup list
    for i=0,timestep do
        if powup_list[i] ~= nil then
            for k,effect in ipairs(powup_list[i]) do

                --if the this powerup is better then the currently selected
                --one, then switch to it
                --print(i,pick[effect.powup.name],current_option.priority)
                if pick[effect.powup.name] < current_option.priority then
                   current_option.powup = effect.powup
                   current_option.priority = pick[effect.powup.name]
                   current_option.c = effect.c
                   current_option.r = effect.r
                   current_option.nearest = their_dist
                end
            end
        end
    end

    local dest = {x=0,y=0}

    --move the player
    if current_option.priority == pick["acid"] then
        --back up is random
        dest.x = math.random(col_start, col_end)
        dest.y = math.random(row_start, row_end)
        print("\tPlayer",self.number,"random:",dest.x,dest.y)
    else
        --otherwise copy location of the selected power-up
        dest.x, dest.y = current_option.c, current_option.r
        print("\tPlayer",self.number,"picked:",current_option.powup.name,
                          ", nearest enemy dist:",current_option.nearest)
    end    

    self:NextStep(dest.x,dest.y,self.x,self.y,positions)
    --with a jet pack you move twice
    if self.jetpack == true then
        self:NextStep(dest.x, dest.y, self.marker.x, 
                                      self.marker.y, positions)
    end
end

function Player:NextStep(dest_x,dest_y, pos_x, pos_y,position)
    print("\tdest:",dest_x,dest_y,"current pos:",pos_x, pos_y)

    assert(position)
    --determine the direction of the destination, relative to
    --the current position
    --values are -1, 0, or 1
    local dir = {x = 0, y = 0}
    if dest_x > pos_x then dir.x = 1
    elseif dest_x < pos_x then dir.x = -1
    end

    if dest_y > pos_y then dir.y = 1
    elseif dest_y < pos_y then dir.y = -1
    end

    --print("\tdir",dir.x,dir.y)

    --if destination is diagonal
    if dir.x ~= 0 and dir.y ~= 0 then
        --if both spots are taken, stay still
        if position[pos_y + dir.y][pos_x] == true and
           position[pos_y][pos_x + dir.x] == true then
            dir.x = 0
            dir.y = 0
        --if only one spot is taken, take the other
        elseif position[pos_y][pos_x + dir.x] == true then dir.x = 0
        elseif position[pos_y + dir.y][pos_x] == true then dir.y = 0
        --otherwise, coin-flip to pick vertical or horizontal
        else
            local flip = math.random(2)
            if flip == 1 then dir.x = 0 else dir.y = 0 end
        end
    --if destination is vertical or whore-izontal, stay still
    elseif position[pos_y + dir.y][pos_x + dir.x] == true then
         dir.x = 0
         dir.y = 0
    end

    print("\tNext step: ", pos_x + dir.x, pos_y + dir.y)
    assert(position[pos_y + dir.y][pos_x + dir.x] == false or 
          (position[pos_y + dir.y][pos_x + dir.x] == true and 
           dir.x == 0 and dir.y == 0), "trying to jump to taken spot")

    self.marker.x, self.marker.y = pos_x + dir.x, pos_y + dir.y
    position[pos_y][pos_x] = false
    position[pos_y + dir.y][pos_x + dir.x] = true
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
function Player:normalMove(positions)
    local depth = 1
    if(self.jetpack) then
        depth = 2
    end
    self.range = depth
    assert(self.y); assert(self.x)
    local moves = calculateMoves(depth, self.y, self.x)
    local marker = {x = self.marker.x, y = self.marker.y}
    textScreen[marker.y][marker.x] = textScreen[marker.y][marker.x].."#"

    --Place possible markers for player to proper nodes on board view
    --boardView:make_selection(marker.y, marker.x, self.range)
    boardView:setFocus(marker.y, marker.x)


    --Set functionality for moving player 1
    screen.on_key_down = function(screen, key)
        --The current marker position
        local marker = {x = self.marker.x, y = self.marker.y}
        --Keys change the players marker position
        if(key == keys.Left) then
            if(marker.x > 1 and not (marker.x - 1 < self.x - self.range)
                and not positions[marker.y][marker.x-1]
                and moves[marker.y][marker.x-1]) then

                positions[marker.y][marker.x] = false
                self.marker.x = marker.x-1
                positions[marker.y][marker.x-1] = true
            end
        elseif(key == keys.Right) then
            if(marker.x < BarneyConstants.cols
                and not (marker.x + 1 > self.x + self.range)
                and not positions[marker.y][marker.x+1]
                and moves[marker.y][marker.x+1]) then

                positions[marker.y][marker.x] = false
                self.marker.x = marker.x+1
                positions[marker.y][marker.x+1] = true
            end
        elseif(key == keys.Up) then
            if(marker.y > 1 and not (marker.y - 1 < self.y - self.range)
                and not positions[marker.y-1][marker.x]
                and moves[marker.y-1][marker.x]) then

                positions[marker.y][marker.x] = false
                self.marker.y = marker.y-1
                positions[marker.y-1][marker.x] = true
            end
        elseif(key == keys.Down) then
            if(marker.y < BarneyConstants.rows
                and not (marker.y + 1 > self.y + self.range)
                and not positions[marker.y+1][marker.x]
                and moves[marker.y+1][marker.x]) then

                positions[marker.y][marker.x] = false
                self.marker.y = marker.y+1
                positions[marker.y+1][marker.x] = true
            end
        end

        textScreen[self.marker.y][self.marker.x] = textScreen[self.marker.y][self.marker.x].."#"
        textScreen[marker.y][marker.x] = string.sub(textScreen[marker.y][marker.x], 1, 1)
        --Set the marker in the view
        boardView:setFocus(self.marker.y, self.marker.x)
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
    pattern[1] = {row = self.y, col = self.x, nextpair = nil, previous = nil}
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
            pattern[i].row = row
            pattern[i].col = col
            pattern[i].previous = pattern[i-1]
            pattern[i-1].nextpair = pattern[i]
        elseif(ratio < 1) then
            if(colsLeft < 1) then
                col = col - 1
                colsLeft = colsLeft + 1
            elseif(colsLeft > 1) then
                col = col + 1
                colsLeft = colsLeft - 1
            end
            pattern[i].row = row
            pattern[i].col = col
            pattern[i].previous = pattern[i-1]
            pattern[i-1].nextpair = pattern[i]
        end
        i = i + 1
    end
end
