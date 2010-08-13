-- ctrl:get_community_cards()
-- ctrl:get_hole_cards()
-- ctrl:get_player_bets()
-- ctrl:get_pot()
-- ctrl:get_action()
-- ctrl:get_players()
-- ctrl:get_sb_qty()
-- ctrl:get_bb_qty()
-- ctrl:get_sb_p()
-- ctrl:get_bb_p()
-- ctrl:get_deck()

HandPresentation = Class(nil,
function(pres, ctrl)
   local ctrl = ctrl
   function pres.display_hand(pres)
   end

   function pres.deal_hole(pres)
      -- just make them all appear in front of the appropriate players
      local text_str = "Dealing hole cards"
      local text = Text{
         font="Sans 40px",
         color="FFFFFF",
         text=text_str,
         position={50,50}
      }
      screen:add(text)
   end
   function pres.deal_flop(pres)
      local text_str = "Dealing flop cards"
      local text = Text{
         font="Sans 40px",
         color="FFFFFF",
         text=text_str,
         position={120,120}
      }
      screen:add(text)
   end
   function pres.deal_turn(pres)
      local text_str = "Dealing turn card"
      local text = Text{
         font="Sans 40px",
         color="FFFFFF",
         text=text_str,
         position={200,200}
      }
      screen:add(text)
   end
   function pres.deal_river(pres)
      local text_str = "Dealing river card"
      local text = Text{
         font="Sans 40px",
         color="FFFFFF",
         text=text_str,
         position={300,300}
      }
      screen:add(text)
   end
end)