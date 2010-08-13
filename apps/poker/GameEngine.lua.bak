local Rounds = {
   HOLE=1,
   FLOP=2,
   TURN=3,
   RIVER=4,
   DONE=5
}

GameEngine = Class(nil,
function(self, players, ...)
   math.randomseed(os.time)

   -- private variables
   local small_blind = nil
   local big_blind = nil

   local players = players
   local dealer = nil
   -- who are the blinds?
   local sb_p = nil
   local bb_p = nil
   local deck = nil

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

   -- private functions
   local function blind_positions()
      assert(dealer)
      assert(#players > 1)
      local sb, bb
      if #players == 2 then
         sb = dealer
         bb = (sb % #players) + 1
      else
         sb = (dealer % #players) + 1
         bb = (sb % #players) + 1
      end

      return sb, bb
   end

   -- public functions
   function self:initialize_game(args)
      small_blind = args.small_blind
      big_blind = args.big_blind

      dealer = math.random(#players)
      print("Dealer randomly selected to be " .. tostring(dealer))
      sb_p, bb_p = blind_positions()
      print("Small blind set to player " .. tostring(small_blind) .. ", " ..
         "big blind set to player " .. tostring(big_blind))
      deck = Deck()
      deck:shuffle()
      print("Deck initialized")
   end

   function self:initialize_hand()
      -- 5 players
      -- early middle late sb bb
      -- 4 players
      -- e l sb bb
      -- 3 players
      -- e sb bb
      -- 2 players
      -- TODO: take into account player position at table and add LUT logic

      -- initialize bet in front of each player
      for _,player in ipairs(players) do
         player_bets[player] = 0
      end
      pot = 0

      -- initialize small blind, big blind bets
      player_bets[players[sb_p]] = small_blind
      player_bets[players[bb_p]] = big_blind

      -- initialize cards for each player
      for _,player in ipairs(players) do
         hole_cards[player] = deck:deal(2)
      end
      community_cards = deck:deal(5)
   end


   function self:hole_deal()
      -- animation junk goes here.
   end

   function self:re_enter()
   end
   
   function self:bet_helper()
      bet_helper()
   end

   function self:hole_betting()
      -- assigns the action to the player under the gun
      action = (bb_p%#players)+1

      if player.isHuman() then
         bet_helper()
      end
      bet_helper()
      -- while all players haven't had a turn yet and not all player
      -- bets are equal
      self:hole_betting()
   end
end