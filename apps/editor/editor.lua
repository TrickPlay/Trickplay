dofile("apply.lua")
dofile("util.lua")

editor = {}

local rect_init_x = 0
local rect_init_y = 0
local g_init_x = 0
local g_init_y = 0
local factory = ui.factory
local selected_objs = {}


function editor.selected(obj)
     if(shift == false)then 
	if (table.getn(selected_objs) ~= 0 ) then -- while () do ? 
		local t_obj = screen:find_child(table.remove(selected_objs)) 
		if (t_obj == nil) then print("error: the_obj is nil") return end 
		if(t_obj.name ~= obj.name.."border") then
			screen:remove(t_obj)
			local i, j = string.find(t_obj.name,"border")
			t_obj = g:find_child(string.sub(t_obj.name, 1, i-1))	
			if(t_obj == nil) then return end 
			t_obj.extra.selected = false
		else 
			table.insert(selected_objs, t_obj.name)
		end
	end
     end 

     obj_border = Rectangle{}
     obj_border.name = obj.name.."border"
     obj_border.color = {0,0,0,0}
     obj_border.border_color = {255,0,0,255}
     obj_border.border_width = 2
     if(obj.extra.is_in_group == true)then 
	local group_pos = get_group_position(obj)
     	obj_border.x = obj.x + group_pos[1]
     	obj_border.y = obj.y + group_pos[2]
	obj_border.extra.group_postion = obj.extra.group_position
     else 
     	obj_border.position = obj.position
     end
     obj_border.size = obj.size
     screen:add(obj_border)
	
     obj.extra.selected = true

     table.insert(selected_objs, obj_border.name)
--[[
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if (obj.name ~= v.name) then 
		       g:find_child(v.name).extra.org_opacity = g:find_child(v.name).opacity
                       g:find_child(v.name):set{opacity = 50}
		  end 
             end
        end
]]
end  

function editor.n_selected(obj)
     screen:remove(screen:find_child(obj.name.."border"))
     table.remove(selected_objs)
     obj.extra.selected = false
	
--[[
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if (obj.name ~= v.name) then 
		       g:find_child(v.name):set{opacity = g:find_child(v.name).extra.org_opacity} 
		  end
             end
        end
]]
end  

function editor.close()
        screen:remove(g)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
                  g:remove(g:find_child(v.name))
		  if(screen:find_child(v.name.."border")) then
                       screen:remove(screen:find_child(v.name.."border"))
		  end 
             end
        end
	undo_list = {}
	redo_list = {}
        cleanText("codes")
        item_num = 0
        current_filename = ""
        current_fn = ""
        screen.grab_key_focus(screen)
end 

function editor.open()

     selected_objs = {}

     editor.close()
     printMsgWindow("File Name : ")
     inputMsgWindow("openfile")

end 

