DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
WindMillView = Class(View, function(view, model, ...)
    view._base.init(view, model)
     
    view.ui=Group{name="windmill_ui", position={800,500}, opacity=255}

    view.items = {
        Text{
            position = {0, 100}
            font = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "light"
        },
        Text{
            position={100, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "normal"
        },
        Text{
            position={200, 100},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "extra"
        },
        Text{
            position = {100, 200}
            font = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "none"
        }
    }
    view.ui:add(unpack(view.items))
    screen:add(view.ui)
    function view:initialize()
        self:set_controller(WindMillController(self))
    end
    
    --reset the ui components to their original state
    function view:reset()
        self.ui:complete_animation
        self.ui.opacity = 0
    end

    local function animateWindmill(selection)
        --roll through different windmill options
        --darken the ones not chosen and extend the one that is
    end

    local CustomizeItemAnimations = {
        [1] = function() --left
           if(not amountSelection) then
               --TODO: highlight
               popOut()
           else
               animateWindmill(1)
           end 
        end,
        [2] = function() --up
           if(not amountSelection) then
               --TODO: highlight
               popOut()
           else
               animateWindmill(2)
           end 
        end,
        [3] = function() --right
           if(not amountSelection) then
               --TODO: highlight
               popOut()
           else
               animateWindmill(3)
           end 
        end,
        [4] = function() --down
            view:reset()
        end
    }

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CUSTOMIZE_ITEM then
            print("Showing Customize Item UI")
--            view.ui.opacity = 255
            CustomizeItemAnimations[controller:get_selected_index()]
            if(amountSelection) then
                CustomizeItemAnimations[controller:get_selected_index()]
            end
        else
            print("Hiding Customize Item UI")
            view:reset()
        end
    end

end)
