local screen_ui = {}
	
local m_init_x = 0 
local m_init_y = 0 
local multi_select_border

local screen_pos_of_child = function(actor)
    return actor.transformed_position[1]/screen.scale[1], 
           actor.transformed_position[2]/screen.scale[2]
end


function screen_ui.n_selected_all() 
    local currentLayer 
	for i, j in pairs (screen.children) do 
		if j.name then 
			if string.find(j.name, "border") then 
		        local a, b = string.find(j.name,"border")
		        local t_obj = screen:find_child(string.sub(j.name, 1, a-1))	
                if t_obj then 
			        _VE_.deselectUIElement(t_obj.gid, false)
                end
			end 
		end
	end
    _VE_.openInspector(screen.gid, false)
	selected_objs = {}

end

function screen_ui.draw_selected_container_border(x,y) 

	local prev_selected_container

	selected_container = util.find_container(x,y) 

	if selected_container then 
		prev_selected_container = selected_container 
	end 
			
	if prev_selected_container then 
		if prev_selected_container ~= selected_container then 
			screen_ui.n_selected (prev_selected_container)
		end 
	end

	if selected_container and selected_content then 
		if selected_content.extra.is_in_group ~= true then 
			if selected_container.ve_selected == false then
				screen_ui.container_selected(selected_container,x,y)	
			elseif selected_container.widget_type == "LayoutManager" then 
				if selected_container.ve_selected == true then
					local layout_bdr = screen:find_child(selected_container.name.."border")
					if layout_bdr then 
				    	local r_c = layout_bdr.r_c
				     	local row, col = selected_container:r_c_from_abs_x_y(x,y)
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
        	border_width = 4,
        	anchor_point = obj.anchor_point,
        	x_rotation = obj.x_rotation,
        	y_rotation = obj.y_rotation,
        	z_rotation = obj.z_rotation,
			scale = obj.scale, 
	} 

	if obj.widget_type ~= "LayoutManager" then 
        
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
	  	local row, col=  obj:r_c_from_abs_x_y(x,y)
        local tile = obj.cells[row][col]

	  	if row and col then 
			tile_x = tile.x - tile.anchor_point[1]
			tile_y = tile.y - tile.anchor_point[2]
			tile_w = tile.w
			tile_h = tile.h
			tile_x = obj.x + tile_x
			tile_y = obj.y + tile_y
		end

        obj_border.position = {tile_x, tile_y, 0} 
        obj_border.size = {tile_w, tile_h}
	  	obj_border.extra.r_c = {row, col}
   end 

    if not screen:find_child(obj_border.name) then 
        screen:add(obj_border)
        obj.extra.ve_selected = true
    end
end  

function screen_ui.getSelectedObj()
	for i, j in pairs (screen.children) do 
		if j.name then 
			if string.find(j.name, "border") then 
				local a, b = string.find(j.name,"border")
		    	local selObj = screen:find_child(string.sub(j.name, 1, a-1))
                if selObj then 
		    	    return selObj
                else 
		    	    return nil
                end 
            end 
        end 
    end
    return nil
end 

function screen_ui.getSelectedName()
	for i, j in pairs (screen.children) do 
		if j.name then 
			if string.find(j.name, "border") then 
				local a, b = string.find(j.name,"border")
		    	local selObj = screen:find_child(string.sub(j.name, 1, a-1))
                if selObj then 
		    	    return string.sub(j.name, 1, a-1), selObj.gid
                else 
		    	    return string.sub(j.name, 1, a-1), nil
                end 
            end 
        end 
    end
    return nil
end 