function editor.the_open()
---[[
	local WIDTH = 800
	local MSGW_OFFSET = 30 
	local L_PADDING = 50
	local R_PADDING = 50
        local TOP_PADDING = 60
        local BOTTOM_PADDING = 12
        local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF" }

        local items_height = 0
	local space = WIDTH
	local used = 0

	local dir = readdir(CURRENT_DIR)
	local dir_text = Text {name = "dir", text = "FILE LOCATION : "..CURRENT_DIR}:set(STYLE)
	local w= (WIDTH - dir_text.w)/2
	local h= TOP_PADDING/2 + Y_PADDING
	dir_text.position = {w,h}

	local line = factory.draw_line()
	
	function is_lua_file(fn)
	     i, j = string.find(fn, ".lua")
	     if (j == string.len(fn)) then
		return true
	     else 
		return false
	     end 
	end 

	function is_dir(fn)
	     --i, j = string.find(fn, ".")
	
	     --if (j ~= nil) then
	     if(fn == "assets" or fn == "dir1" or fn == "dir2") then 
		return true
	     else 
		return false
	     end 
	end
	
	function get_file_list() 
	local iw = w
	local ih = h
	local p_text = Text {name = "parent_dir", text = ".."}:set(STYLE)
	p_text.color = {255,0,255}
	p_text.position = {w,h}
	w = L_PADDING
	h = h + p_text.h + Y_PADDING
     	for i, v in pairs(dir) do
	     if (is_lua_file(v) == true) then 
	     text = Text {name = tostring(i), text = v}:set(STYLE)
	     if (space < text.w) then 
		  w = L_PADDING 
	          h = h + text.h + Y_PADDING
		  space = WIDTH
	     end 
             text.position  = {w,h}
	     space = space - text.w - X_PADDING
	     w = w + text.w + X_PADDING 
	     if (w/WIDTH > 1) then 
		w = L_PADDING 
		h = h + text.h + Y_PADDING
		space = WIDTH
	     end  
             end 
        end
	local return_h = h
	w = iw
	h = ih
	return return_h 
        end 

	
	local file_list_size = get_file_list()

	local msgw_bg = factory.make_popup_bg("msgw", file_list_size)
	local msgw = Group {
	     position ={400, 400},
	     anchor_point = {0,0},
             children =
             {
              msgw_bg,
             }
	}

        msgw:add(dir_text)
	line.position = {0, 80}
        msgw:add(line)
	w = L_PADDING
        h = TOP_PADDING + text.h + Y_PADDING

	function print_file_list() 
	     local p_text = Text {name = "parent_dir", text = ".."}:set(STYLE)
	     p_text.position = {w,h - 20}
	     p_text.color = {255,0,255}

	     w = L_PADDING
	     h = h - 20 -- p_text.h -- + Y_PADDING
	     msgw:add(p_text)
     	     for i, v in pairs(dir) do
	          if (is_lua_file(v) == true) then 
	               text = Text {name = tostring(i), text = v}:set(STYLE)
	               if (space < text.w) then 
		            w = L_PADDING 
	                    h = h + text.h + Y_PADDING
		            space = WIDTH
	               end 
                       text.position  = {w,h}
    	               msgw:add(text)
	               space = space - text.w - X_PADDING
	               w = w + text.w + X_PADDING 
	               if (w/WIDTH > 1) then 
		            w = L_PADDING 
		            h = h + text.h + Y_PADDING
		            space = WIDTH
	     	       end  
		  elseif (is_dir(v) == true) then
		      text = Text {name = tostring(i), text = v}:set(STYLE) 
		      text.color = {255,0,255}
		      if (space < text.w) then 
		            w = L_PADDING 
	                    h = h + text.h + Y_PADDING
		            space = WIDTH
	               end 
                       text.position  = {w,h}
    	               msgw:add(text)
	               space = space - text.w - X_PADDING
	               w = w + text.w + X_PADDING 
	               if (w/WIDTH > 1) then 
		            w = L_PADDING 
		            h = h + text.h + Y_PADDING
		            space = WIDTH
	     	       end  
	
                  end
             end
        end 
	
	print_file_list()

	local open_b  = factory.make_msgw_button_item( assets , "open")
	open_b.position = {WIDTH - 2*open_b.w + 2*X_PADDING, h+ 40 }

        local cancel_b = factory.make_msgw_button_item( assets , "cancel")
	cancel_b.position = {WIDTH - open_b.w + 3*X_PADDING, h+ 40}
	
	msgw:add(open_b)
	msgw:add(cancel_b)

	screen:add(msgw)
--]]
end 

