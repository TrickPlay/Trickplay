Player = Class(function(player, ...)

   player.user = false
   player.number = 0
   player.row = 0
   player.col = 0
   player.bet = model.bet.DEFAULT_BET
   player.money = 800
   player.position = {0, 0}
   player.table_position = nil
   
   for k,v in pairs(args) do
      player[k] = v
   end
   
   function player:makeChips()
      
      player.chips = chipCollection()
      player.chips.group.position = {player.position[1], player.position[2] - 170}
      player.chips:set(player.money)
      player.chips:arrange(55, 5)
      screen:add(player.chips.group)
      
   end
   
   player.status = PlayerStatusView(model, nil, player):initialize()

end)
