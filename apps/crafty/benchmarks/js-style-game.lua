local game_test = Group { y = screen.h - 960 }

local sprites = SpriteSheet { map = "assets/game-sprites.json" }

local monsters = Group{}
local monster_table = {}
local explosions = Group{}
local explosion_table = {}
local R = math.pi/180

local function init()

    -- Create monsters
    for i = 1,600 do
        local speed = 3+math.random()*2
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
        table.insert(explosion_table, explosion)
    end
end

local ground_tile = Image { src = "assets/groundtile.png", w = 1920, h = 960, tile = {true, true} }
local tower = Sprite { sheet = sprites, id = "lighthouse", position = { 880, 360 } }
local tower_top = Sprite { sheet = sprites, id = "lighthousetop", position = { 900, 384 } }
local laser = Rectangle{ size = { 320, 3 }, color = "red", position = { 944, 424 } }

game_test:add(ground_tile,tower,monsters,laser,explosions,tower_top)

game_test.start = function()
    init()

    local t = Timer
    {
        duration = 17,
        on_timer = function()
            -- position monsters
            for _,monster in ipairs(monster_table) do
                monster.x = monster.x + monster.xMove
                monster.y = monster.y + monster.yMove
                if(monster.x < -40) then
                    monster.x = monster.x + 1960
                elseif(monster.x > 1920) then
                    monster.x = monster.x - 1960
                end

                if(monster.y < -40) then
                    monster.y = monster.y + 1000
                elseif(monster.y > 960) then
                    monster.y = monster.y - 1000
                end

                monster.frame = (monster.frame % 3)+1
                monster.id = monster.prefix..monster.frame
            end

            -- draw laser and explosions
            for _,explosion in ipairs(explosion_table) do
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


        end
    }
    t:start()
end

return game_test

