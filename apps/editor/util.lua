----------
-- Utils 
-----------
local util = {}

function util.table_copy(t)
  	local t2 = {}
  	for k,v in pairs(t) do
    	t2[k] = v
  	end
  	return t2
end

function util.table_insert(t, val)
	if t then 
	    table.insert(t, val) 
	end 
	return t
end 

function util.table_move_up(t, itemNum)
	local prev_i, prev_j 
	for i,j in pairs (t) do 
		if i == itemNum then 
			if prev_i then 
		     	t[prev_i] = j 
		     	t[i] = prev_j 
		     	return
			else 
		     	return 
			end 
	    end 
	    prev_i = i 
	    prev_j = j 
	end 
end 

function util.table_move_down(t, itemNum)
	local i, j, next_i, next_j 
	for i,j in pairs (t) do 
		if i == itemNum then 
	    	next_i = i + 1 
		  	if t[next_i] then 
	     		next_j = t[next_i] 
	     		t[i] = next_j
	     		t[next_i] = j 
				return 
		  	else 
		     	return     
		  	end 
	     end 
	end 
	return     
end 

function util.table_remove_val(t, val)
	for i,j in pairs (t) do
		if j == val then 
		     table.remove(t, i)
		end 
	end 
	return t
end 

function util.table_removekey(table, key)
	local idx = 1	
	local temp_t = {}
	table[key] = nil
	for i, j in pairs (table) do 
		temp_t[idx] = j 
		idx = idx + 1 
	end 
	return temp_t
end

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function util.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function util.values(t) 
	local j = 0 
	return function () j = j+1 return t[j] end 
end 

function util.is_available(new_name)
    if(g:find_child(new_name) ~= nil) then 
	return false 
    else 
	return true
    end
end 

function util.is_lua_file(fn)
	local i, j = string.find(fn, ".lua")
	if (j == string.len(fn)) then
		return true
	else 
		return false
	end 
end 

function util.is_img_file(fn)
	local i, j = string.find(fn, ".png")
	if (j == string.len(fn)) then
		return true
	else 
		i, j = string.find(fn, ".jpg")
	if (j == string.len(fn)) then
		return true
    end

	return false
	end 
end 

function util.is_mp4_file(fn)
	local i, j = string.find(fn, ".mp4")
	if (j == string.len(fn)) then
		return true
	else 
		return false
	end 
end 

function util.is_in_list(item, list)
    if list == nil then 
        return false
    end 

    for i, j in pairs (list) do
		if item == j then 
			return true
		end 
    end 
    return false
end 

function util.need_stub_code(v)
    local lists = {"Button", "ButtonPicker", "RadioButtonGroup", "CheckBoxGroup", "MenuButton"}
    if v.extra then 
        if util.is_in_list(v.extra.type, lists) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 
end 

function util.is_this_widget(v)
    if v.extra then 
        if util.is_in_list(v.extra.type, hdr.uiElements) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 
end 

 
function util.is_this_container(v)
    if v.extra then 
        if util.is_in_list(v.extra.type, hdr.uiContainers) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 
end 

function util.clear_bg()
    BG_IMAGE_20.opacity = 0
    BG_IMAGE_20:lower_to_bottom()
    BG_IMAGE_40.opacity = 0
    BG_IMAGE_40:lower_to_bottom()
    BG_IMAGE_80.opacity = 0
    BG_IMAGE_80:lower_to_bottom()
    BG_IMAGE_white.opacity = 0
    BG_IMAGE_white:lower_to_bottom()
    BG_IMAGE_import.opacity = 0
    BG_IMAGE_import:lower_to_bottom()

	menu.clearMenuButtonView_BGIcons() 	
end

function util.getObjnames()
    local obj_names = ""
    for i, v in pairs(g.children) do
		if obj_names ~= "" then 
			obj_names = obj_names..","
		end 
    	obj_names = obj_names..v.name
    end
    return obj_names
end

function util.is_there_guideline () 
	for i, j in pairs (screen.children) do 
		if j.name then 
			if string.find(j.name, "_guideline") then 
				return true 
			end 
		end 
    end 
	return false
end 

selected_container = nil
selected_content = nil

function util.is_in_container_group(x_pos, y_pos) 
	for i, j in pairs (g.children) do 
	if j.x < x_pos and x_pos < j.x + j.w and j.y < y_pos and y_pos < j.y + j.h then 
		if j.extra then 
		    if util.is_this_container(j) then
		        return true 
		    end 
		end 
	end 
  	end 
  	return false 
end 

function util.find_container(x_pos, y_pos)
	for i, j in pairs (g.children) do 
		if j.x < x_pos and x_pos < j.x + j.w and j.y < y_pos and y_pos < j.y + j.h then 
			if j.extra then 
				if util.is_this_container(j) then
					return j, j.extra.type 
				end 
			end 
		end 
	end 
end 

