FoodSelectionView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local bg = Image{src="assets/MenuScreenBg.png"}
    -- local foodHeaderView = FoodHeaderView(model)
    -- foodHeaderView:initialize()
    local foodCarouselView = FoodCarouselView(model)
    foodCarouselView:initialize()
    local foodFooterView = FoodFooterView(model)
    foodFooterView:initialize()

    -- view.items = {foodHeaderView, foodCarouselView, foodFooterView}
    view.items = {foodCarouselView, foodFooterView}
  
    view.provider_ui=Group{name="Food UI", position={0,0}, opacity=255}

    for i,v in ipairs(view.items) do
        view.provider_ui:add(v.ui)
    end

    view.provider_ui:add(bg, unpack(view.items))
    view.provider_ui:lower_child(bg)
    screen:add(view.provider_ui)

    function view:initialize()
        self:set_controller(FoodSelectionController(self))
    end
    
    local prev_selection = {}
    for i = 1, #view.items do
        prev_selection[i] = 1
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.FOOD_SELECTION then
            print("Showing FoodSelectionView UI")
            self.provider_ui.opacity = 255
            for i,c_view in ipairs(view.items) do
                 if i == controller:get_selected_index() then
                   c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                   controller.child = c_view:get_controller()
                else
                   c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                   prev_selection[i] = c_view:get_controller():get_selected_index()
                end
            end
        else
            print("Hiding FoodSelectionView UI")
            self.provider_ui.opacity = 0
        end
    end

end)
