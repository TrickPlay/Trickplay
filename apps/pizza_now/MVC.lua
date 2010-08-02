 -- constructor, called with Model(...)
Model = Class(function(model, ...)
    -- (private) class fields
    model.registry = {}
    model.controllers = {}
    model.active_component = nil

    --pizza data
    model.delivery = nil
    model.arrival_time = 12
    
    model.current_item = nil
    model.current_item_is_in_cart = false

    model.cart = {}
    
    --address info
    model.address = {
        street = false,
        apartment = false,
        city = false,
        zip = false
    }

    model.creditInfo = {
        street =false,
        apartment = false,
        city = false,
        zip = false,
        card_type = false,
        card_number = false,
        card_code = false,
        card_expiration_month = false,
        card_expiration_year = false
    }

    -- class methods
    function model:attach(observer, controller_id)
        self.registry[observer] = true
        if controller_id then
            self.controllers[controller_id] = observer
        end
    end

    function model:detach(observer)
        self.registry[observer] = nil
    end

    function model:notify()
        for observer, bool in pairs(self.registry) do
            observer:update()
        end
    end

    function model:get_controller(comp)
        if self.controllers[comp] then
            return self.controllers[comp]
        else
            error("component doesn't exist.")
        end
    end

    function model:get_active_controller()
       assert(self.controllers[self.active_component])
       return self.controllers[self.active_component]
    end

    function model:get_active_component()
        return self.active_component
    end

    function model:start_app(comp)
        self.active_component = comp
        screen:show()
        self:notify()
    end
    
    function model:set_active_component(comp)
       if type(comp) ~= "number" then
          error("Component " .. tostring(comp) .. " is not a number", 2)
       elseif comp < Components.COMPONENTS_FIRST or Components.COMPONENTS_LAST < comp then
          error("Component " .. comp .. " does not exist", 2)
       end
       self.previous_component = self.active_component
       self.active_component = comp
       print("set active component to",comp)
    end

    function model:set_keys()
        function screen:on_key_down(k)
            assert(model:get_active_controller())
        end
    end

    function model:set_delivery()
        if(self.delivery) then
            self.delivery = not self.delivery
        else
            self.delivery = true
        end
    end

    function model:set_arrival_time()
        self.arrival_time = self.arrival_time + .5
        if(self.arrival_time >= 24) then
            self.arrival_time = 0
        end
    end

    function model:set_address(args)
        for k,v in pairs(args) do
            model.address[k] = v
            assert(model.address[k])
        end
    end

    function model:set_creditInfo(args)
        for k,v in pairs(args) do
            model.creditInfo[k] = v
            assert(model.creditInfo[k])
        end
    end
    
    function model:selected_card()
        return model.creditInfo.card_type
    end

end)




Observer = Class(function(observer, ...)
    -- class fields

    -- class methods
    function observer:update()
        error("Update not defined for observer") 
    end

end)

View = Class(Observer, function(view, model, ...)
    -- COMMON VIEW LOGIC

    -- (private) class fields
    view.model = model
    view.controller = nil
    model:attach(view)

    -- class methods
    function view:initialize()
        error("Initializing empty controller", 2)
        self.controller = Controller(self)
    end

    function view:get_model()
        return self.model
    end

    function view:set_controller(cont)
        self.controller = cont
        self.set_controller = nil
    end

    function view:get_controller()
        return self.controller
    end

    function view:update()
        error("not implemented")
    end
    -- END COMMON VIEW LOGIC

end)

Controller = Class(Observer, function(controller, view, controller_id)
    assert(controller_id)

    -- class fields
    controller.model = view:get_model()
    controller.view = view
    controller.model:attach(controller, controller_id)

    function controller:update()
    end

    function controller:get_model()
        return self.model
    end

    function controller:get_view()
        return self.view
    end

    function controller:run_callback()
        error("run_callback() not defined for controller")
    end

end)
