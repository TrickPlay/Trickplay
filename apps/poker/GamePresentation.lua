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
   
   -- LOCAL FUNCTIONS
   local function create_pot_chips()
      if not model.potchips then
         model.potchips = chipCollection()
         model.potchips.group.position = model.default_bet_locations.POT
         screen:add(model.potchips.group)
         model.potchips:set(0)
         model.potchips.group:raise_to_top()
      else
         local pot = model.potchips
         pot.group:animate{
            opacity=0,
            duration=300,
            on_completed = function() screen:remove(pot) end
         }
         model.potchips:set(0)
         model.potchips = nil
         
         create_pot_chips()
      end
   end
   
   -- GAME FLOW
   function pres.display_ui(pres)
      -- put sb, bb, dealer markers down, plus player chip stacks
      if not model.dealerchip then
         model.dealerchip = Image{
            src = "assets/Chip_D.png",
            position = MSCL[ model.players[ ctrl:get_dealer() ].table_position ],
            name="dealerchip"
         }
         model.bbchip = Image{
            src = "assets/Chip_BB.png",
            position = MSCL[ model.players[ ctrl:get_bb_p() ].table_position ],
            name="bbchip"
         }
         model.sbchip = Image{
            src = "assets/Chip_SB.png",
            position = MSCL[ model.players[ ctrl:get_sb_p() ].table_position ],
            name="sbchip"
         }
         screen:add(model.dealerchip, model.bbchip, model.sbchip)
      end
      
      -- add the pot chips
      create_pot_chips()
      
      if not model.deck then
         model.deck = ctrl:get_deck()
         for i=#model.deck.cards, #model.deck.cards-7, -1 do
            local g = model.deck.cards[i].group
            g.position = MCL.DECK
            g.z_rotation={math.random(-5, 5), 0, 0}
            screen:add(g)
         end
      end
      
   end

   function pres.finish_hand(pres)

      -- Animate chips
      model.dealerchip:animate{ position = MSCL[ model.players[ctrl:get_dealer()].table_position ], duration = 400, mode="EASE_OUT_QUAD" }
      model.bbchip:animate{ position = MSCL[ model.players[ctrl:get_bb_p()].table_position ], duration = 400, mode="EASE_OUT_QUAD" }
      model.sbchip:animate{ position = MSCL[ model.players[ctrl:get_sb_p()].table_position ], duration = 400, mode="EASE_OUT_QUAD" }
      
      create_pot_chips()
      
      for _, card in ipairs(model.deck.cards) do
         card.group.opacity = 255
      end
      
      -- Reset deck
      for i=#model.deck.cards, #model.deck.cards-7, -1 do
         local g = model.deck.cards[i].group
         g.position = MCL.DECK
         g.z_rotation={math.random(-5, 5), 0, 0}
         if g.parent ~= screen then screen:add(g) end
      end
      
   end

   -- called when either human player no longer detected, or one player left.
   function pres:return_to_main_menu()
   end

   -- called when sb_qty and bb_qty updated
   function pres:update_blinds()
   end
end)