function util.create_on_button_down_f(v)
	v.extra.selected = false
	local org_object, new_object 
	
	function v:on_button_down(x,y,button,num_clicks)
	   if (input_mode ~= hdr.S_RECTANGLE) then 
	   		if(v.name ~= "ui_element_insert" and v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw") then 
	     		if(input_mode == hdr.S_SELECT) and  (screen:find_child("msgw") == nil) then
	       			if (v.extra.is_in_group == true and control == false ) then 
		    			local p_obj = v.parent --find_parent(v)
                		if(button == 3) then -- imsi : num_clicks is not correct ! 
                		--if(button == 3 or num_clicks >= 2) then
                			editor.inspector(p_obj)
                    		return true
                		end 

	            		if(input_mode == hdr.S_SELECT and p_obj.extra.selected == false) then 
		     				editor.selected(p_obj)
	            		elseif (p_obj.extra.selected == true) then 
		     				editor.n_select(p_obj)
		    			end
	            		org_object = util.copy_obj(p_obj)
		    			if v.extra.lock == false then -- or  v.name =="inspector" then 
           	    			dragging = {p_obj, x - p_obj.x, y - p_obj.y }
		    			end 
           	    		return true
	      			else 
                		if(button == 3) then-- imsi : num_clicks is not correct ! 
		    		--if(button == 3 or num_clicks >= 2) then
                 			editor.inspector(v)
                    		return true
                		end 
	            		if(input_mode == hdr.S_SELECT and v.extra.selected == false) then 
								----kkkk
		     				editor.selected(v) 
							if(v.type == "Text") then 
			      				v:set{cursor_visible = true}
			      				v:set{editable= true}
     			    			v:grab_key_focus(v)
							end 

		    			elseif (v.extra.selected == true) then 
								if(v.type == "Text") then 
			      					v:set{cursor_visible = true}
			      					v:set{editable= true}
     			    				v:grab_key_focus(v)
								end 
								editor.n_select(v) 
	       				end
-----[[ 	SHOW POSSIBLE CONTAINERS
		    			if control == true then 
							editor_lb:set_cursor(52)

							--[[
							if(screen:find_child("mouse_pointer") ~= nil) then 
		     					screen:remove(screen:find_child("mouse_pointer"))
							end 
							mouse_pointer = CS_move
							mouse_pointer.extra.type = "move"
							mouse_pointer.position = {x - 10 ,y - 10 ,0}
							if(screen:find_child("mouse_pointer") == nil) then 
		     					screen:add(mouse_pointer)
							end 
							]]
							selected_content = v 
			
							local odr 
							for i,j in pairs (g.children) do 
								if j.name == v.name then 
									odr = i
								end 
							end 

							if odr then 
								for i,j in pairs (g.children) do 
									--print(j.name)
									if util.is_this_container(j) == true then 
										--print(j.name, "container")
										if i > odr then 
											j.extra.org_opacity = j.opacity
                       						j:set{opacity = 50}
										end 	
									elseif i ~= odr then  
										j.extra.org_opacity = j.opacity
                       					j:set{opacity = 50}
								end 
							end 
						end
					end 
-----]]]] 

		    -- Debugging : 841 

					if v.type ~= "Text" then 
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
	    			end 
	    			org_object = util.copy_obj(v)
					if v.extra.lock == false then -- or v.name == "inspector" then 
        				dragging = {v, x - v.x, y - v.y }
					end
        			return true
				end
	    	elseif (input_mode == hdr.S_FOCUS) then 
				if (v.name ~= "inspector" and  v.name ~= "ui_element_insert") then 
		     		editor.selected(v)
		     		screen:find_child("text"..focus_type).text = v.name 
				end 
				input_mode = hdr.S_FOCUS
           		return true
            end
	   elseif( input_mode ~= hdr.S_RECTANGLE ) then 
			if v.extra.lock == false then --or v.name == inspector  then  
				dragging = {v, x - v.x, y - v.y }
           		return true
			end 
    	end
	end
