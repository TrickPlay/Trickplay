-----------
-- Utils 
-----------

local factory = ui.factory

function is_available(new_name)
    if(g:find_child(new_name) ~= nil) then 
	return false 
    else 
	return true
    end
end 

function is_lua_file(fn)
	     i, j = string.find(fn, ".lua")
	     if (j == string.len(fn)) then
		return true
	     else 
		return false
	     end 
end 
function is_img_file(fn)
	     i, j = string.find(fn, ".png")
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
function is_mp4_file(fn)
	     i, j = string.find(fn, ".mp4")
	     if (j == string.len(fn)) then
		return true
	     else 
		return false
	     end 
end 

-- Clear background images 
function clear_bg()
    BG_IMAGE_20.opacity = 0
    BG_IMAGE_40.opacity = 0
    BG_IMAGE_80.opacity = 0
    BG_IMAGE_white.opacity = 0
    BG_IMAGE_import.opacity = 0
end

function values(t) 
	local j = 0 
	return function () j = j+1 return t[j] end 
end 

function abs(a) if(a>0) then return a else return -a end end

function getObjnames()
    local obj_names = ""
    local n = table.getn(g.children)
    for i, v in pairs(g.children) do
        if (i ~= n) then
             obj_names = obj_names..v.name..","
        else
             obj_names = obj_names..v.name
        end
    end
    return obj_names
end

function find_parent(child_obj) 
   for i, v in pairs(g.children) do
   	if g:find_child(v.name) then
   	     if (v.type == "Group") then 
   	          if(v:find_child(child_obj.name)) then
		       return v
   		  end 
   	     end 
   	end
   end
end 

local project
local base
local projects = {}

function set_app_path()

    -- Get the user's home directory and make sure it is valid
    local home = editor_lb:get_home_dir()
    
    assert( home )
    
    -- The base directory where the editor will store its files, make sure
    -- we are able to create it (or it already exists )
    
    base = editor_lb:build_path( home , "trickplay-editor"  )

    assert( editor_lb:mkdir( base ) )
    
    -- The list of files and directories there. We go through it and look for
    -- directories.
    local list = editor_lb:readdir( base )
    
    for i = 1 , # list do
    
        if editor_lb:dir_exists( editor_lb:build_path( base , list[ i ] ) ) then
        
            table.insert( projects , list[ i ] )
            
        end
        
    end
    
    input_mode = S_POPUP

    printMsgWindow("Select Project : ", "projectlist")
    inputMsgWindow("projectlist")

end 


