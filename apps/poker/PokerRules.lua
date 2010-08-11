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

STRAIGHT_FLUSH = {
   name="Straight Flush",
   present_in=
      function (hand)
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
         
         -- incomplete
      end,
   comparator=
      function(hand1, hand2)
         return true
         -- both hand1 and hand2 must have this poker hand
         --incomplete
      end
}

FOUR_OF_A_KIND = {
   name="Four of a Kind",
   present_in=
      function(hand)
         return has_n_of_a_kind(hand, 4)
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
               
            end
         end
      end,
   comparator=
      function(hand1,hand2)
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
         local flush_suits = {}
         for suit,cards in pairs(buckets) do
            if #cards >= 5 then
               table.insert(flush_suits,suit)
               for i = #cards-5,1,-1 do
                  table.remove(cards,i)
               end
            else
               buckets[suit] = nil
            end
         end

         local top_cards = {}
         for i = 5,1,-1 do
            for _,suit in ipairs(flush_suits) do
               local cards = buckets[suit]
               table.insert(top_cards,cards[i].rank.num)
            end
            
            local max = 0
         end


      end
}

STRAIGHT = {
   name="Straight",
   present_in=
      function(hand)
      end,
   comparator=
      function(hand1,hand2)
      end
}

THREE_OF_A_KIND = {
   name="Three of a Kind",
   present_in=
      function(hand)
         return has_n_of_a_kind(hand, 3)
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