function editor.inspector(v) 

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
	local inspector_bg = factory.make_popup_bg(v.type, 0)
	local inspector_xbox = factory.make_xbox()

	local inspector = Group {
	     --position ={ v.x + v.w + INSPECTOR_OFFSET , v.y },
	     name = "inspector",
	     position ={0, 0},
	     anchor_point = {0,0},--{ inspector_bg.w / 2 , 0 },
             children =
             {
               inspector_bg, 
	       inspector_xbox:set{position = {465, 40}}
             }
	}

	local function inspector_position() 
	     local x_space, y_space
 
	     if (v.x > screen.w - v.x - v.w) then 
	          x_space = v.x 
        	  if (inspector.w + INSPECTOR_OFFSET < x_space) then 
			inspector.x = x_space - inspector.w - INSPECTOR_OFFSET
		  else 
			inspector.x = (v.x + v.w - inspector.w)/2
        	  end 
	     else 
		  x_space = screen.w - v.x - v.w
        	  if (inspector.w + INSPECTOR_OFFSET < x_space) then 
			inspector.x = v.x + v.w + INSPECTOR_OFFSET
		  else 
			inspector.x = (v.x + v.w - inspector.w)/2
        	  end 
	    end  

	    if (v.y > screen.h - v.y - v.h) then 
		y_space = v.y 
        	if (inspector.h + INSPECTOR_OFFSET < y_space) then 
			inspector.y = v.y - inspector.h - INSPECTOR_OFFSET
			if(inspector.y <= ui.bar_background.h + INSPECTOR_OFFSET) then
			     inspector.y = ui.bar_background.h + INSPECTOR_OFFSET	
			end	
		else 
                	inspector.y = (v.y + v.h - inspector.h) /2
			if(inspector.y <= ui.bar_background.h + INSPECTOR_OFFSET) then
			     inspector.y = ui.bar_background.h + INSPECTOR_OFFSET	
			end	
        	end 
	    else 
		y_space = screen.h - v.y - v.h
        	if (inspector.h + INSPECTOR_OFFSET < y_space) then 
			inspector.y = v.y + v.h + INSPECTOR_OFFSET
		else 
			inspector.y = (v.y + v.h - inspector.h)/2
			if (inspector.y + inspector.h + INSPECTOR_OFFSET >= screen.h) then 
				inspector.y = screen.h - inspector.h - INSPECTOR_OFFSET
			elseif (inspector.y <= ui.bar_background.h + INSPECTOR_OFFSET) then
			     inspector.y = ui.bar_background.h + INSPECTOR_OFFSET	
			end
        	end 
	    end 
	end 

	inspector_position() 

	local attr_n, attr_v
	local i = 0
	for i=1,35 do 
             if (attr_t[i] == nil) then
		  break
	     end 
	     attr_n = attr_t[i][1] 
	     attr_v = attr_t[i][2] 
	     attr_s = attr_t[i][3] 

             attr_v = tostring(attr_v)

	     if(attr_s == nil) then attr_s = "" end 
	     
	     local item = factory.make_text_popup_item(assets, inspector, v, attr_n, attr_v, attr_s) 

             items_height = items_height + item.h 

	     if(item.w <= space) then 
                 items_height = items_height - item.h 
            	 item.x = used + 30
	     else 
                 item.x = ( inspector_bg.w - WIDTH ) / 2
		 space = 0
		 used = 0
             end 
		
---[[
	     if  attr_n == "name" or attr_n == "text" or attr_n == "src" 
	       or attr_n == "r" or attr_n == "g" or attr_n == "b" 
	       or attr_n == "rect_r" or attr_n == "rect_g" or attr_n == "rect_b" 
	       or attr_n == "bord_r" or attr_n == "bord_g" or attr_n == "bord_b" 
	       or attr_n == "font "  
	       then 
                 --item.y = items_height - 15
                 item.y = items_height 
             elseif (attr_n == "line") then  
                 item.y = items_height  + 40

	     elseif (attr_n == "caption") then  
                  item.y = items_height + 10
	     else 
                 item.y = items_height
	     end
--]]

	    if(space == 0) then 
	         space = WIDTH - item.w 
            else 
		 space = space - item.w
	    end
	    used = used + item.w 
	
	    inspector:add(item)
        end 

	screen:add(inspector)
	inspector:find_child("name").extra.on_focus_in()
	
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

