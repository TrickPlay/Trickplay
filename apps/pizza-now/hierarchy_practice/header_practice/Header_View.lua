HeaderView = Class(View, function(view, model, ...)
    view._base.init(view,model)
     
    view.ui=Group{name="header ui", position={10,10}, opacity=255}

    view.menu_items = {
        Text{
            position={0, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Pizza"
        },
        Text{
            position={400, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Sandwiches"
        },
        Text{
            position={800, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Bread"
        },
        Text{
            position={1200, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Shlut fo money"
        }
    }
    view.ui:add(unpack(view.menu_items))
    screen:add(view.ui)
    function view:initialize()
        self:set_controller(HeaderController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Component.FOOD then
            print("Showing HeaderView UI")
--            view.ui.opacity = 255
            for i,item in ipairs(view.menu_items) do
                if i == controller:get_selected_index() then
                    print("\t",i,"opacity to 255")
                    item:animate{duration=500, opacity=255}
                else
                    print("\t",i,"opacity to 0")
                    item:animate{duration=500, opacity=0}
                end
            end
        else
            print("Hiding HeaderView UI")
            view.ui.opacity = 0
        end
    end

   end)
