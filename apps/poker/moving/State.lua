State = Class(nil,function(self,...)
   local num = 1
   local player_num = 1
   local enable_input = true
   function self:set_state(number, enable)
      num=number
      enable_input=enable
   end

   function self:get_state()
      return num, enable_input
   end

   function self:get_num()
      return num
   end

   function self:get_player()
      return player_num
   end
   function self:set_player(player_n)
      player_num = player_n
   end
end)