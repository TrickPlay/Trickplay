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

    function ctrlman:declare_resource(asset_name, asset)
        if not asset_name or not asset then
            error("Usage: declare_resource(name, object)", 2)
        end
        for _,controller in pairs(active_ctrls) do
            controller:declare_resource(asset_name, asset)
        end
    end

    --[[
        Hook up the connect, disconnect and ui controller events
    --]]
    function controllers:on_controller_connected(controller)
        if not controller.has_ui then return end
        print("on_controller_connected controller.name = "..controller.name)

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

            controller:clear_and_set_background("splash")
        end

        local x_ratio = controller.ui_size[1]/640
        local y_ratio = controller.ui_size[2]/870
        function controller:add_image(image_name, x, y, width, height)
            if not image_name then error("no image name", 2) end
            
            return
                controller:set_ui_image(image_name, math.floor(x*x_ratio),
                    math.floor(y*y_ratio), math.floor(width*x_ratio),
                    math.floor(height*y_ratio))
        end

        function controller:clear_and_set_background(image_name)
            controller:clear_ui()
            controller:set_ui_background(image_name)
        end

        controller.x_ratio = x_ratio
        controller.y_ratio = y_ratio

        function controller:on_key_down(key)
            print("controller keypress:", key)
            --[[
            if controller.name == "Keyboard" then return true end
            print("key consumed")

            return false
            --]]
            --return true
        end


        print("CONNECTED", controller.name)
        
        function controller:on_disconnected()
            print("DISCONNECTED", controller.name)

            controller.set_hole_cards = nil
            controller.name_dog = nil
            controller.choose_dog = nil
            controller.state = nil
            controller.add_image = nil
            controller.clear_and_set_background = nil
            controller.on_key_down = nil
            controller.on_disconnected = nil
            controller.on_click = nil
            controller.on_accelerometer = nil
            controller.on_touch_down = nil
            controller.on_touch_up = nil
            controller.on_touch_move = nil
            controller.waiting_room = nil
            controller.update_waiting_room = nil

            for i,ctrl in ipairs(active_ctrls) do
                if ctrl == controller then
                    table.remove(active_ctrls, i)
                end
            end
            number_of_ctrls = number_of_ctrls - 1
        end

        if start_click then
            function controller:on_click(x, y)
                print("answered", controller.name, x, y)

                print("component "..tostring(router:get_active_component())
                .."handling click")
                router:get_active_controller():handle_click(controller, x, y)
            end
            controller:start_clicks()
        end

        if start_accel and controller.has_accelerometer then
            function controller:on_accelerometer(x, y, z)
                print("accelerometer: x", x, "y", y, "z", z)
            end
            controller:start_accelerometer("L", 1)
        end

        if start_touch and controller.has_touches then
            print("can accept touches!")
            function controller:on_touch_down(finger, x, y)
                print("answered", controller.name, x, y)

                print("component "..tostring(router:get_active_component())
                .." handling click")
                -- hackish way to do this for now
                router:get_active_controller():handle_click(controller, x, y)
            end
            function controller:on_touch_up(finger, x, y)
            end
            function controller:on_touch_move(finger, x, y)
            end
            function controller:on_key_down()
                return false
            end
            controller:start_touches()
        end

        function controller:choose_dog(players)
            print("controller", controller.name, "choosing dog")

            controller:clear_and_set_background("bkg")
            controller:add_image("hdr_choose_dog", 95, 30, 450, 50)
            for i = 1,6 do
                if not players[i] then
                    if not controller:add_image("dog_"..i, ((i-1)%2)*(256+8)+60,
                    math.floor((i-1)/2)*256+100, 256, 256) then
                        -- TODO: figure out some good error handling
                        print("error setting dog image")
                    end
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
            controller:clear_and_set_background("bkg")
            controller:add_image("hdr_name_dog", 109, 30, 422, 50)
            controller:add_image("dog_"..pos, 192, 100, 256, 256)
            if controller.has_text_entry
            and controller:enter_text("Name Your Dog", "Name Your Dog") then
                function controller:on_ui_event(text)
                    if text ~= "" and text ~= "Name Your Dog" then
                        controller.player.status:update_name(text)
                    end
                    controller.on_ui_event = function() end
                    controller:waiting_room()
                end
            end

            controller.state = ControllerStates.NAME_DOG
        end

        function controller:photo_dog(pos)
            print("giving dog a photo")
            if controller.has_pictures
            and controller:submit_picture() then
                function controller:on_picture(bitmap)
                    
                end
            end
        end

        function controller:waiting_room()
            controller:clear_and_set_background("bkg")
            controller:add_image("waiting_text", 0, 0, 640, 86)
            for i = 1,6 do
                controller:add_image("player_"..i, 0, (i-1)*115+86, 640, 115)
            end
            controller:add_image("start_button", 0, 6*115+86, 640, 95)
            controller:update_waiting_room(
                router:get_controller(Components.CHARACTER_SELECTION):get_players()
            )

            controller.state = ControllerStates.WAITING
        end

        function controller:update_waiting_room(players)
            local playing = {}
            for i,player in pairs(players) do
                local pos = player.dog_number
                controller:add_image("ready_label", 167, (pos-1)*115+86+60, 122, 34)
                if player.is_human then
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
            controller:clear_and_set_background("bkg")
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

        table.insert(active_ctrls, controller)

        if resources then
            for name,resource in pairs(resources) do
                controller:declare_resource(name, resource)
            end
        end
        declare_necessary_resources()
        router:get_active_controller():add_controller(controller)
    end

---------------Controller states---------------

    -- run the on connected for all controllers already connected
    -- before application startup
    function ctrlman:initialize()
        for i,controller in ipairs(controllers.connected) do
            print("adding controller "..controller.name)
            if controller.has_ui then
                controllers:on_controller_connected(controller)
            end
        end
    end

    -- put all controllers into the choose your dog mode
    function ctrlman:choose_dog(players)
        for i,controller in ipairs(active_ctrls) do
            controller:choose_dog(players)
        end
    end

    function ctrlman:update_choose_dog(players)
        for i,controller in ipairs(active_ctrls) do
            if controller.state == ControllerStates.CHOOSE_DOG then
                controller:choose_dog(players)
            end
        end
    end

    function ctrlman:waiting_room(players)
        for i,controller in ipairs(active_ctrls) do
            if controller.state ~= ControllerStates.WAITING then
                controller:waiting_room(players)
            end
        end
    end

    -- update the waiting room for all controllers
    function ctrlman:update_waiting_room(players)
        print("updating waiting room")
        for i,controller in ipairs(active_ctrls) do
            if controller.state == ControllerStates.WAITING then
                controller:waiting_room(players)
            end
        end
    end

    function ctrlman:enable_on_key_down()
        print("ctlrman enabling on_key_down")
        for i,controller in ipairs(active_ctrls) do
            function controller:on_key_down()
                return true
            end
        end
    end

    function ctrlman:disable_on_key_down()
        print("ctrlman disabling on_key_down")
        for i, controller in ipairs(active_ctrls) do
            function controller:on_key_down()
                return false
            end
        end
    end

end)
