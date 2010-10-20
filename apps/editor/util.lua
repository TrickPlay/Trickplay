-----------
-- Utils 
-----------

local factory = ui.factory

function values(t) 
	local j = 0 
	return function () j = j+1; return t[j] end 
end 

function abs(a) if(a>0) then return a else return -a end end

function getObjnames()
    local obj_names = ""
    local n = table.getn(g.children)
    for i, v in pairs(g.children) do
        if (i ~= n) then
             obj_names = obj_names..v.name..","
	     print(obj_names)
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
	print("creating on_button_down_f of ", v.type) 
	
        function v:on_button_down(x,y,button,num_clicks)
           --print (v.type, button, " button down ")
	   if(v.name ~= "inspector" and v.name ~= "Code") then 
	       if (v.extra.is_in_group == true and control == false) then 
		    local p_obj = find_parent(v)
                    if(button == 3 or num_clicks >= 2) then
                         editor.inspector(p_obj)
                         return true;
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
           	    return true;
	       else  -- v.extra.is_in_group == false
                    if(button == 3 or num_clicks >= 2) then
                         editor.inspector(v)
                         return true;
                    end 
	            if(mouse_mode == S_SELECT and v.extra.selected == false) then 
		     	editor.selected(v) 
			v.extra.selected = true 
	            elseif (v.extra.selected == true) then 
			if(v.type == "Text") then 
				v:set{cursor_visible = true}
     				v.grab_key_focus(v)
			end 
			editor.n_selected(v) 
			v.extra.selected = false 
	       	    end
	            org_object = copy_obj(v)
           	    dragging = {v, x - v.x, y - v.y }
           	    return true;
	   	 end
	   else 
                 dragging = {v, x - v.x, y - v.y }
           	 return true;
           end
        end

        function v:on_button_up(x,y,button,num_clicks)
	   if(v.name ~= "inspector") then 
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
	   else 
	      dragging = nil
              return true
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
           new_object.source = v.source
       elseif (v.type == "Group") then
           new_object = Group{}
	   new_object.children = v.children
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

local current_filename  = ""
local input_t

function printScreen(txt, name)
     if (name == nil) then
        name = "printScreen"
     end
     screen:add(Text{name= name, text = txt, font= "DejaVu Sans 40px",
     color = "FFFFFF", position ={100, 950}, editable = false ,
     reactive = false, wants_enter = false, w = screen.w - 500 , h = screen.h ,wrap=true, wrap_mode="CHAR"})
end

function inputScreen_savefile()
     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_filename = input_t.text
               current_fn = input_t.text
               cleanText()
               cleanText("input")
               printScreen("The file named "..current_filename..
               " already exists. \nDo you want to replace it? [Y|N] \n")
               inputScreen("yn")
               file_not_exists = false
          end
      end
      if (file_not_exists) then
           current_filename = input_t.text
           current_fn = input_t.text
           writefile (current_filename, contents, true)
           contents = ""
           cleanText()
           cleanText("input")
      end
end


function inputScreen_openfile()

     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_filename = input_t.text
               current_fn = input_t.text
               file_not_exists = false
          end
     end
     if (file_not_exists) then
          cleanText()
          cleanText("input")
          printScreen("The file not exists. \n","err_msg")
          printScreen("\nFile Name : ")
          inputScreen("reopenfile")
          return 0
     end
     current_filename = input_t.text
     current_fn = input_t.text
     local f = loadfile(input_t.text)
     f(g)
     item_num = table.getn(g.children)
     for i, v in pairs(g.children) do
          v.reactive = true;
          create_on_button_down_f(v)
     end 
     
     screen:add(g)
     cleanText("pritMsgWindow")
     cleanText("input")
end

function inputScreen_yn()
     if(input_t.text ~= "y") then
          cleanText("printMsgWindwo")
          cleanText("input")
	  msgw_cur_x = 25
     	  msgw_cur_y = 50
          screen:remove(msgw)
     	  msgw.children = {}
          printMsgWindow("File Name : ")
          inputMsgWindow("savefile")
     else
          writefile (current_filename, contents, true)
          contents = ""
          cleanText("printMsgWindwo")
          cleanText("input")
	  msgw_cur_x = 25
     	  msgw_cur_y = 50
          screen:remove(msgw)
     	  msgw.children = {}
     end
