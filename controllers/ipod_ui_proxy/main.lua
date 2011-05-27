dofile("AdvancedUIClasses.lua")

function controllers:on_controller_connected(controller)
    print("CONNECTED", controller.name)

    -- Set up disconnection routine
    function controller:on_disconnected()
        print("DISCONNECTED", controller.name)
        screen.on_key_down = nil
    end
    dumptable(class_table)
    factory = loadfile("AdvancedUIAPI.lua")( controller , class_table )

    local key_handler = {}
    function screen:on_key_down(key)
        for k,func in pairs(key_handler) do
            if k == key then
                func()
            end
        end
    end

    controller:declare_resource("chip", "assets/chip1.png")

    local r = nil
    local g = nil
    key_handler[keys.r] = function()
        r = factory:Rectangle{color = "FF00FFFF", x = 10, size = { 40 , 80 }}
        dumptable(r)
    end
    key_handler[keys.g] = function()
        g = factory:Group{ x = 20, y = 60}
        dumptable(g)
    end
    key_handler[keys.a] = function()
        if r and g then
            g:add(r)
        end
    end
    key_handler[keys.h] = function()
        if r then r:hide() end
    end
end

for k,controller in pairs(controllers.connected) do
    if controller.has_pictures then
        controllers:on_controller_connected(controller)
    end
end

--r2 = factory:Rectangle{}

--g = factory:Group{}

--g:add( r , r2 )


screen:show()
