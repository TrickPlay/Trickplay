BackgroundView = {}
function BackgroundView:new(model)
   local ui = Group{opacity=0}
   local bg_image = Image{src="assets/MapBg.jpg", z=-10}
   ui:add(bg_image)
   screen:add(ui)
   local model = model
   local controller = nil
   local object = {
      ui=ui,
      model=model,
      controller=controller
   }
   setmetatable(object, self)
   self.__index = self
   model:attach(object)
   return object
end

function BackgroundView:update()
   screen:show()
   self.ui.opacity=255
   self.model:detach(self)
end

function BackgroundView:initialize()
end