end

function inputScreen_openvideo()
-- mediaplayer:load(input_t.text)
end

function inputScreen_openimage()
     ui.image= Image { name="img"..tostring(item_num),
     src = input_t.text, opacity = 255 , position = {200,200}}
     ui.image.reactive = true;
     create_on_button_down_f(ui.image)
     table.insert(undo_list, {ui.image.name, ADD, ui.image})
     g:add(ui.image)
     screen:add(g)
     cleanText()
     cleanText("input")
     item_num = item_num + 1
end

local input_purpose     = ""


function inputScreen(a)
     input_purpose = a
     if (input_purpose == "yn") then position = {900, 1000}
     elseif (input_purpose == "reopenfile") then position = {400, 1000}
     else position = {400,950}
     end
     font = "DejaVu Sans 40px"
     input_t = Text { name="input", font= "DejaVu Sans 40px" , color = "FFFFFF" ,
           position = position, text = "=> " , editable = true , reactive = true,
           wants_enter = false, w = screen.w , h = 50 }
     screen:add(input_t)
     input_t.grab_key_focus(input_t)
     function input_t:on_key_down(key)
          if key == keys.Return then
              if (input_purpose == "savefile") then inputScreen_savefile()
              elseif (input_purpose == "yn") then inputScreen_yn()
              elseif (input_purpose == "openfile") then inputScreen_openfile() 
              elseif (input_purpose == "reopenfile") then cleanText("err_msg") inputScreen_openfile()
              elseif (input_purpose == "open_mediafile") then inputScreen_openvideo()
              elseif (input_purpose == "open_imagefile") then  inputScreen_openimage()
              elseif (input_purpose == "open_videofile") then  inputScreen_openvideo()
              elseif (input_purpose == "inspector") then inspector_commit(v, input_t.text)
              end
          end
     end
end

function cleanText(text_name)
     if(text_name == nil) then text_name = "printScreen" end
     if(screen:find_child(text_name)) then screen:remove(screen:find_child(text_name)) end
     if(text_name == "input") then
        screen.grab_key_focus(screen)
        input_t.text = ""
        input_purpose = ""
     end
end

