if not Class then
   dofile("Class.lua")
end

function Suit(name)
   return {
      name=name,
      abbv=string.sub(name, 1, 1)
   }
end

Suits = {
   CLUBS=Suit("Clubs"),
   DIAMONDS=Suit("Diamonds"),
   HEARTS=Suit("Hearts"),
   SPADES=Suit("Spades")
}

-- Returns the string of a card's image
function getCardImageName(card)
   local suits = {
      ["Clubs"] = "C",
      ["Diamonds"] = "D",
      ["Hearts"] = "H",
      ["Spades"] = "S",
   }
   return suits[card.suit.name]..card.rank.num
end

local back_images = {
    Image{src="assets/cards/Back1.png", z=-1, opacity=0},
    Image{src="assets/cards/Back2.png", z=-1, opacity=0},
    Image{src="assets/cards/Back3.png", z=-1, opacity=0},
    Image{src="assets/cards/Back4.png", z=-1, opacity=0},
}
for i,v in ipairs(back_images) do
    screen:add(v)
end
-- Get a group with the image of a card's front/back
function getCardGroup(card, face, args)
    
    -- Front of the card.
    local front = Image{src="assets/cards/"..getCardImageName(card)..".png"}
    CARD_WIDTH = front.width
    CARD_HEIGHT = front.height
    local cardFront = Group{name="front"}
    cardFront:add(front)
    -- Back of the card.
    local backs = {
        Clone{source = back_images[1]},
        Clone{source = back_images[2], opacity = 0},
        Clone{source = back_images[3], opacity = 0},
        Clone{source = back_images[4], opacity = 0},
    }
    local cardBack = Group{name="back", z=-1, y_rotation={180, backs[1].width/2, 0}}
    cardBack:add(unpack(backs))
    -- The front and back grouped together
    local cardGroup = Group{
        name="card",
        extra={face = true},
        anchor_point = {front.w/2, front.h/2},
        position = {0,0,0}
    }
    cardGroup:add(cardBack, cardFront)

    -- options for other arguments
    if args and type(args) == "table" then for k, v in pairs(args) do
        cardGroup[k] = v
    end end
   
    -- corrects for a card that is initialized as face down
    if face == "back" then
        cardGroup.extra.face = false
        cardFront.opacity = 0
        cardGroup.extra.rotation = 180
        cardGroup.y_rotation = { cardGroup.extra.rotation, 0, 0 }
    end

    return cardGroup

end

-- Initializes the card as face down
function resetCardGroup(cardGroup)

    local front = cardGroup:find_child("front")
    local back = cardGroup:find_child("back")

    cardGroup.extra.face = false
    front.opacity = 0
    back.opacity = 255
    cardGroup.extra.rotation = 180
    cardGroup.y_rotation = { cardGroup.extra.rotation, 0, 0 }

end

-- Flip a card, return true if the front is showing
function flipCard(cardGroup, callback)
    
    -- Makes sure the card is flipped exactly 180 degrees from any current angle
    if not cardGroup.extra.rotation then cardGroup.extra.rotation = 180
    else cardGroup.extra.rotation = cardGroup.extra.rotation + 180
    end
    if cardGroup.extra.rotation > 360 then
        cardGroup.extra.rotation = cardGroup.extra.rotation - 360
    end
    
    -- 'true' for forward facing, 'false' for face down
    cardGroup.extra.face = not cardGroup.extra.face
     
    -- Makes sure all the parts are there
    local front = cardGroup:find_child("front")
    local back = cardGroup:find_child("back")
    assert(front)
    assert(back)
   
    -- compensate cards already angled greater than 180
    local rotation = 90
    if cardGroup.y_rotation[1] >= 180 then rotation = 270 end
    if gameloop and gameloop:is_a(GameLoop) then
        local intervals = {
            ["y_rotation"] = {
                Interval(cardGroup.y_rotation[1], rotation),
                Interval(cardGroup.y_rotation[2], cardGroup.y_rotation[2]),
                Interval(cardGroup.y_rotation[3], cardGroup.y_rotation[3])
            }
        }
        gameloop:add(cardGroup, CARD_MOVE_DURATION/3, nil, intervals, function()
                if cardGroup.extra.face then
                    -- show the face
                    front.opacity = 255
                    back.opacity = 0
                else
                    -- show the back
                    front.opacity = 0
                    back.opacity = 255
                end
         
                local intervals = {
                    ["y_rotation"] = {
                        Interval(cardGroup.y_rotation[1], cardGroup.extra.rotation),
                        Interval(cardGroup.y_rotation[2], cardGroup.y_rotation[2]),
                        Interval(cardGroup.y_rotation[3], cardGroup.y_rotation[3])
                    }
                }
                gameloop:add(cardGroup, CARD_MOVE_DURATION/3, nil, intervals, callback)
            end)
 
    else
        -- rotate ninety, flip which side of the card is shown, finish rotation
        cardGroup:complete_animation()
        cardGroup:animate{
            -- y_rotation = cardGroup.extra.rotation - 90,
            y_rotation = rotation,
            duration = 200,
            on_completed = function()
         
                if cardGroup.extra.face then
                    -- show the face
                    front.opacity = 255
                    back.opacity = 0
                else
                    -- show the back
                    front.opacity = 0
                    back.opacity = 255
                end
         
                cardGroup:animate{
                    y_rotation = cardGroup.extra.rotation,
                    duration = 200,
                    on_completed = callback
                }
            end
        }

    end

