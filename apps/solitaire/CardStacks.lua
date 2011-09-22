CardStack = Class(nil,
function(cardStack, position, ...)

    if not position then
        error("This needs a position.", 4)
    end

    cardStack.stack = {}
    cardStack.group = Group{position=position}
    cardStack.enabled = true

    function cardStack:enable() self.enabled = true end
    function cardStack:disable() self.enabled = false end

    function cardStack:push(card, face_front, face_back, force_push, cb)
        if not card then error("no card", 2) end
        if not card:is_a(Card) then error("element pushed is not a Card", 2) end
        if face_front and face_back then error("can't face front and back", 2) end

        if(self:valid_move(card) or force_push) then
            table.insert(self.stack, card)
            if face_front then face_back = not face_front end
            if face_back then face_front = not face_back end
            local card_position = {math.random(2)-1, math.random(2)-1, #cardStack.stack-1}
            card:move_card(self.group, face_front, face_back, false, false,
                card_position, nil, cb)
        else
            print("could not add card to card_stack")
        end
    end

    function cardStack:pop()
        local card = table.remove(self.stack)
        return card
    end

    function cardStack:valid_move(card, position)
        error("valid_move not implemented for this CardStack", 2)
    end

    function cardStack:is_empty()
        if self.stack[1] then return false else return true end
    end

end)


Collection = Class(CardStack,
function(collection, ...)
    collection._base.init(collection, ...)

--    collection.group:add(Rectangle{width = 100, height = 100})

    function collection:push(card, cb)
        if not card then error("no card", 2) end
        if not card:is_a(Card) then error("element pushed is not a Card", 2) end

        local card_position = {0,0,COLLECTION_OFFSET}
        table.insert(self.stack, card)
        mediaplayer:play_sound("assets/sounds/Card_Pickup.mp3")
        card:move_card(self.group, nil, nil, false, false, card_position, nil, cb)
    end

    --[[
        Inserts the collection of cards after the card at the current index.

        @param collection : The collection of Card objects to insert
    --]]
    function collection:insert(cards, cb)
        if #cards == 0 then return end

        local card = nil
        local card_position = nil

        card = table.remove(cards, 1)
        while(cards[1]) do
            card_position = {
                0,
                TABLEAU_OFFSET_FACE_UP*(#self.stack)+15,
                COLLECTION_OFFSET+Z_OFFSET*#self.stack
            }
            table.insert(self.stack, card)
            card:move_card(self.group, true, false, false, false, card_position)

            card = table.remove(cards, 1)
        end
        card_position = {
            0,
            TABLEAU_OFFSET_FACE_UP*(#self.stack)+15,
            COLLECTION_OFFSET+Z_OFFSET*#self.stack
        }
        table.insert(self.stack, card)
        mediaplayer:play_sound("assets/sounds/Card_Pickup.mp3")
        card:move_card(self.group, true, false, false, false, card_position, nil, cb)
    end

    function collection:valid_move()
        return true
    end

end)


Foundation = Class(CardStack,
function(foundation, ...)
    foundation._base.init(foundation,...)

    --[[
        Checks to make sure this card validly can move to the position of the
        Foundation.
    --]]
    function foundation:valid_move(card)
        -- check to make sure its a card object
        if not card:is_a(Card) then
            print("Not a Card object")
            return false
        end

        -- stack is empty requires an ACE
        if self.stack[1] == nil then
            if Ranks.ACE.num == card.rank.num then return true
            else return false
            end
        -- stack has an ACE then requires a 2 of similar suit
        elseif Ranks.ACE.num == self.stack[#self.stack].rank.num
          and Ranks.TWO.num == card.rank.num
          and self.stack[1].suit.name == card.suit.name then
            return true
        -- otherwise card needs to be of a 1 higher rank and similar suit
        elseif self.stack[#self.stack].rank.num == card.rank.num - 1
          and self.stack[1].suit.name == card.suit.name then
            return true
        end

        return false
    end

end)



Stock = Class(CardStack,
function(stock, ...)
    stock._base.init(stock, ...)

    function stock:transfer_collection(collection, cb)
        assert(collection)
        assert(type(collection) == "table", "collection needs to be a table")

        local callback = nil
        local wait = nil
        local card = table.remove(collection, 1)
        while card do
            local card_position = {math.random(),math.random(),Z_OFFSET*#self.stack}
            table.insert(self.stack, card)
            next_card = table.remove(collection, 1)
            if not next_card then
                callback = cb
                wait = 100
            end
            card:move_card(self.group, false, true, false, false, card_position, nil,
                    callback)
            card = next_card
        end
        if not callback and cb then cb() end
    end

    function stock:en_q(collection, cb)
        assert(collection)
        assert(type(collection) == "table", "collection needs to be a table")

        local callback = nil
        local wait = nil
        local card = table.remove(collection)
        while card do
            local card_position = {math.random(),math.random(),Z_OFFSET*#self.stack}
            table.insert(self.stack, card)
            next_card = table.remove(collection)
            if not next_card then
                callback = cb
                wait = 100
            end
            card:move_card(self.group, false, true, false, false, card_position, nil,
                    callback)
            card = next_card
        end
        if not callback and cb then cb() end
    end

    function stock:de_q()
        return table.remove(self.stack)
    end

    -- hack fixes the "ninja card"/"floating card" problem
    function stock:organize()
        for i,card in ipairs(self.stack) do
            if card:isFaceUp() then card:fast_flip() end
            if not (card.group.z == Z_OFFSET*(i-1)) then
                card.group.z = Z_OFFSET*(i-1)
            end
        end
    end

    function stock:valid_move(card) return false end

end)



Waste = Class(CardStack,
function(waste, ...)
    waste._base.init(waste, ...)

    local prev_index = 1
    
    --[[
        @param deal_3_mode boolean : defines whether or not the game is in deal 3
    --]]
    function waste:push(card, deal_3_mode, index, cb)
        if not card then error("not card being pushed", 2) end
        if not card:is_a(Card) then error("not a Card being pushed", 2) end
        if cb and type(cb) ~= "function" then error("cb not a function", 2) end
        if not index then index = prev_index end

        table.insert(self.stack, card)
        local card_position = {0,0,(Z_OFFSET+1)*(#self.stack-1)}
        if deal_3_mode then
            card_position[1] = WASTE_OFFSET*(index-1)
        end
        card:move_card(self.group, true, false, false, false, card_position, nil,
            function()
                if not card:isFaceUp() then card:flip() end
                if cb then cb() end
            end)
    end

    function waste:pop()
        local card = table.remove(self.stack)
        prev_index = card.position[1]/WASTE_OFFSET + 1
        return card
    end

    function waste:move_out_top_cards(wait_duration)
        if #self.stack == 0 or not game:get_state():get_deal_3() then return end
        if not wait_duration then wait_duration = 0 end

        local card = nil
        local card_position_x = 0
        if self.stack[#self.stack-1] and self.stack[#self.stack-2] then
            -- set the first card to 0
            card = self.stack[#self.stack-2]
            card.position[1] = 0
            card:move_card(self.group, true, false, false, false, card.position,
                            wait_duration)
            -- set the second card up one
            card = self.stack[#self.stack-1]
            card.position[1] = WASTE_OFFSET
            card_position_x = card.position[1]
            card:move_card(self.group, true, false, false, false, card.position,
                            wait_duration)
        end

        if self.stack[#self.stack-1] then
            -- move the last card dependant on the position of card 2
            card = self.stack[#self.stack]
            card.position[1] = WASTE_OFFSET + card_position_x
            card:move_card(self.group, true, false, false, false, card.position,
                            wait_duration)
        end
    end

    function waste:organize(cb)
        if #self.stack == 0 then
            if cb then cb() end
            return
        end

        local callback = nil
        for i,card in ipairs(self.stack) do
            if card.position[1] ~= 0 then
                if i == #self.stack then callback = cb end
                intervals = {
                    ["x"] = Interval(card.position[1], 0)
                }
                card.position[1] = 0
                gameloop:add(card.group, 100, nil, intervals, callback)
            end
        end
        -- edge case where the waste is already organized
        if not callback then cb() end
    end

    function waste:waste_three_cards(card1, card2, card3, cb)
        if card1 then self:push(card1, true, 1) end
        if card2 then self:push(card2, true, 2) end
        if card3 then self:push(card3, true, 3, cb) end
    end

    --[[
        Pops the three cards in the waste, puts them in a table, and returns
        the table.

        Use in conjuction with stock.en_q()
    --]]
    function waste:stock_cards()
        local temp = {}
        while not self:is_empty() do
            table.insert(temp, self:pop())
        end

        return temp
    end

    function waste:valid_move(card) return false end

end)



VerticleTableau = Class(CardStack,
function(vertTabl, ...)
    vertTabl._base.init(vertTabl,...)

    --[[
        Creates this section of the tableau determined by position.
    --]]
    function vertTabl:create(position, deck, delay, cb)
        assert(position)
        assert(deck)
        assert(delay)
        local card = nil
        local face_front = nil
        local face_back = nil
        local card_position = nil
        local callback = nil
        for i = 1,position do
            if i == position then callback = cb end

            card = table.remove(deck:deal(1))
            table.insert(self.stack, card)
            face_front = (i == position)
            face_back = not face_front
            card_position = {
                0,
                TABLEAU_OFFSET*(#self.stack-1),
                Z_OFFSET*(#self.stack-1)
            }
            delay = delay + i*20
            card:move_card(self.group, face_front, face_back, false, false,
                card_position, delay, callback)
        end
        return delay
    end

    --[[
        Creates this section of the tableau determined by position if loading
        a saved game.
    --]]
    function vertTabl:load_card(card, face_front, prev_is_face_up, delay, cb)
        local card_position = {0, 0, Z_OFFSET*(#self.stack)}
        -- adjust for the card above, if it is face up
        if prev_is_face_up then
            card_position[2] =
                self.stack[#self.stack].position[2]+TABLEAU_OFFSET_FACE_UP
        elseif self.stack[#self.stack] then
            card_position[2] =
                self.stack[#self.stack].position[2]+TABLEAU_OFFSET
        end

        table.insert(self.stack, card)
        if face_front then
            card:move_card(self.group, true, nil, false, false,
                card_position)
        else
            card:move_card(self.group, nil, nil, false, false,
                card_position)
        end
    end

    --[[
        Pops the collection of cards following the selected one.

        @param index : Where to pop the collection from
        @returns The collection popped.
    --]]
    function vertTabl:select_at(index)
        collection = {}
        while(self.stack[index]) do
            table.insert(collection, table.remove(self.stack, index) )
        end

        return collection
    end

    --[[
        Inserts the collection of cards after the card at the current index.

        @param collection : The collection of Card objects to insert
    --]]
    function vertTabl:insert_at(collection, force_insert, face_front)
        assert(type(collection == "table"))
        if force_insert or self:valid_move(collection[1]) then
            while(collection[1]) do
                local card_position = {0, 0, Z_OFFSET*(#self.stack)}
                -- adjust for the card above, if it is face up
                if self.stack[#self.stack]
                  and self.stack[#self.stack]:isFaceUp() then
                    card_position[2] =
                        self.stack[#self.stack].position[2]+TABLEAU_OFFSET_FACE_UP
                elseif self.stack[#self.stack] then
                    card_position[2] =
                        self.stack[#self.stack].position[2]+TABLEAU_OFFSET
                end

                local card = table.remove(collection, 1)
                table.insert(self.stack, card)
                if face_front then
                    card:move_card(self.group, true, nil, false, false,
                        card_position)
                else
                    card:move_card(self.group, nil, nil, false, false,
                        card_position)
                end
            end
        else
            print("could not insert at position, not a valid move")
        end
    end

    --[[
        Checks to make sure this card validly can move to the position of the
        VerticleTableau.
    --]]
    function vertTabl:valid_move(card)
        -- check to make sure its a card object
        if not card:is_a(Card) then
            print("Not a Card object")
            return false
        end

        -- stack is empty requires a KING
        if #self.stack == 0 then
            if Ranks.KING.num == card.rank.num then return true
            else return false
            end

        -- card at end of stack must be face front
        elseif not self.stack[#self.stack]:isFaceUp() then
            return false

        -- otherwise card needs to be of 1 lower rank and opposite color
        elseif self.stack[#self.stack].rank.num == card.rank.num + 1 
            and self.stack[#self.stack].rank.num ~= Ranks.ACE.num then

            if (self.stack[#self.stack].suit.name == Suits.CLUBS.name
              or self.stack[#self.stack].suit.name == Suits.SPADES.name)
              and (card.suit.name == Suits.DIAMONDS.name
              or card.suit.name == Suits.HEARTS.name) then

                return true

            elseif (self.stack[#self.stack].suit.name == Suits.DIAMONDS.name
              or self.stack[#self.stack].suit.name == Suits.HEARTS.name)
              and (card.suit.name == Suits.CLUBS.name
              or card.suit.name == Suits.SPADES.name) then

                return true

             end
            
        end

        return false
    end

end)
