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
      if not model.dealerchip then
         model.dealerchip = Image{src = "assets/Chip_D.png", position = mdbl[ model.players[ ctrl:get_dealer() ].table_position ], name="dealerchip"}
         model.bbchip = Image{src = "assets/Chip_BB.png", position = mdbl[ model.players[ ctrl:get_bb_p() ].table_position ], name="bbchip"}
         model.sbchip = Image{src = "assets/Chip_SB.png", position = mdbl[ model.players[ ctrl:get_sb_p() ].table_position ], name="sbchip"}
         screen:add(model.dealerchip, model.bbchip, model.sbchip)
      end
      
      -- add the pot chips
      if not model.potchips then
         model.potchips = chipCollection()
         model.potchips.group.position = model.default_bet_locations.POT
         screen:add(model.potchips.group)
         model.potchips:set(0)
         model.potchips.group:raise_to_top()
      end
      
      if not model.deck then
         model.deck = ctrl:get_deck()
      end
      
   end

   function pres.finish_hand(pres)

      -- Animate chips
      model.dealerchip:animate{ position = mdbl[ ctrl.get_dealer(ctrl) ], duration = 400, mode="EASE_OUT_QUAD" }
      model.bbchip:animate{ position = mdbl[ ctrl.get_bb_p(ctrl) ], duration = 400, mode="EASE_OUT_QUAD" }
      model.sbchip:animate{ position = mdbl[ ctrl.get_sb_p(ctrl) ], duration = 400, mode="EASE_OUT_QUAD" }
      model.potchips:set(0)
   
 -- sb, bb, dealer data in ctrl are correct, u just gotta make the view reflect that
 -- move sb, bb, dealer chips to new locations
   end
end)