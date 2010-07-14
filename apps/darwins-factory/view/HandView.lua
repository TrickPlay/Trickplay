function MenuView:RoboToss()

    local hand_images = {
        {"img/splash/handanimate/splash-animation_1.png",4000},
        {"img/splash/handanimate/splash-animation_2.png",250},
        {"img/splash/handanimate/splash-animation_1.png",200},
        {"img/splash/handanimate/splash-animation_2.png",200},
        {"img/splash/handanimate/splash-animation_1.png",150},
        {"img/splash/handanimate/splash-animation_2.png",150},
        {"img/splash/handanimate/splash-animation_1.png",100},
        {"img/splash/handanimate/splash-animation_2.png",100},
        {"img/splash/handanimate/splash-animation_1.png",100},
        {"img/splash/handanimate/splash-animation_2.png",100},
        {"img/splash/handanimate/splash-animation_3.png",100},
        {"img/splash/handanimate/splash-animation_4.png",100},
        {"img/splash/handanimate/splash-animation_5.png",100},
        {"img/splash/handanimate/splash-animation_6.png",100},
        {"img/splash/handanimate/splash-animation_7.png",100},
        {"img/splash/handanimate/splash-animation_8.png",100},
        {"img/splash/handanimate/splash-animation_9.png",100},
        {"img/splash/handanimate/splash-animation_10.png",100},
        {"img/splash/handanimate/splash-animation_11.png",100},
        {"img/splash/handanimate/splash-animation_12.png",100},
        {"img/splash/handanimate/splash-animation_13.png",100},
        {"img/splash/handanimate/splash-animation_14.png",100},
        {"img/splash/handanimate/splash-animation_15.png",100},
        {"img/splash/handanimate/splash-animation_16.png",100},
        {"img/splash/handanimate/splash-animation_17.png",100},
        {"img/splash/handanimate/splash-animation_18.png",100},
        {"img/splash/handanimate/splash-animation_19.png",2000}
    }
    local hand_properties = {
        x = -10,
        y = 175,
        z = MenuViewConstants.top_z + 1,
        width = 1174,
        height = 550
    }
    Utils.makeMovie(hand_images, hand_properties, self.group):start()
end



function Player:PlayerWins()
   local center_pos = {row = 4, col = 7}
   local curr_pos =   {row = self.y,
                       col = self.x}
   local pl = boardView.skew_layers.player_layer

   local function hand()
        local winner = Group()
        local hand_img = Images:load("img/splash/handanimate_endgame.png")
        local center = {x=-70,y=-350}
        local winner_bot = pl:get(center_pos.row, center_pos.col)
        local hand_start = {x = winner_bot.x + center.x, y=-pl.grid_height * pl.num_rotations - 1000}

        pl.group:add(winner)
        winner:add(hand_img)
        winner.x = hand_start.x
        winner.y = hand_start.y

        local function lift()
            winner_bot:unparent()
            winner:add(winner_bot)
            winner_bot.x = 70
            winner_bot.y = 350
            winner:animate{duration=3000,y=hand_start.y}
        end
        winner:animate{duration=3000,y=winner_bot.y+center.y,
                                                on_completed = lift}

   end

   pl:movePlayer(self.number, curr_pos.row, curr_pos.col, 
                    center_pos.row, center_pos.col, hand)
end
