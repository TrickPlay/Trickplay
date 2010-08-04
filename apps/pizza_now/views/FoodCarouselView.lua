FoodCarouselView = Class(View,
   function(view, model, ...)
      view._base.init(view,model, Components.PROVIDER_SELECTION)
      
      local menu_items = {
         Image{src="assets/SelectPizzaLarge.png", scale={.5,.5}},
         Image{src="assets/SelectNormalLarge.png", scale={.5,.5}},
         Image{src="assets/SelectNormalLarge.png", scale={.5,.5}},
         Image{src="assets/SelectNormalLarge.png", scale={.5,.5}},
         Image{src="assets/SelectNormalLarge.png", scale={.5,.5}},
         Image{src="assets/SelectNormalLarge.png", scale={.5,.5}},
      }

      view.ui = Group{name="Food Carousel UI", position={0,0}, opacity=0}

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

      --inited means that it's already been placed on screen
      local ui = Group{name="foodCarousel_ui", position={0,0}, opacity=0, extra={inited=false}}
      ui:add(unpack(menu_items))
      view.ui = ui
      local center = {960,480}
      local item_scale = {1,1}
      local side_item_scale = {.55,.55}
      local regular_scale = {.5,.5}
      local animate_duration = 50

      function view:initialize()
         self:set_controller(FoodCarouselController(self))
      end

      function view:calculate_end_attrs()
         local selected = self:get_controller():get_selected_index()
         local foc_item = menu_items[selected]
         local current_menu_h = menu_h
         if foc_item.h*item_scale[2] > current_menu_h then
            current_menu_h = foc_item.h*item_scale[2]
         end
         
         -- local current_menu_w =
         --    menu_items_width + (#menu_items-1)*menu_items_sep+foc_item.w*(item_scale[1]-1)
         -- store all the ultimate menu_item positions so we can run animations all at once at the end.
         local end_attrs = {}
         for i=1,#menu_items do
            end_attrs[i] = {}
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
         return grp_end_attrs, end_attrs
      end

      

      function view:update()
         local controller = self:get_controller()
         local comp = self.model:get_active_component()
         -- if the doubled-in-height element is the new height of the menu, new_menu_h has the height to reflect that.
         if comp == Components.FOOD_SELECTION then
            local grp_end_attrs, end_attrs = view:calculate_end_attrs()
            if ui.extra.inited then
               grp_end_attrs.duration = animate_duration
               ui:animate(grp_end_attrs)
               for i, menu_item in ipairs(menu_items) do
                  assert(end_attrs[i], type(end_attrs[i]))
                  end_attrs[i].duration = animate_duration
                  menu_item:animate(end_attrs[i])
               end
            else
               ui.extra.inited = true
               for k,v in pairs(grp_end_attrs) do
                  ui[k] = v
               end
               for i, menu_item in ipairs(menu_items) do
                  for k,v in pairs(end_attrs[i]) do
                     menu_item[k] = v
                  end
               end
            end
         else
--            ui.opacity = 0
         end
      end
   end)