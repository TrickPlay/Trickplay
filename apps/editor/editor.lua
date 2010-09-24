
---------------------
-- Global 
---------------------
----------------
-- Constants 
----------------

BUTTON_UP         = 0
BUTTON_DOWN       = 1
S_SELECT          = 0
S_RECTANGLE       = 1
S_MENU            = 3
S_GROUP           = 4

---------------------
-- Variables
---------------------
dragging          = nil
mouse_mode        = S_SELECT
mouse_state       = BUTTON_UP

---------------------
-- Local 
---------------------
local g = Group()
local contents    = ""
local item_num    = 0

-----------
-- Utils 
-----------

function abs(a)
    if(a>0) then
        return a
    else
        return -a
    end
end

function itemTostring(v)
    local itm_str = ""
    local indent       = "\n\t\t"
    local b_indent       = "\n\t"

    if(v.type == "Rectangle") then 
         itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
         "name=\""..v.name.."\","..indent..
         "border_color={"..table.concat(v.border_color,",").."},"..indent..
         "border_width="..v.border_width..",color={"..table.concat(v.color,",").."},"..indent..
	 "size={"..table.concat(v.border_color,",").."},"..indent..
         "border_width="..v.border_width..","..indent.."color={"..table.concat(v.color,",").."},"..indent..
	 "size = {"..table.concat(v.size,",").."},"..indent..
         "position = {"..v.x..","..v.y.."}"..b_indent.."}\n\n"
    elseif (v.type == "Image") then 
    	 itm_str = itm_str..v.name.." = "..v.type..b_indent.."{"..indent..
	 "name=\""..v.name.."\","..indent..
         "src=\""..v.src.."\","..indent..
         "base_size={"..table.concat(v.base_size,",").."},"..indent..
         "position = {"..v.x..","..v.y.."},"..indent.. 
         "async="..tostring(v.async)..","..indent..
	 "loaded="..tostring(v.loaded)..b_indent.."}\n\n"
    elseif (v.type == "Text") then 
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
	 "wrap="..tostring(v.wrap)..b_indent.."}\n\n"
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
     local f = loadfile(input_t.text)
     f(g)
     item_num = table.getn(g.children)
     for i, v in pairs(g.children) do
          v.reactive = true;
          function v:on_button_down(x,y,button,num_clicks)
               print ("rect button down ")
               if(button == 2 or num_clicks >= 2) then
                    editor.inspector(v) 
                    return true;
               end
               dragging = {v, x - v.x, y - v.y }
               return true;
          end
          function v:on_button_up(x,y,button,num_clicks)
               print ("rect button up ")
               dragging = nil
               return true;
          end
     end --for

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
              elseif (input_purpose == "open_mediafile") then  
		   mediaplayer:load(input_t.text) 
	           cleanText()
		   cleanText("input")
              elseif (input_purpose == "open_imagefile") then  
		   ui.image= Image { name="img"..tostring(item_num),
		   src = input_t.text, opacity = 255 , position = {200,200}} g:add(ui.image)
        	   screen:add(g)
     		   cleanText()
     		   cleanText("input")
		   item_num = item_num + 1
              elseif (input_purpose == "inspector") then inspector_commit(v, input_t.text) 
              end --elseif
          end --if
     end --input_t:on_key_down(key)

end --inputScreen()
--[[
function inspector_commit(v, cmd)

cmd = name="rect99", size={100,100}, color = "FFFFFF" 
local  = 
       local i, j, attr 
       i, j =  string.find(cmd, "=")
       
       attr = string.sub(cmd, i,j)	
        
end 
]]

function cleanText(text_name)
     if(text_name == nil) then text_name = "printScreen" end
     if(screen:find_child(text_name)) then screen:remove(screen:find_child(text_name)) end
     if(text_name == "input") then
        screen.grab_key_focus(screen)
        input_t.text = ""
        input_purpose = ""
     end
end

--------------------------------
-- Editor Functions
--------------------------------

local rect_init_x = 0
local rect_init_y = 0

function Editor()
    local editor = {}

    function editor.close()
        screen:remove(g)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
                  g:remove(g:find_child(v.name))
             end
        end
        cleanText("codes")
        item_num = 0
        current_filename = ""
        screen.grab_key_focus(screen)
     end  --editor.close()

     function editor.open()
        editor.close()
        printScreen("File Name : ")
        inputScreen("openfile")
     end -- editor.open()

     function editor.inspector(v)
