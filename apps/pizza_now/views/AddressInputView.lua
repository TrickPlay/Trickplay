AddressInputView = Class(View,
   function(view, model, ...)
      view._base.init(view,model)

      local item1_graphic = Text{
         position={50,0},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text="item1"
      }
      local item2_graphic = Text{
         position={50,60},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text="item2"
      }
      local item3_graphic = Text{
         position={50,120},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text="item3"
      }

      local menu_items = {item1_graphic, item2_graphic, item3_graphic}
      local ui=Group{name="address_ui", position={660,180}, opacity=0}
      ui:add(unpack(menu_items))
      screen:add(ui)

      function view:initialize()
         self:set_controller(AddressInputController(self))
      end

      function view:update()
         local controller = view:get_controller()
         local comp = model:get_active_component()
         if comp == Components.ADDRESS_INPUT then
            print("Showing AddressInputView UI")
            ui.opacity = 255
            for i,item in ipairs(menu_items) do
               if i == controller:get_selected_index() then
                  item:animate{duration=1000, mode="EASE_OUT_EXPO", opacity=255}
               else
                  item:animate{duration=1000, mode="EASE_OUT_BOUNCE", opacity=0}
               end
            end
         else
            print("Hiding AddressInputView UI")
            ui.opacity = 0
         end
      end

   end)
