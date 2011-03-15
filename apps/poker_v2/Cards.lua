if not Class then
    dofile("Class.lua")
end

function Suit(name)
    return {
        name = name,
      abbv = string.sub(name, 1, 1)
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
        ["Clubs"] = "CLUB",
        ["Diamonds"] = "DIAMOND",
        ["Hearts"] = "HEART",
        ["Spades"] = "SPADE",
    }
    return suits[card.suit.name]..card.rank.num
end


-- Get a group with the image of a card's front/back
function getCardGroup(card, args, face)
    -- load card back image
    if not assetman:has_image_of_name("card_back") then
        assetman:load_image("assets/Card_Reverse.png", "card_back")
    end
    -- load card front image
    if not assetman:has_image_of_name(getCardImageName(card)) then
        assetman:load_image("assets/cards/"..getCardImageName(card)..".png",
            getCardImageName(card))
    end
    
    local card_front = assetman:get_clone(getCardImageName(card))
    local card_back = assetman:get_clone("card_back")
    local card_group = assetman:create_group({
        children = {card_back, card_front},
        extra = {face = true, card_name = getCardImageName(card)},
        anchor_point = {card_front.w/2, card_front.h/2}
    })

   if args and type(args) == "table" then for k, v in pairs(args) do
      card_group[k] = v
   end end
   
   if face == "back" then
      card_group.extra.face = false
      card_front.opacity = 0
      card_group.extra.rotation = 180
      card_group.y_rotation = {card_group.extra.rotation, 0, 0}
   end

   return card_group, card_front, card_back
end

function resetCardGroup(card_group)

   local front = card_group.children[2]
   local back = card_group.children[1]

   card_group.extra.face = false
   front.opacity = 0
   back.opacity = 255
   card_group.opacity = 255
   card_group.extra.rotation = 180
   card_group.y_rotation = { card_group.extra.rotation, 0, 0 }

end

-- Flip a card, return true if the front is showing
function flipCard(cardGroup)
   
    if not cardGroup.extra.rotation then cardGroup.extra.rotation = 180
    else cardGroup.extra.rotation = cardGroup.extra.rotation + 180
    end
   
    cardGroup.extra.face = not cardGroup.extra.face
   
    local front = cardGroup.children[2] --cardGroup:find_child("front")
    local back = cardGroup.children[1] --cardGroup:find_child("back")
    assert(front)
    assert(back)
   
    cardGroup:complete_animation()
    cardGroup:animate{
        y_rotation = cardGroup.extra.rotation - 90,
        duration = 200,
        on_completed = function()
         
            if cardGroup.extra.face then
                front.opacity = 255
                back.opacity = 0
            else
                front.opacity = 0
                back.opacity = 255
            end
         
            cardGroup:animate {
                y_rotation = cardGroup.extra.rotation,
                duration = 200,
            }
        end
    }

end

function Rank(name, num, abbv)
    return {
        name = name,
        num = num,
        abbv = abbv
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
function(self, rank, suit)

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

    self.group, self.front, self.back = getCardGroup(self, nil, "back")

    function self:equals(card)
        return self.rank == card.rank and self.suit == card.suit
    end

    function self:dealloc()
        assetman:remove_clone(self.front)
        assetman:remove_clone(self.back)
        assetman:remove_group(self.group.name)
        self.front = nil
        self.back = nil
        self.group = nil
        self.name = nil
        self.abbv = nil
        self.rank = nil
        self.suit = nil
    end

end)

Cards = {}
---[[
for _, suit in pairs(Suits) do
    for __, rank in pairs(Ranks) do
        table.insert(Cards, Card(rank, suit))
    end
end
--]]
--[[
-- for testing split pot
for i = 1,52 do
    table.insert(Cards, Card("ACE", "HEARTS"))
end
--]]
function get_rigged_cards()
    return {
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
        Card("ACE","DIAMONDS"),
        -- Community Cards
        Card("ACE","SPADES"),
        Card("KING","SPADES"),
        Card("QUEEN","SPADES"),
        Card("JACK","SPADES"),
        Card("TEN","SPADES"),
        -- hole 6
        Card("TWO","DIAMONDS"),
        Card("THREE","DIAMONDS"),
        -- hole 5
        Card("FOUR","DIAMONDS"),
        Card("FIVE","DIAMONDS"),
        -- hole 4
        Card("SIX","DIAMONDS"),
        Card("SEVEN","DIAMONDS"),
        -- hole 3
        Card("EIGHT","DIAMONDS"),
        Card("NINE","DIAMONDS"),
        -- hole 2
        Card("TEN","DIAMONDS"),
        Card("JACK","DIAMONDS"),
        -- hole 1
        Card("QUEEN","DIAMONDS"),
        Card("KING","DIAMONDS")
    }
end

Deck = Class(nil,
function(self, ...)
    local cards = {}
    for _, card in ipairs(Cards) do
        table.insert(cards, card)
    end

    function self:shuffle()
        local swapcard
        for i=1,#cards do
            swapcard = math.random(i, #cards)
            cards[i], cards[swapcard] = cards[swapcard], cards[i]
        end
    end

    function self:deal(n)
        assert(n <= #cards)
        local hand = {}
        local card
        for i=1,n do
            card = table.remove(cards)
            table.insert(hand, card)
        end
        return hand
    end

    function self:reset()
        cards = {}
        for _, card in ipairs(Cards) do
            table.insert(cards, card)
        end
    end
   
    self.cards = cards

end)
