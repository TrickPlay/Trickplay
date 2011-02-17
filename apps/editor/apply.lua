dofile("util.lua") --1209

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

      if is_this_widget(v) == true  then
              item_group = (inspector:find_child("si")).content
      else 
         item_group = inspector:find_child("item_group")
      end 

      org_object, new_object = obj_map[v.type]()
      set_obj(org_object, v) 

      dumptable(item_group.children)

      for i, j in pairs(item_group.children) do 
	   if j.name then
 	   if j.name == "itemsList" then 
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
	   end 


	   if j.name == "skin" then 
		v[j.name] = skins[tonumber(item_group:find_child(j.name):find_child("skin_picker").selected_item)]
	   end 

	   if j.name == "anchor_point" then 
	        v:move_anchor_point(item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	  	item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
	   end

	   if item_group:find_child(j.name):find_child("input_text")then 
		if(v[j.name]) then 
	             if j.name == "wrap_mode" then 
           	          v.wrap_mode = string.upper(item_group:find_child("wrap_mode"):find_child("input_text").text)
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
		elseif j.name == "bwidth" then 
           	     v.border_width = tonumber(item_group:find_child("bwidth"):find_child("input_text").text)
		else
		     print(j.name, " 처리해 주세요")
		end 
	   end 
	   end
      end 
      set_obj(new_object, v) 

--[[
           org_object.name = v.name

      if(is_available(item_group:find_child("name"):find_child("input_text").text) == true) then 
           v.name = item_group:find_child("name"):find_child("input_text").text
      else 
		print("the name is duplicated")
      end 
      new_object.name = v.name

      if(v.type ~= "Video") then 
          org_object.name = v.name
	  local i_name = item_group:find_child("name"):find_child("input_text").text
	  --i_name = string.gsub(i_name, "%A", "_") 
	  if(is_available(i_name) == true) then 
               v.name = i_name
	  end
          new_object.name = v.name

          org_object.x = v.x
          v.x = tonumber(item_group:find_child("x"):find_child("input_text").text)

          org_object.y = v.y
          v.y = tonumber(item_group:find_child("y"):find_child("input_text").text) 

-- 스크롤되는 영역 넓히는 코드 
	if(v.y + v.h > g.extra.canvas_t or v.y < g.extra.canvas_f or  
	   v.x + v.w > g.extra.canvas_xt or v.x < g.extra.canvas_xf) then 
	       v.extra.org_y = v.y 
	       v.extra.org_x = v.x 

	       if(g:find_child("screen_rect") ~= nil) then 
                    g:remove(g:find_child("screen_rect"))
	       end 

	       if (screen:find_child("scroll_bar") ~= nil) then 
	            screen:remove(screen:find_child("scroll_bar")) 
	            screen:remove(screen:find_child("scroll_box")) 
		    screen:remove(screen:find_child("y_0_mark"))
		    screen:remove(screen:find_child("y_1080_mark"))
	       end 

	       if (screen:find_child("xscroll_bar") ~= nil) then 
	            screen:remove(screen:find_child("xscroll_bar")) 
	            screen:remove(screen:find_child("xscroll_box")) 
		    screen:remove(screen:find_child("x_0_mark"))
		    screen:remove(screen:find_child("x_1920_mark"))
	       end 

	       for n,m in pairs (g.children) do 
		    if m.extra.type then 
		        if is_in_list(m.extra.type, widgets) == false then
	                    m.y = m.extra.org_y
	                    m.x = m.extra.org_x
				print("I GE MO GI ? ")
		        end 
		    end
	       end 

	       local x_scroll_from = 0 
	       local x_scroll_to = 0  
	       local y_scroll_from = 0
	       local y_scroll_to = 0 

	       if (v.y + v.h > g.extra.canvas_t) then 
		    y_scroll_to = v.y + v.h
	       else 
		    y_scroll_from = v.y
	       end 
			
	       if (v.x + v.w > g.extra.canvas_xt) then 
		    x_scroll_to = v.x + v.w 
	       else 
		    x_scroll_from = v.x
	       end 
		
	       if (x_scroll_from == 0) then 
	            x_scroll_from = g.extra.canvas_xf
	       end 
	       if (x_scroll_to == 0) then 
	            x_scroll_to = g.extra.canvas_xt
	       end 
	       if (y_scroll_from == 0) then 
	            y_scroll_from = g.extra.canvas_f
	       end 
	       if (y_scroll_to == 0) then 
	            y_scroll_to = g.extra.canvas_t
	       end 
		
	       make_scroll(x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)

	       for i,j in pairs(g.children) do 
		    if(g.extra.canvas_f < 0) then
			j.y = j.y - g.extra.canvas_f
		    end 
		    if(g.extra.canvas_xf < 0) then
			j.x = j.x - g.extra.canvas_xf
		    end 
	       end 
	  else 
	       v.extra.org_x = v.x
               v.x = math.floor(tonumber(item_group:find_child("x"):find_child("input_text").text) - g.extra.scroll_x-g.extra.canvas_xf) 
	       v.extra.org_y = v.y
               v.y = math.floor(tonumber(item_group:find_child("y"):find_child("input_text").text) - g.extra.scroll_y-g.extra.canvas_f) 
          end 


          new_object.x = v.x
          new_object.y = v.y 

          org_object.z = v.z
          v.z = tonumber(item_group:find_child("z"):find_child("input_text").text)
          new_object.z = v.z

	  if v.extra then 
          if is_in_list(v.extra.type, widgets) == false  then

          org_object.w = v.w
          v.w = tonumber(item_group:find_child("w"):find_child("input_text").text)
          new_object.w = v.w

          org_object.h = v.h
          v.h = tonumber(item_group:find_child("h"):find_child("input_text").text)
          new_object.h = v.h

	  else 

	  org_object.wwidth = v.wwidth
          v.wwidth = tonumber(item_group:find_child("bw"):find_child("input_text").text)
          new_object.wwidth = v.wwidth

          org_object.wheight = v.wheight
          v.wheight = tonumber(item_group:find_child("bh"):find_child("input_text").text)
          new_object.wheight = v.wheight

	  end 
	  end 

          org_object.opacity = v.opacity
          v.opacity = tonumber(item_group:find_child("opacity"):find_child("input_text").text)
          --v.extra.org_opacity = tonumber(item_group:find_child("opacity"):find_child("input_text").text)
          new_object.opacity = v.opacity
	  
          local x_rotation_t ={} 
	  local y_rotation_t ={}
	  local z_rotation_t ={}

          x_rotation_t = v.x_rotation
	  y_rotation_t = v.y_rotation
	  z_rotation_t = v.z_rotation
          org_object.x_rotation = v.x_rotation
          org_object.y_rotation = v.y_rotation
          org_object.z_rotation = v.z_rotation

          x_rotation_t[1] = tonumber(item_group:find_child("x_angle"):find_child("input_text").text)
          y_rotation_t[1] = tonumber(item_group:find_child("y_angle"):find_child("input_text").text)
          z_rotation_t[1] = tonumber(item_group:find_child("z_angle"):find_child("input_text").text)
	  v.x_rotation = x_rotation_t 
	  v.y_rotation = y_rotation_t
	  v.z_rotation = z_rotation_t

          new_object.x_rotation= v.x_rotation
          new_object.y_rotation= v.y_rotation
          new_object.z_rotation= v.z_rotation

	  org_object.anchor_point = v.anchor_point
	  v:move_anchor_point(item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	  item_group:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
          new_object.anchor_point = v.anchor_point

       else  --Video 
	   org_object = {}
           new_object = {}
	   org_object.name = v.name
	   if(is_available(item_group:find_child("name"):find_child("input_text").text) == true) then 
                v.name = item_group:find_child("name"):find_child("input_text").text
	   else 
		print("the name is duplicated")
	   end 
           new_object.name = v.name
	
           org_object.source = v.source
           v.source = item_group:find_child("source"):find_child("input_text").text
	   if(v.source ~= org_object.source) then 
	   	mediaplayer:load(v.source)
	   end 
           new_object.source = v.source

	   org_object.viewport = v.viewport
           local viewport_t = {}
           viewport_t[1] = item_group:find_child("left"):find_child("input_text").text
           viewport_t[2] = item_group:find_child("top"):find_child("input_text").text
           viewport_t[3] = item_group:find_child("width"):find_child("input_text").text
           viewport_t[4] = item_group:find_child("height"):find_child("input_text").text
           v.viewport = viewport_t
	   if(v.viewport ~= org_object.viewport) then 
	   	mediaplayer:set_viewport_geometry(v.viewport[1], v.viewport[2], v.viewport[3], v.viewport[4])
	   end 
           new_object.viewport = v.viewport
	
           org_object.volume = v.volume
           v.volume = item_group:find_child("volume"):find_child("input_text").text
	   mediaplayer.volume = tonumber(v.volume)
           new_object.volume = v.volume

           org_object.loop = v.loop
           v.loop = toboolean(item_group:find_child("loop"):find_child("input_text").text)
	   if(v.loop == true) then 
	  	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
     	   else  	
		mediaplayer.on_end_of_stream = function ( self ) self:seek(0) end
     	   end

           new_object.loop = toboolean(v.loop)
      end 


      if(v.type == "Rectangle") then
	   color_t = v.color
           org_object.color = v.color
           color_t[1] = tonumber(item_group:find_child("rect_r"):find_child("input_text").text)
           color_t[2] = tonumber(item_group:find_child("rect_g"):find_child("input_text").text)
           color_t[3] = tonumber(item_group:find_child("rect_b"):find_child("input_text").text)
           color_t[4] = tonumber(item_group:find_child("rect_a"):find_child("input_text").text)
	   v.color = color_t
           new_object.color = v.color
 item_group:find_child(j.name):find_child("input_text").text

	   color_t = v.border_color
           org_object.border_color = v.border_color
           color_t[1] = tonumber(item_group:find_child("bord_r"):find_child("input_text").text)
           color_t[2] = tonumber(item_group:find_child("bord_g"):find_child("input_text").text)
           color_t[3] = tonumber(item_group:find_child("bord_b"):find_child("input_text").text)
	   v.border_color = color_t
           new_object.border_color = v.border_color

           org_object.border_width = v.border_width
           v.border_width = tonumber(item_group:find_child("bwidth"):find_child("input_text").text)
           new_object.border_width = v.border_width

       elseif (v.type == "Text") then
	   color_t = v.color
           org_object.color = v.color
           color_t[1] = tonumber(item_group:find_child("r"):find_child("input_text").text)
           color_t[2] = tonumber(item_group:find_child("g"):find_child("input_text").text)
           color_t[3] = tonumber(item_group:find_child("b"):find_child("input_text").text)
	   v.color = color_t
           new_object.color = v.color

           org_object.font = v.font
           v.font = item_group:find_child("font"):find_child("input_text").text
           new_object.font = v.font

           org_object.editable = v.editable
           v.editable = toboolean(item_group:find_child("editable"):find_child("input_text").text)
           new_object.editable = v.editable

           org_object.wrap = v.wrap
           v.wrap = toboolean(item_group:find_child("wrap"):find_child("input_text").text)
           new_object.wrap = v.wrap

           org_object.wrap_mode = v.wrap_mode
           v.wrap_mode = string.upper(item_group:find_child("wrap_mode"):find_child("input_text").text)
           new_object.wrap_mode = v.wrap_mode

       elseif (v.type == "Image") then
           org_object.src = v.src
           v.src = item_group:find_child("src"):find_child("input_text").text
           new_object.src = v.src

           local clip_t = {}
           local clip_use = toboolean(item_group:find_child("clip_use"):find_child("input_text").text)
	   if (clip_use == true) then 
                org_object.clip = v.clip
           	clip_t[1] = item_group:find_child("cx"):find_child("input_text").text
           	clip_t[2] = item_group:find_child("cy"):find_child("input_text").text
           	clip_t[3] = item_group:find_child("cw"):find_child("input_text").text
           	clip_t[4] = item_group:find_child("ch"):find_child("input_text").text
           	v.clip = clip_t
	   else 
		v.clip = {0,0, v.w, v.h}
	   end 
           new_object.clip = v.clip
		 
       elseif (v.type == "Clone") or (v.type == "Group") then
	   org_object.scale = v.scale
           local scale_t = {}
           scale_t[1] = item_group:find_child("x_scale"):find_child("input_text").text
           scale_t[2] = item_group:find_child("y_scale"):find_child("input_text").text
           v.scale = scale_t
           new_object.scale = v.scale

	 --kk
      	   if v.extra th item_group:find_child(j.name):find_child("input_text").text
en 
               if is_in_list(v.extra.type, widgets) == true  then
		    
               end
	   end 

	end
--]]
       input_mode = S_SELECT
       if(v.name ~= "video1") then 
       	    table.insert(undo_list, {v.name, CHG, org_object, new_object})
       end 
       return org_object, new_object
end	

--[[ --0208 
local org_obj, new_obj

local function grab_focus(v, inspector, attr)  --local 0208

     current_focus = inspector:find_child(attr)
 
     if (inspector == nil ) then print ("yugi !!") end 

     if inspector:find_child(attr) and  
          inspector:find_child(attr):find_child("input_text") then
          inspector:find_child(attr):find_child("input_text"):grab_key_focus()
          inspector:find_child(attr):find_child("input_text"):set{cursor_visible = true, cursor_size = 3}
          inspector:find_child(attr).extra.on_focus_in()

	  input_txt = inspector:find_child(attr):find_child("input_text")
	  function input_txt:on_key_down(key)
	       if key == keys.Return or
                  key == keys.Tab or 
                  key == keys.Down then
                     inspector:find_child(attr).extra.on_focus_out()
                     inspector:find_child(attr):find_child("input_text"):set{cursor_visible = false}
                     grab_focus(v, inspector, inspector:find_child(attr):find_child("next_attr").text)
               end
   	  end 
    elseif inspector:find_child(attr):find_child("button") then
 	      inspector:find_child(attr):find_child("button"):grab_key_focus()
              inspector:find_child(attr).extra.on_focus_in()
              button = inspector:find_child(attr):find_child("button")
              function button:on_key_down(key)
                   if key == keys.Return then
                      if (attr == "view code") then 
		          screen:remove(inspector)
		          current_inspector = nil
		          editor.n_selected(v, true)
                          screen.grab_key_focus(screen) 
			  -- org_obj, new_obj = inspector_apply (v, inspector) 
		          editor.view_code(v)
	                  return true
		      elseif (attr == "apply") then 
			  org_obj, new_obj = inspector_apply (v, inspector) 
		          screen:remove(inspector)
		          current_inspector = nil
		          editor.n_selected(v, true)
                          screen.grab_key_focus(screen) 
		      elseif (attr == "cancel") then 
		          screen:remove(inspector)
		          current_inspector = nil
		          editor.n_selected(v, true)
                          screen.grab_key_focus(screen) 
	                  return true
		      end 
 		   elseif key == keys.Tab or key == keys.Down then 
                      inspector:find_child(attr).extra.on_focus_out()
                      grab_focus(v, inspector, inspector:find_child(attr):find_child("next_attr").text)
                   end
              end

        end
end 
]]



