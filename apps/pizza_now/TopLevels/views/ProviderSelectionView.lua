ProviderSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local deliveryOptionsView = DeliveryOptionsView(model)
    deliveryOptionsView:initialize()
    local providersView = ProvidersCarouselView(model)
    providersView:initialize()
    local footerView = ProviderFooterView(model)
    footerView:initialize()

    view.items = {deliveryOptionsView, providersView, footerView}
  
    view.provider_ui=Group{name="provider_ui", position={10,10}, opacity=255}

    for i,v in ipairs(view.items) do
        view.provider_ui:add(v.ui)
    end

    view.provider_ui:add(unpack(view.items))
    screen:add(view.provider_ui)

    function view:initialize()
        self:set_controller(ProviderSelectionController(self))
    end
    
    local prev_selection = {}
    for i = 1, #view.items do
        prev_selection[i] = 1
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing ProviderSelectionView UI")
            self.provider_ui.opacity = 255
            for i,c_view in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=255}

                    self:get_controller().child = c_view:get_controller()
                else
                    c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                    prev_selection[i] = c_view:get_controller():get_selected_index()
                end
            end
        else
            print("Hiding ProviderSelectionView UI")
            self.provider_ui.opacity = 0
        end
    end

end)
