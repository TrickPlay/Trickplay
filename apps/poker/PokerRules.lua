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
               a.rank.num < b.rank.num
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

HIGH_CARD = {
   name="High Card",
   present_in=
      function(hand)
         return #hand > 0
      end
   comparator=
      function(hand1, hand2)
         local hand1_copy = {}
         for _,card in ipairs(hand1) do
            table.insert(hand1_copy,card)
         end
         table.sort(
            hand1_copy,
            function(a,b)
               a.rank.num < b.rank.num
            end
         )
         local hand2_copy = {}
         for _,card in ipairs(hand2) do
            table.insert(hand2_copy,card)
         end
         table.sort(
            hand2_copy,
            function(a,b)
               a.rank.num < b.rank.num
            end
         end

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
   HIGH_CARD
}