end

function Rank(name, num, abbv)
   return {
      name=name,
      num=num,
      abbv=abbv
   }
end

Ranks = {
   TWO=Rank("Two", 2, "2"),
   THREE=Rank("Three", 3, "3"),
   FOUR=Rank("Four", 4, "4"),
   FIVE=Rank("Five", 5, "5"),
   SIX=Rank("Six", 6, "6"),
   SEVEN=Rank("Seven", 7, "7"),
   EIGHT=Rank("Eight", 8, "8"),
   NINE=Rank("Nine", 9, "9"),
   TEN=Rank("Ten", 10, "T"),
   JACK=Rank("Jack", 11, "J"),
   QUEEN=Rank("Queen", 12, "Q"),
   KING=Rank("King", 13, "K"),
   ACE=Rank("Ace", 14, "A"),
}

Card = Class(nil, 
function(self, rank, suit, is_face_up)

    -- public fields
    -- position of card.group within current group, remember to update
    --self.position = Utils.deepcopy(CARD_STARTING_POSITION)
    self.position = {-500,0,0}
    self.is_face_up = is_face_up

    -- Creates the card
    if type(rank) == "string" then
        self.rank = Ranks[rank]
    else
        self.rank = rank
    end
    assert(self.rank)

    if type(suit) == "string" then
        self.suit = Suits[suit]
    else
        self.suit = suit
    end
    assert(self.suit)

    self.name = self.rank.name .. " of " .. self.suit.name
    self.abbv = self.rank.abbv .. self.suit.abbv

    if(is_face_up) then
        self.group = getCardGroup(self, "face")
    else
        self.group = getCardGroup(self, "back")
    end
    self.group.position = Utils.deepcopy(self.position)
    -- card skew
    self.group.z_rotation = {
        (math.random(2)-1)*ROTATION,
        CARD_WIDTH/2,
        CARD_HEIGHT/2
    }

    -- Method Calls
    function self:equals(card)
        return self.rank == card.rank and self.suit == card.suit
    end

    function self:isFaceUp()
        return self.group.extra.face
    end

    function self:flip(callback)
        flipCard(self.group, callback)
        self.is_face_up = self.group.extra.face
    end

    function self:fast_flip()
        local cardGroup = self.group

        -- Makes sure the card is flipped exactly 180 degrees from any current angle
        if not cardGroup.extra.rotation then cardGroup.extra.rotation = 180
        else cardGroup.extra.rotation = cardGroup.extra.rotation + 180
        end
        if cardGroup.extra.rotation > 360 then
            cardGroup.extra.rotation = cardGroup.extra.rotation - 360
        end
    
        -- 'true' for forward facing, 'false' for face down
        cardGroup.extra.face = not cardGroup.extra.face
        self.is_face_up = cardGroup.extra.face
   
        -- Makes sure all the parts are there
        local front = cardGroup:find_child("front")
        local back = cardGroup:find_child("back")
        assert(front)
        assert(back)
   
        -- compensate cards already angled greater than 180
        local rotation = 90
        if cardGroup.y_rotation[1] >= 180 then rotation = 270 end
        if cardGroup.extra.face then
            -- show the face
            front.opacity = 255
            back.opacity = 0
        else
            -- show the back
            front.opacity = 0
            back.opacity = 255
        end
         
        cardGroup.y_rotation = {
            cardGroup.y_rotation[1] + 180,
            cardGroup.y_rotation[2],
            cardGroup.y_rotation[3]
        }

    end

    function self:face_front(callback)
        if not self:isFaceUp() then self:flip(callback)
        elseif callback then callback()
        end

        self.is_face_up = true
    end

    function self:face_back(callback)
        if self:isFaceUp() then self:flip(callback)
        elseif callback then callback()
        end

        self.is_face_up = false
    end

    function self:change_theme(number)
        if 0 >= number or 4 < number then
            error("card theme number must be between 1 and 4", 2)
        end

        local back = self.group:find_child("back")
        local children = back.children
        for i,v in ipairs(children) do
            if i == number then v.opacity = 255
            else v.opacity = 0
            end
        end
    end

    --[[
        Move the card to a new group.

        @param group : the group which the card will move to
        @param face_front : boolean, indicates the card will face front
        @param face_back : boolean, indicates the card will be turned over
        @param position : the new position relative to the new group
    --]]

    function self:move_card(group, face_front, face_back, to_top, to_back, position,
                            wait_duration, cb, duration)
        if not group then error("needs a group to move the card to", 2) end
        assert(not (face_back and face_front))
        assert(not (to_top and to_back))
        if not type(wait_duration) == "number" then error("wait needs a number", 2) end
        if not position then position = {0,0,0} end
        if not duration then duration = CARD_MOVE_DURATION end
        self.position = position

        Utils.move_element_to_group(self.group, group, position,
                duration, to_top, to_back, wait_duration,
                function()
                    if face_back then
                        self:face_back(cb)
                    elseif face_front then
                        self:face_front(cb)
                    elseif
                        cb then cb()
                    end
                end)
    end

end)

