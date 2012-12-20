local game_test = Group { y = screen.h - 960 }

local sprites = SpriteSheet { map = "assets/game-sprites.json" }

local monsters = Group{}
local monster_table = {}
local explosions = Group{}
local explosions_table = {}
local R = math.pi/180

local function init()

    -- Create monsters
    for i = 1,600 do
        local speed = 120+math.random()*120
        local angle = math.random()*360
        local scale = 0.5+math.random()*0.7

        local monster = Sprite { sheet = sprites, id = "monster/s1", x = math.random()*1920, y = math.random()*960, scale = { scale, scale } }
        if(angle >= 45 and angle < 135) then
            monster.prefix = "monster/s"
        elseif(angle >=135 and angle < 225) then
            monster.prefix = "monster/w"
        elseif(angle >= 225 and angle < 315) then
            monster.prefix = "monster/n"
        else
            monster.prefix = "monster/e"
        end

        monster.frame = math.random(3)
        monster.id = monster.prefix..monster.frame
        monster.xMove = math.cos(angle*R)*speed
        monster.yMove = math.sin(angle*R)*speed

        monsters:add(monster)
        table.insert(monster_table, monster)
    end

    -- Create explosions
    for i = 1,8 do
        local explosion = Sprite { sheet = sprites, id = "explosion/e_f0"..i, x = -200, y = -200 }
        explosion.anchor_point = {explosion.w/2, explosion.h/2}
        explosion.frame = i
        explosion.prefix = "explosion/e_f0"

        explosions:add(explosion)
        table.insert(explosions_table, explosion)
    end
end

local ground_tile = Image { src = "assets/groundtile.png", w = 1920, h = 960, tile = {true, true} }
local tower = Sprite { sheet = sprites, id = "lighthouse", position = { 880, 360 } }
local tower_top = Sprite { sheet = sprites, id = "lighthousetop", position = { 900, 384 } }
local laser = Rectangle{ size = { 320, 3 }, color = "red", position = { 944, 424 } }

game_test:add(ground_tile,monsters,tower,laser,explosions,tower_top)

local monster_animate
monster_animate = function(monster)

    local monster_x = monster.x
    local monster_y = monster.y

    -- First, reposition mob if necessary
    if(monster_x <= -40) then
        monster_x = monster_x + 1960
        monster.x = monster_x
    elseif(monster_x >= 1920) then
        monster_x = monster_x - 1960
        monster.x = monster_x
    end
    if(monster_y <= -40) then
        monster_y = monster_y + 1000
        monster.y = monster_y
    elseif(monster_y >= 960) then
        monster_y = monster_y - 1000
        monster.y = monster_y
    end

    local xMove = monster.xMove
    local yMove = monster.yMove

    -- When will the edge get hit?
    local xDuration, yDuration
    if(xMove > 0) then
        xDuration = (1920 - monster_x) / xMove
    else
        xDuration = (monster_x + 40) / -xMove
    end

    if(yMove > 0) then
        yDuration = (960 - monster_y) / yMove
    else
        yDuration = (monster_y + 40) / -yMove
    end

    -- Which direction will get edge hit sooner? (in seconds)
    local duration = math.min(xDuration, yDuration)

    monster:animate(
        {
            duration = duration*1000+1,
            x = monster_x + (xMove * duration),
            y = monster_y + (yMove * duration),
            on_completed = monster_animate, -- wrap and continue when done
        }
    )
end

game_test.start = function()
    init()

    for _,monster in ipairs(monster_table) do
        monster_animate(monster) -- kick off each monster
    end


    local t = Timer
    {
        interval = 17,
        on_timer = function()

            -- draw laser and explosions
            for _,explosion in ipairs(explosions_table) do
                if(explosion.frame == 1) then
                    local angle = math.random()*360
                    local delta_x = 320*math.cos(angle*R)
                    local delta_y = -320*math.sin(angle*R)

                    laser.z_rotation = { -angle, 0, 1.5 }

                    explosion.x = 944+delta_x
                    explosion.y = 424+delta_y
                end

                explosion.frame = (explosion.frame % 8)+1
                explosion.id = explosion.prefix..explosion.frame
            end

            -- position monsters
            for _,monster in ipairs(monster_table) do
                monster.frame = (monster.frame % 3)+1
                monster.id = monster.prefix..monster.frame
            end


        end
    }
end

return game_test

