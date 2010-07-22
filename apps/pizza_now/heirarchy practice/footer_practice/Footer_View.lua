DEFAULT_FONT="DejaVu Sans Mono 40px"
DEFAULT_COLOR="FFFFFF" --WHITE
FooterView = Class(View, function(view, model, ...)
    view._base.init(view,model)
     
    view.ui=Group{name="footer ui", position={10,1000}, opacity=0}

    view.menu_items = {
        Text{
            position={0, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Go Back"
        },
        Text{
            position={400, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Cart"
        },
        Text{
            position={800, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Scroll"
        },
        Text{
            position={1200, 0},
            font  = DEFAULT_FONT,
            color = DEFAULT_COLOR,
            text = "Checkout"
        }
    }
    view.ui:add(unpack(view.menu_items))
    screen:add(view.ui)
    function view:initialize()
        self:set_controller(FooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Component.FOOD then
            print("Showing HeaderView UI")
            view.ui.opacity = 255
            for i,item in ipairs(view.menu_items) do
                if i == controller:get_selected_index() then
                    item:animate{duration=1000, opacity=255}
                else
                    print("opacity to 0")
                    item:animate{duration=1000, opacity=0}
                end
            end
        else
            print("Hiding HeaderView UI")
            view.ui.opacity = 0
        end
    end

   end)
