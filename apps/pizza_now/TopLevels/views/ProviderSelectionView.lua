ProviderSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    -- local deliveryOptionsView = DeliveryOptionsView(model)
    -- deliveryOptionsView:initialize()
    local providersView = ProvidersCarouselView(model)
    providersView:initialize()
    local footerView = ProviderFooterView(model)
    footerView:initialize()

    -- view.items = {deliveryOptionsView, providersView, footerView}
    view.items = {providersView, footerView}

    --Background junk
    local back = Image{
        position = {0,0},
        src = "assets/StoreScreenBg.png"
    }
    local orderBar = Image{
        src = "assets/OrderBarBase.png",
        position = {0, 960},
        tile = {true, false},
        width = 1920
    }
    --Delivery Address
    local addressBillingGroup = Group{position = {100,990}}
    local streetBillingForm = Group{position = {230, 0}}
    local streetBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local streetBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1740-1150,
        tile = {true, false}
    }
    local streetBillingFormRight = Image{
        position = {1740-1140, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    streetBillingForm:add(streetBillingFormLeft, streetBillingFormCenter, streetBillingFormRight)
    local cityBillingForm = Group{position = {850, 0}}
    local cityBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local cityBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1510-1150,
        tile = {true, false}
    }
    local cityBillingFormRight = Image{
        position = {1510-1140, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    cityBillingForm:add(cityBillingFormLeft, cityBillingFormCenter, cityBillingFormRight)
    local stateBillingForm = Group{position = {1240, 0}}
    local stateBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local stateBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1200-1140,
        tile = {true, false}
    }
    local stateBillingFormRight = Image{
        position = {1210-1140, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    stateBillingForm:add(stateBillingFormLeft, stateBillingFormCenter,
        stateBillingFormRight)
    local zipBillingForm = Group{position = {1330, 0}}
    local zipBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local zipBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1740-1630,
        tile = {true, false}
    }
    local zipBillingFormRight = Image{
        position = {1740-1620, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    zipBillingForm:add(zipBillingFormLeft, zipBillingFormCenter, zipBillingFormRight)

    addressBillingGroup:add(streetBillingForm, cityBillingForm, stateBillingForm, zipBillingForm, expirationMonthForm)

    view.background_ui = Group{name="provider_background_ui", position={0,0}, opacity=255}
    view.background_ui:add(back, orderBar, addressBillingGroup)
    view.provider_ui=Group{name="provider_components_ui", position={0,0}, opacity=255}

    for i,v in ipairs(view.items) do
        view.provider_ui:add(v.ui)
    end

    view.ui = Group{name="provider_ui", position = {0,0}, opacity=255}

    view.ui:add(view.background_ui)
    view.ui:add(view.provider_ui)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(ProviderSelectionController(self))
    end
    
    local prev_selection = {}
    for i = 1, #view.items do
        prev_selection[i] = 1
    end

    function view:update()
        screen:grab_key_focus()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
           local selected = controller:get_selected_index()
            print("Showing ProviderSelectionView UI")
            self.ui.opacity = 255
            for i,c_view in ipairs(view.items) do
               if i == controller.ProviderGroups.FOOTER then
                  c_view.ui.opacity=255
                  if i == selected then
                     self:get_controller().child = c_view:get_controller()
                  end
               elseif i == selected then
                  c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                  self:get_controller().child = c_view:get_controller()
               else
                  c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=BOTTOM_OPACITY}
                  prev_selection[i] = c_view:get_controller():get_selected_index()
               end
            end
        else
            print("Hiding ProviderSelectionView UI")
            self.ui.opacity = 0
        end
    end

end)
