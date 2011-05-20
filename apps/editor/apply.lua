dofile("util.lua") --1208

local factory = ui.factory


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
	 	       elseif item:find_child("textInput").text == "--------------" then 
			    v.items[next] = {type="seperator"}
		       elseif item:find_child("textInput").extra.item_type == "label" then 
			    v.items[next] = {type="label", string=item:find_child("textInput").text}
		       elseif item:find_child("textInput").extra.item_type == "item" then 
			    v.items[next] = {type="label", string=item:find_child("textInput").text, f=nil}
		       end 
                     end 
		 end
              end,
       ["skin"] = function()
              v["skin"] = skins[tonumber(item_group:find_child("skin"):find_child("item_picker").selected_item)]
              end,
       ["anchor_point"] = function()
               v:move_anchor_point(item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	      item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
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
              v.border_width = tonumber(item_group:find_child("bwidth"):find_child("input_text").text)
              end,
       ["color"] = function(name)
	      local attr_name = "color"
	      if string.len(name) > 1 then 
	           attr_name = name:sub(1,-2)
	      end 
	      local color_t = {}
	      color_t = v[attr_name]
	      color_t[rgba_map[string.sub(name,-1, -1)]] = tonumber(item_group:find_child(name):find_child("input_text").text)
	      v[attr_name] = color_t
	      end,
       ["hor_arrow_y"] = function()
	       v.hor_arrow_y = tonumber(item_group:find_child("hor_arrow_y"):find_child("input_text").text)
		end, 
       ["vert_arrow_x"] = function()
	       v.ver_arrow_x = tonumber(item_group:find_child("vert_arrow_x"):find_child("input_text").text)
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
	["cells_focusable"] = function()
 	       if item_group:find_child("bool_checkcells_focusable"):find_child("check1").opacity > 0 then 
	            v.cells_focusable = true
	       else 
	            v.cells_focusable = false
	       end
	       end,
	["expansion_location"] = function()
		if  item_group:find_child("radioB").selected_item == 1 then 
		     v.expansion_location = "above"
	        else 
		     v.expansion_location = "below"
		end
		end,
	["direction"] = function()
		if  item_group:find_child("radioB").selected_item == 1 then 
		     v.direction = "vertical"
	        else 
		     v.direction= "horizontal"
		end
		end,
		
	["style"] = function()
		if  item_group:find_child("radioB").selected_item == 1 then 
		     v.style = "orbitting"
	        else 
		     v.style = "spinning"
		end
		end,
	["cell_size"] = function()
		if  item_group:find_child("radioB").selected_item == 1 then 
		     v.cell_size = "fixed"
	        else 
		     v.cell_size = "variable"
		end
		end,
	["icon"] = function()
               --v.icon = "assets/images/"..tostring(item_group:find_child("icon"):find_child("file_name").text)
               v.icon = tostring(item_group:find_child("icon"):find_child("file_name").text)
	       end,
	["source"] = function()
               --v.source = "assets/videos/"..tostring(item_group:find_child("source"):find_child("file_name").text)
               v.source = tostring(item_group:find_child("source"):find_child("file_name").text)
	       end,
	["src"] = function()
               --v.src = "assets/images/"..tostring(item_group:find_child("src"):find_child("file_name").text)
               v.src = tostring(item_group:find_child("src"):find_child("file_name").text)
	       end,
	["name"] = function ()
	       if v.extra then 
	        	v.extra.prev_name = v.name  
	       end 
	       v.name = tostring(item_group:find_child("name"):find_child("input_text").text)
	       end, 

      }       

      if is_this_widget(v) == true  then
              item_group = (inspector:find_child("si")).content
      else 
              item_group = inspector:find_child("item_group")
      end 

      org_object, new_object = obj_map[v.type]()
      set_obj(org_object, v) 


      for i, j in pairs(item_group.children) do 
          	  
	      if j.name then
		 if j.name ~= "anchor_point" and j.name ~= "reactive" and j.name ~= "focusChanger" and j.name ~= "src" and j.name ~= "source" and j.name ~= "loop" and j.name ~= "skin" and j.name ~= "wrap_mode" and j.name ~= "items" and j.name ~= "itemsList" and j.name ~= "icon" and j.name ~= "items" and j.name ~= "expansion_location" and j.name ~= "style" and j.name ~= "cell_size" and j.name ~= "vert_bar_visible" and j.name ~= "horz_bar_visible" and j.name ~= "cells_focusable" and j.name ~= "lock" and j.name ~="direction" then 
		 if  item_group:find_child(j.name):find_child("input_text").text == nil  or item_group:find_child(j.name):find_child("input_text").text == ""then 
			print("여기 빈 공간이 있답니다. 그럼 여기 이 라인을 찍어주고 나가주셩야 하는데.. 왜 죽냐고요.. ") 
	        	return 0 
		end 
              end 

	      --if j.name == "editable" then 
                     --v[j.name] = toboolean(item_group:find_child(j.name):find_child("input_text").text)
              if (attr_map[j.name]) then
                     attr_map[j.name]()
              elseif(v[j.name] ~= nil)then 
					 if j.name == "w" or j.name == "h" then -- 0519
						if v[j.name] ~= tonumber(item_group:find_child(j.name):find_child("input_text").text) then 
                            v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
						end 
					 end 

                     if(tonumber(item_group:find_child(j.name):find_child("input_text").text)) then 
                            v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
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
	      elseif string.find(j.name,"color") then
		     attr_map["color"](j.name)
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
 		     	    v.check_size = csize_t
                         else
                            not_checkbox = true
		         end 
		     else
                            not_checkbox = true
                     end
                     if not_checkbox then 
                            local clip_t = {}
                            clip_t[1] = item_group:find_child("cx"):find_child("input_text").text
                            clip_t[2] = item_group:find_child("cy"):find_child("input_text").text
                            clip_t[3] = item_group:find_child("cw"):find_child("input_text").text
                            clip_t[4] = item_group:find_child("ch"):find_child("input_text").text
                            v.clip = clip_t
                     end 	
		elseif j.name == "bw" or j.name == "bh" then
                     local not_checkbox = false
                     if v.extra then 
		         if(v.extra.type == "CheckBox")then
                            local bsize_t = {}
                            bsize_t[1] = item_group:find_child("bw"):find_child("input_text").text
                            bsize_t[2] = item_group:find_child("bh"):find_child("input_text").text
 		     	    v.box_size = bsize_t
                         end
		     end 
		elseif j.name == "bx" or j.name == "by" then
                     local bpos_t = {}
                     bpos_t[1] = item_group:find_child("bx"):find_child("input_text").text
                     bpos_t[2] = item_group:find_child("by"):find_child("input_text").text
 		     v.b_pos = bpos_t
		elseif j.name == "ix" or j.name == "iy" then
                     local ipos_t = {}
                     ipos_t[1] = item_group:find_child("ix"):find_child("input_text").text
                     ipos_t[2] = item_group:find_child("iy"):find_child("input_text").text
 		     v.item_pos = ipos_t
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
                     v.viewport = viewport_t
		else 
		     print(j.name, " 처리해 주세요")
		end 
	   end 
       end 
       set_obj(new_object, v) 

       input_mode = S_SELECT
       if(v.name ~= "video1") then 
       	    table.insert(undo_list, {v.name, CHG, org_object, new_object})
       end 
       return org_object, new_object
end	

