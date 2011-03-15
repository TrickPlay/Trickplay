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
      ["itemsList"] = function()
                 local items, item
		 if item_group:find_child(j.name) then 
		    if item_group:find_child(j.name):find_child("items_list") then 
		        items = item_group:find_child(j.name):find_child("items_list")
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
              v[j.name] = skins[tonumber(item_group:find_child(j.name):find_child("skin_picker").selected_item)]
              end,
       ["anchor_point"] = function()
               v:move_anchor_point(item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	      item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
              end,     
       ["wrap_mode"] = function()
              v.wrap_mode = string.upper(item_group:find_child("wrap_mode"):find_child("input_text").text)
              end,        
       ["bwidth"] = function()
              v.border_width = tonumber(item_group:find_child("bwidth"):find_child("input_text").text
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
              if (attr_map[j.name]) then
                     attr_map[j.name]()
              elseif(v[j.name])then 
                     if(tonumber(item_group:find_child(j.name):find_child("input_text").text)) then 
                            v[j.name] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
                     else 
                            v[j.name] = item_group:find_child(j.name):find_child("input_text").text
                     end
	      elseif(j.name == "dr" or j.name == "dg" or j.name == "db" or j.name == "da") then 
 		     local color_t = {}
		     color_t = v.dot_color
		     color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.dot_color = color_t
              elseif(j.name == "r" or j.name == "g" or j.name == "b" or j.name == "a" or 
		     j.name == "rect_r" or j.name == "rect_g" or j.name == "rect_b" or j.name == "rect_a") then 
 		     local color_t = {}
		     color_t = v.color
		     color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.color = color_t
	      elseif(j.name == "br" or j.name == "bg" or j.name == "bb" or j.name == "ba"
	          or j.name == "bord_r" or j.name == "bord_g" or j.name == "bord_b" or j.name == "bord_a") then 
 		     local color_t = {}
 		     color_t = v.border_color
		     if v.extra then 
		         if(v.extra.type == "CheckBox")then 
 		     	     color_t = v.box_color
		         end 
		     end
		     color_t[rgba_map[j.name:sub(-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.border_color = color_t
	      elseif(j.name == "fr" or j.name == "fg" or j.name == "fb" or j.name == "fa") then  
 		     local color_t = {}
 		     color_t = v.f_color
		     color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.f_color = color_t
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
		else
		     print(j.name, " 처리해 주세요")
		end 
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




---------------------------------------------------------------------------------------------------------------------------------------------

	      elseif(j.name == "dr" or j.name == "dg" or j.name == "db" or j.name == "da") then 
 		     local color_t = {}
		     color_t = v.dot_color
		     color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.dot_color = color_t
              elseif(j.name == "r" or j.name == "g" or j.name == "b" or j.name == "a" or 
		     j.name == "rect_r" or j.name == "rect_g" or j.name == "rect_b" or j.name == "rect_a") then 
 		     local color_t = {}
		     color_t = v.color
		     color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.color = color_t
	      elseif(j.name == "br" or j.name == "bg" or j.name == "bb" or j.name == "ba"
	          or j.name == "bord_r" or j.name == "bord_g" or j.name == "bord_b" or j.name == "bord_a") then 
 		     local color_t = {}
		     local border = false
                     if v.extra then 
		         if(v.extra.type == "CheckBox")then
 		     	     color_t = v.box_color
		     	     color_t[rgba_map[j.name:sub(-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	                     v.box_color = color_t
		         elseif(v.extra.type == "RadioButton")then 
 		     	     color_t = v.button_color
		     	     color_t[rgba_map[j.name:sub(-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	                     v.button_color = color_t
			 else
                            border = true
		         end 
		     else
                         border = true
                     end
		     if border then 
 		     	 color_t = v.border_color
		     	 color_t[rgba_map[j.name:sub(-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	                 v.border_color = color_t
		     end
	      elseif(j.name == "sr" or j.name == "sg" or j.name == "sb" or j.name == "sa") then  
 		     local color_t = {}
		     if v.extra then 
		         if(v.extra.type == "LoadingBar")then
 		     		color_t = v.stroke_color
		     		color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             		v.stroke_color = color_t
		         elseif(v.extra.type == "RadioButton")then
 		     		color_t = v.select_color
		     		color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             		v.select_color = color_t
			 end 
		     end 
	      elseif(j.name == "fr" or j.name == "fg" or j.name == "fb" or j.name == "fa") then  
 		     local color_t = {}
 		     color_t = v.f_color
		     color_t[rgba_map[string.sub(j.name,-1, -1)]] = tonumber(item_group:find_child(j.name):find_child("input_text").text)
	             v.f_color = color_t



