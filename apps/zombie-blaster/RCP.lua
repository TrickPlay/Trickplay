 -- constructor, called with Router(...)
Router = Class(nil,
function(router, ...)

    -- class fields
    router.registry = {}
    router.controllers = {}
    router.active_component = nil

    -- class methods

    --[[
        Attach observers to the router. When the router gets events it will
        forward the even to attached observers
    --]]
    function router:attach(observer, controller_id)
        self.registry[observer] = true
        if controller_id then
            self.controllers[controller_id] = observer
        end
    end
    
    --[[
        Detaches the observer from the router. The observer effectively becomes
        inactive.
    --]]
    function router:detach(observer, controller_id)
        self.registry[observer] = nil
        if controller_id then
            self.controllers[controller_id] = nil
        end
    end

    --[[
        Either notify a specific controller of an event, or all controllers.

        @param event : an Event object to pass to the controller(s).
        @param controller_ids : a table of controller_ids specifiying the
               controllers to pass the event too, if nil the event is passed to
               all controllers.
    --]]
    function router:delegate(event, controller_ids)
        assert(event:is_a(Event))
        if controller_ids and type(controller_ids) == "table" then
            for _,id in ipairs(controller_ids) do
                assert(self.controllers, "this router has no registry of controllers")
                assert(self.controllers[id], "controller "..id.." is not attached!")
                self.controllers[id]:update(event)
            end

            return
        end

        for observer, bool in pairs(self.registry) do
            if observer:is_a(Controller) then observer:update(event) end
        end
    end

    --[[
        Tell all observers to check the current state.
    --]]
    function router:notify()
        for observer, bool in pairs(self.registry) do
            if not observer.update then
                error("update() not defined for Component "..self:get_active_component())
            end
            observer:update(NotifyEvent())
        end
    end

    function router:get_controller(comp)
        if self.controllers[comp] then
            return self.controllers[comp]
        else
            error("component doesn't exist.")
        end
    end

    function router:get_active_controller()
       assert(self.controllers[self.active_component])
       return self.controllers[self.active_component]
    end

    function router:get_active_component()
        return self.active_component
    end

    function router:start_app(comp)
        self.active_component = comp
        self:notify()
        game:initialize_game()
    end
    
    function router:set_active_component(comp)
        if type(comp) ~= "number" then
            error("Component " .. tostring(comp) .. " is not a number", 2)
        elseif comp < Components.COMPONENTS_FIRST or Components.COMPONENTS_LAST < comp then
            error("Component " .. comp .. " does not exist", 2)
        end
        self.previous_component = self.active_component
        self.active_component = comp
        print("set active component to",comp)
    end

    function router:set_keys()
        function screen:on_key_down(k)
            assert(router:get_active_controller())
        end
    end

end)




Observer = Class(function(observer, ...)

    -- class methods
    function observer:update()
        error("Update not defined for observer") 
    end

end)

View = Class(Observer, function(view, router, ...)

    -- class fields
    view.router = router
    view.controller = nil
    router:attach(view)

    -- class methods
    function view:initialize()
        error("Initializing empty controller", 2)
        self.controller = Controller(self)
    end

    function view:get_router() return view.router end
    function view:get_controller() return self.controller end

    function view:set_controller(cont)
        self.controller = cont
        self.set_controller = nil
    end

    function view:update()
        error("update() not implemented for this view")
    end

end)

Controller = Class(Observer, function(ctrl, router, id)
    assert(id)

    -- class fields
    ctrl.router = router
    ctrl.router:attach(ctrl, id)

    function ctrl:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            ctrl:on_key_down(event.key)
        end
    end
    
    -- getters
    function ctrl:is_active_component()
        return id == router:get_active_component()
    end
    function ctrl:get_router() return self.router end
    function ctrl:get_view() return self.view end

    -- prototypes
    function ctrl:run_callback()
        error("run_callback() not defined for this controller")
    end

    function ctrl:move(dir)
        error("move_selector() not defined for this controller")
    end

    local ControlKeyTable = {
        [keys.Up] = function() ctrl:move(Directions.UP) end,
        [keys.Down] = function() ctrl:move(Directions.DOWN) end,
        [keys.Left] = function() ctrl:move(Directions.LEFT) end,
        [keys.Right] = function() ctrl:move(Directions.RIGHT) end,
        [keys.BackSpace] =
            function()
                if not pcall(function() ctrl:back_pressed() end) then
                    print("ctrl.back_pressed not defined for controller id #"..id)
                end
            end,
        [keys.Return] =
            function()
                --ctrl:return_pressed()
                ---[[
                if not pcall(function() ctrl:return_pressed() end) then
                    print("either an error occurred or ctrl.return_pressed not define for controller id #"..id)
                end
                --]]
            end
    }
    ControlKeyTable[keys.OK] = ControlKeyTable[keys.Return]

    function ctrl:on_key_down(k)
        if ControlKeyTable[k] then
            ControlKeyTable[k]()
        end
    end

end)