function editor.view_code(v)

	local WIDTH = 750 
        local TOP_PADDING = 12
        local BOTTOM_PADDING = 12
	local CODE_OFFSET = 30 
        local codes = ""
	local codeViewWin_bg = factory.make_popup_bg("Code", v.type)
	local xbox = factory.make_xbox()

	local codeViewWin = Group {
	     name = "Code",
	     position ={0, 0},
             children =
             {
               codeViewWin_bg,
	       xbox:set{position = {765, 40}}
             }
	}
	codeViewWin.reactive = true
	
	if(v.type ~= "Group") then 
		codes = codes..itemTostring(v)
	else 
		local indent       = "\n\t\t"
    		local b_indent       = "\n\t"

 		local i = 1
        	local children = ""
        	for e in values(v.children) do
		     if i == 1 then
	                  children = children..e.name
	             else 
			  children = children..","..e.name
		     end
		     i = i + 1
        	end 
		
		codes =  codes..v.name.." = "..v.type..b_indent.."{"..indent..
        	"name=\""..v.name.."\","..indent..
	        "size={"..table.concat(v.size,",").."},"..indent..
	        "position = {"..v.x..","..v.y.."},"..indent..
	        "children = {"..children.."},"..indent..
	        "opacity = "..v.opacity..b_indent.."}\n\n"
	end 
	

	local function codeViewWin_position() 
	     local x_space, y_space
	     if (v.x > screen.w - v.x - v.w) then 
	          x_space = v.x 
        	  if (codeViewWin.w + CODE_OFFSET < x_space) then 
			codeViewWin.x = x_space - codeViewWin.w - CODE_OFFSET
		  else 
			codeViewWin.x = (v.x + v.w - codeViewWin.w)/2
        	  end 
	     else 
		  x_space = screen.w - v.x - v.w
        	  if (codeViewWin.w + CODE_OFFSET < x_space) then 
			codeViewWin.x = v.x + v.w + CODE_OFFSET
		  else 
			codeViewWin.x = (v.x + v.w - codeViewWin.w)/2
        	  end 
	    end  

	    if (v.y > screen.h - v.y - v.h) then 
		y_space = v.y 
        	if (codeViewWin.h + CODE_OFFSET < y_space) then 
			codeViewWin.y = v.y - codeViewWin.h - CODE_OFFSET
			if(codeViewWin.y <= ui.bar_background.h + CODE_OFFSET) then
			     codeViewWin.y = ui.bar_background.h + CODE_OFFSET	
			end	
		else 
                	codeViewWin.y = (v.y + v.h - codeViewWin.h) /2
			if(codeViewWin.y <= ui.bar_background.h + CODE_OFFSET) then
			     codeViewWin.y = ui.bar_background.h + CODE_OFFSET	
			end	
        	end 
	    else 
		y_space = screen.h - v.y - v.h
        	if (codeViewWin.h + CODE_OFFSET < y_space) then 
			codeViewWin.y = v.y + v.h + CODE_OFFSET
		else 
			codeViewWin.y = (v.y + v.h - codeViewWin.h)/2
			if (codeViewWin.y + codeViewWin.h + CODE_OFFSET >= screen.h) then 
				codeViewWin.y = screen.h - codeViewWin.h - CODE_OFFSET
			elseif (codeViewWin.y <= ui.bar_background.h + CODE_OFFSET) then
			     codeViewWin.y = ui.bar_background.h + CODE_OFFSET	
			end
        	end 
	    end 
	end 

	codeViewWin_position() 
        text_codes = Text{name="codes",text = codes,font="DejaVu Sans 30px" ,
        color = "FFFFFF" , position = { 50 , 60 } , editable = false ,
        reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}
	codeViewWin:add(text_codes)
	screen:add(codeViewWin)
        create_on_button_down_f(codeViewWin)
	mouse_mode = S_SELECT

	xbox.reactive = true
	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(codeViewWin)
		editor.n_selected(v)
                screen.grab_key_focus(screen) 
		return true
        end 

end 

function editor.save(save_current_f)
     cleanText("codes")
     if (save_current_f == true) then 
	print("current_fn...", current_fn)
        contents = "local g = ... \n\n"
        local obj_names = getObjnames()
        local n = table.getn(g.children)
   
        for i, v in pairs(g.children) do
             contents= contents..itemTostring(v)
             if (i == n) then
                  contents = contents.."g:add("..obj_names..")"
             end
        end
        undo_list = {}
        redo_list = {}
	print("CURRENT", current_filename)
	if(current_fn ~= "") then 
		writefile (current_fn, contents, true)	
	else 
		editor.save(false)
		return
	end 
     else 
        printMsgWindow("File Name : ")
        contents = "local g = ... \n\n"
        local obj_names = getObjnames()
        local n = table.getn(g.children)
   
        for i, v in pairs(g.children) do
             contents= contents..itemTostring(v)
             if (i == n) then
                  contents = contents.."g:add("..obj_names..")"
             end
        end
        undo_list = {}
        redo_list = {}
        inputMsgWindow("savefile")
     end 	
end  

function editor.rectangle(x, y)
	
        cleanText("codes")
        rect_init_x = x 
        rect_init_y = y 
        if (ui.rect ~= nil and "rect"..tostring(item_num) == ui.rect.name) then
                return 0
        end

        ui.rect = Rectangle{
                name="rect"..tostring(item_num),
                border_color= defalut_color,
                border_width=2,
                color= DEFAULT_COLOR,
                size = {1,1},
                position = {x,y}
        }
        ui.rect.reactive = true;
        table.insert(undo_list, {ui.rect.name, ADD, ui.rect})
        g:add(ui.rect)
        screen:add(g)

        create_on_button_down_f(ui.rect) 

end 

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
	  if( undo_list == nil) then return true end 
          local undo_item= table.remove(undo_list)
	  if(undo_item == nill) then return true end
	  if undo_item[2] == CHG then 
