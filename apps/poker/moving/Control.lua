Control = Class(nil,
function(control,...)
   local side_effect_LUT = {
      computer=
         function()
         end,
      human=
         function()
         end,
   }

   local old_screen_on_key_down

   function control.on_event(control, event)
      if event=="keyboard" then
         -- disable keyboard
         old_screen_on_key_down, screen.on_key_down = screen.on_key_down, function()end

         print("keyboard disabled")
      elseif event=="timer" then
         --disable timer
         t:disable()
         print("timer disabled")
      end

      local num = state:get_state()
      local player_num = state:get_player()
      local next_player_num = (player_num % #players) + 1
      texts[player_num]:animate{duration=100,opacity = 0}
      texts[next_player_num]:animate{duration=100,opacity=255}
      state:set_player(next_player_num)

      if players[next_player_num].isHuman then
         print("enabling keyboard")
         screen.on_key_down, old_screen_on_key_down = old_screen_on_key_down, nil
      else
         print("enabling timer")
         t:enable{
            interval=1,
            on_timer=
               function()
                  control:on_event(TimerEvent{interval=1})
               end
         }
      end
   end
end)