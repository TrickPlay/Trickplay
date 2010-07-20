ProviderSelectionView = Class(View,
   function(view, model, ...)
      view._base.init(view,model)

      local dominos_1 = Text{
         position={50,0},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         editable = true,
         text="Dominos?"
      }
      local dominos_2 = Text{
         position={50,60},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text="Dominos!"
      }
      local dominos_3 = Text{
         position={50,120},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text=":)"
      }
      local pizza_hut = Text{
         position={50, 180},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text = "Pizza Hut"
      }
      local go_back = Text{
         position={50, 240},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text = "Go Back"
      }

      local menu_items = {dominos_1, dominos_2, dominos_3, pizza_hut, go_back}
      local ui=Group{name="provider_ui", position={660,180}, opacity=0}
      ui:add(unpack(menu_items))
      screen:add(ui)

      function view:initialize()
         self:set_controller(ProviderSelectionController(self))
      end

      function view:update()
         local controller = view:get_controller()
         local comp = model:get_active_component()
         if comp == Components.PROVIDER_SELECTION then
            print("Showing ProviderSelectionView UI")
            ui.opacity = 255
            for i,item in ipairs(menu_items) do
               if i == controller:get_selected_index() then
                  item:animate{duration=1000, mode="EASE_OUT_EXPO", opacity=255}
               else
                  item:animate{duration=1000, mode="EASE_OUT_BOUNCE", opacity=0}
               end
            end
         else
            print("Hiding ProviderSelectionView UI")
            ui.opacity = 0
         end
      end

   end)
