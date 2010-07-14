dofile("view/ClockView.lua")

-- add layers
dofile("view/BoardLayer.lua")
dofile("view/BeltLayer.lua")
dofile("view/GridLayer.lua")
dofile("view/SelectLayer.lua")
dofile("view/PlayerLayer.lua")
dofile("view/EffectsLayer.lua")
dofile("view/PlayerView.lua")

BoardViewConstants = {
    bg_src     = "img/game_bg.png",
    skew_board_y    = 200,

    --- nuke destruction movie properties
    window_default = "img/animations/window/window_1.jpg",

    nuke_property = {
        x = 393,
        y = 26,
        width  = 239,
        height = 122
    },

    nuke_images_src = {
        -- image and duration (ms) pairs to make movie
        {"img/animations/window/window_1.jpg", 100},
        {"img/animations/window/window_2.jpg", 100},
        {"img/animations/window/window_3.jpg", 100},
        {"img/animations/window/window_4.jpg", 100},
        {"img/animations/window/window_5.jpg", 200},
        {"img/animations/window/window_6.jpg", 200},
        {"img/animations/window/window_7.jpg", 200},
        {"img/animations/window/window_7_pause.jpg", 200},
        {"img/animations/window/window_8.jpg", 200},
        {"img/animations/window/window_9.jpg", 100},
        {"img/animations/window/window_10.jpg", 100},
        {"img/animations/window/window_11.jpg", 100},
        {"img/animations/window/window_12.jpg", 100},
        {"img/animations/window/window_13.jpg", 2000}
    },

    -- big stamp
    stamp_src = "img/animations/giant_stamp_cropped.png",

    -- arrow above player
    arrow_src = "img/focus/player_focus.png"
}

BoardView = class(function(self)

    self.rows = BarneyConstants.rows
    self.cols = BarneyConstants.cols

    self.board = Group()

    self.board.height = BarneyConstants.board_height
    self.board.width  = BarneyConstants.board_width

    self.clock = ClockView(self.board)
    
    -- add skew board
    self.skew_board = Group()
    self.skew_board.z = 1

    self.skew_board.height = BarneyConstants.board_height
    self.skew_board.width  = BarneyConstants.board_width

    self.skew_board.x_rotation = {15, 0, 0}
    self.skew_board.x = 130
    self.skew_board.y = BoardViewConstants.skew_board_y

    self.skew_layers = {} 

    local belt_top = 75
    local belt_width = BarneyConstants.cols * 102

    local center_belt = 155
    self.skew_layers.belt_layer   = BeltLayer(self.skew_board, 
                                              {z=1, 
                                               y=belt_top,
                                               x=center_belt,
                                               width=belt_width,
                                               height=500
                                              })

    self.skew_layers.effect_layer = EffectsLayer(self.skew_board, 
                                                 {z=2, 
                                                  x=center_belt,
                                                  y=belt_top})

    self.skew_layers.select_layer = SelectLayer(self.skew_board,  
                                                {z=3, 
                                                 x=center_belt,
                                                 y=belt_top})

    self.skew_layers.player_layer = PlayerLayer(self.skew_board,
                                                {z=4,
                                                 x=center_belt,
                                                 y=belt_top })

    self.board:add(self.skew_board)

    local bg = Images:load(BoardViewConstants.bg_src)
    self.board:add(bg)

    -- add player health on bottom

    self.player_view = {}
    for i=1,BarneyConstants.players do
        self.player_view[i] = PlayerView(i, self.skew_layers.player_layer, self.board)
    end

    self.iterations = 0

    -- add nuke window
    self.nuke_window_image = Images:load(BoardViewConstants.window_default, 
       BoardViewConstants.nuke_property    
    )

    self.board:add(self.nuke_window_image)

    screen:add(self.board)

    screen:show()
end)

function BoardView:updateBoard(old_board, new_row, callback)

    self.iterations = self.iterations + 1

    if 1 == self.iterations then
        for i,effect in pairs(new_row) do
            self.skew_layers.effect_layer:insert(effect.imageSrc, 1, i)
        end
        for i=1, BarneyConstants.rows - 1 do
            for j=1, BarneyConstants.cols do
                local effect = old_board:getEffectAt(i, j)
                self.skew_layers.effect_layer:insert(effect.imageSrc, i+1, j)
            end
        end
        callback()
    else
        -- get new effects
        local top_effects = {}

        for i,effect in pairs(new_row) do
            top_effects[i] = effect.imageSrc
        end

        -- rotate board down
        self.skew_layers.belt_layer:rotateRows()
        self.skew_layers.effect_layer:rotateRows(top_effects)
        self.skew_layers.player_layer:rotateRows(callback)
   end
end

function BoardView:clearFocus()
    self.skew_layers.select_layer:clearSelection()
end

function BoardView:setFocus(row, col)
    self.skew_layers.select_layer:selectPosition(row, col)
end

function BoardView:setPlayerHealth(player, health)
    return self.player_view[player]:setHealth(health)
end

function BoardView:movePlayer(player, old_row, old_col, new_row, new_col, callback)
    self.skew_layers.player_layer:movePlayer(player, old_row, old_col, new_row, new_col, callback)
end

function BoardView:clockTock()
    self.clock:tock()
end

function BoardView:clockReset()
    self.clock:reset()
end

function BoardView:draw()
    screen:show()
end

function BoardView:clear()
    screen:remove(self.board)   
end

function BoardView:setPlayerShield(player, number_of_shields)
    self.player_view[player]:setShield(number_of_shields)
