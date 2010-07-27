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
            position = {90, 90},
            src = "assets/PizzaRadialUI/LightColor.png",
            name = "light",
            opacity = 0
        },
        Image{
            position={110, 100},
            src = "assets/PizzaRadialUI/NormalColor.png",
            name = "normal",
            opacity = 0
        },
        Image{
            position={110, 90},
            src = "assets/PizzaRadialUI/ExtraColor.png",
            name = "extra",
            opacity = 0
        },
    }
    view.directionIcon = {
        Image{
            position = {70, 100},
            src = "assets/PizzaRadialUI/LeftIcon.png",
            name = "left_icon",
        },
        Image{
            position = {100, 70},
            src = "assets/PizzaRadialUI/UpIcon.png",
            name = "up_icon",
        },
        Image{
            position = {200, 100},
            src = "assets/PizzaRadialUI/RightIcon.png",
            name = "right_icon",
        },
        Image{
            position = {100, 200},
            src = "assets/PizzaRadialUI/DownIcon.png",
            name = "down_icon"
        }
    }
    view.ui:add(unpack(view.amountItemsGray))
    view.ui:add(unpack(view.amountItemsColor))
    view.ui:add(unpack(view.sideItems))
    view.ui:add(unpack(view.directionIcon))
    screen:add(view.ui)
    view.ui:raise_to_top()
    for i = 5, 1, -1 do
        view.sideItems[i]:raise_to_top()
    end
    function view:initialize()
        self:set_controller(WindMillController(self))
    end

    local function popIn()
        view.directionIcon[1].x = 70
        view.directionIcon[1].y = 100
        view.directionIcon[2].x = 100
        view.directionIcon[2].y = 70
        view.directionIcon[3].x = 200
        view.directionIcon[3].y = 100
        view.directionIcon[4].x = 100
        view.directionIcon[4].y = 200

        view.amountItemsGray[1].x = 90
        view.amountItemsGray[1].y = 100
        view.amountItemsGray[2].x = 110
        view.amountItemsGray[2].y = 110
        view.amountItemsGray[3].x = 110
        view.amountItemsGray[3].y = 100
        view.amountItemsColor[1].x = 90
        view.amountItemsColor[1].y = 90
        view.amountItemsColor[2].x = 110
        view.amountItemsColor[2].y = 100
        view.amountItemsColor[3].x = 110
        view.amountItemsColor[3].y = 90
    end

    --reset the ui components to their original state
    function view:reset()
        print("Customize item RESET()")
        amountSelection = false
        self.ui:complete_animation()
        self.ui.opacity = 0
    end
    local function set()
        print("\n\nCustomize item SET()")
        popIn()
        amountSelection = false
	    view.ui.opacity = 255
        view.directionIcon.opacity = 255
        view.amountItemsGray.opacity = 255
        view.amountItemsColor.opacity = 0
        for i,v in ipairs(view.sideItems) do
            view.sideItems[i].opacity = 0
        end
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
        view.directionIcon[1]:animate{x = 40, y = 100, duration = 400}
        view.directionIcon[2]:animate{x = 100, y = 30, duration = 400}
        view.directionIcon[3]:animate{x = 250, y = 100, duration = 400}
        view.amountItemsGray[1]:animate{x = 60, y = 70, duration = 400}
        view.amountItemsGray[2]:animate{x = 110, y = 70, duration = 400}
        view.amountItemsGray[3]:animate{x = 160, y = 70, duration = 400}
        view.amountItemsColor[1]:animate{x = 60, y = 60, duration = 400}
        view.amountItemsColor[2]:animate{x = 110, y = 60, duration = 400}
        view.amountItemsColor[3]:animate{x = 160, y = 60, duration = 400}
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
