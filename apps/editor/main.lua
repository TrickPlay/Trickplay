---------------------------------------------------------
--		Visual Editor Main.lua 
---------------------------------------------------------

-- Constants, Global Variables  
	hdr = dofile("header")

-------------------------------------------------------------------------------
-- Build the MENU 
-------------------------------------------------------------------------------
   
    ----------------------------------------------------------------------------
    -- Key Map
    ----------------------------------------------------------------------------
    
    local key_map =
    {
        [ keys.a	] = function() editor.save(false) input_mode = hdr.S_SELECT end,
		[ keys.b	] = function() editor.undo_history() input_mode = hdr.S_SELECT end,
        [ keys.c	] = function() editor.clone() input_mode = hdr.S_SELECT end,
        [ keys.d	] = function() editor.duplicate() input_mode = hdr.S_SELECT end,
        [ keys.e	] = function() editor.redo() input_mode = hdr.S_SELECT end,
        [ keys.f	] = function() project_mng.new_project() input_mode = hdr.S_SELECT end,
        [ keys.g	] = function() editor.group() input_mode = hdr.S_SELECT end,
        [ keys.h	] = function() editor.h_guideline() input_mode = hdr.S_SELECT end,
        [ keys.i	] = function() editor.ui_elements() input_mode = hdr.S_SELECT end,
        [ keys.j	] = function() screen_ui.timeline_show() input_mode = hdr.S_SELECT end,
        [ keys.m	] = function() screen_ui.menu_hide() input_mode = hdr.S_SELECT end,
        [ keys.n	] = function() editor.close(true) input_mode = hdr.S_SELECT end,
        [ keys.o	] = function() editor.open() input_mode = hdr.S_SELECT   end,
        [ keys.p	] = function() project_mng.open_project() end,
        [ keys.q	] = function() if editor.close(nil,exit) == nil then exit() end end,
		[ keys.r	] = function() input_mode = hdr.S_RECTANGLE screen:grab_key_focus() end,
        [ keys.s	] = function() editor.save(true) input_mode = hdr.S_SELECT end,
        [ keys.t	] = function() editor.text() input_mode = hdr.S_SELECT end,
        [ keys.u	] = function() editor.ugroup() input_mode = hdr.S_SELECT end,
        [ keys.z	] = function() editor.undo() input_mode = hdr.S_SELECT end,
        [ keys.v	] = function() editor.v_guideline() input_mode = hdr.S_SELECT end,
        [ keys.w	] = function() editor.image() input_mode = hdr.S_SELECT end,
        [ keys.x	] = function() editor.debug() input_mode = hdr.S_SELECT end,
        [ keys.BackSpace ] = function() editor.delete() input_mode = hdr.S_SELECT end,
        [ keys.Delete    ] = function() editor.delete() input_mode = hdr.S_SELECT end,
		[ keys.Shift_L   ] = function() shift = true end,
		[ keys.Shift_R   ] = function() shift = true end,
		[ keys.Control_L ] = function() control = true end,
		[ keys.Control_R ] = function() control = true end,
        [ keys.Return    ] = function() screen_ui.nselect_all() input_mode = hdr.S_SELECT end ,
        [ keys.Left     ] = function() screen_ui.move_selected_obj("Left") input_mode = hdr.S_SELECT end,
        [ keys.Right    ] = function() screen_ui.move_selected_obj("Right") input_mode = hdr.S_SELECT end ,
        [ keys.Down     ] = function() screen_ui.move_selected_obj("Down") input_mode = hdr.S_SELECT end,
        [ keys.Up       ] = function() screen_ui.move_selected_obj("Up") input_mode = hdr.S_SELECT end,
    }
    
    function screen:on_key_down( key )

		if(input_mode ~= hdr.S_POPUP) then 
          if key_map[key] then
              key_map[key](self)
     	  end
     	end

    end

    function screen:on_key_up( key )

    	if key == keys.Shift_L or key == keys.Shift_R then shift = false end 
    	if key == keys.Control_L or key == keys.Control_R then control = false end 

    end

	function screen:on_button_down(x,y,button,num_clicks,m)

      	mouse_state = hdr.BUTTON_DOWN 		-- for drawing rectangle 

		if current_focus then 				-- for closing menu button or escaping from text editting 
			current_focus.on_focus_out()
			screen:grab_key_focus()
		end 

      	if(input_mode == hdr.S_RECTANGLE) then 
	       editor.rectangle( x, y) 
	  	end

		-- if(button == 3 or num_clicks >= 2) and (g.extra.video ~= nil) and current_inspector == nil then
		if button == 3 and g.extra.video ~= nil and current_inspector == nil then
        	editor.inspector(g.extra.video)
        end 

		if(m.shift == true) then 
			screen_ui.multi_select(x,y)
		end 

    end

	function screen:on_button_up(x,y,button,clicks_count, m)

		-- for dragging timepoint 
		screen_ui.dragging_up(x,y)

	  	dragging = nil

        if (mouse_state == hdr.BUTTON_DOWN) then
            if input_mode == hdr.S_RECTANGLE then 
	           editor.rectangle_done(x, y) 
	           input_mode = hdr.S_SELECT 
	      	elseif input_mode == hdr.S_SELECT and m and m.shift then
				screen_ui.multi_select_done(x,y)
	      	end 
       	end

       	mouse_state = hdr.BUTTON_UP

	end

    function screen:on_motion(x,y)

	  	if control == true then 
			screen_ui.draw_selected_container_border(x,y) 
		end 
	 
	 	screen_ui.cursor_setting()

	 	screen_ui.dragging(x,y)

        if(mouse_state == hdr.BUTTON_DOWN) then
            if (input_mode == hdr.S_RECTANGLE) then 
				editor.rectangle_move(x, y) 
			end
            if (input_mode == hdr.S_SELECT)  then 
		    	screen_ui.multi_select_move(x, y) 
			end
        end
	end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

    function main()

		-- to activate mouse handlers 
		
    	if controllers.start_pointer then 
  			controllers:start_pointer()
    	end

		screen.reactive=true
    
    	if editor_lb.disable_exit then
			editor_lb:disable_exit()
    	end

    	screen_ui.add_bg()

		menu.menu_raise_to_top()

		-- open project 
		project_mng.open_project(nil,nil,"main")

		-- auto save 
		screen_ui.auto_save()
		
    end

    screen:show()
    dolater(main)