function create_on_button_down_f(v)
	v.extra.selected = false
	local org_object, new_object 
	
        function v:on_button_down(x,y,button,num_clicks)
	   if (input_mode ~= S_RECTANGLE) then 
	   if(v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw") then 
	     if(input_mode == S_SELECT) and  (screen:find_child("msgw") == nil) then
	       if (v.extra.is_in_group == true and control == false) then 
		    local p_obj = find_parent(v)
                    if(button == 3 or num_clicks >= 2) then
                         editor.inspector(p_obj)
                         return true
                    end 

	            if(input_mode == S_SELECT and p_obj.extra.selected == false) then 
		     	editor.selected(p_obj)
	            elseif (p_obj.extra.selected == true) then 
		     	editor.n_select(p_obj)
	       	    end
	            org_object = copy_obj(p_obj)
           	    dragging = {p_obj, x - p_obj.x, y - p_obj.y }
           	    return true
	      else 
                    if(button == 3 or num_clicks >= 2) then
                         editor.inspector(v)
                         return true
                    end 
	            if(input_mode == S_SELECT and v.extra.selected == false) then 
		     	editor.selected(v) 
	            elseif (v.extra.selected == true) then 
			if(v.type == "Text") then 
			      v:set{cursor_visible = true}
			      v:set{editable= true}
     			      v:grab_key_focus(v)
			end 
			editor.n_select(v) 
	       	    end
	            org_object = copy_obj(v)
           	    dragging = {v, x - v.x, y - v.y }
           	    return true
	   	 end
              end
	   elseif( input_mode ~= S_RECTANGLE) then  
                 dragging = {v, x - v.x, y - v.y }
           	 return true
           end
	  end
           --return true .. 렉탱글 안에서 또 렉탱글 글릴때 안되아서.. 뺌
        end

        function v:on_button_up(x,y,button,num_clicks)
	   if (input_mode ~= S_RECTANGLE) then 
	   if(v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw" ) then 
	     if(input_mode == S_SELECT) and (screen:find_child("msgw") == nil) then
	        if (v.extra.is_in_group == true) then 
		    local p_obj = find_parent(v)
		    new_object = copy_obj(p_obj)
		    if(dragging ~= nil) then 
	            	local actor , dx , dy = unpack( dragging )
	            	new_object.position = {x-dx, y-dy}
			if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
			editor.n_select(v, false, dragging) 
			editor.n_select(new_object, false, dragging) 
			editor.n_select(org_object, false, dragging) 
                    	table.insert(undo_list, {p_obj.name, CHG, org_object, new_object})
			end 
	            	dragging = nil
	            end 
		    return true 
		elseif( input_mode ~= S_RECTANGLE) then  
	      	    if(dragging ~= nil) then 
	               local actor , dx , dy = unpack( dragging )
		       new_object = copy_obj(v)
	               new_object.position = {x-dx, y-dy}
	
		       local border = screen:find_child(v.name.."border")
		       local group_pos
	       	       if(border ~= nil) then 
		             if (v.extra.is_in_group == true) then
			     group_pos = get_group_position(v)
	                     border.position = {x - dx + group_pos[1], y - dy + group_pos[2]}
		             else 
	                     border.position = {x -dx, y -dy}
		             end 
	                end 

			local am = screen:find_child(v.name.."a_m") 
 
			for i=1, v_guideline,1 do 
			   if(screen:find_child("v_guideline"..i) ~= nil) then 
			     local gx = screen:find_child("v_guideline"..i).x 
			     if(15 >= math.abs(gx - x + dx)) then  
				new_object.x = gx
				v.x = gx
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
				v.y = gy
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
                    	     table.insert(undo_list, {v.name, CHG, org_object, new_object})
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

function get_group_position(child_obj)
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


	

	
function set_obj (f, v)

      if f == nil then 
	    print("ERROR f is nill") 
	    print("ERROR f is nill") 
	    print("ERROR f is nill") 
	    print("ERROR f is nill") 
	    print("ERROR f is nill") 
	    print("ERROR f is nill") 
	    print("ERROR f is nill") 
      end 

      if(f.type == "Rectangle") then
           f.color = v.color
           f.border_color = v.border_color
           f.border_width = v.border_width

       elseif (v.type == "Text") then
           f.color = v.color
           f.font = v.font
           f.text = v.text
           f.editable = v.editable
           f.wants_enter = v.wants_enter
           f.wrap = v.wrap
           f.wrap_mode = v.wrap_mode
       elseif (v.type == "Image") then
           f.src = v.src
           f.clip = v.clip
       elseif (v.type == "Clone") then
	   f.scale = v.scale
           f.source = v.source
       elseif (v.type == "Group") then
	   f.scale = v.scale
       end
       f.x_rotation = v.x_rotation
       f.y_rotation = v.y_rotation
       f.z_rotation = v.z_rotation
       f.anchor_point = v.anchor_point
       f.name = v.name
       f.x = v.x
       f.y = v.y
       f.z = v.z
       f.w = v.w
       f.h = v.h
       f.opacity = v.opacity
       return new_object
end	


function copy_obj (v)

      local new_object
      if(v.type == "Rectangle") then
           new_object = Rectangle{}
           new_object.color = v.color
           new_object.border_color = v.border_color
           new_object.border_width = v.border_width

       elseif (v.type == "Text") then
           new_object = Text{}
           new_object.color = v.color
           new_object.font = v.font
           new_object.text = v.text
           new_object.editable = v.editable
           new_object.wants_enter = v.wants_enter
           new_object.wrap = v.wrap
           new_object.wrap_mode = v.wrap_mode
       elseif (v.type == "Image") then
           new_object = Image{}
           new_object.src = v.src
           new_object.clip = v.clip
       elseif (v.type == "Clone") then
           new_object = Clone{}
	   new_object.scale = v.scale
           new_object.source = v.source
       elseif (v.type == "Group") then
           new_object = Group{}
	   new_object.scale = v.scale
       end
       new_object.x_rotation = v.x_rotation
       new_object.y_rotation = v.y_rotation
       new_object.z_rotation = v.z_rotation
       new_object.anchor_point = v.anchor_point
       new_object.name = v.name
       new_object.x = v.x
       new_object.y = v.y
       new_object.z = v.z
       new_object.w = v.w
       new_object.h = v.h
       new_object.opacity = v.opacity
       return new_object
end	

--------------------------------
-- Inspector 
--------------------------------

local input_t
function make_attr_t(v)
function toboolean(s) if (s == "true") then return true else return false end end
  local attr_t 


  if(v.type ~= "Video") then
     if (v.extra.type == "Button") then 
	attr_t =
      {
             {"title", "INSPECTOR : "..string.upper(v.extra.type)},
             {"caption", "OBJECT NAME"},
             {"name", v.name,"name"},
             {"line",""},
             {"x", math.floor(v.x + g.extra.scroll_x + g.extra.canvas_xf) , "x"},
             {"y", math.floor(v.y + g.extra.scroll_y + g.extra.canvas_f), "y"},
             {"z", math.floor(v.z), "z"},
             {"bw", math.floor(v.bwidth), "bw"},
             {"bh", math.floor(v.bheight), "bh"},
             {"line",""}
      }

     else 
	attr_t =
      {
             {"title", "INSPECTOR : "..string.upper(v.type)},
             {"caption", "OBJECT NAME"},
             {"name", v.name,"name"},
             {"line",""},
             {"x", math.floor(v.x + g.extra.scroll_x + g.extra.canvas_xf) , "x"},
             {"y", math.floor(v.y + g.extra.scroll_y + g.extra.canvas_f), "y"},
             {"z", math.floor(v.z), "z"},
             {"w", math.floor(v.w), "w"},
             {"h", math.floor(v.h), "h"},
             {"line",""}
      }

     end 
  else 
      attr_t =
      {
             {"title", "INSPECTOR : "..string.upper(v.type)},
             {"caption", "OBJECT NAME"},
             {"name", v.name,"name"},
             {"line",""},
             {"caption", "SOURCE"},
             {"source", v.source, "source"},
             {"line",""},
             {"caption", "VIEW PORT"},
             {"left", v.viewport[1], "x"},
             {"top", v.viewport[2], "y"},
             {"width", v.viewport[3], "w"},
             {"height", v.viewport[4], "h"},
             {"line",""},
             {"volume", v.volume, "volume"},
             {"loop", v.loop, "loop"},
             {"line",""}
      }
  end 

      if (v.type == "Text") then
        table.insert(attr_t, {"caption", "COLOR "})
        local color_t = v.color 
        if color_t == nil then 
             color_t = {0,0,0}
        end
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"r", color_t[1], "r"})
        table.insert(attr_t, {"g", color_t[2], "g"})
        table.insert(attr_t, {"b", color_t[3], "b"})
        table.insert(attr_t, {"font", v.font,"font "})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"editable", v.editable,"editable"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"wrap", v.wrap, "wrap"})
        table.insert(attr_t, {"wrap_mode", v.wrap_mode,"wrap mode"})
	table.insert(attr_t, {"line",""})
 	table.insert(attr_t, {"caption", "ROTATION  "})
        local x_rotation_t = v.x_rotation 
        local y_rotation_t = v.y_rotation 
        local z_rotation_t = v.z_rotation 
        table.insert(attr_t, {"x_angle", x_rotation_t[1], "x"})
        table.insert(attr_t, {"y_angle", y_rotation_t[1], "y"})
        table.insert(attr_t, {"z_angle", z_rotation_t[1], "z"})

 	table.insert(attr_t, {"anchor_point", v.anchor_point,"ANCHOR POINT"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})

      elseif (v.type  == "Rectangle") then
        color_t = v.color 
        if color_t == nil then 
             color_t = {0,0,0,0}
        end
        table.insert(attr_t, {"caption", "FILL COLOR"})
        table.insert(attr_t, {"rect_r", color_t[1], "r"})
        table.insert(attr_t, {"rect_g", color_t[2], "g"})
        table.insert(attr_t, {"rect_b", color_t[3], "b"})
        table.insert(attr_t, {"rect_a", color_t[4], "a"})
        color_t = v.border_color 
        if color_t == nil then 
             color_t = {0,0,0}
        end
        table.insert(attr_t, {"caption", "BORDER COLOR"})
        table.insert(attr_t, {"bord_r", color_t[1], "r"})
        table.insert(attr_t, {"bord_g", color_t[2], "g"})
        table.insert(attr_t, {"bord_b", color_t[3], "b"})
        table.insert(attr_t, {"bwidth", v.border_width, "border width"})
        table.insert(attr_t, {"line",""})
	table.insert(attr_t, {"caption", "ROTATION  "})
        local x_rotation_t = v.x_rotation 
        local y_rotation_t = v.y_rotation 
        local z_rotation_t = v.z_rotation 
        table.insert(attr_t, {"x_angle", x_rotation_t[1], "x"})
        table.insert(attr_t, {"y_angle", y_rotation_t[1], "y"})
        table.insert(attr_t, {"z_angle", z_rotation_t[1], "z"})

 	table.insert(attr_t, {"anchor_point", v.anchor_point,"ANCHOR POINT"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})

      elseif (v.type  == "Image") then
        table.insert(attr_t, {"caption", "SOURCE LOCATION"})
        table.insert(attr_t, {"src", v.src,"source"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"caption", "CLIPPING REGION"})
        local clip_t = v.clip
        if clip_t == nil then
             clip_t = {0,0 ,v.w, v.h}
        end
        table.insert(attr_t, {"clip_use", false, "use"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"cx", clip_t[1], "x"})
        table.insert(attr_t, {"cy", clip_t[2], "y"})
        table.insert(attr_t, {"cw", clip_t[3], "w"})
        table.insert(attr_t, {"ch", clip_t[4], "h"})
        table.insert(attr_t, {"line",""})
 	table.insert(attr_t, {"caption", "ROTATION  "})
        local x_rotation_t = v.x_rotation 
        local y_rotation_t = v.y_rotation 
        local z_rotation_t = v.z_rotation 
        table.insert(attr_t, {"x_angle", x_rotation_t[1], "x"})
        table.insert(attr_t, {"y_angle", y_rotation_t[1], "y"})
        table.insert(attr_t, {"z_angle", z_rotation_t[1], "z"})

 	table.insert(attr_t, {"anchor_point", v.anchor_point,"ANCHOR POINT"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})

      elseif (v.type  == "Group" or v.type == "Clone") then

        table.insert(attr_t, {"caption", "SCALE"})
	local scale_t = v.scale
        if scale_t == nil then
             scale_t = {1,1} 
        end

        table.insert(attr_t, {"x_scale", scale_t[1], "x"})
        table.insert(attr_t, {"y_scale", scale_t[2], "y"})

	table.insert(attr_t, {"line",""})
 	table.insert(attr_t, {"caption", "ROTATION  "})
        local x_rotation_t = v.x_rotation 
        local y_rotation_t = v.y_rotation 
        local z_rotation_t = v.z_rotation 
        table.insert(attr_t, {"x_angle", x_rotation_t[1], "x"})
        table.insert(attr_t, {"y_angle", y_rotation_t[1], "y"})
        table.insert(attr_t, {"z_angle", z_rotation_t[1], "z"})

 	table.insert(attr_t, {"anchor_point", v.anchor_point,"ANCHOR POINT"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})
        table.insert(attr_t, {"line","", "hide"})

	if (v.extra.type == "Button") then 
             table.insert(attr_t, {"Caption","Button", "Caption"})
	end 

      end

      if(v.type ~= "Video") then
      	table.insert(attr_t, {"line",""})
      	table.insert(attr_t, {"opacity", v.opacity, "opacity"})
      	table.insert(attr_t, {"line",""})
      end 

      table.insert(attr_t, {"button", "view code", "view code"})
      table.insert(attr_t, {"button", "apply", "apply"})
      table.insert(attr_t, {"button", "cancel", "cancel"})

      return attr_t