end

	
	function v:on_button_up(x,y,button,num_clicks)
		if shift == true then 
			return 
		end 
		if (input_mode ~= hdr.S_RECTANGLE) then 
	   		if( v.name ~= "ui_element_insert" and v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw" ) then 
	    		if(input_mode == hdr.S_SELECT) and (screen:find_child("msgw") == nil) then
	    			if (v.extra.is_in_group == true) then 
						local p_obj = v.parent --find_parent(v)
						new_object = util.copy_obj(p_obj)
					    if(dragging ~= nil) then 
	            			local actor , dx , dy = unpack( dragging )
							if type(dx) == "number" then 
	            				new_object.position = {x-dx, y-dy}
							else 
								print("dx is function") 
							end 
							if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
								editor.n_select(v, false, dragging) 
								editor.n_select(new_object, false, dragging) 
								editor.n_select(org_object, false, dragging) 
                    			table.insert(undo_list, {p_obj.name, hdr.CHG, org_object, new_object})
							end 
	            			dragging = nil
	            		end 
		    		return true 
				elseif( input_mode ~= hdr.S_RECTANGLE) then  
	      	    	if(dragging ~= nil) then 
	       	       		local actor = unpack(dragging) 
		       			if (actor.name == "grip") then  -- scroll_window -> grip
							dragging = nil 
							return true 
		       			end 
	               		local actor , dx , dy = unpack( dragging )
		       			new_object = util.copy_obj(v)
	               		new_object.position = {x-dx, y-dy}
---[[ Content Setting 
		       			if util.is_in_container_group(x,y) then 
			     			local c, t = util.find_container(x,y) 
			     			if control == true then 
			       				if not util.is_this_container(v) or c.name ~= v.name then
			     					if c and t then 
				    					if (v.extra.selected == true and c.x < v.x and c.y < v.y) then 
			        						v:unparent()
											if t ~= "TabBar" then
			        							v.position = {v.x - c.x, v.y - c.y,0}
											end 
			        						v.extra.is_in_group = true
											if screen:find_child(v.name.."border") then 
			             						screen:find_child(v.name.."border").position = v.position
											end
											if screen:find_child(v.name.."a_m") then 
			             						screen:find_child(v.name.."a_m").position = v.position 
			        						end 
			        						if t == "ScrollPane" or t == "DialogBox" or  t == "ArrowPane" then 
			            						c.content:add(v) 
												v.x = v.x - c.content.x
												v.y = v.y - c.content.y
			        						elseif t == "LayoutManager" then 
				     							local col , row=  c:r_c_from_abs_position(x,y)
				     							c:replace(row,col,v) 
			        						elseif t == "TabBar" then 
												local x_off, y_off = c:get_offset()
												local t_index = c:get_index()

												if t_index then 
													v.x = v.x - x_off	
													v.y = v.y - y_off	
			            							c.tabs[t_index]:add(v) 
												end 
											elseif t == "Group" then 
												c:add(v)
			        						end 
			     	       				end 
				    				end 
			       				end 
								editor_lb:set_cursor(68)
								--[[
								mouse_pointer = CS_pointer
								mouse_pointer.position = {x ,y  ,0}
								if(screen:find_child("mouse_pointer") == nil) then 
		     						screen:add(mouse_pointer)
		     						mouse_pointer.extra.type = "pointer"
								end 
								]]
			     			end 
			     			if screen:find_child(c.name.."border") and selected_container then 
								screen:remove(screen:find_child(c.name.."border"))
								screen:remove(screen:find_child(c.name.."a_m"))
								screen:remove(screen:find_child(v.name.."border"))
								screen:remove(screen:find_child(v.name.."a_m"))
								selected_content = nil
								selected_container = nil
			    			end 
		       			end 
---]] Content Setting 
		       			for i,j in pairs (g.children) do 
			     			if j.extra then 
				   				if j.extra.org_opacity then 
									j.opacity = j.extra.org_opacity
				   				end 
			     			end 
		       			end 
	
		       			local border = screen:find_child(v.name.."border")
		       			local am = screen:find_child(v.name.."a_m") 
		       			local group_pos
	       	       		if(border ~= nil) then 
		             		if (v.extra.is_in_group == true) then
			     				group_pos = get_group_position(v)
			     				if group_pos then 
									if border then border.position = {x - dx + group_pos[1], y - dy + group_pos[2]} end
	                     				if am then am.position = {am.x + group_pos[1], am.y + group_pos[2]} end
								end
		             		else 
	                     		border.position = {x -dx, y -dy}
			     				if am then 
	                     			am.position = {x -dx, y -dy}
			     				end
		             		end 
	                	end 
			
						if screen:find_child("menuButton_view").items[12]["icon"].opacity > 0 then  
						    for i=1, v_guideline,1 do 
			   					if(screen:find_child("v_guideline"..i) ~= nil) then 
			     					local gx = screen:find_child("v_guideline"..i).x 
			     					if(15 >= math.abs(gx - x + dx)) then  
									    new_object.x = gx
										v.x = gx + screen:find_child("v_guideline"..i).w 
										if (am ~= nil) then 
			     	     						am.x = am.x - (x-dx-gx)
										end
			     					elseif(15>= math.abs(gx - x + dx - new_object.w)) then
										new_object.x = gx - new_object.w  
										v.x = gx - new_object.w 
										if (am ~= nil) then 
			     	     						am.x = am.x - (x-dx+new_object.w - gx)
										end
			     					end 
			   					end 
		        			end 
							for i=1, h_guideline,1 do 
			   					if(screen:find_child("h_guideline"..i) ~= nil) then 
			      					local gy =  screen:find_child("h_guideline"..i).y 
			      					if(15 >= math.abs(gy - y + dy)) then 
									    new_object.y = gy
										v.y =gy + screen:find_child("h_guideline"..i).h 
										if (am ~= nil) then 
			     	     						am.y = am.y - (y-dy - gy) 
										end
			      						elseif(15>= math.abs(gy - y + dy - new_object.h)) then
											new_object.y = gy - new_object.h
											v.y =  gy - new_object.h 
											if (am ~= nil) then 
			     	     						am.y = am.y - (y-dy + new_object.h - gy)  
											end
			      						end 
			   						end
								end
							end 
		        			if(border ~= nil )then 
			     				border.position = v.position
							end 
							if(org_object ~= nil) then  
		           				if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
			     					editor.n_select(v, false, dragging) 
			     					editor.n_select(new_object, false, dragging) 
			     					editor.n_select(org_object, false, dragging) 
			     					v.extra.org_x = v.x + g.extra.scroll_x + g.extra.canvas_xf
			     					v.extra.org_y = v.y + g.extra.scroll_y + g.extra.canvas_f 
                    	     		table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
			   					end
							end 
	            			dragging = nil
              	  		end
              	  		return true
	      			end 
             	end
	   		else 
	      		dragging = nil
          		return true
       		end
		end
	end
end

function util.get_group_position(child_obj)
     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	       if (v.type == "Group") then 
		    if(v:find_child(child_obj.name)) then
			return v.position 
		    end 
	       end 
          end
     end
end 
	
function util.set_obj (f, v)
      for i,j in pairs(hdr.attr_name_list) do 
           if v[j] then f[j] = v[j] end 
      end 
end 


function util.copy_obj (v)

      local new_map = {
	["Rectangle"] = function() new_obj = Rectangle{} return new_obj end, 
	["Text"] = function() new_obj = Text{} return new_obj end, 
	["Image"] = function() new_obj = Image{} return new_obj end, 
	["Clone"] = function() new_obj = Clone{} return new_obj end, 
	["Group"] = function() new_obj = Group{} return new_obj end, 
	["Video"] = function() new_obj = {} return new_obj end, 
      }
	
      local new_object = new_map[v.type]()

      util.set_obj(new_object, v)


      return new_object
end	


function util.make_attr_t(v)

  local attr_t
  local obj_type = v.type

  local function stringTotitle(str)
      local i,j = string.find(str,"_")
      if i then str = string.upper(str:sub(1,1))..str:sub(2,i-1).." "..string.upper(str:sub(i+1, i+1))..str:sub(i+2,-1)
      else str = string.upper(str:sub(1,1))..str:sub(2,-1)
      end

      i,j = string.find(str,"_") 
      if i then 
	    str = str:sub(1,i-1).." "..string.upper(str:sub(i+1, i+1))..str:sub(i+2,-1)
      end
	   
      if str == "Color" and v.type == "Rectangle" then 
          str = "Fill Color" 
      elseif str == "Color" and v.type == "Text" then 
          str = "Text Color" 
      elseif str == "Message Font" and v.extra.type == "ToastAlert" then 
          str = "Msg Font" 
      end 

      return str
  end

  local function stringToitem(str)
       local first = ""
       local second = ""
       local last

       local i, j = str:find("_")
       if i then 
       	first = str:sub(1,1)
       	last = str:sub(i+1,-1)
	i, j = last:find("_")
	if i then 
	    second = last:sub(1,1)
        end 
       end 
      
       return first..second
  end 

  local attr_map = {
	["tab_labels"] = function ()
		if v.extra.type == "TabBar" then 
		    table.insert(attr_t, {"tab_labels", v.tab_labels, "Tab Labels"})
		end
		end, 
	["items"] = function ()
		if v.extra.type == "ButtonPicker" then 
		    table.insert(attr_t, {"items", v.items, "Items"})
		else 
		    --table.insert(attr_t, {"caption", "Menu Contents"}) --0714
		    table.insert(attr_t, {"items", v.items, "Items"})
		end 
		end,
	["scale"] = function()
		table.insert(attr_t, {"caption", "Scale"})
		local scale_t = v.scale
        	if scale_t == nil then
             		scale_t = {1,1} 
        	end
        	table.insert(attr_t, {"x_scale", scale_t[1], "X"})
        	table.insert(attr_t, {"y_scale", scale_t[2], "Y"})
		end,
	["x_rotation"] = function()
 		table.insert(attr_t, {"caption", "Angle Of Rotation About"})
        	local x_rotation_t = v.x_rotation 
        	local y_rotation_t = v.y_rotation 
        	local z_rotation_t = v.z_rotation 
        	table.insert(attr_t, {"x_angle", x_rotation_t[1], "X"})
        	table.insert(attr_t, {"y_angle", y_rotation_t[1], "Y"})
        	table.insert(attr_t, {"z_angle", z_rotation_t[1], "Z"})
		end,  
       ["clip"] = function()
                table.insert(attr_t, {"caption", "Clipping Region"})
                local clip_t = v.clip
                if clip_t == nil then
                     clip_t = {0,0 ,v.w, v.h}
                end
                table.insert(attr_t, {"cx", clip_t[1], "X"})
                table.insert(attr_t, {"cy", clip_t[2], "Y"})
                table.insert(attr_t, {"cw", clip_t[3], "W"})
                table.insert(attr_t, {"ch", clip_t[4], "H"})
		end,
        ["anchor_point"] = function()	
 		table.insert(attr_t, {"anchor_point", v.anchor_point,"Anchor Point"})
		end,
	["src"] = function()
        	table.insert(attr_t, {"caption", "Source Location"})
        	table.insert(attr_t, {"src", v.src,"Source"})
		end,
	["icon"] = function()
        	table.insert(attr_t, {"caption", "Icon Source"})
        	table.insert(attr_t, {"icon", v.icon,"Icon"})
		end,
	["color"] = function(j)
		table.insert(attr_t, {"caption", stringTotitle(j)})
             	local color_t = v[j] 
             	if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	end
	     	table.insert(attr_t, {j.."r", color_t[1], "R"})
            table.insert(attr_t, {j.."g", color_t[2], "G"})
            table.insert(attr_t, {j.."b", color_t[3], "B"})
       	    table.insert(attr_t, {j.."a", color_t[4], "A"})    
		end,
	["size"] = function(j)
		table.insert(attr_t, {"caption", stringTotitle(j)})
             	local size_t = v[j] 
             	if size_t == nil then 
                 	size_t = {0,0}
	     	end
             	local size_k = ""
             	if j:sub(1,1) ~= "s" then
                 	size_k = j:sub(1,1) 
             	end 
	     	table.insert(attr_t, {size_k.."w", size_t[1], "W"})
             	table.insert(attr_t, {size_k.."h", size_t[2], "H"})
		end,
	["pos"] = function(j)
		table.insert(attr_t, {"caption", stringTotitle(j)})
             	local pos_t = v[j] 
             	if pos_t == nil then 
                 	pos_t = {0,0,0,0}
	     	end
             	local pos_k = ""
             	if j:sub(1,1) ~= "p" then 
                 	pos_k = j:sub(1,1) 
             	end 
	     	table.insert(attr_t, {pos_k.."x", pos_t[1], "X"})
            table.insert(attr_t, {pos_k.."y", pos_t[2], "Y"})
		end,
	["focus"]= function()
 		if v.extra.focus then 
 		     table.insert(attr_t, {"focus", v.extra.focus, "Focus"})
 		else 
 		     table.insert(attr_t, {"focus", {"1","2","3","4","5"}, "Focus"})
 		end 
 		end, 
	["label"]= function()
		if v.extra.type == "ToastAlert" then 
		     table.insert(attr_t, {"caption", "Title"})
		else 
		     table.insert(attr_t, {"caption", "Label"})
		end 
        	table.insert(attr_t, {"label", v.label,"Label"})
		end,
	["empty_top_color"] = function()
		     table.insert(attr_t, {"caption", "Empty Bar"})
		     local color_t = v.empty_top_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Top Color"})
	     	     table.insert(attr_t, {"empty_top_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"empty_top_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"empty_top_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"empty_top_color".."a", color_t[4], "A"})    
		     end,
	["empty_bottom_color"] = function()
		     local color_t = v.empty_bottom_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Bottom Color"})
	     	     table.insert(attr_t, {"empty_bottom_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"empty_bottom_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"empty_bottom_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"empty_bottom_color".."a", color_t[4], "A"})    
		     end,
	["filled_top_color"] = function()
		     table.insert(attr_t, {"caption", "Filled Bar"})
		     local color_t = v.filled_top_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Top Color"})
	     	     table.insert(attr_t, {"filled_top_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"filled_top_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"filled_top_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"filled_top_color".."a", color_t[4], "A"})    

		     end,
	["filled_bottom_color"] = function()
		     local color_t = v.filled_bottom_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Bottom Color"})
	     	     table.insert(attr_t, {"filled_bottom_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"filled_bottom_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"filled_bottom_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"filled_bottom_color".."a", color_t[4], "A"})   
		     end,
	["rows"] = function() 
                     table.insert(attr_t, {"rows", v.rows, "Rows"})
		     end,  	
	["visible_w"] = function ()
		     table.insert(attr_t, {"caption", "Visible"})
        	     table.insert(attr_t, {"visible_w", v.visible_w,"W"})
		     end, 
	["visible_h"] = function ()
        	     table.insert(attr_t, {"visible_h", v.visible_h,"H"})
		     end, 
	["virtual_w"] = function ()
		     table.insert(attr_t, {"caption", "Virtual"})
        	     table.insert(attr_t, {"virtual_w", v.virtual_w,"W"})
		     end, 
	["virtual_h"] = function ()
        	     table.insert(attr_t, {"virtual_h", v.virtual_h,"H"})
		     end, 
	["lock"]  = function ()
		     table.insert(attr_t, {"lock", v.extra.lock, "Lock"})
		     end,
	["font"] = function ()
             table.insert(attr_t, {"caption", "Font"})
			 table.insert(attr_t, {"font", v.font,"font"})
			 end,
	["text_font"] = function ()
             table.insert(attr_t, {"caption", "Text Font"})
			 table.insert(attr_t, {"text_font", v.text_font,"text_font"})
			 end,
	["message_font"] = function ()
             table.insert(attr_t, {"caption", "Message Font"})
			 table.insert(attr_t, {"message_font", v.message_font,"message_font"})
			 end,
	["title_font"] = function ()
             table.insert(attr_t, {"caption", "Title Font"})
			 table.insert(attr_t, {"title_font", v.title_font,"title_font"})
			 end,
  }
  
  local obj_map = {
       ["Rectangle"] = function() return {"border_color", "color", "border_width", "lock","x_rotation", "anchor_point", "opacity", "reactive", "focus"} end,
       ["Text"] = function() return {"color", "font", "wrap_mode", "lock", "x_rotation","anchor_point","opacity","reactive", "focus", } end,
       ["Image"] = function() return {"src", "clip","lock",  "x_rotation","anchor_point","opacity", "reactive", "focus",} end,
       ["Group"] = function() return {"lock", "scale","x_rotation","anchor_point","opacity", "reactive", "focus"} end,
       ["Clone"] = function() return {"lock", "scale","x_rotation","anchor_point","opacity", "reactive", "focus"} end,
       ["Button"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","reactive", "focus","label","border_color","fill_color", "focus_color","focus_fill_color","focus_text_color","text_color","text_font","border_width","border_corner_radius"} end,
       ["TextInput"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity", "reactive", "focus","border_color","fill_color", "focus_color","focus_fill_color","cursor_color","text_color","text_font","padding","border_width","border_corner_radius", "justify","single_line", "alignment", "wrap_mode"} end,
       ["ButtonPicker"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","reactive","focus","border_color","fill_color","focus_color","focus_fill_color","focus_text_color","text_color","text_font","direction","selected_item","items",} end,
       ["MenuButton"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity", "reactive","focus","label","border_color","fill_color","focus_color","focus_fill_color", "focus_text_color","text_color","text_font","border_width","border_corner_radius","menu_width","horz_padding","vert_spacing","horz_spacing","vert_offset","background_color","separator_thickness","expansion_location","items"} end,
       ["CheckBoxGroup"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","reactive", "focus","fill_color","focus_color","focus_fill_color","text_color","text_font","box_color","box_width","direction","box_size","check_size","line_space","b_pos", "item_pos","items", "selected_items"} end,
       ["RadioButtonGroup"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity", "reactive", "focus", "button_color","focus_color","text_color","select_color","text_font","direction","button_radius","select_radius","line_space","b_pos", "item_pos","items","selected_item"} end,

       ["TabBar"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","border_color","fill_color","focus_color","focus_fill_color", "focus_text_color","text_color", "label_color", "unsel_color","text_font","border_width","border_corner_radius", "font", "label_padding",  "tab_position", "display_width", "display_height",  "tab_labels", "arrow_sz", "arrow_dist_to_frame",} end,  
       ["ToastAlert"] = function() return {"lock", "skin","x_rotation", "anchor_point","opacity","icon","label","message","border_color","fill_color","title_color","title_font","message_color","message_font","border_width","border_corner_radius","on_screen_duration","fade_duration",} end,
       ["DialogBox"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","label","border_color","fill_color","title_color","title_font","border_width","border_corner_radius","title_separator_color","title_separator_thickness",} end,
       ["ProgressSpinner"] = function() return {"lock", "skin","style","x_rotation","anchor_point","opacity","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time", } end,
       ["ProgressBar"] = function() return {"lock", "skin","x_rotation","anchor_point", "opacity","border_color","empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","progress"} end,
       ["LayoutManager"] = function() return {"lock", "skin","x_rotation","anchor_point", "opacity","rows","columns","cell_size","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable",} end,
       ["ScrollPane"] = function() return {"lock", "skin", "visible_w", "visible_h",  "virtual_w", "virtual_h","opacity", "bar_color_inner", "bar_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness", "frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "horz_bar_visible", "box_color", "box_width"} end,  
       ["ArrowPane"] = function() return {"lock", "skin","visible_w", "visible_h",  "virtual_w", "virtual_h","opacity", "arrow_sz", "arrow_dist_to_frame", "arrows_visible", "arrow_color","box_color", "box_width"} end,  
   }
  
  if util.is_this_widget(v) == true  then
       obj_type = v.extra.type
	attr_t =
      {
             {"title", "Inspector : "..(v.extra.type)},
             {"caption", "Object Name"},
             {"name", v.name,"name"},
             {"x", math.floor(v.x + g.extra.scroll_x + g.extra.canvas_xf) , "X"},
             {"y", math.floor(v.y + g.extra.scroll_y + g.extra.canvas_f), "Y"},
             {"z", math.floor(v.z), "Z"},
      }
       if (v.extra.type ~= "ProgressSpinner" and v.extra.type ~= "LayoutManager" and v.extra.type ~= "ScrollPane" and v.extra.type ~= "MenuBar" ) and v.extra.type ~= "ArrowPane" and  v.extra.type ~= "CheckBoxGroup" and  v.extra.type ~= "RadioButtonGroup" then 
             table.insert(attr_t, {"ui_width", math.floor(v.ui_width), "W"})
             table.insert(attr_t, {"ui_height", math.floor(v.ui_height), "H"})
       end

  elseif v.type ~= "Video" then  --Rectangle, Image, Text, Group, Clone
	attr_t =
      {
             {"title", "Inspector : "..(v.type)},
             {"caption", "Object Name"},
             {"name", v.name,"name"},
             {"x", math.floor(v.x + g.extra.scroll_x + g.extra.canvas_xf) , "X"},
             {"y", math.floor(v.y + g.extra.scroll_y + g.extra.canvas_f), "Y"},
             {"z", math.floor(v.z), "Z"},
             {"w", math.floor(v.w), "W"},
             {"h", math.floor(v.h), "H"},
      }

  else -- Video 
      attr_t =
      {
             {"title", "Inspector : "..(v.type)},
             {"caption", "Object Name"},
             {"name", v.name,"name"},
             {"caption", "Source"},
             {"source", v.source, "Source Location"},
             {"caption", "View Port"},
             {"left", math.floor(v.viewport[1]), "X"},
             {"top", math.floor(v.viewport[2]), "Y"},
             {"width", math.floor(v.viewport[3]), "W"},
             {"height", math.floor(v.viewport[4]), "H"},
             {"volume", v.volume, "Volume"},
             {"loop", v.loop, "Loop"},
             {"button", "view code", "View code"},
             {"button", "apply", "OK"},
             {"button", "cancel", "Cancel"},
      }
      return attr_t 
  end 
  
  for i,j in pairs(obj_map[obj_type]()) do 
		
	if (j == "message") then 
	--print (j)
	end 
       	if attr_map[j] then
             attr_map[j](j)
        elseif type(v[j]) == "number" then 
	     if j ~= "progress" then 
                 table.insert(attr_t, {j, math.floor(v[j]), stringTotitle(j)})
	     else 
                 table.insert(attr_t, {j, v[j], stringTotitle(j)})
	     end
	elseif type(v[j]) == "string" then 
	     if j == "message" then 
             table.insert(attr_t, {"caption", stringTotitle(j)})
	     end 
             table.insert(attr_t, {j, v[j], stringTotitle(j)})
	elseif type(v[j]) == "boolean" then 
	     if j == "reactive" then 
		  if v.extra.reactive ~= nil then 
                       table.insert(attr_t, {j, v.extra.reactive, stringTotitle(j)})
		  else 
                       table.insert(attr_t, {j, true, stringTotitle(j)})
		  end 
	     else 
                  table.insert(attr_t, {j, v[j], stringTotitle(j)})
	     end 
	elseif string.find(j,"color") then
             attr_map["color"](j)
	elseif string.find(j,"size") then
             attr_map["size"](j)
	elseif string.find(j,"pos") then
             attr_map["pos"](j)
	elseif j == "hor_arrow_y"or j == "vert_arrow_x" then 
           table.insert(attr_t, {j, "nil", stringTotitle(j)})
	elseif j == "selected_items" then 
		   local selected_items_str = ""

		   for _, i in pairs(v[j]) do 
				if i then 
		        	selected_items_str = selected_items_str..tostring(i)..","
				end 
		   end 
           table.insert(attr_t, {j, selected_items_str, stringTotitle(j)})
	else
	     print("make_attr_t() : ", j, " 처리해 주세용~ ~")
	end 
   end 
 
   --table.insert(attr_t, {"opacity", v.opacity, "Opacity"})
   table.insert(attr_t, {"button", "view code", "View code"})
   table.insert(attr_t, {"button", "apply", "OK"})
   table.insert(attr_t, {"button", "cancel", "Cancel"})
   
   return attr_t
end

local input_t

function util.itemTostring(v, d_list, t_list)
    local itm_str  = ""
    local itm_str2 = ""
    local indent   = "\n\t\t"
    local b_indent = "\n\t"

    local w_attr_list =  {"ui_width","ui_height","skin","style","label","button_color","focus_color","text_color","text_font","border_width","border_corner_radius","reactive","border_color","padding","fill_color","title_color","title_font","title_separator_color","title_separator_thickness","icon","message","message_color","message_font","on_screen_duration","fade_duration","items","selected_item","selected_items","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time","empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","progress","rows","columns","cell_size","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable","visible_w", "visible_h",  "virtual_w", "virtual_h", "bar_color_inner", "bar_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness", "frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "horz_bar_visible", "box_color", "box_width","menu_width","horz_padding","vert_spacing","horz_spacing","vert_offset","background_color","separator_thickness","expansion_location","direction", "f_color","box_size","check_size","line_space", "b_pos", "item_pos","select_color","button_radius","select_radius","tiles","content","text", "focus_fill_color", "focus_text_color","cursor_color", "ellipsize", "label_padding", "tab_position", "display_width", "display_height", "tab_spacing", "label_color", "unsel_color", "arrow_sz", "arrow_dist_to_frame", "arrows_visible", "arrow_color", "tab_labels", "tabs", "wrap_mode", "wrap", "justify", "alignment", "single_line" }

    local nw_attr_list = {"color", "border_color", "border_width", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "position", "size", "opacity", "children","reactive","cursor_visible"}

    local group_list = {"name", "position", "scale", "anchor_point", "x_rotation", "y_rotation", "z_rotation", "opacity"}

    local widget_map = {
	["Button"] = function () return "ui_element.button"  end, 
	["TextInput"] = function () return "ui_element.textInput" end, 
	["DialogBox"] = function () return "ui_element.dialogBox" end, 
	["ToastAlert"] = function () return "ui_element.toastAlert" end,   
	["RadioButtonGroup"] = function () return "ui_element.radioButtonGroup" end, 
	["CheckBoxGroup"] = function () return "ui_element.checkBoxGroup"  end, 
	["ButtonPicker"] = function () return "ui_element.buttonPicker"  end, 
	["ProgressSpinner"] = function () return "ui_element.progressSpinner" end, 
	["ProgressBar"] = function () return "ui_element.progressBar" end,
	["LayoutManager"] = function () return "ui_element.layoutManager" end,
	["ScrollPane"] = function () return "ui_element.scrollPane" end, 
	["ArrowPane"] = function () return "ui_element.arrowPane" end, 
	["TabBar"] = function () return "ui_element.tabBar" end, 
	["MenuButton"] = function () return "ui_element.menuButton" end, 
   }

   local function add_attr (list, head, tail) 
       local item_string =""
       for i,j in pairs(list) do 
          if v[j] ~= nil then 
	      --if j == "src" and v.type == "Image" then 
		  --item_string = item_string..head..j.." = \"assets\/images\/"..v[j].."\""..tail
	      if j == "position" then 
		  item_string = item_string..head..j.." = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."}"..tail
	      elseif j == "children" then 
                  local children = ""
		  for k,l in pairs(v.children) do
		      if (l ~= nil) then 
		      if k == 1 then
		         children = children..l.name
		      else 
		         children = children..","..l.name
		      end
		      end 
                  end 
		  item_string = item_string..head.."children = {"..children.."}"..tail
	      elseif j == "tab_labels" then 
		  	  local items = ""
		  	  for i,j in pairs(v.tab_labels) do 
				   items = items.."\""..j.."\", "
		  	  end
    		  item_string = item_string..head.."tab_labels = {"..items.."}"..tail
	      elseif j == "items" then 
		  local items = ""
		  if v.extra.type == "MenuButton" then 
		  	for i,j in pairs(v.items) do 
				items = items.."\t\t\t{type=\""..j["type"].."\","
				if j["string"] then 
					items = items.." string=\""..j["string"].."\","
				end
				if j["type"] == "item" then 
					items = items.." f=nil"
				end
				items = items.."},\n"
		  	end
    		  	item_string = item_string..head.."items = {\n"..items.."\t\t}"..tail
		  else 
		  	for i,j in pairs(v.items) do 
				items = items.."\""..j.."\", "
		  	end
    		  	item_string = item_string..head.."items = {"..items.."}"..tail
		  end 
	      elseif type(v[j]) == "number" then 
	          item_string = item_string..head..j.." = "..v[j]..tail 
	      elseif type(v[j]) == "string" then 
	          item_string = item_string..head..j.." = \""..v[j].."\""..tail 
	      elseif type(v[j]) == "boolean" then 
		  if j == "reactive" then 
		       if v.extra.reactive == nil then 
				v.extra.reactive = true
		       end 
		       item_string = item_string..head..j.." = "..tostring(v.extra.reactive)..tail
		  else 
	               item_string = item_string..head..j.." = "..tostring(v[j])..tail 
		  end 
	      elseif type(v[j]) == "table" then 
		  		if v.extra.type == "TabBar" and j == "tabs" then 
					item_string = item_string..head..j.."= {"
					for q,w in pairs (v[j]) do
						item_string = item_string.." Group{ children = {"
						for m,n in pairs (w.children) do
							item_string = item_string .. n.name..","
						end 
						item_string = item_string.."}},"
					end 
					item_string = item_string.."}"..tail
		  		elseif(type(v[j][1]) == "table") then  
					local tiles_name_table = {} 
					for m=1, v.rows, 1 do -- rows
						local tile_name_table = {}
						for i= 1,v.columns,1 do  --cols 
				   			local element = v.tiles[m][i]
				   			if element then 
				     			table.insert(tile_name_table, element.name)
				   			else 
				     			table.insert(tile_name_table, "nil")
				   			end 
						end 
		        		if table.getn(tile_name_table) ~= 0 then 
							table.insert(tiles_name_table, tile_name_table)
						end
					end 
	          		item_string = item_string..head..j.." = {"
					for m,n in pairs(tiles_name_table) do 
	          			item_string = item_string.." {"..table.concat(n,",").."},"
					end 
					item_string = item_string.."}"..tail
		  		else
	          		item_string = item_string..head..j.." = {"..table.concat(v[j],",").."}"..tail
		  		end 
	      elseif v[j].type == "Group" then 
				if is_this_widget(v[j]) == true then 
		        	item_string = item_string..head..j.."= "..v[j].name..tail
				else 
		        	item_string = item_string..head..j.."= Group { children = {"
					for m,n in pairs (v[j].children) do
						item_string = item_string .. n.name..","
					end 
					item_string = item_string.."} }"..tail
				end 
	      elseif type(v[j]) == "userdata" then 
		  item_string = item_string..head..j.." = "..v[j].name..tail 
	      else
	          print("--", j, " 처리해 주세용 ~")
	      end 
	  end 
       end 
       return item_string
    end 
  
 
    if (v.type == "Text") then
		v.cursor_visible = false
    elseif (v.type == "Image") then
		--if (v.clip == nil) then v.clip = {0, 0,v.w, v.h} end 
    elseif (v.type == "Clone") then
	 	src = v.source 
		if src ~= nil then 
	 		if util.is_in_list(src.name, d_list) == false then 
	     		if(t_list == nil) then 
					t_list = {src.name}
	     		else 
					table.insert(t_list, src.name) 
	     		end
        	end 
        end 
    elseif (v.type == "Group") and util.is_this_widget(v) == false then 
	 	local org_d_list = {}

	 	if(d_list ~= nil) then 
	     	for i,j in pairs (d_list) do 
		 		org_d_list[i] = j 
	     	end      
	 	end 

        for e in values(v.children) do
	     	result, done_list, todo_list, result2 = util.itemTostring(e, d_list, t_list)
	     	if(result ~= nil) then 
		 		itm_str = itm_str..result
	     	end
	     	if(result2 ~= nil) then 
		 		itm_str2 = result2..itm_str2
	     	end 
			
	     	d_list = done_list
	     	t_list = todo_list
	 	end
    end

    if (v.type == "Video") then
  	 itm_str = itm_str.."\nlocal "..v.name.." = ".."{"..indent..
         "name=\""..v.name.."\","..indent..
         "type=\""..v.type.."\","..indent..
         "source=\""..v.source.."\","..indent..
         "viewport={"..table.concat(v.viewport,",").."},"..indent..
         "loop = "..tostring(v.loop)..","..indent..
         "volume = "..v.volume..b_indent.."}\n"..b_indent

	 itm_str = itm_str.."mediaplayer:load("..v.name..".source)"..b_indent..
	 "mediaplayer.on_loaded = function(self) self:play() end"..b_indent..
	 "if ("..v.name..".loop == true) then"..b_indent..
     	 "     mediaplayer.on_end_of_stream = function(self) self:seek(0) self:play() end"..b_indent..
	 "else"..b_indent..
	 "     mediaplayer.on_end_of_stream = function(self) self:seek(0) end"..b_indent..
	 "end"..b_indent..
	 "mediaplayer:set_viewport_geometry("..v.name..".viewport[1], "..v.name..".viewport[2], "..v.name..".viewport[3], "..v.name..".viewport[4])"..b_indent..
	 "mediaplayer.volume = "..v.name..".volume\n\n"
	 itm_str = itm_str.."g.extra.video = "..v.name.."\n\n"

    elseif util.is_this_widget(v) == true then 	 
	 	if v.content then 
	    	for m,n in pairs (v.content.children) do
				itm_str= util.itemTostring(n) .. itm_str
	    	end 
	 	end 
	 	if v.tiles then 
	    	for m,n in pairs(v.tiles) do 
	          	for q,r in pairs(n) do 
					if r.name ~= "nil" then
		            	itm_str= util.itemTostring(r)..itm_str
					end 
	          	end 
	     	end 
	 	end 
	 	if v.tabs then 
	    	for q,w in pairs (v.tabs) do
	    		for m,n in pairs (w.children) do
					itm_str= util.itemTostring(n) .. itm_str
	    		end 
	    	end 
	 	end 
		
		if v.extra.type == "ScrollPane" or v.extra.type == "ArrowPane" then 
        	itm_str = itm_str.."\n"..v.name.." = "..widget_map[v.extra.type]()..b_indent.."{"..indent
		else 
        	itm_str = itm_str.."\nlocal "..v.name.." = "..widget_map[v.extra.type]()..b_indent.."{"..indent
		end 
	 	itm_str = itm_str..add_attr(w_attr_list, "", ","..indent)
	 	itm_str = itm_str:sub(1,-2)
        itm_str = itm_str.."}\n\n"
	 	itm_str = itm_str..add_attr(group_list, v.name..".", "\n")
    else 
         itm_str = itm_str.."\nlocal "..v.name.." = "..v.type..b_indent.."{"..indent
	 	 itm_str = itm_str..add_attr(nw_attr_list, "", ","..indent)
	 	 itm_str = itm_str:sub(1,-2)
         itm_str = itm_str.."}\n\n"
    end

    if v.extra then 
    if v.extra.focus then 
		
		local scroll_seek_to_line = ""
		for i, c in pairs(g.children) do
			if v.name == c.name then 
				break
			else 
				if c.extra then 
					if c.extra.type == "ScrollPane" or c.extra.type == "ArrowPane" then 
						for k, e in pairs (c.content.children) do 
							if e.name == v.name then 
								scroll_seek_to_line = "\t"..c.name..".seek_to_middle(0,screen:find_child("..v.name..".focus[key]).y)\n\t\t\t" 
							end 
						end 
					end 
				end
			end
    	end

		local focus_map = {["65362"] = function() return "keys.Up" end, 
						   ["65364"] = function() return "keys.Down" end, 
						   ["65361"] = function() return "keys.Left" end, 
						   ["65363"] = function() return "keys.Right" end, 
						   ["65293"] = function() return "keys.Return" end, 
						  }

		itm_str = itm_str..v.name.."\.extra\.focus = {" 
		for m,n in pairs (v.extra.focus) do 
			if type(n) ~= "function" then 
		     	itm_str = itm_str.."["..focus_map[tostring(m)]().."] = \""..n.."\", " 
			end 
		end 
		itm_str = itm_str.."}\n\n"

		itm_str = itm_str.."function "..v.name..":on_key_down(key)\n\t"
		.."if "..v.name..".focus[key] then\n\t\t" 
		.."if type("..v.name..".focus[key]) == \"function\" then\n\t\t\t"
		..v.name..".focus[key]()\n\t\t"
		.."elseif screen:find_child("..v.name..".focus[key]) then\n\t\t\t"
		.."if "..v.name..".on_focus_out then\n\t\t\t\t"
		..v.name..".on_focus_out(key)\n\t\t\t".."end\n\t\t\t" -- on_focus_out
		.."screen:find_child("..v.name..".focus[key]):grab_key_focus()\n\t\t\t"
		.."if ".."screen:find_child("..v.name..".focus[key]).on_focus_in then\n\t\t\t\t"
        .."screen:find_child("..v.name..".focus[key]).on_focus_in(key)\n\t\t\t"..scroll_seek_to_line.."end\n\t\t\t"
		.."end\n\t"
		.."end\n\t"
		.."return true\n"
        .."end\n\n"
    end 

    if v.extra.reactive ~= nil then 
	itm_str = itm_str..v.name.."\.extra\.reactive = "..tostring(v.extra.reactive).."\n\n" 
    end 

    if v.extra.timeline then 
	    itm_str = itm_str..v.name.."\.extra\.timeline = {" 
	    for m,n in pairs (v.extra.timeline) do 
	         itm_str = itm_str.."["..m.."] = { \n"
	         for q,r in pairs (n) do
	             itm_str = itm_str.."[\""..q.."\"] = "
		     if type(r) == "table" then 
		          itm_str = itm_str.."{"
		          for s,t in pairs (r) do
			      itm_str = itm_str..t..","
		          end 
		          itm_str = itm_str.."},"
		     else 
		          itm_str = itm_str..tostring(r).."," 
		     end
	         end
	         itm_str = itm_str.."},\n"
	    end 
	    itm_str = itm_str.."}\n\n"
    end 

    if v.extra.type == "ButtonPicker" then 
		if v.extra.focus then 
	   		if v.extra.direction == "vertical" then 
	    		itm_str = itm_str..v.name..".focus[keys.Down] = "..v.name..".press_down\n"
	    		itm_str = itm_str..v.name..".focus[keys.Up] = "..v.name..".press_up\n"
			else 
	    		itm_str = itm_str..v.name..".focus[keys.Right] = "..v.name..".press_right\n"
	    		itm_str = itm_str..v.name..".focus[keys.Left] = "..v.name..".press_left\n"
			end
		end
    end

    end -- if v.extra then 

    if(d_list == nil) then  
	d_list = {v.name}
    else 
        table.insert(d_list, v.name) 
    end 


    -- 만약 문제가 된다면 Clone일 경 아래 조건문은 빼세요    
    if util.is_in_list(v.name, t_list) == true  then 
	return "", d_list, t_list, itm_str
    end 

    return itm_str, d_list, t_list, itm_str2
end

return util