Cards = {}
for _, suit in pairs(Suits) do
   for __, rank in pairs(Ranks) do
      table.insert(Cards, Card(rank, suit))
   end
end

function rigged_cards()
    Cards = {
           -- HEARTS
       Card("ACE","HEARTS"),
       Card("TWO","HEARTS"),
       Card("THREE","HEARTS"),
       Card("FOUR","HEARTS"),
       Card("FIVE","HEARTS"),
       Card("SIX","HEARTS"),
       Card("SEVEN","HEARTS"),
       Card("EIGHT","HEARTS"),
       Card("NINE","HEARTS"),
       Card("TEN","HEARTS"),
       Card("JACK","HEARTS"),
       Card("QUEEN","HEARTS"),
       Card("KING","HEARTS"),
       -- DIAMONDS
       Card("ACE","DIAMONDS"),
       Card("TWO","DIAMONDS"),
       Card("THREE","DIAMONDS"),
       Card("FOUR","DIAMONDS"),
       Card("FIVE","DIAMONDS"),
       Card("SIX","DIAMONDS"),
       Card("SEVEN","DIAMONDS"),
       Card("EIGHT","DIAMONDS"),
       Card("NINE","DIAMONDS"),
       Card("TEN","DIAMONDS"),
       Card("JACK","DIAMONDS"),
       Card("QUEEN","DIAMONDS"),
       Card("KING","DIAMONDS"),
       --SPADES
       Card("ACE","SPADES"),
       Card("TWO","SPADES"),
       Card("THREE","SPADES"),
       Card("FOUR","SPADES"),
       Card("FIVE","SPADES"),
       Card("SIX","SPADES"),
       Card("SEVEN","SPADES"),
       Card("EIGHT","SPADES"),
       Card("NINE","SPADES"),
       Card("TEN","SPADES"),
       Card("JACK","SPADES"),
       Card("QUEEN","SPADES"),
       Card("KING","SPADES"),
       --CLUBS
       Card("ACE","CLUBS"),
       Card("TWO","CLUBS"),
       Card("THREE","CLUBS"),
       Card("FOUR","CLUBS"),
       Card("FIVE","CLUBS"),
       Card("SIX","CLUBS"),
       Card("SEVEN","CLUBS"),
       Card("EIGHT","CLUBS"),
       Card("NINE","CLUBS"),
       Card("TEN","CLUBS"),
       Card("JACK","CLUBS"),
       Card("QUEEN","CLUBS"),
       Card("KING","CLUBS"),
    }
end

Deck = Class(nil,
function(self, ...)
    self.cards = {}
    self.find_card = {}
    for _,suit in pairs(Suits)do
        self.find_card[suit.name] = {}
    end

    self.group = Group{position = Utils.deepcopy(CARD_STARTING_POSITION)}
    screen:add(self.group)

    for _, card in ipairs(Cards) do
        table.insert(self.cards, card)
        self.find_card[card.suit.name][card.rank.num] = card
        if not card.group.parent then
            self.group:add(card.group)
            --        screen:add(card.group)
        end
    end

    function self:shuffle()
        local swapcard
        for i=1,#self.cards do
            swapcard = math.random(i, #self.cards)
            self.cards[i], self.cards[swapcard] = self.cards[swapcard], self.cards[i]
        end
    end

    function self:deal(n)
        assert(n <= #self.cards)
        local hand = {}
        local card
        for i=1,n do
            card = table.remove(self.cards)
            table.insert(hand, card)
        end
        return hand
    end

    function self:reset()
        self.cards = {}
        for _, card in ipairs(Cards) do
            table.insert(self.cards, card)
        end
    end

end)