end

function itemTostring(v)
    local itm_str = ""
    local indent       = "\n\t\t"
    local b_indent       = "\n\t"
    
    if(v.type == "Rectangle") then
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "border_color={"..table.concat(v.border_color,",").."},"..indent..
         "border_width="..v.border_width..","..indent.."color={"..table.concat(v.color,",").."},"..indent..
         "size = {"..table.concat(v.size,",").."},"..indent..
         "anchor_point = {"..table.concat(v.anchor_point,",").."},"..indent..
         "x_rotation={"..table.concat(v.x_rotation,",").."},"..indent..
         "y_rotation={"..table.concat(v.y_rotation,",").."},"..indent..
         "z_rotation={"..table.concat(v.z_rotation,",").."},"..indent..
         "position = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."}"..","..indent.."opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Image") then

	if (v.clip == nil) then v.clip = {0, 0,v.w, v.h} end 
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "src=\""..v.src.."\","..indent..
         "position = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."},"..indent..
         "size = {"..table.concat(v.size,",").."},"..indent..
         "clip = {"..table.concat(v.clip,",").."},"..indent..
         "anchor_point = {"..table.concat(v.anchor_point,",").."},"..indent..
         "x_rotation={"..table.concat(v.x_rotation,",").."},"..indent..
         "y_rotation={"..table.concat(v.y_rotation,",").."},"..indent..
         "z_rotation={"..table.concat(v.z_rotation,",").."},"..indent..
         "opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Text") then
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "text=\""..v.text.."\","..indent..
         "font=\""..v.font.."\","..indent..
         "color={"..table.concat(v.color,",").."},"..indent..
         "size={"..table.concat(v.size,",").."},"..indent..
         "position = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."},"..indent..
         "anchor_point = {"..table.concat(v.anchor_point,",").."},"..indent..
         "x_rotation={"..table.concat(v.x_rotation,",").."},"..indent..
         "y_rotation={"..table.concat(v.y_rotation,",").."},"..indent..
         "z_rotation={"..table.concat(v.z_rotation,",").."},"..indent..
         "editable="..tostring(v.editable)..","..indent..
         "reactive="..tostring(v.reactive)..","..indent..
         "wants_enter="..tostring(v.wants_enter)..","..indent..
         "wrap="..tostring(v.wrap)..","..indent..
         "wrap_mode=\""..v.wrap_mode.."\","..indent.."opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Clone") then
	itm_str =  itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "size={"..table.concat(v.size,",").."},"..indent..
         "position = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."},"..indent..
         "source="..v.source.name..","..indent..
         "scale = {"..table.concat(v.scale,",").."},"..indent..
         "anchor_point = {"..table.concat(v.anchor_point,",").."},"..indent..
         "x_rotation={"..table.concat(v.x_rotation,",").."},"..indent..
         "y_rotation={"..table.concat(v.y_rotation,",").."},"..indent..
         "z_rotation={"..table.concat(v.z_rotation,",").."},"..indent..
         "opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Group") then
	local i = 1
        local children = ""
        for e in values(v.children) do
		itm_str = itm_str..itemTostring(e)
		if i == 1 then
			children = children..e.name
		else 
			children = children..","..e.name
		end
		i = i + 1
        end 

	itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
        "name=\""..v.name.."\","..indent..
        "size={"..table.concat(v.size,",").."},"..indent..
        "position = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."},"..indent..
	"children = {"..children.."},"..indent..
        "scale = {"..table.concat(v.scale,",").."},"..indent..
        "anchor_point = {"..table.concat(v.anchor_point,",").."},"..indent..
        "x_rotation={"..table.concat(v.x_rotation,",").."},"..indent..
        "y_rotation={"..table.concat(v.y_rotation,",").."},"..indent..
        "z_rotation={"..table.concat(v.z_rotation,",").."},"..indent..
        "opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Video") then
	itm_str = itm_str..v.name.." = ".."{"..indent..
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

    end
    return itm_str
