dofile("apply.lua")

editor = {}


local rect_init_x = 0
local rect_init_y = 0
local g_init_x = 0
local g_init_y = 0
local factory = ui.factory

function guideline_type(name) 
    local i, j = string.find(name,"v_guideline")
    if(i ~= nil and j ~= nil)then 
         return "v_guideline"
    end 
    local i, j = string.find(name,"h_guideline")
    if(i ~= nil and j ~= nil)then 
         return "h_guideline"
    end 
    return ""
end 


local function guideline_inspector(v)
	local gw  = Group {
	     name = "msgw",
	     position ={500, 500},
	     anchor_point = {0,0},
             children = {}
        }
	local input_h, input_v, input_box_h, input_box_v
	local save_t, save_b, cancel_t, cancel_b, delete_t, delete_b

	local function create_on_key_down_f(button) 
     	     function button:on_key_down(key)
	     if key == keys.Return then
              	if (button.name == "apply") then 
		     if (input_h.text ~= "") then 
			v.y = tonumber(input_h.text) 
		     elseif (input_v.text ~= "") then 
			v.x = tonumber(input_v.text) 
		     end 
              	elseif (button.name == "delete") then  
		     screen:remove(screen:find_child(v.name))
              	end
		gw.children = {}
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	        return true 
	     elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
              	if (button.name == "cancel") then cancel_b.extra.on_focus_out() save_b.extra.on_focus_in()
              	elseif (button.name == "apply") then save_b.extra.on_focus_out() delete_b.extra.on_focus_in()
              	elseif (button.name == "delete") then 
		     delete_b.extra.on_focus_out()
		     if(guideline_type(v.name) == "v_guideline") then 
			  input_box_v.extra.on_focus_in()
                          input_v.cursor_visible = true
		     elseif(guideline_type(v.name) == "h_guideline") then 
			  input_box_h.extra.on_focus_in()
                          input_h.cursor_visible = true
		     end 
                end
	        return true 
	     elseif (key == keys.Tab and shift == true) or ( key == keys.Up ) or (key == keys.Left) then 
              	if (button.name == "apply") then 
		     save_b.extra.on_focus_out() 
		     cancel_b.extra.on_focus_in()
              	elseif (button.name == "cancel") then 
	             cancel_b.extra.on_focus_out()	
		     if(guideline_type(v.name) == "v_guideline") then 
			  input_box_v.extra.on_focus_in()
                          input_v.cursor_visible = true
		     elseif(guideline_type(v.name) == "h_guideline") then 
			  input_box_h.extra.on_focus_in()
                          input_h.cursor_visible = true
		     end 
              	elseif (button.name == "delete") then 
		     delete_b.extra.on_focus_out()
		     save_b.extra.on_focus_in()
                end
	        return true 
	     end 
             end 
        end 

	local gw_bg = factory.make_popup_bg("guidew", 0)

     	gw:add(gw_bg)
     	gw:add(Text{name= "title", text = "GUIDE LINE", font= "DejaVu Sans 25px",
     	color = "FFFFFF", position ={gw.w * 2/5, 40}, editable = false , reactive = false})

	if(guideline_type(v.name) == "h_guideline") then 
             input_h = Text { name="input_h", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = tostring(v.y), editable = true , reactive = true, cursor_visible=false}

             input_v = Text { name="input_v", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = "" , editable = true , reactive = true, cursor_visible=false}
	elseif(guideline_type(v.name) == "v_guideline") then 
             input_v = Text { name="input_v", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = tostring(v.x) , editable = true , reactive = true, cursor_visible=false}

             input_h = Text { name="input_h", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = "", editable = true , reactive = true, cursor_visible=false}
	end 

	gw:add(Text{name= "horiz", text = "HORIZ.", font= "DejaVu Sans 25px",
     	color = "FFFFFF", position ={40, 90}, editable = false , reactive = false})

	input_box_h = create_tiny_input_box(input_h)
        input_box_h.position = {140, 90}
        gw:add(input_box_h)

	gw:add(Text{name= "vert", text = "VERT.", font= "DejaVu Sans 25px",
     	color = "FFFFFF", position ={350, 90}, editable = false ,
     	reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}) 
	
	input_box_v = create_tiny_input_box(input_v)
        input_box_v.position = {430, 90}
        gw:add(input_box_v)

	save_b, save_t  = factory.make_msgw_button_item( assets , "Apply")
        save_b.position = {250, 150}
	save_b.reactive = true 
	save_b.name = "apply"

        cancel_b, cancel_t= factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {40, 150}
	cancel_b.reactive = true 
	cancel_b.name = "cancel"
	
        delete_b, delete_t= factory.make_msgw_button_item( assets ,"Delete")
        delete_b.position = {450, 150}
	delete_b.reactive = true 
	delete_b.name = "delete"

        gw:add(cancel_b)
        gw:add(save_b)
        gw:add(delete_b)

	create_on_key_down_f(save_b) 
	create_on_key_down_f(cancel_b) 
	create_on_key_down_f(delete_b) 

	 function input_h:on_key_down(key)
		if(key == keys.Return) then 
		elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
			input_box_h.extra.on_focus_out()
                        input_h.cursor_visible = false
              		cancel_b.extra.on_focus_in()
	                return true 
                end
	 end

	 function input_v:on_key_down(key)
		if(key == keys.Return) then 
		elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
			input_box_v.extra.on_focus_out()
                        input_v.cursor_visible = false
			cancel_b.extra.on_focus_in()
			return true
		end 
	 end
	
	 function cancel_b:on_button_down(x,y,button,num_clicks)
		gw.children = {}
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
         end 

         function cancel_t:on_button_down(x,y,button,num_clicks)
		gw.children = {}
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
         end 

	 function save_b:on_button_down(x,y,button,num_clicks)
		if (input_h.text ~= "") then 
		     v.y = tonumber(input_h.text) 
		elseif (input_v.text ~= "") then 
		     v.x = tonumber(input_v.text) 
		end 
		gw.children = {}
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 

         function save_t:on_button_down(x,y,button,num_clicks)
	        if (input_h.text ~= "") then 
		     v.y = tonumber(input_h.text) 
		elseif (input_v.text ~= "") then 
		     v.x = tonumber(input_v.text) 
		end 

		gw.children = {}
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 

	 function delete_b:on_button_down(x,y,button,num_clicks)
		gw.children = {}
		screen:remove(screen:find_child(v.name))
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 

         function delete_t:on_button_down(x,y,button,num_clicks)
		gw.children = {}
		screen:remove(screen:find_child(v.name))
		screen:remove(gw)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 
         
	input_mode = S_POPUP 
	screen:add(gw)

	if(guideline_type(v.name) == "h_guideline")then 
            input_h.cursor_visible = true
	    input_box_h.extra.on_focus_in()
	    input_h:grab_key_focus()
	else 
            input_v.cursor_visible = true
	    input_box_v.extra.on_focus_in()
	    input_v:grab_key_focus()
	end

