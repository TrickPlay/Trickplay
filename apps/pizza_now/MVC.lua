Model = Class(nil, -- base class
   function(model, ...) -- constructor, called with Model(...)
      -- (private) class fields
      registry = {}
      controllers = {}
      active_component = nil

      -- class methods
      function model:attach(observer, controller_id)
         registry[observer] = true
         if controller_id then
            controllers[controller_id] = observer
         end
      end

      function model:detach(observer)
         registry[observer] = nil
      end

      function model:notify()
         for observer, bool in pairs(registry) do
            observer:update()
         end
      end

      function model:get_active_controller()
         return controllers[active_component]
      end

      function model:get_active_component()
         return active_component
      end

      function model:start_app(comp)
         active_component = comp
         screen:show()
         self:notify()
      end
   end)














Observer = Class(nil,
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
      local model = model
      local controller = nil
      model:attach(view)

      -- class methods
      function view:initialize()
         error("Initializing empty controller", 2)
         controller = Controller(self)
      end

      function view:get_model()
         return model
      end

      function view:set_controller(cont)
         controller = cont
         view.set_controller = nil
      end

      function view:get_controller()
         return controller
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
      local model = view:get_model()
      local view = view
      model:attach(controller, controller_id)

      function controller:update()
      end

      function controller:get_model()
         return model
      end

      function controller:get_view()
         return view
      end
   end)