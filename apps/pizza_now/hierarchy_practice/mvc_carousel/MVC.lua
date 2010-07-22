Model = Class(
   function(model, ...) -- constructor, called with Model(...)
      -- (private) class fields
      model.registry = {}
      model.controllers = {}
      model.active_component = nil

      -- class methods
      function model:attach(observer, controller_id)
         self.registry[observer] = true
         if controller_id then
            self.controllers[controller_id] = observer
         end
      end

      function model:detach(observer)
         self.registry[observer] = nil
      end

      function model:notify()
          for observer, bool in pairs(self.registry) do
             observer:update()
          end
      end

      function model:get_active_controller()
         return self.controllers[self.active_component]
      end

      function model:get_active_component()
         return self.active_component
      end

      function model:start_app(comp)
         self.active_component = comp
         screen:show()
         self:notify()
      end
      
      function model:set_active_component(comp)
         self.previous_component = self.active_component
         self.active_component = comp
         print("set active component")
      end
   end)




Observer = Class(
   function(observer, ...)
      -- class fields

      -- class methods
      function observer:update()
         error("Update not defined for observer") 
     end
   end)

View = Class(Observer,
   function(view, model, ...)
      -- COMMON VIEW LOGIC
      
      -- (private) class fields
      view.model = model
      view.controller = nil
      model:attach(view)

      -- class methods
      function view:initialize()
         error("Initializing empty controller", 2)
         self.controller = Controller(self)
      end

      function view:get_model()
         return self.model
      end

      function view:set_controller(cont)
         self.controller = cont
         self.set_controller = nil
      end

      function view:get_controller()
         return self.controller
      end

      function view:update()
         error("not implemented")
      end
      -- END COMMON VIEW LOGIC
   end)

Controller = Class(Observer,
   function(controller, view, controller_id)
      assert(controller_id)

      -- class fields
      controller.model = view:get_model()
      controller.view = view
      controller.model:attach(controller, controller_id)

      function controller:update()
      end

      function controller:get_model()
         return self.model
      end

      function controller:get_view()
         return self.view
      end
   end)