attr_t_idx = {"name", "source", "left", "top", "width", "height", "rate", "volume", "mute", "loop", "x", "y", "z", "w", "h", "r", "g", "b", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "rect_r", "rect_g", "rect_b", "bord_r", "bord_g", "bord_b", "bwidth", "x_ang", "y_ang", "z_ang", "src", "cx", "cy", "cw", "ch", "x_angle", "y_angle", "z_angle", "opacity", "view code", "apply", "cancel"}

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
             {"rate", v.rate, "rate"},
             {"line",""},
             {"volume", v.volume, "volume"},
             {"mute", v.mute, "mute"},
             {"line",""},
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
        --table.insert(attr_t, {"caption", "TEXT"})
        --table.insert(attr_t, {"text", v.text,"text"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"editable", v.editable,"editable"})
        table.insert(attr_t, {"wants_enter", v.wants_enter,"wants enter"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"wrap", v.wrap, "wrap"})
        table.insert(attr_t, {"wrap_mode", v.wrap_mode,"wrap mode"})
      elseif (v.type  == "Rectangle") then
        color_t = v.color 
        if color_t == nil then 
             color_t = {0,0,0}
        end
        table.insert(attr_t, {"caption", "FILL COLOR"})
        table.insert(attr_t, {"rect_r", color_t[1], "r"})
        table.insert(attr_t, {"rect_g", color_t[2], "g"})
        table.insert(attr_t, {"rect_b", color_t[3], "b"})
        --table.insert(attr_t, {"fill_color  ", v.color,"border_color"})
        color_t = v.border_color 
        if color_t == nil then 
             color_t = {0,0,0}
        end
        table.insert(attr_t, {"caption", "BORDER COLOR"})
        table.insert(attr_t, {"bord_r", color_t[1], "r"})
        table.insert(attr_t, {"bord_g", color_t[2], "g"})
        table.insert(attr_t, {"bord_b", color_t[3], "b"})
        --table.insert(attr_t, {"border_color", v.border_color, "border_width"})
        table.insert(attr_t, {"bwidth", v.border_width, "border width"})
        table.insert(attr_t, {"line",""})
	table.insert(attr_t, {"caption", "ROTATION  "})
        local x_rotation_t = v.x_rotation 
        local y_rotation_t = v.x_rotation 
        local z_rotation_t = v.x_rotation 
        if x_rotation_t == nil then 
             x_rotation_t = {0,0,0} 
        elseif y_rotation_t == nil then 
             y_rotation_t = {0,0,0} 
        elseif z_rotation_t == nil then 
             z_rotation_t = {0,0,0} 
        end
        table.insert(attr_t, {"x_ang", x_rotation_t[1], "x"})
        table.insert(attr_t, {"y_ang", y_rotation_t[1], "y"})
        table.insert(attr_t, {"z_ang", z_rotation_t[1], "z"})

      elseif (v.type  == "Image") then
        table.insert(attr_t, {"caption", "SOURCE LOCATION"})
        table.insert(attr_t, {"src", v.src,"source"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"caption", "CLIP   "})
        local clip_t = v.clip
        if clip_t == nil then
             clip_t = {0,0 ,v.w, v.h}
        end
        table.insert(attr_t, {"cx", clip_t[1], "x"})
        table.insert(attr_t, {"cy", clip_t[2], "y"})
        table.insert(attr_t, {"cw", clip_t[3], "w"})
        table.insert(attr_t, {"ch", clip_t[4], "h"})
        --table.insert(attr_t, {"ch", clip_t[4], "opacity"})
        table.insert(attr_t, {"line",""})
 	table.insert(attr_t, {"caption", "ROTATION  "})
        local x_rotation_t = v.x_rotation 
        local y_rotation_t = v.x_rotation 
        local z_rotation_t = v.x_rotation 
        if x_rotation_t == nil then 
             x_rotation_t = {0,0,0} 
        elseif y_rotation_t == nil then 
             y_rotation_t = {0,0,0} 
        elseif z_rotation_t == nil then 
             z_rotation_t = {0,0,0} 
        end
        table.insert(attr_t, {"x_angle", x_rotation_t[1], "x"})
        table.insert(attr_t, {"y_angle", y_rotation_t[1], "y"})
        table.insert(attr_t, {"z_angle", z_rotation_t[1], "z"})
	
