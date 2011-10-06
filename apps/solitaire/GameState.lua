GameState = Class(nil,function(state, ctrl)
    math.randomseed(os.time())
    local ctrl = ctrl
    

    game_timer = {
        start = 0,
        current = 0,
        prev = 0,
        stop = false,
        text = Text{
            text = "0:00",
            position = {1070, 301},
            font = MENU_FONT_BOLD,
            color = Colors.WHITE
        }
    }
    settings.saved_time = settings.time
    function game_timer:update()
        local min = math.floor(self.prev/60)
        local sec = self.prev - min*60
        if sec < 10 then
            self.text.text = tostring(min)..":0"..tostring(sec)
        else
            self.text.text = tostring(min)..":"..tostring(sec)
        end

        settings.time = self.prev
    end
    --[[
        Private Variables
    --]]
    local deck = nil
    -- extra cards to choose from, 1 or 3 at a time depending on rules
    local waste = nil
    -- places you want to put your cards to win, starts with 'Ace' cards
    local foundations = nil
    -- main game on bottom
    local tableau = nil
    -- the cards left over that can be drawn into the waste
    local stock = nil
    -- cards go here after wasted to be recycled
    local backup_stock = nil
    -- the game grid
    local grid = nil
    -- saved game
    local saved_game = settings.saved_game
    -- the collection of the current cards the user is moving across the game
    local collection = nil
    -- the focus
    local selector = nil
    -- stock deals 3 cards if true, 1 if false
    local deal_3 = true
    if type(settings.deal_3) == "boolean" then deal_3 = settings.deal_3 end
    -- whether or not to give the option to auto finish
    local auto_finish = true
    if type(settings.auto_finish) == "boolean" then auto_finish = settings.auto_finish end
    -- the last move
    local last_move = {}
    -- true if the game has not started yet
    local new_game = true
    if type(settings.new_game) == "boolean" then new_game = settings.new_game end
    -- true if the game was won and the auto-complete dialog already showed
    local game_won = false
    -- true if the game is won and the player must redeal to do anything
    local must_restart = false
    if type(settings.must_restart) == "boolean" then must_restart = settings.must_restart end
    -- true if a card flipped after the child card was relocated
    local undo_parent_card_was_flipped = false

    -- getters/setters
    function state:get_deck() return deck end
    function state:get_waste() return waste end
    function state:get_foundations() return foundations end
    function state:get_tableau() return tableau end
    function state:get_stock() return stock end
    function state:get_backup_stock() return backup_stock end
    function state:get_grid() return grid end
    function state:get_collection() return collection end
    function state:get_deal_3() return deal_3 end
    function state:get_auto_finish() return auto_finish end
    function state:get_last_move() return last_move end
    function state:is_new_game() return new_game end
    function state:must_restart() return must_restart end
    function state:game_won() return game_won end
    function state:set_undo_to_flip() undo_parent_card_was_flipped = true end
    function state:set_undo_to_not_flip() undo_parent_card_was_flipped = false end

    function state:change_deal_3()
        if new_game then
            deal_3 = not deal_3
            settings.deal_3 = deal_3
        end
    end
    function state:change_auto_finish()
        auto_finish = not auto_finish
        settings.auto_finish = auto_finish
    end
    function state:set_must_restart(bool)
        assert(type(bool)=="boolean")
        must_restart = bool
        settings.must_restart = must_restart
    end
    --[[
        If true the player can move anywhere.
        If false the palyer has a collection of cards and can only move those
        cards to specific CardStack Objects.
    --]]
    function state:is_roaming() return #collection.stack == 0 end


----------------- Initialization -------------


    function state:initialize()
        print("state initializing")
        game_won = false
        -- Build the essential features of Solitaire
        waste = Waste(GridPositions[2][1])
        tableau = {}
        for i = 1,7 do
            tableau[i] = VerticleTableau(GridPositions[i][2])
        end
        foundations = {}
        for i = 1,4 do
            foundations[i] = Foundation(GridPositions[i+3][1])
        end
        stock = Stock(GridPositions[1][1])
        backup_stock = Stock({-100, -100, 300})

        collection = Collection(GridPositions[1][1])
    end

    function state:reset()
        new_game = true
        settings.new_game = new_game
        game_won = false
        must_restart = false
        settings.must_restart = must_restart
        game_timer.start = 0
        game_timer.current = 0
        settings.time = 0
        settings.saved_time = 0
        waste.stack = {}
        for i = 1,7 do
            tableau[i].stack = {}
        end
        for i = 1,4 do
            foundations[i].stack = {}
        end
        stock.stack = {}
        backup_stock.stack = {}
        collection.stack = {}
    end

    function state:build_test()
        rigged_cards()
        -- Sets up the game grid the player moves across
        grid = {}
        for i = 1,7 do
            grid[i] = {}
        end

        grid[1][1] = stock
        grid[2][1] = waste
        local card
        for i,foundation in ipairs(foundations) do
            grid[3+i][1] = foundation
            -- put in an ACE
            card = RiggedCards[13*(i-1) + 1]
            if not card:isFaceUp() then card:flip() end
            foundation:push(card)
        end
        for i,vertTabl in ipairs(tableau) do
            grid[i][2] = vertTabl
            -- insert cards in order
            if i <= 4 then
                for j = 0,11 do
                    card = RiggedCards[13*(i) - j]
                    if not card:isFaceUp() then card:flip() end
                    vertTabl:insert_at({card}, true)
                end
            end
        end

    end

    function state:build_ace_king_test()
        rigged_cards()

        if splash_screen then
            splash_screen:unparent()
            splash_screen = nil
        end

        -- Sets up the game grid the player moves across
        grid = {}
        for i = 1,7 do
            grid[i] = {}
        end

        grid[1][1] = stock
        grid[2][1] = waste
        for i,foundation in ipairs(foundations) do
            grid[3+i][1] = foundation
        end
        for i,vertTabl in ipairs(tableau) do
            grid[i][2] = vertTabl
        end


        tableau[2]:insert_at({Cards[51]}, true)
        tableau[2]:insert_at({Cards[24]}, true)
        tableau[3]:insert_at({Cards[38]}, true)
        Cards[24]:face_front()
        Cards[38]:face_front()

    end

    function state:build_klondike()

        master_event_listener_en = false
        -- Sets up the game grid the player moves across
        grid = {}
        for i = 1,7 do
            grid[i] = {}
        end

        grid[1][1] = stock
        grid.backup = backup_stock
        grid[2][1] = waste
        for i,foundation in ipairs(foundations) do
            grid[3+i][1] = foundation
        end
        for i,vertTabl in ipairs(tableau) do
            grid[i][2] = vertTabl
        end

        -- and the card stacks
        local card_counter = 0
        local deck = Deck()
        deck:shuffle()
        local interval = nil
        for i,card in ipairs(deck.cards) do
            if i < #deck.cards then
                intervals = {
                    ["x"] = Interval(card.group.x, deck.group.x-card.group.parent.x),
                    ["y"] = Interval(card.group.y, deck.group.y-card.group.parent.y),
                    ["z"] = Interval(card.group.z, deck.group.z-card.group.parent.z)
                }
                card.position = Utils.deepcopy(deck.group.position)
                gameloop:add(card.group, CARD_MOVE_DURATION, i*10, intervals,
                    function()
                        card.group:unparent()
                        card.group.position = {0,0,0}
                        deck.group:add(card.group)
                        card:face_back(function()
                            card_counter = card_counter + 1
                        end)
                    end)
            else
                intervals = {
                    ["x"] = Interval(card.group.x, deck.group.x-card.group.parent.x),
                    ["y"] = Interval(card.group.y, deck.group.y-card.group.parent.y),
                    ["z"] = Interval(card.group.z, deck.group.z-card.group.parent.z)
                }
                card.position = Utils.deepcopy(deck.group.position)
                gameloop:add(card.group, CARD_MOVE_DURATION, i*10, intervals,
                    card:face_back(function()
                        card_counter = card_counter + 1
                        card.group:unparent()
                        card.group.position = {0,0,0}
                        deck.group:add(card.group)
                        local a_timer = Timer()
                        a_timer.interval = 2000
                        function a_timer:on_timer()
                            if card_counter >= 52 then
                                if splash_screen then
                                    splash_screen:unparent()
                                    splash_screen = nil
                                end
                                a_timer:stop()
                                a_timer.on_timer = nil
                                
                                ---[[
                                if saved_game and not new_game
                                and not must_restart then
                                    state:load_save(deck)
                                    return
                                end
                                --]]

                                mediaplayer:play_sound(
                                "assets/sounds/Shuffle.mp3")
                                -- delays between delaying building tableaus
                                local delay = 200
                                for i = 1,6 do
                                    delay = tableau[i]:create(i, deck, delay)
                                end
                                tableau[7]:create(7, deck, delay, function()
                                    stock:en_q(deck.cards)
                                    mediaplayer:play_sound(
                                    "assets/sounds/Card_Movement.mp3")
                                    master_event_listener_en = true
                                end)
                            end
                        end
                        a_timer:start()
                    end))
            end
        end
    end

    function state:load_save(deck)
        -- start by loading cards into the tableaus
        for i = 1,7 do
            -- generate a table holding the cards from the deck
            -- based on the saved data, this table will be transported
            -- to the appropriate location on the board
            local prev_face_up = false
            for _,card in ipairs(saved_game[i][2].stack) do
                tableau[i]:load_card(
                    deck.find_card[card.suit.name][card.rank.num],
                    card.is_face_up, prev_face_up
                )
                prev_face_up = card.is_face_up
            end
        end

        -- next send the appropriate cards to the foundation
        for i = 1,4 do
            for _,card in ipairs(saved_game[3+i][1].stack) do
                foundations[i]:push(
                    deck.find_card[card.suit.name][card.rank.num], true, false, true
                )
            end
        end

        -- then the cards in the waste
        for i,card in ipairs(saved_game[2][1].stack) do
            waste:push(
                deck.find_card[card.suit.name][card.rank.num], deal_3
            )
            if i == #saved_game[2][1].stack then
                waste:move_out_top_cards(100)
            end
        end

        -- backup stock
        for _,card in ipairs(saved_game.backup.stack) do
            backup_stock:push(
                deck.find_card[card.suit.name][card.rank.num], false, true, true
            )
        end

        -- finally the stock
        local temp_stock = Stock({-100, -100, 0})
        for _,card in ipairs(saved_game[1][1].stack) do
            temp_stock:push(
                deck.find_card[card.suit.name][card.rank.num], false, true, true
            )
        end

        local a_timer = Timer()
        a_timer.interval = 1000
        function a_timer:on_timer()
            a_timer:stop()
            a_timer.on_timer = nil
            a_timer = nil
            temp_stock:organize()
            stock:transfer_collection(temp_stock.stack)
        end
        a_timer:start()

        master_event_listener_en = true
    end


--------------------- Functions ------------------


    function state:undo()
        if must_restart then return end

        local undo_orig_selector = ctrl:get_undo_orig_selector()
        local undo_latest_selector = ctrl:get_undo_latest_selector()
        if (not undo_orig_selector) or (not undo_latest_selector) then return end

        local orig_x = undo_orig_selector.x
        local orig_y = undo_orig_selector.y
        local orig_t = undo_orig_selector.tableau_index
        local orig_grid = grid[orig_x][orig_y]
        local orig_stack = orig_grid.stack
        local latest_x = undo_latest_selector.x
        local latest_y = undo_latest_selector.y
        local latest_t = undo_latest_selector.tableau_index
        local latest_grid = grid[latest_x][latest_y]
        local latest_stack = grid.stack

        ctrl:set_selector(undo_latest_selector, function ()
        
        -- correct for card being flipped after child card moved from position
        if orig_grid:is_a(VerticleTableau) and undo_parent_card_was_flipped then
            orig_stack[orig_t-1]:flip()
        end
        if latest_grid:is_a(VerticleTableau) then
            collection:insert(latest_grid:select_at(latest_t),
                function()
                    ctrl:set_selector_and_move(undo_orig_selector,
                    function()
                        if orig_grid:is_a(VerticleTableau) then
                            orig_grid:insert_at(collection.stack, true)
                        elseif orig_grid:is_a(Waste) then
                            assert(#collection.stack == 1)
                            orig_grid:push(collection:pop(), deal_3)
                            waste:move_out_top_cards()
                        else
                            assert(#collection.stack == 1)
                            orig_grid:push(collection.stack[1], nil, nil, true)
                        end
                        ctrl:set_undo_orig_selector(nil)
                        ctrl:set_undo_latest_selector(nil)
                        ctrl:get_presentation():move_focus()
                        state:save_game()
                    end)
                end)
        elseif latest_grid:is_a(Foundation) then
            collection:push(latest_grid:pop(),
                function()
                    ctrl:set_selector_and_move(undo_orig_selector,
                    function()
                        assert(#collection.stack == 1)
                        if orig_grid:is_a(Waste) then
                            assert(#collection.stack == 1)
                            orig_grid:push(collection:pop(), deal_3)
                            waste:move_out_top_cards()
                        elseif orig_grid:is_a(VerticleTableau) then
                            orig_grid:insert_at({collection:pop()}, true)
                        else
                            orig_grid:push(collection:pop(), nil, nil, true)
                        end
                        ctrl:set_undo_orig_selector(nil)
                        ctrl:set_undo_latest_selector(nil)
                        ctrl:get_presentation():move_focus()
                        state:save_game()
                    end)
                end)
        elseif latest_grid:is_a(Waste) then
            if waste:is_empty() and stock:is_empty() then
                -- do nothing
            elseif waste:is_empty() then
                while stock.stack[2] do
                    local card = table.remove(stock.stack, 1)
                    backup_stock:push(card, true, false, true)
                end
                assert(#stock.stack == 1)
                backup_stock:push(table.remove(stock.stack, 1), true, false, true,
                    function()
                        for i,card in ipairs(backup_stock.stack) do
                            if not card:isFaceUp() then card:fast_flip() end
                        end
                        while backup_stock.stack[2] do
                            local card = backup_stock:de_q()
                            waste:push(card, false, #waste.stack+1)
                        end
                        assert(#backup_stock.stack == 1)
                        waste:push(backup_stock:de_q(), false, #waste.stack+1,
                            function()
                                if deal_3 then waste:move_out_top_cards() end
                                ctrl:get_presentation():move_focus()
                                state:save_game()
                            end)
                    end)
            elseif deal_3 then
                stock:push(waste:pop(), false, true, true)
                stock:push(waste:pop(), false, true, true)
                stock:push(waste:pop(), false, true, true,
                    function() stock:organize() end)
                waste:move_out_top_cards()
            else
                stock:push(waste:pop(), false, true, true,
                    function() stock:organize() end)
                waste:move_out_top_cards()
            end
            ctrl:set_undo_orig_selector(nil)
            ctrl:set_undo_latest_selector(nil)
            ctrl:get_presentation():move_focus()
            state:save_game()
        end

        end)
    end

    local function find_card_match(card, not_check_foundation, not_check_tableau)
        for x = 1,7 do
            for y = 1,2 do
                if grid[x][y] then

                    if grid[x][y]:is_a(VerticleTableau) and (not not_check_tableau)
                      and grid[x][y]:valid_move(card) then
                        return x,y,#grid[x][y].stack
                    elseif grid[x][y]:is_a(Foundation) and (not not_check_foundation)
                      and grid[x][y]:valid_move(card) then
                        local t_index = #grid[x][y].stack
                        if t_index < 1 then t_index = 1 end
                        return x,y,t_index
                    end

                end
            end
        end

    end

    local function tableau_card_logic_check_move(card, old_x, old_y, old_t_index, hint)
        if not card then error("no card is face up in this tableau!", 2) end
        -- check to see if this particular card may be moved anywhere
        local old_stack = grid[old_x][old_y].stack
        new_x,new_y,new_t_index = find_card_match(card,
                                        old_stack[#old_stack] ~= card)
        if new_x and new_y then 
            local new_stack = grid[new_x][new_y].stack
            -- eliminate edge condition of king in empty spot
            if card.rank.num == Ranks.KING.num and #new_stack == 0
              and old_stack[1] == card then
                -- try again but only check the foundation
                new_x,new_y,new_t_index = find_card_match(card, false, true)
                if (not new_x) and (not new_y) then return true end
              -- eliminate condition of card moving to spot with same number/color
              -- as the card its already at
            elseif #new_stack > 0 and #old_stack > 1 and old_t_index > 1
              and old_stack[old_t_index-1]:isFaceUp()
              and new_stack[#new_stack].rank.num == old_stack[old_t_index-1].rank.num then
                -- might want to check if card belongs in foundation though
                new_x,new_y,new_t_index = find_card_match(card, false, true)
                if (not new_x) and (not new_y) then return true end
            end
            if hint then
                game:get_presentation():hint_animation(old_x, old_y, old_t_index,
                                                        new_x, new_y, new_t_index)
            end
            return false
        end
        return true
    end

    function state:check_remaining_moves(hint)
        if must_restart then return end

        -- iterate through all the stacks
        for x = 1,7 do
            for y = 1,2 do
                -- check to make sure the stack has cards
                if grid[x][y] and #grid[x][y].stack > 0 then
                    local stack = grid[x][y].stack
                    local new_x = nil
                    local new_y = nil
                    local old_t_index = 1
                    local old_x = x
                    local old_y = y
                    -- if the stack is apart of the tableau
                    if grid[x][y]:is_a(VerticleTableau) then
                        local card = nil
                        -- find the first card that is face up
                        for t_index = 1,#stack do
                            if stack[t_index]:isFaceUp() then
                                card = stack[t_index]
                                old_t_index = t_index
                                break
                            end
                        end
                        local continue = tableau_card_logic_check_move(card, x, y,
                                                                       old_t_index, hint)
                        if not continue then return end
                        -- find the last card if the stack has cards left
                        if #stack > 0 then
                            old_t_index = #stack
                            continue = 
                                tableau_card_logic_check_move(stack[#stack], x, y,
                                                              old_t_index, hint)
                        end
                        if not continue then return end
                    -- if the stack is a waste
                    elseif grid[x][y]:is_a(Waste) then
                        -- select the top card
                        local card = stack[#stack]
                        assert(card)
                        -- find out if the card can be moved anywhere
                        new_x,new_y,new_t_index = find_card_match(card)
                        -- if so then move it to the new location
                        if new_x and new_y and hint then
                            game:get_presentation():hint_animation(old_x, old_y,
                                                                old_t_index, new_x,
                                                                new_y, new_t_index)
                            return
                        end
                    -- if the stack is the Stock
                    elseif grid[x][y]:is_a(Stock) and not hint then
                        -- check through either every third card or every card
                        for i,card in ipairs(stack) do
                        end
                        if deal_3 then
                            local i = #stack-2
                            while stack[i] do
                                local card = stack[i]
                                if find_card_match(card) then return end
                                i = i - 3
                            end
                            -- check the last card as well, sometimes will be redundant
                            if find_card_match(stack[1]) then return end
                        else
                            for i,card in ipairs(stack) do
                                if find_card_match(card) then return end
                            end
                        end
                    end

                end
            end
        end
        
        -- if nothing worked and the player wants a hint then set the player to the stock
        if hint then
            DialogDisplay("Deal a new Card", DIALOG_DISPLAY_TIME)
            game:set_selector({x=1, y=1, tableau_index=1})
        else
        -- otherwise it must be a game over
            if game_won then return end
            print("game over")
            router:set_active_component(Components.NO_MOVES_DIALOG)
            router:notify()
        end
    end

    function state:return_card(prev_selector)
        assert(prev_selector, "no location given to return card to")

        local x = prev_selector.x
        local y = prev_selector.y
        local t_index = prev_selector.tableau_index

        if grid[x][y]:is_a(Waste) then
            assert(#collection.stack == 1)
            local waste = grid[x][y]
            waste:push(collection:pop(), deal_3)
        elseif grid[x][y]:is_a(Foundation) then
            assert(#collection.stack == 1)
            local foundation = grid[x][y]
            foundation:push(collection:pop(), true, false, true)
        elseif grid[x][y]:is_a(VerticleTableau) then
            assert(not collection:is_empty())
            vertTabl = grid[x][y]
            vertTabl:insert_at(collection.stack, true)
        else
            error("should be one of those")
        end

        ctrl:get_presentation():move_focus()
        state:save_game()
    end

    function state:save_game()
        settings.saved_game = grid
    end

    function state:click(selector, cb)
        if new_game then
            new_game = false
            settings.new_game = false
        end

        local x = selector.x
        local y = selector.y
        local t_index = selector.tableau_index

        if state:is_roaming() then
            if grid[x][y] == stock then

                if stock:is_empty() then
                    backup_stock:en_q(waste:stock_cards(),
                        function()
                            backup_stock:organize()
                            stock:en_q(backup_stock.stack, state.check_remaining_moves)
                            if not stock:is_empty() then
                                mediaplayer:play_sound(
                                "assets/sounds/Card_Movement.mp3")
                            end
                            backup_stock.stack = {}
                        end)
                else
                    if deal_3 then
                        waste:organize(
                            function()
                                waste:waste_three_cards(
                                    stock:de_q(), stock:de_q(), stock:de_q(),
                                    function()
                                        state:save_game()
                                        mediaplayer:play_sound(
                                        "assets/sounds/Card_Flip.mp3")
                                    end
                                )
                            end)
                    else
                        waste:push(stock:de_q(), false, nil,
                            function()
                                mediaplayer:play_sound("assets/sounds/Card_Flip.mp3")
                            end
                        )
                    end
                    stock:organize()
                end
                if not stock:is_empty() or not backup_stock:is_empty() then
                    increase_moves() --this is global in "MenuView.lua"/should change 
                end
                game:set_undo_orig_selector({x = 1, y = 1, tableau_index = 1})
                game:set_undo_latest_selector({x = 2, y = 1, tableau_index = #waste.stack})
            elseif grid[x][y] == waste then
                if not waste:is_empty() then
                    collection:push(waste:pop(), cb)
                    ctrl:get_presentation():move_focus()
                end
            elseif grid[x][y]:is_a(Foundation) then
                local foundation = grid[x][y]
                if not foundation:is_empty() then collection:push(foundation:pop(),cb) end
            elseif grid[x][y]:is_a(VerticleTableau) then
                local vertTabl = grid[x][y]
                if not vertTabl:is_empty() then
                    -- correct for picking up a King after placing it (weird bug)
                    if t_index == 0 then t_index = 1 end
                    collection:insert(vertTabl:select_at(t_index), cb)
                    -- correct selector position for missing card
                    local selector = ctrl:get_selector()
                    if selector.tableau_index - 1 >= 1 then
                        selector.tableau_index = selector.tableau_index - 1
                        ctrl:get_presentation():move_focus()
                    end
                end
            else
                error("should not be here")
            end
        else
            local prev_selector = ctrl:get_prev_selector()
            local prev_x = prev_selector.x
            local prev_y = prev_selector.y
            local prev_t = prev_selector.tableau_index
            if grid[x][y]:is_a(Foundation) then
                assert(#collection.stack == 1)
                local foundation = grid[x][y]
                if foundation:valid_move(collection.stack[1]) then
                    foundation:push(collection:pop(), true)
                    increase_score()
                end
            elseif grid[x][y]:is_a(VerticleTableau) then
                assert(#collection.stack >= 1)
                local vertTabl = grid[x][y]
                if vertTabl:valid_move(collection.stack[1]) then
                    vertTabl:insert_at(collection.stack)
                elseif (prev_x == x and prev_y == y) then
                    ctrl:back_pressed()
                end
            elseif grid[x][y]:is_a(Waste) and prev_x == x and prev_y == y then
                ctrl:back_pressed()
            end
        end

        return state:is_roaming()
    end

    function state:valid_move()
        local selector = ctrl:get_selector()
        local x = selector.x
        local y = selector.y

        if grid[x][y]:is_a(Foundation) then
            local foundation = grid[x][y]
            if foundation:valid_move(collection.stack[1]) then
                return true
            end
        elseif grid[x][y]:is_a(VerticleTableau) and (
                (grid[x][y].stack[#grid[x][y].stack]
                and grid[x][y].stack[#grid[x][y].stack]:isFaceUp())
                or
                (#grid[x][y].stack == 0
                and collection.stack[1].rank.num == Ranks.KING.num)
            ) then
                    local vertTabl = grid[x][y]
                    if vertTabl:valid_move(collection.stack[1]) then
                        return true
                    end
        end

        return false
    end

    function state:check_for_win()

        if (not stock:is_empty()) or (not waste:is_empty()) then return end
        if auto_finish and not game_won then
            for i,card in ipairs(Cards) do
                -- all cards must be face up
                if not card:isFaceUp() then return end
            end
            router:set_active_component(Components.AUTO_COMPLETE_DIALOG)
            router:notify()
            game_won = true
        else
            for i = 1,7 do
                if not grid[i][2]:is_empty() then return end
            end
            must_restart = true
            settings.must_restart = must_restart
            router:set_active_component(Components.MENU)
            router:notify()
            game:get_presentation():end_game_animation()
            game_won = true
        end

    end

    function state:auto_complete()
        local done = false
        local card = nil
        local card_number = 0
        local rank_to_find = 1
        local suit_to_find = "Any"
        local count = 0
        while not done do
            count = 0
            -- find a card to put in a foundation
            for i,foundation in ipairs(foundations) do
                if foundation:is_empty() then
                    rank_to_find = 14
                    suit_to_find = "Any"
                elseif #foundation.stack >= 13 then
                    count = count + 1
                else
                    rank_to_find = foundation.stack[#foundation.stack].rank.num + 1
                    -- if ace then search for 2
                    if rank_to_find >= 14 then rank_to_find = 2 end
                    suit_to_find = foundation.stack[#foundation.stack].suit.name
                end
                -- find the card in the tableau and put it in the foundation
                for i,table in ipairs(tableau) do
                    if not table:is_empty() then
                        card = table.stack[#table.stack]
                        if (card.rank.num == rank_to_find
                          and card.suit.name == suit_to_find)
                          or (card.rank.num == 14
                          and suit_to_find == "Any") then
                            foundation:push(table:pop(), nil, nil, true)
                        end
                    end
                end
            end

            -- if all foundations filled then done
            if count >= 4 then done = true end
        end

        state:check_for_win()
    end

end)
