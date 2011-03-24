STATUS_CHIP_POSITIONS = {
    [1] = {500, 820},
    [2] = {320, 520},
    [3] = {700, 310},
    [4] = {1185, 310},
    [5] = {1550, 520},
    [6] = {1290, 820}
}

GamePresentation = Class(nil,
function(pres, ctrl)
    local ctrl = ctrl

-------------- Private Variables ----------------

    local info_bb, info_bb_t, info_sb, info_sb_t, info_grp
    local dealer_chip, bb_chip, sb_chip--, pot_chips

-------------- Some View stuff ------------------

    pres.ui = assetman:create_group({})

    assetman:load_image("assets/table.jpg", "Table")
    assetman:load_image("assets/UI/new/table-marks.png", "TableText")
    local table = assetman:get_clone("Table")
    local table_text = assetman:get_clone("TableText", {
        position = {674, 445}
    })
    table_text:hide()
    pres.ui:add(table, table_text)
    screen:add(pres.ui)
    
   
    -- LOCAL FUNCTIONS
    --[[
    local function create_pot_chips()
        if not pot_chips then
            pot_chips = ChipCollection("POT")
            screen:add(pot_chips.group)
            pot_chips:set(0)
            pot_chips.group:raise_to_top()
        else
            pot_chips:dealloc()
            pot_chips = nil
            create_pot_chips()
        end
    end
    --]]
   
    -- GAME FLOW
    assetman:load_image("assets/Chip_D.png", "dealer_chip")
    assetman:load_image("assets/Chip_BB.png", "bb_chip")
    assetman:load_image("assets/Chip_SB.png", "sb_chip")
    function pres:display_ui()

        table_text:show()

        -- put sb, bb, dealer markers down, plus player chip stacks
        if not dealer_chip then
            local players = ctrl:get_players()
            local SCP = STATUS_CHIP_POSITIONS
            dealer_chip = assetman:get_clone("dealer_chip",
                {position = SCP[players[ctrl:get_dealer()].dog_number]})
            bb_chip = assetman:get_clone("bb_chip",
                {position = SCP[players[ctrl:get_bb_p()].dog_number]})
            sb_chip = assetman:get_clone("sb_chip",
                {position = SCP[players[ctrl:get_sb_p()].dog_number]})
            screen:add(dealer_chip, bb_chip, sb_chip)
        end
      
        -- add the pot chips
        --create_pot_chips()
      
        if not deck then
            deck = ctrl:get_deck()
            for i = #deck.cards,#deck.cards-7,-1 do
                local g = deck.cards[i].group
                g.position = CARD_LOCATIONS.DECK
                g.z_rotation={math.random(-5, 5), 0, 0}
                screen:add(g)
            end
        end
      
    end

    function pres:finish_hand()
        local SCP = STATUS_CHIP_POSITIONS
        local players = ctrl:get_players()
        -- Animate chips
        dealer_chip:animate{
            position = SCP[players[ctrl:get_dealer()].dog_number],
            duration = 400,
            mode="EASE_OUT_QUAD"
        }
        bb_chip:animate{
            position = SCP[players[ctrl:get_bb_p()].dog_number],
            duration = 400,
            mode="EASE_OUT_QUAD"
        }
        sb_chip:animate{
            position = SCP[players[ctrl:get_sb_p()].dog_number],
            duration = 400,
            mode="EASE_OUT_QUAD"
        }
      
        --create_pot_chips()
      
        for _, card in ipairs(deck.cards) do
            card.group.opacity = 255
        end
      
        -- Reset deck
        for i = #deck.cards,#deck.cards-7,-1 do
            local g = deck.cards[i].group
            g.position = CARD_LOCATIONS.DECK
            g.z_rotation = {math.random(-5, 5), 0, 0}
            if g.parent then g:unparent() end
            screen:add(g)
        end
      
    end

    -- Load up the win/lose stuff for good measure
    assetman:load_image("assets/outcome_new/winner.png", "Win")
    assetman:load_image("assets/outcome_new/loser.png", "Lose")
    -- called when either human player no longer detected, or one player left.
    function pres:return_to_main_menu(human_won, reset)
        
        for _,player in ipairs(ctrl:get_players()) do
            if player.status then player.status:hide() end
            if player.bet_chips then
                player.bet_chips:dealloc()
                player.bet_chips = nil
            end
        end

        for _,card in ipairs(deck.cards) do
            card.group:unparent()
        end
        -- delete blind info from lower left-hand corner
        info_bb:dealloc()
        info_bb = nil
        info_bb_t:dealloc()
        info_bb_t = nil
        info_sb:dealloc()
        info_sb = nil
        info_sb_t:dealloc()
        info_sb_t = nil
        info_grp:dealloc()
        info_grp = nil
        -- get the status chips off da grid yo
        dealer_chip:dealloc()
        dealer_chip = nil
        bb_chip:dealloc()
        bb_chip = nil
        sb_chip:dealloc()
        sb_chip = nil
        --[[
        pot_chips:dealloc()
        pot_chips = nil
        --]]
        -- hide the text that says where to lay down the cards
        table_text:hide()
        if not reset then 
            local r = assetman:create_rect{
                w = 1920, h = 1080,
                opacity = 0, color = "000000"
            }
            screen:add(r)
            local m
            if human_won then
                m = assetman:get_clone("Win")
            else
                m = assetman:get_clone("Lose")
            end
            m.anchor_point = {m.w/2, m.h/2}
            m.position = {screen.w/2, screen.h/2}
            screen:add(m)
      
            Popup:new{group = r, time = 5000}
            Popup:new{group = m, time = 5000}
        end
    end

    -- called when sb_qty and bb_qty updated
    function pres:update_blinds()
        if not info_grp then
            info_bb = assetman:get_clone("bb_chip")
            info_bb_t = assetman:create_text{
                position = {60, 5},
                text = tostring(ctrl:get_bb_qty()),
                name = "big_blind_info_text",
                color="FFFFFF",
                font = PLAYER_NAME_FONT
            }
            info_sb = assetman:get_clone("sb_chip", {y = 30})
            info_sb_t = assetman:create_text{
                position = {60, 35},
                text = tostring(ctrl:get_sb_qty()),
                name = "small_blind_info_text",
                color = "FFFFFF",
                font = PLAYER_NAME_FONT
            }
            info_grp = assetman:create_group{
                children = {info_bb, info_sb, info_bb_t, info_sb_t},
                position = {15, 1000},
                name = "info_grp"
            }
            screen:add(info_grp)
        else
            info_bb_t.text = ctrl:get_bb_qty()
            info_sb_t.text = ctrl:get_sb_qty()
        end
        info_grp.opacity = 255
    end

end)
