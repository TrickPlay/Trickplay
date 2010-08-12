local engine = GameEngine()

{
   [HAND_NOT_INITIALIZED] =
      function()
         engine:initialize_hand()
         engine:hole_deal()
         engine:hole_set_action()
         engine:hole_betting_til_block()
      end,
   [HOLE_BETTING] =
      function()
         engine:hole_betting_til_block(bet)
         if engine.round == Rounds.FLOP then
            engine:flop_deal()
            engine:flop_set_action()
            engine:flop_betting_til_block()
         end
      end,
   [FLOP_BETTING] =
      function()
         engine:flop_betting_til_block(bet)
         if engine.round == Rounds.TURN then
            engine:turn_deal()
            engine:turn_set_action()
            engine:turn_betting_til_block()
         end
      end,
   [TURN_BETTING] =
      function()
         engine:turn_betting_til_block(bet)
         if engine.round == Rounds.RIVER then
            engine:river_deal()
            engine:river_set_action()
            engine:river_betting_til_block()
         end
      end,
   [RIVER_BETTING] =
      function()
         engine:river_betting_til_block(bet)
         if engine.round == Rounds.DONE then
            --               engine:end_animate()
            engine:cleanup_and_reset()
         end
      end
}

function screen:on_key_down(k)
end

engine:initialize_game()
engine:initialize_hand()
engine:hole_deal()
engine:hole_betting()
