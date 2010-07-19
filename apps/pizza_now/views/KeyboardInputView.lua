KeyboardInputView = Class(View,
   function(view, model, ...)
      view._base.init(view,model)

      local textbox = Text{
         position={50,0},
         font=DEFAULT_FONT,
         color=DEFAULT_COLOR,
         text="Example Text"
      }

      local ui=Group{name="kbd_ui", position={660,180}, opacity=0}
      ui:add(textbox)
      screen:add(ui)

      function view:initialize()
         self:set_controller(KeyboardInputController(self))
      end

      function view:update()
         local controller = view:get_controller()
         local comp = model:get_active_component()
         textbox.text = controller:get_textbox_text()
         print(textbox.text)
         if comp == Components.KEYBOARD_INPUT then
            ui.opacity = 255
         else
            ui.opacity = 0
         end
      end
   end)