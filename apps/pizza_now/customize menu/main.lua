dofile("Class.lua")
dofile("MVC.lua")
dofile("EmptyPizza.lua")
dofile("Tab_View.lua")
dofile("Tab_Controller.lua")
dofile("Customize_View.lua")
dofile("Customize_Controller.lua")

Component = {
    CUSTOMIZE = 1,
    TAB = 2
}

local model = Model()
customize_view = CustomizeView(model)
customize_view:initialize()
tab_view = TabView(model)
tab_view:initialize()
customize_view:get_controller():set_child_controller(tab_view:get_controller())



function screen:on_key_down(k)
   assert(model:get_active_controller())
   model:get_active_controller():on_key_down(k)
end

model:start_app(Component.CUSTOMIZE)
