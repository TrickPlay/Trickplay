Player = Class(function(player, ...)

        player.user = false
        player.number = 0
        player.row = 0
        player.col = 0
        player.bet = 0 --model.bet.DEFAULT_BET
        player.money = 250
        player.position = {0, 0}
    
        for k,v in pairs(args) do
                player[k] = v
        end
        
        function player:makeChips()
                
                player.chips = chipStack()
                player.chips.group.position = {player.position[1], player.position[2] - 170}
                screen:add(player.chips.group)
                
                --[[while player.chips:count() <= player.money do
                        player.chips:pushChip( Chip(10, Image{src = "pokerchip10.png"}) )
                        player.chips:convertUp()
                end]]
                
                player.chips:setChips(player.money)
                
                player.chips:arrangeChips(15, 150)
                
        end
        
        player.status = PlayerStatusView(model, nil, player):initialize()

end)
