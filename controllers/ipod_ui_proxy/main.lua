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
    factory = loadfile("AdvancedUIAPI.lua")( controller )

    local key_handler = {}
    function screen:on_key_down(key)
        for k,func in pairs(key_handler) do
            if k == key then
                func()
            end
        end
    end

    --[[
        Some hot-keys for testing
    --]]

    -- Declare an image resource than may be used to load images
    controller:declare_resource("chip", "assets/chip1.png")

    -- create a Rectangle
    key_handler[keys.r] = function()
        r = factory:Rectangle{color = "FF00FFFF", x = 10, size = { 40 , 80 }}
        dumptable(r)
    end
    -- create a Group
    key_handler[keys.g] = function()
        g = factory:Group{ x = 20, y = 60}
        dumptable(g)
    end
    -- create an Image using the 'chip' image
    key_handler[keys.i] = function()
        i = factory:Image{x = 100, y = 100, w = 100, h = 100, src = "chip"}
        dumptable(i)
    end
    -- create a Text element
    key_handler[keys.t] = function()
        t = factory:Text{x = 200, y = 200, w = 100, h = 100, text = "I am text"}
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
