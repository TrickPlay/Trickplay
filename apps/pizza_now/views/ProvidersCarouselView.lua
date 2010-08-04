ProvidersCarouselView = Class(View,
   function(view, model, ...)
      view._base.init(view,model, Components.PROVIDER_SELECTION)
      
      local menu_items = {
         Image{src="assets/DominosStoreSmall.png"},
         Image{src="assets/DominosStoreSmall.png"},
         Image{src="assets/DominosStoreSmall.png"},
         Image{src="assets/DominosStoreSmall.png"},
         Image{src="assets/DominosStoreSmall.png"},
         -- Image{src="assets/ph_logo.png"},
         -- Image{src="assets/rtp_logo.jpg"},
         -- Image{src="assets/pmh_logo.jpg"},
         -- Image{src="assets/pj_logo.gif"},
      }
      local menu_items_width = 0
      local menu_h = 0
      for _,menu_item in ipairs(menu_items) do
         menu_items_width = menu_items_width + menu_item.w
         if menu_item.h > menu_h then
            menu_h = menu_item.h
         end
      end
      assert(menu_items_width ~= 0, "Menu items have 0 width!")

      local menu_items_sep = MENU_ITEMS_SEP

      local ui = Group{name="providersCarousel_ui", position={0,0}, opacity=0}
      ui:add(unpack(menu_items))
      view.ui = ui
      local center = screen.center
      local item_scale = {2,2}
      local side_item_scale = {1.1,1.1}
      local regular_scale = {1,1}
      local animate_duration = 50
      function view:initialize()
         self:set_controller(ProvidersCarouselController(self))
      end
      
      function view:update()
         local controller = self:get_controller()
         local comp = self.model:get_active_component()
         local selected = controller:get_selected_index()
         -- if the doubled-in-height element is the new height of the menu, new_menu_h has the height to reflect that.
         if comp == Components.PROVIDER_SELECTION then
            ui.opacity = 255

            local foc_item = menu_items[selected]
            local current_menu_h = menu_h
            if foc_item.h*item_scale[2] > current_menu_h then
               current_menu_h = foc_item.h*item_scale[2]
            end

            -- local current_menu_w =
            --    menu_items_width + (#menu_items-1)*menu_items_sep+foc_item.w*(item_scale[1]-1)
            -- store all the ultimate menu_item positions so we can run animations all at once at the end.
            local end_attrs = {duration=animate_duration}
            for i=1,#menu_items do
               end_attrs[i] = {duration=animate_duration}
            end
            
            -- first redefine cen_x, cen_y for within ui group
            local cen_y = current_menu_h/2
            local x_so_far = 0
            local scale = {1,1}
            for i,menu_item in ipairs(menu_items) do
               -- calculate appropriate scale
               if i==selected then
                  scale=item_scale
               elseif i==selected+1 or i==selected-1 then
                  scale = side_item_scale
               else
                  scale = regular_scale
               end

               -- update animation params
               end_attrs[i].x = x_so_far
               end_attrs[i].scale=scale
               end_attrs[i].y = cen_y - menu_item.h*scale[2]/2

               -- update new x coordinate
               x_so_far = x_so_far + menu_item.w*scale[1]+menu_items_sep
            end

            local grp_end_attrs = {
               duration=100,
               x=center[1]-x_so_far/2,
               y=center[2]-current_menu_h/2,
            }
            ui:animate(grp_end_attrs)
            for i, menu_item in ipairs(menu_items) do
               assert(end_attrs[i], type(end_attrs[i]))
               menu_item:animate(end_attrs[i])
            end
         else
            self.ui.opacity = 80
         end
      end
   end)
