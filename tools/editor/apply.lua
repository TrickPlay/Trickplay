	local factory = ui.factory

	local org_object, new_object, item_group 
	local prev_skin, new_skin, prev_font_size, new_font_size
	local prev_ix, prev_iy, new_ix, new_iy, prev_line_space, new_line_space, img_w, img_h

	local non_txt_items = {"arrows_visible", "anchor_point", "reactive", "focusChanger", "src", "source", "loop", "skin", "wrap_mode", "items", "itemsList", "icon", "items", "expansion_location", "tab_position", "style", "cell_size", "vert_bar_visible", "horz_bar_visible", "cells_focusable", "lock", "direction", "justify", "alignment", "single_line", }

	local number_attr_t = {"bwidth", "hor_arrow_y", "vert_arrow_x", "cx", "cy", "cw", "ch", "bw", "bh", "bx", "by", "ix", "iy", 
	"left", "top", "width", "height", "x", "y", "z", "w", "h", "opacity", "button_radius", "select_radius", "line_space", "volume", "ui_width", "ui_height", "border_width", "border_corner_radius", "on_screen_duration", "fade_duration", "padding", "button_width", "button_height", "display_border_width", "display_width", "display_height", "arrow_size", "arrow_dist_to_frame", "visible_width", "visible_height", "virtual_width", "virtual_height", "frame_thickness", "bar_thickness", "bar_offset", "box_border_width", "overall_diameter", "dot_diameter", "number_of_dots", "cycle_time", "progress", "menu_width", "horz_padding", "vert_spacing", "horz_spacing", "vert_offset", "separator_thickness", "rows", "columns", "cell_width", "cell_height", "cell_spacing_width", "cell_spacing_height", "cell_timing", "cell_timing_offset", "title_separator_thickness", "selected_item", 
} 

	local reserved_words = {"and", "end", "break", "do" ,"else", "elseif", "false", "for", "function", "if", "in",
"local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"}

	local rgba_map = {["r"] = 1, ["g"] = 2, ["b"] = 3, ["a"] = 4,}  

	local focus_t_list = {"U","D","E","L","R",}

	local focus_map = {["U"] = keys.Up, ["D"] = keys.Down, ["E"] = keys.Return, ["L"] = keys.Left, ["R"] = keys.Right,["Red"] = keys.RED,["G"] = keys.GREEN,["Y"] = keys.YELLOW,["B"] = keys.BLUE}

	local focus_match= {["U"] = keys.Down, ["D"] = keys.Up, ["L"] = keys.Right,["R"] = keys.Left,}

	local toboolean = function(s) if (s == "true") then return true else return false end end

	local inspector_deactivate = function (inspector)
		local rect = Rectangle {name = "deactivate_rect", color = {10,10,10,100}, size = {300,400}, position = {0,0}, reactive = true}
		inspector:add(rect)
	end 

	local is_this_txt_item = function(name) 

	for q,w in pairs(non_txt_items) do 
		if w == name then 
			return false 
		end 
	end 

	return true 
	end 

	local verify_attr_map = {
	["frame_thickness"] = function (attr_val,v,inspector) 
			if tonumber(attr_val) >=  v.bar_thickness then 
				editor.error_message("012","frame thickness",nil,nil,inspector) 
				inspector_deactivate(inspector)
				return -1 
			end 
		end, 
	["selected_item"] = function (attr_val, v, inspector) 
			attr_val = tonumber(attr_val) 
			if attr_val > #v.items or attr_val < 1 then 
				editor.error_message("012","selected_item",nil,nil,inspector)
				inspector_deactivate(inspector)
				return -1 
			end
		end,  
	["name"] = function (attr_val, v, inspector) 
			local name_format = "[%u%l_]+[%w_]*"
			local a, b = string.find(attr_val, name_format) 
			if a and a == 1 and b == string.len(attr_val) then 
				for q, w in pairs (reserved_words) do 
					if w == name_val then 
			 			editor.error_message("012","name",nil,nil,inspector)
						inspector_deactivate(inspector)
				 		return -1 
					end 
				end 
			else 
				editor.error_message("012","name",nil,nil,inspector)
				inspector_deactivate(inspector)
				return -1 
			end
		end, 
	["selected_item"] = function (attr_val, v, inspector)
			attr_val = tonumber(attr_val) 
			if attr_val > #v.items or attr_val < 1 then 
				editor.error_message("012","selected_item",nil,nil,inspector)
				inspector_deactivate(inspector)
				return -1 
			end 
	 	end, 
	["selected_items"] = function (attr_val, v, inspector)
			local items_tbl = {}
			local items_idx = 1

			while attr_val ~= ""  do 
		   		local i,j = string.find(attr_val, ",")
		   		if i then 
					local ival = tonumber(string.sub(attr_val, items_idx, i-1))
					if ival then
						if ival > #v.items or ival < 1  then 
			        		editor.error_message("012","selected_items",nil,nil,inspector)
							inspector_deactivate(inspector)
							return -1 
						else 
							attr_val = string.sub(attr_val, j+1, -1) 
						end 
					else 
			    		editor.error_message("012","selected_items",nil,nil,inspector)
						inspector_deactivate(inspector)
						return -1 
					end 
				else 
					local ival = tonumber(attr_val)
					if ival then 
						if ival > #v.items or ival < 1 then 
			        		editor.error_message("012","selected_items",nil,nil,inspector)
							inspector_deactivate(inspector)
							return -1 
						else
							attr_val = ""
						end
					else 
			    		editor.error_message("012","selected_items",nil,nil,inspector)
						inspector_deactivate(inspector)
						return -1 
					end 
				end 
			end 
		end,
	}

	local function CB_RB(v)

	local font_diff = new_font_size - prev_font_size 
	local line_space_diff = new_line_space - prev_line_space
	local ix_diff = new_ix - prev_ix
	local iy_diff = new_iy - prev_iy 
	local ls_val = 0 
	local p_val = 0 
	
	if v.extra.type == "CheckBoxGroup" then 
		if prev_skin ~= "CarbonCandy" and v.skin == "CarbonCandy" then -- Custom->CarbonCandy
			ls_val = 20 p_val = 20
		elseif  prev_skin ~= "Custom" and v.skin == "Custom" then -- CarbonCandy -> Custom
			ls_val = -20 p_val = -20
		end 
	elseif v.extra.type == "RadioButtonGroup" then 
		if prev_skin ~= "CarbonCandy" and v.skin == "CarbonCandy" then -- Custom->CarbonCandy
			ls_val = 25 p_val = 20
		elseif  prev_skin ~= "Custom" and v.skin == "Custom" then -- CarbonCandy -> Custom
			ls_val = -25 p_val = -20
		end 
	end 

	if new_line_space == prev_line_space and new_ix == prev_ix and new_iy == prev_iy then 
		v.line_space = v.line_space + ls_val
		v.item_position = {v.item_position[1] + p_val, v.item_position[2] + p_val}
	end

	if prev_line_space == new_line_space and prev_ix == new_ix then 
		v.line_space = v.line_space + math.floor(font_diff/3)
		v.item_position = {v.item_position[1]- font_diff, v.item_position[2] - font_diff}
	end 

	end 

	local attr_map = {
    ["itemsList"] = function(j,v,inspector)
    	local items, item, t_item
        local next = 1
		local iList = item_group:find_child("itemsList")

		if iList then 
			items = iList:find_child("items_list")
        end 

		if items then 
        	for next, _ in pairs(items.cells) do 
		    	item = items.cells[next][1]
				t_item = item:find_child("textInput")

		if v.extra.type == "ButtonPicker" or v.extra.type == "CheckBoxGroup" or v.extra.type == "RadioButtonGroup" then 
			v.items[next] = t_item.text
		elseif v.extra.type == "TabBar" then 
			v.tab_labels[next] = t_item.text
						elseif v.extra.type == "MenuButton" then 
	 	       				if t_item.text == "--------------" then 
			    				v.items[next] = {type="separator"}
							else 
								local pp = t_item.parent
		       					if pp.item_type == "label" then 
			    					v.items[next] = {type="label", string=t_item.text}
		       					elseif pp.item_type == "item" then 
			    					v.items[next] = {type="item", string=t_item.text, f=nil}
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

       	["skin"] = function(j,v,inspector)

				  prev_skin = v.skin
    	          v["skin"] = hdr.inspector_skins[tonumber(item_group:find_child("skin"):find_child("item_picker").selected_item)]
				  new_skin = skins[tonumber(item_group:find_child("skin"):find_child("item_picker").selected_item)]

               end,

		["frame_thickness"] = function (j,v,inspector)
					
				  v["frame_thickness"] =  tonumber(item_group:find_child("frame_thickness"):find_child("input_text").text)

			  end, 

		["arrows_visible"] = function (j,v,inspector)

	       	  		if item_group:find_child("bool_checkarrows_visible"):find_child("check1").opacity > 0 then 
	          			v.arrows_visible = true
	       			else 
	            		v.arrows_visible = false
	       			end
			   end,

       	["anchor_point"] = function(j,v,inspector)

					local anchor_pnt = item_group:find_child("anchor_point"):find_child("anchor")
	           		v:move_anchor_point(anchor_pnt.extra.anchor_point[1], anchor_pnt.extra.anchor_point[2]) 

              end,     
		["alignment"] = function(j,v,inspector)

	      	  		local itemLists = {"left", "center", "right", }
              		v.alignment = string.upper(itemLists[tonumber(item_group:find_child("alignment"):find_child("item_picker").selected_item)])

              end,     
       	["wrap_mode"] = function(j,v,inspector)

	    		  	local itemLists = {"none", "char", "word", "word_char"}
					local s_num = tonumber(item_group:find_child("wrap_mode"):find_child("item_picker").selected_item)
						
	      			if s_num == 1 then 
		   				v.wrap = false
                		v.wrap_mode = "CHAR"
	      			else 
		   				v.wrap = true
                		v.wrap_mode = string.upper(itemLists[s_num])
	      			end 
               end,        
       	["bwidth"] = function(j,v,inspector)

					local bwidth_txt = item_group:find_child("bwidth"):find_child("input_text").text
                   	v.border_width = tonumber(bwidth_txt)

               end,
       	["color"] = function(name,v,inspector)

	      			local attr_name = "color"
					local color_txt = item_group:find_child(name):find_child("input_text").text

	      			if string.len(name) > 1 then 
	           			attr_name = name:sub(1,-2)
	      			end 

	      			local color_t = v[attr_name]

		  			color_t[rgba_map[string.sub(name,-1, -1)]] = tonumber(color_txt)

	      			v[attr_name] = color_t

	      	    end,
       	["hor_arrow_y"] = function(j,v,inspector)

	       			v.hor_arrow_y = tonumber(item_group:find_child("hor_arrow_y"):find_child("input_text").text)

				end, 
       	["vert_arrow_x"] = function(j,v,inspector)

	       			v.ver_arrow_x = tonumber(item_group:find_child("vert_arrow_y"):find_child("input_text").text)
				
				end,
       	["reactive"] = function(j,v,inspector)

	       			if item_group:find_child("bool_checkreactive"):find_child("check1").opacity > 0 then 
	            		v.extra.reactive = true
	       			else 
	            		v.extra.reactive = false
	       			end

	       		end,
       	["loop"] = function(j,v,inspector)

	       			if item_group:find_child("bool_checkloop"):find_child("check1").opacity > 0 then 
	            		v.loop = true
	       		    else 
	            		v.loop = false
	       		    end
	       		end,
		["vert_bar_visible"] = function(j,v,inspector)

	       			if item_group:find_child("bool_checkvert_bar_visible"):find_child("check1").opacity > 0 then 
	            		v.vert_bar_visible = true
	       			else 
	            		v.vert_bar_visible = false
	       			end
	       		end,
		["horz_bar_visible"] = function(j,v,inspector)

 	       			if item_group:find_child("bool_checkhorz_bar_visible"):find_child("check1").opacity > 0 then 
	            		v.horz_bar_visible = true
	       			else 
	            		v.horz_bar_visible = false
	       			end

	       		end,
		["lock"] = function(j,v,inspector)

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
		["justify"] = function(j,v,inspector)
 	       		
					if item_group:find_child("justify"):find_child("check1").opacity > 0 then 
	            		v.justify = true
	       			else 
	            		v.justify = false
	       			end

	       		end,
		["single_line"] = function(j,v,inspector)

 	       			if item_group:find_child("single_line"):find_child("check1").opacity > 0 then 
	            		v.single_line = true
	       			else 
	            		v.single_line = false
	       			end

	       		end,

		["cells_focusable"] = function(j,v,inspector)

 	       			if item_group:find_child("bool_checkcells_focusable"):find_child("check1").opacity > 0 then 
	            		v.cells_focusable = true
	       			else 
	            		v.cells_focusable = false
	       			end

	       		end,

		["tab_position"] = function(j,v,inspector)

			  		local itemLists = {"top", "right"} 
              		v["tab_position"] = itemLists[tonumber(item_group:find_child("tab_position"):find_child("item_picker").selected_item)]

					if v.extra.focus == nil then 
						v.extra.focus = {}
					end 

					if itemLists[tonumber(item_group:find_child("tab_position"):find_child("item_picker").selected_item)] == "top" and 
			    		inspector:find_child("focuschanger_bg".."R").opacity == 255 then 
				 		for i = 1, #v.tab_labels do
				 			v.tabs[i].extra.up_focus = v.tabs[i].extra.left_focus 
				 			v.tabs[i].extra.left_focus = ""
				 			v.tabs[i].extra.down_focus = v.tabs[i].extra.right_focus 
				 			v.tabs[i].extra.right_focus = ""
				    		if i == 1 then 
				 				v.extra.focus[keys.Left] = v.extra.focus[keys.Up] 
					    		v.extra.focus[keys.Up] = "" 
							elseif i == #v.tab_labels then 
				 				v.extra.focus[keys.Right] = v.extra.focus[keys.Down]
								v.extra.focus[keys.Down] = "" 
							end 
				 		end 
		      		elseif itemLists[tonumber(item_group:find_child("tab_position"):find_child("item_picker").selected_item)] == "right" and 
			     		inspector:find_child("focuschanger_bg".."D").opacity == 255 then 
				 		for i = 1, #v.tab_labels do
				 			v.tabs[i].extra.left_focus = v.tabs[i].extra.up_focus 
				 			v.tabs[i].extra.up_focus = ""
				 			v.tabs[i].extra.right_focus = v.tabs[i].extra.down_focus 
				 			v.tabs[i].extra.down_focus = ""
				    		if i == 1 then 
				 				v.extra.focus[keys.Up] = v.extra.focus[keys.Left] 
					    		v.extra.focus[keys.Left] = "" 
							elseif i == #v.tab_labels then 
				 				v.extra.focus[keys.Down] = v.extra.focus[keys.Right]
								v.extra.focus[keys.Right] = "" 
							end 
				 		end 
			  		end 

				end,

		["expansion_location"] = function(j,v,inspector)

			  		local itemLists = {"above", "below"} 
              		v["expansion_location"] = itemLists[tonumber(item_group:find_child("expansion_location"):find_child("item_picker").selected_item)]

				end,

		["direction"] = function(j,v,inspector)


				   local itemLists = {"vertical", "horizontal"}
              	   v["direction"] = itemLists[tonumber(item_group:find_child("direction"):find_child("item_picker").selected_item)]

				end,
		
		["style"] = function(j,v,inspector)
			  	   local itemLists = {"orbitting", "spinning"}
              	   v["style"] = itemLists[tonumber(item_group:find_child("style"):find_child("item_picker").selected_item)]

				end,

		["cell_size"] = function(j,v,inspector)


			  	   local itemLists = {"fixed", "variable"}
              	   v["cell_size"] = itemLists[tonumber(item_group:find_child("cell_size"):find_child("item_picker").selected_item)]

				end,

		["icon"] = function(j,v,inspector)

			   		local icon_txt = tostring(item_group:find_child("icon"):find_child("file_name").text)
			   		local a, b = string.find(icon_txt,"assets/images/")

			   		if a == nil then 
			   			a, b = string.find(icon_txt,"lib/assets/")
			   		end 

			   		if a then 
               			v.icon = icon_txt
			   		else 
               			v.icon = "assets/images/"..icon_txt
			   		end 
	       		
				end,

		["source"] = function(j,v,inspector)

               		local img_tmp = tostring(item_group:find_child("source"):find_child("file_name").text)
			   		local a, b = string.find(img_tmp, "assets/videos/")

			   		if a then
               			v.source = img_tmp
			   		else 
               			v.source = "assets/videos/"..img_tmp
			   		end 

	       		end,

		["src"] = function(j,v,inspector)
               	   
				   	local img_tmp = tostring(item_group:find_child("src"):find_child("file_name").text)
			   	   	local a, b = string.find(img_tmp, "assets/images/")
			   	   	if a then
               			v.src = img_tmp
			   	   	else 
               			v.src = "assets/images/"..img_tmp
			   		end 
	       		
				end,

		["name"] = function(j,v,inspector)

		  	   		if v.extra then 
		            	v.extra.prev_name = v.name  
	    	   		end 

	       	   		v.name = tostring(item_group:find_child("name"):find_child("input_text").text) 

	       		end, 

		["selected_items"] = function (j,v,inspector)

					local items_str = tostring(item_group:find_child("selected_items"):find_child("input_text").text)
		    		local items_tbl = {}
		    		local items_idx = 1

		    		while items_str ~= ""  do 
		   				local i,j = string.find(items_str, ",")
		   				if i then 
							local ival = tonumber(string.sub(items_str, items_idx, i-1))
							if ival then
									table.insert(items_tbl, ival)
									items_str = string.sub(items_str, j+1, -1) 
							end 
						else 
							local ival = tonumber(items_str)
					 		if ival then 
									table.insert(items_tbl, ival)
									items_str = ""
					 		end 
						end 
		    		end 
				    v.extra.selected_items = items_tbl 
				end 
	}       
	  

	local apply = function (item_group,v,inspector) 

		local itxt

		for i, j in pairs(item_group.children) do 
	      	if j.name then
				if item_group:find_child(j.name):find_child("input_text") then 
					itxt = item_group:find_child(j.name):find_child("input_text").text
						-- Empty text filed 
					if is_this_txt_item(j.name) == true then 
		 				if itxt == nil  or itxt == "" then 
							editor.error_message("007",j.name,nil,nil,inspector)
							inspector_deactivate(inspector)
	        				return -1 
				 		end 
              		end 

					local color_attr = string.find(j.name, "color")
					local rotation_attr = string.find(j.name, "angle") 
					local number_attr 
	
					for q, w in pairs (number_attr_t) do 
						if w == j.name then 
							number_attr = true 
						end 
					end 

					if number_attr or color_attr or rotation_attr then 
						if tonumber(itxt) == nil then 
							editor.error_message("011",j.name,nil,nil,inspector)
							inspector_deactivate(inspector)
							return -1 
						end 
					end 

					if verify_attr_map[j.name] then 
						if verify_attr_map[j.name](itxt, v, inspector) then 
							return -1
						end 
					end 
				end
			end 
		end 
			
      	for i, j in pairs(item_group.children) do 
	    	if j.name then
				if item_group:find_child(j.name):find_child("input_text") then 
					itxt = item_group:find_child(j.name):find_child("input_text").text
				end 
					
              	if attr_map[j.name] then
					attr_map[j.name](j.name,v,inspector) 
              	elseif(v[j.name] ~= nil)then 
			 	--	Numeric Text Input Field 
					local inum = tonumber(itxt)
              		if inum then 
						if j.name == "w" then 
							img_w = v.w
							if v[j.name] ~= inum then 
                        		v[j.name] = inum
							end 
						elseif  j.name == "h" then 
							img_h = v.h 
							if v[j.name] ~= inum then 
                        		v[j.name] = inum
							end 
						
						elseif j.name == "line_space" then 
							prev_line_space = v[j.name]
					        v[j.name] = inum
							new_line_space = inum
			    		else
                        	v[j.name] = inum 
			    		end 
                	else 
			 	--	Boolean Text Input Field 
			    		if v[j.name] == true or v[j.name] == false then
							v[j.name] = toboolean(itxt)
			    		else 
							if j.name == "text_font" then 
							 	local a,b = string.find(v.text_font, "px")
							 	prev_font_size = tonumber(string.sub(v.text_font, a-3, a-1))
								local new_font = tostring(itxt)
								if new_font then 
									a,b = string.find(new_font, "px")
							 		new_font_size = tonumber(string.sub(new_font, a-3, a-1))
								end 
							end 

							if tostring(itxt) then 
                        		v[j.name] = tostring(itxt)
							end 
			    		end 
             		end
	      		elseif string.find(j.name,"color") then
		    		attr_map["color"](j.name,v,inspector)
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

						if tonumber(itxt) then 
          	    			rotation_t[1] = tonumber(itxt)
	  	     				v[attr_n] = rotation_t 
						end 
	      		elseif j.name == "cx" or j.name == "cy" or j.name == "cw" or j.name == "ch" then
                		local not_checkbox = false
                		if v.extra then 
		        			if(v.extra.type == "CheckBoxGroup")then
                            	local csize_t = v.check_size --{}
                            	csize_t[1] = item_group:find_child("cw"):find_child("input_text").text
                            	csize_t[2] = item_group:find_child("ch"):find_child("input_text").text
 		     	    			if tonumber(csize_t[1]) and tonumber(csize_t[2]) then 
 		     	    				v.check_size = csize_t
					 			end 
                         	else
                            	not_checkbox = true
		         			end 
		     			else
                    		not_checkbox = true
                    	end
				  		if not_checkbox then 
							local clip_t = {}
							if v.clip then 
								clip_t = v.clip
							end 
							if tonumber(itxt) then 
								if j.name == "cx" then clip_t[1] = tonumber(itxt)
								elseif j.name == "cy" then clip_t[2] = tonumber(itxt)
								elseif j.name == "cw" then if img_w ~= v.w then clip_t[3] = v.w else clip_t[3] = tonumber(itxt) end 
								elseif j.name == "ch" then if img_h ~= v.h then clip_t[4] = v.h else clip_t[4] = tonumber(itxt) end  
								end 
                            	v.clip = clip_t
							end 
                     	end 	
				elseif j.name == "bw" or j.name == "bh" then
                     	if v.extra then 
		         			if(v.extra.type == "CheckBoxGroup")then
                            	local bsize_t = v.box_size --{}

								if tonumber(itxt) then 
									if j.name == "bw" then bsize_t[1] = tonumber(itxt)
									elseif j.name == "bh" then bsize_t[2] = tonumber(itxt)
									end 
                            		v.box_size = bsize_t 
								end 
                       		end
		     			end 
				elseif j.name == "bx" or j.name == "by" then
               		local bpos_t 
					if v.extra.type == "CheckBoxGroup" then 
		 	   			bpos_t = v.box_position 
			 		else 
		 	   			bpos_t = v.button_position 
			 		end 

					if tonumber(itxt) then 
					 	if j.name == "bx" then 
					 		bpos_t[1] = tonumber(itxt)
					 	elseif j.name == "by" then 
					 		bpos_t[2] = tonumber(itxt)
					 	end 
	
					 	if v.extra.type == "CheckBoxGroup" then 
		 		     		v.box_position = bpos_t
					 	else 
		 		    		v.button_position = bpos_t
						end 
					end 
				elseif j.name == "ix" or j.name == "iy" then
					prev_ix = v.item_position[1]
					prev_iy = v.item_position[2]
                	local ipos_t = {}
					if tonumber(itxt) then 
						if j.name == "ix" then 
							ipos_t[1] = tonumber(itxt) new_ix = ipos_t[1] v.item_position[1] = ipos_t[1]
						elseif j.name == "iy" then 
							ipos_t[2] = tonumber(itxt) new_iy = ipos_t[2] v.item_position[2] = ipos_t[2]
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
					end 
				else 
		    		print(j.name, "is missing")
				end 
			end 
    	end 	  
		return 1 
	end 



