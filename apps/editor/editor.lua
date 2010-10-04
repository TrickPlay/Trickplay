editor = {}
dofile("apply.lua")
dofile("util.lua")

--local g = Group ()
--local contents    = ""
--local item_num    = 0
local rect_init_x = 0
local rect_init_y = 0

local factory = ui.factory

function editor.close()
        screen:remove(g)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
                  g:remove(g:find_child(v.name))
             end
        end
	undo_list = {}
	redo_list = {}
        cleanText("codes")
        item_num = 0
        current_filename = ""
        screen.grab_key_focus(screen)
end 

function editor.selected(obj)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if (obj.name ~= v.name) then 
		       g:find_child(v.name).extra.org_opacity = g:find_child(v.name).opacity
                       g:find_child(v.name):set{opacity = 50}
		  end 
             end
        end
end  

function editor.n_selected(obj)
        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  g:find_child(v.name):set{opacity = g:find_child(v.name).extra.org_opacity} 
             end
        end
end  

function editor.open()
        editor.close()
        printScreen("File Name : ")
        inputScreen("openfile")
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
	     n_attr_n = attr_t[i][3] 

	     if(type(attr_i) == table ) then
	          attr_v = table.concat(attr_i,",")
             else
                  attr_v = tostring(attr_i)
             end 

	     if(n_attr_n == nil) then n_attr_n = "" end 
	     
	     local item = factory.make_text_popup_item(assets, attr_n, attr_v, n_attr_n) 
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
	local org_obj, new_obj

	function grab_focus(attr) 
        if inspector:find_child(attr) and  
             inspector:find_child(attr):find_child("input_text") then
             inspector:find_child(attr):find_child("input_text"):grab_key_focus()
             inspector:find_child(attr):find_child("input_text"):set{cursor_visible = true, cursor_size = 3}
             inspector:find_child(attr).extra.on_focus_in()

	     input_txt = inspector:find_child(attr):find_child("input_text")
	     function input_txt:on_key_down(key)
	          if key == keys.Return or
                     key == keys.Tab or 
                     key == keys.Right then
                     inspector:find_child(attr).extra.on_focus_out()
                     inspector:find_child(attr):find_child("input_text"):set{cursor_visible = false}
                     grab_focus(inspector:find_child(attr):find_child("next_attr").text)
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
		          editor.n_selected(v)
                          screen.grab_key_focus(screen) 
			  -- org_obj, new_obj = inspector_apply (v, inspector) 
		          editor.view_code()
	                  return true
		      elseif (attr == "apply") then 
			  org_obj, new_obj = inspector_apply (v, inspector) 
		          screen:remove(inspector)
		          current_inspector = nil
		          editor.n_selected(v)
                          screen.grab_key_focus(screen) 
		      elseif (attr == "cancel") then 
		          screen:remove(inspector)
		          current_inspector = nil
		          editor.n_selected(v)
                          screen.grab_key_focus(screen) 
	                  return true
		      end 
 		   elseif key == keys.Tab or key == keys.Right then 
                      inspector:find_child(attr).extra.on_focus_out()
                      grab_focus(inspector:find_child(attr):find_child("next_attr").text)
                   end
              end

        end
	end 

	grab_focus("name") 
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

function editor.view_code()
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

end 

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
        undo_list = {}
        redo_list = {}
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
	  if undo_item[2] == CHG then 
               local the_obj = g:find_child(undo_item[1])
 	       the_obj:set{opacity = undo_item[3].opacity} 
 	       the_obj:set{w = undo_item[3].w, h =undo_item[3].h } 
 	       --the_obj:set{color = undo_item[3].color}
	       redo_item = {undo_item[3].name, CHG, undo_item[3], undo_item[4]}
	       table.insert(redo_list, redo_item)
	  elseif undo_item[2] == ADD then 
               editor.delete(g:find_child(undo_item[1]))
               table.insert(redo_list, undo_item)
	  elseif undo_item[2] == DEL then 
               editor.add(g:find_child(undo_item[1])) 
               table.insert(redo_list, undo_item)
 	  end 
end
	
function editor.undo_history()
--[[
        local temp_list = redo_list 
        do 
        	temp_itme = table.remove(temp_list)
		print (temp_item[1], temp_item[2])
        while (temp_list == nil)
]]
end
	
function editor.redo()
          
	  if( redo_list == nil) then return true end 
          local redo_item= table.remove(redo_list)
 	  
          if redo_item[2] == CHG then 
              local the_obj = g:find_child(redo_item[1])
	       the_obj:set{opacity = redo_item[4].opacity}
 	       the_obj:set{w = redo_item[4].w, h =redo_item[4].h } 
               undo_item = {redo_item[4].name, CHG, redo_item[3], redo_item[4]}
               table.insert(undo_list, undo_item)
          elseif redo_item[2] == ADD then 
               editor.add(g:find_child(redo_item[1]))
              -- table.insert(undo_list, redo_item)
          elseif undo_item[2] == DEL then 
               editor.delete(g:find_child(redo_item[1]))
              -- table.insert(undo_list, redo_item)
          end 
end

function editor.add(obj)
	g:add(obj)
        --screen:add(g:find_child(obj.name))
        screen:add(obj)
        table.insert(undo_list, {obj.name, ADD, obj})
end

function editor.delete(obj)
        --screen:remove(g:find_child(obj.name))
        screen:remove(obj)
        table.insert(undo_list, {obj.name, DEL, obj})
	g:remove(obj)
end

function editor.debug()
	print("Debuggin Msg ----- ")
	dumptable(undo_list)
	dumptable(redo_list)
	print("-------------------")
end 

function editor.preferences()
     -- background setting 
     -- ruler 
     -- menu hidign 
     -- file saving  
end

function editor.text()

        cleanText("codes")
        ui.text = Text{
        name="text"..tostring(item_num),
	text = "", font= "DejaVu Sans 40px",
     	color = DEFAULT_COLOR, position ={100, 100}, editable = true ,
     	reactive = true, wants_enter = true, size = {150, 150},wrap=true, wrap_mode="CHAR"} 
        table.insert(undo_list, {ui.text.name, ADD, ui.text})
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
	

