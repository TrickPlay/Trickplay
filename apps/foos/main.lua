dofile("Class.lua") -- Must be declared before any class definitions.
dofile("MVC.lua")
dofile("FrontPageView.lua")
dofile("FrontPageController.lua")

dofile("Load.lua")

Components = {
   COMPONENTS_FIRST = 1,
   FRONT_PAGE       = 1,
   COMPONENTS_LAST  = 1
}
local model = Model()


local front_page_view = FrontPageView(model)
front_page_view:initialize()

function screen:on_key_down(k)
   if k == keys.r then
      model:notify()
   else
      assert(model:get_active_controller())
      model:get_active_controller():on_key_down(k)
   end
end

model:start_app(Components.FRONT_PAGE)

