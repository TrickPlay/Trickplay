CharacterSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
    }

    local chooseCharacterText = Text{
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLUE,
        position = {3000, 500},
        text = "Choose Character's"        
    }

    local timer = Timer()
    timer.interval = 2
    timer.on_timer = function(timer)
        timer:stop()
        timer.on_timer = nil
        timer = nil
        chooseCharacterText:animate{
            duration = CHANGE_VIEW_TIME, x = -3000,
            on_completed = function()
                chooseCharacterText:unparent()
                chooseCharacterText = nil
            end
        }
    end
         
    --create the components

    view.items = {
        {
            Rectangle{color={255,255,255}, width=100, height=100, position = model.default_player_locations[1] },
            Rectangle{color={255,255,255}, width=100, height=100, position = model.default_player_locations[2] },
            Rectangle{color={255,255,255}, width=100, height=100, position = model.default_player_locations[3] },
            Rectangle{color={255,255,255}, width=100, height=100, position = model.default_player_locations[4] },
        },
        {
            Rectangle{color={255,255,255}, width=100, height=100, position = model.default_player_locations[5] },
            Text{font=CUSTOMIZE_TAB_FONT, color=Colors.RED, position=model.default_player_locations[6], text="START"},
            Text{font=CUSTOMIZE_TAB_FONT, color=Colors.RED, position=model.default_player_locations[7], text="EXIT"},
            Rectangle{color={255,255,255}, width=100, height=100, position = model.default_player_locations[8] },
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
    view.ui:add(chooseCharacterText)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CharacterSelectionController(self))
    end
    
    local chooseCharacterFlag = true
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHARACTER_SELECTION then
            self.ui.opacity = 255
            self.ui:raise_to_top()
            print("Showing Character Selection UI")
            if(chooseCharacterFlag) then
                chooseCharacterFlag = nil
                chooseCharacterText:animate{
                    duration = CHANGE_VIEW_TIME, x = 800,
                    on_completed = function()
                        timer:start()
                    end
                }
            end
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
        else
            print("Hiding Character Selection UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
