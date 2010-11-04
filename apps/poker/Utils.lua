

function sort_hand(hand)
   if not hand then error("hand is nil!", 2) end
   local hand_copy = {}
   for _,card in ipairs(hand) do
      table.insert(hand_copy,card)
   end
   table.sort(
      hand_copy,
      function(a,b)
         return a.rank.num < b.rank.num
      end
   )
   return hand_copy
end

---
-- Returns the index of the first occurrence of the specified element
-- in hand, or -1 if hand does not contain the element. More formally,
-- returns the lowest index i such that card:equals(get(i)), or -1 if
-- there is no such index.
--
-- @param hand array  Array of cards
-- @param card Card  card to search for
--
-- @returns the index of the last occurrence of the specified element
-- in hand, or -1 if hand does not contain the element
function indexOf(hand, card)
   assert(type(hand)=="table")
   for i,hand_card in ipairs(hand) do
      if hand_card:equals(card) then
         return i
      end
   end
   return -1
end

---
-- Returns true if hand contains the specified element. More formally,
-- returns true if and only if hand contains at least one element e
-- such that card:equals(e).
--
-- @param hand array  Array of cards
-- @param card Card  card whose presence in hand is to be tested
-- @returns true if hand contains the specified card
function contains(hand, card)
   assert(type(hand)=="table")
   for i,hand_card in ipairs(hand) do
      if hand_card:equals(card) then
         return true
      end
   end
   return false
end

function count_outs(hand)
   -- make a local copy of h so any user of this interface doesn't go
   -- wtf when his hand turns into potatoes.
   local h = {}
   for _,card in ipairs(hand) do
      table.insert(h,card)
   end

   local targets = {}
   local out_table = {}
   for _, poker_hand in ipairs(PokerHands) do
      if poker_hand.present_in(h) then
         -- print(poker_hand.name .. " in hand!")
      else
         table.insert(targets, poker_hand)
         out_table[poker_hand] = 0
      end
   end

   for _, card in ipairs(Cards) do
      if not contains(h, card) then
         table.insert(h, card)
         for __, poker_hand in ipairs(targets) do
            if poker_hand.present_in(h) then
               out_table[poker_hand] = out_table[poker_hand] + 1
            end
         end
         table.remove(h)
      end
   end
   return out_table
end

--prints the mofok'n hand
function hand_print(hand)
   local str_builder = {}
   table.insert(str_builder, "\n\nThis hand contains:")
   assert(hand)
   for _,card in ipairs(hand) do
      table.insert(str_builder, "                     "..card.abbv)
   end
   table.insert(str_builder,"")
   print(table.concat(str_builder,"\n"))
end

Utils = {}
Utils.clamp = function(a, b, c)
    if b < a then return a
    elseif b > c then return c
    end

    return b
end

Utils.deepcopy = function(t)
    if type(t) ~= "table" then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            v = Utils.deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res, mt)
    return res
end
