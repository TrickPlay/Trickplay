
--local g = Group()
--local contents    = ""
--local item_num    = 0

-----------
-- Utils 
-----------

function abs(a) if(a>0) then return a else return -a end end
function make_attr_t(v)
function toboolean(s) if (s == "true") then return true else return false end end
local attr_t =
      {
             {"title", "INSPECTOR : "..string.upper(v.type)},
             {"caption", "OBJECT NAME"},
             {"name", v.name,"x"},
             {"line",""},
             {"x", v.x, "y"},
             {"y", v.y, "z"},
             {"z", v.z, "w"},
             {"w", v.w, "h"},
             {"h", v.h},
             {"line",""}
      }
      if (v.type == "Text") then
        table.insert(attr_t[9], "color")
        table.insert(attr_t, {"color", v.color,"font "})
        table.insert(attr_t, {"font ", v.font,"text"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"caption", "TEXT"})
        table.insert(attr_t, {"text", v.text,"editable"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"editable", v.editable,"wants_enter"})
        table.insert(attr_t, {"wants_enter", v.wants_enter,"wrap"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"wrap", v.wrap, "wrap_mode"})
        table.insert(attr_t, {"wrap_mode", v.wrap_mode,"opacity"})
        table.insert(attr_t, {"line",""})
      elseif (v.type  == "Rectangle") then
        table.insert(attr_t[9], "fill_color  ")
        --table.insert(attr_t, {"caption", "FILL COLOR"})
        table.insert(attr_t, {"fill_color  ", v.color,"border_color"})
        --table.insert(attr_t, {"caption", "BORDER COLOR"})
        table.insert(attr_t, {"border_color", v.border_color, "border_width"})
        table.insert(attr_t, {"border_width", v.border_width, "opacity"})
        table.insert(attr_t, {"line",""})
      elseif (v.type  == "Image") then
        table.insert(attr_t[9], "src")
        table.insert(attr_t, {"caption", "SOURCE LOCATION"})
        table.insert(attr_t, {"src", v.src,"cx"})
        table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"caption", "CLIP   "})
        local clip_t = v.clip
        if clip_t == nil then
             clip_t = {0,0 ,v.w, v.h}
        end
        table.insert(attr_t, {"cx", clip_t[1], "cy"})
        table.insert(attr_t, {"cy", clip_t[2], "cw"})
        table.insert(attr_t, {"cw", clip_t[3], "ch"})
        table.insert(attr_t, {"ch", clip_t[4], "opacity"})
        table.insert(attr_t, {"line",""})
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
      end
      table.insert(attr_t, {"opacity", v.opacity, "view code"})
      table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"rotation", v.rotation})
      --table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"anchor_point", v.anchor_point})
      --table.insert(attr_t, {"line",""})
      table.insert(attr_t, {"button", "view code", "apply"})
      table.insert(attr_t, {"button", "apply", "cancel"})
      table.insert(attr_t, {"button", "cancel"})

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
         "wrap="..tostring(v.wrap)..","..indent.."opacity = "..v.opacity..b_indent.."}\n\n"
         end
    end
    return itm_str
end

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
        function v:on_button_down(x,y,button,num_clicks)
               print (v.type, " button down ")
               if(button == 2 or num_clicks >= 2) then
                    if(v.type ~= "Group") then
                         editor.inspector(v)
                    end
                    return true;
               end
               dragging = {v, x - v.x, y - v.y }
               return true;
          end
          function v:on_button_up(x,y,button,num_clicks)
	       --local org_object, new_object 
               --table.insert(undo_list, {v.name, CHG, org_object, new_object})
               dragging = nil
               return true;
          end
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
     local dir = readdir("./editor")
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
     local dir = readdir("./editor")
     for i, v in pairs(dir) do
          if(input_t.text == v)then
               current_filename = input_t.text
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
     print(current_filename)
     local f = loadfile(input_t.text)
     f(g)
     item_num = table.getn(g.children)
     for i, v in pairs(g.children) do
          v.reactive = true;
	  print(v.name)
          create_on_button_down_f(v)
     end 

     screen:add(g)
     cleanText()
     cleanText("input")
end

function inputScreen_yn()
     if(input_t.text ~= "y") then
          cleanText()
          cleanText("input")
          printScreen("File Name : ")
          inputScreen("savefile")
     else
          writefile (current_filename, contents, true)
          contents = ""
          cleanText()
          cleanText("input")
     end
end

function inputScreen_openvideo()
     print(input_t.text)
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
     print(input_purpose)
     if (input_purpose == "yn") then position = {900, 1000}
     elseif (input_purpose == "reopenfile") then position = {400, 1000}
     else position = {400, 950}
     end
     font = "DejaVu Sans 40px"
     input_t = Text { name="input", font= font, color = "FFFFFF" ,
           position = position, text = "" , editable = true , reactive = true,
           wants_enter = false, w = screen.w , h = 50 }
     screen:add(input_t)
     input_t.grab_key_focus(input_t)
     function input_t:on_key_down(key)
          if key == keys.Return then
                print(input_purpose)
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


