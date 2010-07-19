MainMenuView = {}
function MainMenuView:new(model)
   local model = model or
      error("Model is nil", 2)
   local controller = nil

   -- initializing menu graphics   
   local bg = Image{
      name="menu_bg",
      position={50,0},
      src="assets/MenuBg.png",
--      opacity=200,
      opacity=255,
   }
   local title_graphic = Image{
      position={120,60},
      src="assets/M-DiceCraft.png"
   }
   local continue_graphic = Image{
      position={120,180},
      src="assets/M-Continue.png"
   }
   local new_game_graphic = Image{
      position={120,300},
      src="assets/M-NewGame.png"
   }

   -- initialize graphic element for humans menu item
   local humans_graphic = Group{name="humans", x=180,y=420}

   local humans_label = Image{src="assets/M-Humans.png", x=0, y=0}
   local humans_nums = {
      [1]=Image{src="assets/M-N1.png", opacity=0, x=210, y=0},
      [2]=Image{src="assets/M-N2.png", opacity=0, x=210, y=0},
      [3]=Image{src="assets/M-N3.png", opacity=0, x=210, y=0},
      [4]=Image{src="assets/M-N4.png", opacity=0, x=210, y=0},
   }
   humans_graphic:add(humans_label)
   for _,image in pairs(humans_nums) do
      humans_graphic:add(image)
   end


   local exit_graphic = Image{
      position={120,540},
      src="assets/M-Exit.png"
   }

   local ui=Group{name="main_menu_ui", position={660,180}, opacity=0, extra={orig_position={660, 180}}}
   local fg=Group{}
   ui:add(bg, fg)
   fg:add(title_graphic, continue_graphic, new_game_graphic, humans_graphic, exit_graphic)

   local menu_items = {continue_graphic, new_game_graphic, humans_graphic, exit_graphic}

   screen:add(ui)

   local object = {
      bg=bg,
      fg=fg,
      ui=ui,
      menu_items=menu_items,
      model=model,
      humans_nums=humans_nums,
      controller=controller,
      to_reroll_menu_timeline=nil
   }
   ui.extra.view = object
   setmetatable(object, self)
   self.__index = self
   model:attach(object)
   return object
end

function MainMenuView:update()
   local comp = self.model.active_component
   if comp == Components.MAIN_MENU then
      screen:raise_child(self.ui)
      self.ui:animate{duration=200, y=self.ui.extra.orig_position[2]}
      self.fg.opacity=255
      if not self.ui:find_child("menu_bg") then
	 self.bg:unparent()
	 self.ui:add(self.bg)
	 self.ui:lower_child(self.bg)
      end
      self.ui.opacity=255
      for i,item in ipairs(self.menu_items) do
	 if self.controller.disabled_items[i] then
	    item.opacity=0
	 elseif i == self.controller.selected then
	    item.opacity=255
	 else
	    item.opacity=100
	 end
      end

      for i,num in ipairs(self.humans_nums) do
	 num.opacity=0
      end
      self.humans_nums[self.model.num_human_players].opacity = 255
   else
      self.ui.opacity=0
   end
end

function MainMenuView:initialize()
   self.controller = MainMenuController:new(self)
end

function MainMenuView:animate_to_reroll_menu(callback)
   local main_ui = self.ui
   local reroll_ui = screen:find_child("reroll_menu_ui") or error("Couldn't find main menu ui", 1)
   local main_fg = self.fg
   local main_bg = self.bg

   screen:raise_child(main_ui)
   main_ui.extra.reroll_ui = reroll_ui
   reroll_ui.extra.main_ui = main_ui
   reroll_ui.extra.bg = main_bg
   reroll_ui.extra.main_fg = main_fg
   reroll_ui.extra.callback = callback
   reroll_ui.extra.model = self.model
   reroll_ui.extra.on_key_down = screen.on_key_down
   screen.on_key_down = function() end
   main_ui:animate{
      duration=300,
      mode="EASE_IN_QUAD",
      y=reroll_ui.y,
      on_completed=
	 function(ui)
	    ui:animate{
	       duration=100,
	       y=reroll_ui.y-50,
	       on_completed=
		  function(ui)
		     ui:animate{
			duration=100,
			y=reroll_ui.y,
			on_completed=
			   function(ui)
			      local reroll_ui = ui.extra.reroll_ui
			      screen:raise_child(reroll_ui)
			      reroll_ui:animate{
				 duration=100,
				 opacity=255,
				 on_completed=
				    function(ui)
				       local main_ui = ui.extra.main_ui
				       local main_bg = ui.extra.bg
				       local main_fg = ui.extra.main_fg
				       main_bg:unparent()
				       ui:add(main_bg)
				       ui:lower_child(main_bg)
				       ui.extra.callback()
				       main_ui.opacity=0
				       main_fg.opacity=255
				       ui.extra.model:notify()
				       screen.on_key_down = ui.extra.on_key_down
				    end
			      }
			   end
		     }
		  end
	    }
	 end
   }
   main_fg:animate{
      duration=300,
      opacity=0
   }
end

function MainMenuView:animate_to_game()
   local main_ui = self.ui
   local main_fg = self.fg
   local ingame_menu_ui = screen:find_child("ingame_menu_ui")
   ingame_menu_ui.y = 960
   main_ui.extra.bg = self.bg
   main_ui.extra.fg = main_fg
   main_ui.extra.ingame_menu_ui = ingame_menu_ui
   main_ui:animate{
      duration=200,
      y=ingame_menu_ui.y,
      mode="EASE_OUT_QUARTIC",
      on_completed=
	 function(ui)
	    local bg = ui.extra.bg
	    local fg = ui.extra.fg
	    local ingame_menu_ui = ui.extra.ingame_menu_ui
	    bg:unparent()
	    ingame_menu_ui:add(bg)
	    ingame_menu_ui:lower_child(bg)
	    ingame_menu_ui.opacity=255
	    main_ui.opacity=0
	    fg.opacity=255
	    main_ui.y=180
	    print(ui_elt_tostring(bg))
	    print(ui_elt_tostring(ingame_menu_ui))
	 end
   }

   main_fg:animate{
      duration=200,
      opacity=0
   }
   -- self.bg:unparent()
   -- game_menu_ui:add(self.bg)
   -- game_menu_ui:lower_child(self.bg)
   -- main_ui.opacity=0
   self.model.game:update()
   -- game_menu_ui=255
end