dofile("util.lua") 

local factory = ui.factory


local check_number_val = function(val, name)
	if tonumber(val) == nil then 
		return -1 
	end 
end

local number_attrs = { "x", "y", "z", "w", "h", "opacity", "button_radius", "select_radius", "line_space", "volume", "ui_width", "ui_height", "border_width", "border_corner_radius", "on_screen_duration", "fade_duration", "padding", "label_padding", "display_width", "display_height", "arrow_sz", "arrow_dist_to_frame", "visible_w", "visible_h", "virtual_w", "virtual_h", "frame_thickness", "bar_thickness", "bar_offset", "box_width", "overall_diameter", "dot_diameter", "number_of_dots", "cycle_time", "progress", "menu_width", "horz_padding", "vert_spacing", "horz_spacing", "vert_offset", "separator_thickness", "rows", "columns", "cell_w", "cell_h", "cell_spacing", "cell_timing", "cell_timing_offset", "title_separator_thickness",
} 

local reserved_words = {"and", "end", "break", "do" ,"else", "elseif", "false", "for", "function", "if", "in",
"local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"}


function inspector_apply (v, inspector)

      local org_object, new_object, item_group 
      local function toboolean(s) if (s == "true") then return true else return false end end
      local obj_map = {
		["Rectangle"] = function() org_obj = Rectangle{} new_obj = Rectangle{} return org_obj, new_obj end, 
		["Text"] = function() org_obj = Text{} new_obj = Text{} return org_obj, new_obj end, 
		["Image"] = function() org_obj = Image{} new_obj = Image{} return org_obj, new_obj end, 
		["Clone"] = function() org_obj = Clone{} new_obj = Clone{} return org_obj, new_obj end, 
		["Group"] = function() org_obj = Group{} new_obj = Group{} return org_obj, new_obj end, 
		["Video"] = function() org_obj = {} new_obj = {} return org_obj, new_obj end, 
      }

      local rgba_map = {["r"] = 1, ["g"] = 2, ["b"] = 3, ["a"] = 4,}  

      local attr_map = {
      		["itemsList"] = function(j)
         	local items, item
		 	if item_group:find_child("itemsList") then 
		    	if item_group:find_child("itemsList"):find_child("items_list") then 
		        	items = item_group:find_child("itemsList"):find_child("items_list")
		    	end 
         	end 
		 	if items then 
               local next = 1
               for next, _ in pairs(items.tiles) do 
		       		item = items.tiles[next][1]
		       		if v.extra.type == "ButtonPicker" or v.extra.type == "CheckBoxGroup" or v.extra.type == "RadioButtonGroup" then 
		            	v.items[next] = item:find_child("textInput").text
		       		elseif v.extra.type == "TabBar" then 
		            	v.tab_labels[next] = item:find_child("textInput").text
					elseif v.extra.type == "MenuButton" then 
	 	       			if item:find_child("textInput").text == "--------------" then 
			    			v.items[next] = {type="separator"}
						else 
							local pp = item:find_child("textInput").parent
		       				if pp.item_type == "label" then 
			    				v.items[next] = {type="label", string=item:find_child("textInput").text}
		       				elseif pp.item_type == "item" then 
			    				v.items[next] = {type="item", string=item:find_child("textInput").text, f=nil}
							end 
		       			end 
		       		end 
               end 
		       if v.extra.type == "TabBar" then 
		       		v.tab_labels = v.tab_labels
			   else 
			   		v.items = v.items -- to redraw item lists 
			   end 
		 	end
         end,
       	["skin"] = function()
              v["skin"] = hdr.inspector_skins[tonumber(item_group:find_child("skin"):find_child("item_picker").selected_item)]
              end,
       	["anchor_point"] = function()
               v:move_anchor_point(item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	      		item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
              end,     
		["alignment"] = function()
	      	  local itemLists = {"left", "center", "right", }

              v.alignment = string.upper(itemLists[tonumber(item_group:find_child("alignment"):find_child("item_picker").selected_item)])
              end,     
       	["wrap_mode"] = function()
	      	local itemLists = {"none", "char", "word", "word_char"}
	      	if tonumber(item_group:find_child("wrap_mode"):find_child("item_picker").selected_item) == 1 then 
		   		v.wrap = false
                v.wrap_mode = "CHAR"
	      	else 
		   		v.wrap = true
                v.wrap_mode = string.upper(itemLists[tonumber(item_group:find_child("wrap_mode"):find_child("item_picker").selected_item)])
	      	end 
            end,        
       	["bwidth"] = function()
            --v.border_width = tonumber(item_group:find_child("bwidth"):find_child("input_text").text)
			if check_number_val(item_group:find_child("bwidth"):find_child("input_text").text, "bwidth") then 
			     editor.error_message("011","bwidth",nil,nil,inspector)
			     return -1 
			else 
                   v.border_width = tonumber(item_group:find_child("bwidth"):find_child("input_text").text)
			end
            end,
       	["color"] = function(name)
	      	local attr_name = "color"
	      	if string.len(name) > 1 then 
	           	attr_name = name:sub(1,-2)
	      	end 
	      	local color_t = {}
	      	color_t = v[attr_name]

	      	--color_t[rgba_map[string.sub(name,-1, -1)]] = tonumber(item_group:find_child(name):find_child("input_text").text)
		  	if check_number_val(item_group:find_child(name):find_child("input_text").text, name) then 
			  	editor.error_message("011",name,nil,nil,inspector)
			  	return -1
		  	else 
	      			color_t[rgba_map[string.sub(name,-1, -1)]] = tonumber(item_group:find_child(name):find_child("input_text").text)
		  	end 

	      	v[attr_name] = color_t
	      	end,
       	["hor_arrow_y"] = function()
	       	-- v.hor_arrow_y = tonumber(item_group:find_child("hor_arrow_y"):find_child("input_text").text)
			if tonumber(item_group:find_child("hor_arrow_y"):find_child("input_text").text) then 
	       		v.hor_arrow_y = tonumber(item_group:find_child("hor_arrow_y"):find_child("input_text").text)
			else 
			    editor.error_message("011","hor_arrow_y",nil,nil,inspector)
				return -1 
			end 
			end, 
       	["vert_arrow_x"] = function()
	       	--v.ver_arrow_x = tonumber(item_group:find_child("vert_arrow_x"):find_child("input_text").text)
			if tonumber(item_group:find_child("vert_arrow_y"):find_child("input_text").text) then 
	       		v.ver_arrow_x = tonumber(item_group:find_child("vert_arrow_x"):find_child("input_text").text)
			else 
			    editor.error_message("011","vert_arrow_y",nil,nil,inspector)
				return -1 
			end 

			end,
       	["reactive"] = function()
	       if item_group:find_child("bool_checkreactive"):find_child("check1").opacity > 0 then 
	            v.extra.reactive = true
	       else 
	            v.extra.reactive = false
	       end
	       end,
       	["loop"] = function()
	       if item_group:find_child("bool_checkloop"):find_child("check1").opacity > 0 then 
	            v.loop = true
	       else 
	            v.loop = false
	       end
	       end,
		["vert_bar_visible"] = function()
	       if item_group:find_child("bool_checkvert_bar_visible"):find_child("check1").opacity > 0 then 
	            v.vert_bar_visible = true
	       else 
	            v.vert_bar_visible = false
	       end
	       end,

		["horz_bar_visible"] = function()
 	       if item_group:find_child("bool_checkhorz_bar_visible"):find_child("check1").opacity > 0 then 
	            v.horz_bar_visible = true
	       else 
	            v.horz_bar_visible = false
	       end
	       end,

		["lock"] = function()
 	       if item_group:find_child("lock"):find_child("check1").opacity > 0 then 
	            v.extra.lock = true
		    if v.type == "Group" then 
			for i,j in pairs (v.children) do 
				j.extra.lock = true
			end 
		    end 
	       else 
	            v.extra.lock = false
		    if v.type == "Group" then 
			for i,j in pairs (v.children) do 
				j.extra.lock = false
			end 
		    end 

	       end
	       end,
		["justify"] = function()
 	       if item_group:find_child("justify"):find_child("check1").opacity > 0 then 
	            v.justify = true
	       else 
	            v.justify = false
	       end
	       end,
		["single_line"] = function()
 	       if item_group:find_child("single_line"):find_child("check1").opacity > 0 then 
	            v.single_line = true
	       else 
	            v.single_line = false
	       end
	       end,

		["cells_focusable"] = function()
 	       if item_group:find_child("bool_checkcells_focusable"):find_child("check1").opacity > 0 then 
	            v.cells_focusable = true
	       else 
	            v.cells_focusable = false
	       end
	       end,
		["tab_position"] = function()
			  local itemLists = {"top", "right"} 
              v["tab_position"] = itemLists[tonumber(item_group:find_child("tab_position"):find_child("item_picker").selected_item)]
			end,
		["expansion_location"] = function()
			  local itemLists = {"above", "below"} 
              v["expansion_location"] = itemLists[tonumber(item_group:find_child("expansion_location"):find_child("item_picker").selected_item)]
			end,
		["direction"] = function()
			  local itemLists = {"vertical", "horizontal"}
              v["direction"] = itemLists[tonumber(item_group:find_child("direction"):find_child("item_picker").selected_item)]
			end,
		
		["style"] = function()
			  local itemLists = {"orbitting", "spinning"}
              v["style"] = itemLists[tonumber(item_group:find_child("style"):find_child("item_picker").selected_item)]
			end,
		["cell_size"] = function()
			  local itemLists = {"fixed", "variable"}
              v["cell_size"] = itemLists[tonumber(item_group:find_child("cell_size"):find_child("item_picker").selected_item)]
			end,
		["icon"] = function()
			   local img_tmp = tostring(item_group:find_child("icon"):find_child("file_name").text)
			   local a, b = string.find(img_tmp,"assets/images/")

			   if a == nil then 
			   	a, b = string.find(img_tmp,"lib/assets/")
			   end 

			   if a then 
               		v.icon = tostring(item_group:find_child("icon"):find_child("file_name").text)
			   else 
               		v.icon = "assets/images/"..tostring(item_group:find_child("icon"):find_child("file_name").text)
			   end 
	       end,
		["source"] = function()
               local img_tmp = tostring(item_group:find_child("source"):find_child("file_name").text)
			   local a, b = string.find(img_tmp, "assets/videos/")
			   if a then
               		v.source = tostring(item_group:find_child("source"):find_child("file_name").text)
			   else 
               		v.source = "assets/videos/"..tostring(item_group:find_child("source"):find_child("file_name").text)
			   end 
	       end,
		["src"] = function()
               local img_tmp = tostring(item_group:find_child("src"):find_child("file_name").text)
			   local a, b = string.find(img_tmp, "assets/images/")
			   if a then
               		v.src = tostring(item_group:find_child("src"):find_child("file_name").text)
			   else 
               		v.src = "assets/images/"..tostring(item_group:find_child("src"):find_child("file_name").text)
			   end 
	       end,
		["name"] = function ()
		--[[
	       if v.extra then 
	        	v.extra.prev_name = v.name  
	       end 
	       v.name = tostring(item_group:find_child("name"):find_child("input_text").text)
		  ]]
		  	   if v.extra then 
		        	v.extra.prev_name = v.name  
	    	   end 

			   local name_val =  tostring(item_group:find_child("name"):find_child("input_text").text) 
			   local name_format = "[%u%l_]+[%w_]*"
			   local a, b = string.find(name_val, name_format) 
			   if a and a == 1 and b == string.len(name_val) then 
					for q, w in pairs (reserved_words) do 
						if w == name_val then 
							 editor.error_message("012","name",nil,nil,inspector)
							 return -1 
						end 
					end 
	       	   		v.name = tostring(item_group:find_child("name"):find_child("input_text").text)
			   else 
			        editor.error_message("012","name",nil,nil,inspector)
					return -1 
			   end

	       end, 
		["selected_items"] = function () 
		--[[
		    local items_str = tostring(item_group:find_child("selected_items"):find_child("input_text").text)
		    local items_tbl = {}
		    local items_idx = 1
		    while items_str ~= ""  do 
		   		local i,j = string.find(items_str, ",")
		   		if i then 
						table.insert(items_tbl, tonumber(string.sub(items_str, items_idx, i-1)))
						items_str = string.sub(items_str, j+1, -1) 
				else 
					 if tonumber(items_str) then 
						table.insert(items_tbl, tonumber(items_str))
						items_str = ""
					 end 
				end 
		    end 
			v.extra.selected_items = items_tbl 
			]]

			local items_str = tostring(item_group:find_child("selected_items"):find_child("input_text").text)
		    local items_tbl = {}
		    local items_idx = 1

		    while items_str ~= ""  do 
		   		local i,j = string.find(items_str, ",")
		   		if i then 
						if  tonumber(string.sub(items_str, items_idx, i-1)) then
							if tonumber(string.sub(items_str, items_idx, i-1)) > #v.items then 
			        			editor.error_message("012","selected_items",nil,nil,inspector)
								return -1 
							else 
								table.insert(items_tbl, tonumber(string.sub(items_str, items_idx, i-1)))
								items_str = string.sub(items_str, j+1, -1) 
							end 
						else 
			        		editor.error_message("012","selected_items",nil,nil,inspector)
							return -1 
						end 
				else 
					 if tonumber(items_str) then 
						if tonumber(items_str) > #v.items then 
			        		editor.error_message("012","selected_items",nil,nil,inspector)
							return -1 
						else
							table.insert(items_tbl, tonumber(items_str))
							items_str = ""
						end
					 else 
			        	editor.error_message("012","selected_items",nil,nil,inspector)
						return -1 
					 end 
				end 
		    end 
				v.extra.selected_items = items_tbl 

			end 

      }       
	  
      org_object, new_object = obj_map[v.type]()
      util.set_obj(org_object, v) 

	  local apply = function (item_group) 
	  	local inspector_deactivate = function ()
			local rect = Rectangle {name = "deactivate_rect", color = {10,10,10,100}, size = {300,400}, position = {0,0}, reactive = true}
			inspector:add(rect)
		end 

      	for i, j in pairs(item_group.children) do 
          	  
	      if j.name then
		 	if j.name ~= "anchor_point" and j.name ~= "reactive" and j.name ~= "focusChanger" and j.name ~= "src" and j.name ~= "source" and j.name ~= "loop" and j.name ~= "skin" and j.name ~= "wrap_mode" and j.name ~= "items" and j.name ~= "itemsList" and j.name ~= "icon" and j.name ~= "items" and j.name ~= "expansion_location" and j.name ~= "tab_position" and j.name ~= "style" and j.name ~= "cell_size" and j.name ~= "vert_bar_visible" and j.name ~= "horz_bar_visible" and j.name ~= "cells_focusable" and j.name ~= "lock" and j.name ~="direction" and j.name ~= "justify" and j.name ~= "alignment" and j.name ~= "single_line" then 
		 		if  item_group:find_child(j.name):find_child("input_text").text == nil  or item_group:find_child(j.name):find_child("input_text").text == ""then 
					editor.error_message("007",j.name,nil,nil,inspector)
					inspector_deactivate()
	        		return -1 
				 end 
              end 

              if (attr_map[j.name]) then
					if attr_map[j.name]() then 
						inspector_deactivate()
						return -1
					end 
              elseif(v[j.name] ~= nil)then 
			  --[[
			  		-- Text Input Field
                     if(tonumber(item_group:find_child(j.name):find_child("input_text").text)) then 
					 	if j.name == "w" or j.name == "h" then 
							if v[j.name] ~= tonumber(item_group:find_child(j.name):find_child("input_text").text) then 
                            	v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
							end 
			    		else 
                        	v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
			    		end 
					 --0521
                     	--v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
                     else 
			    		if v[j.name] == true or v[j.name] == false then
								v[j.name] = toboolean(item_group:find_child(j.name):find_child("input_text").text)
			    		else 
							if j.name == "message" then 
							--print (tostring(item_group:find_child(j.name):find_child("input_text").text)) 
							end 
                            v[j.name] = tostring(item_group:find_child(j.name):find_child("input_text").text)
			    	end 
             end
			 ]]

			 --	Text Input Field 
              		if(tonumber(item_group:find_child(j.name):find_child("input_text").text)) then 
						if j.name == "w" or j.name == "h" then 
						 	if v[j.name] ~= tonumber(item_group:find_child(j.name):find_child("input_text").text) then 
                        	 	v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
							end 
			    	 	elseif j.name == "selected_item" then 
							if tonumber(item_group:find_child(j.name):find_child("input_text").text) > #v.items or 
							   tonumber(item_group:find_child(j.name):find_child("input_text").text) < 1 then 
			        			editor.error_message("012","selected_item",nil,nil,inspector)
								inspector_deactivate()
								return -1 
							else 
                        		v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
							end
						else
                        	v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
			    		end 
                	else 
			    		if v[j.name] == true or v[j.name] == false then
							v[j.name] = toboolean(item_group:find_child(j.name):find_child("input_text").text)
			    		else 
							for q,w in pairs (number_attrs) do 
								if w == j.name then 
										 
							--if j.name == "selected_item" or j.name == "w" or j.name == "h" or j.name == "x" or j.name == "y" or j.name == "z" or j.name == "opacity" or j.name == "button_radius" or j.name == "select_radius" or j.name == "line_space" then 
									editor.error_message("011",j.name,nil,nil,inspector)
									inspector_deactivate()
	        						return -1 
								end 
							end 
							if j.name == "message" then 
								--print (tostring(item_group:find_child(j.name):find_child("input_text").text)) 
							end 
							if tostring(item_group:find_child(j.name):find_child("input_text").text) then 
                        		v[j.name] = tostring(item_group:find_child(j.name):find_child("input_text").text)
							else 
								editor.error_message("011",j.name,nil,nil,inspector)
								inspector_deactivate()
	        					return -1 
							end 
			    		end 
             		end

	      elseif string.find(j.name,"color") then
		    if attr_map["color"](j.name) then 
				inspector_deactivate()
				return -1
			end
	      elseif(j.name =="x_scale" or j.name =="y_scale")then 
		     	local scale_t = {}
           	    scale_t[1] = item_group:find_child("x_scale"):find_child("input_text").text
                scale_t[2] = item_group:find_child("y_scale"):find_child("input_text").text
		     	v.scale = scale_t
	      elseif(j.name =="x_angle" or j.name =="y_angle" or j.name == "z_angle")then 
		     	local attr_n
		     	local rotation_t ={} 
	            if j.name == "x_angle" then attr_n = "x_rotation"
		     	elseif j.name == "y_angle" then attr_n = "y_rotation"
		     	else attr_n = "z_rotation" end
          	    rotation_t = v[attr_n] 
          	    rotation_t[1] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	  	     	v[attr_n] = rotation_t 
	      elseif j.name == "cx" or j.name == "cy" or j.name == "cw" or j.name == "ch" then
                local not_checkbox = false
                if v.extra then 
		        	if(v.extra.type == "CheckBoxGroup")then
                            local csize_t = {}
                            csize_t[1] = item_group:find_child("cw"):find_child("input_text").text
                            csize_t[2] = item_group:find_child("ch"):find_child("input_text").text
 		     	    		if tonumber(csize_t[1]) and tonumber(csize_t[2]) then 
 		     	    			v.check_size = csize_t
							else 
			    				editor.error_message("011","check size",nil,nil,inspector)
								inspector_deactivate()
								return -1 
					 		end 
                         else
                            	not_checkbox = true
		         		end 
		     		else
                    	not_checkbox = true
                    end
                    if not_checkbox then 
                            local clip_t = {}
                            if tonumber(item_group:find_child("cx"):find_child("input_text").text) then 
                	    clip_t[1] = item_group:find_child("cx"):find_child("input_text").text
					else
			        	editor.error_message("012","clip",nil,nil,inspector)
						inspector_deactivate()
						return -1 
					end 
					if tonumber(item_group:find_child("cy"):find_child("input_text").text) then 
                    	clip_t[2] = item_group:find_child("cy"):find_child("input_text").text
					else 
			        	editor.error_message("012","clip",nil,nil,inspector)
						inspector_deactivate()
						return -1 
					end 
					if tonumber(item_group:find_child("cw"):find_child("input_text").text) then 
                    	clip_t[3] = item_group:find_child("cw"):find_child("input_text").text
					else 
			        	editor.error_message("012","clip",nil,nil,inspector)
						inspector_deactivate()
						return -1 
					end 
					if tonumber(item_group:find_child("ch"):find_child("input_text").text) then 
                    	clip_t[4] = item_group:find_child("ch"):find_child("input_text").text
					else 
			        	editor.error_message("012","clip",nil,nil,inspector)
						inspector_deactivate()
						return -1 
					end 
                            v.clip = clip_t
                     end 	
		elseif j.name == "bw" or j.name == "bh" then
                     local not_checkbox = false
                     if v.extra then 
		         		if(v.extra.type == "CheckBoxGroup")then
                            local bsize_t = {}
                            bsize_t[1] = item_group:find_child("bw"):find_child("input_text").text
                            bsize_t[2] = item_group:find_child("bh"):find_child("input_text").text
							if tonumber(bsize_t[1]) and tonumber(bsize_t[2]) then 
 		     	    			v.box_size = bsize_t
					 		else 
			    				editor.error_message("011","box size",nil,nil,inspector)
								inspector_deactivate()
								return -1 
					 		end 
                       	end
		     		end 
		elseif j.name == "bx" or j.name == "by" then
                     local bpos_t = {}
                     bpos_t[1] = item_group:find_child("bx"):find_child("input_text").text
                     bpos_t[2] = item_group:find_child("by"):find_child("input_text").text
					 if tonumber(bpos_t[1]) and tonumber(bpos_t[2]) then 
					 	if v.extra.type == "CheckBoxGroup" then 
		 		     		v.box_position = bpos_t
					 	else 
		 		     		v.button_position = bpos_t
					 	end 
					 else 
			    		editor.error_message("011","button size",nil,nil,inspector)
						inspector_deactivate()
						return -1 
					 end 
		elseif j.name == "ix" or j.name == "iy" then
                 local ipos_t = {}
                 ipos_t[1] = item_group:find_child("ix"):find_child("input_text").text
                 ipos_t[2] = item_group:find_child("iy"):find_child("input_text").text
 		     	 if tonumber(ipos_t[1]) and tonumber(ipos_t[2]) then 
 		         	v.item_position = ipos_t
				 else 
			    	editor.error_message("011","item position",nil,nil,inspector)
					inspector_deactivate()
					return -1 
				 end 
		elseif j.name == "focusChanger" then 
		     v.extra.focus = {}
		     local focus_t_list = {"U","D","E","L","R","Red","G","Y","B"}
		     local focus_map = {["U"] = keys.Up, ["D"] = keys.Down, ["E"] = keys.Return, ["L"] = keys.Left, ["R"] = keys.Right,["Red"] = keys.RED,["G"] = keys.GREEN,["Y"] = keys.YELLOW,["B"] = keys.BLUE}
		     local focus_match= {["U"] = keys.Down, ["D"] = keys.Up, ["L"] = keys.Right,["R"] = keys.Left,}
		     for m,n in pairs (focus_t_list) do 
		          if item_group:find_child("text"..n).text ~= "" then 
					if item_group:find_child("text"..n).text == v.extra.prev_name then 
						v.extra.focus[focus_map[n]] = v.name
					else 
						v.extra.focus[focus_map[n]] = item_group:find_child("text"..n).text
					end 
					if focus_match[n] then 
						if g:find_child(item_group:find_child("text"..n).text) then 
						if g:find_child(item_group:find_child("text"..n).text).extra.focus then 
					     	g:find_child(item_group:find_child("text"..n).text).extra.focus[focus_match[n]] = v.name
						else
					     	g:find_child(item_group:find_child("text"..n).text).extra.focus = {} 
					     	g:find_child(item_group:find_child("text"..n).text).extra.focus[focus_match[n]] = v.name
						end
						end
					end 
			  	end 
		     end 
		elseif j.name == "left" or j.name == "top" or  j.name == "width" or j.name == "height" then 
		     local viewport_t = {}
                     viewport_t[1] = item_group:find_child("left"):find_child("input_text").text
                     viewport_t[2] = item_group:find_child("top"):find_child("input_text").text
                     viewport_t[3] = item_group:find_child("width"):find_child("input_text").text
                     viewport_t[4] = item_group:find_child("height"):find_child("input_text").text
					 if tonumber(viewport_t[1]) and tonumber(viewport_t[2]) and tonumber(viewport_t[3]) and tonumber(viewport_t[4]) then
                    	v.viewport = viewport_t
				 	else 
			    		editor.error_message("011","viewport",nil,nil,inspector)
						inspector_deactivate()
						return -1 
				 	end 

		else 
		     print(j.name, " 처리해 주세요")
		end 
	   end 
       end 	  
	   	return 1 
	   end 

		local return_v = 0 

	  	if inspector:find_child("item_group_info") then 
	       item_group = inspector:find_child("item_group_info")
		   if apply(item_group) == -1 then 
				return -1 
		   end 
	  	end 
	 
	 
	  	if inspector:find_child("focusChanger") then 
		   item_group = inspector:find_child("focusChanger") 

		   v.extra.focus = {}
		   local focus_t_list = {"U","D","E","L","R",}
		   local focus_map = {["U"] = keys.Up, ["D"] = keys.Down, ["E"] = keys.Return, ["L"] = keys.Left, ["R"] = keys.Right,["Red"] = keys.RED,["G"] = keys.GREEN,["Y"] = keys.YELLOW,["B"] = keys.BLUE}
		   local focus_match= {["U"] = keys.Down, ["D"] = keys.Up, ["L"] = keys.Right,["R"] = keys.Left,}
		   for m,n in pairs (focus_t_list) do 
		   	    if item_group:find_child("text"..n).text ~= "" then 
					if item_group:find_child("text"..n).text == v.extra.prev_name then 
						v.extra.focus[focus_map[n]] = v.name
					else 
						v.extra.focus[focus_map[n]] = item_group:find_child("text"..n).text
					end 
					if focus_match[n] then 
						if g:find_child(item_group:find_child("text"..n).text) then 
						if g:find_child(item_group:find_child("text"..n).text).extra.focus then 
					     	g:find_child(item_group:find_child("text"..n).text).extra.focus[focus_match[n]] = v.name
						else
					     	g:find_child(item_group:find_child("text"..n).text).extra.focus = {} 
					     	g:find_child(item_group:find_child("text"..n).text).extra.focus[focus_match[n]] = v.name
						end
						end
					end 
			    end 
		  end 
	  	end 

		if inspector:find_child("item_group_more") then 
	       item_group = inspector:find_child("item_group_more")
		   if apply(item_group) == -1 then 
				return -1 
		   end 
	  	end 

		if inspector:find_child("item_group_list") then 
		   item_group = inspector:find_child("item_group_list")
		   if apply(item_group) == -1 then 
				return -1 
		   end 
	  	end 

        util.set_obj(new_object, v) 
        input_mode = hdr.S_SELECT
        if(v.name ~= "video1") then 
       	    table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
        end 
		
       return org_object, new_object
end	