--[[
	local itm_str = itemTostring(v)
	printScreen(item_str) 
        printScreen("::> ")
	inputScreen("inspector")
]]
     end -- editor.inspector()

     function editor.view_codes()
          local codes = "local g = ... \n\n"
          local obj_names = getObjnames()
	
          local n = table.getn(g.children)
          for i, v in pairs(g.children) do
               codes= codes..itemTostring(v)
               if (i == n) then
                    codes = codes.."g:add("..obj_names..")"
	       end 
           end
	   screen:remove(g)
           screen:add(Text{name="codes",text = codes,font="DejaVu Sans 30px" ,
           color = "FFFFFF" , position = { 100 , 100 } , editable = false ,
           reactive = false, wants_enter = false, w = screen.w - 500 , h = screen.h ,wrap=true, wrap_mode="CHAR"})
           screen.grab_key_focus(screen) --hjk

     end -- editor.view_codes()

     function editor.save()

        cleanText("codes")
        printScreen("File Name : ")
        contents = "local g = ... \n\n"
        local obj_names = getObjnames()
        local n = table.getn(g.children)
   
        for i, v in pairs(g.children) do
             contents= contents..itemTostring(v)
             if (i == n) then
                  contents = contents.."g:add("..obj_names..")"
             end
        end
        inputScreen("savefile")

     end  

     function editor.rectangle(x, y)
	
        cleanText("codes")
	local DEFAULT_COLOR     = "FFFFFFC0"
        rect_init_x = x -- origin x
        rect_init_y = y -- origin y
        if (ui.rect ~= nil and "rect"..tostring(item_num) == ui.rect.name) then
                return 0
        end

        ui.rect = Rectangle{
                name="rect"..tostring(item_num),
                border_color= defalut_color,
                border_width=1,
                color= DEFAULT_COLOR,
                size = {1,1},
                position = {x,y}
        }
        ui.rect.reactive = true;
        g:add(ui.rect)
        screen:add(g)

        function ui.rect:on_button_down(x,y,button,num_clicks)
             print ("rect button down ")
             if(button == 2 or num_clicks >= 2) then
                  editor.inspector(v) 
                  return true;
             end
             dragging = {ui.rect, x - ui.rect.x, y - ui.rect.y }
             return true;
        end
        function ui.rect:on_button_up(x,y,button,num_clicks)
            print ("rect button up ")
            dragging = nil
            return true;
        end

     end -- editor.rectangle

     function editor.rectangle_done(x,y)
        ui.rect.size = { abs(x-rect_init_x), abs(y-rect_init_y) }
        if(x-rect_init_x < 0) then
           ui.rect.x = x
        end
        if(y-rect_init_y < 0) then
            ui.rect.y = y
        end
        item_num = item_num + 1
        screen.grab_key_focus(screen)
     end 

     function editor.rectangle_move(x,y)
        ui.rect.size = { abs(x-rect_init_x), abs(y-rect_init_y) }
        if(x- rect_init_x < 0) then
            ui.rect.x = x
        end
        if(y- rect_init_y < 0) then
            ui.rect.y = y
        end
     end

     function editor.undo()
     end
	
     function editor.text()
	local DEFAULT_COLOR     = "FFFFFFC0"

        cleanText("codes")
        ui.text = Text{
        name="text"..tostring(item_num),
	text = "", font= "DejaVu Sans 40px",
     	color = "FFFFFF", position ={100, 100}, editable = true ,
     	reactive = true, wants_enter = true, size = {150, 150},wrap=true, wrap_mode="CHAR"} 
        g:add(ui.text)
        screen:add(g)
        ui.text.grab_key_focus(ui.text)
        local n = table.getn(g.children)

     	function ui.text:on_key_down(key)
             if key == keys.Return then
        	screen.grab_key_focus(screen)
		item_num = item_num + 1
		return true
	     end 
	end 
    end
	
    function editor.image()
        cleanText("codes")
        printScreen("File Name : ")
        inputScreen("open_imagefile")
    end
	
    function editor.video()
        cleanText("codes")
        printScreen("File Name : ")
        inputScreen("open_mediafile")
	mediaplayer.on_loaded = function( self ) self:play() end
	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
    end
	
    function editor.clone()
    end
	
    function editor.group()
    end
	
    return editor
end --Editor()

