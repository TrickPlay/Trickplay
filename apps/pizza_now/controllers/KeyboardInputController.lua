KeyboardInputController = Class(Controller,
   function(self, view, ...)
      self._base.init(self, view, Components.KEYBOARD_INPUT)

      local textbox_text = "Example text"

      function self:get_textbox_text()
         return textbox_text
      end

      function self:on_key_down(k)
         print("key pressed:", k)
         if Characters[k] then
            textbox_text = textbox_text .. Characters[k]
         elseif k == keys.BackSpace then
            textbox_text = string.sub(textbox_text, 1,-2)
         end
         self:get_view():update()
      end
   end)