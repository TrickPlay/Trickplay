Effect = class(function(effects, kwargs)
    kwargs = kwargs or {}
    --Name of the object, such as "nuke"
    effects.name = nil
    --Remaining number of uses of the effect
    effects.numberOfUses = 0

    for k,v in pairs(kwargs) do
        effect[k] = v
    end
end)

--[[
    Applies the Effect.

    @parameter player The Player who is applying the effect.
--]]
function Effect:apply(player)
    assert(player)
    print("player "..player.number.." applies "..self.name)
    return self[self.name](self, player)
end

--Play sound
function Effect:playSound()
    assert(self.audioSrc)
    mediaplayer:play_sound(self.audioSrc)
end

--Attacks everybody
function Effect:nuke(player)
    for i = 1, board.numberOfPlayers do
        board.players[i]:getsHit()
    end

    return board.players
end


--Support
    --Gives the player health
function Effect:health(player)
    player.health = Utils.clamp(0, player.health + 100/BarneyConstants.numberOfHearts, 100)
    mediaplayer:play_sound("sounds/health.wav")
    boardView:setPlayerHealth(player.number, player.health)
    print("player "..player.number.." health: "..player.health)

    return {}
end

function Effect:shield(player)
    local shields = player.shield
    --only can have as many shields as hearts
    player.shield = Utils.clamp(0, player.shield + 1, player.health/BarneyConstants.numberOfHearts)
    if(player.shield > shields) then
        boardView:setPlayerShield(player.number, player.shield)
    end
    
    mediaplayer:play_sound("sounds/shield.wav")
    print("player "..player.number.." shield: "..player.shield)
    return {}
end

--Single Attack
    --Attacks across all places horizontal and vertical to the player
function Effect:laser(player)
    local attackedPlayers = {}
    local count = 1

    --X axis
    for i = 1, board.numberOfPlayers do
        if(board.players[i].number ~= player.number) then
            if(player.x == board.players[i].x) then
                board.players[i]:getsHit()
                attackedPlayers[count] = board.players[i]
                count = count + 1
            end
        end
    end
    --Y axis
    for i = 1, board.numberOfPlayers do
        if(board.players[i].number ~= player.number) then
            if(player.y == board.players[i].y) then
                board.players[i]:getsHit()
                attackedPlayers[count] = board.players[i]
                count = count + 1
            end
        end
    end

    return attackedPlayers
end

--Attacks whoever stepped on it
function Effect:acid(player)
    player:getsHit()
    mediaplayer:play_sound("sounds/acid.wav")
    return {}
end

--Attacks one random player, not the player using it
function Effect:surge(player)
    local random = math.random(board.numberOfPlayers)
    while(board.players[random].number == player.number) do
        random = math.random(board.numberOfPlayers)
    end
    board.players[random]:getsHit()

    return {board.players[random]}
end


--Area Attack
    --Attacks 8 random places, possibly the player
function Effect:water(player)
    local attackedPlayers = {}
    local targets = {}
    local count = 1

    for i = 1, 8 do
        local randx = math.random(BarneyConstants.cols)
        local randy = math.random(BarneyConstants.rows)
        targets[i] = {x = randx, y = randy}

        for j = 1, board.numberOfPlayers do
            if(board.players[j].x == randx and board.players[j].y == randy) then
                board.players[j]:getsHit()
                attackedPlayers[count] = board.players[j]
                count = count + 1
            end
        end
    end

    return attackedPlayers, targets
end

--Attacks everybody except the player
function Effect:saw(player)
    local attackedPlayers = {}
    local count = 1
    for i = 1, board.numberOfPlayers do
        if(board.players[i].number ~= player.number) then
            board.players[i]:getsHit()
            attackedPlayers[count] = board.players[i]
            count = count + 1
        end
    end

    return attackedPlayers
end

--Movement Enhancers
    --Teleports the player to a random place on the board
