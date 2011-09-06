--dumptable = function() end
-- Load the AdvancedUI Classes into a class table.
local class_table = dofile("AdvancedUIClasses.lua")

-- Controller initialization function
function controllers:on_controller_connected(controller)
    print("CONNECTED", controller.name)

    -- Set up disconnection routine
    function controller:on_disconnected()
        print("DISCONNECTED", controller.name)
        screen.on_key_down = nil
    end
    function controller:on_advanced_ui_ready()
        controller.factory = loadfile("AdvancedUIAPI.lua")( controller )
        print(controller.factory)
    end

    local key_handler = {}
    function screen:on_key_down(key)
        print("on_key_down:", key)
        if key == keys.BACK then print("back")
        elseif key == keys.RED then print("red")
        end
        for k,func in pairs(key_handler) do
            if k == key then
                func()
            end
        end
    end

    if controller.has_touches then
        function controller:on_touch_down(finger, x, y)
            print("on_touch_down:", finger, "x:", x, "y:", y)
        end
        function controller:on_touch_move(finger, x, y)
            print("on_touch_move:", finger, "x:", x, "y:", y)
        end
        function controller:on_touch_up(finger, x, y)
            print("on_touch_up:", finger, "x:", x, "y:", y)
        end
    end

    --[[
        Some hot-keys for testing
    --]]

    -- Declare an image resource than may be used to load images
    --controller:declare_resource("chip", "assets/chip1.png")

    -- create a Rectangle
    key_handler[keys.r] = function()
        r = controller.factory:Rectangle{color = "FF00FFFF", x = 10, size = { 40 , 80 }}
        function r:on_touches(touches, state)
            print("touched my rectangle with state:", state)
            dumptable(touches)
        end
        dumptable(r)
    end
    -- create a Group
    key_handler[keys.g] = function()
        g = controller.factory:Group{x = 20, y = 60, w = 50, h = 50}
        function g:on_touches(touches, state)
            print("touched my group with state:", state)
            dumptable(touches)
        end
        dumptable(g)
    end
    -- create an Image using the 'chip' image
    key_handler[keys.i] = function()
        controller:declare_resource("chip", "assets/chip1.png")
        i = controller.factory:Image{x = 100, y = 100, w = 100, h = 100, src = "chip"}
        j = controller.factory:Image{x = 200, y = 500, w = 100, h = 100, src = "chip"}
        function i:on_loaded(failed)
            print("i image loaded?: "..tostring(not failed))
        end
        function j:on_loaded(failed)
            print("j image loaded?: "..tostring(not failed))
        end
        dumptable(i)
    end
    -- create a Text element
    key_handler[keys.t] = function()
        t = controller.factory:Text{x = 200, y = 200, w = 100, h = 100, text = "I am text"}
        function t:on_text_changed(string)
            print("text changed:", string)
        end
        function t:on_touches(touches, state)
            print("touched my text with state:", state)
            dumptable(touches)
        end
        dumptable(t)
    end
    -- add the Rectangle to the Group if both exist
    key_handler[keys.a] = function()
        if r and g then
            g:add(r)
        end
    end
    -- hide and show the Rectangle
    key_handler[keys.h] = function()
        if r then r:hide() end
    end
    key_handler[keys.s] = function()
        if r then r:show() end
    end
    -- speed test
    key_handler[keys.c] = function()
        print("idle control")
        if idle.on_idle then 
            idle.on_idle = nil
            return
        end
        function idle:on_idle(seconds)
            print(seconds)
            g:show()
            g:hide()
            --r = factory:Rectangle{color = "FF00FFFF", x = 10, size = { 40 , 80 }}
        end
    end
    -- set bkg vs adanced_ui image bug
    key_handler[keys.b] = function()
        print("bkg vs advanced_ui image")
        controller:set_ui_background("chip")
        i = controller.factory:Image{x = 100, y = 100, w = 100, h = 100, src = "chip"}
    end
    ctrl = controller
end

for k,controller in pairs(controllers.connected) do
    if controller.has_advanced_ui then
        controllers:on_controller_connected(controller)
    end
end

--r2 = factory:Rectangle{}

--g = factory:Group{}

--g:add( r , r2 )


screen:show()
