Player = Class(function(player, isHuman, ...)
   player.isHuman = isHuman
   player.user = false
   player.number = 0
   player.row = 0
   player.col = 0
   player.bet = model.bet.DEFAULT_BET
   player.money = 800 - player.bet
   player.position = false
   player.table_position = nil
   -- for k,v in pairs(args) do
   --    player[k] = v
   -- end
   
   function player:createMoneyChips()
      
      player.moneyChips = chipCollection()
      player.moneyChips.group.position = {player.position[1], player.position[2] - 170}
      player.moneyChips:set(player.money)
      player.moneyChips:arrange(55, 5)
      screen:add(player.moneyChips.group)
      
   end
   
   function player:createBetChips()
      
      player.betChips = chipCollection()
      player.betChips.group.position = {player.position[1], player.position[2] - 300}
      player.betChips:set(player.bet)
      player.betChips:arrange(55, 5)
      screen:add(player.betChips.group)
      
   end
   
--   player.status = PlayerStatusView(model, nil, player):initialize()

end)