--[[
        table.insert(attr_t, {"caption", "X ROTATION  "})
        local x_rotation_t = v.x_rotation 
        if x_rotation_t == nil then 
             x_rotation_t = {"-","-","-"} 
        end
        table.insert(attr_t, {"x_angle", x_rotation_t[1], "rxy"})
        table.insert(attr_t, {"rxy", x_rotation_t[2], "rxz"})
        table.insert(attr_t, {"rxz", x_rotation_t[3], "opacity"})
        table.insert(attr_t, {"line",""})

        table.insert(attr_t, {"caption", "Y ROTATION  "})
        local y_rotation_t = v.y_rotation 
        if y_rotation_t == nil then 
             y_rotation_t = {"-","-","-"} 
        end
        table.insert(attr_t, {"y_angle", y_rotation_t[1], "ryz"})
        table.insert(attr_t, {"ryx", y_rotation_t[2], "ryz"})
        table.insert(attr_t, {"ryz", y_rotation_t[3], "z_angle"})
        table.insert(attr_t, {"line",""})

        table.insert(attr_t, {"caption", "Z ROTATION  "})
        local z_rotation_t = v.z_rotation 
        if z_rotation_t == nil then 
             z_rotation_t = {"-","-","-"} 
        end
        table.insert(attr_t, {"z_angle", z_rotation_t[1], "rzx"})
        table.insert(attr_t, {"rzx", z_rotation_t[2], "rzy"})
        table.insert(attr_t, {"rzy", z_rotation_t[3], "opacity"})
 table.insert(attr_t, {"line",""})
]]
      elseif (v.type  == "Clone") then
        table.insert(attr_t, {"source", v.source,"source"})
      elseif (v.type  == "Group") then
        table.insert(attr_t, {"children", v.children,"children"})
      end
  if(v.type ~= "Video") then
      table.insert(attr_t, {"line",""})
      table.insert(attr_t, {"opacity", v.opacity, "opacity"})
      table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"rotation", v.rotation})
      --table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"anchor_point", v.anchor_point})
      --table.insert(attr_t, {"line",""})
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
    if(v.type ~= "Video")then 
         local clip_t = v.clip
         if(clip_t == nil) then
             clip_t = {0,0 ,v.w, v.h}
         end
    end 
    if(v.type == "Rectangle") then
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "border_color={"..table.concat(v.border_color,",").."},"..indent..
         "border_width="..v.border_width..","..indent.."color={"..table.concat(v.color,",").."},"..indent..
         "size = {"..table.concat(v.size,",").."},"..indent..
         "position = {"..v.x..","..v.y.."}"..","..indent.."opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Image") then
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "src=\""..v.src.."\","..indent..
        -- "base_size={"..table.concat(v.base_size,",").."},"..indent..
        -- "async="..tostring(v.async)..","..indent..
        -- "loaded="..tostring(v.loaded)..","..indent..
         "position = {"..v.x..","..v.y.."},"..indent..
         "clip = {"..clip_t[1]..","..clip_t[2]..","..clip_t[3]..","..
                  clip_t[4].."},"..indent..
         "opacity = "..v.opacity..b_indent.."}\n\n"
    elseif (v.type == "Text") then
         if (v.extra.name == "MediaPlayer") then
                itm_str = "mediaplayer:load(\""..v.extra.source.."\")\n"..
                   "mediaplayer.on_loaded = function( self ) self:play() end"
         else
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "text=\""..v.text.."\","..indent..
         "font=\""..v.font.."\","..indent..
         "color={"..table.concat(v.color,",").."},"..indent..
         "size={"..table.concat(v.size,",").."},"..indent..
         "position = {"..v.x..","..v.y.."},"..indent..
         "editable="..tostring(v.editable)..","..indent..
         "reactive="..tostring(v.reactive)..","..indent..
         "wants_enter="..tostring(v.wants_enter)..","..indent..
         "wrap="..tostring(v.wrap)..","..indent..
         "wrap_mode=\""..v.wrap_mode.."\","..indent.."opacity = "..v.opacity..b_indent.."}\n\n"
         end
    elseif (v.type == "Clone") then
	itm_str =  itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "size={"..table.concat(v.size,",").."},"..indent..
         "position = {"..v.x..","..v.y.."},"..indent..
         "source="..v.source.name..","..indent..
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
	--print(children)
	itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
        "name=\""..v.name.."\","..indent..
        "size={"..table.concat(v.size,",").."},"..indent..
        "position = {"..v.x..","..v.y.."},"..indent..
        "children = {"..children.."},"..indent..
        "opacity = "..v.opacity..b_indent.."}\n\n"
	
    elseif (v.type == "Video") then
	itm_str = itm_str..v.name.." = ".."{"..indent..
        "name=\""..v.name.."\","..indent..
        "type=\""..v.type.."\","..indent..
        "source=\""..v.source.."\","..indent..
        "viewport={"..table.concat(v.viewport,",").."},"..indent..
        "rate = "..v.rate..","..indent..
        "loop = "..tostring(v.loop)..","..indent..
        "volume = "..v.volume..","..indent..
        "mute = "..tostring(v.mute)..","..b_indent.."}\n"..b_indent
	
	itm_str = itm_str.."mediaplayer:load("..v.name..".source)"..b_indent..
	"mediaplayer.on_loaded = function(self) screen:remove(BG_IMAGE) self:play() end"..b_indent..
	"if ("..v.name..".loop == true) then"..b_indent..
     	"     mediaplayer.on_end_of_stream = function(self) self:seek(0) self:play() end"..b_indent..
	"end"..b_indent..
	"mediaplayer:set_viewport_geometry("..v.name..".viewport[1], "..v.name..".viewport[2], "..v.name..".viewport[3], "..v.name..".viewport[4])"..b_indent..
	"mediaplayer:set_playback_rate("..v.name..".rate)"..b_indent..
	"mediaplayer.volume = "..v.name..".volume"..b_indent..
	"mediaplayer.mute = "..v.name..".mute\n\n"

	itm_str = itm_str.."g.extra.video = "..v.name.."\n\n"

	print(itm_str)
    end
    return itm_str
end

local function create_input_button(txt)
     	local button_g = Group {}
     	local button = factory.draw_ring()
     	--local button_focus = factory.draw_focus_ring()
	button.name = "input_b"
        button.position  = {0,0}
        button.reactive = true
	button_g:add(button)
	button_g:add(button_focus)
	