local function tab_item_apply (inspector_focus, v_focus, rel_key, v_name)
							 
	if inspector_focus ~= nil and  inspector_focus ~= "" then 
		v_focus = inspector_focus
		if g:find_child(inspector_focus).extra.focus == nil then 
			g:find_child(inspector_focus).extra.focus = {}
		end 
		g:find_child(inspector_focus).extra.focus[rel_key] = v_name
	elseif inspector_focus == "" then 
		v_focus = nil
	end 

	return v_focus

end 

local function tab_apply (v, inspector)

	if v.extra.type == "TabBar" then 
		for i = 1, #v.tab_labels, 1 do
			if v.tab_position == "top" then 
				-- item_group.extra.tabs[i] 새로 생성한 텝에 대해서 이게 없는거이 문제구마이.. 
 				 v.tabs[i].extra.up_focus = tab_item_apply (item_group.extra.tabs[i].up_focus, v.tabs[i].extra.up_focus, keys.Down, v.name)
 				 v.tabs[i].extra.down_focus = tab_item_apply (item_group.extra.tabs[i].down_focus, v.tabs[i].extra.down_focus, keys.Up, v.name)
			else 
 				 v.tabs[i].extra.left_focus = tab_item_apply (item_group.extra.tabs[i].left_focus, v.tabs[i].extra.left_focus, keys.Right, v.name)
 				 v.tabs[i].extra.right_focus = tab_item_apply (item_group.extra.tabs[i].right_focus, v.tabs[i].extra.right_focus, keys.Left, v.name)
			end 

			if i == 1 then 
				if v.tab_position == "top" then 
 				 	v.extra.focus[keys.Left] = tab_item_apply (item_group.extra.tabs[i].left_focus, v.extra.focus[keys.Left], keys.Right, v.name)
				else 
 				 	v.extra.focus[keys.Up] = tab_item_apply (item_group.extra.tabs[i].up_focus, v.extra.focus[keys.Up], keys.Down, v.name)
				end 
			elseif i == #v.tab_labels then 
				if v.tab_position == "top" then 
 				 	v.extra.focus[keys.Right] = tab_item_apply (item_group.extra.tabs[i].right_focus, v.extra.focus[keys.Right], keys.Left, v.name)
				else
 				 	v.extra.focus[keys.Down] = tab_item_apply (item_group.extra.tabs[i].down_focus, v.extra.focus[keys.Down], keys.Up, v.name)
				end
			end 
		end 
	else 
	   	for m,n in pairs (focus_t_list) do 
			local nth_txt = item_group:find_child("text"..n).text
	   	    if nth_txt ~= "" then 
				if nth_txt == v.extra.prev_name then 
					v.extra.focus[focus_map[n]] = v.name
				else 
					v.extra.focus[focus_map[n]] = nth_txt
				end 
				if focus_match[n] then 
					local g_nth_txt = g:find_child(item_group:find_child("text"..n).text)
					if g_nth_txt then 
						if g_nth_txt.extra.focus then 
					   		g_nth_txt.extra.focus[focus_match[n]] = v.name
						else
					    	g_nth_txt.extra.focus = {} 
					     	g_nth_txt.extra.focus[focus_match[n]] = v.name
						end
					end
				end 
			end 
		end 
	end 

end 

function inspector_apply (v, inspector)


    org_object = util.copy_obj(v) 

	if inspector:find_child("item_group_info") then 
		item_group = inspector:find_child("item_group_info")
		if apply(item_group, v, inspector) == -1 then 
			return -1 
		end 
	end 

	
	if inspector:find_child("item_group_more") then 
		item_group = inspector:find_child("item_group_more")
		if apply(item_group, v, inspector) == -1 then 
			return -1 
		end 
	end 

	if inspector:find_child("item_group_list") then 
		item_group = inspector:find_child("item_group_list")
		if apply(item_group, v, inspector) == -1 then 
			return -1 
		end 
	end 
	
	if inspector:find_child("focusChanger") then 
		item_group = inspector:find_child("focusChanger") 
		v.extra.focus = {}
		tab_apply(v,inspector)
	end 

	if v.extra and ( v.extra.type == "CheckBoxGroup" or v.extra.type == "RadioButtonGroup" ) then
		CB_RB(v)
	end

    new_object = util.copy_obj(v) 
    input_mode = hdr.S_SELECT

    if(v.type ~= "Video") then 
    	table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
    end 
		
    return org_object, new_object
end	

