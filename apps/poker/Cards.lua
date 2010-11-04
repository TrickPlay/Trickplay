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
      ["Clubs"] = "CLUB",
      ["Diamonds"] = "DIAMOND",
      ["Hearts"] = "HEART",
      ["Spades"] = "SPADE",
   }
   return suits[card.suit.name]..card.rank.num
end


local card_back_image = Image{src = "assets/Card_Reverse.png", opacity = 0}
screen:add(card_back_image)
-- Get a group with the image of a card's front/back
local card_front_images = {}
function getCardGroup(card, args, face)
   if not card_front_images[getCardImageName(card)] then
      card_front_images[getCardImageName(card)] = 
         Image{ src="assets/cards/"..getCardImageName(card)..".png", name="front", opacity=0}
      screen:add(card_front_images[getCardImageName(card)])
   end

   local cardImage = Clone{source=card_front_images[getCardImageName(card)], name="front"}
   local cardBack = Clone{source = card_back_image, name="back" }
   local cardGroup = Group{ children={cardBack,cardImage}, name="card",extra={face = true}, anchor_point = {cardImage.w/2, cardImage.h/2} }

   if args and type(args) == "table" then for k, v in pairs(args) do
      cardGroup[k] = v
   end end
   
   if face=="back" then
      cardGroup.extra.face = false
      cardImage.opacity = 0
      cardGroup.extra.rotation = 180
      cardGroup.y_rotation = { cardGroup.extra.rotation, 0, 0 }
   end

   return cardGroup
end

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
function flipCard(cardGroup)
   
   if not cardGroup.extra.rotation then cardGroup.extra.rotation = 180
   else cardGroup.extra.rotation = cardGroup.extra.rotation + 180
   end
   
   cardGroup.extra.face = not cardGroup.extra.face
   
   local front = cardGroup:find_child("front")
   local back = cardGroup:find_child("back")
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
         
         cardGroup:animate{
            y_rotation = cardGroup.extra.rotation,
            duration = 200,
            }
      end
   }

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

   self.group = getCardGroup(self, nil, "back")

   function self:equals(card)
      return self.rank == card.rank and self.suit == card.suit
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