end 

local function create_on_line_down_f(v)
        function v:on_button_down(x,y,button,num_clicks)
             dragging = {v, x - v.x, y - v.y }
	     v.color = {50, 50,50,255}
	     if(button == 3 or num_clicks >= 2) then
		  guideline_inspector(v)
                  return true
             end 
 
             return true
        end

        function v:on_button_up(x,y,button,num_clicks)
	     if(dragging ~= nil) then 
	          local actor , dx , dy = unpack( dragging )
		  if(guideline_type(v.name) == "v_guideline") then 
			v.x = x - dx
		  elseif(guideline_type(v.name) == "h_guideline") then  
			v.y = y - dy
		  end 
	          dragging = nil
             end
	     v.color = {100,255,25,255}
             return true
        end
end 

function editor.v_guideline()

     v_guideline = v_guideline + 1 


     local v_gl = Rectangle {
		name="v_guideline"..tostring(v_guideline),
		border_color={255,255,255,255},
		border_color={255,255,255,255},
		color={100,255,25,255},
		size = {4, screen.h},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w/2, 0, 0}, 
		opacity = 255,
		reactive = true
     }
     create_on_line_down_f(v_gl)
     screen:add(v_gl)
end

function editor.h_guideline()
     
     h_guideline = h_guideline + 1


     local h_gl = Rectangle {
		name="h_guideline"..tostring(h_guideline),
		border_color={255,255,255,255},
		border_color={255,255,255,255},
		color={100,255,25,255},
		size = {screen.w, 4},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {0, screen.h/2, 0}, 
		opacity = 255,
		reactive = true
     }

     create_on_line_down_f(h_gl)
     screen:add(h_gl)
end


function editor.selected(obj, call_by_inspector)

     if(obj.type ~= "Video") then 
     if(shift == false)then 
	
	while(table.getn(selected_objs) ~= 0) do
		local t_border = screen:find_child(table.remove(selected_objs)) 
		if(t_border ~= nil) then 
		     screen:remove(t_border)
		     local i, j = string.find(t_border.name,"border")
		     t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
                     if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
     			screen:remove(screen:find_child(t_obj.name.."a_m"))
     		     end
		     if(t_obj ~= nil) then 
			t_obj.extra.selected = false
	             end
		end
	end

     end 

     obj_border = Rectangle{}
     obj_border.name = obj.name.."border"
     obj_border.color = {0,0,0,0}
     obj_border.border_color = {255,0,0,255}
     obj_border.border_width = 2
     local group_pos
     if(obj.extra.is_in_group == true)then 
	group_pos = get_group_position(obj)
     	obj_border.x = obj.x + group_pos[1]
     	obj_border.y = obj.y + group_pos[2]
	obj_border.extra.group_postion = obj.extra.group_position
     else 
     	obj_border.position = obj.position
     end
     obj_border.anchor_point = obj.anchor_point
     obj_border.x_rotation = obj.x_rotation
     obj_border.y_rotation = obj.y_rotation
     obj_border.z_rotation = obj.z_rotation
     obj_border.size = obj.size
     if(obj.scale ~= nil) then 
          obj_border.scale = obj.scale
     end 

     if (screen:find_child(obj.name.."a_m") ~= nil) then 
     	screen:remove(screen:find_child(obj.name.."a_m"))
     end

     anchor_mark= ui.factory.draw_anchor_pointer()
     if(obj.extra.is_in_group == true)then 
          anchor_mark.position = {obj.x + group_pos[1] , obj.y + group_pos[2], obj.z}
     else 
          anchor_mark.position = {obj.x, obj.y, obj.z}
     end
     anchor_mark.name = obj.name.."a_m"
     screen:add(anchor_mark)
     screen:add(obj_border)
     obj.extra.selected = true
     table.insert(selected_objs, obj_border.name)
     end 
end  

function editor.n_select(obj, call_by_inspector, drag)

     if(obj.name == nil) then return end 

     if(obj.type ~= "Video") then 

     if(shift == false)then 
	while(table.getn(selected_objs) ~= 0) do
		local t_border = screen:find_child(table.remove(selected_objs)) 
		if(t_border ~= nil) then 
		     screen:remove(t_border)
		     local i, j = string.find(t_border.name,"border")
		     t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		     if(t_obj ~= nil) then 
			t_obj.extra.selected = false
        		if (screen:find_child(t_obj.name.."a_m") ~= nil) then 
	   			screen:remove(screen:find_child(t_obj.name.."a_m"))
        		end
	             end
		end
	end
	if(drag == nil) then
	     editor.selected(obj) 
	end 
     else
        if (screen:find_child(obj.name.."a_m") ~= nil) then 
	     screen:remove(screen:find_child(obj.name.."a_m"))
        end
        screen:remove(screen:find_child(obj.name.."border"))
        table.remove(selected_objs)
        obj.extra.selected = false
     end 

    end
end  

function editor.n_selected(obj, call_by_inspector)

     if(obj.name == nil) then return end 
     if(obj.type ~= "Video") then 
        screen:remove(screen:find_child(obj.name.."border"))
        if (screen:find_child(obj.name.."a_m") ~= nil) then 
	     screen:remove(screen:find_child(obj.name.."a_m"))
        end
        table.remove(selected_objs)
        obj.extra.selected = false
     end 

end  

function editor.close()

	clear_bg()
        if(g.extra.video ~= nil) then 
	    g.extra.video = nil
	    mediaplayer:reset()
            mediaplayer.on_loaded = nil
	end

	BG_IMAGE_40.opacity = 255 

	for i, j in pairs (g.children) do 
	     if(j.extra.selected == true) then 
		editor.n_selected(j) 
	     end 
	end 

	if(screen:find_child("mouse_pointer") ~= nil) then 
             screen:remove(mouse_pointer) 
	end 
	
	if(table.getn(g.children) ~= 0) then 
             screen:remove(g)
	end 

        for i, v in pairs(g.children) do
             if g:find_child(v.name) then
                  g:remove(g:find_child(v.name))
		  if(screen:find_child(v.name.."border")) then
                       screen:remove(screen:find_child(v.name.."border"))
		  end 
             end
        end

	if(screen:find_child("xscroll_bar") ~= nil) then 
		screen:remove(screen:find_child("xscroll_bar")) 
		screen:remove(screen:find_child("xscroll_box")) 
		screen:remove(screen:find_child("x_0_mark"))
		screen:remove(screen:find_child("x_1920_mark"))
	end 

	if(screen:find_child("scroll_bar") ~= nil) then 
		screen:remove(screen:find_child("scroll_bar")) 
		screen:remove(screen:find_child("scroll_box")) 
		screen:remove(screen:find_child("y_0_mark"))
		screen:remove(screen:find_child("y_1080_mark"))
	end 


	for i=1, v_guideline, 1 do 
	   if(screen:find_child("v_guideline"..i) ~= nil) then 
	     screen:remove(screen:find_child("v_guideline"..i))
	   end 
	end
    
	for i=1, h_guideline, 1 do 
	   if(screen:find_child("h_guideline"..i) ~= nil) then 
	     screen:remove(screen:find_child("h_guideline"..i))
	   end 
	end

	undo_list = {}
	redo_list = {}
        item_num = 0
        current_fn = ""
        screen.grab_key_focus(screen)

	g.extra.canvas_f = 0
	g.extra.canvas_t = 0
	g.extra.canvas_xf = 0
	g.extra.canvas_xt = 0
	g.extra.scroll_y = 0
	g.extra.scroll_x = 0
	g.extra.canvas_w = screen.w
	g.extra.canvas_h = screen.h
	g.extra.scroll_dy = 0
	g.extra.scroll_dx = 0
