
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
DEFAULT_COLOR     = "FFFFFFC0"

-- Section index constants. These also determine their order.

SECTION_FILE      = 1
SECTION_EDIT      = 2
SECTION_ARRANGE   = 3
SECTION_HELP      = 4
    
-- Style constants

BUTTON_TEXT_STYLE = { font = "DejaVu Sans 30px" , color = "FFFFFFFF" }
    
-- Background image 
BG_IMAGE = Image {src = "baduk.png", tile = {true, true}, position = {0,0}, size = {screen.w, screen.h}}

---------------------
-- Variables
---------------------
dragging          = nil
menu_hide 	  = false
popup_hide 	  = false
mouse_mode        = S_SELECT
mouse_state       = BUTTON_UP
current_inspector = nil

local g = Group()
local contents    = ""
local item_num    = 0

-- localized string table

strings = dofile( "localized:strings.lua" ) or {}
function missing_localized_string( t , s )
	rawset(t,s,s) 
	return s
end

setmetatable( strings , { __index = missing_localized_string } )


-- The asset cache
assets = dofile( "assets-cache" )

ui =
    {
        assets              = assets,
        factory             = dofile( "ui-factory" ),
        fs_focus            = nil,
        bar                 = Group {},
        bar_background      = assets( "assets/menu-background.png" ),
        button_focus        = assets( "assets/button-focus.png" ),
        search_button       = assets( "assets/button-search.png" ),
        search_focus        = assets( "assets/button-search-focus.png" ),
        logo                = assets( "assets/logo.png" ),

        sections =
        {
            [SECTION_FILE] =
            {
                button  = assets( "assets/button-red.png" ),
                text    = Text  { text = strings[ "  FILE " ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 120 ,  21 ,  21 , 230 }, -- RED
                height  = 370,
                init    = dofile( "section-file" )
            },

            [SECTION_EDIT] =
            {
                button  = assets( "assets/button-green.png" ),
                text    = Text  { text = strings[ "  EDIT  " ] }:set( BUTTON_TEXT_STYLE ),
                color   = {   5 ,  72 ,  18 , 230 }, -- GREEN
                height  = 500,
                init    = dofile( "section-edit" )
            },

            [SECTION_ARRANGE] =
            {
                button  = assets( "assets/button-yellow.png" ),
                text    = Text  { text = strings[ "  ARRANGE" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 300,
                init    = dofile( "section-arrange" )
            },
  	   [SECTION_HELP] =
            {
                button  = assets( "assets/button-blue.png" ),
                text    = Text  { text = strings[ "  HELP" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 200,
                init    = dofile( "section-help" )
            }
        }
    }

local factory = ui.factory
-----------
-- Utils 
-----------

function abs(a) if(a>0) then return a else return -a end end
function make_attr_t(v)        

local attr_t =  
      {
	     {"title", "INSPECTOR : "..string.upper(v.type)},
     	     {"caption", "OBJECT NAME"},
 	     {"name", v.name},
	     {"line",""},
	     {"x", v.x},
	     {"y", v.y},
	     {"z", v.z},
	     {"w", v.w},
	     {"h", v.h},
	     {"line",""}
      }
      if (v.type == "Text") then 
	table.insert(attr_t, {"color", v.color})
	table.insert(attr_t, {"font ", v.font})
	table.insert(attr_t, {"line",""})
	table.insert(attr_t, {"caption", "TEXT"})
	table.insert(attr_t, {"text", v.text})
	table.insert(attr_t, {"line",""})
	table.insert(attr_t, {"editable", v.editable})
	table.insert(attr_t, {"wants_enter", v.wants_enter})
	table.insert(attr_t, {"line",""})
	table.insert(attr_t, {"wrap", v.wrap})
	table.insert(attr_t, {"wrap_mode", v.wrap_mode})
	table.insert(attr_t, {"line",""})
      elseif (v.type  == "Rectangle") then
	--table.insert(attr_t, {"caption", "FILL COLOR"})
	table.insert(attr_t, {"fill_color  ", v.color})
	--table.insert(attr_t, {"caption", "BORDER COLOR"})
        table.insert(attr_t, {"border_color", v.border_color})
        table.insert(attr_t, {"border_width", v.border_width})
	table.insert(attr_t, {"line",""})
      elseif (v.type  == "Image") then
	table.insert(attr_t, {"caption", "SOURCE LOCATION"})
	table.insert(attr_t, {"src", v.src})
	table.insert(attr_t, {"line",""})
        table.insert(attr_t, {"base_size", v.base_size})
        table.insert(attr_t, {"async    ", v.async})
        table.insert(attr_t, {"loaded   ", v.loaded})
	table.insert(attr_t, {"line",""})
      end 
      table.insert(attr_t, {"opacity", v.opacity})
      table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"rotation", v.rotation})
      --table.insert(attr_t, {"line",""})
      --table.insert(attr_t, {"anchor_point", v.anchor_point})
      --table.insert(attr_t, {"line",""})
      table.insert(attr_t, {"button", "VIEW CODE"})
      table.insert(attr_t, {"button", "APPLY"})
      table.insert(attr_t, {"button", "CANCEL"})

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
	 "wrap="..tostring(v.wrap)..b_indent.."}\n\n"
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
                         Editor().inspector(v)
		    end 
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
	  create_on_button_down_f(v)
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

function inputScreen_openvideo()
     print(input_t.text)
     mediaplayer:load(input_t.text)
     --mediaplayer:set_viewport_geometry(100, 100, 500, 500)
     mp_t = Text{name = "mediaplayer", extra = {name = "MediaPlayer", source = input_t.text}}
     g:add(mp_t)
     cleanText()
     cleanText("input")

end 

function inputScreen_openimage()
     ui.image= Image { name="img"..tostring(item_num),
     src = input_t.text, opacity = 255 , position = {200,200}}
     ui.image.reactive = true;
     create_on_button_down_f(ui.image)
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
     end 

     function editor.selected(obj)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if (obj.name ~= v.name) then 
                       g:find_child(v.name):set{opacity = 100}
		  end 
             end
        end
     end  

     function editor.n_selected(obj)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
                  g:find_child(v.name):set{opacity = 255}
             end
        end
     end  

     function editor.open()
        editor.close()
        printScreen("File Name : ")
        inputScreen("openfile")
     end 

     function editor.inspector(v) -- build_inspector_ui()

	local WIDTH = 450 
	local INSPECTOR_OFFSET = 30 
        local TOP_PADDING = 12
        local BOTTOM_PADDING = 12

        local items_height = 0
	local space = 0
	local used = 0

	if(current_inspector ~= nil) then 
		return 
        end 

        editor.selected(v)

	local attr_t = make_attr_t(v)
	local inspector_items = {}
	local inspector_bg = factory.make_popup_bg(v.type)
	local inspector_xbox = factory.make_xbox()

	local inspector = Group {
	     position ={ v.x + v.w + INSPECTOR_OFFSET , v.y },
	     anchor_point = {0,0},--{ inspector_bg.w / 2 , 0 },
             children =
             {
               inspector_bg, 
	       inspector_xbox:set{position = {465, 40}}
             }
	}


	if(inspector.y - INSPECTOR_OFFSET  <= ui.bar_background.h) then
                inspector.y = ui.bar_background.h + INSPECTOR_OFFSET
        elseif (inspector.y + inspector.h + INSPECTOR_OFFSET >= screen.h ) then
                inspector.y = screen.h - inspector.h - INSPECTOR_OFFSET
        end 
        if (inspector.x + inspector.w + INSPECTOR_OFFSET >= screen.w ) then
                inspector.x = v.x - inspector.w - INSPECTOR_OFFSET
        end 
	local attr_i, attr_n, attr_v
	local i = 0
	for i=1,35 do 
             if (attr_t[i] == nil) then
		  break
	     end 
	     attr_n = attr_t[i][1] 
	     attr_i = attr_t[i][2] 

	     if(type(attr_i) == table ) then
	          attr_v = table.concat(attr_i,",")
             else
                  attr_v = tostring(attr_i)
             end 

	     print("attr_n",attr_n)
	     print("attr_v",attr_v)

	    local item = factory.make_text_popup_item(assets, attr_n, attr_v) 
	    if(attr_n ~= "title" and attr_n ~= "line" and attr_n ~=  "caption") then 
	    	table.insert(inspector_items, item)

	         function item:on_button_down(x,y,button,num_clicks)
                 if (item.on_activate) then
                     item:on_activate()
                 end
                 end

	         item.extra.on_activate = function ()  end 
	    end 

            items_height = items_height + item.h 

	    if(item.w <= space) then 
                 items_height = items_height - item.h 
            	 item.x = used + 30
	    else 
                 item.x = ( inspector_bg.w - WIDTH ) / 2
		 space = 0
		 used = 0
            end 
		
	    if(attr_n == "name" or attr_n == "text" or attr_n == "src") then 
                 item.y = items_height - 15
            elseif (attr_n == "line") then  
                 item.y = items_height + 35
	    else 
                 item.y = items_height
	    end

	    if(space == 0) then 
	         space = WIDTH - item.w 
            else 
		 space = space - item.w
	    end
	    used = used + item.w 

	    inspector:add(item)
        end 

	screen:add(inspector)

        if inspector:find_child("name") and 
             inspector:find_child("name"):find_child("name") then
             inspector:find_child("name"):find_child("name"):grab_key_focus()
             inspector:find_child("name"):remove(inspector:find_child("name"):find_child("ring"))
             inspector:find_child("name"):add(inspector:find_child("name").extra.focus)
             inspector:find_child("name"):find_child("name"):set{cursor_visible = true, cursor_size = 3}
        end

	current_inspector = inspector

        inspector.reactive = true;
	create_on_button_down_f(inspector)

        inspector_xbox.reactive = true;
	function inspector_xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(inspector)
		current_inspector = nil
		editor.n_selected(v)
                screen.grab_key_focus(screen) 
		return true
        end 

     end

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

        create_on_button_down_f(ui.rect) 

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

        cleanText("codes")
        ui.text = Text{
        name="text"..tostring(item_num),
	text = "", font= "DejaVu Sans 40px",
     	color = DEFAULT_COLOR, position ={100, 100}, editable = true ,
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
	ui.text.reactrective = true;
	create_on_button_down_f(ui.text)

    end
	
    function editor.image()
        cleanText("codes")
        printScreen("File Name : ")
        inputScreen("open_imagefile")
    end
	
    function editor.video()
        mediaplayer.on_loaded = function( self ) screen:remove(BG_IMAGE) self:play() end 
	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end

        cleanText("codes")
        printScreen("File Name : ")
        inputScreen("open_mediafile")
    end
	
    function editor.clone()
    end
	
    function editor.group()
    end
	
    return editor
end --Editor()

