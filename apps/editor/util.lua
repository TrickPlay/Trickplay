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
        else
             obj_names = obj_names..v.name
        end
    end
    return obj_names
end

function create_on_button_down_f(v)
	v.extra.selected = false
	local org_object, new_object 
	print("creating on_button_down_f of ", v.type) 
	
        function v:on_button_down(x,y,button,num_clicks)
               print (v.type, button, " button down ")
               if(button == 3 or num_clicks >= 2) then
                    editor.inspector(v)
                    return true;
               end 
	       if(mouse_mode == S_CLONE) then editor.clone(v) end
	       if(mouse_mode == S_SELECT and v.extra.selected == false) then 
			editor.selected(v) 
			v.extra.selected = true 
			print("true1")
	       elseif (v.extra.selected == true) then 
			editor.n_selected(v) 
			v.extra.selected = false 
			print("false1")
	       end


	       org_object = copy_obj(v)
               dragging = {v, x - v.x, y - v.y }
	       if (shift == true) then 
                    v:raise_to_top()
	       end 
               return true;
        end
        function v:on_button_up(x,y,button,num_clicks)
	      new_object = copy_obj(v)
	      if(dragging ~= nil) then 
	            local actor , dx , dy = unpack( dragging )
	            new_object.position = {x-dx, y-dy}
                    table.insert(undo_list, {v.name, CHG, org_object, new_object})
	            dragging = nil
	            if(shift == true and v.type ~= "Group") then 
			for i, j in pairs(g.children) do
             			if g:find_child(j.name) then
					if (j.type == "Group") then 
					     local childrent_t = j.children 
        				     for e in values(children_t) do
						  if(e == v.name) then	
							v_is_child = true
						  end 
					     end 
					     if (x > j.x and x < j.x + j.w and y > j.y and y < j.y + j.h) then 	
						 g:remove(v)
						 table.insert(v.extra, v.x)
						 table.insert(v.extra, v.y)
						 v.x = v.x - j.x
			 			 v.y = v.y - j.y
						 j:add(v)
						 j.reactive = true 
						 create_on_button_down_f(j)
						 screen.grab_key_focus(screen)
					 	 mouse_mode = S_SELECT
						 break
					     end
					end 
				end
			end
		     end 
              end
              return true
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
     mediaplayer:load(input_t.text)
     --mediaplayer:set_viewport_geometry(100, 100, 500, 500)
     mp_t = Text{name = "mediaplayer", extra = {name = "MediaPlayer", source = input_t.text}}
     table.insert(undo_list, {mp_t.name, ADD, mp_t})
     g:add(mp_t)
     cleanText()
     cleanText("input")

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

attr_t_idx = {"name", "x", "y", "z", "w", "h", "r", "g", "b", "font", "text", "editable", "wants_enter",
 "wrap", "wrap_mode", "rect_r", "rect_g", "rect_b", "bord_r", "bord_g", "bord_b", 
 "bwidth", "x_ang", "y_ang", "z_ang", "src", "cx", "cy", "cw", "ch", "x_angle", "y_angle", "z_angle", "opacity",
 "view code", "apply", "cancel"}

function make_attr_t(v)
function toboolean(s) if (s == "true") then return true else return false end end
local attr_t =
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
        table.insert(attr_t, {"caption", "TEXT"})
        table.insert(attr_t, {"text", v.text,"text"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"editable", v.editable,"editable"})
        table.insert(attr_t, {"wants_enter", v.wants_enter,"wants_enter"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"wrap", v.wrap, "wrap"})
        table.insert(attr_t, {"wrap_mode", v.wrap_mode,"wrap_mode"})
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
      table.insert(attr_t, {"line",""})
      table.insert(attr_t, {"opacity", v.opacity, "opacity"})
      table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"rotation", v.rotation})
      --table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"anchor_point", v.anchor_point})
      --table.insert(attr_t, {"line",""})
      table.insert(attr_t, {"button", "view code", "view code"})
      table.insert(attr_t, {"button", "apply", "apply"})
      table.insert(attr_t, {"button", "cancel", "cancel"})

      return attr_t
end

function itemTostring(v)
    local itm_str = ""
    local indent       = "\n\t\t"
    local b_indent       = "\n\t"
    local clip_t = v.clip
    if(clip_t == nil) then
             clip_t = {0,0 ,v.w, v.h}
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

	
    end
    return itm_str
end

local function create_input_button(txt)
     	local button_g = Group {}
     	local button = factory.draw_ring()
	button.name = "input_b"
        button.position  = {0,0}
        button.reactive = true
	button_g:add(button)
	
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

function inputMsgWindow_yn()
     if(input_t.text ~= "y") then
          cleanText()
          cleanText("input")
          printScreen("File Name : ")
          inputMsgWindow("savefile")
     else
          writefile (current_filename, contents, true)
          contents = ""
          cleanText()
          cleanText("input")
     end
end

function inputMsgWindow_openvideo()
     mediaplayer:load(input_t.text)
     --mediaplayer:set_viewport_geometry(100, 100, 500, 500)
     mp_t = Text{name = "mediaplayer", extra = {name = "MediaPlayer", source = input_t.text}}
     table.insert(undo_list, {mp_t.name, ADD, mp_t})
     g:add(mp_t)
     cleanText()
     cleanText("input")

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

function inputMsgWindow(a)
     input_purpose = a
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
     	local save_b  = factory.make_msgw_button_item( assets , "save")
        save_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}

        local cancel_b = factory.make_msgw_button_item( assets ,"cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	
        msgw:add(save_b)
        msgw:add(cancel_b)
     elseif (input_purpose == "yn") then 
     	local yes_b  = factory.make_msgw_button_item( assets , "yes")
        yes_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}

        local no_b = factory.make_msgw_button_item( assets ,"no")
        no_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	
        msgw:add(yes_b)
        msgw:add(no_b)
     else 
     	local open_b  = factory.make_msgw_button_item( assets , "open")
        open_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}

        local cancel_b = factory.make_msgw_button_item( assets ,"cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	
        msgw:add(open_b)
        msgw:add(cancel_b)
     end

     screen:add(msgw)
     if( input_purpose ~="yn") then 
          input_t.grab_key_focus(input_t)
     end 

     function input_t:on_key_down(key)
          if key == keys.Return then
              if (input_purpose == "savefile") then inputMsgWindow_savefile()
              elseif (input_purpose == "yn") then screen.grab_key_focus(screen)
					          --inputMsgWindow_yn()
              elseif (input_purpose == "openfile") then inputMsgWindow_openfile() 
              elseif (input_purpose == "reopenfile") then inputMsgWindow_openfile()
              elseif (input_purpose == "open_mediafile") then inputMsgWindow_openvideo()
              elseif (input_purpose == "open_imagefile") then  inputMsgWindow_openimage()
              elseif (input_purpose == "reopenImg") then 
			inputMsgWindow_openimage()
--[[
          		cleanText("err_msg")
          		cleanText("reopenImg")
	  		msgw_cur_x = 25
	  		msgw_cur_y = 50
	  		screen:remove(msgw)
     			msgw.children = {}
]]
              elseif (input_purpose == "inspector") then inspector_commit(v, input_t.text)
              end
          end
     end
end


