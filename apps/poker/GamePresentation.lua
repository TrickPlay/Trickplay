   -- -- getters/setters
   -- function ctrl.get_players(ctrl) return state:get_players() end
   -- function ctrl.get_sb_qty(ctrl) return state:get_sb_qty() end
   -- function ctrl.get_bb_qty(ctrl) return state:get_bb_qty() end
   -- function ctrl.get_dealer(ctrl) return state:get_dealer() end
   -- function ctrl.get_sb_p(ctrl) return state:get_sb_p() end
   -- function ctrl.get_bb_p(ctrl) return state:get_bb_p() end
   -- function ctrl.get_deck(ctrl) return state:get_deck() end


GamePresentation = Class(nil,
function(pres, ctrl)
   local ctrl = ctrl
   function pres.display_ui(pres)
      -- put sb, bb, dealer markers down, plus player chip stacks
      if not screen:find_child("dealerchip") then
         local dealerchip = Image{src = "assets/Chip_D.png", position = mdbl[ ctrl.get_dealer(ctrl) ], name="dealerchip"}
         local bbchip = Image{src = "assets/Chip_BB.png", position = mdbl[ ctrl.get_bb_p(ctrl) ], name="bbchip"}
         local sbchip = Image{src = "assets/Chip_SB.png", position = mdbl[ ctrl.get_sb_p(ctrl) ], name="sbchip"}
         screen:add(dealerchip, bbchip, sbchip)
      end
      
      -- maybe this? model.default_bet_locations[model.players[ctrl.get_dealer(ctrl)].table_position]
      
      for key, player in pairs(ctrl.get_players(ctrl)) do
         if not player.betChips then
            player.betChips = chipCollection()
            player.betChips.group.position = {model.default_bet_locations[player.table_position][1], model.default_bet_locations[player.table_position][2]-150}
            screen:add(player.betChips.group)
            player.betChips.group:raise_to_top()
         end
      end
      
   end

   function pres.finish_hand(pres)
   -- Just move
   --[[
   screen:find_child("dealerchip").position = mdbl[ ctrl.get_dealer(ctrl) ]
   screen:find_child("bbchip").position = mdbl[ ctrl.get_bb_p(ctrl) ]
   screen:find_child("sbchip").position = mdbl[ ctrl.get_sb_p(ctrl) ]
   --]]
   
   -- Animate chips
   screen:find_child("dealerchip"):animate{ position = mdbl[ ctrl.get_dealer(ctrl) ], duration = 400, mode="EASE_OUT_QUAD" }
   screen:find_child("bbchip"):animate{ position = mdbl[ ctrl.get_bb_p(ctrl) ], duration = 400, mode="EASE_OUT_QUAD" }
   screen:find_child("sbchip"):animate{ position = mdbl[ ctrl.get_sb_p(ctrl) ], duration = 400, mode="EASE_OUT_QUAD" }
   
 -- sb, bb, dealer data in ctrl are correct, u just gotta make the view reflect that
 -- move sb, bb, dealer chips to new locations
   end
end)