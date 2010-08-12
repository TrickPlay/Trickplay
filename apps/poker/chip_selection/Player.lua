Player = Class(function(player, ...)

    player.user = false
    player.row = 0
    player.col = 0

    for k,v in pairs(args) do
        player[k] = v
    end

end)