end 

function editor.open()

    -- editor.close()
     if(CURRENT_DIR == "") then 
	set_app_path()
     else 
        input_mode = S_POPUP
        printMsgWindow("File Name : ")
        inputMsgWindow("openfile")
     end 
     
end 

local function cleanMsgWin(msgw)	
     msgw.children = {}
     screen:remove(msgw)
     input_mode = S_SELECT
end 

function editor.the_image()
---[[
	local WIDTH = 700
	local L_PADDING = 50
	local R_PADDING = 50
        local TOP_PADDING = 60
        local BOTTOM_PADDING = 12
        local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF"}
	local space = WIDTH

	local dir = editor_lb:readdir(CURRENT_DIR)
	local dir_text = Text {name = "dir", text = "File Location : "..CURRENT_DIR}:set(STYLE)

	local cur_w= (WIDTH - dir_text.w)/2
	local cur_h= TOP_PADDING/2 + Y_PADDING


	dir_text.position = {cur_w,cur_h,0}

	--local line = factory.draw_line()
	
	function get_file_list_sz() 
	     local iw = cur_w
	     local ih = cur_h
	     cur_w = L_PADDING
	     cur_h = cur_h + dir_text.h + Y_PADDING

     	     for i, v in pairs(dir) do
	          if (is_img_file(v) == true) then 
	               text = Text {name = tostring(i), text = v}:set(STYLE)

                       text.position  = {cur_w, cur_h,0}
		       if(cur_w == L_PADDING) then
				cur_w = cur_w + 7*L_PADDING
		       else 
	               		cur_w = L_PADDING 
	               		cur_h = cur_h + text.h + Y_PADDING
		       end
                  end 
             end

	     local return_h = cur_h - 40

	     cur_w = iw
	     cur_h = ih
	     return return_h 
        end 

	local file_list_size = get_file_list_sz()
        local scroll_box 
        local scroll_bar 
	
	if (file_list_size > 500) then 
             scroll_box = factory.make_msgw_scroll_box()
             scroll_bar = factory.make_msgw_scroll_bar(file_list_size)
	     file_list_size = 500 
	end 
	
	local msgw_bg = factory.make_popup_bg("file_ls", file_list_size)

	local msgw = Group {
	     position ={500, 100,0},
	     anchor_point = {0,0},
             children =
             {
              msgw_bg,
             }
	}

        msgw:add(dir_text)

	local text_g
	local input_text
	function print_file_list() 
	     cur_w = L_PADDING
             cur_h = TOP_PADDING + dir_text.h + Y_PADDING
	     text_g = Group{position = {cur_w, cur_h,0}}
	     text_g.extra.org_y = cur_h
	     text_g.reactive  = true 

	     cur_w = 0
	     cur_h = 0 
     	     for i, v in pairs(dir) do
	          if (is_img_file(v) == true) then 
	               text = Text {name = tostring(i), text = v}:set(STYLE)

                       text.position = {cur_w, cur_h,0}
	 	       text.reactive = true
    	               text_g:add(text)

		       if(cur_w == 0) then
				cur_w = cur_w + 7*L_PADDING
		       else 
	               		cur_w = 0
	               		cur_h = cur_h + text.h + Y_PADDING
		       end
                  end
             end

	     cur_w = cur_w + L_PADDING
	     cur_h = cur_h + TOP_PADDING + dir_text.h + Y_PADDING
	     text_g.clip = {0,0,text_g.w,500}
    	     msgw:add(text_g)
        end 
	
	print_file_list()
	if(scroll_bar ~= nil) then 
	     scroll_box.position = {720, TOP_PADDING + dir_text.h + Y_PADDING}
	     scroll_bar.position = {724, TOP_PADDING + dir_text.h + Y_PADDING + 4}
	     scroll_bar.extra.org_y = TOP_PADDING + dir_text.h + Y_PADDING + 4
	     scroll_bar.extra.txt_y = text_g.extra.org_y
	     scroll_bar.extra.h_y = TOP_PADDING + dir_text.h + Y_PADDING + 4
	     scroll_bar.extra.l_y = scroll_bar.extra.h_y + 500 - scroll_bar.h
	     scroll_bar.extra.text_clip = text_g.clip 
	     scroll_bar.extra.text_position = text_g.position 
	     msgw:add(scroll_box)
	     msgw:add(scroll_bar)
 
             function scroll_bar:on_button_down(x,y,button,num_clicks)
	     	dragging = {scroll_bar, x- scroll_bar.x, y - scroll_bar.y }
        	return true
    	     end 

    	     function scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      	      local actor , dx , dy = unpack( dragging )
	       		if (actor.extra.h_y < y-dy and y-dy < actor.extra.l_y) then 	
	           		local dif = y - dy - scroll_bar.extra.org_y
	           		scroll_bar.y = y - dy 
	           		text_g.position = {text_g.x, text_g.extra.org_y -dif}
	           		text_g.clip = {0,dif,text_g.w,500}
	      		end 
	      		dragging = nil
	 	end 
         	return true
            end 
 	end 

        for i,j in pairs (text_g.children) do 
         function j:on_button_down(x,y,button, num_clicks)
	      if input_text ~= nil then 
		    input_text.color = {255, 255, 255, 255}
	      end 
              input_text = j
	      j.color = {0,255,0,255}
	      return true
         end 
        end 

    local open_b, open_t  = factory.make_msgw_button_item( assets , "open")
    open_b.position = {(WIDTH - 2*open_b.w - X_PADDING)/2, file_list_size + 110}
    open_b.name = "openfile"
    open_b.reactive = true

    local cancel_b, cancel_t = factory.make_msgw_button_item( assets , "cancel")
    cancel_b.position = {open_b.x + open_b.w + X_PADDING, file_list_size + 110}
    cancel_b.name = "cancel"
    cancel_b.reactive = true 
	
    msgw:add(open_b)
    msgw:add(cancel_b)

    function open_b:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
	      inputMsgWindow_openimage("open_imagefile", input_text.text)
	      cleanMsgWin(msgw)
	 end 
    end 
    function open_t:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
	      inputMsgWindow_openimage("open_imagefile", input_text.text)
	      cleanMsgWin(msgw)
	 end 
    end 

    function cancel_b:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    function cancel_t:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    screen:add(msgw)
--]]
end 


