dofile("header.lua")
dofile("editor.lua")

-------------------------------------------------------------------------------
-- Build the UI
-------------------------------------------------------------------------------
local function build_ui( show_it )
    -------------------------------------------------------------------------------
    -- Position constants
    -------------------------------------------------------------------------------
    local BUTTON_TEXT_X_OFFSET      = 20
    local BUTTON_TEXT_Y_OFFSET      = 22
    local FIRST_BUTTON_X            = 13                    -- x coordinate of first button
    local FIRST_BUTTON_Y            = 9                     -- y coordinate of first button
    local BUTTON_X_OFFSET           = 7                     -- distance between left side of buttons
    local SEARCH_BUTTON_X_OFFSET    = 5
    local DROPDOWN_POINT_Y_OFFSET   = -2                    -- how far to raise or lower the drop downs
    local DROPDOWN_WIDTH_OFFSET     = -8                   -- The width of the dropdown in relation to its button
    
    ----------------------------------------------------------------------------
    -- The group that holds the bar background and the buttons
    ----------------------------------------------------------------------------
    
    ui.bar:set
    {
        size = ui.bar_background.size,
        
        position = { 0 , 0 },
        
        children =
        {
            ui.bar_background:set
            {
                position = { 0 , 0 },
		size = {ui.bar_background.w, ui.bar_background.h - 15}
            },
            
            ui.button_focus:set
            {
                position = { FIRST_BUTTON_X , FIRST_BUTTON_Y },        
            }
        }
    }

    screen:add( ui.bar )    
    
    ----------------------------------------------------------------------------
    
    local i = 0
    local left = FIRST_BUTTON_X
    
    for _ , section in ipairs( ui.sections ) do
    
        section.ui = ui
        section.button.h = section.button.h - 15

        -- Create the dropdown background
        section.dropdown_bg = ui.factory.make_dropdown( { section.button.w + DROPDOWN_WIDTH_OFFSET , section.height } , section.color )
    
        -- Position the button and text for this section
        section.button.position =
        {
            left,
            FIRST_BUTTON_Y
        }
        
        left = left + BUTTON_X_OFFSET + section.button.w 
    
        section.text.position =
        {
            section.button.x + BUTTON_TEXT_X_OFFSET ,
            section.button.y + BUTTON_TEXT_Y_OFFSET - 5 
        }
        
        -- Create the dropdown group
        
        section.dropdown = Group
        {
            size = section.dropdown_bg.size,
            anchor_point = { section.dropdown_bg.w / 2 , 0 },
            position = 
            {
                section.button.x + section.button.w / 2,
                ui.bar.h + DROPDOWN_POINT_Y_OFFSET
            },
            children =
            {
                section.dropdown_bg
            }
        }
        
        -- Add the text and button
        
        ui.bar:add( section.button , section.text )
        
        -- Make sure its Z is correct with respect to the focus image
        
        section.button:lower( ui.button_focus )
        section.text:raise( ui.button_focus )
        
        -- Add the section dropdown to the screen
        
        screen:add( section.dropdown )
        i = i + 1

    end

    -------------------------------------------------------------------------------
    -- Add the help button and the logo
    -------------------------------------------------------------------------------
    
    ui.help_button.position = { left + SEARCH_BUTTON_X_OFFSET , FIRST_BUTTON_Y }
    ui.help_button.size = { ui.help_button.w -15 , ui.help_button.h - 15 }
    ui.bar:add( ui.help_button )
    ui.logo.position = { screen.w - ( ui.logo.w + FIRST_BUTTON_X ) , FIRST_BUTTON_Y }
    ui.bar:add( ui.logo )

    -------------------------------------------------------------------------------
    -- UI state information
    -------------------------------------------------------------------------------
    
    local DROPDOWN_TIMEOUT = 200    -- How many milliseconds one has to stay
                                    -- on a button for the dropdown to show up
                        
    ui.strings = strings            -- Store the string table
    ui.focus = SECTION_FILE         -- The section # that has focus
    --ui.dropdown_timer = Timer( DROPDOWN_TIMEOUT / 1000 )
    ui.dropdown_timer = Timer( DROPDOWN_TIMEOUT )
    ui.color_keys =             -- Which section # to focus with the given key
    {
        [ keys.RED    ] = SECTION_FILE,
        [ keys.GREEN  ] = SECTION_EDIT,
        [ keys.YELLOW ] = SECTION_ARRANGE,
        [ keys.BLUE   ] = SECTION_SETTING
    }

    -------------------------------------------------------------------------------
    -- Internal functions
    -------------------------------------------------------------------------------

    local function reset_dropdown_timer()
    
        if ui.dropdown_timer then
            ui.dropdown_timer:stop()
            ui.dropdown_timer:start()
        end
    
    end

    function animate_out_dropdown( callback )

        local ANIMATION_DURATION = 200
        local section = ui.sections[ ui.focus ]
        
        if not section.dropdown then
            if callback then
                callback( section )
            end
            return
        end
        
        section.dropdown:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 0,
            y_rotation = -90,
            on_completed =
                function()
                    section.dropdown:hide()
                    if callback then
                        callback( section )
                    end
                end
        }
    end

    local menu_init 	= true

    local function animate_in_dropdown( )

        local ANIMATION_DURATION = 150
        local section = ui.sections[ ui.focus ]
        
        if section.dropdown.is_visible then return end
        
        -- If the section has not been initialized, do it now
        
        if section.init then
            section:init( )
            section.init = nil
        end
        
        -- Call its on_show method
        
        -- pcall( section.on_show , section )
	if section.on_show then
            section:on_show()
        end

        section.dropdown.opacity = 0
        section.dropdown:show()
        section.dropdown.y_rotation = { 90 , 0 , 0 }
        section.dropdown:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 255,
            y_rotation = 0
        }
   	section.dropdown:raise_to_top() 
    end
    
    local function move_focus( new_focus )

        -- Bad focus. Your focus needs more focus.
        if not new_focus then return end
        -- Same focus. Laser focus.
        if new_focus == ui.focus then reset_dropdown_timer() return end
        local section = ui.sections[ new_focus ]
        -- Focus out of range. Blurred.
        if not section then return end -- The new section is out of range
        animate_out_dropdown()
        ui.focus = new_focus
        ui.button_focus.position = section.button.position
        reset_dropdown_timer()    
    end

    -------------------------------------------------------------------------------
    
    local function enter_section()

        local section = ui.sections[ ui.fs_focus or ui.focus ]
        
        if not section then return end

        if section.init then
            section:init()
            section.init = nil
        end
                
        if section:on_enter() then
            ui.button_focus.opacity = 0
        end
    
    end

    -------------------------------------------------------------------------------
    -- Invoke the default action for the current section    
    -------------------------------------------------------------------------------
    
    local function do_default_for_section()
    
        if ui.fs_focus and ( ui.focus == ui.fs_focus ) then
            
            -- If they hit enter on the section that is currently full screen,
            -- we just act like they hit 'down' and enter the section
            
            --enter_section()
        
        else
        
            -- Otherwise, we are going to ask the currently focused section
            -- to take itself into full screen mode
            
            local section = ui.sections[ ui.focus ]
            
            if not section then
                return
            end
            
            if section.init then
                section:init()
                section.init = nil
            end
            
            if not section.on_default_action then
                return
            end
            
            if section:on_default_action() then
                
                --ui.button_focus.opacity = 0
                --ui.fs_focus = ui.focus
            end
        
        end
    
    end

    -------------------------------------------------------------------------------
    -- Handlers
    -------------------------------------------------------------------------------

    local key_map =
    {
	[ keys.h	] = function() animate_out_dropdown() editor.undo_history() mouse_mode = S_SELECT end,
	[ keys.w	] = function() animate_out_dropdown() editor.the_open() mouse_mode = S_SELECT end,
	[ keys.r	] = function() animate_out_dropdown() mouse_mode = S_RECTANGLE end,
        [ keys.v	] = function() animate_out_dropdown() editor.view_code() mouse_mode = S_SELECT end,
        [ keys.n	] = function() animate_out_dropdown() editor.close() mouse_mode = S_SELECT end,
        [ keys.o	] = function() animate_out_dropdown() editor.open() mouse_mode = S_SELECT end,
        [ keys.s	] = function() animate_out_dropdown() editor.save(true) mouse_mode = S_SELECT end,
        [ keys.a	] = function() animate_out_dropdown() editor.save(false) mouse_mode = S_SELECT end,
        [ keys.t	] = function() animate_out_dropdown() editor.text() mouse_mode = S_SELECT end,
        [ keys.i	] = function() animate_out_dropdown() editor.image() mouse_mode = S_SELECT end,
        [ keys.u	] = function() animate_out_dropdown() editor.undo() mouse_mode = S_SELECT end,
        [ keys.e	] = function() animate_out_dropdown() editor.redo() mouse_mode = S_SELECT end,
        [ keys.x	] = function() animate_out_dropdown() editor.debug() mouse_mode = S_SELECT end,
        [ keys.c	] = function() animate_out_dropdown() editor.clone() mouse_mode = S_SELECT end,
        [ keys.BackSpace] = function() animate_out_dropdown() editor.delete() mouse_mode = S_SELECT end,
        [ keys.g	] = function() animate_out_dropdown() editor.group() mouse_mode = S_SELECT end,
        [ keys.p	] = function() animate_out_dropdown() end,
        [ keys.m	] = function() animate_out_dropdown() if (menu_hide == true) then 
								   menu_hide = false 
        							   ui.bar:show()
								   ui.button_focus:show()
        							   ui:animate_in() 
   								   ui.bar:raise_to_top()  --kkk
							      else 
								   menu_hide = true 
							      end end,
        [ keys.q	] = function() exit() end,
        [ keys.Left     ] = function() if(current_inspector == nil) then move_focus( ui.focus - 1 ) end end,
        [ keys.Right    ] = function() if(current_inspector == nil) then move_focus( ui.focus + 1 ) end end ,
        
        [ keys.RED      ] = function() move_focus( ui.color_keys[ keys.RED ] ) end,
        [ keys.GREEN    ] = function() move_focus( ui.color_keys[ keys.GREEN ] ) end,
        [ keys.YELLOW   ] = function() move_focus( ui.color_keys[ keys.YELLOW ] ) end,
        [ keys.BLUE     ] = function() move_focus( ui.color_keys[ keys.BLUE ] ) end,
        
        [ keys.F5       ] = function() move_focus( ui.color_keys[ keys.RED ] ) end,
        [ keys.F6       ] = function() move_focus( ui.color_keys[ keys.GREEN ] ) end,
        [ keys.F7       ] = function() move_focus( ui.color_keys[ keys.YELLOW ] ) end,
        [ keys.F8       ] = function() move_focus( ui.color_keys[ keys.BLUE ] ) end,
        
	[ keys.Shift_L  ] = function() shift = true end,
	[ keys.Shift_R  ] = function() shift = true end,
	[ keys.Control_L  ] = function() control = true end,
	[ keys.Control_R  ] = function() control = true end,
        [ keys.Return   ] = function() if(current_inspector == nil) then 
			    	     if(menu_init == true) then 
			                menu_init = false
			    		local s= ui.sections[ui.focus]
        		    		ui.button_focus.position = s.button.position
        		    		ui.button_focus.opacity = 0
			    		animate_out_dropdown() 
				     else 
			                menu_init = true
			    		local s= ui.sections[ui.focus]
        		    		ui.button_focus.position = s.button.position
        		    		ui.button_focus.opacity = 255
	 		   		-- do_default_for_section() 
			    		animate_in_dropdown() 
			    	     end 
			         end 
			    end ,
        [ keys.Down     ] = function() if(current_inspector == nil) then enter_section() end end
       -- [ keys.Up       ] = function() if(current_inspector == nil) then animate_out_dropdown() end end
    }
    
    -------------------------------------------------------------------------------
    -- Mouse Button Handlers
    -------------------------------------------------------------------------------

    local button_map =
    {

        ["  FILE "]   = function() move_focus(SECTION_FILE) end,
        ["  EDIT  "]  = function() move_focus(SECTION_EDIT) end,
        ["  ARRANGE"] = function() move_focus(SECTION_ARRANGE) end, 
        ["  SETTING"]    = function() move_focus(SECTION_SETTING ) end
    }

    local menu_button_second_down = false

    function ui:menu_button_down() 
        for _,section in ipairs( ui.sections ) do
	     section.button.reactive = true
             section.button.name = section.text.text
             function section.button:on_button_down(x,y,button,num_clicks)
		  if(mouse_mode == S_SELECT) and
		    (screen:find_child("msgw") == nil) then
	               button_map[section.button.name]()
		       menu_init = true
		       local s= ui.sections[ui.focus]
        	       ui.button_focus.position = s.button.position
        	       ui.button_focus.opacity = 255
		  end 
                  return true
	     end
	 end
    end

    function ui.bar.on_key_down( _ , key )
     
	if(key == keys.Shift_L) then shift = true end
	if(key == keys.Shift_R ) then shift = true end
	if(key == keys.Control_L ) then control = true end
	if(key == keys.Control_R ) then control = true end

	if(mouse_mode == S_SELECT) then 
             local f = key_map[ key ]
             if f then
            	f()
	    	if(current_inspector == nil and (key == keys.Return or key == keys.Down 
		   or key == keys.Left or key == keys.Right)) then 
	             local s= ui.sections[ui.focus]
        	     ui.button_focus.position = s.button.position
        	     ui.button_focus.opacity = 255 
	        else 
		   local s= ui.sections[ui.focus]
        	   ui.button_focus.position = s.button.position
        	   ui.button_focus.opacity = 0
	        end 
             end    
	end
	return true
    end
    
    function ui.dropdown_timer.on_timer( )
    
        animate_in_dropdown()
        
        return false
    
    end
    
    -------------------------------------------------------------------------------

     function screen.on_key_down( screen , key )

	if(key == keys.Shift_L) then shift = true end
	if(key == keys.Shift_R ) then shift = true end
	if(key == keys.Control_L ) then control = true end
	if(key == keys.Control_R ) then control = true end

	if(mouse_mode == S_SELECT) then 
          if key_map[key] then
              key_map[key](self)
	      if(current_inspector == nil)and (key == keys.Return or key == keys.Down 
		   or key == keys.Left or key == keys.Right) then 
	           local s= ui.sections[ui.focus]
        	   ui.button_focus.position = s.button.position
        	   ui.button_focus.opacity = 255 
	      else 
		   local s= ui.sections[ui.focus]
        	   ui.button_focus.position = s.button.position
        	   ui.button_focus.opacity = 0
	      end 

     	  end
     	end
     end
     function screen.on_key_up( screen , key )
    	if key == keys.Shift_L or key == keys.Shift_R then
             shift = false
	end 
    	if key == keys.Control_L or key == keys.Control_R then
             control = false
	end 
     end

     function screen:on_button_down(x,y,button,num_clicks)

          mouse_state = BUTTON_DOWN
          if(mouse_mode == S_RECTANGLE) then editor.rectangle(x, y) end
          if(mouse_mode == S_SELECT) and 
		    (screen:find_child("msgw") == nil) then
	       if(current_inspector == nil) then 
		    if(button == 3 or num_clicks >= 2) and (g.extra.video ~= nil) then
                         editor.inspector(g.extra.video)
                    end 
		    if(menu_init == true) then 
			 menu_init = false
			 local s= ui.sections[ui.focus]
        		 ui.button_focus.position = s.button.position
        		 ui.button_focus.opacity = 0
			 animate_out_dropdown() 
		    end 
		    if(shift == true) then 
			editor.multi_select(x,y)
		    end 
	       end 
	  end
     end

     function screen:on_button_up(x,y,button,clicks_count)
	  dragging = nil
          if (mouse_state == BUTTON_DOWN) then
              if (mouse_mode == S_RECTANGLE) then editor.rectangle_done(x, y) mouse_mode = S_SELECT end
	      if(mouse_mode == S_SELECT) and 
		    (screen:find_child("msgw") == nil) then
			editor.multi_select_done(x,y)
	      end 

              mouse_state = BUTTON_UP
          end
      end

      function screen:on_motion(x,y)
	  if (menu_hide == true ) then
    	  if( y > ui.bar_background.h) then 
        	     animate_out_dropdown()
		     ui:hide()
    	  else 
		ui.button_focus:show()
        	ui.bar:show()
        	ui:animate_in()
   	        ui.bar:raise_to_top()  --kkk
    	  end 
	  end
          if dragging then
               local actor , dx , dy = unpack( dragging )
	
	       local border = screen:find_child(actor.name.."border")
	       if(border ~= nil) then 
		    if (actor.extra.is_in_group == true) then
			 local group_pos = get_group_position(actor)
	                 border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
		    else 
	                 border.position = {x -dx, y -dy}
		    end 
	       end 

	       actor.position = { x - dx , y - dy  }
          end
          if(mouse_state == BUTTON_DOWN) then
               if (mouse_mode == S_RECTANGLE) then editor.rectangle_move(x, y) end
               if (mouse_mode == S_SELECT) and 
		  (screen:find_child("msgw") == nil) then 
		    editor.multi_select_move(x, y) end
          end
      end

    -------------------------------------------------------------------------------
    -- Define ui functions
    -------------------------------------------------------------------------------
    
    function ui:get_client_rect( )
        return { x = 0 , y = ui.bar.h , w = screen.w , h = screen.h - ui.bar.h }
    end
    
    
    ----------------------------------------------------------------------------
    -- Utility to iterate over all sections
    
    function ui:foreach_section( f )
    
        if f then for _,section in ipairs( self.sections ) do f( section ) end end
    
    end
    
    ----------------------------------------------------------------------------
    -- Hides everything with no animation
    
    function ui:hide()
    
        self.button_focus:hide()
        self.bar:hide()
        self:foreach_section( function( section ) section.dropdown:hide() end )
            
    end
    
    ----------------------------------------------------------------------------
    -- Animates the bar into view
    
    function ui:animate_in( callback )
    
        -- Make sure everthing that needs to be hidden is hidden
        
        self:hide()
        self.bar:show()
        self.button_focus:show()
        
        -- Constants

        local INITIAL_BAR_ANGLE     = -120
        local ANIMATION_DURATION    = 250
        
        -- Set the initial values for the bar and the focus ring
        
        self.bar:set
        {
            x_rotation = { INITIAL_BAR_ANGLE , 0 , 0 },
            opacity = 0
        }
        
        self.button_focus.opacity = 0
        
        -- Completion function
            
        local function animation_completed()
        
            -- The bar gets key focus after we animate
            self.bar:grab_key_focus(self.bar)
            self.dropdown_timer:start()
            
            if callback then
                callback( self )
            end
            
        end
        
        -- Animate
        
        self.bar:animate
        {
            duration = ANIMATION_DURATION,
            x_rotation = 0,
            opacity = 255,
            on_completed = animation_completed
        }
        
        self.button_focus:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 255
        }
        
    end
    
    ----------------------------------------------------------------------------
    -- Called by a section when it wants to lose focus
    -- (When you press UP at the top selection of a dropdown)
    ----------------------------------------------------------------------------    
    
    function ui:on_exit_section()
    
        self.bar:grab_key_focus(self.bar)
        self.button_focus.opacity = 255
    
    end

    ----------------------------------------------------------------------------
    -- Called by a section when it goes full screen. This spells the end of
    -- dropdowns.
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- Hide everything unless show_it is true (only for debugging)
    
    if not show_it then
    
        ui:hide()
    
    end

    ----------------------------------------------------------------------------
    
    return ui
    
end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

function main()

    screen:add(BG_IMAGE)
    screen:show()
    screen.reactive=true
    ui = build_ui(true)
    ui:animate_in()
    ui:menu_button_down() 
    
end

main()
