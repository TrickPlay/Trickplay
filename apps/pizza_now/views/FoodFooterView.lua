local DEFAULT_FONT = CUSTOMIZE_ENTRY_FONT
local DEFAULT_COLOR = Colors.BLACK

FoodFooterView = Class(View, function(view, model,parent, ...)
    view.parent = parent
    view._base.init(view, model)
     
    view.ui=Group{name="Food Footer UI", position={0,960}, opacity=255}
    view.prev_cart_size = #model.cart
    view.bar = Image{
            position = {0,0},
            width = 1920,
            tile = {false,true},
            src="assets/OrderBarBase.png"
    }
    view.backText = Text{
        position={0, 0},
        font  = DEFAULT_FONT,
        color = Colors.BLACK,
        text = "Go Back"
    }
    view.checkoutText = Text{
        position={1700, 0},
        font  = DEFAULT_FONT,
        color = Colors.BLACK,
        text = "Checkout"
    }
    --interactive images
    view.back = FocusableImage(30, 30,
        "assets/BackArrow.png",
        "assets/BackArrowFocus.png"
    )
    view.checkout = FocusableImage(1700, 30,
        "assets/CartButton.png",
        "assets/CartButtonFocus.png"
    )
    view.back_pressed = Image{
        position = {30, 30},
        src = "assets/BackArrowPress.png",
        opacity = 0
    }
    view.checkout_pressed = Image{
        position={1700,30},
        src="assets/CartButtonPress.png",
        opacity = 0
    }

    view.items = {view.back, view.checkout}
    view.pressed_items = {view.back_pressed, view.checkout_pressed}
    view.ui:add(view.bar)
    view.ui:add(view.back.group, view.checkout.group,
        view.backText, view.checkoutText, view.back_pressed, view.checkout_pressed
    )
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
                if i == controller:get_selected_index() and view.parent:get_controller():get_selected_index() == 2 then
                    if(item.on_focus) then
                        item:on_focus()
                    else
                        item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    end
                else
                    if(item.out_focus) then
                        item:out_focus()
                    else
                        item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                    end
                end
            end
        else
            print("Hiding FoodFooterView UI")
            controller:reset_index()
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