function editor.the_open()
---[[
	local WIDTH = 700
	local L_PADDING = 50
	local R_PADDING = 50
        local TOP_PADDING = 60
        local BOTTOM_PADDING = 12
        local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF"}
	local space = WIDTH

	local dir = editor_lb:readdir(CURRENT_DIR)
	local dir_text = Text {name = "dir", text = "File Location : "..CURRENT_DIR}:set(STYLE)

	local cur_w= (WIDTH - dir_text.w)/2
	local cur_h= TOP_PADDING/2 + Y_PADDING


	dir_text.position = {cur_w,cur_h}

	--local line = factory.draw_line()
	
	function get_file_list_sz() 
	     local iw = cur_w
	     local ih = cur_h
	     cur_w = L_PADDING
	     cur_h = cur_h + dir_text.h + Y_PADDING

     	     for i, v in pairs(dir) do
	          if (is_lua_file(v) == true) then 
	               text = Text {name = tostring(i), text = v}:set(STYLE)

                       text.position  = {cur_w, cur_h}
		       if(cur_w == L_PADDING) then
				cur_w = cur_w + 7*L_PADDING
		       else 
	               		cur_w = L_PADDING 
	               		cur_h = cur_h + text.h + Y_PADDING
		       end
                  end 
             end

	     local return_h = cur_h - 40

	     cur_w = iw
	     cur_h = ih
	     return return_h 
        end 

	
	local file_list_size = get_file_list_sz()
        local scroll_box 
        local scroll_bar 
	
	if (file_list_size > 500) then 
             scroll_box = factory.make_msgw_scroll_box()
             scroll_bar = factory.make_msgw_scroll_bar(file_list_size)
	     file_list_size = 500 
	end 
	
	local msgw_bg = factory.make_popup_bg("file_ls", file_list_size)

	local msgw = Group {
	     position ={500, 100},
	     anchor_point = {0,0},
             children =
             {
              msgw_bg,
             }
	}

        msgw:add(dir_text)

	local text_g
	local input_text
	function print_file_list() 
	     cur_w = L_PADDING
             cur_h = TOP_PADDING + dir_text.h + Y_PADDING
	     text_g = Group{position = {cur_w, cur_h}}
	     text_g.extra.org_y = cur_h
	     text_g.reactive  = true 

	     cur_w = 0
	     cur_h = 0 
     	     for i, v in pairs(dir) do
	          if (is_lua_file(v) == true) then 
	               text = Text {name = tostring(i), text = v}:set(STYLE)

                       text.position = {cur_w, cur_h}
	 	       text.reactive = true
    	               text_g:add(text)

		       if(cur_w == 0) then
				cur_w = cur_w + 7*L_PADDING
		       else 
	               		cur_w = 0
	               		cur_h = cur_h + text.h + Y_PADDING
		       end
                  end
             end

	     cur_w = cur_w + L_PADDING
	     cur_h = cur_h + TOP_PADDING + dir_text.h + Y_PADDING
	     text_g.clip = {0,0,text_g.w,500}
    	     msgw:add(text_g)
        end 
	
	print_file_list()
	if(scroll_bar ~= nil) then 
	     scroll_box.position = {720, TOP_PADDING + dir_text.h + Y_PADDING}
	     scroll_bar.position = {724, TOP_PADDING + dir_text.h + Y_PADDING + 4}
	     scroll_bar.extra.org_y = TOP_PADDING + dir_text.h + Y_PADDING + 4
	     scroll_bar.extra.txt_y = text_g.extra.org_y
	     scroll_bar.extra.h_y = TOP_PADDING + dir_text.h + Y_PADDING + 4
	     scroll_bar.extra.l_y = scroll_bar.extra.h_y + 500 - scroll_bar.h
	     scroll_bar.extra.text_clip = text_g.clip 
	     scroll_bar.extra.text_position = text_g.position 
	     msgw:add(scroll_box)
	     msgw:add(scroll_bar)

 
    	function scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {scroll_bar, x- scroll_bar.x, y - scroll_bar.y }
        	return true
    	end 

    	function scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
	      		if (actor.extra.h_y < y-dy and y-dy < actor.extra.l_y) then 	
	           		local dif = y - dy - scroll_bar.extra.org_y
	           		scroll_bar.y = y - dy 
	           		text_g.position = {text_g.x, text_g.extra.org_y -dif}
	           		text_g.clip = {0,dif,text_g.w,500}
	      		end 
	      		dragging = nil
	 	end 
         	return true
    	end 
    end 

    for i,j in pairs (text_g.children) do 
         function j:on_button_down(x,y,button, num_clicks)
	      if input_text ~= nil then 
		    input_text.color = {255, 255, 255, 255}
	      end 
              input_text = j
	      j.color = {0,255,0,255}
	      return true
         end 
    end 

    local open_b, open_t  = factory.make_msgw_button_item( assets , "open")
    open_b.position = {(WIDTH - 2*open_b.w - X_PADDING)/2, file_list_size + 110}
    open_b.name = "openfile"
    open_b.reactive = true

    local cancel_b, cancel_t = factory.make_msgw_button_item( assets , "cancel")
    cancel_b.position = {open_b.x + open_b.w + X_PADDING, file_list_size + 110}
    cancel_b.name = "cancel"
    cancel_b.reactive = true 
	
    msgw:add(open_b)
    msgw:add(cancel_b)

    function open_b:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
              inputMsgWindow_openfile(input_text.text) 
	      cleanMsgWin(msgw)
	 end 
    end 
    function open_t:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
              inputMsgWindow_openfile(input_text.text) 
	      cleanMsgWin(msgw)
	 end 
    end 

    function cancel_b:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    function cancel_t:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

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
	
        editor.n_selected(v) --add 1108
	
        for i, c in pairs(g.children) do
            if g:find_child(c.name) then
	        if(c.extra.selected == true and c.name ~= v.name) then
			editor.n_selected(c)
		end
		if(c.type == "Text") then 
			c.reactive = false
		end 
            end
        end

        --editor.selected(v, true)
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
	     if(v.type == "Video") then return end 
 
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

	if(v.type ~= "Video") then
	     inspector_position() 
	else 
	     inspector.x = screen.w/8
	     inspector.y = screen.h/8
	end 

	local attr_n, attr_v
	local i = 0
	for i=1,40 do 
             if (attr_t[i] == nil) then break end 
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
		
	     if  attr_n == "name" or attr_n == "text" or attr_n == "src" 
	       or attr_n == "r" or attr_n == "g" or attr_n == "b" 
	       or attr_n == "rect_r" or attr_n == "rect_g" or attr_n == "rect_b" or attr_n == "rect_a" 
	       or attr_n == "bord_r" or attr_n == "bord_g" or attr_n == "bord_b"
	       or attr_n == "font "  
	       then 
                 --item.y = items_height - 15
                 item.y = items_height 
             --elseif (attr_n == "line") then  
                 --item.y = items_height  + 40

	     elseif (attr_n == "caption") then  
                  item.y = items_height + 10
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
	input_mode = S_POPUP
	inspector:find_child("name").extra.on_focus_in()
	
	current_inspector = inspector
        inspector.reactive = true
	create_on_button_down_f(inspector)

        inspector_xbox.reactive = true
	function inspector_xbox:on_button_down(x,y,button,num_clicks)
		editor.n_selected(v, true)
		screen:remove(inspector)
		current_inspector = nil
			
        	for i, c in pairs(g.children) do
		    if(c.type == "Text") then 
			c.reactive = true
		    end 
                end

                screen.grab_key_focus(screen) 
	        input_mode = S_SELECT
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
	local codeViewWin 

	if(v.type ~= "Video") then 
	     codeViewWin = Group {
	          name = "Code",
	          position ={0, 0},
                  children =
                  {
                    codeViewWin_bg,
	            xbox:set{position = {765, 40}}
                  }
	     }
	else 
	     codeViewWin = Group {
	          name = "Code",
	          position ={0, 0},
                  children =
                  {
                    codeViewWin_bg,
	            xbox:set{position = {1450, 40}}
                  }
	     }

    	end 
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
		"scale = {"..table.concat(v.scale,",").."},"..indent..
		"anchor_point = {"..table.concat(v.anchor_point,",").."},"..indent..
        	"x_rotation={"..table.concat(v.x_rotation,",").."},"..indent..
        	"y_rotation={"..table.concat(v.y_rotation,",").."},"..indent..
        	"z_rotation={"..table.concat(v.z_rotation,",").."},"..indent..
	        "opacity = "..v.opacity..b_indent.."}\n\n"
	end 
	

	local function codeViewWin_position() 
	     local x_space, y_space
	     if(v.type == "Video") then return end 
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

	if(v.type ~= "Video") then 
	     codeViewWin_position() 
	else 
	     codeViewWin.x = screen.w / 16
	     codeViewWin.y = screen.h / 16
        end 

        text_codes = Text{name="codes",text = codes,font="DejaVu Sans 30px" ,
        color = "FFFFFF" , position = { 50 , 60 } , size = {1400, 910}, editable = false ,
        reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}
	codeViewWin:add(text_codes)
	screen:add(codeViewWin)
        create_on_button_down_f(codeViewWin)
	input_mode = S_POPUP

	xbox.reactive = true
	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(codeViewWin)
		editor.n_selected(v, true)
                screen.grab_key_focus(screen) 
	        input_mode = S_SELECT
		return true
        end 

end 

function editor.save(save_current_f)

     local screen_rect = g:find_child("screen_rect")
  
     if(g:find_child("screen_rect") ~= nil) then 
          g:remove(g:find_child("screen_rect"))
     end 

     if (save_current_f == true) then 
        contents = "local g = ... \n\n"
        local obj_names = getObjnames()

        local n = table.getn(g.children)
   
        for i, v in pairs(g.children) do
               contents= contents..itemTostring(v)
        end
	if (g.extra.video ~= nil) then
	     contents = contents..itemTostring(g.extra.video)
	end 

	contents = contents.."g:add("..obj_names..")"
        undo_list = {}
        redo_list = {}
	if(current_fn ~= "") then 
		editor_lb:writefile (current_fn, contents, true)	
	else 
		editor.save(false)
		return
	end 
     else 
	if(CURRENT_DIR == "") then 
	     set_app_path()
        else 
             input_mode = S_POPUP
             printMsgWindow("File Name : ")
             contents = "local g = ... \n\n"
             local obj_names = getObjnames()
   
             for i, v in pairs(g.children) do
                   contents= contents..itemTostring(v)
             end

	     if (g.extra.video ~= nil) then
	          contents = contents..itemTostring(g.extra.video)
	     end 

	     contents = contents.."g:add("..obj_names..")"
             undo_list = {}
             redo_list = {}
             inputMsgWindow("savefile")
        end 
     end 	

     g:add(screen_rect) 
end  

function editor.rectangle(x, y)
	
        rect_init_x = x 
        rect_init_y = y 
        if (ui.rect ~= nil and "rect"..tostring(item_num) == ui.rect.name) then
                return 0
        end

	while (is_available("rect"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 

        ui.rect = Rectangle{
                name="rect"..tostring(item_num),
                border_color= DEFAULT_COLOR,
                border_width=0,
                color= {255,255,255,255},
                size = {1,1},
                position = {x,y,0}, 
		extra = {org_x = x, org_y = y}
        }
        ui.rect.reactive = true
        table.insert(undo_list, {ui.rect.name, ADD, ui.rect})
        g:add(ui.rect)
	if(screen:find_child("screen_objects") == nil) then 
             screen:add(g)
	end

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

local function ungroup(v)
     v.extra.children = {}
     editor.n_selected(v)
     for i,c in pairs(v.children) do 
        table.insert(v.extra.children, c.name) 
	v:remove(c)
	c.extra.is_in_group = false
	c.x = c.x + v.x 
	c.y = c.y + v.y 
	g:add(c)
	if(c.type == "Text") then
	function c:on_key_down(key)
             if key == keys.Return then
	          c:set{cursor_visible = false}
        	  screen.grab_key_focus(screen)
		  return true
	     end 
	end 
	end 
     end
     g:remove(v)
end 

function editor.undo()
	  if( undo_list == nil) then return true end 
          local undo_item= table.remove(undo_list)

	  if(undo_item == nill) then return true end
	  if undo_item[2] == CHG then 
	        editor.n_selected(undo_item[1])
		set_obj(g:find_child(undo_item[1]), undo_item[3])
	        table.insert(redo_list, undo_item)
	  elseif undo_item[2] == ADD then 
	       editor.n_selected(undo_item[3])
	       if((undo_item[3]).type == "Group") then 
			ungroup(undo_item[3])
	       else
			g:remove(g:find_child(undo_item[1]))
	       end 
               table.insert(redo_list, undo_item)
	  elseif undo_item[2] == DEL then 
	       editor.n_selected(undo_item[3])
	       if((undo_item[3]).type == "Group") then 
		    for i, c in pairs(undo_item[3].extra.children) do
			local c_tmp = g:find_child(c)
			editor.n_selected(c_tmp)
			g:remove(g:find_child(c))
			c_tmp.extra.is_in_group = true
			c_tmp.x = c_tmp.x - undo_item[3].x
			c_tmp.y = c_tmp.y - undo_item[3].y
			undo_item[3]:add(c_tmp)
		    end 
		    g:add(undo_item[3])
  
	       else 
	            g:add(undo_item[3])
	       end
               table.insert(redo_list, undo_item)
 	  end 
	  screen:grab_key_focus() --1115
end
	
function editor.redo()
	  if(redo_list == nil) then return true end 
          local redo_item= table.remove(redo_list)
	  if(redo_item == nill) then return true end
 	  
          if redo_item[2] == CHG then 
		set_obj(g:find_child(redo_item[1]),  redo_item[4])
	        table.insert(undo_list, redo_item)
          elseif redo_item[2] == ADD then 
	       if(redo_item[3].type == "Group") then 
	           for i, c in pairs(redo_item[3].extra.children) do
			local c_tmp = g:find_child(c)
			g:remove(g:find_child(c))
			c_tmp.extra.is_in_group = true
			c_tmp.x = c_tmp.x - redo_item[3].x
			c_tmp.y = c_tmp.y - redo_item[3].y
			redo_item[3]:add(c_tmp)
		   end 
		   g:add(redo_item[3])
	       else 
                   g:add(redo_item[3])
	       end 
               table.insert(undo_list, redo_item)
          elseif redo_item[2] == DEL then 
	       if(redo_item[3].type == "Group") then 
		    ungroup(redo_item[3])
	       else 
                    g:remove(g:find_child(redo_item[1]))
	       end 
               table.insert(undo_list, redo_item)
          end 
	  screen:grab_key_focus() --1115
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

function editor.rm(obj)
        --screen:remove(obj)
	g:remove(obj)
end

function editor.debug()
	print("input_mode", input_mode)
	print("selected objects")
	dumptable(selected_objs)
end 

function editor.text()

	while (is_available("text"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 

        ui.text = Text{
        name="text"..tostring(item_num),
	text = strings[""], font= "DejaVu Sans 40px",
	-- 0111 text = "", font= "DejaVu Sans 40px",
     	color = DEFAULT_COLOR, 
	position ={700, 500, 0}, 
	editable = true , reactive = true, 
	wants_enter = true, size = {300, 100},wrap=true, wrap_mode="CHAR", 
	extra = {org_x = 700, org_y = 500}
	} 


        table.insert(undo_list, {ui.text.name, ADD, ui.text})
        g:add(ui.text)
	if(screen:find_child("screen_objects") == nil) then 
             screen:add(g)
	end
        ui.text.grab_key_focus(ui.text)
        local n = table.getn(g.children)

     	function ui.text:on_key_down(key)
             if key == keys.Return then
		ui.text:set{cursor_visible = false}
        	screen.grab_key_focus(screen)
		ui.text:set{editable= false}
		local text_len = string.len(ui.text.text) 
		local font_len = string.len(ui.text.font) 
	        local font_sz = tonumber(string.sub(ui.text.font, font_len - 3, font_len -2))	
		local total = math.floor((font_sz * text_len / ui.text.w) * font_sz *2/3) -- math.floor(font_sz * text_len % ui.text.w)  
		if(total > ui.text.h) then 
			ui.text.h = total 
		end 
		item_num = item_num + 1
		return true
	     end 
	end 
	ui.text.reactive = true
	create_on_button_down_f(ui.text)

end
	
function editor.image()
	if(CURRENT_DIR == "") then 
		set_app_path()
     	else 
        	input_mode = S_POPUP
        	printMsgWindow("Image File : ")
        	inputMsgWindow("open_imagefile")
	end 
end
	
function editor.video()
	if(CURRENT_DIR == "") then 
		set_app_path()
     	else 
        	input_mode = S_POPUP
        	printMsgWindow("Video File : ")
        	inputMsgWindow("open_videofile")
	end
end
	
function editor.clone()
        if(table.getn(selected_objs) == 0 )then 
		print("there are no selected objects") 
                screen:grab_key_focus()
	        input_mode = S_SELECT
		return 
        end 
	while (is_available("clone"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 
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
	             if(screen:find_child("screen_objects") == nil) then 
        	          screen:add(g)        
		     end 
        	     ui.clone.reactive = true
		     create_on_button_down_f(ui.clone)
		     item_num = item_num + 1
		end 
            end
        end

	input_mode = S_SELECT
end
	
function editor.delete()
        if(table.getn(selected_objs) == 0 )then 
		print("there are no selected objects") 
                screen:grab_key_focus()
		input_mode = S_SELECT
		return 
        end 
	for i, v in pairs(g.children) do
            if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     editor.n_selected(v)
        	     table.insert(undo_list, {v.name, DEL, v})
        	     if (screen:find_child(v.name.."a_m") ~= nil) then 
	     		screen:remove(screen:find_child(v.name.."a_m"))
                     end
        	     g:remove(v)
		end 
            end
        end

	input_mode = S_SELECT
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
       
	while (is_available("group"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 
        ui.group = Group{
                name="group"..tostring(item_num),
        	position = {min_x, min_y}
        }
        ui.group.reactive = false
        ui.group.extra.selected = false
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
	if(screen:find_child("screen_objects") == nil) then 
             screen:add(g)
	end 

        item_num = item_num + 1
        create_on_button_down_f(ui.group) 
        screen.grab_key_focus(screen)
	input_mode = S_SELECT
end

function editor.ugroup()
	for i, v in pairs(g.children) do
             if g:find_child(v.name) then
		  if(v.extra.selected == true) then
			if(v.type == "Group") then 
			     editor.n_selected(v)
			     v.extra.children = {}
			     for i,c in pairs(v.children) do 
				     table.insert(v.extra.children, c.name) 
				     v:remove(c)
				     c.extra.is_in_group = false
				     c.x = c.x + v.x 
				     c.y = c.y + v.y 
		     		     g:add(c)
				     --c.reactive = true
        			     --create_on_button_down_f(c)
				     if(c.type == "Text") then
					function c:on_key_down(key)
             				    if key == keys.Return then
						c:set{cursor_visible = false}
        					screen.grab_key_focus(screen)
						return true
	     				    end 
					end 
	  			     end 
			     end
			     g:remove(v)
        		     table.insert(undo_list, {v.name, DEL, v})
		        end 
		   end 
              end
        end
        screen.grab_key_focus(screen)
	input_mode = S_SELECT
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
                border_width=0,
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
	input_mode = S_SELECT

end 

function editor.multi_select_move(x,y)
	if(multi_select_border == nil) then return end 
	multi_select_border:set{border_width = 2}
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
	input_mode = S_SELECT
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

local function org_cord() 
     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     v.x = v.x - v.anchor_point[1] 
		     v.y = v.y - v.anchor_point[2] 
		end 
	  end 
     end 
end  

local function ang_cord() 
     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     editor.n_selected(v)
		     v.x = v.x + v.anchor_point[1] 
		     v.y = v.y + v.anchor_point[2] 
		end 
	  end 
     end 
end  



function editor.left() 
     local org_object, new_object 

     org_cord()

     if(table.getn(selected_objs) == 0 )then 
	print("there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
     end 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     --editor.n_selected(v)
		     if(v.x ~= basis_obj.x) then
	                  org_object = copy_obj(v)
			  v.x = basis_obj.x
			  new_object = copy_obj(v)
                          table.insert(undo_list, {v.name, CHG, org_object, new_object})
		     end
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

function editor.right() 
     local org_object, new_object 

     if(table.getn(selected_objs) == 0 )then 
	print(":there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
     end 

     org_cord()

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		   --editor.n_selected(v)
		   if(v.x ~= basis_obj.x + basis_obj.w - v.w) then
	                org_object = copy_obj(v)
			v.x = basis_obj.x + basis_obj.w - v.w
			new_object = copy_obj(v)
                        table.insert(undo_list, {v.name, CHG, org_object, new_object})
		   end
		end 
          end
    end

    ang_cord()
    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

function editor.top()
     local org_object, new_object 

     if(table.getn(selected_objs) == 0 )then 
	print("there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
     end 

     org_cord()

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		  --   editor.n_selected(v)
		     if(v.y ~= basis_obj.y) then
	                org_object = copy_obj(v)
			v.y = basis_obj.y 
			new_object = copy_obj(v)
                        table.insert(undo_list, {v.name, CHG, org_object, new_object})
		     end 
		end 
          end
    end

    ang_cord()
    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

function editor.bottom()
     local org_object, new_object 

     if(table.getn(selected_objs) == 0 )then 
	print(":there are  no selected objects") 
	input_mode = S_SELECT
	return 
     end 

     org_cord() 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     --editor.n_selected(v)
		     if(v.y ~= basis_obj.y + basis_obj.h - v.h) then 	
	                org_object = copy_obj(v)
			v.y = basis_obj.y + basis_obj.h - v.h 
			new_object = copy_obj(v)
                        table.insert(undo_list, {v.name, CHG, org_object, new_object})
		     end 
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end
function editor.hcenter()
     local org_object, new_object 

     if(table.getn(selected_objs) == 0 )then 
	print("there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
     end 

     org_cord() 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     -- editor.n_selected(v)
		     if(v.x ~= basis_obj.x + basis_obj.w/2 - v.w/2) then 
	                org_object = copy_obj(v)
			v.x = basis_obj.x + basis_obj.w/2 - v.w/2
			new_object = copy_obj(v)
                        table.insert(undo_list, {v.name, CHG, org_object, new_object})
		     end
		end 
          end
    end

    ang_cord() 

    screen.grab_key_focus(screen)
    input_mode = S_SELECT

end

function editor.vcenter()
     local org_object, new_object 

     if(table.getn(selected_objs) == 0 )then 
	print("there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
     end 

     org_cord() 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     -- editor.n_selected(v)
		     if(v.y ~=  basis_obj.y + basis_obj.h/2 - v.h/2) then 
	                org_object = copy_obj(v)
			v.y = basis_obj.y + basis_obj.h/2 - v.h/2
			new_object = copy_obj(v)
                        table.insert(undo_list, {v.name, CHG, org_object, new_object})
		     end
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = S_SELECT
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
     if (n > 2) then 
     	space = space / (n - 1)
     end 

     return space
end 

function editor.hspace()
    local org_object, new_object 

    if(table.getn(selected_objs) == 0 )then 
	print("there are  no selected objects") 
	input_mode = S_SELECT
	return 
    end 

    local  x_sort_t, space, reverse_t, f, b

    org_cord() 

    x_sort_t = get_x_sort_t()

    space = get_x_space(x_sort_t)
    space = math.floor(space)

    x_sort_t = get_x_sort_t()
    reverse_t = get_reverse_t(x_sort_t)

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			--editor.n_selected(v)
		end 
          end
    end

    f = table.remove(reverse_t)
    while(table.getn(reverse_t) ~= 0) do  
         b = table.remove(reverse_t)
	 if(b.x ~= f.x + f.w + space) then 
	      org_object = copy_obj(b)
	      b.x = f.x + f.w + space 
	      if(b.x > 1920) then 
		print("ERROR b.x is bigger than screen size") 
		print("b.x",b.x,"f.x",f.x,"f.w",f.w,"space",space)
		b.x = 1920 - b.w 
	      end 
	      new_object = copy_obj(b)
              table.insert(undo_list, {b.name, CHG, org_object, new_object})
	 end 

         f = b 
    end 

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = S_SELECT
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
    local org_object, new_object 

    if(table.getn(selected_objs) == 0 )then 
	print(":there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
    end 

    local  y_sort_t, space, reverse_t, f, b

    org_cord()

    y_sort_t = get_y_sort_t()
    space = get_y_space(y_sort_t)
    space = math.floor(space)

    y_sort_t = get_y_sort_t()
    reverse_t = get_reverse_t(y_sort_t)

    f = table.remove(reverse_t)
    while(table.getn(reverse_t) ~= 0) do  
         b = table.remove(reverse_t)
	 if(b.y ~= f.y + f.h + space) then 
	      org_object = copy_obj(b)
              b.y = f.y + f.h + space 
	      new_object = copy_obj(b)
              table.insert(undo_list, {b.name, CHG, org_object, new_object})
	 end
         f = b 
    end 

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
	--		editor.n_selected(v)
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

function editor.bring_to_front()

     if(table.getn(selected_objs) == 0 )then 
	print(":there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
	return 
     end 

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			g:remove(v)
			g:add(v)
    			table.insert(undo_list, {v.name, ARG, BRING_FR})
			editor.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

function editor.send_to_back()

     if(table.getn(selected_objs) == 0 )then 
	print(":there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
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
         table.insert(undo_list, {v.name, ARG, SEND_BK})
	g:add(v)	
    end 
    
    tmp_g = get_reverse_t(tmp_g) 
    while(table.getn(tmp_g) ~= 0) do
	v = table.remove(tmp_g)
        table.insert(undo_list, {v.name, ARG, SEND_BK})
	g:add(v)	
    end 
	
    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

function editor.send_backward()

     if(table.getn(selected_objs) == 0 )then 
	print("there are no selected objects") 
                screen:grab_key_focus()
	input_mode = S_SELECT
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
        table.insert(undo_list, {v.name, ARG, SEND_BW})
    end 

    screen.grab_key_focus(screen)
    input_mode = S_SELECT

end


function editor.bring_forward()

     if(table.getn(selected_objs) == 0 )then 
	print("there are  no selected objects") 
	input_mode = S_SELECT
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
        table.insert(undo_list, {v.name, ARG, BRING_FW})
	g:add(v)
    end 
	
    screen.grab_key_focus(screen)
    input_mode = S_SELECT
end

local widget_map = {
	["Button"] = function () return widget.button()  end, 
	["TextField"] = function () return widget.textField() end, 
	["DialogBox"] = function () return widget.dialogBox() end, 
	["ToastBox"] = function () return widget.toastBox() end,   
	["RadioButton"] = function () return widget.radioButton() end, 
	["CheckBox"] = function () return widget.checkBox()  end, 
	["ButtonPicker"] = function () return widget.buttonPicker()  end, 
	["LoadingDots"] = function () return widget.loadingdots() end, 
	["LoadingBar"] = function () return widget.loadingbar() end, 
}

function editor.widgets()
	local WIDTH = 500
	local L_PADDING = 50
	local R_PADDING = 50
        local TOP_PADDING = 60
        local BOTTOM_PADDING = 12
        local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF"}
	local space = WIDTH
	local msgw_bg = factory.make_popup_bg("widgets")
	local msgw = Group {
	     position ={500, 200},
	     anchor_point = {0,0},
             children =
             {
              msgw_bg,
             }
	}
        local widgets_list = Text {name = "w_list", text = "Widgets List"}:set(STYLE)
	local text_g

	cur_w= (WIDTH - widgets_list.w)/2
	cur_h= TOP_PADDING/2 + Y_PADDING

        widgets_list.position = {cur_w,cur_h}
        msgw:add(widgets_list)

	local widgets = {"Button", "TextField", "DialogBox", "ToastBox", "RadioButton", "CheckBox", "ButtonPicker", "LoadingDots", "LoadingBar", 
			 "MenuBar", "3D_List", "ScrollImage", "TabBar", "OSK"}
        
        function print_widget_list() 
	    cur_w = L_PADDING
            cur_h = TOP_PADDING + widgets_list.h + Y_PADDING

	    text_g = Group{position = {cur_w, cur_h}}
	    text_g.extra.org_y = cur_h
	    text_g.reactive  = true 
            cur_w = 0
	    cur_h = 0 

            local input_text
            for i, v in pairs(widgets) do
		if (i == 8) then 
            	     cur_w = 200
            	     cur_h = 0
		end 
	        text = Text {name = tostring(i), text = v}:set(STYLE)
                text.position  = {cur_w, cur_h}
		text.reactive = true
    	        text_g:add(text)

		if(cur_w == L_PADDING) then
		     cur_w = cur_w + 7*L_PADDING
		else 
		     if(i < 8) then 
	                  cur_w = 0 
		     else 
            	          cur_w = 200
	             end 
	             cur_h = cur_h + text.h + Y_PADDING
		end
		
           end
           cur_w = cur_w + L_PADDING
           cur_h = cur_h + TOP_PADDING + widgets_list.h + Y_PADDING
           msgw:add(text_g)
	end

	print_widget_list()

	
        for i,j in pairs (text_g.children) do 
             function j:on_button_down(x,y,button, num_clicks)
	      if input_text ~= nil then 
		    input_text.color = {255, 255, 255, 255}
	      end 
              input_text = j
	      j.color = {0,255,0,255}
	      return true
             end 
        end 

	
	local file_list_size = 280
        local insert_b, insert_t  = factory.make_msgw_button_item( assets , "insert")
    	insert_b.position = {(WIDTH - 2*insert_b.w - X_PADDING)/2, file_list_size + 130}
    	insert_b.name = "insert"
    	insert_b.reactive = true

    	local cancel_b, cancel_t = factory.make_msgw_button_item( assets , "cancel")
    	cancel_b.position = {insert_b.x + insert_b.w + X_PADDING, file_list_size + 130}
    	cancel_b.name = "cancel"
    	cancel_b.reactive = true 
	
    	msgw:add(insert_b)
    	msgw:add(cancel_b)

    function insert_b:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
	      new_widget = widget_map[input_text.text]() 

--imsi  : for debugging, will be deleted 
	      if (new_widget.extra.type == "Button") then 
		b=new_widget
	      elseif (new_widget.extra.type == "TextField") then 
		t=new_widget
	      elseif (new_widget.extra.type == "DialogBox") then 
		db=new_widget
	      elseif (new_widget.extra.type == "ToastBox") then 
		tb=new_widget
	      elseif (new_widget.extra.type == "RadioButton") then 
		rb=new_widget
	      elseif (new_widget.extra.type == "CheckBox") then 
		cb=new_widget
	      elseif (new_widget.extra.type == "ButtonPicker") then 
		bp=new_widget
	      elseif (new_widget.extra.type == "LoadingDots") then 
		ld=new_widget
	      elseif (new_widget.extra.type == "LoadingBar") then 
		lb=new_widget
	      end
--imsi 

	      a = new_widget
	      while (is_available(new_widget.name..tostring(item_num)) == false) do  
		item_num = item_num + 1
	      end 
	      new_widget.name = new_widget.name..tostring(item_num)
	      g:add(new_widget)
              create_on_button_down_f(new_widget)
	      screen:add(g)
	      screen:grab_key_focus()

	      cleanMsgWin(msgw)
	 end 
    end 
    function insert_t:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
	      new_widget = widget_map[input_text.text]() 

--imsi  : for debugging, will be deleted 
	      if (new_widget.extra.type == "Button") then 
		b=new_widget
	      elseif (new_widget.extra.type == "TextField") then 
		t=new_widget
	      elseif (new_widget.extra.type == "DialogBox") then 
		db=new_widget
	      elseif (new_widget.extra.type == "ToastBox") then 
		tb=new_widget
	      elseif (new_widget.extra.type == "RadioButton") then 
		rb=new_widget
	      elseif (new_widget.extra.type == "CheckBox") then 
		cb=new_widget
	      elseif (new_widget.extra.type == "ButtonPicker") then 
		bp=new_widget
	      elseif (new_widget.extra.type == "LoadingDots") then 
		ld=new_widget
	      elseif (new_widget.extra.type == "LoadingBar") then 
		lb=new_widget
	      end
--imsi 
 	      while (is_available(new_widget.name..tostring(item_num)) == false) do  
		item_num = item_num + 1
	      end 
	      new_widget.name = new_widget.name..tostring(item_num)
	      g:add(new_widget)
              create_on_button_down_f(new_widget)
	      screen:add(g)
	      screen:grab_key_focus()

	      cleanMsgWin(msgw)
	 end 
    end 

    function cancel_b:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    function cancel_t:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    screen:add(msgw)
--]]
end 



