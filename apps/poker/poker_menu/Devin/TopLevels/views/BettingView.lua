BettingView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
    }
     
    --create the components

    view.items = {
        {
            Rectangle{color={255,0,0}, width=200, height=100, position={100, 100}, extra={text = "Fold"}},
            Rectangle{color={0,0,255}, width=200, height=100, position={350, 100}, extra={text = "Call"}},
            Rectangle{color={0,255,0}, width=200, height=100, position={600, 100}, extra={text = "Bet: "..model.bet.DEFAULT_BET}},
        },
    }
    
    view.text = {}
    
    for i, table in ipairs(view.items) do
        for k,v in ipairs(table) do
            local text = Text{ font = "Sans 38px", color = "FFFFFF", text = v.extra.text }
            view.text[k] = text
            text.anchor_point = {text.w/2, text.h/2}
            text.position = {v.position[1] + v.w/2, v.position[2] + v.h/2}
            local g = Group{children={v, text}}
            view.items[i][k] = g
        end
    end

    --background ui
    view.background_ui = Group{name = "checkoutBackground_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --ui that actually moves
    view.moving_ui=Group{name="checkoutMoving_ui", position=HIDE_TOP}
--    view.moving_ui:add()
    --all ui junk for this view
    view.ui=Group{name="checkout_ui", position={0,0}}
    for _,v in ipairs(view.items) do
        view.ui:add(unpack(v))
    end

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(BettingController(self))
    end
    
    view.stack = chipStack()
    view.stack.group.position = {1800,500}
    screen:add(view.stack.group)
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.PLAYER_BETTING then
            self.ui.opacity = 255
            self.ui:raise_to_top()
            print("Showing Betting UI")
            for i,t in ipairs(view.items) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_subselection_index()) then
                        item.opacity = 255
                    else
                        item.opacity = 100
                    end
                end
            end
            
            local t = view.text[3]
            t.text = "Bet:"..model.players[1].bet
            t.anchor_point = {t.w/2, t.h/2}
            
            local player = model.players[1]
            local playerStack = player.chips
            local stack = view.stack
            
            -- Add chips to the bet
            stack:setChips(player.bet)
            --playerStack:setChips(player.money)
            
            stack:arrangeChips(15)
            playerStack:arrangeChips(15,150)
            
        else
            print("Hiding Betting UI")
            self.ui:complete_animation()
            self.ui.opacity = 255
        end
    end

end)

--[[
            if player.bet > stack:count() then
                while player.bet > stack:count() do
                    playerStack:convertDown(10)    
                    
                    local c = playerStack:popChip( playerStack )
                    --print("Chip position", c.image.position[1], c.image.position[2])
                    stack:pushChip( c )
                    stack:convertUp()
                    
                    playerStack:arrangeChips(15, 150)
                    stack:arrangeChips(15)
                end
            -- Give chips back to the player
            elseif player.bet < stack:count() then
                while player.bet < stack:count() do
                    stack:convertDown(10)
                    local c = stack:popChip( true )
                    stack:arrangeChips(15)
                    
                    playerStack:pushChip( c )
                    playerStack:convertUp()
                    playerStack:arrangeChips(15, 150)
                end
            end
]]