--[[
                local the_obj = g:find_child(undo_item[1])
		g:remove(the_obj)
		the_obj = undo_item[3] --original object 
		g:add(the_obj)
		create_on_button_down_f(the_obj)
]]
		g:remove(g:find_child(undo_item[1]))
		g:add(undo_item[3])
		undo_item[3].reactive = true
		create_on_button_down_f(undo_item[3])
	        table.insert(redo_list, undo_item)

	  elseif undo_item[2] == ADD then 
	       if((undo_item[3]).type == "Group") then 
		 	children_t = undo_item[3].children 
			dumptable(children_t)
		 	for e in values(children_t) do
			     if (e.name ~= "group_border") then
			          undo_item[3]:remove(e)
				  table.insert(undo_item[3].extra, e.name)
				  local g_position = e.position 
				  e.position = e.extra
				  e.extra = g_position
			          g:add(e)
				  --create_on_button_down_f(e)
			     end 
        		end 
			editor.n_selected(undo_item[3]) --kkk
			--screen:remove(undo_item[3]) --kkk
			g:remove(undo_item[3])
			screen:add(g)
	       else
			editor.n_selected(undo_item[3]) --kkk
			g:remove(g:find_child(undo_item[1]))
	       end 
               table.insert(redo_list, undo_item)
	  elseif undo_item[2] == DEL then 
	       g:add(undo_item[3])
               table.insert(redo_list, undo_item)
 	  end 
end
	
function editor.redo()
          
	  if( redo_list == nil) then return true end 
          local redo_item= table.remove(redo_list)
	  if(redo_item == nill) then return true end
 	  
          if redo_item[2] == CHG then 
		local the_obj = g:find_child(redo_item[1])
		g:remove(the_obj)
		the_obj = redo_item[4] --new object 
		g:add(the_obj)
		the_obj.reactive = true
		create_on_button_down_f(the_obj)
	        table.insert(undo_list, redo_item)
--[[
              local the_obj = g:find_child(redo_item[1])
	       the_obj:set{opacity = redo_item[4].opacity}
 	       the_obj:set{w = redo_item[4].w, h =redo_item[4].h } 
               undo_item = {redo_item[4].name, CHG, redo_item[3], redo_item[4]}
               table.insert(undo_list, undo_item)
]]
          elseif redo_item[2] == ADD then 
	       if(redo_item[3].type == "Group") then 
		 	children_t = redo_item[3].extra 
		 	for e in values(children_t) do
			     local group_item = g:find_child(e)
			     if(group_item ~= nil) then 
			     local o_position = group_item.position 
			     g:remove(group_item)
			     screen:remove(group_item)
			     group_item.position = group_item.extra
			     group_item.extra =  o_position
			     redo_item[3]:add(group_item)
			     end
        		end 
			--g:add(redo_item[3])
               		g:add(g:find_child(undo_item[1])) 
			screen:add(g)
			--create_on_button_down_f(redo_item[3])
	       else 
               g:add(redo_item[3])
	       end 
               table.insert(undo_list, redo_item)
          elseif undo_item[2] == DEL then 
               g:remove(g:find_child(redo_item[1]))
               table.insert(undo_list, redo_item)
          end 
end

function editor.undo_history()
	print("undo list : ")
	dumptable(undo_list)
	print("redo list : ")
	dumptable(redo_list)
end
	
function editor.add(obj)
	g:add(obj)
        --screen:add(obj)
end

function editor.delete(obj)
        --screen:remove(obj)
	g:remove(obj)
end

function editor.debug()
	dumptable(selected_objs)
end 

function editor.preferences()
     -- background setting 
     -- menu hidign 
     -- file saving  
end

function editor.text()

        cleanText("codes")
        ui.text = Text{
        name="text"..tostring(item_num),
	text = "", font= "DejaVu Sans 40px",
     	color = DEFAULT_COLOR, position ={700, 500}, editable = true ,
     	reactive = true, wants_enter = true, size = {300, 100},wrap=true, wrap_mode="CHAR"} 
        table.insert(undo_list, {ui.text.name, ADD, ui.text})
        g:add(ui.text)
        screen:add(g)
        ui.text.grab_key_focus(ui.text)
        local n = table.getn(g.children)

     	function ui.text:on_key_down(key)
             if key == keys.Return then
		ui.text:set{cursor_visible = false}
        	screen.grab_key_focus(screen)
		item_num = item_num + 1
		return true
	     end 
	end 
	ui.text.reactive = true;
	create_on_button_down_f(ui.text)

end
	
function editor.image()
        cleanText("codes")
        printMsgWindow("Image File : ")
        inputMsgWindow("open_imagefile")
end
	
function editor.video()
        mediaplayer.on_loaded = function( self ) screen:remove(BG_IMAGE) self:play() end 
	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
        mediaplayer:load("golf_game.mp4")	