end

local msgw_focus = ""

function create_tiny_input_box(txt)
     	local box_g = Group {}
     	local box = factory.draw_tiny_ring()
     	local box_focus = factory.draw_tiny_focus_ring()
	box_g.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
	box_g:add(box)
	box_focus.opacity = 0 
	box_g:add(box_focus)
    	box_g:add(txt)

        function box_g.extra.on_focus_in()
		txt:grab_key_focus(txt)
		txt.cursor_visible = true
	        box.opacity = 0 
            	box_focus.opacity = 255
		msgw_focus = "input_b"
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
		txt.cursor_visible = false
        end

	return box_g
end 



local function create_small_input_box(txt)
     	local box_g = Group {}
     	local box = factory.draw_small_ring()
     	local box_focus = factory.draw_small_focus_ring()
	box_g.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
	box_g:add(box)
	box_focus.opacity = 0 
	box_g:add(box_focus)
    	box_g:add(txt)

        function box_g.extra.on_focus_in()
		txt:grab_key_focus(txt)
		txt.cursor_visible = true
	        box.opacity = 0 
            	box_focus.opacity = 255
		msgw_focus = "input_b"
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
		txt.cursor_visible = false
        end

	return box_g
end 



local function create_input_box()
     	local box_g = Group {}
        local input_l = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
              position = {25, 10}, text = project.."/" }
        input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
        -- 0111 position = {input_l.w + 25, 10}, text = "" , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
        position = {input_l.w + 25, 10}, text = strings[""] , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
     	local box = factory.draw_ring()
     	local box_focus = factory.draw_focus_ring()
	box_g.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
	box_g:add(box)
	box_focus.opacity = 0 
	box_g:add(box_focus)
    	box_g:add(input_l)
    	box_g:add(input_t)

        function box_g.extra.on_focus_in()
		input_t:grab_key_focus(input_t)
	        box.opacity = 0 
            	box_focus.opacity = 255
		msgw_focus = "input_b"
		input_t.cursor_visible = true
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
		input_t.cursor_visible = false
        end

	return box_g
end 

--------------------------------
-- Message Window 
--------------------------------

local  msgw = Group {
	     name = "msgw",
	     position ={400, 400},
	     anchor_point = {0,0},
             children =
             {
             }
     }
local msgw_cur_x = 25  
local msgw_cur_y = 50

function cleanMsgWindow()
     msgw.children = {}
     msgw_cur_x = 25
     msgw_cur_y = 50
     screen:remove(msgw)
     input_mode = S_SELECT
end 

local projectlist_len 
local selected_prj 	= ""

