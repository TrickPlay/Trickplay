dofile("Class.lua")
dofile("MVC.lua")
dofile("Footer_View.lua")
dofile("Footer_Controller.lua")

Component = {
    FOOD = 1
}

local model = Model()

local footer_view = FooterView(model)
footer_view:initialize()


function screen:on_key_down(k)
   assert(model:get_active_controller())
   model:get_active_controller():on_key_down(k)
end

model:start_app(Component.FOOD)
