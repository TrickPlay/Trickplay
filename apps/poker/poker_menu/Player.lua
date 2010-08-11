Player = Class(function(player, ...)

        player.user = false
        player.row = 0
        player.col = 0
        player.money = 500
        
        player.makeChips = function(player)
                
                player.chips = chipStack()
                player.chips.group.position = {800, 800}
                screen:add(player.chips.group)
                
                while player.chips:count() < player.money do
                        self.stack:pushChip( Chip(10, Image{src = "pokerchip10.png"}) )
                        self.stack:convertUp()
                        self.stack:arrangeChips(15, 150)
                end
                
        end
    
        for k,v in pairs(args) do
                player[k] = v
        end

end)