--[[
        cleanText("codes")
        printMsgWindow("File Name : ")
        inputMsgWindow("open_mediafile")
]]
end
	
function editor.clone()

        if(table.getn(selected_objs) == 0 )then 
		print("error:there aren't any selected objects") 
		return 
        end 

	--print("making clone of .. ", v.name)

	for i, v in pairs(g.children) do
            if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     editor.n_selected(v)
		     ui.clone = Clone {
                     	name="clone"..tostring(item_num),
		     	source = v,
                     	position = {v.x + 20, v.y +20}
        	     }
        	     table.insert(undo_list, {ui.clone.name, ADD, ui.clone})
        	     g:add(ui.clone)
        	     screen:add(g)        
        	     ui.clone.reactive = true
		     create_on_button_down_f(ui.clone)
		     item_num = item_num + 1
		end 
            end
        end

	mouse_mode = S_SELECT
end
	

	
local function get_min_max () 
     local min_x = screen.w
     local max_x = 0
     local min_y = screen.h
     local max_y = 0

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			if(v.x < min_x) then min_x = v.x end 
			if(v.x > max_x) then max_x = v.x end
			if(v.y < min_y) then min_y = v.y end 
			if(v.y > max_y) then max_y = v.y end
		end 
          end
    end
    return min_x, max_x, min_y, max_y
end 

function editor.group()
        local min_x, max_x, min_y, max_y = get_min_max () 
       
        ui.group = Group{
                name="group"..tostring(item_num),
        	position = {min_x, min_y}
        }
        ui.group.reactive = false;
        ui.group.extra.selected = false;
        table.insert(undo_list, {ui.group.name, ADD, ui.group})

	for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if(v.extra.selected == true) then
			editor.n_selected(v)
			g:remove(v)
        		ui.group:add(v)
		  end 
             end
        end

	for i, v in pairs (ui.group.children) do 
		if ui.group:find_child(v.name) then 
			v.extra.is_in_group = true
			v.extra.group_position = ui.group.position
			v.x = v.x - min_x
			v.y = v.y - min_y
		end 
	end 

        g:add(ui.group)
        screen:add(g)

        item_num = item_num + 1
        create_on_button_down_f(ui.group) 
        screen.grab_key_focus(screen)
	mouse_mode = S_SELECT
end



function editor.ugroup()
	for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if(v.extra.selected == true) then
			if(v.type ~= "Group") then 
			     print("error:this object is not Group")
			     return 
			else
			     editor.n_selected(v)
			     g:remove(v)
			     
        		     table.insert(undo_list, {v.name, DEL, v})
			     print(v.name)
			     dumptable(v.children)
			     for i,c in pairs(v.children) do 
			     	if(v:find_child(c.name)) then 
				     print(c.name)
			             dumptable(c.position)
			             dumptable(c.size)
				     c.extra.is_in_group = false
				     c.x = c.x + v.x 
				     c.y = c.y + v.y 
				     v:remove(c)
		     		     g:add(c) 
			     	end 
			     end
		        end 
		   end 
              end
        end
        screen.grab_key_focus(screen)
	mouse_mode = S_SELECT
end
	
local m_init_x = 0 
local m_init_y = 0 
local multi_select_border

function editor.multi_select(x,y) 
 	m_init_x = x -- origin x
        m_init_y = y -- origin y

        multi_select_border = Rectangle{
                name="multi_select_border", 
                border_color= {0,255,0},
                border_width=2,
                color= {0,0,0,0},
                size = {1,1},
                position = {x,y},
		opacity = 255
        }
        multi_select_border.reactive = false
        screen:add(multi_select_border)
end 

function editor.multi_select_done(x,y) 

	if(multi_select_border == nil) then return end 
        multi_select_border.size = { abs(x-m_init_x), abs(y-m_init_y) }

        if(x-m_init_x < 0) then
	   multi_select_border.x = x 
	   m_init_x = x
	   x = m_init_x + multi_select_border.w
        end
        if(y-m_init_y < 0) then
	   multi_select_border.y = y 
	   m_init_y = y
	   y = m_init_y + multi_select_border.h
        end

        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		if (v.x > m_init_x and v.x < x and v.y < y and v.y > m_init_y ) and
		(v.x + v.w > m_init_x and v.x + v.w < x and v.y + v.h < y and v.y + v.h > m_init_y ) then 
			if(shift == true and v.extra.selected == false) then 
		             editor.selected(v)
			end 
		end 
             end
        end
	
	screen:remove(multi_select_border)
	m_init_x = 0 
	m_init_y = 0 
	multi_select_border = nil
        screen.grab_key_focus(screen)
	mouse_mode = S_SELECT

