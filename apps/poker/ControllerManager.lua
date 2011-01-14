ControllerManager = Class(nil,
function(ctrlman, start_accel, start_click, start_touch, resources, max_controllers)
    if resources ~= nil and not type(resources) == "table" then
        error("all resources must be declared as strings in a table", 3)
    end
    if not max_controllers then max_controllers = 4 end

    local number_of_ctrls = 0
    local active_ctrls = {}
    local accepting_controllers = false

    function ctrlman:start_accepting_ctrls()
        accepting_controllers = true
    end
    
    function ctrlman:stop_accepting_ctrls()
        accepting_controllers = false
    end

    function ctrlman:declare_resource(asset)
        for name,controller in pairs(active_ctrls) do
            controller:declare_resource(asset)
        end
    end

    --[[
        Hook up the connect, disconnect and ui controller events
    --]]
    function controllers:on_controller_connected(controller)
        if number_of_ctrls > 10 or not accepting_controllers then return end
        if not model:get_active_controller().add_controller then return end

        model:get_active_controller():add_controller(controller)
        number_of_ctrls = number_of_ctrls + 1

        active_ctrls[controller.name] = controller

        if resources then
            for name,resource in pairs(resources) do
                controller:declare_resource(name, resource)
            end
        end
        controller:declare_resource("bomb","bomb.png")
        controller:declare_resource("numbers","numbers.png")
        --controller:set_ui_background("numbers")

        function controller:on_key_down(key)
            print("controller keypress:", key)
            screen:on_key_down(key)

            return true
        end


        print("CONNECTED",controller.name)
        
        function controller.on_disconnected(controller)
            
            print("DISCONNECTED",controller.name)
            
        end

        if start_click then
            function controller.on_click(controller, x, y)
                print("answered",controller.name,x,y)

                -- disable additional clicks
                controller.on_click = nil

                -- reset background picture
                controller:set_ui_background("bomb")
            end
            controller:start_clicks()
        end

        if start_accel then
            function controller:on_accelerometer(x, y, z)
                print("accelerometer: x", x, "y", y, "z", z)
            end
            controller:start_accelerometer("L", 1)
        end

    end
end)
