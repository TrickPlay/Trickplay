local Rounds = {
   HOLE=1,
   FLOP=2,
   TURN=3,
   RIVER=4
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
   local small_blind_player = nil
   local big_blind_player = nil

   -- an initialized hand state looks like this:
   {
      -- first three cards are flop, then turn, then river
      comm_cards={card1,card2,card3,card4,card5},
      remaining_players={player1, player2, player3, player4},
      dealer=2,
      small_blind=3,
      big_blind=4,
      sb_qty=1,
      bb_qty=2,

      events={}
   }
   local hand_state = {}

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
      small_blind_player, big_blind_player = blind_positions()
      print("Small blind set to player " .. tostring(small_blind) .. ", " ..
         "big blind set to player " .. tostring(big_blind))
   end
end