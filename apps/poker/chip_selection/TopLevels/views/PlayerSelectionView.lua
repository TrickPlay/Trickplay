PlayerSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
    }
     
    --create the components

    view.items = {
        {
            Rectangle{color={255,255,255}, width=100, height=100, position={100, 100}},
            Rectangle{color={255,255,255}, width=100, height=100, position={800, 100}},
            Rectangle{color={255,255,255}, width=100, height=100, position={1700, 100}},
        },
        {
            Rectangle{color={255,255,255}, width=100, height=100, position={100, 800}},
            Rectangle{color={255,255,255}, width=100, height=100, position={800, 800}},
            Rectangle{color={255,255,255}, width=100, height=100, position={1700, 800}},
        }
    }

    --background ui
    view.background_ui = Group{name = "checkoutBackground_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --ui that actually moves
    view.moving_ui=Group{name="checkoutMoving_ui", position=HIDE_TOP}
--    view.moving_ui:add()
    --all ui junk for this view
    view.ui=Group{name="checkout_ui", position={0,0}}
    view.ui:add(unpack(view.items[1]))
    view.ui:add(unpack(view.items[2]))

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(PlayerSelectionController(self))
    end
    
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
                        item.opacity = 0
                    end
                end
            end
        else
            print("Hiding Player Selection UI")
            self.ui:complete_animation()
            self.ui.opacity = 255
        end
    end

end)
