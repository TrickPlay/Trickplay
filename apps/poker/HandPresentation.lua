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
      local hole_cards = ctrl:get_hole_cards()

      -- tell me if you want this to be more like
      -- for i, hole in ipairs(hole_cards)
      y=0
      for player,hole in pairs(hole_cards) do
         local card1, card2 = unpack(hole)
         local text1 = Text{
            font="Sans 40px",
            color="FFFFFF",
            text=card1.abbv,
            position={50,y}
         }
         local text2 = Text{
            font="Sans 40px",
            color="FFFFFF",
            text=card2.abbv,
            position={50,y+50}
         }
         screen:add(text1, text2)
         y = y + 150
      end
      local text_str = "Dealing hole cards"
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

   function pres.clear_ui(pres)
   end
end)