dofile("Class.lua")
dofile("MVC.lua")
dofile("Carousel_View.lua")
dofile("Carousel_Controller.lua")

Component = {
    CAROUSEL = 1
}

local model = Model()

local carousel_view = CarouselView(model)
carousel_view:initialize()


function screen:on_key_down(k)
   assert(model:get_active_controller())
   model:get_active_controller():on_key_down(k)
end

model:start_app(Component.CAROUSEL)
