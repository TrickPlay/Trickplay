dofile("Class.lua")
dofile("MVC.lua")

dofile("header_practice/Header_View.lua")
dofile("header_practice/Header_Controller.lua")
dofile("footer_practice/Footer_View.lua")
dofile("footer_practice/Footer_Controller.lua")
dofile("mvc_carousel/Carousel_View.lua")
dofile("mvc_carousel/Carousel_Controller.lua")

dofile("Top_Level_View.lua")
dofile("Top_Level_Controller.lua")
Component = {
    FOOD = 1
}

local model = Model()

local top_level_view = TopLevelView(model)
top_level_view:initialize()


function screen:on_key_down(k)
   assert(model:get_active_controller())
   model:get_active_controller():on_key_down(k)
end

model:start_app(Component.FOOD)
