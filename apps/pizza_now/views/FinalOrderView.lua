ORDER_SPACING = 10
RIGHT_LIMIT = 886
local Icons = {
   LEFT = Image{src="assets/PizzaHalfLeft.png",opacity=0},
   RIGHT = Image{src="assets/PizzaRightHalf.png",opacity=0},
   BOTH = Image{src="assets/PizzaHalfBoth.png",opacity=0},
   NONE = Image{src="assets/PizzaHalfNone.png",opacity=0},
   EDIT_BLK = Image{src="assets/EditItem.png",opacity=0},
   EDIT_RED = Image{src="assets/EditItemFocus.png",opacity=0},
   REMOVE_BLK = Image{src="assets/RemoveItem.png",opacity=0},
   REMOVE_RED = Image{src="assets/RemoveItemFocus.png",opacity=0}
}
local hidden_icons = Group{}
for k,icon in pairs(Icons) do
   hidden_icons:add(icon)
end
screen:add(hidden_icons)

local function to_ui(obj, price, y)
   local summary, custom
   local k=1

   local price_str
   if type(price) == "number" then
      price_str = string.format("$%.2f", price)
   end
   
   if type(obj) == "table" and obj.is_a and obj:is_a(DominosPizza) then
      summary, custom = obj:as_order()
   elseif type(obj) == "string" then
      summary = obj
   else
      error("to_ui does not support this object: " .. tostring(obj), 2)
   end

   local item_grp = Group{y=y}
   local current_y = 0

   -- Add summary text
   local summary_text = Text{
      text=summary,
      font="KacstArt 32px",
      width=RIGHT_LIMIT-185,
      wrap=true,
      alignment="LEFT",
      position={185, current_y}
   }
   current_y = summary_text.y+summary_text.h+ORDER_SPACING
   item_grp:add(summary_text)

   if type(custom) == "table" then
      -- Add whole pizza info
      if #custom[Placement.WHOLE] > 0 then
         local both_icon = Clone{
            source=Icons.BOTH,
            position={178,current_y-16},
         }
         local both_text = Text{
            text=table.concat(custom[Placement.WHOLE], ", "),
            font="KacstArt 32px",
            width=RIGHT_LIMIT-245,
            wrap=true,
            alignment="LEFT",
            position = {245, current_y}
         }
         item_grp:add(both_icon, both_text)
         current_y = both_text.y+both_text.h+ORDER_SPACING
      end

      -- Add left half info
      if #custom[Placement.LEFT] > 0 then
         local left_icon = Clone{
            source=Icons.LEFT,
            position={178,current_y-16}
         }
         local left_text = Text{
            text=table.concat(custom[Placement.LEFT], ", "),
            font="KacstArt 32px",
            width=RIGHT_LIMIT-245,
            wrap=true,
            alignment="LEFT",
            position = {245,current_y}
         }
         item_grp:add(left_icon, left_text)
         current_y = left_text.y+left_text.h+ORDER_SPACING
      end

      -- Add right half info
      if #custom[Placement.RIGHT] > 0 then
         local right_icon = Clone{
            source=Icons.RIGHT,
            position={178,current_y-16}
         }
         local right_text = Text{
            text=table.concat(custom[Placement.RIGHT], ", "),
            font="KacstArt 32px",
            width=RIGHT_LIMIT-245,
            wrap=true,
            alignment="LEFT",
            --position={245,225}
            position={245,current_y}
         }
         item_grp:add(right_icon, right_text)
         current_y = right_text.y+right_text.h+ORDER_SPACING
      end
   end

   local edit_icon = Clone{
      name="unfocus",
      source=Icons.EDIT_BLK,
      position={RIGHT_LIMIT-218,current_y-6}
   }
   local edit_icon_focus = Clone{
      source=Icons.EDIT_RED,
      position={RIGHT_LIMIT-218,current_y-6},
      opacity=0
   }
      
   local remove_icon = Clone{
      name="unfocus",
      source=Icons.REMOVE_BLK,
      position={RIGHT_LIMIT-168,current_y-6}
   }
   local remove_icon_focus = Clone{
      source=Icons.REMOVE_RED,
      position={RIGHT_LIMIT-168,current_y-6},
      opacity=0
   }
   local price_text = Text{
      text=price_str or "$16.50",
      font="KacstArt 32px",
      width=RIGHT_LIMIT-801,
      position={801,current_y},
      wrap=true,
      alignment="RIGHT"
   }
   current_y = price_text.y+price_text.h+ORDER_SPACING
   item_grp:add(edit_icon, edit_icon_focus, remove_icon, remove_icon_focus, price_text)
   local edit_icons = {unfocus=edit_icon, focus=edit_icon_focus}
   local remove_icons = {unfocus=remove_icon, focus=remove_icon_focus}
   return item_grp, current_y, edit_icons, remove_icons