--[[	
 	b_text = Text {text = string.upper(button_n)}:set(STYLE)
        b_text.position  = {(button.w - b_text.w)/2, (button.h - b_text.h)/2}
    	button_g:add(b_text)
]]
    	button_g:add(txt)
        function button_g.extra.on_focus_in()
        end

        function button_g.extra.on_focus_out()
        end

	return button_g
end 

--------------------------------
-- Message Window Inputs 
--------------------------------

local  msgw = Group {
	     position ={400, 400},
	     anchor_point = {0,0},
             children =
             {
             }
     }
local msgw_cur_x = 25  
local msgw_cur_y = 50

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
     msgw:add(Text{name= name, text = txt, font= "DejaVu Sans 32px",
     color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"})
end

function inputMsgWindow_savefile()
     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_filename = input_t.text
               current_fn = input_t.text
               cleanText("printMsgWindow")
               cleanText("input")
	       msgw_cur_x = 25
	       msgw_cur_y = 50
	       screen:remove(msgw)
               msgw.children = {}
               printMsgWindow("The file named "..current_filename..
               " already exists.\nDo you want to replace it? \n", "aleady_exists")
               inputMsgWindow("yn")
               file_not_exists = false
          end
      end
      if (file_not_exists) then
           current_filename = input_t.text
           current_fn = input_t.text
           writefile(current_filename, contents, true)
           contents = ""
           cleanText("printMsgWindow")
           cleanText("input")
	   msgw_cur_x = 25
	   msgw_cur_y = 50
	   screen:remove(msgw)
           msgw.children = {}
      end
end


function inputMsgWindow_openfile()
     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_filename = input_t.text
     	       current_fn = input_t.text
               file_not_exists = false
          end
     end
     if (file_not_exists) then
          cleanText("printMsgWindow")
          cleanText("input") 
	  msgw_cur_x = 25
	  msgw_cur_y = 50
	  screen:remove(msgw)
          msgw.children = {}
          printMsgWindow("The file not exists.\nFile Name : ","err_msg")
          inputMsgWindow("reopenfile")
          return 0
     end
     current_filename = input_t.text
     current_fn = input_t.text
     local f = loadfile(input_t.text)
     f(g)
     item_num = table.getn(g.children)
     for i, v in pairs(g.children) do
          v.reactive = true;
          create_on_button_down_f(v)
     end 
     
     cleanText("printMsgWindow")
     cleanText("input")
     msgw_cur_x = 25
     msgw_cur_y = 50
     screen:remove(msgw)
     msgw.children = {}
     screen:add(g)
     screen:grab_key_focus()
end

function inputMsgWindow_yn(txt)
     if(txt == "no") then
          cleanText("printMsgWindow")
          cleanText("input")
          printScreen("File Name : ")
          inputMsgWindow("savefile")
     elseif(txt =="yes") then 
          writefile (current_filename, contents, true)
          contents = ""
          cleanText("printMsgWindow")
          cleanText("input")
     end
     msgw_cur_x = 25
     msgw_cur_y = 50
     screen:remove(msgw)
     msgw.children = {}
     screen:grab_key_focus()
end

function inputMsgWindow_openvideo()
     mediaplayer:load(input_t.text)

     video1 = { name = "video1", 
                type ="Video",
                viewport ={0,0,screen.w/2,screen.h/2},
           	source= input_t.text,
           	rate=1,
           	loop= true, 
                volume=0.5,  
                mute=false
              }

     g.extra.video = video1
     table.insert(undo_list, {video1.name, ADD, video1})
     mediaplayer.on_loaded = function( self ) screen:remove(BG_IMAGE) self:play() end 
     if(video1.loop == true) then 
	  	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
     end

     msgw_cur_x = 25
     msgw_cur_y = 50
     screen:remove(msgw)
     msgw.children = {}
     screen:grab_key_focus()

end

function inputMsgWindow_openimage()

     local file_not_exists = true
     local dir = readdir(CURRENT_DIR)
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               local current_imgname = input_t.text
               file_not_exists = false
          end
     end
     if (file_not_exists) then
          cleanText("printMsgWindow")
          cleanText("input")
	  msgw_cur_x = 25
	  msgw_cur_y = 50
	  screen:remove(msgw)
     	  msgw.children = {}
          printMsgWindow("The file not exists.\nFile Name :","err_msg")
          inputMsgWindow("reopenImg")
	  return 0
     end

     ui.image= Image { name="img"..tostring(item_num),
     src = input_t.text, opacity = 255 , position = {200,200}}
     ui.image.reactive = true;
     create_on_button_down_f(ui.image)
     table.insert(undo_list, {ui.image.name, ADD, ui.image})
     g:add(ui.image)
     screen:add(g)
     cleanText("printMsgWindow")
     cleanText("input")
     msgw_cur_x = 25
     msgw_cur_y = 50
     screen:remove(msgw)
     msgw.children = {}
     item_num = item_num + 1
end

local input_purpose     = ""

function inputMsgWindow(input_purpose)
     local save_b, cancel_b
     if (input_purpose == "reopenfile" or input_purpose == "reopenImg") then 
	msgw_cur_x = msgw_cur_x + 200 
	msgw_cur_y = msgw_cur_y + 45
     else 
	msgw_cur_x = msgw_cur_x + 200 
     end
     
     
     position = {msgw_cur_x, msgw_cur_y} 

     if (input_purpose ~= "yn") then 
        input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
        position = {25, 10}, 
	text = "" , editable = true , reactive = true,
        wants_enter = false, w = screen.w , h = 50 }

        local input_box = create_input_button(input_t)
        input_box.position = position
        msgw:add(input_box)
     end 

     if (input_purpose == "savefile") then 
     	save_b  = factory.make_msgw_button_item( assets , "save")
	save_b.name = "savefile"
        save_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	save_b.reactive = true 

        cancel_b = factory.make_msgw_button_item( assets ,"cancel")
	cancel_b.name = "cancel"
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	cancel_b.reactive = true 
	
        msgw:add(save_b)
        msgw:add(cancel_b)
	--create_on_key_down_f(save_b) 
	--create_on_key_down_f(cancel_b) 
	function save_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_savefile()	
     	end 
     	function cancel_b:on_button_down(x,y,button,num_clicks)
		cleanText("printMsgWindow")
        	cleanText("input")
        	msgw.children = {}
		msgw_cur_x = 25
		msgw_cur_y = 50
		screen:remove(msgw)
     	end 
	
     elseif (input_purpose == "yn") then 
     	local yes_b  = factory.make_msgw_button_item( assets , "yes")
	yes_b.name = "yes"
        yes_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	yes_b.reactive = true
        local no_b = factory.make_msgw_button_item( assets ,"no")
	no_b.name = "no"
        no_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	no_b.reactive = true
	
        msgw:add(yes_b)
        msgw:add(no_b)

	--create_on_key_down_f(yes_b) 
	--create_on_key_down_f(no_b) 
	function yes_b:on_button_down(x,y,button,num_clicks)
          	writefile (current_filename, contents, true)
          	contents = ""
          	cleanText("printMsgWindow")
          	cleanText("input")
	  	msgw.children = {}
		msgw_cur_x = 25
		msgw_cur_y = 50
		screen:remove(msgw)
     	end 
     	function no_b:on_button_down(x,y,button,num_clicks)

		cleanText("printMsgWindow")
        	cleanText("input")
        	msgw.children = {}
		msgw_cur_x = 25
		msgw_cur_y = 50
		screen:remove(msgw)
		editor.save(false)
     	end 
     else 
     	local open_b  = factory.make_msgw_button_item( assets , "open")
        open_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	open_b.reactive = true

        local cancel_b = factory.make_msgw_button_item( assets ,"cancel")
	cancel_b.name = "cancel"
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	cancel_b.reactive = true 
	
        msgw:add(open_b)
        msgw:add(cancel_b)

	--create_on_key_down_f(open_b) 
	--create_on_key_down_f(cancel_b) 

	if (input_purpose == "openfile") then  
	open_b.name = "openfile"
	function open_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_openfile() 
     	end 
	elseif (input_purpose == "open_imagefile") then  
	open_b.name = "open_imagefile"
	function open_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_openimage() 
     	end 
	elseif (input_purpose == "open_videofile") then  
	open_b.name = "open_videofile"
	function open_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_openvideo() 
     	end 
	end 

     	function cancel_b:on_button_down(x,y,button,num_clicks)
		cleanText("printMsgWindow")
        	cleanText("input")
        	msgw.children = {}
		msgw_cur_x = 25
		msgw_cur_y = 50
		screen:remove(msgw)
                screen:grab_key_focus(screen)
     	end 
     end

     screen:add(msgw)
     if( input_purpose ~="yn") then 
          input_t.grab_key_focus(input_t)
     end 

     local function create_on_key_down_f(button) 
     	function button:on_key_down(key)
	     if key == keys.Return then
              	if (button.name == "savefile") then inputMsgWindow_savefile()
              	elseif (button.name == "yes") then inputMsgWindow_yn(button.name)
              	elseif (button.name == "no") then inputMsgWindow_yn(button.name)
              	elseif (button.name == "openfile") then inputMsgWindow_openfile() 
              	elseif (button.name == "open_videofile") then inputMsgWindow_openvideo()
              	elseif (button.name == "open_imagefile") then  inputMsgWindow_openimage()
              	elseif (button.name == "cancel") then 	cleanText("printMsgWindow")
        						cleanText("input")
        						msgw.children = {}
							msgw_cur_x = 25
							msgw_cur_y = 50
							screen:remove(msgw)
                					screen:grab_key_focus(screen)
               end
	     elseif (key == keys.Tab and shift == false) or key == Down then 
		if (button.name == "savefile") then cancel_b.extra.on_focus_in()
              	elseif (button.name == "yes") then no_b.extra.on_focus_in()
              	elseif (button.name == "openfile") then cancel_b.extra.on_focus_in()
              	elseif (button.name == "open_videofile") then cancel_b.extra.on_focus_in()
              	elseif (button.name == "open_imagefile") then cancel_b.extra.on_focus_in()
		end
	     elseif (key == keys.Tab and shift == true ) or key == Up then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() 
              	elseif (button.name == "yes") then yes_b.extra.on_focus_out()
              	elseif (button.name == "no") then no_b.extra.on_focus_out() yes_b.extra.on_focus_in()
              	elseif (button.name == "openfile") then openfile_b.extra.on_focus.out() cancel_b.extra.on_fucus_in()
              	elseif (button.name == "open_videofile") then openfile_b.extra.on_focus.out() cancel_b.extra.on_fucus_in()
              	elseif (button.name == "open_imagefile") then  openfile_b.extra.on_focus.out() cancel_b.extra.on_fucus_in()
               end
	     end 
        end 
     end 

     function input_t:on_key_down(key)
	       	
          if key == keys.Return then
              if (input_purpose == "savefile") then inputMsgWindow_savefile()
              elseif (input_purpose == "yn") then screen.grab_key_focus(screen) --inputMsgWindow_yn()
              elseif (input_purpose == "openfile") then inputMsgWindow_openfile() 
              elseif (input_purpose == "reopenfile") then inputMsgWindow_openfile()
              elseif (input_purpose == "open_videofile") then inputMsgWindow_openvideo()
              elseif (input_purpose == "open_imagefile") then  inputMsgWindow_openimage()
              elseif (input_purpose == "reopenImg") then inputMsgWindow_openimage()
              elseif (input_purpose == "inspector") then inspector_commit(v, input_t.text)
              end
	  elseif (key == keys.Tab and shift == false) or key == Down then 
	  elseif (key == keys.Tab and shift == true ) or key == Up then 
          end

--[[
          if key == keys.Return or
            (key == keys.Tab and shift == false) or 
             key == keys.Down then
		input_t:set{color = "000000"} 
		input_t:set{cursor_visible = false}
		screen:grab_key_focus(screen)
	        if (input_purpose == "savefile") then save_b.extra.on_focus_in()
                elseif (input_purpose == "yn") then yes_b.extra.on_focus_in()
                elseif (input_purpose == "openfile") then open_b.extra.on_focus_in()
                elseif (input_purpose == "reopenfile") then open_b.extra.on_focus_in()
                elseif (input_purpose == "open_videofile") then open_b.extra.on_focus_in()
                elseif (input_purpose == "open_imagefile") then  open_b.extra.on_focus_in()
                elseif (input_purpose == "reopenImg") then open_b.extra.on_focus_in()
                end
    	  end 
]]
	end 
	
end
