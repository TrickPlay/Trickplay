if not Card then dofile("Cards.lua") end

GameState = Class(nil,function(state, ctrl)

    math.randomseed(os.time())
    local ctrl = ctrl
    -- private variables
    -- blind sizes
    local sb_qty = nil
    local bb_qty = nil
    local endowment = nil

    local players = nil
    local removed_players = nil
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
    function state:get_players() return players end
    function state:get_sb_qty() return sb_qty end
    function state:get_bb_qty() return bb_qty end
    function state:get_dealer() return dealer end
    function state:get_sb_p() return sb_p end
    function state:get_bb_p() return bb_p end
    function state:get_deck() return deck end

    function state:move_blinds()
        dealer = (dealer % #players) + 1
        sb_p, bb_p = calc_blind_pos()
    end

    -- public functions
    function state:initialize(args)
        sb_qty = args.sb or error("Assign small blind!", 2)
        bb_qty = args.bb or error("Assign big blind!", 2)
        -- since player may select dogs 1, 2 and 6 (for example) need to compress the
        -- table to make stuff easier
        if not args.players then error("No players !", 2) end
        players = args.players
        randomness = args.randomness or 0
        for _,player in ipairs(players) do
            player.money = player.endowment + math.random(-randomness, randomness)
        end
        removed_players = {}

        dealer = math.random(#players)
        print("Dealer randomly selected to be " .. tostring(dealer))
        sb_p, bb_p = calc_blind_pos()
        print("small blind set to player " ..tostring(sb_p)..", "..
            "big blind set to player " ..tostring(bb_p))
        deck = Deck()
        deck:shuffle()
        print("Deck initialized and shuffled")
    end

    function state:increase_blinds()
        sb_qty = sb_qty * 2
        bb_qty = bb_qty * 2
    end

    function state:remove_player(removed_player)
        table.insert(removed_players, removed_player)
    end

    function state:reset()
        for k,player in pairs(players) do
            player:dealloc()
            players[k] = nil
        end

        for k,player in pairs(removed_players) do
            player:dealloc()
        end
        removed_players = nil
    end

end)
