PlayerSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
    }
     
    --create the components

    view.items = {
        {
            Rectangle{color={255,0,0}, width=200, height=100, position={100, 100}, extra={text = "Fold"}},
            Rectangle{color={0,0,255}, width=200, height=100, position={350, 100}, extra={text = "Call"}},
            Rectangle{color={0,255,0}, width=200, height=100, position={600, 100}, extra={text = "Bet: "..model.bet.CURRENT_BET}},
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
        self:set_controller(PlayerSelectionController(self))
    end
    
    view.stack = chipStack()
    view.stack.group.position = {500,500}
    screen:add(view.stack.group)
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.PLAYER_SELECTION then
            self.ui.opacity = 255
            self.ui:raise_to_top()
            print("Showing Player Selection UI")
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
            t.text = "Bet:"..model.bet.CURRENT_BET
            t.anchor_point = {t.w/2, t.h/2}
            
            if model.bet.CURRENT_BET > self.stack:count() then
                self.stack:pushChip( Chip(10, Image{src = "pokerchip10.png"}) )
                self.stack:convertUp()
                --self.stack:arrangeChips(15, 150)
                self.stack:arrangeChips(15)
            elseif model.bet.CURRENT_BET < self.stack:count() then
                self.stack:convertDown(10)
                self.stack:popChip()
                --self.stack:arrangeChips(15, 150)
                self.stack:arrangeChips(15)
            end
            
            
            
        else
            print("Hiding Player Selection UI")
            self.ui:complete_animation()
            self.ui.opacity = 255
        end
    end

end)
