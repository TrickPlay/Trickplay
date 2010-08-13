--dofile("HandState.lua")
dofile("HandPresentation.lua")

local Rounds = {
   HOLE=1,
   FLOP=2,
   TURN=3,
   RIVER=4,
   DONE=5
}
HandControl = Class(nil,
function(ctrl, game_ctrl, ...)

   --local state = HandState(ctrl)
   local pres = HandPresentation(ctrl)
   local game_ctrl = game_ctrl or error("no game_ctrl",2)

   local hand_pipeline = {}
   local orig_hand_pipeline = {
      function(ctrl) return ctrl:deal(Rounds.HOLE) end,
      function(ctrl) return ctrl:bet(Rounds.HOLE) end,
      function(ctrl) return ctrl:deal(Rounds.FLOP) end,
      function(ctrl) return ctrl:bet(Rounds.FLOP) end,
      function(ctrl) return ctrl:deal(Rounds.TURN) end,
      function(ctrl) return ctrl:bet(Rounds.TURN) end,
      function(ctrl) return ctrl:deal(Rounds.RIVER) end,
      function(ctrl) return ctrl:bet(Rounds.RIVER) end,
      function(ctrl) return ctrl:showdown() end
   }
   -- an initialized hand state looks like this:
   -- {
   --    -- first three cards are flop, then turn, then river
   --    comm_cards={card1,card2,card3,card4,card5},
   --    remaining_players={player1, player2, player3, player4},
   --    stacks={},
   --    dealer=2,
   --    small_blind=3,
   --    big_blind=4,
   --    sb_qty=1,
   --    bb_qty=2,
   --

   --    events={}
   -- }
   -- local hand_state = {}

   -- Hand variables
   local community_cards
   local hole_cards
   local player_bets
   local pot
   local action

   local players
   local sb_qty
   local bb_qty
   local dealer
   local sb_p
   local bb_p
   local deck

   function ctrl:get_community_cards() return community_cards end
   function ctrl:get_hole_cards() return hole_cards end
   function ctrl:get_player_bets() return player_bets end
   function ctrl:get_pot() return pot end
   function ctrl:get_action() return action end
   function ctrl:get_players() return players end
   function ctrl:get_sb_qty() return sb_qty end
   function ctrl:get_bb_qty() return bb_qty end
   function ctrl:get_sb_p() return sb_p end
   function ctrl:get_bb_p() return bb_p end
   function ctrl:get_deck() return deck end

   -- public functions
   function ctrl.initialize(ctrl)
      players = game_ctrl:get_players()
      sb_qty = game_ctrl:get_sb_qty()
      bb_qty = game_ctrl:get_bb_qty()
      dealer = game_ctrl:get_dealer()
      sb_p = game_ctrl:get_sb_p()
      bb_p = game_ctrl:get_bb_p()
      deck = game_ctrl:get_deck()

      -- initialize bet in front of each player
      player_bets = {}
      for _,player in ipairs(players) do
         player_bets[player] = 0
      end
      pot = 0

      -- initialize small blind, big blind bets
      player_bets[players[sb_p]] = sb_qty
      players[sb_p].money = players[sb_p].money - sb_qty
      player_bets[players[bb_p]] = bb_qty
      players[bb_p].money = players[bb_p].money - bb_qty

      -- initialize cards for each player
      deck:reset()
      deck:shuffle()
      hole_cards = {}
      for _,player in ipairs(players) do
         hole_cards[player] = deck:deal(2)
      end
      community_cards = deck:deal(5)

      hand_pipeline = {}
      for _,stage in ipairs(orig_hand_pipeline) do
         table.insert(hand_pipeline, stage)
      end

      pres:display_hand()

      enable_event_listener(Events.TIMER, 1)
   end


   -- Table of ui deal animations
   local deal_LUT = {
      [Rounds.HOLE]=function(pres) pres:deal_hole() end,
      [Rounds.FLOP]=function(pres) pres:deal_flop() end,
      [Rounds.TURN]=function(pres) pres:deal_turn() end,
      [Rounds.RIVER]=function(pres) pres:deal_river() end
   }
   function ctrl.deal(ctrl, round)
      deal_LUT[round](pres)
      enable_event_listener(Events.TIMER, .5)
      return true
   end

   local bet_LUT = {
      [Rounds.HOLE]=
         function(pres)
--            pres:deal_hole()
         end,
      [Rounds.FLOP]=
         function(pres)
--            pres:deal_flop()
         end,
      [Rounds.TURN]=
         function(pres)
--            pres:deal_turn()
         end,
      [Rounds.RIVER]=
         function(pres)
--            pres:deal_river()
         end
   }
   function ctrl.bet(ctrl, round)
      bet_LUT[round](pres)
      enable_event_listener(Events.TIMER, .1)
      return true
   end

   function ctrl.showdown(ctrl)
      enable_event_listener(Events.TIMER, .5)
      return true
   end

   function ctrl.on_event(ctrl)
      print(#hand_pipeline, "entries left in hand_pipeline")
      if #hand_pipeline > 0 then
         local next_action = hand_pipeline[1]
         local result = next_action(ctrl)
         if result then table.remove(hand_pipeline, 1) end
      end

      if #hand_pipeline > 0 then
         return false
      else
         return true
      end
   end

   function ctrl.cleanup(ctrl)
      pres:clear_ui()
      return true
   end
end)