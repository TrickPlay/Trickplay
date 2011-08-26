local screen_ui = {}

function screen_ui.draw_selected_container_border(x,y) 

	local prev_selected_container

	if selected_container then 
		prev_selected_container = selected_container 
	end 
			
	selected_container = util.find_container(x,y) 

	if prev_selected_container then 
		if prev_selected_container ~= selected_container then 
			screen_ui.n_selected (prev_selected_container)
		end 
	end

	if selected_container and selected_content then 
		if selected_content.extra.is_in_group ~= true then 
			if selected_container.selected == false then
				screen_ui.container_selected(selected_container,x,y)	
			elseif selected_container.extra.type == "LayoutManager" then 
				if selected_container.selected == true then
					local layout_bdr = screen:find_child(selected_container.name.."border")
					if layout_bdr then 
				    	local r_c = layout_bdr.r_c
				     	local col , row = selected_container:r_c_from_abs_position(x,y)
						if r_c then 
				     		if r_c[1] ~= row or r_c[2] ~= col then  
		    					screen_ui.n_selected(selected_container)
				     		end 
				     	end 
					end 
				end
			end 
		end 
	end 
end 

function screen_ui.container_selected(obj, x, y)

	local obj_border = Rectangle {
			name = obj.name.."border", 
        	color = {0,0,0,0},
        	border_color = {255,25,25,255},
        	border_width = 2,
        	anchor_point = obj.anchor_point,
        	x_rotation = obj.x_rotation,
        	y_rotation = obj.y_rotation,
        	z_rotation = obj.z_rotation,
			scale = obj.scale, 
	} 

	if obj.extra.type ~= "LayoutManager" then 
        
		obj_border.position = obj.position
        obj_border.size = obj.size

        anchor_mark= ui.factory.draw_anchor_pointer()
        if(obj.extra.is_in_group == true)then 
        	anchor_mark.position = {obj.x + group_pos[1] , obj.y + group_pos[2], obj.z}
        else 
        	anchor_mark.position = {obj.x, obj.y, obj.z}
        end
        anchor_mark.name = obj.name.."a_m"

        screen:add(anchor_mark)

   	else -- Layout Manager Tile border

		local tile_x, tile_y, tile_w, tile_h 
	  	local col, row=  obj:r_c_from_abs_position(x,y)

	  	if row and col then 
			tile_x, tile_y, tile_w, tile_h = obj:cell_x_y_w_h(row,col)
			tile_x = obj.x + tile_x
			tile_y = obj.y + tile_y
		end

        obj_border.position = {tile_x, tile_y, 0} 
        obj_border.size = {tile_w, tile_h}
	  	obj_border.extra.r_c = {row, col}

   end 

   screen:add(obj_border)
   obj.extra.selected = true
   table.insert(selected_objs, obj_border.name)

end  

