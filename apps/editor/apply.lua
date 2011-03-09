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
		       v.items[next] = item:find_child("textInput").text
                     end 
		 end
              end,
       ["skin"] = function()
              v["skin"] = skins[tonumber(item_group:find_child("skin"):find_child("skin_picker").selected_item)]
              end,
       ["anchor_point"] = function()
               v:move_anchor_point(item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	      item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
              end,     
       ["wrap_mode"] = function()
              v.wrap_mode = string.upper(item_group:find_child("wrap_mode"):find_child("input_text").text)
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
	      if j.name == "editable" then 
                     v[j.name] = toboolean(item_group:find_child(j.name):find_child("input_text").text)
              elseif (attr_map[j.name]) then
                     attr_map[j.name]()
              elseif(v[j.name] ~= nil)then 
                     if(tonumber(item_group:find_child(j.name):find_child("input_text").text)) then 
                            v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
			    print(j.name, " is number")
                     else 
                            v[j.name] = item_group:find_child(j.name):find_child("input_text").text
			    if v[j.name] == "true" or v[j.name] == "false" then
				v[j.name] = toboolean(item_group:find_child(j.name):find_child("input_text").text)
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
	      elseif j.name == "clip_use" or j.name == "cx" or j.name == "cy" or j.name == "cw" or j.name == "ch" then
                     local not_checkbox = false
                     if v.extra then 
		         if(v.extra.type == "CheckBox")then
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
                            local clip_use = toboolean(item_group:find_child("clip_use"):find_child("input_text").text)
                            if (clip_use == true) then 
                                   clip_t[1] = item_group:find_child("cx"):find_child("input_text").text
                                   clip_t[2] = item_group:find_child("cy"):find_child("input_text").text
                                   clip_t[3] = item_group:find_child("cw"):find_child("input_text").text
                                   clip_t[4] = item_group:find_child("ch"):find_child("input_text").text
                                   v.clip = clip_t
                            else 
                                   v.clip = {0,0, v.w, v.h}
                            end
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
				v.extra.focus[focus_map[n]] = item_group:find_child("text"..n).text
				if focus_match[n] then 
					if g:find_child(item_group:find_child("text"..n).text).extra.focus then 
					     g:find_child(item_group:find_child("text"..n).text).extra.focus[focus_match[n]] = v.name
					else
					     g:find_child(item_group:find_child("text"..n).text).extra.focus = {} 
					     g:find_child(item_group:find_child("text"..n).text).extra.focus[focus_match[n]] = v.name
					end
						
				end 
			  end 
		     end 
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

