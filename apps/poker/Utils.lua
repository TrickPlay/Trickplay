function sort_hand(hand)
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