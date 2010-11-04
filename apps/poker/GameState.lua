dofile("Cards.lua")
GameState = Class(nil,function(state, ctrl)
   math.randomseed(os.time())
   local ctrl = ctrl
   -- private variables
   -- blind sizes
   local sb_qty = nil
   local bb_qty = nil
   local endowment = nil

   local players = players
   -- index of dealer
   local dealer = nil
   -- who are the blinds? sb_p and bb_p are the indices into players
   -- of the small blind and big blind players
   local sb_p = nil
   local bb_p = nil
   local deck = nil
   local randomness = nil

   -- private functions
   local function calc_blind_pos()
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

      print("new sb position:", sb, "new bb position:", bb)
      return sb, bb
   end

   -- getters/setters
   function state.get_players(state) return players end
   function state.get_sb_qty(state) return sb_qty end
   function state.get_bb_qty(state) return bb_qty end
   function state.get_dealer(state) return dealer end
   function state.get_sb_p(state) return sb_p end
   function state.get_bb_p(state) return bb_p end
   function state.get_deck(state) return deck end

   function state:move_blinds()
      dealer = (dealer % #players) + 1
      sb_p, bb_p = calc_blind_pos()
   end

   -- public functions
   function state.initialize(state, args)
      sb_qty = args.sb or error("Assign small blind!", 2)
      bb_qty = args.bb or error("Assign big blind!", 2)
      endowment = args.endowment or error("No initial endowment", 2)
      players = args.players or error("No players!", 2)
      randomness = args.randomness or 0
      for _,player in ipairs(players) do
         player.money = endowment + math.random(-randomness, randomness)
      end

      dealer = math.random(#players)
      print("Dealer randomly selected to be " .. tostring(dealer))
      sb_p, bb_p = calc_blind_pos()
      print("small blind set to player " ..tostring(sb_p)..", "..
         "big blind set to player " ..tostring(bb_p))
      deck = Deck()
      deck:shuffle()
      print("Deck initialized and shuffled")
   end

   function state.increase_blinds(state)
      sb_qty = sb_qty * 2
      bb_qty = bb_qty * 2
   end
end)
