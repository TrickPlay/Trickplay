dofile("Class.lua")
dofile("MVC.lua")
dofile("Header_View.lua")
dofile("Header_Controller.lua")

Component = {
    FOOD = 1
}

local model = Model()

local header_view = HeaderView(model)
header_view:initialize()


function screen:on_key_down(k)
   assert(model:get_active_controller())
   model:get_active_controller():on_key_down(k)
end

model:start_app(Component.FOOD)