function printMsgWindow(txt, name)
     if (name == nil) then
        name = "pritMsgWindow"
     end

     txt_sz = string.len(txt) 
     local n = table.getn(projects)

     if (name == "aleady_exists" ) then
	txt_sz = txt_sz - 50
     elseif(name == "projectlist") then  
     	projectlist_len = n * 45 
	txt_sz = projectlist_len + 20  
	if (n > 14) then 
		msgw.position = {400, 100}
	elseif (n > 10) then 
		msgw.position = {400, 200}
	elseif (n > 5) then 
		msgw.position = {400, 300}
	end 
     else 
     	i, j = string.find(txt, "\n")
     	if (j ~= nil) then 
	     txt_sz = txt_sz + 20 
        end 
     end 
     local msgw_bg = factory.make_popup_bg("msgw", txt_sz)
     msgw:add(msgw_bg)
     input_mode = S_POPUP
     msgw:add(Text{name= name, text = txt, font= "DejaVu Sans 32px",
     color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"})     
  

     if(name == "projectlist") then  
         msgw_cur_x = msgw_cur_x + string.len(txt) * 20
	 
     	 for i, j in pairs (projects) do  
	     local prj_text = Text {text = j, color = {255,255,255,255}, font= "DejaVu Sans 32px", color = "FFFFFF"}
	     prj_text.reactive = true
	     prj_text.position = {msgw_cur_x, msgw_cur_y+10}
	     prj_text.extra.index = i 
	     prj_text.name = "prj"..i 
	     msgw:add(prj_text)
	     msgw_cur_y = msgw_cur_y + 32 + 10 -- 10 : line padding 

	     function prj_text.extra.on_focus_in()
                  prj_text:set{color = {0,255,0,255}}
	 	  prj_text:grab_key_focus()
		  msgw_focus = prj_text.name
             end
    
             function prj_text.extra.on_focus_out()
                  prj_text:set{color = {255,255,255,255}}
             end

	     function prj_text:on_key_down(key)
		if(key == keys.Return) then 
		     if( selected_prj == prj_text.name) then 
			selected_prj = ""
			prj_text.extra.on_focus_in()
		     else
			if( selected_prj ~= "") then  
			    if(msgw:find_child(selected_prj) ~= nil) then 
				msgw:find_child(selected_prj):set{color = {255,255,255,255}} 
			    end 
			end 
			selected_prj = prj_text.name
		     end 
		elseif(key == keys.Tab and shift == false) or (key == keys.Down) or key == keys.Right then 
			prj_text.extra.on_focus_out()
			if(prj_text.name == selected_prj) then
			     prj_text:set{color = {0,255,0,255}}
			end 
			if (prj_text.extra.index < n) then 
				local k = prj_text.extra.index + 1
				msgw:find_child("prj"..k).extra.on_focus_in()
			else 
				msgw:find_child("input_b").extra.on_focus_in()
			end 
		elseif(key == keys.Tab and shift == true) or key == keys.Up or key == keys.Left then 
			if (prj_text.extra.index > 1) then 
				prj_text.extra.on_focus_out()
				if(prj_text.name == selected_prj) then
			     	     	prj_text:set{color = {0,255,0,255}}
				end 
				local k = prj_text.extra.index - 1
				msgw:find_child("prj"..k).extra.on_focus_in()
			end 
		end 
		return true 
	     end 

	     function prj_text:on_button_down(x,y,button,num)
	         if( selected_prj ~= "") then  
		      if(msgw:find_child(selected_prj) ~= nil) then 
		           msgw:find_child(selected_prj):set{color = {255,255,255,255}} 
	              end 
		 end 
	         msgw:find_child(msgw_focus).extra.on_focus_out()
		 prj_text.extra.on_focus_in()
		 selected_prj = prj_text.name
		 msgw_focus = prj_text.name --1102
	     end 

	     if (i == 1) then msgw_focus = prj_text.name project = prj_text.text end 

         end 
     end 
end

local function inputMsgWindow_savefile()
     local file_not_exists = true
     local dir = editor_lb:readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_fn = input_t.text
	       cleanMsgWindow()
               printMsgWindow("The file named "..current_fn..
               " already exists.\nDo you want to replace it? \n", "aleady_exists")
               inputMsgWindow("yn")
               file_not_exists = false
          end
      end
      if (file_not_exists) then
           current_fn = input_t.text
           editor_lb:writefile(current_fn, contents, true)
           contents = ""
	   cleanMsgWindow()
           screen:grab_key_focus(screen) 
      end
end

function make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     
     local x_scroll_box, y_scroll_box 
     local x_scroll_bar, y_scroll_bar 

     if(x_scroll_to == 0)then 
	 x_scroll_to = screen.w
     end
     if(y_scroll_to == 0)then 
	 y_scroll_to = screen.h
     end

     g.extra.canvas_h = y_scroll_to - y_scroll_from -- y 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_w = x_scroll_to - x_scroll_from -- x 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_f = y_scroll_from
     g.extra.canvas_xf = x_scroll_from
     g.extra.canvas_t = y_scroll_to
     g.extra.canvas_xt = x_scroll_to

     screen_rect =  Rectangle{
                name="screen_rect",
                border_color= {2, 25, 25, 140},
                border_width=2,
                color= {255,255,255,0},
                size = {screen.w+1,screen.h+1},
                position = {0,0,0}, 
     }
     screen_rect.reactive = false
     g:add(screen_rect)


     
    if (g.extra.canvas_w > screen.w) then 
	local SCROLL_X_POS = 10
	local BOX_BAR_SPACE = 6
	
        x_scroll_box = factory.make_x_scroll_box()
        x_scroll_bar = factory.make_x_scroll_bar(g.extra.canvas_w)

	x_scroll_box.position = {SCROLL_X_POS, screen.h - 60}
	x_scroll_bar.position = {SCROLL_X_POS + BOX_BAR_SPACE, screen.h - 56}

	
        x_scroll_bar.extra.org_x = 16
	x_scroll_bar.extra.h_x = 16
	x_scroll_bar.extra.l_x = x_scroll_box.x + x_scroll_box.w - x_scroll_bar.w - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(x_scroll_box) 
	screen:add(x_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dx = ((g.extra.canvas_w - screen.w)/(x_scroll_bar.extra.l_x - x_scroll_bar.extra.h_x))

		
	local x0 = - g.extra.canvas_xf/g.extra.scroll_dx + 10 
	local x1920 = (-g.extra.canvas_xf+1080)/g.extra.scroll_dx + 10

	x_0_mark= Rectangle {
		name="x_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x0, screen.h - 55, 0},
		opacity = 255
        }

	x_1920_mark= Rectangle {
		name="x_1920_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x1920, screen.h - 55, 0},
		opacity = 255
        }
  
	screen:add(x_0_mark)
	screen:add(x_1920_mark) 

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_x = m.x
	end 
         
        function x_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {x_scroll_bar, x-x_scroll_bar.x, y-x_scroll_bar.y }

		if table.getn(selected_objs) ~= 0 then
		     for q, w in pairs (selected_objs) do
			 local t_border = screen:find_child(w)
			 local i, j = string.find(t_border.name,"border")
		         local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		         if(t_obj ~= nil) then 
			      screen:remove(screen:find_child(t_obj.name.."a_m"))
			 end
		     end
		end

        	return true
    	end 

    	function x_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_x <= x-dx and x-dx <= actor.extra.l_x) then -- 스크롤 되는 범위안에 있으면	
	           		dif = x - dx - x_scroll_bar.extra.org_x -- 스크롤이 이동한 거리 
	           		x_scroll_bar.x = x - dx 
	      		elseif (actor.extra.h_x > x-dx ) then
				dif = actor.extra.h_x - x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.h_x
	      		elseif (actor.extra.l_x < x-dx ) then
				dif = actor.extra.l_x- x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.l_x
			end 
			dif = dif * g.extra.scroll_dx -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.extra.org_x-dif-x_scroll_from, j.y, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.x = t_obj.x 
				 end
			     end
			end

			g.extra.scroll_x = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 


     if(g.extra.canvas_h > screen.h) then 


	local SCROLL_Y_POS = 90
	local BOX_BAR_SPACE = 6

	y_scroll_box = factory.make_y_scroll_box()
        y_scroll_bar = factory.make_y_scroll_bar(g.extra.canvas_h) 

	y_scroll_box.position = {screen.w - 60, SCROLL_Y_POS}
	y_scroll_bar.position = {screen.w - 56, SCROLL_Y_POS + BOX_BAR_SPACE}

        y_scroll_bar.extra.org_y = 96
	y_scroll_bar.extra.h_y = 96
	y_scroll_bar.extra.l_y = y_scroll_box.y + y_scroll_box.h - y_scroll_bar.h - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(y_scroll_box) 
	screen:add(y_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dy = ((g.extra.canvas_h - screen.h)/(y_scroll_bar.extra.l_y - y_scroll_bar.extra.h_y))
  
	
	local y0 = - g.extra.canvas_f/g.extra.scroll_dy + 10 
	local y1080 = (-g.extra.canvas_f+1080)/g.extra.scroll_dy + 10

	y_0_mark= Rectangle {
		name="y_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y0, 0},
		opacity = 255
        }

	y_1080_mark= Rectangle {
		name="y_1080_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y1080, 0},
		opacity = 255
       }
  
	screen:add (y_0_mark)
	screen:add (y_1080_mark)

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_y = m.y
	end 
         
        function y_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {y_scroll_bar, x-y_scroll_bar.x, y-y_scroll_bar.y }
		if table.getn(selected_objs) ~= 0 then
			for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
				      screen:remove(screen:find_child(t_obj.name.."a_m"))
				 end
			end
		end

        	return true
    	end 

    	function y_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_y <= y-dy and y-dy <= actor.extra.l_y) then -- 스크롤 되는 범위안에 있으면	
	           		dif = y - dy - y_scroll_bar.extra.org_y -- 스크롤이 이동한 거리 
	           		y_scroll_bar.y = y - dy 
	      		elseif (actor.extra.h_y > y-dy ) then
				dif = actor.extra.h_y - y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.h_y
	      		elseif (actor.extra.l_y < y-dy ) then
				dif = actor.extra.l_y- y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.l_y
			end 
			dif = dif * g.extra.scroll_dy -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.x, j.extra.org_y-dif-y_scroll_from, j.z}
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
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 
end

function inputMsgWindow_openfile(input_text)
     local file_not_exists = true
     local dir = editor_lb:readdir(CURRENT_DIR)
     if(input_text ~= nil) then
	  input_t.text = input_text
     end 
     for i, v in pairs(dir) do
          if(input_t.text == v)then
     	       current_fn = input_t.text
               file_not_exists = false
          end
     end
     if (file_not_exists) then
	  cleanMsgWindow()
	  screen:grab_key_focus(screen) 
          printMsgWindow("The file not exists.\nFile Name : ","err_msg")
          inputMsgWindow("reopenfile")
          return 
     end
     if(is_lua_file(input_t.text) == true) then 
           editor.close()
           current_fn = input_t.text
           local f = loadfile(current_fn)
           f(g) 
     else 
	  cleanMsgWindow()
	  screen:grab_key_focus(screen)
          printMsgWindow("The file is not a lua file.\nFile Name : ","err_msg")
          inputMsgWindow("reopenfile")
          return 
     end 
     if(g.extra.video ~= nil) then clear_bg() end 
     item_num = table.getn(g.children)

     local x_scroll_from=0
     local x_scroll_to=0

     local y_scroll_from=0
     local y_scroll_to=0

     for i, v in pairs(g.children) do
          v.reactive = true
	  if(v.type == "Text") then
		v.cursor_visible = false
		function v:on_key_down(key)
             		if key == keys.Return then
				v:set{cursor_visible = false}
				return true
	     		end 
		end 
	  end 
          create_on_button_down_f(v)
	  if(v.type == "Group") then 
	       for j, c in pairs (v.children) do
                    c.reactive = true
		    c.extra.is_in_group = true
                    create_on_button_down_f(c)
	       end 
	  end 

          if(v.x < 0) then 
		if( v.x < x_scroll_from )then 
		     x_scroll_from = v.x 
		end
          end 
	  
          if(v.y < 0) then 
		if( v.y < y_scroll_from ) then 
		     y_scroll_from = v.y 
		end
          end 

          if(v.x > screen.w) then 
		if( x_scroll_to < v.x + v.w)then 
		     x_scroll_to = v.x + v.w
		end
          end 
	  
          if(v.y > screen.h) then 
		if(y_scroll_to < v.y + v.h) then 
		     y_scroll_to = v.y + v.h 
		end
          end 
     end 

     if (x_scroll_to ~= 0 or x_scroll_from ~= 0 or y_scroll_to ~=0 or y_scroll_from ~= 0) then 
          make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     end 

     cleanMsgWindow()
     if(screen:find_child("screen_objects") == nil) then
	  for i,j in pairs(g.children) do 
		if(y_scroll_from < 0) then
			j.y = j.y - y_scroll_from
		end 
		if(x_scroll_from < 0) then
			j.x = j.x - x_scroll_from
		end 
	  end 
          screen:add(g)
     end
     screen:grab_key_focus(screen) 
end

function inputMsgWindow_yn(txt)
     cleanMsgWindow()
     if(txt == "no") then
          editor.save(false)
     elseif(txt =="yes") then 
          editor_lb:writefile (current_fn, contents, true)
          contents = ""
     end
     screen:grab_key_focus(screen) 
end

function inputMsgWindow_openvideo()
     
     if(is_mp4_file(input_t.text) == true) then 
          mediaplayer:load(input_t.text)
     else 
	  cleanMsgWindow()
	  screen:grab_key_focus(screen)
          printMsgWindow("The file is not a video file.\nFile Name : ","err_msg")
          inputMsgWindow("reopen_videofile")
          return 
     end 

     video1 = { name = "video1", 
                type ="Video",
                viewport ={0,0,screen.w/2,screen.h/2},
           	source= input_t.text,
           	loop= false, 
                volume=0.5  
              }

     g.extra.video = video1
     mediaplayer.on_loaded = function( self ) clear_bg() if(g.extra.video ~= nil) then self:play() end end 
     if(video1.loop == true) then 
	  	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
     else  	
		mediaplayer.on_end_of_stream = function ( self ) self:seek(0) end
     end

     cleanMsgWindow()
     screen:grab_key_focus(screen)

end

function inputMsgWindow_openimage(input_purpose, input_text)

     if(input_text ~= nil) then
	  input_t.text = input_text
     end 

     local file_not_exists = true
     local dir = editor_lb:readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               file_not_exists = false
          end
     end
     if (file_not_exists) then
          cleanMsgWindow()
          printMsgWindow("The file not exists.\nFile Name :","err_msg")
          inputMsgWindow("reopenImg")
	  return 0
     end
 
     if (input_purpose == "open_bg_imagefile") then  
	  BG_IMAGE_20.opacity = 0
	  BG_IMAGE_40.opacity = 0
	  BG_IMAGE_80.opacity = 0
	  BG_IMAGE_white.opacity = 0
	  BG_IMAGE_import:set{src = input_t.text, opacity = 255} 
	  input_mode = S_SELECT
     elseif(is_img_file(input_t.text) == true) then 
	  
	  while (is_available("img"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	  end 

          ui.image= Image { name="img"..tostring(item_num),
          src = input_t.text, opacity = 255 , position = {200,200}, 
	  extra = {org_x = 200, org_y = 200} }
          ui.image.reactive = true
          create_on_button_down_f(ui.image)
          table.insert(undo_list, {ui.image.name, ADD, ui.image})
          g:add(ui.image)
          if(screen:find_child("screen_objects") == nil) then
               screen:add(g)
          end 
          item_num = item_num + 1
     else 
	  cleanMsgWindow()
	  screen:grab_key_focus(screen) -- iii
          printMsgWindow("The file is not an image file.\nFile Name : ","err_msg")
          inputMsgWindow("reopenImg")
          return 
     end 

     cleanMsgWindow()
     screen:grab_key_focus(screen)
end

local input_purpose     = ""

--[[
kk
local function copy_widget_imgs ()
	local source_files = readdir("assets/widgets")
	for i, j in pairs(source_files) do 
	     source_file = "assets/widgets"..j 
	     dest_file = CURRENT_DIR..j 
	     file_copy(source_file, dest_file) 
	end 
end 
]]
local function set_project_path ()
	if(selected_prj == "" and input_t.text ~= "") then
	     project = input_t.text 
	elseif(selected_prj ~= "") then  
	     project = msgw:find_child(selected_prj).text
	end 
        app_path = editor_lb:build_path( base , project )
        if not editor_lb:mkdir( app_path ) then
        -- Tell the user we were not able to create it
   	     print("couldn't create ",app_path)  
        else
             editor_lb:change_app_path( app_path )
	     CURRENT_DIR = app_path
        end
	--copy_widget_imgs()
	cleanMsgWindow()
        screen:grab_key_focus(screen)
end 

function inputMsgWindow(input_purpose)

     local save_b, cancel_b, input_box, open_b, yes_b, no_b
     local save_t, cancel_t, input_box, open_t, yes_t, no_t
    
     function create_on_key_down_f(button) 
     	function button:on_key_down(key)
	     if key == keys.Return then
              	if (button.name == "savefile") then inputMsgWindow_savefile()
              	elseif (button.name == "yes") then inputMsgWindow_yn(button.name)
              	elseif (button.name == "no") then inputMsgWindow_yn(button.name)
              	elseif (button.name == "openfile") or (button.name == "reopenfile") then inputMsgWindow_openfile() 
              	elseif (button.name == "projectlist") then set_project_path()
              	elseif (button.name == "open_videofile") or (button.name == "reopen_videofile")then inputMsgWindow_openvideo()
              	elseif (button.name == "open_imagefile") or (button.name == "reopenImg")  then  inputMsgWindow_openimage(input_purpose)
              	elseif (button.name == "cancel") then 	cleanMsgWindow() screen:grab_key_focus(screen)
							if(input_purpose == "projectlist") then projects = {} end 
                end
	        return true 
	     elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() cancel_b.extra.on_focus_in()
              	elseif (button.name == "yes") then yes_b.extra.on_focus_out() no_b.extra.on_focus_in() 
              	elseif (button.name == "projectlist") then button.extra.on_focus_out() cancel_b.extra.on_focus_in() 
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or (button.name == "reopen_videofile") or 
              	       (button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() cancel_b.extra.on_focus_in() 
		end
	     elseif (key == keys.Tab and shift == true) or ( key == keys.Up ) or (key == keys.Left) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "no") then no_b.extra.on_focus_out() yes_b.extra.on_focus_in()
              	elseif (button.name == "projectlist") then button.extra.on_focus_out() 
				                           msgw:find_child("input_b").extra.on_focus_in()
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or (button.name == "reopen_videofile") or 
              	(button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "cancel") then 
			cancel_b.extra.on_focus_out() 
			if(open_b ~= nil) then open_b.extra.on_focus_in()
			elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
               end
	     end 
        end 
     end 


     if (input_purpose == "reopenfile" or input_purpose == "reopenImg") or (input_purpose== "reopen_videofile") then 
	msgw_cur_x = msgw_cur_x + 200 
	msgw_cur_y = msgw_cur_y + 45
     elseif(input_purpose == "projectlist") then 
	msgw_cur_x = 25
	if(msgw_focus ~= "") then 
	msgw:add(Text{name= name, text = "   New Project : ", font= "DejaVu Sans 32px",
     	color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     	reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"})  
	else 
	     msgw_focus = "input_b"
	end 

	msgw_cur_x = 360
	msgw_cur_y = msgw_cur_y + 10
     else 
	msgw_cur_x = msgw_cur_x + 200 
     end
     
     position = {msgw_cur_x, msgw_cur_y} 

     if (input_purpose ~= "yn") then 
	if(input_purpose == "projectlist") then 
            input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
            position = {25, 10}, text = "" , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
            input_box = create_small_input_box(input_t)
            input_box.position = position
            msgw:add(input_box)
	    input_box.extra.on_focus_out()
	else 
            input_box = create_input_box()
            input_box.position = position
            msgw:add(input_box)
	    input_box.extra.on_focus_in()
	end

     end 

     if (input_purpose == "savefile") then 

     	save_b, save_t  = factory.make_msgw_button_item( assets , "Save")
        save_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	save_b.reactive = true 
	save_b.name = "savefile"

        cancel_b, cancel_t= factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	cancel_b.reactive = true 
	cancel_b.name = "cancel"
	
        msgw:add(save_b)
        msgw:add(cancel_b)
	create_on_key_down_f(save_b) 
	create_on_key_down_f(cancel_b) 

	function save_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_savefile()	
     	end 
	function save_t:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_savefile()	
     	end 


     elseif (input_purpose == "yn") then 

     	yes_b, yes_t  = factory.make_msgw_button_item( assets , "Yes")
        yes_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	yes_b.reactive = true
	yes_b.name = "yes"

        no_b, no_t= factory.make_msgw_button_item( assets ,"No")
        no_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	no_b.reactive = true
	no_b.name = "no"
	
        msgw:add(yes_b)
        msgw:add(no_b)

	create_on_key_down_f(yes_b) 
	create_on_key_down_f(no_b) 

	yes_b.extra.on_focus_in() 

	function yes_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("yes")
		return true
     	end 
     	function no_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("no")
		return true
     	end 
	function yes_t:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("yes")
		return true
     	end 
     	function no_t:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("no")
		return true
     	end 
     else 
     	open_b, open_t  = factory.make_msgw_button_item( assets , "Open")
        open_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	open_b.reactive = true

        cancel_b, cancel_t = factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	cancel_b.reactive = true 
	cancel_b.name = "cancel"
	
        msgw:add(open_b)
        msgw:add(cancel_b)


	if (input_purpose == "openfile") or  
	   (input_purpose == "reopenfile") then  
		open_b.name = "openfile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openfile() 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openfile() 
			--return true
     		end 
        elseif (input_purpose == "projectlist") then
 		open_b.name = "projectlist"
        	open_b.position = {360, msgw_cur_y + 70}
        	cancel_b.position = {560, msgw_cur_y + 70}

		function open_b:on_button_down(x,y,button,num_clicks)
			set_project_path()
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			set_project_path()
     		end 

	elseif (input_purpose == "open_imagefile") or  
	       (input_purpose == "open_bg_imagefile") or  
	       (input_purpose == "reopenImg") then  
		open_b.name = "open_imagefile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openimage(input_purpose) 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openimage(input_purpose) 
			--return true
     		end 
	elseif (input_purpose == "open_videofile") or (input_purpose == "reopen_videofile") then  
		open_b.name = "open_videofile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openvideo() 
			return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openvideo() 
			return true
     		end 
	end 
	create_on_key_down_f(open_b) 
	create_on_key_down_f(cancel_b) 
     end
     if(cancel_b ~= nil) then 
     	   function cancel_b:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		if(input_purpose == "projectlist") then projects = {} end 
		--return true
     	   end 
     	   function cancel_t:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		if(input_purpose == "projectlist") then projects = {} end 
		--return true
     	   end 
     end

     screen:add(msgw)
     input_mode = S_POPUP

	
     if( input_purpose =="yn") then 
          yes_b:grab_key_focus(yes_b)
     elseif( input_purpose == "projectlist") then 
	  if(msgw_focus ~= "") then 
	       msgw:find_child(msgw_focus).extra.on_focus_in()
	  end 
     else 
          input_t:grab_key_focus(input_t)
     end 

     function input_t:on_key_down(key)
	  if (input_t.text ~= "" and selected_prj ~= "") then 
		if(msgw:find_child(selected_prj) ~= nil) then 
			msgw:find_child(selected_prj):set{color = {255,255,255,255}}
		end 
		selected_prj = ""
	  end 

          if key == keys.Return or (key == keys.Tab and shift == false) or key == keys.Down or key == keys.Right then 
	      input_box.extra.on_focus_out()
	      if(open_b ~= nil) then open_b.extra.on_focus_in() 
	      elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
	  elseif(key == keys.Tab and shift == true) or key == keys.Up or key == keys.Left then 
	      if (input_purpose == "projectlist") then 
	           local n = table.getn(projects)
	           input_box.extra.on_focus_out()
		   msgw:find_child("prj"..n).extra.on_focus_in()
		   return true 
	      end 
          end
     end 
	
    function input_t:on_button_down(x,y,button,num)
	 msgw:find_child(msgw_focus).extra.on_focus_out()
	 input_box.extra.on_focus_in()
    end 
    function input_box:on_button_down(x,y,button,num)
	 msgw:find_child(msgw_focus).extra.on_focus_out()
	 input_box.extra.on_focus_in()
    end 
end
