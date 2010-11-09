
function inspector_apply (v, inspector)
      local org_object, new_object, color_t 
      local function toboolean(s) if (s == "true") then return true else return false end end
      if(v.type == "Rectangle") then
           org_object = Rectangle{}
           new_object = Rectangle{}
      elseif (v.type == "Text") then
           org_object = Text{}
           new_object = Text{}
      elseif (v.type == "Image") then
           org_object = Image{}
           new_object = Image{}
      elseif (v.type == "Clone") then
           org_object = Clone{}
           new_object = Clone{}
      elseif (v.type == "Group") then
           org_object = Group{}
           new_object = Group{}
      end

      if(v.type ~= "Video") then 
          org_object.name = v.name
          v.name = inspector:find_child("name"):find_child("input_text").text
          new_object.name = v.name

          org_object.x = v.x
          v.x = tonumber(inspector:find_child("x"):find_child("input_text").text)
          new_object.x = v.x

          org_object.y = v.y
          v.y = tonumber(inspector:find_child("y"):find_child("input_text").text)
          new_object.y = v.y

          org_object.z = v.z
          v.z = tonumber(inspector:find_child("z"):find_child("input_text").text)
          new_object.z = v.z

          org_object.w = v.w
          v.w = tonumber(inspector:find_child("w"):find_child("input_text").text)
          new_object.w = v.w

          org_object.h = v.h
          v.h = tonumber(inspector:find_child("h"):find_child("input_text").text)
          new_object.h = v.h

          org_object.opacity = v.opacity
          v.opacity = tonumber(inspector:find_child("opacity"):find_child("input_text").text)
          --v.extra.org_opacity = tonumber(inspector:find_child("opacity"):find_child("input_text").text)
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

          x_rotation_t[1] = tonumber(inspector:find_child("x_angle"):find_child("input_text").text)
          y_rotation_t[1] = tonumber(inspector:find_child("y_angle"):find_child("input_text").text)
          z_rotation_t[1] = tonumber(inspector:find_child("z_angle"):find_child("input_text").text)
	  v.x_rotation = x_rotation_t 
	  v.y_rotation = y_rotation_t
	  v.z_rotation = z_rotation_t

          new_object.x_rotation= v.x_rotation
          new_object.y_rotation= v.y_rotation
          new_object.z_rotation= v.z_rotation

	  org_object.anchor_point = v.anchor_point
	  v:move_anchor_point(inspector:find_child("anchor_point"):find_child("anchor").extra.anchor_point[1], 
	  inspector:find_child("anchor_point"):find_child("anchor").extra.anchor_point[2]) 
          new_object.anchor_point = v.anchor_point

    
          if(org_object.anchor_point ~= v.anchor_point) then 
	       if (v.extra.a_m ~= nil) then 
	            g:remove(v.extra.a_m) 
               end
               anchor_mark= ui.factory.draw_anchor_pointer()
	       anchor_mark.position = {v.x, v.y, v.z}
               v.extra.a_m = anchor_mark
	       g:add(anchor_mark)
          end

       else  --Video 
	   org_object = {}
           new_object = {}
	   org_object.name = v.name
           v.name = inspector:find_child("name"):find_child("input_text").text
           new_object.name = v.name
	
           org_object.source = v.source
           v.source = inspector:find_child("source"):find_child("input_text").text
	   if(v.source ~= org_object.source) then 
	   	mediaplayer:load(v.source)
	   end 
           new_object.source = v.source

	   org_object.viewport = v.viewport
           local viewport_t = {}
           viewport_t[1] = inspector:find_child("left"):find_child("input_text").text
           viewport_t[2] = inspector:find_child("top"):find_child("input_text").text
           viewport_t[3] = inspector:find_child("width"):find_child("input_text").text
           viewport_t[4] = inspector:find_child("height"):find_child("input_text").text
           v.viewport = viewport_t
	   if(v.viewport ~= org_object.viewport) then 
	   	mediaplayer:set_viewport_geometry(v.viewport[1], v.viewport[2], v.viewport[3], v.viewport[4])
	   end 
           new_object.viewport = v.viewport
	
           org_object.volume = v.volume
           v.volume = inspector:find_child("volume"):find_child("input_text").text
	   mediaplayer.volume = tonumber(v.volume)
           new_object.volume = v.volume

           org_object.loop = v.loop
           v.loop = toboolean(inspector:find_child("loop"):find_child("input_text").text)
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
           color_t[1] = tonumber(inspector:find_child("rect_r"):find_child("input_text").text)
           color_t[2] = tonumber(inspector:find_child("rect_g"):find_child("input_text").text)
           color_t[3] = tonumber(inspector:find_child("rect_b"):find_child("input_text").text)
           color_t[4] = tonumber(inspector:find_child("rect_a"):find_child("input_text").text)
	   v.color = color_t
           new_object.color = v.color

	   color_t = v.border_color
           org_object.border_color = v.border_color
           color_t[1] = tonumber(inspector:find_child("bord_r"):find_child("input_text").text)
           color_t[2] = tonumber(inspector:find_child("bord_g"):find_child("input_text").text)
           color_t[3] = tonumber(inspector:find_child("bord_b"):find_child("input_text").text)
	   v.border_color = color_t
           new_object.border_color = v.border_color

           org_object.border_width = v.border_width
           v.border_width = tonumber(inspector:find_child("bwidth"):find_child("input_text").text)
           new_object.border_width = v.border_width

       elseif (v.type == "Text") then
	   color_t = v.color
           org_object.color = v.color
           color_t[1] = tonumber(inspector:find_child("r"):find_child("input_text").text)
           color_t[2] = tonumber(inspector:find_child("g"):find_child("input_text").text)
           color_t[3] = tonumber(inspector:find_child("b"):find_child("input_text").text)
	   v.color = color_t
           new_object.color = v.color

           org_object.font = v.font
           v.font = inspector:find_child("font"):find_child("input_text").text
           new_object.font = v.font

           org_object.editable = v.editable
           v.editable = toboolean(inspector:find_child("editable"):find_child("input_text").text)
           new_object.editable = v.editable

           org_object.wrap = v.wrap
           v.wrap = toboolean(inspector:find_child("wrap"):find_child("input_text").text)
           new_object.wrap = v.wrap

           org_object.wrap_mode = v.wrap_mode
           v.wrap_mode = string.upper(inspector:find_child("wrap_mode"):find_child("input_text").text)
           new_object.wrap_mode = v.wrap_mode

       elseif (v.type == "Image") then
           org_object.src = v.src
           v.src = inspector:find_child("src"):find_child("input_text").text
           new_object.src = v.src

           local clip_t = {}
           local clip_use = toboolean(inspector:find_child("clip_use"):find_child("input_text").text)
	   if (clip_use == true) then 
                org_object.clip = v.clip
           	clip_t[1] = inspector:find_child("cx"):find_child("input_text").text
           	clip_t[2] = inspector:find_child("cy"):find_child("input_text").text
           	clip_t[3] = inspector:find_child("cw"):find_child("input_text").text
           	clip_t[4] = inspector:find_child("ch"):find_child("input_text").text
           	v.clip = clip_t
	   else 
		v.clip = {0,0, v.w, v.h}
	   end 
           new_object.clip = v.clip
		 
       elseif (v.type == "Clone") then
	   org_object.scale = v.scale
           local scale_t = {}
           scale_t[1] = inspector:find_child("x_scale"):find_child("input_text").text
           scale_t[2] = inspector:find_child("y_scale"):find_child("input_text").text
           v.scale = scale_t
           new_object.scale = v.scale

       elseif (v.type == "Group") then
	   org_object.scale = v.scale
           local scale_t = {}
           scale_t[1] = inspector:find_child("x_scale"):find_child("input_text").text
           scale_t[2] = inspector:find_child("y_scale"):find_child("input_text").text
           v.scale = scale_t
           new_object.scale = v.scale
       end

       input_mode = S_SELECT
       if(v.name ~= "video1") then 
       	    table.insert(undo_list, {v.name, CHG, org_object, new_object})
       end 
       return org_object, new_object
end	

local org_obj, new_obj

function grab_focus(v, inspector, attr) 

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




