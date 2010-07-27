DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
WindMillView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    local amountSelection = false
     
    view.ui=Group{name="windmill_ui", position={800,500}, opacity=255}

    view.sideItems = {
        Image{
            position = {100,100},
            src = "assets/PizzaRadialUI/CenterColorLeft.png",
            name = "left",
            opacity = 0 
        },
        Image{
            position = {100, 100},
            src = "assets/PizzaRadialUI/CenterColorUp.png",
            name = "up",
            opacity = 0
        },
        Image{
            position = {100, 100},
            src = "assets/PizzaRadialUI/CenterColorRight.png",
            name = "right",
            opacity = 0
        },
        Image{
            position = {100, 100},
            src = "assets/PizzaRadialUI/CenterColorDown.png",
            name = "down",
            opacity = 0
        },
        Image{
            position = {100, 100},
            src = "assets/PizzaRadialUI/CenterNormal.png",
            name = "center",
            opacity = 255
        }
    }
    view.amountItemsGray = {
        Image{
            position = {90, 100},
            src = "assets/PizzaRadialUI/LightGray.png",
            name = "light_gray"
        },
        Image{
            position={110, 110},
            src = "assets/PizzaRadialUI/NormalGray.png",
            name = "normal_gray"
        },
        Image{
            position={110, 100},
            src = "assets/PizzaRadialUI/ExtraGray.png",
            name = "extra_gray"
        }
    }
    view.amountItemsColor = {
        Image{
            position = {60, 60},
            src = "assets/PizzaRadialUI/LightColor.png",
            name = "light",
            opacity = 0
        },
        Image{
            position={110, 60},
            src = "assets/PizzaRadialUI/NormalColor.png",
            name = "normal",
            opacity = 0
        },
        Image{
            position={160, 60},
            src = "assets/PizzaRadialUI/ExtraColor.png",
            name = "extra",
            opacity = 0
        },
    }
    view.ui:add(unpack(view.amountItemsGray))
    view.ui:add(unpack(view.amountItemsColor))
    view.ui:add(unpack(view.sideItems))
    screen:add(view.ui)
    view.ui:raise_to_top()
    for i = 5, 1, -1 do
        view.sideItems[i]:raise_to_top()
    end
    function view:initialize()
        self:set_controller(WindMillController(self))
    end
    
    --reset the ui components to their original state
    function view:reset()
        amountSelection = false
        self.ui:complete_animation()
        self.ui.opacity = 0
    end
    local function set()
        amountSelection = false
        view.amountItemsGray.opacity = 255
        view.amountItemsColor.opacity = 0
        view.sideItems.opacity = 0
        view.sideItems[5].opacity = 255
    end

    local function animateWindmill(selection)
        --roll through different windmill options
        --darken the ones not chosen and extend the one that is
        for i,v in ipairs(view.sideItems) do
            if(selection == i) then
                view.amountItemsColor[i].opacity = 255
            end
        end
    end
    local function popOut()
        view.amountItemsGray[1]:animate{x = 60, y = 70, duration = 700}
        view.amountItemsGray[2]:animate{x = 110, y = 70, duration = 700}
        view.amountItemsGray[3]:animate{x = 160, y = 70, duration = 700}
        amountSelection = true
    end

    local CustomizeItemAnimations = {
        [0] = function() set() end,
        [1] = function() --left
           if(not amountSelection) then
               view.sideItems[1].opacity = 255
               popOut()
           else
               animateWindmill(1)
           end 
        end,
        [2] = function() --up
           if(not amountSelection) then
               view.sideItems[2].opacity = 255
               popOut()
           else
               animateWindmill(2)
           end 
        end,
        [3] = function() --right
           if(not amountSelection) then
               view.sideItems[3].opacity = 255
               popOut()
           else
               animateWindmill(3)
           end 
        end,
        [4] = function() --down
            view.sideItems[4].opacity = 255
            view:reset()
        end
    }

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CUSTOMIZE_ITEM then
            print("Showing Customize Item UI")
            CustomizeItemAnimations[controller:get_selected_index()]()
        else
            print("Hiding Customize Item UI")
            view:reset()
        end
    end

end)