end 

function editor.multi_select_move(x,y)
	if(multi_select_border == nil) then return end 
        multi_select_border.size = { abs(x-m_init_x), abs(y-m_init_y) }
        if(x- m_init_x < 0) then
            multi_select_border.x = x
        end
        if(y- m_init_y < 0) then
            multi_select_border.y = y
        end
end

function editor.group_done(x, y)
        ui.group.size = { abs(x-g_init_x), abs(y-g_init_y) }
        group_border.size = { abs(x-g_init_x), abs(y-g_init_y) }
        if(x-g_init_x < 0) then
           ui.group.w = x - g_init_x 
	   group_border.x = x 
        end
        if(y-g_init_y < 0) then
            ui.group.h = y - g_init_y
	   group_border.y = y 
        end

        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		if (v.x > g_init_x and v.x < x and v.y < y and v.y > g_init_y ) and
		(v.x + v.w > g_init_x and v.x + v.w < x and v.y + v.h < y and v.y + v.h > g_init_y ) then 
		        g:remove(v)
			table.insert(v.extra, v.x)
			table.insert(v.extra, v.y)
			v.x = v.x - g_init_x
			v.y = v.y - g_init_y
			ui.group:add(v)
		end 
             end
        end

        item_num = item_num + 1
        create_on_button_down_f(ui.group) 
        screen.grab_key_focus(screen)
	mouse_mode = S_SELECT
end 

function editor.group_move(x,y)
        ui.group.size = { abs(x-g_init_x), abs(y-g_init_y) }
        group_border.size = { abs(x-g_init_x), abs(y-g_init_y) }
        if(x- g_init_x < 0) then
            ui.group.w = x - g_init_x
	   group_border.x = x 
        end
        if(y- g_init_y < 0) then
            ui.group.h = y - g_init_y
	   group_border.y = y 
        end
end

local function getObjName (border_n) 
     local i, j = string.find(border_n, "border")
     return string.sub(border_n, 1, i-1)
end 

function editor.left() 

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			v.x = basis_obj.x
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

function editor.right() 

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			v.x = basis_obj.x + basis_obj.w - v.w
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

function editor.top()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			v.y = basis_obj.y 
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

function editor.bottom()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			v.y = basis_obj.y + basis_obj.h - v.h 
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end
function editor.vcenter()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			v.x = basis_obj.x + basis_obj.w/2 - v.w/2
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT

end

function editor.hcenter()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			v.y = basis_obj.y + basis_obj.h/2 - v.h/2
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

local function get_x_sort_t()
     
     local x_sort_t = {}
     
     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		        local n = table.getn(x_sort_t)
			if(n ==0) then
				table.insert(x_sort_t, v) 
			elseif (v.x >= x_sort_t[n].x) then
				table.insert(x_sort_t, v) 
			elseif (v.x < x_sort_t[n].x) then  
				local tmp_cord = {}
				while (v.x < x_sort_t[n].x) do
					table.insert(tmp_cord, table.remove(x_sort_t))
					n = table.getn(x_sort_t)
					if n == 0 then 
						break
					end 
				end 
				table.insert(x_sort_t, v) 
				while (table.getn(tmp_cord) ~= 0 ) do 
					table.insert(x_sort_t, table.remove(tmp_cord))
				end 
			end
		end 
          end
     end
      
     return x_sort_t 
end

local function get_reverse_t(sort_t)
     local reverse_t = {}

	while(table.getn(sort_t) ~= 0) do
		table.insert(reverse_t, table.remove(sort_t))
	end 
	return reverse_t 
end

local function get_x_space(x_sort_t)
     local f, b 
     local space = 0
     b = table.remove(x_sort_t) 
     while (table.getn(x_sort_t) ~= 0) do 
          f = table.remove(x_sort_t) 
          space = space + b.x - f.x - f.w
          b = f
     end 
     
     local n = table.getn(selected_objs)
     space = space / (n - 1)
     return space
end 

function editor.hspace()

    if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
    end 

    local  x_sort_t, space, reverse_t, f, b

    x_sort_t = get_x_sort_t()
    dumptable(x_sort_t)

    space = get_x_space(x_sort_t)
    print(space)

    x_sort_t = get_x_sort_t()
    reverse_t = get_reverse_t(x_sort_t)

    f = table.remove(reverse_t)
    while(table.getn(reverse_t) ~= 0) do  
         b = table.remove(reverse_t)
         b.x = f.x + f.w + space 
         f = b 
    end 
    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