end

function BoardView:doTeleAnimate(player, from_row, from_col, to_row, to_col, callback)
    local callbackCounter = Utils.makeCallbackCounter(2, callback)
    mediaplayer:play_sound("sounds/teleport.wav")
    self.skew_layers.player_layer:animateTransport(player, from_row, from_col, to_row, to_col, callbackCounter)
    self.skew_layers.effect_layer:dissolve(from_row, from_col, callbackCounter)
end

function BoardView:doWaterAnimate(targets,from_row,from_col, callback)
    local callbackCounter = Utils.makeCallbackCounter(2, callback)
    mediaplayer:play_sound("sounds/water.wav")
    self.skew_layers.player_layer:animateWater(targets, callbackCounter)
    self.skew_layers.effect_layer:dissolve(from_row, from_col, callbackCounter)
end

function BoardView:doAnimate(effect_name, attacking_player, attacked_players, callback)
    local player_layer = self.skew_layers.player_layer
    local effect_layer = self.skew_layers.effect_layer
    local attacking_row, attacking_col, attacking_name = attacking_player.y, attacking_player.x, attacking_player.number

    local attacked_players_cords = {}
    for i,player in ipairs(attacked_players) do
        attacked_players_cords[#attacked_players_cords+1] = {player.y, player.x}
    end

    if effect_name == "saw" then
        callback = Utils.makeCallbackCounter(2, callback)
        mediaplayer:play_sound("sounds/saw.wav")
        player_layer:animateSaw(attacking_row, attacking_col, callback)
    elseif effect_name == "laser" then
        callback = Utils.makeCallbackCounter(2, callback)
        player_layer:animateLaser(attacking_name, attacking_row, attacking_col, callback)
    elseif effect_name == "bigRed" then
        callback = Utils.makeCallbackCounter(2, callback)
        self:animateBigRed(callback)
    elseif effect_name == "surge" then
        callback = Utils.makeCallbackCounter(2, callback)
        mediaplayer:play_sound("sounds/surge.wav")
        assert(1 == #attacked_players_cords, "surge attacking more than one player")
        local attacked_row, attacked_col = attacked_players_cords[1][1], attacked_players_cords[1][2]
        player_layer:animateSurge(attacked_row, attacked_col, callback)
    end

    effect_layer:dissolve(attacking_player.y, attacking_player.x, callback)
end


function BoardView:animateKillPlayer(player, row, col)
    self.skew_layers.player_layer:animateKillPlayer(player, row, col)
    self.player_view[player]:flipID()
end

function BoardView:animateBigRed(callback)
    mediaplayer:play_sound("sounds/bigRed.wav")
    self.nuke_window_image:hide()
    
 --   mediaplayer:sound_stop()
 --   mediaplayer:play_sound("sounds/bigRed.wav")

    local BVC = BoardViewConstants
    Utils.makeMovie(BVC.nuke_images_src, BVC.nuke_property, self.board,
    function()
        self.nuke_window_image:show()
        callback()
    end):start()
end

function BoardView:animateStamp(effects_table, callback)
    local BVC = BoardViewConstants

    local function replaceBoard()
        local effect_layer = self.skew_layers.effect_layer

        effect_layer:clear()

        for i=1, BarneyConstants.rows do
            for j=1, BarneyConstants.cols do
                local effect = effects_table:getEffectAt(i, j)
                effect_layer:insert(effect.imageSrc, i, j)
            end
        end
    end

    local stamp_width,stamp_height = 1280,1280
    local scale_factor = 2
    local duration = 2000

    local large_center_x = (BarneyConstants.board_width-stamp_width)/2
    local small_center_x = (BarneyConstants.board_width-stamp_width/scale_factor)/2
    local large_center_y = (BarneyConstants.board_height-stamp_height)/2
    local small_center_y = (BarneyConstants.board_height-stamp_height/scale_factor)/2
    
    local stamp_image = Images:load(BVC.stamp_src, {
        y = large_center_y,
        x = large_center_x,
        z = 3
    })

    self.board:add(stamp_image)
    stamp_image:animate{
        duration = duration,
        scale =  {1/scale_factor,1/scale_factor},
        x = small_center_x,
        y = small_center_y,
        x_rotation = 12,
        on_completed = function ()
            mediaplayer:play_sound("sounds/stamp.wav")

            -- repopulate board
            replaceBoard()

            stamp_image:animate{
                x = large_center_x,
                y = large_center_y,
                x_rotation = 0,
                duration = duration,
                scale = {1, 1},
                on_completed = function ()
                    stamp_image:unparent()
                    callback()
                end
            }
        end
    }
    
end

function BoardView:showArrow()

    local BVC = BoardViewConstants

    local start_y = 470
    local end_y   = 500
    local x = 325

    local y_distance = end_y - start_y

    local arrow = Images:load(BVC.arrow_src, {
        x = x,
        y = start_y,
        z = 1
    })
    self.board:add(arrow)


    local duration = 3000
    local num_bounces = 4
    local switch_time = duration/num_bounces

    local timeline = Timeline{
        duration  = duration,
        on_new_frame = function(timer, elapsed, progress)

            -- on way down
            if elapsed % switch_time < (switch_time / 2) then
                arrow.y = start_y + y_distance*(progress/switch_time)
            -- on way up
            else
                arrow.y = end_y - y_distance*(progress/switch_time)
            end

        end,
        on_completed = function(timer)
            arrow:unparent()
        end
    }
    timeline:start()
end

