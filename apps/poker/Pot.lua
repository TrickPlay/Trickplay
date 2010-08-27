Pot = Class(nil,
function(pot,...)
   local players

   pot.ctrbs = {}
   for _,player in ipairs(players) do
      pot.ctrbs[player] = 0
   end
   -- when a player folds, check all pots to see if he's in them, and
   -- then remove him from the pot player tables. then figure out if
   -- you need to merge pots

   function pot:get_max_ctrb()
      local min_money = players[1].money+pot.ctrbs[players[1]]
      for _,player in ipairs(players) do
         local cash = player.money + pot.ctrbs[player]
         if cash < min_money then
            cash = min_money
            min_players = {player}
         elseif cash == min_money then
            table.insert(min_players,player)
         end
      end
   end
end)

Betting = Class(nil,
function(self,...)
   local pots

   function self:initialize(in_players)
      pots = {Pot(in_players)} -- just the main pot.
   end

   function self:add_bet(player, bet)
      local lbet = bet -- local bet var

      -- put money in bets
      for _, pot in ipairs(pots) do
         new_ctrb, new_bet = pot.ctrbs[player] + bet, 0
         max_ctrb = pot:get_max_ctrb()
         if new_ctrb > max_ctrb then
            new_ctrb, new_bet = max_ctrb, new_ctrb-max_ctrb
         end
         pot.ctrbs[player], lbet = new_ctrb, new_bet
      end

      -- still some money to bet, let's create some side pots
      while lbet > 0 do
         -- find all players who can afford to contest a new pot
         
      end
   end

   ---
   -- Gets the sizes of all pots as an array of positive integers, in
   -- order of pots contested by the most players to the pots
   -- contested by the least
   function self:get_pots()
      return pots
   end
end)