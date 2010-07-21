ProviderSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    view.deliveryOptions = Group{
        position={0,0},
        width = Dimensions.WIDTH,
        height = Dimensions.HEIGHT * 1/5
    }
    view.providers = Group{
        position={Dimensions.HEIGHT * 1/5,0},
        width = Dimensions.WIDTH,
        height = Dimensions.HEIGHT * 3/5
    }
    view.taskBar = Group{
        position={Dimensions.HEIGHT * 4/5,0},
        width = Dimensions.WIDTH,
        height = Dimensions.HEIGHT * 1/5
    }

    local items = {view.deliveryOptions, view.providers, view.taskBar}
    view.provider_ui=Group{name="provider_ui", position={0,0}, opacity=0}
    view.provider_ui:add(unpack(items))
    screen:add(view.provider_ui)

    function view:initialize()
        self:set_controller(ProviderSelectionController(self))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing ProviderSelectionView UI")
            self.provider_ui.opacity = 255
            for i,item in ipairs(items) do
                if i == controller:get_selected_index() then
                    item:animate{duration=1000, mode="EASE_OUT_EXPO", opacity=255}
                else
                    item:animate{duration=1000, mode="EASE_OUT_BOUNCE", opacity=100}
                end
            end
        else
            print("Hiding ProviderSelectionView UI")
            self.provider_ui.opacity = 0
        end
    end

end)