function screen_ui.selected(obj)

    if input_mode == hdr.S_FOCUS then
        local obj_border = Rectangle{
   			name = obj.name.."border",
   			color = {0,0,0,0},
	    	border_color = {3,176,203,255},
 	  		border_width = 2,
	    }
	    obj_border.anchor_point = obj.anchor_point
        obj_border.x_rotation = obj.x_rotation
        obj_border.y_rotation = obj.y_rotation
        obj_border.z_rotation = obj.z_rotation
        obj_border.size = obj.size
        obj_border.position = obj.position
        if obj.is_in_group == true then
            obj_border.scale = obj.parent_group.scale
        end

        screen:add(obj_border)
        return 
    end

	if obj.name == nil then return end 

	if screen:find_child("multi_select_border") == nil and shift == false then 
		screen_ui.n_selected_all()
	end 

	local obj_border = Rectangle{
   			name = obj.name.."border",
   			color = {0,0,0,0},
	    	border_color = {255,25,25,255},
 	  		border_width = 2,
	}

	local group_pos
	local bumo	
	local tab_extra_h, tab_extra_w

   	if(obj.extra.is_in_group == true)then 
		for i, c in pairs(screen.children) do  
			if obj.name == c.name then 
				break
			else 
				if c.extra then 
					if c.widget_type == "ScrollPane" or c.widget_type == "ArrowPane" then 
						for k, e in pairs (c.children) do 
							if e.name == obj.name then 
								bumo = c	
							end 
						end 
					elseif c.widget_type == "TabBar" then 
						for h,q in pairs (c.tabs) do 
							for k,w in pairs (q.children) do 
								if w.name == obj.name then 
									if c.tab_position == "top" then 
										tab_extra_h = c.ui_height
										tab_extra_w = nil
									else
										tab_extra_w = c.ui_width
										tab_extra_h = nil
									end
								end
							end
						end 	
					end 
				end
			end
    	end
		group_pos = util.get_group_position(obj)
		if bumo then 
			obj_border.x, obj_border.y = screen_pos_of_child(obj) 	
		elseif group_pos then 
     		obj_border.x = (obj.x * obj.parent_group.scale[1] + group_pos[1])
            obj_border.y = (obj.y * obj.parent_group.scale[2] + group_pos[2])  
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

    local am = screen:find_child(obj.name.."a_m") 
    if am then 
    	screen:remove(am)
    end
	
    anchor_mark= ui.factory.draw_anchor_pointer()

    if(obj.extra.is_in_group == true)then 
		if bumo then 
    		anchor_mark.position = {obj_border.x, obj_border.y, obj_border.z}
		elseif group_pos then
    		anchor_mark.position = {obj.x* obj.parent_group.scale[1] + group_pos[1] , obj.y * obj.parent_group.scale[2] + group_pos[2], obj.z}
		end
    else 
   		anchor_mark.position = {obj.x, obj.y, obj.z}
    end
	
	if tab_extra_h then 
		anchor_mark.y = anchor_mark.y + tab_extra_h 
		obj_border.y = obj_border.y + tab_extra_h
	end 

	if tab_extra_w then 
		anchor_mark.x = anchor_mark.x + tab_extra_w
		obj_border.x = obj_border.x + tab_extra_w
	end 
	
    if(obj.extra.is_in_group == true)then 
        obj_border.scale = obj.parent_group.scale
        if obj.parent_group.scale[1] < 1 then
            obj_border.w = obj_border.w + 2 
            obj_border.h = obj_border.h + 2 
        end
    elseif obj.scale[1] < 1 then 
            obj_border.w = obj_border.w + 2 
            obj_border.h = obj_border.h + 2 
    end
    anchor_mark.name = obj.name.."a_m"
    screen:add(anchor_mark)
    screen:add(obj_border)
    obj.extra.ve_selected = true
    table.insert(selected_objs, obj_border.name)
end  

function screen_ui.n_selected(obj)
     if input_mode == hdr.S_FOCUS then
        screen:remove(screen:find_child(obj.name.."border"))
        return    
     end

     if(obj.name == nil) then 
		return 
	 end 

     if(obj.type ~= "Video") then 
		-- remove red border
        screen:remove(screen:find_child(obj.name.."border"))
		-- remove red cross mark showing anchor point
        if (screen:find_child(obj.name.."a_m") ~= nil) then 
	     	screen:remove(screen:find_child(obj.name.."a_m"))
        end

		util.table_removekey(selected_objs, obj.name.."border")

        obj.extra.ve_selected = false
     end 

end  

function screen_ui.n_select_all ()

    local currentLayer 

	for i, j in pairs (screen.children) do 
		if(j.extra.ve_selected == true) then 
			screen_ui.n_selected(j) 
		end 
	end 
	selected_objs = {}
end 

function screen_ui.n_select(obj, drag)
     if(obj.name == nil)then return end 

     if(obj.type ~= "Video") then 
     	if(shift == false)then 
			screen_ui.n_selected_all()
			if(drag == nil) then
	     		screen_ui.selected(obj) 
			end 
     	else
			screen_ui.n_selected(obj) 
     	end 
    end
end  

function screen_ui.move_selected_obj(direction)

	local direction_val = 
		{
			["Left"] = function() return -1 end, 
			["Right"] = function() return 1 end,  
			["Up"] = function() return -1 end,  
			["Down"] = function() return 1 end,  
		}

	if #selected_objs ~= 0 then
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
		     	local anchor_mark = screen:find_child(t_obj.name.."a_m")
	       		if anchor_mark then 
		     		anchor_mark.position = {t_obj.x, t_obj.y, t_obj.z}
               	end
	         end
		end
	end 
end

