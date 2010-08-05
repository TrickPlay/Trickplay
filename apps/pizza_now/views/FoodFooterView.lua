local DEFAULT_FONT = CUSTOMIZE_ENTRY_FONT
local DEFAULT_COLOR = Colors.BLACK

FoodFooterView = Class(View, function(view, model, ...)
    view._base.init(view, model)
     
    view.ui=Group{name="Food Footer UI", position={0,960}, opacity=255}
    view.prev_cart_size = #model.cart
    view.bar = Image{
                position = {0,0},
                width = 1920,
                tile = {false,true},
src="assets/OrderBarBase.png"
    }
    view.back = Text{
            position={0, 0},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Go Back"
        }
    view.checkout = Text{
            position={1700, 0},
            font  = DEFAULT_FONT,
            color = Colors.BLACK,
            text = "Checkout"
        }

    view.items = {view.back, view.checkout}
    view.ui:add(view.bar)
    view.ui:add(unpack(view.items))
    --screen:add(view.ui)
    function view:initialize()
        self:set_controller(FoodFooterController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.FOOD_SELECTION then
            print("Showing FoodFooterView UI")
            if view.prev_cart_size ~= #model.cart then
                print("\n\nUpdating Cart, size is now",#model.cart,"... adding "..model.cart[#model.cart].Name)
                view.ui:clear()
                view.items = {}
                local j = 1
                view.items[j] = view.back
                j = j+1
                view.ui:add(view.bar)

                for i = #model.cart,1,-1 do
                    print(j,i)
                    view.ui:add(Image{
                        position = {1700-250*(i-1)-20, 0},
                        src = "assets/OrderBarDivider.png"
                        })
                    view.items[j] =Text{
                       position={1700-250*i, 0},
                       font  = DEFAULT_FONT,
                       color = Colors.BLACK,
                       text  = model.cart[i].Name.."\n"..model.cart[i].Price
                    }
                    j=j+1
                end
                view.items[j] = view.checkout
                print(j)

                view.ui:add(unpack(view.items))
                view.prev_cart_size = #model.cart
                controller:refresh()
            end
            for i,item in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    print("\t",i,"opacity to 255")
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                else
                    print("\t",i,"opacity to 0")
                    item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                end
            end
    --[[    elseif comp == Components.CUSTOMIZE or comp == Components.TAB or
               comp == Components.CUSTOMIZE_ITEM then
            print("Graying FoodFooterView UI")
            controller:reset_index()
            view.ui:raise_to_top()
            view.ui:complete_animation()
            view.items[controller:get_selected_index()].opacity = 100
--]]
        else
            print("Hiding FoodFooterView UI")
            controller:reset_index()
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
