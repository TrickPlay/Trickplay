---------------------------------------------------------
--		Visual Editor Main.lua 
---------------------------------------------------------

-- constants 

hdr = dofile("header")

hdr.test = 100
-- Global 
---------------------
editor_lb = editor
editor_use = false

-- Table g contains all the ui elements in the screen 
g = Group{name = "screen_objects", extra={canvas_xf = 0, canvas_f = 0, canvas_xt = 0, canvas_t = 0, canvas_w = screen.w, canvas_h = screen.h, scroll_x = 0, scroll_y = 0, scroll_dy = 1}}

-- localized string table
strings = dofile( "localized:strings.lua" ) or {}

function missing_localized_string( t , s )
	rawset(t,s,s) -- only warn once per string
    return s
end

setmetatable( strings , { __index = missing_localized_string } )

-- The asset cache
assets = dofile( "assets-cache" )

ui =
    {
        assets              = assets,
        factory             = dofile( "ui-factory" ),
    }

-- for the modifier keys 
shift 		      = false
shift_changed 	  = false
control 	      = false

skins = {}

ui_element = dofile("/lib/ui_element.lua")
dofile("editor.lua")



-------------------------------------------------------------------------------
-- Build the MENU 
-------------------------------------------------------------------------------
   
    ----------------------------------------------------------------------------
    -- Key Map
    ----------------------------------------------------------------------------
    
    local key_map =
    {
        [ keys.a	] = function() hdr.input_mode = hdr.S_SELECT editor.save(false) end,
		[ keys.b	] = function() editor.undo_history() hdr.input_mode = hdr.S_SELECT end,
        [ keys.c	] = function() editor.clone() hdr.input_mode = hdr.S_SELECT end,
        [ keys.d	] = function() editor.duplicate() hdr.input_mode = hdr.S_SELECT end,
        [ keys.e	] = function() editor.redo() hdr.input_mode = hdr.S_SELECT end,
        [ keys.f	] = function() new_project() hdr.input_mode = hdr.S_SELECT end,
        [ keys.g	] = function() editor.group() hdr.input_mode = hdr.S_SELECT end,
        [ keys.u	] = function() editor.ugroup() hdr.input_mode = hdr.S_SELECT end,
        [ keys.w	] = function() hdr.input_mode = hdr.S_SELECT  editor.image() end,
        [ keys.n	] = function() editor.close() hdr.input_mode = hdr.S_SELECT end,
        [ keys.o	] = function() hdr.input_mode = hdr.S_SELECT editor.open()  end,
        [ keys.q	] = function() if editor.close() == nil then exit() end end,
        [ keys.p	] = function() open_project() end,
		[ keys.r	] = function() hdr.input_mode = hdr.S_RECTANGLE screen:grab_key_focus() end,
        [ keys.s	] = function() hdr.input_mode = hdr.S_SELECT editor.save(true) end,
        [ keys.t	] = function() editor.text() hdr.input_mode = hdr.S_SELECT end,
        [ keys.z	] = function() editor.undo() hdr.input_mode = hdr.S_SELECT end,
        [ keys.v	] = function() editor.v_guideline() hdr.input_mode = hdr.S_SELECT end,
        [ keys.h	] = function() editor.h_guideline() hdr.input_mode = hdr.S_SELECT end,
        [ keys.j	] = function() if not screen:find_child("timeline") then 
					    				if table.getn(g.children) > 0 then
											hdr.input_mode = hdr.S_SELECT local tl = ui_element.timeline() screen:add(tl)
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
        --[ keys.x	] = function() editor.export() hdr.input_mode = hdr.S_SELECT end,
        [ keys.i	] = function() editor.the_ui_elements() hdr.input_mode = hdr.S_SELECT end,
        [ keys.m	] = function() if (hdr.menu_hide  == true) then 
					    				menuShow()
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
					    			   hdr.menu_hide  = false 
						          else 
		     			    		   menuHide()
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
					    			 hdr.menu_hide  = true 
					    			 screen:grab_key_focus()
				       			end 
				       			hdr.input_mode = hdr.S_SELECT 
			    		end,
        [ keys.BackSpace] = function() editor.delete() hdr.input_mode = hdr.S_SELECT end,
        [ keys.Delete] = function() editor.delete() hdr.input_mode = hdr.S_SELECT end,
		[ keys.Shift_L  ] = function() shift = true end,
		[ keys.Shift_R  ] = function() shift = true end,
		[ keys.Control_L  ] = function() control = true end,
		[ keys.Control_R  ] = function() control = true end,
        [ keys.Return   ] = function() if(hdr.current_inspector == nil) then 
				     						for i, j in pairs (g.children) do 
												if(j.extra.selected == true) then 
													editor.n_selected(j) 
												end 
				     						end 
		   		     						screen:find_child("menuButton_file"):grab_key_focus()
		   		     						screen:find_child("menuButton_file").on_focus_in()
				     						hdr.input_mode = S_MENU
			             			  end 
			    			end ,
        [ keys.Left     ] = function() if table.getn(hdr.selected_objs) ~= 0 then
			         for q, w in pairs (hdr.selected_objs) do
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
			   end end,
        [ keys.Right    ] = function() if table.getn(hdr.selected_objs) ~= 0 then
			         for q, w in pairs (hdr.selected_objs) do
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
			   end end ,
        [ keys.Down     ] = function()if table.getn(hdr.selected_objs) ~= 0 then
			         for q, w in pairs (hdr.selected_objs) do
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
			   elseif(hdr.current_inspector == nil) then 
					if hdr.current_focus then 	
					      if hdr.current_focus.parent then 
						     --hdr.current_focus.parent.press_down() 
					      end 
					end
			  end end,
        [ keys.Up       ] = function() if table.getn(hdr.selected_objs) ~= 0 then
			         for q, w in pairs (hdr.selected_objs) do
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
			   elseif(hdr.current_inspector == nil) then 
					if hdr.current_focus then 	
					      if hdr.current_focus.parent then 
						     --hdr.current_focus.parent.press_up() 
					      end 
					end
			   end end
    }
    
    function screen.on_key_down( screen , key )
		if(key == keys.Shift_L) then shift = true end
		if(key == keys.Shift_R ) then shift = true end
		if(key == keys.Control_L ) then control = true end
		if(key == keys.Control_R ) then control = true end
	
		if(hdr.input_mode ~= hdr.S_POPUP) then 
          if key_map[key] then
              key_map[key](self)
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
	  if(hdr.input_mode == hdr.S_MENU_M) then
		if hdr.current_focus then 
			hdr.current_focus.on_focus_out()
			screen:grab_key_focus()
		end 
	  end 
	  if(hdr.input_mode == S_MENU) then
		if screen:find_child("menuButton_file"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_file").on_focus_out()
		elseif screen:find_child("menuButton_edit"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_edit").on_focus_out()
		elseif screen:find_child("menuButton_arrange"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_arrange").on_focus_out()
		elseif screen:find_child("menuButton_view"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_view").on_focus_out()
		end
		screen:grab_key_focus()
		hdr.input_mode = hdr.S_SELECT
	  end 

	  for i, j in pairs (g.children) do  
	       if j.type == "Text" then 
	            if not((x > j.x and x <  j.x + j.w) and (y > j.y and y <  j.y + j.h)) then 
			  ui.text = j	
			  if ui.text.on_key_down then 
	                  	ui.text:on_key_down(keys.Return)
			  end 
		    end
	       end 
	  end 

          --mouse_state = BUTTON_DOWN
          if(hdr.input_mode == hdr.S_RECTANGLE) then 
		editor.rectangle(x, y) 
	  end

          if(hdr.input_mode == S_MENU) then
		if screen:find_child("menuButton_file"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_file").on_focus_out()
		elseif screen:find_child("menuButton_edit"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_edit").on_focus_out()
		elseif screen:find_child("menuButton_arrange"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_arrange").on_focus_out()
		elseif screen:find_child("menuButton_view"):find_child("focus").opacity > 0 then 
			screen:find_child("menuButton_view").on_focus_out()
		end
		screen:grab_key_focus()

		hdr.input_mode = hdr.S_SELECT
          elseif(hdr.input_mode == hdr.S_SELECT) and (screen:find_child("msgw") == nil) then
	       if(hdr.current_inspector == nil) then 
		   -- if(button == 3 or num_clicks >= 2) and (g.extra.video ~= nil) then
		    if(button == 3) and (g.extra.video ~= nil) then -- imsi : num_clicks is not correct in engine 17
                         editor.inspector(g.extra.video)
                    end 
		    if(shift == true) then 
			editor.multi_select(x,y)
		    end 
	       end 
	  end
     end

	function screen:on_button_up(x,y,button,clicks_count)
		if hdr.current_focus ~= nil and  hdr.current_focus.extra.type == "EditorButton" then 
			local temp_focus = hdr.current_focus 
				hdr.current_focus.on_focus_out()
				temp_focus.on_focus_in()
			return true
		end 

		if hdr.dragging then
	    	local actor = unpack(hdr.dragging)
	       	if actor.parent then 	
		   		if actor.parent.name == "timeline" then 
					local actor, dx , dy, pointer_up_f = unpack( hdr.dragging )
					pointer_up_f(x,y,button,clicks_count) 
					return true
		   		end 
	       	end 
        end 	
	  	hdr.dragging = nil
        --if (mouse_state == BUTTON_DOWN) then
            if (hdr.input_mode == hdr.S_RECTANGLE) then 
	           editor.rectangle_done(x, y) 
	           hdr.input_mode = hdr.S_SELECT 
	    	end

	      	if(hdr.input_mode == hdr.S_SELECT) and 
		    	(screen:find_child("msgw") == nil) then
				editor.multi_select_done(x,y)
	      	end 

            --mouse_state = BUTTON_UP
       --end
	end



      function screen:on_motion(x,y)

	  local mouse_pointer

	  if control == true then 
		if is_in_container_group(x,y) == true and selected_content then 
			if selected_content.extra.is_in_group ~= true then 
				local c, t = find_container(x,y) 
				selected_container = c
				--if screen:find_child(c.name.."border") == nil then 
				if c.selected == false then
				 --if c.extra.org_opacity == nil or c.opacity == c.extra.org_opacity then
					editor.container_selected(c,x,y)	
					editor_lb:set_cursor(52)
					--[[
					if screen:find_child("mouse_pointer") then 
					     screen:remove(screen:find_child("mouse_pointer"))
					     mouse_pointer = CS_move_into
					     mouse_pointer.position = {x - 10 ,y - 10 ,0}
					     if(screen:find_child("mouse_pointer") == nil) then 
		     				     screen:add(mouse_pointer)
		     				     mouse_pointer.extra.type = "move_into"
					     end 
					end 
					]]
				 --end 
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
					--[[
			screen:remove(screen:find_child("mouse_pointer"))
			if control then 
				mouse_pointer = CS_move
				mouse_pointer.position = {x - 10 ,y - 10 ,0}
				if(screen:find_child("mouse_pointer") == nil) then 
		     			screen:add(mouse_pointer)
		     			mouse_pointer.extra.type = "move"
				end 
			end 
			]]
			selected_container = nil
		end 
	  end 

	  if(hdr.input_mode == hdr.S_RECTANGLE) then 
			editor_lb:set_cursor(34)
	  elseif shift == true then 
			editor_lb:set_cursor(68)
	  else 
			editor_lb:set_cursor(68)
	  end 
--[[

	  if(hdr.input_mode == hdr.S_RECTANGLE) then 
		if(screen:find_child("mouse_pointer") ~= nil) then 
		     screen:remove(screen:find_child("mouse_pointer"))
		end 
		--rect_mouse_pointer = ui.factory.draw_mouse_pointer()
		mouse_pointer = CS_crosshair 
		mouse_pointer.position = {x - 15 ,y - 15 ,0}
		if(screen:find_child("mouse_pointer") == nil) then 
		     screen:add(mouse_pointer)
		     mouse_pointer.extra.type = "crosshair"
		end 
	  elseif shift == true then 
		if(screen:find_child("mouse_pointer") ~= nil) then 
		     screen:remove(screen:find_child("mouse_pointer"))
		end 
		mouse_pointer = CS_pointer_plus
		mouse_pointer.position = {x  ,y  ,0}
		if(screen:find_child("mouse_pointer") == nil) then 
		     screen:add(mouse_pointer)
		     mouse_pointer.extra.type = "pointer_plus"
		end 
	  elseif screen:find_child("mouse_pointer") ~= nil  then 
		     screen:find_child("mouse_pointer").position = {x - 10 ,y - 10 ,0}
	  elseif screen:find_child("mouse_pointer") == nil then
		if(screen:find_child("mouse_pointer") ~= nil) then 
		     screen:remove(screen:find_child("mouse_pointer"))
		end 
		mouse_pointer = CS_pointer
		mouse_pointer.position = {x  ,y  ,0}
		if(screen:find_child("mouse_pointer") == nil) then 
		     screen:add(mouse_pointer)
		     mouse_pointer.extra.type = "pointer"
		end 
	  end 
]]
          if hdr.dragging then

	       local actor = unpack(hdr.dragging) 

	       if (actor.name == "grip") then  
	             local actor,s_on_motion = unpack(hdr.dragging) 
	             s_on_motion(x, y)
	             return true
	       end 
		
               local actor, dx , dy = unpack( hdr.dragging )

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
			
 	       if is_there_guideline() then 	
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
							end 
						end
					end
    			 end

				 if bumo then 
					local cur_x, cur_y = bumo:screen_pos_of_child(actor) 
	             	border.position = {cur_x, cur_y}
				 else 
				 	local group_pos = get_group_position(actor)
	             	border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
				 end 
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
			      
			      if table.getn(hdr.selected_objs) ~= 0 then
			      	for q, w in pairs (hdr.selected_objs) do
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


			if table.getn(hdr.selected_objs) ~= 0 then
			     for q, w in pairs (hdr.selected_objs) do
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
			 		local group_pos = get_group_position(actor)
	                anchor_mark.position = {actor.x + group_pos[1], actor.y + group_pos[2]}
				end 
		     end 

               end
          end

          --if(mouse_state == BUTTON_DOWN) then
               if (hdr.input_mode == hdr.S_RECTANGLE) then editor.rectangle_move(x, y) end
               if (hdr.input_mode == hdr.S_SELECT) and 
		  (screen:find_child("msgw") == nil) then 
		    editor.multi_select_move(x, y) end
          --end

	  
      end

      local function screen_add_bg()
    	screen:add(hdr.BG_IMAGE_20)
    	screen:add(hdr.BG_IMAGE_40)
    	screen:add(hdr.BG_IMAGE_80)
    	screen:add(hdr.BG_IMAGE_white)
    	screen:add(hdr.BG_IMAGE_import)
      end 


    
-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

    function main()

    	if controllers.start_pointer then 
  		controllers:start_pointer()
    	end
    
    	if editor_lb.disable_exit then
		editor_lb:disable_exit()
    	end

    	screen_add_bg()
    	screen.reactive=true
    
    	dofile("menu.lua")
		open_project(nil,nil,"main")

		local auto_save_duration = 60000  --msecs
		local auto_save = true
		local backup_timeline = Timeline {
		 	  duration = auto_save_duration,
	       	  direction = "FORWARD",
	       	  loop = true
	    }

	    function backup_timeline.on_completed()
			if auto_save == true and hdr.current_fn ~= "" then 
				editor.save(nil, true) 
			end 
			t = nil
	    end
	    backup_timeline:start()

    end

    screen:show()
    dolater(main)
