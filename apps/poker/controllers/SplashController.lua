SplashController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.SPLASH)

    local controller = self
    model = view:get_model()

    local KeyTable = {
        [keys.Return] =
        function(self)
            model:set_active_component(Components.CHARACTER_SELECTION)
            model:notify()
            ctrlman:choose_dog()
        end
    }
    KeyTable[keys.OK] = KeyTable[keys.Return]

    function self:on_key_down(k)
        if KeyTable[k] then
            KeyTable[k](self)
        end
    end

    function self:add_controller()
    end

end)
