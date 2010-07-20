AddressInputView = Class(View,
   function(view, model, ...)
      view._base.init(view,model)

      local street = Text{
         position={50,0},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         editable = true,
         text="Enter Street"
      }
      local apartment = Text{
         position = {400, 0},
         font=DEFAULT_FONT,
         color = DEFAULT_COLOR,
         editable = true,
         text = "Apt."
      }
      local city = Text{
         position={50,60},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         editable = true,
         text="City"
      }
      local zip_code = Text{
         position={50,120},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         editable = true,
         text="Zip Code"
      }
      local confirm = Text{
         position={50, 180},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text = "Confirm Address?"
      }
      local exit = Text{
         position={50, 240},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text = "Exit App?"
      }

      local menu_items = {street, apartment, city, zip_code, confirm, exit}
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
