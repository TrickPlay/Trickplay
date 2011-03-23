BettingView = Class(View, function(view, model, ...)
    view._base.init(view, router)

    view.ui = assetman:create_group({})

    function view:add(object) view.ui:add(object) end

    function view:update()
        local controller = router:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.PLAYER_BETTING then
            ctrlman:start_accepting_ctrls()

            self.ui.opacity = 255
            self.ui:raise_to_top()
--            print("Showing Betting UI")
            -- figures out whether "call" or "check" should be displayed
            
            local player = model.currentPlayer
            bet_text.text = "$"..player.bet

            local playerBet = player.betChips
            
            -- Add chips to the bet
            playerBet:set(player.bet)

        else
--            print("Hiding Betting UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

    
end)
