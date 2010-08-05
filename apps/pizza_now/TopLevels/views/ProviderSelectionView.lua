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
    --Delivery Address
    view.background_ui = Group{name="provider_background_ui", position={0,0}, opacity=255}
    view.background_ui:add(back, orderBar)
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
    
    function view:update()
        screen:grab_key_focus()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
           local selected = controller:get_selected_index()
            print("Showing ProviderSelectionView UI")
            self.ui.opacity = 255
            for i,c_view in ipairs(view.items) do
               if i == selected then
                  c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                  self:get_controller().child = c_view:get_controller()
               else
                  c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=BACKGROUND_FADE_OPACITY}
               end
            end
        else
            print("Hiding ProviderSelectionView UI")
            self.ui.opacity = 0
        end
    end

end)
