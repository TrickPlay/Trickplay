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
    print("apply "..self.name)
    self[self.name](self, player)
    --boardView:animateEffect(player._effects[i], player)
end

--Attacks everybody
function Effect:nuke(player)
    for i = 1, board.numberOfPlayers do
        board.players[i]:getsHit()
    end
    --**animation**
end


--Support
    --Gives the player health
function Effect:health(player)
    player.health = Utils.clamp(0, player.health + 100/BarneyConstants.numberOfHearts, 100)
    boardView:setPlayerHealth(player.number, player.health)
    print("player "..player.number.." health: "..player.health)
end

function Effect:shield(player)
    player.shield = true
    --**animate**
end

--Single Attack
    --Attacks across all places horizontal and vertical to the player
function Effect:laser(player)
    --X axis
    for i = 1, board.numberOfPlayers do
        if(board.players[i].number ~= player.number) then
            if(player.x == board.players[i].x) then
                board.players[i]:getsHit()
            end
        end
    end
    --Y axis
    for i = 1, board.numberOfPlayers do
        if(board.players[i].number ~= player.number) then
            if(player.y == board.players[i].y) then
                board.players[i]:getsHit()
            end
        end
    end
    --***animate attack***
end

--Attacks whoever stepped on it
function Effect:acid(player)
    player:getsHit()
    --***animate***
end

--Attacks one random player, not the player using it
function Effect:surge(player)
    local random = math.random(board.numberOfPlayers)
    while(board.players[random].number ~= player.number) do
        random = math.random(board.numberOfPlayers)
    end
    board.players[random]:getsHit()
    --***animate***
end


--Area Attack
    --Attacks 8 random places, possibly the player
function Effect:water(player)
    for i = 1, 8 do
        local randx = math.random(BarneyConstants.cols)
        local randy = math.random(BarneyConstants.rows)

        for j = 1, board.numberOfPlayers do
            if(board.players[j].x == randx and board.players[j].y == randy) then
                board.players[j]:getsHit()
                --***animate***
            end
        end
    end
end

--Attacks everybody except the player
function Effect:saw(player)
    for i = 1, board.numberOfPlayers do
        if(board.players[i].number ~= player.number) then
            board.players[i]:getsHit()
        end
    end
    --**animate**
end

--Movement Enhancers
    --Teleports the player to a random place on the board
function Effect:tele(player)
    player.x = math.random(BarneyConstants.cols)
    player.y = math.random(BarneyConstants.rows)
    player.marker.x = player.x
    player.marker.y = player.y
end

function Effect:jet(player)
end

--Special
    --Explosion in the background
function Effect:bigRed(player)
    --***animate***
end

--Randomly re-assigns all the spots on the board
function Effect:recycle(player)
    while(board:getQSize() > 0) do
        board:DQRow()
    end
    while(board:getQSize() < BarneyConstants.rows) do
        board:enQRow(board:generateRow())
    end
    --***animate***
end

function Effect:null(player)
end

--Effects Factory
effectConstructor = { 
Nuke = class(Effect, function(nuke, kwargs)
    nuke.name = "nuke"
    nuke.numberOfUses = 1
    nuke.imageSrc = "img/powerup_example_100x100.png"
end),


--Support
Health = class(Effect, function(health, kwargs)
    health.name = "health"
    health.numberOfUses = 1
    health.imageSrc = "img/powerup_crown_new.png"
end),

Shield = class(Effect, function(shield, kwargs)
    shield.name = "shield"
    shield.numberOfUses = 1
    shield.imageSrc = "img/powerup_crown_new.png"
end),


--Single Attack
Laser = class(Effect, function(laser, kwargs)
    laser.name = "laser"
    laser.numberOfUses = 1
    laser.imageSrc = "img/powerup_crown_new.png"
end),

Acid = class(Effect, function(acid, kwargs)
    acid.name = "acid"
    acid.numberOfUses = 1
    acid.imageSrc = "img/powerup_crown_new.png"
end),

Surge = class(Effect, function(surge, kwargs)
    surge.name = "surge"
    surge.numberOfUses = 1
    surge.imageSrc = "img/powerup_crown_new.png"
end),


--Area Attack
Water = class(Effect, function(water, kwargs)
    water.name = "water"
    water.numberOfUses = 1
    water.imageSrc = "img/powerup_crown_new.png"
end),

Saw = class(Effect, function(saw, kwargs)
    saw.name = "saw"
    saw.numberOfUses = 1
    saw.imageSrc = "img/powerup_crown_new.png"
end),


--Movement enhancers
Tele = class(Effect, function(tele, kwargs)
    tele.name = "tele"
    tele.numberOfUses = 1
    tele.imageSrc = "img/powerup_crown_new.png"
end),

Jet = class(Effect, function(jet, kwargs)
    jet.name = "jet"
    jet.numberOfUses = 4
    jet.imageSrc = "img/powerup_crown_new.png"
end),


--Special
BigRed = class(Effect, function(bigRed, kwargs)
    bigRed.name = "bigRed"
    bigRed.numberOfUses = 1
    bigRed.imageSrc = "img/powerup_crown_new.png"
end),

Recycle = class(Effect, function(recycle, kwargs)
    recycle.name = "recycle"
    recycle.numberOfUses = 1
    recycle.imageSrc = "img/powerup_crown_new.png"
end),

Null = class(Effect, function(null, kwargs)
    null.name = "0"
    null.numberOfUses = 0
    null.imageSrc = ""
end)
}