function Effect:tele(player)
    player.x = math.random(BarneyConstants.cols)
    player.y = math.random(BarneyConstants.rows)
    for i = 1, board.numberOfPlayers do
        --not the same player
        if(player.number ~= board.players[i].number) then
            if(player.x == board.players[i].x and player.y == board.players[i].y) then
                local y = player.y
                player.y = Utils.clamp(1, player.y+1, BarneyConstants.rows)
                if(player.y == y) then
                    player.y = player.y - 1
                end
            end
        end
    end
    --player.marker.x = player.x
    --player.marker.y = player.y

    return {}
end

function Effect:jet(player)
    player.jetpack = true
    mediaplayer:play_sound("sounds/jet.wav")
    return {}
end

--Special
    --Explosion in the background
function Effect:bigRed(player)
    --make sure no more bigRed's
    board.max.bigred = 0
    return {}
end

--Randomly re-assigns all the spots on the board
function Effect:recycle(player)
    while(board:getQSize() > 0) do
        board:DQRow()
    end
    while(board:getQSize() < BarneyConstants.rows) do
        board:enQRow(board:generateRow())
    end

    return {}
end

function Effect:null(player)
    return {}
end

--Effects Factory
effectConstructor = {
--[[ 
Nuke = class(Effect, function(nuke, kwargs)
    nuke.name = "nuke"
    nuke.numberOfUses = 1
    nuke.imageSrc = "img/powerup_example_100x100.png"
end),
--]]

--Support
Health = class(Effect, function(health, kwargs)
    health.name = "health"
    health.numberOfUses = 1
    health.imageSrc = "img/powerups/powerups_heart.png"
    health.audioSrc = "sounds/heal.wav"
end),

Shield = class(Effect, function(shield, kwargs)
    shield.name = "shield"
    shield.numberOfUses = 1
    shield.imageSrc = "img/powerups/powerups_shield.png"
    shield.audioSrc = "sounds/shield.wav"
end),


--Single Attack
Laser = class(Effect, function(laser, kwargs)
    laser.name = "laser"
    laser.numberOfUses = 1
    laser.imageSrc = "img/powerups/powerups_laser.png"
    laser.audioSrc = "sounds/laser.wav"
end),

Acid = class(Effect, function(acid, kwargs)
    acid.name = "acid"
    acid.numberOfUses = 1
    acid.imageSrc = "img/powerups/powerup_acid.png"
    acid.audioSrc = "sounds/acid.wav"
end),

Surge = class(Effect, function(surge, kwargs)
    surge.name = "surge"
    surge.numberOfUses = 1
    surge.imageSrc = "img/powerups/powerup_powersurge.png"
    surge.audioSrc = "sounds/surge.wav"
end),


--Area Attack
Water = class(Effect, function(water, kwargs)
    water.name = "water"
    water.numberOfUses = 1
    water.imageSrc = "img/powerups/powerups_water.png"
    water.audioSrc = "sounds/water.wav"
end),

Saw = class(Effect, function(saw, kwargs)
    saw.name = "saw"
    saw.numberOfUses = 1
    saw.imageSrc = "img/powerups/powerup_saw.png"
    saw.audioSrc = "sounds/saw.wav"
end),


--Movement enhancers
Tele = class(Effect, function(tele, kwargs)
    tele.name = "tele"
    tele.numberOfUses = 1
    tele.imageSrc = "img/powerups/powerups_teleport.png"
    tele.audioSrc = "sounds/teleport.wav"
end),

Jet = class(Effect, function(jet, kwargs)
    jet.name = "jet"
    jet.numberOfUses = 2
    jet.imageSrc = "img/powerups/powerups_jetpack.png"
    jet.audioSrc = "sounds/jet.wav"
end),


--Special
BigRed = class(Effect, function(bigRed, kwargs)
    bigRed.name = "bigRed"
    bigRed.numberOfUses = 1
    bigRed.imageSrc = "img/powerups/powerups_redbutton.png"
    bigRed.audioSrc = ""
end),

Recycle = class(Effect, function(recycle, kwargs)
    recycle.name = "recycle"
    recycle.numberOfUses = 1
    recycle.imageSrc = "img/powerups/powerups_lever.png"
    recycle.audioSrc = "sounds/stamp.wav"
end),

Null = class(Effect, function(null, kwargs)
    null.name = "null" 
    null.numberOfUses = 0
    null.imageSrc = ""
    null.audioSrc = ""
end)
}
