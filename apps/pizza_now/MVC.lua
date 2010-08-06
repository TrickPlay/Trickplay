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
        driverInstructions = false,
        password = false,
        firstName = false,
        lastName = false,
        phone_areaCode = false,
        phone_first = false,
        phone_last = false,
        phone_ext = false,
        email_alias = false,
        email_at = false,
        cardNumber_first = false,
        cardNumber_second = false,
        cardNumber_third = false,
        cardNumber_forth = false,
        card_expiration_month = false,
        card_expiration_year = false,
        card_code = false,
        street = false,
        apartment = false,
        city = false,
        zip = false,
        card_type = false,
        card_number = false,
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
        local firstAnimation = Group{position = {1920, 750}}
        local text = Text{
            position = {0,0},
            font = CUSTOMIZE_TAB_FONT,
            color = Colors.WHITE,
            text = "Enter Your Delivery Address NOW!"
        }
        local image = Image{
            position = {10, 70},
            src = "assets/DownScrollArrow.png",
            scale = {4,4}
        }
        firstAnimation:add(text, image)
        screen:add(firstAnimation)
        firstAnimation:animate{duration = 1000, x = 420,
            on_completed = function()
                local timer = Timer()
                timer.interval = 2
                function timer:on_timer()
                    timer.on_timer = nil
                    timer = nil
                    firstAnimation:animate{duration = 300, x = -900}
                end
                timer:start()
            end
        }
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

    function model:edit_selected_cart_item(item_num)
       self.current_item = self.cart[item_num]
       self.current_item_is_in_cart = true
       self:set_active_component(Components.CUSTOMIZE)
       self:get_active_controller():init_shit()
       self:get_controller(Components.TAB):init_shit()
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
        return view.model
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

    function controller:on_focus()
        error("self:on_focus() not defined for controller")
    end
    
    function controller:out_focus()
        error("self:out_focus() not defined for controller")
    end

end)
