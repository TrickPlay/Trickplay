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
   end

   function pres.finish_hand(pres)
      -- sb, bb, dealer data in ctrl are correct, u just gotta make the view reflect that
      -- move sb, bb, dealer chips to new locations
   end
end)