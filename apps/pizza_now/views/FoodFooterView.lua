
FoodFooterView = Class(View, function(view, model, ...)
    view._base.init(view, model)
     
    view.ui=Group{name="Food Footer UI", position={0,960}, opacity=255}

    view.bar = Image{
                position = {0,0},
                width = 1920,
                tile = {false,true},
src="assets/OrderBarBase.png"
    }
    view.items = {
        Text{
            position={0, 0},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Go Back"
        },
        Text{
            position={400, 0},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Cart"
        },
        Text{
            position={1200, 0},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Checkout"
        }
    }
    view.ui:add(view.bar)
    view.ui:add(unpack(view.items))
    screen:add(view.ui)
    function view:initialize()
        self:set_controller(FoodFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.FOOD_SELECTION then
            print("Showing FoodFooterView UI")
            for i,item in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    print("\t",i,"opacity to 255")
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                else
                    print("\t",i,"opacity to 0")
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                end
            end
        elseif comp == Components.CUSTOMIZE or comp == Components.TAB or
               comp == Components.CUSTOMIZE_ITEM then
            print("Graying FoodFooterView UI")
            view.ui:complete_animation()
            view.items[controller:get_selected_index()].opacity = 100
        else
            print("Hiding FoodFooterView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