local function get_y_sort_t()
     local y_sort_t = {}
     local n
     
     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		        n = table.getn(y_sort_t)
			if(n ==0) then
				table.insert(y_sort_t, v) --{v.x, v.w})
			elseif (v.y >= y_sort_t[n].y) then
				table.insert(y_sort_t, v) --{v.x, v.w})
			elseif (v.y < y_sort_t[n].y) then  
				local tmp_cord = {}
				while (v.y < y_sort_t[n].y) do
					table.insert(tmp_cord, table.remove(y_sort_t))
					n = n - 1
					if(table.getn(y_sort_t) == 0) then 
						break
					end 
				end 
				table.insert(y_sort_t, v) -- {v.x, v.w})
				while (table.getn(tmp_cord) ~= 0 ) do 
					table.insert(y_sort_t, table.remove(tmp_cord))
				end 
			end
		end 
          end
     end
      
     return y_sort_t 
end


local function get_y_space(y_sort_t)
     local f, b 
     local space = 0
     b = table.remove(y_sort_t) 
     while (table.getn(y_sort_t) ~= 0) do 
          f = table.remove(y_sort_t) 
          space = space + b.y - f.y - f.h
          b = f
     end 
     
     local n = table.getn(selected_objs)
     space = space / (n - 1)
     return space
end 

function editor.vspace()

    if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
    end 

    local  y_sort_t, space, reverse_t, f, b

    y_sort_t = get_y_sort_t()
    space = get_y_space(y_sort_t)
    y_sort_t = get_y_sort_t()
    reverse_t = get_reverse_t(y_sort_t)

    f = table.remove(reverse_t)
    while(table.getn(reverse_t) ~= 0) do  
         b = table.remove(reverse_t)
         b.y = f.y + f.h + space 
         f = b 
    end 

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

function editor.bring_to_front()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			g:remove(v)
			g:add(v)
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

function editor.send_to_back()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local tmp_g = {}
     local slt_g = {}

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        g:remove(v) 
	        if(v.extra.selected == true) then
		        table.insert(slt_g, v)
			editor.n_selected(v)
		else 
		     	table.insert(tmp_g, v) 
		end
          end
    end
    
    while(table.getn(slt_g) ~= 0) do
	v = table.remove(slt_g)
	g:add(v)	
    end 
    
    tmp_g = get_reverse_t(tmp_g) --kk
    while(table.getn(tmp_g) ~= 0) do
	v = table.remove(tmp_g)
	g:add(v)	
    end 
	
    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

function editor.send_backward()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local tmp_g = {}
     local slt_g = {}

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        g:remove(v)  -- 1,2,(3)
		if(table.getn(slt_g) ~= 0) then 
			local b = table.remove(slt_g)
			local f = table.remove(tmp_g)
			table.insert(tmp_g, b)
			table.insert(tmp_g, f) 
		end 
	        if(v.extra.selected == true) then
			table.insert(slt_g, v) 
			editor.n_selected(v)
		else 
		      	table.insert(tmp_g, v) 
		end
          end
    end


    if(table.getn(slt_g) ~= 0) then 
	local b = table.remove(slt_g) 
	local f = table.remove(tmp_g) 
	table.insert(tmp_g, b) 
	table.insert(tmp_g, f) 
    end 

    tmp_g = get_reverse_t(tmp_g)
    while(table.getn(tmp_g) ~= 0) do
	v = table.remove(tmp_g)
	g:add(v) 
    end 

    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT

end

function editor.bring_forward()

     if(table.getn(selected_objs) == 0 )then 
	print("error:there aren't any selected objects") 
	return 
     end 

     local tmp_g = {}
     local slt_g = {}

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        g:remove(v) 
		if(table.getn(slt_g) ~= 0) then 
			table.insert(tmp_g, v)
			table.insert(tmp_g, table.remove(slt_g))
		end 
	        if(v.extra.selected == true) then
			table.insert(slt_g, v) 
			editor.n_selected(v)
		else 
		      	table.insert(tmp_g, v) 
		end
          end
    end

    if(table.getn(slt_g) ~= 0) then
    	table.insert(tmp_g, table.remove(slt_g))
    end 
    tmp_g = get_reverse_t(tmp_g)
    while(table.getn(tmp_g) ~= 0) do
	v = table.remove(tmp_g)
	g:add(v)
    end 
	
    screen.grab_key_focus(screen)
    mouse_mode = S_SELECT
end

