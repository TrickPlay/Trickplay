-----------
-- Utils 
-----------


local factory = ui.factory

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


function create_on_button_down_f(v)
	v.extra.selected = false
	local org_object, new_object 
	
        function v:on_button_down(x,y,button,num_clicks)
	   if(v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw") then 
	     if(mouse_mode == S_SELECT) and  
	       (screen:find_child("msgw") == nil) then
	       if (v.extra.is_in_group == true and control == false) then 
		    local p_obj = find_parent(v)
                    if(button == 3 or num_clicks >= 2) then
                         editor.inspector(p_obj)
                         return true
                    end 
	            if(mouse_mode == S_SELECT and p_obj.extra.selected == false) then 
		     	editor.selected(p_obj)
			p_obj.extra.selected = true 
	            elseif (p_obj.extra.selected == true) then 
		     	editor.n_selected(p_obj)
			p_obj.extra.selected = false 
	       	    end
	            org_object = copy_obj(p_obj)
           	    dragging = {p_obj, x - p_obj.x, y - p_obj.y }
           	    return true
	       else  -- v.extra.is_in_group == false or control == true 
                    if(button == 3 or num_clicks >= 2) then
                         editor.inspector(v)
                         return true
                    end 
	            if(mouse_mode == S_SELECT and v.extra.selected == false) then 
		     	editor.selected(v) 
			v.extra.selected = true 
	            elseif (v.extra.selected == true) then 
			if(v.type == "Text") then 
			      v:set{cursor_visible = true}
     			      v:grab_key_focus(v)
			end 
			editor.n_selected(v) 
			v.extra.selected = false 
	       	    end
	            org_object = copy_obj(v)
           	    dragging = {v, x - v.x, y - v.y }
           	    return true
	   	 end
              end
	   else 
                 dragging = {v, x - v.x, y - v.y }
           	 return true
           end
           return true
        end

        function v:on_button_up(x,y,button,num_clicks)
	   if(v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw" ) then 
	     if(mouse_mode == S_SELECT) and 
	       (screen:find_child("msgw") == nil) then
	        if (v.extra.is_in_group == true) then 
		    local p_obj = find_parent(v)
		    new_object = copy_obj(p_obj)
		    if(dragging ~= nil) then 
	            	local actor , dx , dy = unpack( dragging )
	            	new_object.position = {x-dx, y-dy}
			if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
			editor.n_selected(v) 
			editor.n_selected(new_object) 
			editor.n_selected(org_object) 
                    	table.insert(undo_list, {p_obj.name, CHG, org_object, new_object})
			end 
	            	dragging = nil
	            end 
		    return true 
		else 
	      	    new_object = copy_obj(v)
	      	    if(dragging ~= nil) then 
	            	local actor , dx , dy = unpack( dragging )
	            	new_object.position = {x-dx, y-dy}
			
			if(org_object ~= nil) then  -- ?  
		        if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
			editor.n_selected(v) 
			editor.n_selected(new_object) 
			editor.n_selected(org_object) 
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
           return true
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
-- Screen Command Line Inputs 
--------------------------------

local input_t

attr_t_idx = {"name", "source", "left", "top", "width", "height", "volume", "loop", "x", "y", "z", "w", "h", "x_scale", "y_scale", "r", "g", "b", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "rect_r", "rect_g", "rect_b", "rect_a", "bord_r", "bord_g", "bord_b", "bwidth", "src", "cx", "cy", "cw", "ch", "x_angle", "y_angle", "z_angle",  "opacity", "view code", "apply", "cancel"}

function make_attr_t(v)
function toboolean(s) if (s == "true") then return true else return false end end
  local attr_t 

  if(v.type ~= "Video") then
     attr_t =
      {
             {"title", "INSPECTOR : "..string.upper(v.type)},
             {"caption", "OBJECT NAME"},
             {"name", v.name,"name"},
             {"line",""},
             {"x", v.x, "x"},
             {"y", v.y, "y"},
             {"z", v.z, "z"},
             {"w", v.w, "w"},
             {"h", v.h, "h"},
             {"line",""}
      }
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
        table.insert(attr_t, {"r", color_t[1], "r"})
        table.insert(attr_t, {"g", color_t[2], "g"})
        table.insert(attr_t, {"b", color_t[3], "b"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"font", v.font,"font "})
        table.insert(attr_t, {"line",""})
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
         "position = {"..v.x..","..v.y.."}"..","..indent.."opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Image") then

	if (v.clip == nil) then v.clip = {0, 0,v.w, v.h} end 
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "src=\""..v.src.."\","..indent..
         "position = {"..v.x..","..v.y.."},"..indent..
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
         "position = {"..v.x..","..v.y.."},"..indent..
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
         "position = {"..v.x..","..v.y.."},"..indent..
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
        "position = {"..v.x..","..v.y.."},"..indent..
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
	"mediaplayer.on_loaded = function(self) screen:remove(BG_IMAGE) self:play() end"..b_indent..
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

local function create_input_box(txt)
     	local box_g = Group {}
     	local box = factory.draw_ring()
     	local box_focus = factory.draw_focus_ring()
	box.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
	box_g:add(box)
	box_focus.opacity = 0 
	box_g:add(box_focus)
    	box_g:add(txt)

        function box_g.extra.on_focus_in()
		txt:grab_key_focus(txt)
	        box.opacity = 0 
            	box_focus.opacity = 255
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
        end

	return box_g
end 

--------------------------------
-- Message Window Inputs 
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
     mouse_mode = S_SELECT
end 

function printMsgWindow(txt, name)
     if (name == nil) then
        name = "pritMsgWindow"
     end

     txt_sz = string.len(txt) 

     if (name == "aleady_exists" ) then
	txt_sz = txt_sz - 50
     else 
     	i, j = string.find(txt, "\n")
     	if (j ~= nil) then 
	     txt_sz = txt_sz + 20 
        end 
     end 
     local msgw_bg = factory.make_popup_bg("msgw", txt_sz)
     msgw:add(msgw_bg)
     mouse_mode = S_POPUP
     msgw:add(Text{name= name, text = txt, font= "DejaVu Sans 32px",
     color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"})
end

local function inputMsgWindow_savefile()
     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_fn = "./working_space/"..input_t.text
	       cleanMsgWindow()
               printMsgWindow("The file named "..current_fn..
               " already exists.\nDo you want to replace it? \n", "aleady_exists")
               inputMsgWindow("yn")
               file_not_exists = false
          end
      end
      if (file_not_exists) then
           current_fn = "./working_space/"..input_t.text
           writefile(current_fn, contents, true)
           contents = ""
	   cleanMsgWindow()
           screen:grab_key_focus(screen) 
      end
end

function inputMsgWindow_openfile()
     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
     	       current_fn = "./working_space/"..input_t.text
               file_not_exists = false
          end
     end
     if (file_not_exists) then
	  cleanMsgWindow()
	  screen:grab_key_focus(screen) -- iii
          printMsgWindow("The file not exists.\nFile Name : ","err_msg")
          inputMsgWindow("reopenfile")
          return 
     end
     current_fn = "./working_space/"..input_t.text
     local f = loadfile(current_fn)
     f(g)
     item_num = table.getn(g.children)
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

     end 
     cleanMsgWindow()
     screen:add(g)
     screen:grab_key_focus(screen) 
end

function inputMsgWindow_yn(txt)
     cleanMsgWindow()
     if(txt == "no") then
          editor.save(false)
     elseif(txt =="yes") then 
          writefile (current_fn, contents, true)
          contents = ""
     end
     screen:grab_key_focus(screen) --kkk
end

function inputMsgWindow_openvideo()
     mediaplayer:load("working_space/"..input_t.text)

     video1 = { name = "video1", 
                type ="Video",
                viewport ={0,0,screen.w/2,screen.h/2},
           	source= "./working_space/"..input_t.text,
           	loop= true, 
                volume=0.5  
              }

     g.extra.video = video1
     table.insert(undo_list, {video1.name, ADD, video1})
     mediaplayer.on_loaded = function( self ) screen:remove(BG_IMAGE) self:play() end 
     if(video1.loop == true) then 
	  	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
     else  	
		mediaplayer.on_end_of_stream = function ( self ) self:seek(0) end
     end

     cleanMsgWindow()
     screen:grab_key_focus(screen)

end

function inputMsgWindow_openimage()

     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
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

     ui.image= Image { name="img"..tostring(item_num),
     src = "./working_space/"..input_t.text, opacity = 255 , position = {200,200}}
     ui.image.reactive = true
     create_on_button_down_f(ui.image)
     table.insert(undo_list, {ui.image.name, ADD, ui.image})
     g:add(ui.image)
     screen:add(g)
     cleanMsgWindow()
     item_num = item_num + 1
     screen:grab_key_focus(screen)
end

local input_purpose     = ""


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
              	elseif (button.name == "open_videofile") then inputMsgWindow_openvideo()
              	elseif (button.name == "open_imagefile") or (button.name == "reopenImg")  then  inputMsgWindow_openimage()
              	elseif (button.name == "cancel") then 	cleanMsgWindow() screen:grab_key_focus(screen)
                end
	        return true 
	     elseif (key == keys.Tab and shift == false ) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() cancel_b.extra.on_focus_in()
              	elseif (button.name == "yes") then yes_b.extra.on_focus_out() no_b.extra.on_focus_in() 
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or 
              	       (button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() cancel_b.extra.on_focus_in() 
		end
	     elseif (key == keys.Tab and shift == true) then 
			--print(" tap + shift")
		if (button.name == "savefile") then save_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "no") then no_b.extra.on_focus_out() yes_b.extra.on_focus_in()
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or 
              	(button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "cancel") then 
			--print("cancel, tap + shift")
			cancel_b.extra.on_focus_out() 
			if(open_b ~= nil) then open_b.extra.on_focus_in()
			elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
               end
	     end 
        end 
     end 

     if (input_purpose == "reopenfile" or input_purpose == "reopenImg") then 
	msgw_cur_x = msgw_cur_x + 200 
	msgw_cur_y = msgw_cur_y + 45
     else 
	msgw_cur_x = msgw_cur_x + 200 
     end
     
     position = {msgw_cur_x, msgw_cur_y} 

     if (input_purpose ~= "yn") then 
        input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
        position = {25, 10}, text = "" , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }

        input_box = create_input_box(input_t)
        input_box.position = position
        msgw:add(input_box)
	input_box.extra.on_focus_in()
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
	elseif (input_purpose == "open_imagefile") or  
	       (input_purpose == "reopenImg") then  
		open_b.name = "open_imagefile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openimage() 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openimage() 
			--return true
     		end 
	elseif (input_purpose == "open_videofile") then  
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
		--return true
     	   end 
     	   function cancel_t:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		--return true
     	   end 
     end

     screen:add(msgw)
     mouse_mode = S_POPUP

	
     if( input_purpose ~="yn") then 
          input_t:grab_key_focus(input_t)
     else 
          yes_b:grab_key_focus(yes_b)
     end 

     function input_t:on_key_down(key)
          if key == keys.Return or (key == keys.Tab and shift == false) or key == Down then 
	      input_box.extra.on_focus_out()
	      if(open_b ~= nil) then open_b.extra.on_focus_in() 
	      elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
          end
     end 
	
end
