CharacterSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz

    local background = {
    }

    --create the components

    view.items = {
        {
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[2] },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[3] },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[4] },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[5] },
        },
        {
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[1] },
            Rectangle{width=200, height=120, color=Colors.RED, position=MDPL.START, extra = { text="START" } },
            Rectangle{width=200, height=120, color=Colors.RED, position=MDPL.EXIT, extra = { text="EXIT" } },
            Rectangle{color="FFFFFF", width=100, height=100, position = MDPL[6] },
        }
    }
    
    view.text = {}
    
    for i, table in ipairs(view.items) do
        for k,v in ipairs(table) do
            if v.extra.text then
                local text = Text{ font = "Sans 38px", color = "FFFFFF", text = v.extra.text }
                view.text[k] = text
                text.anchor_point = {text.w/2, text.h/2}
                text.position = {v.position[1] + v.w/2, v.position[2] + v.h/2}
                local g = Group{children={v, text}}
                view.items[i][k] = g
            end
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
    view.ui:add(unpack(view.items[1]))
    view.ui:add(unpack(view.items[2]))
    view.ui:add(chooseCharacterText)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CharacterSelectionController(self))
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHARACTER_SELECTION then
            self.ui.opacity = 255
            self.ui:raise_to_top()
            print("Showing Character Selection UI")
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
