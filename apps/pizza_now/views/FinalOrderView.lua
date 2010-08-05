FinalOrderView = Class(View, function(view, model, parent_view, ...)
   view._base.init(view, model)
                                
   view.parent_view = parent_view
   view.cart_items = {}
   view.icons = {}
   
   view.ui = Group{name="finalOrder_ui", position={10, 10}, opacity=255}
   
   function view:initialize()
      self:set_controller(FinalOrderController(self))
   end
   
   function view:update()
      local controller = self:get_controller()
      local parent_controller = self.parent_view:get_controller()
      local checkout_group = parent_controller:get_selected_index()
      local CheckoutGroups = parent_controller.CheckoutGroups
      local comp = model:get_active_component()
   end
   
   function view:refresh_cart()
      
      print("refreshing cart on checkout screen, cart has "
            ..#model.cart.." item(s)")
      --if nil ~= #view.cart_items then
      for i=1,#view.cart_items do
         view.cart_items[i]:unparent()
      end
      for i=1,#view.icons do
         view.icons[i]:unparent()
      end
      
      --end
      view.cart_items = {}
      view.icons = {}
      local next_y = 60
      local cart_index = 1
      local y_adjust = 100
      while cart_index <= #model.cart and
         next_y <= EDIT_ORDER_Y do
         print("adding "..model.cart[cart_index].Name.." from cart to screen")
         local lines = model.cart[cart_index].CheckOutDesc()
         
         -- e.g. Large Handtossed Pizza with:      $16.95
         view.cart_items[#view.cart_items+1] = Text{
            position = {200,next_y},
            font = CUSTOMIZE_SUB_FONT_B,
            color = Colors.BLACK,
            text = lines.top
         }
         view.cart_items[#view.cart_items+1] = Text{
            position = {200,next_y+50},
            font = CUSTOMIZE_SUB_FONT,
            color = Colors.BLACK,
            text = lines.crust
         }
         if lines.entire ~= "" then
            view.cart_items[#view.cart_items+1] = Text{
               position = {200,next_y+y_adjust},
               font = CUSTOMIZE_SUB_FONT,
               color = Colors.BLACK,
               text = lines.entire
            }
            view.icons[#view.icons+1] = Image{
               position = {250,next_y+y_adjust-10},
               src = "assets/Placement/Entire.png"
            }
            y_adjust = y_adjust+50
         end
         if lines.left ~= "" then
            view.cart_items[#view.cart_items+1] = Text{
               position = {200,next_y+y_adjust},
               font = CUSTOMIZE_SUB_FONT,
               color = Colors.BLACK,
               text = lines.left
            }
            view.icons[#view.icons+1] = Image{
               position = {250,next_y+y_adjust-10},
               src = "assets/Placement/Left.png"
            }
            y_adjust = y_adjust+50
         end
         if lines.right ~= "" then
            view.cart_items[#view.cart_items+1] = Text{
               position = {200,next_y+y_adjust},
               font = CUSTOMIZE_SUB_FONT,
               color = Colors.BLACK,
               text = lines.right
            }
            view.icons[#view.icons+1] = Image{
               position = {250,next_y+y_adjust-10},
               src = "assets/Placement/Right.png"
            }
            y_adjust = y_adjust+50
         end
         next_y = next_y +120 -- + model.cart[cart_index].Desc_height
         cart_index = cart_index+1
      end
      view.moving_ui:add(unpack(view.cart_items))
      view.moving_ui:add(unpack(view.icons))
   end
end)