function screen_ui.selected(obj, call_by_inspector)

	if obj.name == nil then return end 

	if(shift == false)then 
		while(#selected_objs ~= 0) do
			local t_border = screen:find_child(table.remove(selected_objs)) 
			if(t_border ~= nil) then 
				-- t_obj 만 찾아서 n_select 불러 주면 되는걸 여기서 중복 되게 하고 있는건 아닌지 확인요망 

		    	local i, j = string.find(t_border.name,"border")
		    	t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	

				screen:remove(t_border)

            	if screen:find_child(t_obj.name.."a_m") then 
     				screen:remove(screen:find_child(t_obj.name.."a_m"))
     			end

		    	if(t_obj ~= nil) then 
					t_obj.extra.selected = false
	        	end

			end
		end -- while 

	   	local obj_border = Rectangle{
   			name = obj.name.."border",
   			color = {0,0,0,0},
	    	border_color = {255,25,25,255},
 	  		border_width = 2,
		}

	   	local group_pos
		local bumo	
		local tab_extra

   		if(obj.extra.is_in_group == true)then 
			for i, c in pairs(g.children) do
				if obj.name == c.name then 
					break
				else 
					if c.extra then 
						if c.extra.type == "ScrollPane" or c.extra.type == "ArrowPane" then 
							for k, e in pairs (c.content.children) do 
								if e.name == obj.name then 
									bumo = c	
								end 
							end 
						elseif c.extra.type == "TabBar" then 
							for h,q in pairs (c.tabs) do 
								for k,w in pairs (q.children) do 
									if w.name == obj.name then 
										tab_extra = c.ui_height
									end
								end
							end 	
						end 
					end
				end
    		end

			group_pos = util.get_group_position(obj)
			if bumo then 
		   		obj_border.x, obj_border.y = bumo:screen_pos_of_child(obj) 	
			else 
     	   		obj_border.x = obj.x + group_pos[1]
     	   		obj_border.y = obj.y + group_pos[2]
			end
			obj_border.extra.group_postion = obj.extra.group_position
   		else 
     		obj_border.position = obj.position
   		end
   	
		obj_border.anchor_point = obj.anchor_point
    	obj_border.x_rotation = obj.x_rotation
    	obj_border.y_rotation = obj.y_rotation
    	obj_border.z_rotation = obj.z_rotation
    	obj_border.size = obj.size
    	if(obj.scale ~= nil) then 
    		obj_border.scale = obj.scale
    	end 

    	if (screen:find_child(obj.name.."a_m") ~= nil) then 
     		screen:remove(screen:find_child(obj.name.."a_m"))
    	end
	
    	anchor_mark= ui.factory.draw_anchor_pointer()
    	if(obj.extra.is_in_group == true)then 
			if bumo then 
    			anchor_mark.position = {obj_border.x, obj_border.y, obj_border.z}
			else
    			anchor_mark.position = {obj.x + group_pos[1] , obj.y + group_pos[2], obj.z}
			end
    	else 
        	anchor_mark.position = {obj.x, obj.y, obj.z}
    	end
	
		if tab_extra then 
			anchor_mark.y = anchor_mark.y + tab_extra 
			obj_border.y = obj_border.y + tab_extra
		end 
	
    	anchor_mark.name = obj.name.."a_m"
    	screen:add(anchor_mark)
    	screen:add(obj_border)
    	obj.extra.selected = true
    	table.insert(selected_objs, obj_border.name)
	end 
end  

function screen_ui.n_select(obj, call_by_inspector, drag)
     if(obj.name == nil)then 
		return 
	 end 
     if(obj.type ~= "Video") then 
     	if(shift == false)then 
			while(table.getn(selected_objs) ~= 0) do
				local t_border = screen:find_child(table.remove(selected_objs)) 
				if(t_border ~= nil) then 
		     		screen:remove(t_border)
		     		local i, j = string.find(t_border.name,"border")
		     		t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		     		if(t_obj ~= nil) then 
						t_obj.extra.selected = false
        				if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
	   						screen:remove(screen:find_child(t_obj.name.."a_m"))
        				end
	             	end
				end
			end
			if(drag == nil) then
	     		screen_ui.selected(obj) 
			end 
     	else
        	if (screen:find_child(obj.name.."a_m") ~= nil) then 
	     		screen:remove(screen:find_child(obj.name.."a_m"))
        	end
        	screen:remove(screen:find_child(obj.name.."border"))
        	table.remove(selected_objs)
        	obj.extra.selected = false
     	end 
    end
end  

function screen_ui.n_selected(obj, call_by_inspector)
     if(obj.name == nil) then 
		return 
	 end 
     if(obj.type ~= "Video") then 
        screen:remove(screen:find_child(obj.name.."border"))
        if (screen:find_child(obj.name.."a_m") ~= nil) then 
	     	screen:remove(screen:find_child(obj.name.."a_m"))
        end
        table.remove(selected_objs)
        obj.extra.selected = false
     end 
end  

function screen_ui.nselect_all ()
	for i, j in pairs (g.children) do 
		if(j.extra.selected == true) then 
			screen_ui.n_selected(j) 
		end 
	end 
	selected_objs = {}
end 


function screen_ui.move_selected_obj(direction)

	local direction_val = 
		{
			["Left"] = function() return -1 end, 
			["Right"] = function() return 1 end,  
			["Up"] = function() return -1 end,  
			["Down"] = function() return 1 end,  
		}

	if table.getn(selected_objs) ~= 0 then
		for q, w in pairs (selected_objs) do
			local t_border = screen:find_child(w)
			if(t_border ~= nil) then 
		     	local i, j = string.find(t_border.name,"border") 
				local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	

				if direction == "Left" or direction == "Right" then 
		    		t_border.x = t_border.x + direction_val[direction]()
		        	if(t_obj ~= nil) then 
			    		t_obj.x = t_obj.x + direction_val[direction]()
					end 
				else 
		     		t_border.y = t_border.y + direction_val[direction]()
					 if(t_obj ~= nil) then 
			           	t_obj.y = t_obj.y + direction_val[direction]()
					 end 
				end 
	       		if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
		     		local anchor_mark = screen:find_child(t_obj.name.."a_m")
		     		anchor_mark.position = {t_obj.x, t_obj.y, t_obj.z}
               	end
	         end
		end
	end 
end

	
local m_init_x = 0 
local m_init_y = 0 
local multi_select_border

function screen_ui.multi_select(x,y) 

 	m_init_x = x -- origin x
        m_init_y = y -- origin y

        multi_select_border = Rectangle{
                name="multi_select_border", 
                --border_color= {0,255,0},
                border_color= {255,25,25,255},
                border_width=0,
                color= {0,0,0,0},
                size = {1,1},
                position = {x,y},
		opacity = 255
        }
        multi_select_border.reactive = false
        screen:add(multi_select_border)
end 

function screen_ui.multi_select_done(x,y) 

	if(multi_select_border == nil) then return end 
        multi_select_border.size = { math.abs(x-m_init_x), math.abs(y-m_init_y) }

        if(x-m_init_x < 0) then
	   multi_select_border.x = x 
	   m_init_x = x
	   x = m_init_x + multi_select_border.w
        end
        if(y-m_init_y < 0) then
	   multi_select_border.y = y 
	   m_init_y = y
	   y = m_init_y + multi_select_border.h
        end

        for i, v in pairs(g.children) do
				if v.name then 
             if g:find_child(v.name) then
		if (v.x > m_init_x and v.x < x and v.y < y and v.y > m_init_y ) and
		(v.x + v.w > m_init_x and v.x + v.w < x and v.y + v.h < y and v.y + v.h > m_init_y ) then 
			if(shift == true and v.extra.selected == false) then 
		             screen_ui.selected(v)
			end 
		end 
             end
			 end 
        end
	
	screen:remove(multi_select_border)
	m_init_x = 0 
	m_init_y = 0 
	multi_select_border = nil
    screen.grab_key_focus(screen)
	input_mode = hdr.S_SELECT

end 

function screen_ui.multi_select_move(x,y)
	if(multi_select_border == nil) then return end 
	multi_select_border:set{border_width = 2}
        multi_select_border.size = { math.abs(x-m_init_x), math.abs(y-m_init_y) }
        if(x- m_init_x < 0) then
            multi_select_border.x = x
        end
        if(y- m_init_y < 0) then
            multi_select_border.y = y
        end
end

function screen_ui.dragging_up(x,y)
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
end 

function screen_ui.dragging(x,y)

	 	local tab_extra

        if dragging then

	       local actor = unpack(dragging) 
			
		   -- for dragging scroll bar grip 
		   if actor.name == nil then 
		       return 
	       elseif (actor.name == "grip" or actor.name == "focus_grip" ) then  
	           local actor,s_on_motion = unpack(dragging) 
	           s_on_motion(x, y)
	           return true
	       end 
		
           local actor, dx , dy = unpack( dragging )

		   -- for dragging timepoint 

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
			
		  -- for dragging guideline 

 	      if util.is_there_guideline() then 	
	           if (util.guideline_type(actor.name) == "v_guideline") then 
	            	actor.x = x - dx
	            	return true
	       	   elseif (util.guideline_type(actor.name) == "h_guideline") then 
		    		actor.y = y - dy
	            	return true
	       	   end 
		  end 

		  -- for dragging selected object

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
    			 end -- for 

				 if bumo then 
					local cur_x, cur_y = bumo:screen_pos_of_child(actor) 
	             	border.position = {cur_x, cur_y}
				 else 
				 	local group_pos = util.get_group_position(actor)
	             	border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
				 end 
		    else -- if 
	             border.position = {x -dx, y -dy}
		    end 
	    end -- if dragging then 

	    if tab_extra then 
			border.y = border.y + tab_extra
		end 
 
	    if(actor.name ~= "scroll_bar" and actor.name ~= "xscroll_bar") then
	            actor.x =  x - dx 
	            actor.y =  y - dy  
	    else

			-- for dragging screen-scroll-bar  
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
			   		g.extra.scroll_y = math.floor(dif) 
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

	   	-- for selected object's anchor mark dragging 	
	
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

end 
function screen_ui.cursor_setting()
	if(input_mode == hdr.S_RECTANGLE) then 
		editor_lb:set_cursor(34)
		cursor_type = 34
	elseif shift == true then 
		editor_lb:set_cursor(68)
		cursor_type = 68
	elseif cursor_type == 34 or control == false then  
		editor_lb:set_cursor(68)
		cursor_type = 68
	end 
end 


function screen_ui.timeline_show()
	if not screen:find_child("timeline") then 
		if table.getn(g.children) > 0 then
			input_mode = hdr.S_SELECT local tl = ui_element.timeline() screen:add(tl)
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
end 

function screen_ui.menu_hide()
	if (menu_hide  == true) then 
		menu.menuShow()
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
		menu_hide  = false 
	else 
		menu.menuHide()
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
		menu_hide  = true 
		screen:grab_key_focus()
	end 
end 

function screen_ui.add_bg()
	screen:add(BG_IMAGE_20)
    screen:add(BG_IMAGE_40)
    screen:add(BG_IMAGE_80)
    screen:add(BG_IMAGE_white)
    screen:add(BG_IMAGE_import)
end 

function screen_ui.auto_save()
	local backup_timeline = Timeline {
		duration = hdr.AUTO_SAVE_DURATION,
	    direction = "FORWARD",
	    loop = true
	}

	function backup_timeline.on_completed()
		if hdr.AUTO_SAVE == true and current_fn ~= "" and current_fn ~= "unsaved_temp.lua" and current_fn ~= "/screens/unsaved_temp.lua" then 
			editor.save(nil, true) 
			print(current_fn.." is auto_saved")
		end 
		t = nil
		menu.menu_raise_to_top()
	end

	backup_timeline:start()
end 

return screen_ui
