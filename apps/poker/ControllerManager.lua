ControllerManager = Class(nil,
function(ctrlman, start_accel, start_click, start_touch, resources, max_controllers)
    if resources ~= nil and not type(resources) == "table" then
        error("all resources must be declared as strings in a table", 3)
    end
    if not max_controllers then max_controllers = 4 end

    local number_of_ctrls = 0
    local active_ctrls = {}
    local accepting_controllers = true

    function ctrlman:start_accepting_ctrls()
        accepting_controllers = true
    end
    
    function ctrlman:stop_accepting_ctrls()
        accepting_controllers = false
    end

    function ctrlman:declare_resource(asset_name, asset)
        if not asset_name or not asset then
            error("Usage: declare_resource(name, object)", 2)
        end
        for name,controller in pairs(active_ctrls) do
            controller:declare_resource(asset_name, asset)
        end
    end

    --[[
        Hook up the connect, disconnect and ui controller events
    --]]
    function controllers:on_controller_connected(controller)
        if number_of_ctrls > max_controllers
        or not accepting_controllers
        or active_ctrls[controller]
        or not model:get_active_controller().add_controller then
            return
        end

        local function declare_necessary_resources()
            --[[
                Declare resources to be used by the phone
            --]]
            -- buttons for betting
            controller:declare_resource("buttons", "assets/phone/buttons.png")
            -- buttons for dog selection
            controller:declare_resource("dog_1", "assets/phone/chip1.png")
            controller:declare_resource("dog_2", "assets/phone/chip2.png")
            controller:declare_resource("dog_3", "assets/phone/chip3.png")
            controller:declare_resource("dog_4", "assets/phone/chip4.png")
            controller:declare_resource("dog_5", "assets/phone/chip5.png")
            controller:declare_resource("dog_6", "assets/phone/chip6.png")
            -- phone splash screen
            controller:declare_resource("splash", "assets/phone/splash.jpg")
            -- blank background
            controller:declare_resource("bkg", "assets/phone/bkgd-blank.jpg")
            -- headers which help instruct the pyylayer
            controller:declare_resource("hdr_blank", "assets/phone/title-blank.jpg")
            controller:declare_resource("hdr_choose_dog",
                "assets/phone/title-choose-dawg.jpg")
            controller:declare_resource("hdr_name_dog",
                "assets/phone/title-name-dawg.jpg")

            controller:set_ui_background("splash")
        end

        function controller:add_image(image_name, x, y, width, height)
            local x_ratio = controller.ui_size[1]/540
            local y_ratio = controller.ui_size[2]/(960-150)

            print("x_ratio", tostring(x_ratio))
            print("y_ratio", tostring(y_ratio))
            print("x*x_ratio", tostring(x*x_ratio))
            print("y*y_ratio", tostring(y*y_ratio))
            print("width*x_ratio", tostring(width*x_ratio))
            print("height*y_ratio", tostring(height*y_ratio))

            return
                controller:set_ui_image(image_name, x*x_ratio, y*y_ratio,
                width*x_ratio, height*y_ratio)
        end

        function controller:on_key_down(key)
            print("controller keypress:", key)

            return true
        end


        print("CONNECTED", controller.name)
        
        function controller:on_disconnected()
            print("DISCONNECTED", controller.name)

            active_ctrls[controller.name] = nil
        end

        if start_click then
            function controller:on_click(x, y)
                print("answered", controller.name,x,y)

                -- disable additional clicks
                controller.on_click = nil

            end
            controller:start_clicks()
        end

        if start_accel then
            function controller:on_accelerometer(x, y, z)
                print("accelerometer: x", x, "y", y, "z", z)
            end
            controller:start_accelerometer("L", 1)
        end

        function controller:choose_dog()
            print("choosing dog")

            controller:set_ui_background("bkg")
            if not controller:add_image("dog_1", 0, 0, 256, 256) then
                print("error setting dog image")
                return
            end
        end
        
---------------On Connected Junk---------------


        number_of_ctrls = number_of_ctrls + 1

        active_ctrls[controller.name] = controller

        if resources then
            for name,resource in pairs(resources) do
                controller:declare_resource(name, resource)
            end
        end
        declare_necessary_resources()
        model:get_active_controller():add_controller(controller)
    end

---------------Controller states---------------

    -- run the on connected for all controllers already connected
    -- before application startup
    function ctrlman:initialize()
        for k,controller in pairs(controllers.connected) do
            controllers:on_controller_connected(controller)
        end
    end

    -- put all controllers into the choose your dog mode
    function ctrlman:choose_dog()
        for k,controller in pairs(controllers.connected) do
            controller:choose_dog()
        end
    end

end)
