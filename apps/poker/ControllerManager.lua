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
        if number_of_ctrls > max_controllers or not accepting_controllers then return end
        if not model:get_active_controller().add_controller then return end

        local function declare_necessary_resources()
            --[[
                Declare resources to be used by the phone
            --]]
            -- buttons for betting
            controller:declare_resource("buttons", "assets/phone/buttons.png")
            -- buttons for dog selection
            controller:declare_resource("dog_1", "assets/phone/chip1.jpg")
            controller:declare_resource("dog_2", "assets/phone/chip2.jpg")
            controller:declare_resource("dog_3", "assets/phone/chip3.jpg")
            controller:declare_resource("dog_4", "assets/phone/chip4.jpg")
            controller:declare_resource("dog_5", "assets/phone/chip5.jpg")
            controller:declare_resource("dog_6", "assets/phone/chip6.jpg")
            -- covers up dog selection
            controller:declare_resource("blank_1", "assets/phone/chip1-blank.jpg")
            controller:declare_resource("blank_2", "assets/phone/chip2-blank.jpg")
            controller:declare_resource("blank_3", "assets/phone/chip3-blank.jpg")
            controller:declare_resource("blank_4", "assets/phone/chip4-blank.jpg")
            controller:declare_resource("blank_5", "assets/phone/chip5-blank.jpg")
            controller:declare_resource("blank_6", "assets/phone/chip6-blank.jpg")
            -- phone splash screen
            controller:declare_resource("splash", "assets/phone/splash.jpg")
            -- headers which help instruct the player
            controller:declare_resource("hdr_blank", "assets/phone/title-blank.jpg")
            controller:declare_resource("hdr_choose_dog",
                "assets/phone/title-choose-dawg.jpg")
            controller:declare_resource("hdr_name_dog",
                "assets/phone/title-name-dawg.jpg")

 --           controller:set_ui_background("splash")
        end

        function controller:on_key_down(key)
            print("controller keypress:", key)
            screen:on_key_down(key)

            return true
        end


        print("CONNECTED", controller.name)
        
        function controller.on_disconnected(controller)
            
            print("DISCONNECTED", controller.name)
            
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

--[[
        function controller:choose_dog()
            print("choosing dog")

            if not controller:set_ui_image("dog_1", 0, 0, 19, 85) then
                print("error setting dog image")
            end
        end
--]]
        
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
end)
