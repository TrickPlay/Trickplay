---------------------------------------------------------
--		Visual Editor Main.lua 
---------------------------------------------------------

---------------------
-- Constants 
---------------------

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
        [ keys.i	] = function() editor.the_ui_elements() input_mode = hdr.S_SELECT end,
        [ keys.j	] = function() editor.timeline_show() end,
        [ keys.m	] = function() editor.menu_hide() input_mode = hdr.S_SELECT end,
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
        [ keys.Return    ] = function() 
									 if(current_inspector == nil) then 
				     					for i, j in pairs (g.children) do 
											if(j.extra.selected == true) then 
												editor.n_selected(j) 
											end 
				     					end 
			             			 end 
			    			end ,
        [ keys.Left     ] = function() editor.move_selected_obj("Left") end,
        [ keys.Right    ] = function() editor.move_selected_obj("Right") end ,
        [ keys.Down     ] = function() editor.move_selected_obj("Down")end,
        [ keys.Up       ] = function() editor.move_selected_obj("Up")end
    }
    
    function screen.on_key_down( screen , key )

		if(key == keys.Shift_L) then shift = true end
		if(key == keys.Shift_R ) then shift = true end
		if(key == keys.Control_L ) then control = true end
		if(key == keys.Control_R ) then control = true end
	
		if(input_mode ~= hdr.S_POPUP) then 
          if key_map[key] then
              key_map[key](self)
     	  end
     	end

    end

    function screen.on_key_up( screen , key )

    	if key == keys.Shift_L or key == keys.Shift_R then shift = false end 
    	if key == keys.Control_L or key == keys.Control_R then control = false end 

    end

	function screen:on_button_down(x,y,button,num_clicks)

      	mouse_state = hdr.BUTTON_DOWN 		-- for drawing rectangle 

		if current_focus then 				-- for closing menu button or escaping from text editting 
			current_focus.on_focus_out()
			screen:grab_key_focus()
		end 

      	if(input_mode == hdr.S_RECTANGLE) then 
	       editor.rectangle( x, y) 
	  	end

      	if(input_mode == S_MENU) then
			
			screen:grab_key_focus()
			input_mode = hdr.S_SELECT

     	else -- if(input_mode == hdr.S_SELECT) and (screen:find_child("msgw") == nil) then
		   	 -- if(button == 3 or num_clicks >= 2) and (g.extra.video ~= nil) then
		    if(button == 3) and (g.extra.video ~= nil) and (current_inspector == nil) then
            	editor.inspector(g.extra.video)
            end 

		    if(shift == true) then 
				editor.multi_select(x,y)
		    end 

	  	end

     end

	function screen:on_button_up(x,y,button,clicks_count)

	--[[ 
		if current_focus ~= nil and  current_focus.extra.type == "EditorButton" then 
			local temp_focus = current_focus 
			current_focus.on_focus_out()
			temp_focus.on_focus_in()
			return true
		end 
 	  ]]

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

        if (mouse_state == hdr.BUTTON_DOWN) then
            if (input_mode == hdr.S_RECTANGLE) then 
	           editor.rectangle_done(x, y) 
	           input_mode = hdr.S_SELECT 
	    	end

	      	if(input_mode == hdr.S_SELECT) and (screen:find_child("msgw") == nil) then
				editor.multi_select_done(x,y)
	      	end 
       end

       mouse_state = hdr.BUTTON_UP

	end

    function screen:on_motion(x,y)

		local tab_extra

	  	if control == true then 
			if util.is_in_container_group(x,y) == true and selected_content then 
				if selected_content.extra.is_in_group ~= true then 
					local c, t = util.find_container(x,y) 
					selected_container = c
					if c.selected == false then
						editor.container_selected(c,x,y)	
						editor_lb:set_cursor(52)
						cursor_type = 68
					elseif c.extra.type == "LayoutManager" then 
				     	if screen:find_child(c.name.."border") then 
				     		local col , row=  c:r_c_from_abs_position(x,y)
				     		if screen:find_child(c.name.."border").r_c[1] ~= row or
		   						screen:find_child(c.name.."border").r_c[2] ~= col then  
		    					editor.n_selected(c)
				     		end 
				     	end
					end 
				end 
			elseif  selected_container then 
				editor.n_selected (selected_container)
				editor_lb:set_cursor(52)
				cursor_type = 52
				selected_container = nil
			end 
	  	end 

	  	if(input_mode == hdr.S_RECTANGLE) then 
			
			editor_lb:set_cursor(34)
			cursor_type = 34

	  	elseif shift == true then 
			
			editor_lb:set_cursor(68)
			cursor_type = 68

	  	else --if cursor_type == 34 then  

			editor_lb:set_cursor(68)
			cursor_type = 68

	  	end 

        if dragging then

	       local actor = unpack(dragging) 

		   if actor.name == nil then  -- 0727
				   return 
		   end 

	       if (actor.name == "grip" or actor.name == "focus_grip" ) then  
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
			for j,k in util.orderedPairs (screen:find_child("timeline").points) do
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
			
 	       if util.is_there_guideline() then 	
	       if (guideline_type(actor.name) == "v_guideline") then 
	            actor.x = x - dx
	            return true
	       elseif (guideline_type(actor.name) == "h_guideline") then 
		    actor.y = y - dy
	            return true
	       end 
		   end 

		   local bumo 
	       local border = screen:find_child(actor.name.."border")
	       if(border ~= nil) then 
		   if (actor.extra.is_in_group == true) then
				 for i, c in pairs(g.children) do
					if actor.name == c.name then 
						break
					else 
						if c.extra then 
							if c.extra.type == "ScrollPane" or c.extra.type == "ArrowPane" then 
								for k, e in pairs (c.content.children) do 
									if e.name == actor.name then 
										bumo = c	
									end 
								end 
							elseif c.extra.type == "TabBar" then 
								for h,q in pairs (c.tabs) do 
									for k,w in pairs (q.children) do 
										if w.name == actor.name then 
											tab_extra = c.ui_height
										end
									end
								end 
							end 
						end
					end
    			 end

				 if bumo then 
					local cur_x, cur_y = bumo:screen_pos_of_child(actor) 
	             	border.position = {cur_x, cur_y}
				 else 
				 	local group_pos = util.get_group_position(actor)
	             	border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
				 end 
		    else 
	             border.position = {x -dx, y -dy}
		    end 
	       end 
	     	if tab_extra then 
				border.y = border.y + tab_extra
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

		        g.extra.scroll_x = math.floor(dif) 
	            end 
	       end

	       if (screen:find_child(actor.name.."a_m") ~= nil) then 
		     local anchor_mark = screen:find_child(actor.name.."a_m")
		     anchor_mark.position = {actor.x, actor.y, actor.z}

		     if (actor.extra.is_in_group == true) then
				if bumo then 
					local cur_x, cur_y = bumo:screen_pos_of_child(actor) 
	                anchor_mark.position = {cur_x, cur_y}
				else 
			 		local group_pos = util.get_group_position(actor)
	                anchor_mark.position = {actor.x + group_pos[1], actor.y + group_pos[2]}
				end 
		     end 

               end
          end

		  if tab_extra then 
			anchor_mark.y = anchor_mark.y + tab_extra
		  end 

          if(mouse_state == hdr.BUTTON_DOWN) then
               if (input_mode == hdr.S_RECTANGLE) then 
					editor.rectangle_move(x, y) 
			   end
               if (input_mode == hdr.S_SELECT) and (screen:find_child("msgw") == nil) then 
		    		editor.multi_select_move(x, y) 
			   end
          end
      end

      local function screen_add_bg()
    	screen:add(BG_IMAGE_20)
    	screen:add(BG_IMAGE_40)
    	screen:add(BG_IMAGE_80)
    	screen:add(BG_IMAGE_white)
    	screen:add(BG_IMAGE_import)
      end 


    
-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

    function main()

		local auto_save_duration = 60000  
		local auto_save = true

    	if controllers.start_pointer then 
  			controllers:start_pointer()
    	end
    
    	if editor_lb.disable_exit then
			editor_lb:disable_exit()
    	end

    	screen_add_bg()
    	screen.reactive=true
		menu.menu_raise_to_top()
		project_mng.open_project(nil,nil,"main")

		-----------------
		-- Auto Save 
		-----------------

		local backup_timeline = Timeline {
		 	  duration = auto_save_duration,
	       	  direction = "FORWARD",
	       	  loop = true
	    }

	    function backup_timeline.on_completed()
			if auto_save == true and current_fn ~= "" and current_fn ~= "unsaved_temp.lua" and current_fn ~= "/screens/unsaved_temp.lua" then 
				editor.save(nil, true) 
				print(current_fn.." is auto_saved")
			end 
			t = nil
	    end
	    backup_timeline:start()


    end

    screen:show()
    dolater(main)