function screen_ui.multi_select(x,y) 
	
 	m_init_x = x -- origin x
    m_init_y = y -- origin y

    multi_select_border = Rectangle{
        name="multi_select_border", 
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

	local m_slt_flag 

	for k, l in pairs(screen.children) do  
        if l.children then
	    for i, v in pairs(l.children) do 
		if (v.x > m_init_x and v.x < x and v.y < y and v.y > m_init_y ) and
			(v.x + v.w > m_init_x and v.x + v.w < x and v.y + v.h < y and v.y + v.h > m_init_y ) then 
			m_slt_flag = true 
		end 
		end 
		end 
    end

	if m_slt_flag then 
		screen_ui.n_select_all()
	end 

    for k, l in pairs(screen.children) do 
        if l.children then
        for i, v in pairs(l.children) do 
		if (v.x > m_init_x and v.x < x and v.y < y and v.y > m_init_y ) and
			(v.x + v.w > m_init_x and v.x + v.w < x and v.y + v.h < y and v.y + v.h > m_init_y ) then 
			if(v.extra.ve_selected == false and v.parent.visible == true) then 
			    if(v.extra.ve_selected == false and l.visible == true) then 
                    _VE_.openInspector(v.gid, true)
                end
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

	if current_focus ~= nil and  current_focus.widget_type == "EditorButton" then 
		local temp_focus = current_focus 
		current_focus.clear_focus()
		temp_focus.set_focus()
		return true
	end 

	if dragging then
    	local actor = unpack(dragging)
		if actor.parent and actor.parent.name == "timeline" then 
			local actor, dx , dy, pointer_up_f = unpack( dragging )
			pointer_up_f(x,y,button,clicks_count) 
			return true
	    end
	end 	

end 

function screen_ui.dragging(x,y)

		local actor, dx, dy 
		local bumo, border, tab_extra_w, tab_extra_h

        if dragging then

	       actor = unpack(dragging) 
			
		   -- for dragging scroll bar grip 
		   if actor.name == nil then 
		       return 
	       elseif (actor.name == "grip" or actor.name == "focus_grip" ) then  
	           local actor,s_on_motion = unpack(dragging) 
	           s_on_motion(x, y)
	           return true
	       end 
		
           actor, dx , dy = unpack( dragging )

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

	      border = screen:find_child(actor.name.."border")
	      if(border ~= nil) then 
		  	  if (actor.extra.is_in_group == true) then
				 for k, l in pairs(screen.children) do
                    if l.children then
				    for i, c in pairs(l.children) do 
					if actor.name == c.name then 
						break
					else 
						if c.extra then 
							if c.widget_type == "ScrollPane" or c.widget_type == "ArrowPane" then 
								for k, e in pairs (c.children) do 
									if e.name == actor.name then 
										bumo = c	
									end 
								end 
							elseif c.widget_type == "TabBar" then 
								for h,q in pairs (c.tabs) do 
									for k,w in pairs (q.children) do 
										if w.name == actor.name then 
											if c.tab_position == "top" then 
												tab_extra_h = c.ui_height
												tab_extra_w = nil
											else
												tab_extra_w = c.ui_width
												tab_extra_h = nil
											end
										end
									end
								end 
							end 
						end
					end
					end
					end
    			 end -- for 


				 if bumo then 
					local cur_x, cur_y = screen_pos_of_child(actor) 
	             	border.position = {cur_x, cur_y}
				 else 
				 	local group_pos = util.get_group_position(actor)
                    if  group_pos then 
	             	    border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
                    end 
				 end 
		    else -- if 
	             border.position = {x -dx, y -dy}
		    end 

			if tab_extra_h then 
				border.y = border.y + tab_extra_h
			elseif tab_extra_w then 
				border.x = border.x + tab_extra_w
			end 
		else 
			screen_ui.n_select_all()
	    end -- if border ~= nil 

	     
	    actor.x =  x - dx 
	    actor.y =  y - dy  
		
		-- for selected object's anchor mark dragging 	
	
		local anchor_mark = screen:find_child(actor.name.."a_m")
	  	if anchor_mark then 
		    anchor_mark.position = {actor.x, actor.y, actor.z}

		    if (actor.extra.is_in_group == true) then
				if bumo then 
					local cur_x, cur_y = screen_pos_of_child(actor) 
	                anchor_mark.position = {cur_x, cur_y}
				else 
			 		local group_pos = util.get_group_position(actor)
                    if group_pos then 
	                    anchor_mark.position = {actor.x + group_pos[1], actor.y + group_pos[2]}
                    end
				end 
		    end 
        end
	end

	if tab_extra_h then
		anchor_mark.y = anchor_mark.y + tab_extra_h
	elseif tab_extra_w then 
		anchor_mark.x = anchor_mark.x + tab_extra_w
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

	local timeline =  screen:find_child("timeline") 

	if not timeline then 
		if #screen.children > 0 then  
			input_mode = hdr.S_SELECT 
			local tl = ui_element.timeline() 
			tl.extra.show = true 
			screen:add(tl)
		end
	elseif #screen.children == 0 then 
		screen:remove(timeline)
	elseif timeline.extra.show ~= true  then 
		timeline:show()
		timeline.extra.show = true
	else 
		timeline:hide()
		timeline.extra.show = false
	end
end 

function screen_ui.menu_hide()
	if (menu_hide  == true) then 
		menu.menuShow()
	else 
		menu.menuHide()
	end 
	screen:grab_key_focus()
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
		end 
		t = nil
		menu.menu_raise_to_top()
	end

	backup_timeline:start()
end 

return screen_ui
