if not sort_hand then
   dofile("Utils.lua")
end

function has_n_of_a_kind(hand, n)
   local h = sort_hand(hand)
   local counter = 0
   local rank = nil
   for i=#h, 1, -1 do
      if h[i].rank == rank then
         counter = counter+1
         if counter >= n then
            for j=1, counter do
               table.remove(h, i)
            end
            return true, rank, h
         end
      else
         rank = h[i].rank
         counter = 1
      end
   end
   return false
end

function get_n_of_a_kind(hand, n)
   if not has_n_of_a_kind(hand, n) then
      error("hand does not have "..n.."of a kind", 2)
   end

   local cards = {}
   local h = sort_hand(hand)
   local rank = nil
   for i = #h, 1, -1 do
      if h[i].rank == rank then
         counter = counter+1
         if counter >= n then
            for j = 1,counter do
               table.insert(cards, table.remove(h, i))
            end
            return cards
         end
      else
         rank = h[i].rank
         counter = 1
      end
   end
end

function n_of_a_kind_compare(hand1,hand2,N)
   local pair1_found, rank1, rem_hand1 = has_n_of_a_kind(hand1, N)
   assert(pair1_found)
   
   local pair2_found, rank2, rem_hand2 = has_n_of_a_kind(hand2, N)
   assert(pair2_found)
   
   if rank1.num > rank2.num then
      return -1
   elseif rank1.num < rank2.num then
      return 1
   else
      for i = 1,5-N do
         local p1card = table.remove(rem_hand1,#rem_hand1)
         local p2card = table.remove(rem_hand2,#rem_hand2)
         if p1card.rank.num > p2card.rank.num then
            return -1
         elseif p1card.rank.num < p2card.rank.num then
            return 1
         end
      end
      return 0
   end
end

function get_best_flush(hand)
   local sorted_hand = sort_hand(hand)
   local buckets = {
      [Suits.CLUBS] = {},
      [Suits.DIAMONDS] = {},
      [Suits.HEARTS] = {},
      [Suits.SPADES] = {}
   }
   for _,card in ipairs(sorted_hand) do
      table.insert(buckets[card.suit], card)
   end

   local flush_found = false
   local flush_suits = {}
   for suit,cards in pairs(buckets) do
      if #cards >= 5 then
         flush_suits[suit] = true
         flush_found = true
         for i = #cards-5,1,-1 do
            table.remove(cards,i)
         end
      else
         buckets[suit] = nil
      end
   end

   assert(flush_found)

   local top_suits = {}
   for i = 5,1,-1 do
      local top_rank_num = Ranks.TWO.num
      for suit,_ in pairs(flush_suits) do
         local cards = buckets[suit]
         if cards[i].rank.num > top_rank_num then
            top_rank_num = cards[i].rank.num
            top_suits = {[suit]=true}
         elseif cards[i].rank.num == top_rank_num then
            top_suits[suit] = true
         end
      end
      flush_suits = top_suits
   end

   local counter = 0
   local cards = {}
   for suit, _ in pairs(flush_suits) do
      counter = counter+1
      cards = buckets[suit]
   end
   return cards
end

-- returns cards in descending order
function get_best_straight(hand)
   local sorted_hand = sort_hand(hand)
   local last_rank_num
   local aces = {}
   local straight_so_far = {}
   for i=#sorted_hand, 1, -1 do
      if sorted_hand[i].rank == Ranks.ACE then
         table.insert(aces, sorted_hand[i])
      end
      if #straight_so_far == 0 then
         -- start a new straight
         table.insert(straight_so_far, sorted_hand[i])
      elseif sorted_hand[i].rank.num == last_rank_num then
         -- skip the current card, same rank as last card
      elseif sorted_hand[i].rank.num == last_rank_num-1 then
         -- insert new card into straight, as it fits
         table.insert(straight_so_far, sorted_hand[i])
      else -- start a new straight template
         straight_so_far = {sorted_hand[i]}
      end

      last_rank_num = sorted_hand[i].rank.num
      if #straight_so_far >= 5 then
         return straight_so_far
      end
   end
   if #aces > 0 and last_rank_num == Ranks.TWO.num then
      table.insert(straight_so_far, aces[1])
   end
   if #straight_so_far >= 5 then
      return straight_so_far
   else
      return {}
   end
end

function get_best_straight_flush(hand)
   if not hand then error("hand is nil!", 2) end
   local sorted_hand = sort_hand(hand)
   local buckets = {
      [Suits.CLUBS] = {},
      [Suits.DIAMONDS] = {},
      [Suits.HEARTS] = {},
      [Suits.SPADES] = {}
   }
   for i=#sorted_hand, 1, -1 do
      local card = sorted_hand[i]
      table.insert(buckets[card.suit], card)
   end

   local straight_flushes = {}
   for suit, cards in pairs(buckets) do
      local straight = get_best_straight(cards)
      if #straight == 5 then
         straight_flushes[suit] = straight
      end
   end

   local top_rank_num = Ranks.TWO.num
   local top_suits = {}
   local straight_flush = {}
   for suit,straight in pairs(straight_flushes) do
      if straight[1].rank.num > top_rank_num then
         top_rank_num = straight[1].rank.num
         top_suits = {[suit]=true}
      elseif straight[1].rank.num == top_rank_num then
         top_suits[suit] = true
      end
   end
   for suit,_ in pairs(top_suits) do
      straight_flush = straight_flushes[suit]
   end
   return straight_flush
end

STRAIGHT_FLUSH = {
   name="Straight Flush",
   present_in=
      function (hand)
         if not hand then error("hand is nil, in STRAIGHT_FLUSH.present_in()", 2) end
         return #get_best_straight_flush(hand) == 5
      end,
   get_best=
      function(hand)
         return get_best_straight_flush(hand)
      end,
   comparator=
      function(hand1, hand2)
         -- get_best_straight returns cards in descending order
         local straight_flush1 = get_best_straight_flush(hand1)
         assert(#straight_flush1 ~= 0)
         local straight_flush2 = get_best_straight_flush(hand2)
         assert(#straight_flush2 ~= 0)

         if straight_flush1[1].rank.num > straight_flush2[1].rank.num then
            return -1
         elseif straight_flush1[1].rank.num < straight_flush2[1].rank.num then
            return 1
         else
            return 0
         end
      end
}

FOUR_OF_A_KIND = {
   name="4 of a Kind",
   present_in=
      function(hand)
         return has_n_of_a_kind(hand, 4)
      end,
   get_best=
      function(hand)
         return get_n_of_a_kind(hand, 4)
      end,
   comparator=
      function(hand1,hand2)
         return n_of_a_kind_compare(hand1,hand2,4)
      end
}

FULL_HOUSE = {
   name="Full House",
   present_in=
      function(hand)
         local success, rank, rem_hand = has_n_of_a_kind(hand, 3)
         if success then
            return has_n_of_a_kind(rem_hand, 2)
         end
         return false
      end,
   get_best=
      function(hand)
         local triplet = get_n_of_a_kind(hand, 3)
         local success, rank, rem_hand = has_n_of_a_kind(hand, 3)
         if not success then error("fail", 2) end
         local pair = get_n_of_a_kind(rem_hand, 2)
         table.insert(triplet, table.remove(pair))
         table.insert(triplet, table.remove(pair))

         return triplet
      end,
   comparator=
      function(hand1,hand2)
         local success, highrank1, rem_hand1 = has_n_of_a_kind(hand1, 3)
         assert(success)
         local lowrank1
         success, lowrank1, rem_hand1 = has_n_of_a_kind(rem_hand1, 2)
         assert(success)

         local success, highrank2, rem_hand2 = has_n_of_a_kind(hand2, 3)
         assert(success)
         local lowrank2
         success, lowrank2, rem_hand2 = has_n_of_a_kind(rem_hand2, 2)
         assert(success)

         if highrank1.num > highrank2.num then
            return -1
         elseif highrank1.num < highrank2.num then
            return 1
         elseif lowrank1.num > lowrank2.num then
            return -1
         elseif lowrank1.num < lowrank2.num then
            return 1
         else
            return 0
         end
      end
}

FLUSH = {
   name="Flush",
   present_in=
      function(hand)
         local sorted_hand = sort_hand(hand)
         local buckets = {
            [Suits.CLUBS] = {},
            [Suits.DIAMONDS] = {},
            [Suits.HEARTS] = {},
            [Suits.SPADES] = {}
         }
         for _,card in ipairs(sorted_hand) do
            table.insert(buckets[card.suit], card)
         end
         for suit,cards in pairs(buckets) do
            if #cards >= 5 then
               return true
            end
         end
      end,
   get_best=
      function(hand)
         return get_best_flush(hand)
      end,
   comparator=
      function(hand1,hand2)
         local cards1 = get_best_flush(hand1)
         assert(#cards1 == 5)
         local cards2 = get_best_flush(hand2)
         assert(#cards2 == 5)


         for i = 5, 1, -1 do
            if cards1[i].rank.num > cards2[i].rank.num then
               return -1
            elseif cards1[i].rank.num < cards2[i].rank.num then
               return 1
            end
         end
         return 0
      end
}

STRAIGHT = {
   name="Straight",
   present_in=
      function(hand)
         local straight = get_best_straight(hand)
         return #straight ~= 0
      end,
   get_best =
      function(hand)
         return get_best_straight(hand)
      end,
   comparator=
      function(hand1,hand2)
         -- get_best_straight returns cards in descending order
         local straight1 = get_best_straight(hand1)
         assert(#straight1 ~= 0)
         local straight2 = get_best_straight(hand2)
         assert(#straight2 ~= 0)

         if straight1[1].rank.num > straight2[1].rank.num then
            return -1
         elseif straight1[1].rank.num < straight2[1].rank.num then
            return 1
         else
            return 0
         end
      end
}

THREE_OF_A_KIND = {
   name="3 of a Kind",
   present_in=
      function(hand)
         return has_n_of_a_kind(hand, 3)
      end,
   get_best=
      function(hand)
         return get_n_of_a_kind(hand, 3)
      end,
   comparator=
      function(hand1,hand2)
         return n_of_a_kind_compare(hand1,hand2,3)
      end
}

TWO_PAIR = {
   name="Two Pair",
   present_in=
      function(hand)
         local success, rank, rem_hand = has_n_of_a_kind(hand, 2)
         if success then
            return has_n_of_a_kind(rem_hand, 2)
         end
         return false
      end,
   get_best=
      function(hand)
         local pair1 = get_n_of_a_kind(hand, 2)
         local success, rank, rem_hand = has_n_of_a_kind(hand, 2)
         if not success then error("fail", 2) end
         local pair2 = get_n_of_a_kind(rem_hand, 2)
         table.insert(pair2, table.remove(pair1))
         table.insert(pair2, table.remove(pair1))

         return pair2
      end,
   comparator=
      function(hand1,hand2)
         local success, highrank1, rem_hand1 = has_n_of_a_kind(hand1, 2)
         assert(success)
         local lowrank1
         success, lowrank1, rem_hand1 = has_n_of_a_kind(rem_hand1, 2)
         assert(success)
         local success, highrank2, rem_hand2 = has_n_of_a_kind(hand2, 2)
         assert(success)
         local lowrank2
         success, lowrank2, rem_hand2 = has_n_of_a_kind(rem_hand2, 2)
         assert(success)

         if highrank1.num > highrank2.num then
            return -1
         elseif highrank1.num < highrank2.num then
            return 1
         elseif lowrank1.num > lowrank2.num then
            return -1
         elseif lowrank1.num < lowrank2.num then
            return 1
         else
            local rank_num1 = rem_hand1[#rem_hand1].rank.num
            local rank_num2 = rem_hand2[#rem_hand2].rank.num
            if rank_num1 > rank_num2 then
               return -1
            elseif rank_num1 < rank_num2 then
               return 1
            else
               return 0
            end
         end
      end
}

ONE_PAIR = {
   name="One Pair",
   present_in=
      function(hand)
         return has_n_of_a_kind(hand, 2)
         -- local sorted_hand = sort_hand(hand)
         -- for i=1,#sorted_hand do
         --    local rank = sorted_hand[i].rank
         --    for j=i+1,#sorted_hand do
         --       if sorted_hand[j].rank == rank then
         --          return true
         --       end
         --    end
         -- end
         -- return false
      end,
   get_best=
      function(hand)
         return get_n_of_a_kind(hand, 2)
      end,
   comparator=
      function(hand1,hand2)
         local N = 2
         local pair1_found, rank1, rem_hand1 = has_n_of_a_kind(hand1, N)
         assert(pair1_found)


         local pair2_found, rank2, rem_hand2 = has_n_of_a_kind(hand2, N)
         assert(pair2_found)

         if rank1.num > rank2.num then
            return -1
         elseif rank1.num < rank2.num then
            return 1
         else
            for i = 1,5-N do
               local p1card = table.remove(rem_hand1,#rem_hand1)
               local p2card = table.remove(rem_hand2,#rem_hand2)
               if p1card.rank.num > p2card.rank.num then
                  return -1
               elseif p1card.rank.num < p2card.rank.num then
                  return 1
               end
            end
            return 0
         end
      end
}

HIGH_CARD = {
   name="High Card",
   present_in=
      function(hand)
         return #hand > 0
      end,
   get_best =
      function(hand)
         local h = sort_hand(hand)
         return h[#h]
      end,
   comparator=
      function(hand1, hand2)
         local hand1_copy = {}
         for _,card in ipairs(hand1) do
            table.insert(hand1_copy,card)
         end
         table.sort(
            hand1_copy,
            function(a,b)
               return a.rank.num < b.rank.num
            end
         )
         local hand2_copy = {}
         for _,card in ipairs(hand2) do
            table.insert(hand2_copy,card)
         end
         table.sort(
            hand2_copy,
            function(a,b)
               return a.rank.num < b.rank.num
            end
         )

         for i=#hand1_copy, #hand1_copy-4, -1 do
            if hand1_copy[i].rank.num > hand2_copy[i].rank.num then
               return -1
            elseif hand1_copy[i].rank.num < hand2_copy[i].rank.num then
               return 1
            end
         end
         return 0
      end
}

function compare_hands(hand1, hand2)
   local pin1, pin2
   for _,poker_hand in ipairs(PokerHands) do
      pin1 = poker_hand.present_in(hand1)
      pin2 = poker_hand.present_in(hand2)
      if pin1 and pin2 then
         return poker_hand.comparator(hand1,hand2), poker_hand
      elseif pin1 then
         return -1, poker_hand
      elseif pin2 then
         return 1, poker_hand
      end
   end
   return 0, poker_hand
end

function get_best(hand)
   if not hand then error("get_best passed a nil hand", 2) end
   for position, poker_hand in ipairs(PokerHands) do
      if poker_hand.present_in(hand) then
         return poker_hand, position
      end
   end
   error("fail.")
end

function get_best_cards(hand)
    poker_hand = get_best(hand)
    return poker_hand.get_best(hand)
end

function get_best_5(hand)
    local orig_hand = {}
    for i,card in ipairs(hand) do
        orig_hand[i] = card
    end
    local tmp_hand = get_best_cards(hand)
    for i = #orig_hand,1,-1 do
        for j = 1,#tmp_hand do
            if orig_hand[i] == tmp_hand[j] then
                table.remove(orig_hand, i)
                break
            end
        end
    end

    if #tmp_hand >= 5 then return tmp_hand end
    
    local card
    for i = 5-#tmp_hand,1,-1 do
        card = HIGH_CARD.get_best(orig_hand)
        for i,v in ipairs(orig_hand) do
            if v == card then
                table.remove(orig_hand, i)
                break
            end
        end
        table.insert(tmp_hand, card)
    end

    return tmp_hand
end

PokerHands = {
   STRAIGHT_FLUSH,
   FOUR_OF_A_KIND,
   FULL_HOUSE,
   FLUSH,
   STRAIGHT,
   THREE_OF_A_KIND,
   TWO_PAIR,
   ONE_PAIR,
   HIGH_CARD
}
