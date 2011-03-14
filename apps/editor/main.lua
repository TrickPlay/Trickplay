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
		size  = {ui.button_focus.w, ui.button_focus.h - 15}
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

    local meun_init = true

    local function grayed_out_dd_item()
        local section = ui.sections[ ui.focus ]

	local function turn_off(item)
		item.reactive = false 
		for i, j in pairs(item.children) do 
		     if (j.reactive) then 
			j.reactive = false
		     end 
		end 
		item:find_child("caption").color = {100,100,100,255} 
	end 

	local function turn_on(item, option)
		item.reactive = true	
		for i, j in pairs(item.children) do 
		     if (j.reactive) then 
			j.reactive = true
		     end 
		end 
		if option then 
		    if option == "Hide" then 
			if item.name == "guideline" then 
			    item:find_child("caption").text = option.." Lines"
			else 
			    item:find_child("caption").text = option.." Timeline\t\t".."[J]"
			end 
		    else 
			if item.name == "guideline" then 
			    item:find_child("caption").text = option.." Lines"
			else 
			    item:find_child("caption").text = option.." Timeline".."\t".."[J]"
			end
		    end
		end 
		item:find_child("caption").color = {255,255,255,255} 
	end 

	if (ui.focus == SECTION_EDIT) then 
	     if table.getn(undo_list) == 0 then
		turn_off(section.dropdown:find_child("undo")) 
	     else 
		turn_on(section.dropdown:find_child("undo")) 
	     end

	     if table.getn(redo_list) == 0 then
		turn_off(section.dropdown:find_child("redo")) 
	     else 
		turn_on(section.dropdown:find_child("redo")) 
	     end

	     if table.getn(selected_objs) == 0 then 
		turn_off(section.dropdown:find_child("clone")) 
		turn_off(section.dropdown:find_child("delete")) 
		turn_off(section.dropdown:find_child("group")) 
		turn_off(section.dropdown:find_child("ungroup")) 
	     else 
		turn_on(section.dropdown:find_child("clone")) 
		turn_on(section.dropdown:find_child("delete")) 
		turn_on(section.dropdown:find_child("group")) 
		turn_on(section.dropdown:find_child("ungroup")) 
	     end 	

	     if table.getn(g.children) > 0 then 
		if screen:find_child("timeline") then 
		      if screen:find_child("timeline").extra.show ~= true  then 
		           turn_on(section.dropdown:find_child("tline"), "Show") 
		      else 
		     	   turn_on(section.dropdown:find_child("tline"), "Hide") 
		      end 
		else 
		     turn_on(section.dropdown:find_child("tline")) 
		end 
	     else 
		if screen:find_child("timeline") then 
		     screen:remove(screen:find_child("timeline"))
		end 
		if screen:find_child("tline") then 
		     screen:find_child("tline"):find_child("caption").text = "Timeline".."\t\t\t".."[J]"
		end 
		turn_off(section.dropdown:find_child("tline")) 
	     end 
	elseif (ui.focus == SECTION_ARRANGE) then 
	     if table.getn(selected_objs) == 0 then 
		turn_off(section.dropdown:find_child("left"))
		turn_off(section.dropdown:find_child("right"))
		turn_off(section.dropdown:find_child("top"))
		turn_off(section.dropdown:find_child("bottom"))
		turn_off(section.dropdown:find_child("hcenter"))
		turn_off(section.dropdown:find_child("vcenter"))
		turn_off(section.dropdown:find_child("hspace"))
		turn_off(section.dropdown:find_child("vspace"))
		turn_off(section.dropdown:find_child("bring_front"))
		turn_off(section.dropdown:find_child("bring_forward"))
		turn_off(section.dropdown:find_child("send_back"))
		turn_off(section.dropdown:find_child("send_backward"))
	     elseif table.getn(selected_objs) == 1 then 
		turn_off(section.dropdown:find_child("left"))
		turn_off(section.dropdown:find_child("right"))
		turn_off(section.dropdown:find_child("top"))
		turn_off(section.dropdown:find_child("bottom"))
		turn_off(section.dropdown:find_child("hcenter"))
		turn_off(section.dropdown:find_child("vcenter"))
		turn_off(section.dropdown:find_child("hspace"))
		turn_off(section.dropdown:find_child("vspace"))
		turn_on(section.dropdown:find_child("bring_front"))
		turn_on(section.dropdown:find_child("bring_forward"))
		turn_on(section.dropdown:find_child("send_back"))
		turn_on(section.dropdown:find_child("send_backward"))
             elseif table.getn(selected_objs) == 2 then 
		turn_on(section.dropdown:find_child("left"))
		turn_on(section.dropdown:find_child("right"))
		turn_on(section.dropdown:find_child("top"))
		turn_on(section.dropdown:find_child("bottom"))
		turn_on(section.dropdown:find_child("hcenter"))
		turn_on(section.dropdown:find_child("vcenter"))
		turn_on(section.dropdown:find_child("bring_front"))
		turn_on(section.dropdown:find_child("bring_forward"))
		turn_on(section.dropdown:find_child("send_back"))
		turn_on(section.dropdown:find_child("send_backward"))
		turn_off(section.dropdown:find_child("hspace"))
		turn_off(section.dropdown:find_child("vspace"))
             else 
		turn_on(section.dropdown:find_child("left"))
		turn_on(section.dropdown:find_child("right"))
		turn_on(section.dropdown:find_child("top"))
		turn_on(section.dropdown:find_child("bottom"))
		turn_on(section.dropdown:find_child("hcenter"))
		turn_on(section.dropdown:find_child("vcenter"))
		turn_on(section.dropdown:find_child("hspace"))
		turn_on(section.dropdown:find_child("vspace"))
		turn_on(section.dropdown:find_child("bring_front"))
		turn_on(section.dropdown:find_child("bring_forward"))
		turn_on(section.dropdown:find_child("send_back"))
		turn_on(section.dropdown:find_child("send_backward"))
	     end 
        elseif (ui.focus == SECTION_SETTING) then 
             if screen:find_child("h_guideline"..tostring(h_guideline)) or 
		screen:find_child("v_guideline"..tostring(v_guideline)) then 
		if section.dropdown:find_child("guideline").extra.show ~= true then 
		    turn_on(section.dropdown:find_child("guideline"), "Show") 
		else 
		    turn_on(section.dropdown:find_child("guideline"), "Hide")
		end 
	     else 
		turn_off(section.dropdown:find_child("guideline"))
		section.dropdown:find_child("guideline").extra.show = true
	     end 
	end 
    end 

    local function animate_in_dropdown( )

	input_mode = S_MENU 
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

        grayed_out_dd_item()

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
        [ keys.a	] = function() animate_out_dropdown() input_mode = S_SELECT editor.save(false) end,
	[ keys.b	] = function() animate_out_dropdown() editor.undo_history() input_mode = S_SELECT end,
        [ keys.c	] = function() animate_out_dropdown() editor.clone() input_mode = S_SELECT end,
        [ keys.e	] = function() animate_out_dropdown() editor.redo() input_mode = S_SELECT end,
        [ keys.g	] = function() animate_out_dropdown() editor.group() input_mode = S_SELECT end,
        [ keys.i	] = function() animate_out_dropdown() input_mode = S_SELECT  editor.the_image() end,
        [ keys.n	] = function() animate_out_dropdown() editor.close() input_mode = S_SELECT end,
        [ keys.o	] = function() animate_out_dropdown() input_mode = S_SELECT editor.the_open()  end,
        [ keys.q	] = function() exit() end,
	[ keys.r	] = function() animate_out_dropdown() input_mode = S_RECTANGLE screen:grab_key_focus() end,
        [ keys.s	] = function() animate_out_dropdown() input_mode = S_SELECT editor.save(true) end,
        [ keys.t	] = function() animate_out_dropdown() editor.text() input_mode = S_SELECT end,
        [ keys.u	] = function() animate_out_dropdown() editor.undo() input_mode = S_SELECT end,
        [ keys.v	] = function() animate_out_dropdown() editor.v_guideline() input_mode = S_SELECT end,
        [ keys.h	] = function() animate_out_dropdown() editor.h_guideline() input_mode = S_SELECT end,
        [ keys.j	] = function() animate_out_dropdown() if not screen:find_child("timeline") then 
							         if table.getn(g.children) > 0 then
								     input_mode = S_SELECT local tl = widget.timeline() screen:add(tl)
							             screen:find_child("timeline").extra.show = true 
							         end
						 	      elseif table.getn(g.children) == 0 then 
		      						    screen:remove(screen:find_child("timeline"))
		                                                    if screen:find_child("tline") then 
		                                                         screen:find_child("tline"):find_child("caption").text = "Timeline".."\t\t\t".."[J]"
		                                                    end 
							      elseif screen:find_child("timeline").extra.show ~= true  then 
								   screen:find_child("timeline"):show()
								   screen:find_child("timeline").extra.show = true
						 	      else 
								   screen:find_child("timeline"):hide()
								   screen:find_child("timeline").extra.show = false
							      end
							      end,
        --[ keys.x	] = function() animate_out_dropdown() editor.debug() input_mode = S_SELECT end,
        [ keys.x	] = function() animate_out_dropdown() editor.export() input_mode = S_SELECT end,
        [ keys.w	] = function() animate_out_dropdown() editor.ui_elements() input_mode = S_SELECT end,
        [ keys.m	] = function() if (menu_hide == true) then 
					    ui.button_focus:show()
        				    ui.bar:show()
        				    ui:animate_in()
   	        			    ui.bar:raise_to_top()  
					    if(screen:find_child("xscroll_bar") ~= nil) then 
					    	screen:find_child("xscroll_bar"):show() 
						screen:find_child("xscroll_box"):show() 
						screen:find_child("x_0_mark"):show()
						screen:find_child("x_1920_mark"):show()
					    end 
					    if(screen:find_child("scroll_bar") ~= nil) then 
		 				screen:find_child("scroll_bar"):show() 
						screen:find_child("scroll_box"):show() 
						screen:find_child("y_0_mark"):show()
						screen:find_child("y_1080_mark"):show()
					    end 
					    menu_hide = false 
				       else 
        	     			    animate_out_dropdown()
		     			    ui:hide()
					    if(screen:find_child("xscroll_bar") ~= nil) then 
					    	screen:find_child("xscroll_bar"):hide() 
						screen:find_child("xscroll_box"):hide() 
						screen:find_child("x_0_mark"):hide()
						screen:find_child("x_1920_mark"):hide()
					    end 
					    if(screen:find_child("scroll_bar") ~= nil) then 
		 				screen:find_child("scroll_bar"):hide() 
						screen:find_child("scroll_box"):hide() 
						screen:find_child("y_0_mark"):hide()
						screen:find_child("y_1080_mark"):hide()
					    end 
					    menu_hide = true 
					    screen:grab_key_focus()
				       end 
				       input_mode = S_SELECT end,
	--[ keys.w	] = function() animate_out_dropdown() editor.the_open() input_mode = S_SELECT end,
        [ keys.BackSpace] = function() animate_out_dropdown() editor.delete() input_mode = S_SELECT end,
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
				     for i, j in pairs (g.children) do 
					if(j.extra.selected == true) then 
						editor.n_selected(j) 
					end 
				     end 
			    	     local s= ui.sections[ui.focus]
        		    	     ui.button_focus.position = s.button.position
        		    	     ui.button_focus.opacity = 255
			    	     animate_in_dropdown() 
				     input_mode = S_MENU
			             end 
			    end ,
        [ keys.Left     ] = function() if table.getn(selected_objs) ~= 0 then
			         for q, w in pairs (selected_objs) do
				      local t_border = screen:find_child(w)
				      if(t_border ~= nil) then 
		     			    t_border.x = t_border.x - 1
		     		            local i, j = string.find(t_border.name,"border")
		     			    local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                            if(t_obj ~= nil) then 
			                         t_obj.x = t_obj.x - 1
					    end 
	       				    if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
		     				local anchor_mark = screen:find_child(t_obj.name.."a_m")
		     				anchor_mark.position = {t_obj.x, t_obj.y, t_obj.z}
               				    end
	             		      end
			         end
			   elseif(current_inspector == nil) then move_focus( ui.focus - 1 ) end end,
        [ keys.Right    ] = function() if table.getn(selected_objs) ~= 0 then
			         for q, w in pairs (selected_objs) do
				      local t_border = screen:find_child(w)
				      if(t_border ~= nil) then 
		     			    t_border.x = t_border.x + 1
		     		            local i, j = string.find(t_border.name,"border")
		     			    local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                            if(t_obj ~= nil) then 
			                         t_obj.x = t_obj.x + 1
					    end 
	       				    if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
		     				local anchor_mark = screen:find_child(t_obj.name.."a_m")
		     				anchor_mark.position = {t_obj.x, t_obj.y, t_obj.z}
               				    end
	             		      end
			         end
			   elseif(current_inspector == nil) then move_focus( ui.focus + 1 ) end end ,
        [ keys.Down     ] = function()if table.getn(selected_objs) ~= 0 then
			         for q, w in pairs (selected_objs) do
				      local t_border = screen:find_child(w)
				      if(t_border ~= nil) then 
		     			    t_border.y = t_border.y + 1
		     		            local i, j = string.find(t_border.name,"border")
		     			    local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                            if(t_obj ~= nil) then 
			                         t_obj.y = t_obj.y + 1
					    end 
	       				    if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
		     				local anchor_mark = screen:find_child(t_obj.name.."a_m")
		     				anchor_mark.position = {t_obj.x, t_obj.y, t_obj.z}
               				    end
	             		      end
			         end
			   elseif(current_inspector == nil) then enter_section() end end,
        [ keys.Up       ] = function() if table.getn(selected_objs) ~= 0 then
			         for q, w in pairs (selected_objs) do
				      local t_border = screen:find_child(w)
				      if(t_border ~= nil) then 
		     			    t_border.y = t_border.y - 1
		     		            local i, j = string.find(t_border.name,"border")
		     			    local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                            if(t_obj ~= nil) then 
			                         t_obj.y = t_obj.y - 1
					    end 
	       				    if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
		     				local anchor_mark = screen:find_child(t_obj.name.."a_m")
		     				anchor_mark.position = {t_obj.x, t_obj.y, t_obj.z}
               				    end
	             		      end
			         end
			   end end
    }
    
    -------------------------------------------------------------------------------
    -- Mouse Button Handlers
    -------------------------------------------------------------------------------

    local button_map =
    {

        ["  File "]   = function() move_focus(SECTION_FILE) end,
        ["  Edit  "]  = function() move_focus(SECTION_EDIT) end,
        ["  Arrange"] = function() move_focus(SECTION_ARRANGE) end, 
        ["  View"]    = function() move_focus(SECTION_SETTING ) end
    }

    local menu_button_second_down = false

    function ui:menu_button_down() 
        for _,section in ipairs( ui.sections ) do
	     section.button.reactive = true
             section.button.name = section.text.text
             function section.button:on_button_down(x,y,button,num_clicks)
	          if(screen:find_child("mouse_pointer") ~= nil) then 
             		screen:remove(mouse_pointer) 
        	  end 
		  if(input_mode ~= S_POPUP) and
		    (screen:find_child("msgw") == nil) then
	               button_map[section.button.name]()
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
	if(table.getn(selected_objs) == 0) and (input_mode ~= S_POPUP) then 
             local f = key_map[ key ]
             if f then
            	f()
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

	if(screen:find_child("mouse_pointer") ~= nil) then 
             screen:remove(mouse_pointer) 
        end 
	        
	if(input_mode ~= S_POPUP) then 
          if key_map[key] then
              key_map[key](self)
	      if(table.getn(selected_objs) == 0) then 
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
          if(input_mode == S_RECTANGLE) then editor.rectangle(x, y) end
          if(input_mode == S_MENU) then
		     local s= ui.sections[ui.focus]
        	     ui.button_focus.position = s.button.position
        	     ui.button_focus.opacity = 0
		     animate_out_dropdown() 
		     screen:grab_key_focus()
		     input_mode = S_SELECT
          elseif(input_mode == S_SELECT) and (screen:find_child("msgw") == nil) then
	       if(current_inspector == nil) then 
		   -- if(button == 3 or num_clicks >= 2) and (g.extra.video ~= nil) then
		    if(button == 3) and (g.extra.video ~= nil) then -- imsi : num_clicks is not correct in engine 17
			 print("Button Number -- ", button)
			 print("Number of click-- ", num_clicks)
                         editor.inspector(g.extra.video)
                    end 
		    		    if(shift == true) then 
			editor.multi_select(x,y)
		    end 
	       end 
	  end
     end

     function screen:on_button_up(x,y,button,clicks_count)
	   if dragging then
	       local actor = unpack(dragging)
	       if actor.parent then 	
		   if actor.parent.name == "timeline" then 
			local actor, dx , dy, pointer_up_f = unpack( dragging )
			pointer_up_f(x,y,button,clicks_count) 
			return true
		   end 
	       end 
          end 	
	  dragging = nil
          if (mouse_state == BUTTON_DOWN) then
              if (input_mode == S_RECTANGLE) then 
	           editor.rectangle_done(x, y) 
	           if(screen:find_child("mouse_pointer") ~= nil) then 
		        screen:remove(mouse_pointer) 
		   end 
	           input_mode = S_SELECT 
	      end

	      if(input_mode == S_SELECT) and 
		    (screen:find_child("msgw") == nil) then
			editor.multi_select_done(x,y)
	      end 

              mouse_state = BUTTON_UP
          end
      end

      function screen:on_motion(x,y)

	  if(input_mode == S_RECTANGLE) then 
		if(rect_mouse_pointer == nil) then 
		rect_mouse_pointer = ui.factory.draw_mouse_pointer()
	        end 
		rect_mouse_pointer.position = {x,y,0}
		if(screen:find_child("mouse_pointer") == nil) then 
		     screen:add(rect_mouse_pointer)
		end 
	  end 

          if dragging then

	       local actor = unpack(dragging) 

	       if (actor.name == "scroll_window") then  
	             local actor,s_on_motion = unpack(dragging) 
	             s_on_motion(x, y)
	             return true
	       end 
		
               local actor, dx , dy = unpack( dragging )

	       local tl = actor.parent          
	       if tl then 
	         if tl.name == "timeline" then 
			local timepoint, last_point, new_x	
			
			timepoint = tonumber(actor.name:sub(8, -1))
			for j,k in orderedPairs (screen:find_child("timeline").points) do
	     		   last_point = j
			end 
			new_x = x - dx 
			if timepoint == last_point then 
			     if new_x > 1860 then 
				 new_x = 1860
			     end 
			end
			screen:find_child("text"..tostring(timepoint)).x = new_x - 120 
			actor.x = new_x 
		        return true 
		 end 
	       end

	       if (guideline_type(actor.name) == "v_guideline") then 
	            actor.x = x - dx
	            return true
	       elseif (guideline_type(actor.name) == "h_guideline") then 
		    actor.y = y - dy
	            return true
	       end 

	       local border = screen:find_child(actor.name.."border")
	       if(border ~= nil) then 
		    if (actor.extra.is_in_group == true) then
			 local group_pos = get_group_position(actor)
	                 border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
		    else 
	                 border.position = {x -dx, y -dy}
		    end 
	       end 
	      
	       if(actor.name ~= "scroll_bar" and actor.name ~= "xscroll_bar") then
	            actor.x =  x - dx 
	            actor.y =  y - dy  
	       else
		    if(actor.extra.h_y) then 
	                local dif 
			if(actor.extra.h_y <= y-dy and y-dy <= actor.extra.l_y) then 
		             dif = y - dy - actor.extra.org_y
	                     actor.y =  y - dy  
			elseif (actor.extra.h_y > y-dy ) then
				dif = actor.extra.h_y - actor.extra.org_y 
	           		actor.y = actor.extra.h_y
	      		elseif (actor.extra.l_y < y-dy ) then
				dif = actor.extra.l_y- actor.extra.org_y 
	           		actor.y = actor.extra.l_y
			end 
		        if(actor.extra.text_position) then 
		              actor.extra.text_position = {actor.extra.text_position[1], actor.extra.txt_y -dif}
		              actor.extra.text_clip = {0, dif, actor.extra.text_clip[3], 500}
		        else 
			      dif = dif * g.extra.scroll_dy
			      for i,j in pairs (g.children) do 
	           	           j.position = {j.x, j.extra.org_y- dif - g.extra.canvas_f, j.z}
			      end 
			      
			      if table.getn(selected_objs) ~= 0 then
			      	for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.y = t_obj.y 
				 end
			     	end
			      end
			      g.extra.scroll_y = math.floor(dif) -- + 1
		       end 
		    end

		    if(actor.extra.h_x) then 
	                local dif 
	                if (actor.extra.h_x <= x-dx and x-dx <= actor.extra.l_x) then 
		             dif = x - dx - actor.extra.org_x
	                     actor.x =  x - dx  
			elseif(actor.extra.h_x > x-dx) then 
			     dif = actor.extra.h_x - actor.extra.org_x
			     actor.x = actor.extra.h_x
			elseif(actor.extra.l_x < x-dx) then 
			     dif = actor.extra.l_x - actor.extra.org_x
			     actor.x = actor.extra.l_x
		        end 

		        dif = dif * g.extra.scroll_dx
		        for i,j in pairs (g.children) do 
	           	     j.position = {j.extra.org_x- dif - g.extra.canvas_xf, j.y, j.z}
		        end 


			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.x = t_obj.x 
				      screen:remove(screen:find_child(t_obj.name.."a_m"))
				 end
			     end
			end

		        g.extra.scroll_x = math.floor(dif) -- + 1
	            end 
	       end

	       if (screen:find_child(actor.name.."a_m") ~= nil) then 
		     local anchor_mark = screen:find_child(actor.name.."a_m")
		     anchor_mark.position = {actor.x, actor.y, actor.z}
               end
          end

          if(mouse_state == BUTTON_DOWN) then
               if (input_mode == S_RECTANGLE) then editor.rectangle_move(x, y) end
               if (input_mode == S_SELECT) and 
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
            --self.bar:grab_key_focus(self.bar)  -- 1102
            --self.dropdown_timer:start() -- 1101   set_app_path()
            
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
            opacity = 0 --255 1101 set_app_path()
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

    if controllers.start_pointer then 
  	controllers:start_pointer()
    end
    
    screen:add(BG_IMAGE_20)
    screen:add(BG_IMAGE_40)
    screen:add(BG_IMAGE_80)
    screen:add(BG_IMAGE_white)
    screen:add(BG_IMAGE_import)
    screen:show()
    screen.reactive=true
    ui = build_ui(true)
    ui:animate_in()
    ui:menu_button_down() 
    set_app_path()
    
end
dolater(main)
--main()

