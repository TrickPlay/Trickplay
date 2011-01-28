ControllerStates = {
    SPLASH = 1,
    CHOOSE_DOG = 2,
    NAME_DOG = 3,
    WAITING = 4,
    PLAY_HAND = 5
}

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

        controller.state = ControllerStates.SPLASH

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
            -- headers which help instruct the player
            controller:declare_resource("hdr_choose_dog",
                "assets/phone/text-choose-your-dog.png")
            controller:declare_resource("hdr_name_dog",
                "assets/phone/text-name-your-dog.png")
            -- waiting room stuff
            controller:declare_resource("click_label",
                "assets/phone/waiting_screen/label-clicktoadd.png")
            controller:declare_resource("comp_label",
                "assets/phone/waiting_screen/label-computer.png")
            controller:declare_resource("human_label",
                "assets/phone/waiting_screen/label-human.png")
            controller:declare_resource("ready_label",
                "assets/phone/waiting_screen/label-ready.png")
            controller:declare_resource("start_button",
                "assets/phone/waiting_screen/button-start.png")
            controller:declare_resource("waiting_text",
                "assets/phone/waiting_screen/text-waiting.png")
            for i = 1,6 do
                controller:declare_resource("player_"..i,
                    "assets/phone/waiting_screen/player"..i..".png")
            end

            controller:set_ui_background("splash")
        end

        local x_ratio = controller.ui_size[1]/640
        local y_ratio = controller.ui_size[2]/870
        function controller:add_image(image_name, x, y, width, height)
            if not image_name then error("no image name", 2) end
            
            --[[
            print("controller.ui_size")
            dumptable(controller.ui_size)

            print("x_ratio", tostring(x_ratio))
            print("y_ratio", tostring(y_ratio))
            print("x*x_ratio", tostring(x*x_ratio))
            print("y*y_ratio", tostring(y*y_ratio))
            print("width*x_ratio", tostring(width*x_ratio))
            print("height*y_ratio", tostring(height*y_ratio))
            --]]

            return
                controller:set_ui_image(image_name, math.floor(x*x_ratio),
                    math.floor(y*y_ratio), math.floor(width*x_ratio),
                    math.floor(height*y_ratio))
        end

        controller.x_ratio = x_ratio
        controller.y_ratio = y_ratio

        function controller:on_key_down(key)
            print("controller keypress:", key)
            if controller.name == "Keyboard" then return true end
            print("key consumed")

            return false
        end


        print("CONNECTED", controller.name)
        
        function controller:on_disconnected()
            print("DISCONNECTED", controller.name)

            active_ctrls[controller.name] = nil
        end

        if start_click then
            function controller:on_click(x, y)
                print("answered", controller.name,x,y)

                model:get_active_controller():handle_click(controller, x, y)
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
            controller:add_image("hdr_choose_dog", 95, 30, 450, 50)
            for i = 1,6 do
                if not controller:add_image("dog_"..i, ((i-1)%2)*(256+8)+60,
                math.floor((i-1)/2)*256+100, 256, 256) then
                    -- TODO: figure out some good error handling
                    print("error setting dog image")
                end
            end

            controller.state = ControllerStates.CHOOSE_DOG
        end

        --[[
            Brings up the name your dog screen on the iphone. Player may enter a name
            that replaces the Player # on their dogs name bubble.

            @parameter pos : the dogs number/position (1-6). Determines which dog icon
                to show on the iphone.
        --]]
        function controller:name_dog(pos)
            print("naming dog")
            controller:set_ui_background("bkg")
            controller:add_image("hdr_name_dog", 109, 30, 422, 50)
            controller:add_image("dog_"..pos, 192, 100, 256, 256)
            if controller:enter_text("Name Your Dog", "Name Your Dog") then
                function controller:on_ui_event(text)
                    if text ~= "" then
                        controller.player.status:update_name(text)
                    end
                    controller.on_ui_event = function() end
                    controller:waiting_room()
                end
            end

            controller.state = ControllerStates.NAME_DOG
        end

        function controller:waiting_room()
            controller:set_ui_background("bkg")
            controller:add_image("waiting_text", 0, 0, 640, 86)
            for i = 1,6 do
                controller:add_image("player_"..i, 0, (i-1)*115+86, 640, 115)
            end
            controller:add_image("start_button", 0, 6*115+86, 640, 95)
            controller:update_waiting_room()

            controller.state = ControllerStates.WAITING
        end

        function controller:update_waiting_room()
            local playing = {}
            for i,player in ipairs(model.players) do
                local pos = player.table_position
                controller:add_image("ready_label", 167, (pos-1)*115+86+60, 122, 34)
                if player.isHuman then
                    controller:add_image("human_label", 330, (pos-1)*115+86+20, 122, 34)
                else
                    controller:add_image("comp_label", 330, (pos-1)*115+86+20, 196, 34)
                end
                playing[pos] = true
            end
            for i = 1,6 do
                if not playing[i] then
                    controller:add_image("click_label", 167, (i-1)*115+86+60, 212, 33)
                end
            end
        end

        function controller:set_hole_cards(hole)
            assert(hole[1])
            assert(hole[2])
            controller:set_ui_background("bkg")
            controller:add_image("buttons", 0, 535, 640, 313)

            controller:declare_resource("card1",
                "assets/cards/"..getCardImageName(hole[1])..".png")
            controller:declare_resource("card2",
                "assets/cards/"..getCardImageName(hole[2])..".png")

            controller:add_image("card1", 60, 70, 100*3, 130*3)
            controller:add_image("card2", 280, 90, 100*3, 130*3)
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

    -- update the waiting room for all controllers
    function ctrlman:update_waiting_room()
        for k,controller in pairs(controllers.connected) do
            controller:update_waiting_room()
        end
    end

end)