end












FinalOrderView = Class(View, function(view, model, parent_view, ...)
   view._base.init(view, model)
                                
   view.parent_view = parent_view
   local cart_items = {}
-- MAKE local icons table, so I can change it as I need.
   local icons = {}
   
   view.ui = Group{name="finalOrder_ui", position={0,0}, opacity=255}
   local ui_clipper = Group{name="ui_clipper", position={0,15}, opacity=255, clip = {0,0, 960, 720}}
   local up_arrow = Image{src="assets/UpScrollArrow.png", position={910, 10}, opacity=0}
   local down_arrow = Image{src="assets/DownScrollArrow.png", position={910, 700}, opacity=0}
   local order_grp = Group{position={0,15}}
   --more text
   local subtotal_text = Text{
      position = {190, 750},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Subtotal"
   }
   local subtotal_cost = Text{
      text="",
      font=CUSTOMIZE_SUB_FONT,
      color = Colors.BLACK,
      width=RIGHT_LIMIT-801,
      position={801,750},
      wrap=true,
      alignment="RIGHT"
   }
   local tax_text = Text{
      position = {190, 800},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Tax, Processing, & Delivery",
   }
   local tax_cost = Text{
      text="",
      font=CUSTOMIZE_SUB_FONT,
      color = Colors.BLACK,
      width=RIGHT_LIMIT-801,
      position={801,800},
      wrap=true,
      alignment="RIGHT"
   }
   local total_text = Text{
      position = {170,880},
      font = CUSTOMIZE_TAB_FONT,
      color = Colors.BLACK,
      text = "Total",
   }
   local total_cost = Text{
      text="",
      font=CUSTOMIZE_TAB_FONT,
      color = Colors.BLACK,
      position={801,880},
      wrap=true,
      alignment="RIGHT",
      width=RIGHT_LIMIT-801
   }

   ui_clipper:add(order_grp)
   view.ui:add(
      ui_clipper,
      subtotal_text, subtotal_cost,
      tax_text, tax_cost,
      total_text, total_cost,
      up_arrow, down_arrow
   )

   local lut = {}

   function view:initialize()
      self:set_controller(FinalOrderController(self))
      local cont = self:get_controller()
      lut = {
         [cont.Choices.EDIT] = "edit",
         [cont.Choices.REMOVE] = "remove"
      }
   end
   
   function view:update()
      local controller = self:get_controller()
      local comp = model:get_active_component()
      local sel_choice, sel_item = controller:get_selected()
      if comp == Components.CHECKOUT and #icons > 0 then
         local choice_name = lut[sel_choice]
         for i, choice_icons in ipairs(icons) do
            for j, tweak_icons in pairs(choice_icons) do
               if i == sel_item and j == choice_name then
                  tweak_icons.focus:raise_to_top()
                  tweak_icons.focus:animate{duration=50,opacity = 255}
                  tweak_icons.unfocus:animate{duration=50, opacity = 0}
               else
                  tweak_icons.unfocus.opacity = 255
                  tweak_icons.unfocus:raise_to_top()
                  tweak_icons.focus.opacity = 0
               end
            end
         end

         -- if target item is off screen, animate it onto the screen,
         -- possibly kicking other shit off.

         -- first check if target item is off the top of the screen.
         -- new selected item is currently off the top of the screen
         if sel_item then
            if order_grp.y+cart_items[sel_item].y < ui_clipper.clip[2] then
               order_grp:animate{
                  duration=100,
                  y = ui_clipper.clip[2] - cart_items[sel_item].y,
                  mode = "EASE_OUT_BOUNCE"
               }
               down_arrow:animate{duration=50, opacity=255}
               if sel_item == 1 then
                  up_arrow:animate{duration=50, opacity=0}
               else
                  up_arrow:animate{duration=50, opacity=255}
               end
            elseif order_grp.y+cart_items[sel_item].y+cart_items[sel_item].h > ui_clipper.clip[2]+ui_clipper.clip[4] then
               order_grp:animate{
                  duration=100,
                  y = ui_clipper.clip[2]+ui_clipper.clip[4] -
                     (cart_items[sel_item].y+cart_items[sel_item].h),
                  mode = "EASE_OUT_BOUNCE"
               }
               up_arrow:animate{duration=50, opacity=255}
               if sel_item == #cart_items then
                  down_arrow:animate{duration=50, opacity=0}
               else
                  down_arrow:animate{duration=50, opacity=255}
               end               
            end
         end
      end
   end
   
   function view:refresh_cart()
      order_grp:clear()
      cart_items = {}
      icons = {}
      up_arrow.opacity=0
      down_arrow.opacity=0
      local item_grp
      local current_y = 0
      local height
      
      local subtotal = 0
      for i, pizza in ipairs(model.cart) do
         subtotal = subtotal + pizza.Price
         item_grp, height, edit_icon, remove_icon = to_ui(pizza:as_dominos_pizza(), pizza.Price, current_y)
         table.insert(cart_items, item_grp)
         table.insert(icons, {edit=edit_icon, remove=remove_icon})
         current_y = current_y + height
      end

      local tax = subtotal*.0925 + 2
      local total = subtotal + tax

      subtotal_cost.text = string.format("$%.2f", subtotal)
      tax_cost.text = string.format("$%.2f", tax)
      total_cost.text = string.format("$%.2f", total)

      order_grp:add(unpack(cart_items))
      if order_grp.y+cart_items[#cart_items].y+cart_items[#cart_items].h > ui_clipper.clip[2]+ui_clipper.clip[4] then
         down_arrow.opacity=255
      end
   end

   function view:do_remove_animation()
      local sel_choice, sel_item = self:get_controller():get_selected()
      print("do_remove_animation called")
      assert(type(sel_item) == "number", "sel_item not a number")
      assert(1 <= sel_item and sel_item <= #cart_items, "sel_item index not in cart_items array")
      local removed_item = table.remove(cart_items, sel_item)
      local removed_icons = table.remove(icons, sel_item)
      local choice_name = lut[sel_choice]
      local icon = icons[sel_item][choice_name]
      removed_item.extra.cart_items = cart_items
      removed_item.extra.sel_item = sel_item
      removed_item.extra.top_of_order = order_grp.y
      removed_item.extra.bottom_edge = ui_clipper.clip[2]+ui_clipper.clip[4]
      removed_item.extra.icon = icon
      removed_item:animate{
         duration=50,
         opacity=0,
         on_completed=
         function(anim,ui)
            if not ui then ui = anim end -- workaround for change in method signature from trickplay 0.0.6 to 0.0.7

            local cart_items = ui.extra.cart_items
            local sel_item = ui.extra.sel_item
            local icon = ui.extra.icon

            if #cart_items == 0 then
               down_arrow:animate{duration=50, opacity=0}
            else
               icon.focus:raise_to_top()
               icon.focus:animate{duration=50, opacity=255}
               icon.unfocus:animate{duration=50, opacity=0}
               if ui.extra.top_of_order+cart_items[#cart_items].y+cart_items[#cart_items].h <= ui.extra.bottom_edge then
                  down_arrow:animate{duration=50, opacity=0}
               end
               
               if sel_item <= #cart_items then
                  local y_trans = cart_items[sel_item].y-ui.y
                  for i=sel_item, #cart_items do
                     cart_items[i]:animate{duration=50,y=cart_items[i].y-y_trans}
                  end
               end

            end
            ui:unparent()
         end
      }

      if #cart_items > 0 then
         icon.focus:raise_to_top()
         icon.focus:animate{duration=50, opacity=255}
         icon.unfocus:animate{duration=50, opacity=0}
      end
   end
end)
