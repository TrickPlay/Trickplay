AI = Class(Player, function(ai, ...)

    if(math.random(2) == 2) then
        ai.play_style = "tight"
    else
        ai.play_style = "loose"
    end

    for k,v in pairs(args) do
        player[k] = v
    end

    

    function self:first_move(hand)
        local card1 = hand[1]
        local card2 = hand[2]
        
        --sort the cards, higher card first
        if(card1.rank.num > card2.rank.num) then
            card1, card2 = card2, card1
        end



    end

end)
