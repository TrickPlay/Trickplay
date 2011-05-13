dofile("apply.lua")
dofile("editor_lib.lua")

editor = {}


local rect_init_x = 0
local rect_init_y = 0
local g_init_x = 0
local g_init_y = 0
local factory = ui.factory


local widget_f_map = {
     ["Rectangle"]	= function () input_mode = S_RECTANGLE screen:grab_key_focus() end, 
     ["Text"]		= function () editor.text() input_mode = S_SELECT end, 
     ["Image"]		= function () input_mode = S_SELECT  editor.the_image() end, 	
     ["Video"] 		= function () input_mode = S_SELECT editor.the_video() end,
     ["Button"]     = function () return ui_element.button()       end, 
     ["TextInput"] 	= function () return ui_element.textInput()    end, 
     ["DialogBox"] 	= function () return ui_element.dialogBox()    end, 
     ["ToastAlert"] = function () return ui_element.toastAlert()     end,   
     ["RadioButtonGroup"]   = function () return ui_element.radioButtonGroup()  end, 
     ["CheckBoxGroup"]      = function () return ui_element.checkBoxGroup()     end, 
     ["ButtonPicker"]   	= function () return ui_element.buttonPicker() end, 
     ["ProgressSpinner"]    = function () return ui_element.progressSpinner()  end, 
     ["ProgressBar"]     	= function () return ui_element.progressBar()   end,
     ["MenuButton"]       	= function () return ui_element.menuButton()  end,
     ["MenuBar"]        	= function () return ui_element.menuBar()      end,
     ["LayoutManager"]      = function () return ui_element.layoutManager()   end,
     ["ScrollPane"]    		= function () return ui_element.scrollPane() end, 
     ["ArrowPane"]    		= function () return ui_element.arrowPane() end, 
	 ["TabBar"]		 		= function () return ui_element.tabBar() end, 
     ["MenuBar"]    		= function () return ui_element.menuBar() end, 
}

local widget_n_map = {
     ["Button"]    	= function () return "Button" end, 
     ["TextInput"] 	= function () return "Text Input" end, 
     ["DialogBox"] 	= function () return "Dialog Box" end, 
     ["ToastAlert"]	= function () return "Toast Alert" end,   
     ["RadioButtonGroup"]    = function () return "Radio Button Group" end, 
     ["CheckBoxGroup"]       = function () return "Checkbox Group" end, 
     ["ButtonPicker"]   	 = function () return "Button Picker" end, 
     ["ProgressSpinner"]     = function () return "Progress Spinner" end, 
     ["ProgressBar"]     	 = function () return "Progress Bar" end,
     ["MenuButton"]      	 = function () return "Menu Button" end,
     ["LayoutManager"]       = function () return "Layout Manager" end,
     ["ScrollPane"]    		 = function () return "Scroll Pane" end, 
     ["ArrowPane"]    		 = function () return "Arrow Pane" end, 
     ["TabBar"]    			 = function () return "Tab Bar" end, 
     ["MenuBar"]     		 = function () return "Menu Bar" end, 
}

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
       		if (button.name == "cancel") then 
				cancel_b.extra.on_focus_out() save_b.extra.on_focus_in()
            elseif (button.name == "apply") then 
				save_b.extra.on_focus_out() delete_b.extra.on_focus_in()
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

	save_b, save_t  = factory.make_msgw_button_item( assets , "OK")
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

function editor.reference_image()
 	if(CURRENT_DIR == "") then 
		--set_app_path() 
	else 
		input_mode = S_SELECT  
		editor.the_image(true)
		screen:grab_key_focus()
	end 
	screen:find_child("menuButton_view").items[2]["icon"].opacity = 255
	screen:find_child("menuButton_view").items[3]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[4]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[5]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[6]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[7]["icon"].opacity = 0
end 

function editor.small_grid()
	clear_bg() BG_IMAGE_20.opacity = 255 input_mode = S_SELECT
	screen:find_child("menuButton_view").items[3]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.medium_grid()
	clear_bg() BG_IMAGE_40.opacity = 255 input_mode = S_SELECT
	screen:find_child("menuButton_view").items[4]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.large_grid()
	clear_bg() BG_IMAGE_80.opacity = 255 input_mode = S_SELECT
	screen:find_child("menuButton_view").items[5]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.white_bg()
	clear_bg() BG_IMAGE_white.opacity = 255 input_mode = S_SELECT
	screen:find_child("menuButton_view").items[6]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.black_bg()
	clear_bg() input_mode = S_SELECT
	screen:find_child("menuButton_view").items[7]["icon"].opacity = 255
	screen:grab_key_focus()
end 


function editor.show_guides()
	if guideline_show == false then 
		screen:find_child("menuButton_view").items[11]["icon"].opacity = 255
		guideline_show = true
		for i= 1, h_guideline, 1 do 
			screen:find_child("h_guideline"..tostring(i)):show() 
		end 
		for i= 1, v_guideline, 1 do 
			screen:find_child("v_guideline"..tostring(i)):show() 
		end 
	else 
		screen:find_child("menuButton_view").items[11]["icon"].opacity = 0
		guideline_show = false
		for i= 1, h_guideline, 1 do 
			screen:find_child("h_guideline"..tostring(i)):hide() 
		end 
		for i= 1, v_guideline, 1 do 
			screen:find_child("v_guideline"..tostring(i)):hide() 
		end 
	end
	screen:grab_key_focus()
end 

function editor.snap_guides()
	if screen:find_child("menuButton_view").items[12]["icon"].opacity > 0 then 
		 screen:find_child("menuButton_view").items[12]["icon"].opacity = 0 
	else 
		 screen:find_child("menuButton_view").items[12]["icon"].opacity = 255 
	end
	screen:grab_key_focus()
end 

function editor.timeline() 
        if not screen:find_child("timeline") then 
			if table.getn(g.children) > 0 then
				input_mode = S_SELECT local tl = ui_element.timeline() screen:add(tl)
				screen:find_child("timeline").extra.show = true 
				screen:find_child("timeline"):raise_to_top()
			else 
				print("Err : There is no UI element to make animation.")
			end
		elseif table.getn(g.children) == 0 then 
			screen:remove(screen:find_child("timeline"))
			if screen:find_child("tline") then 
				screen:find_child("tline"):find_child("caption").text = "Timeline".."\t\t\t".."[J]"
			end 
		elseif screen:find_child("timeline").extra.show ~= true  then 
			screen:find_child("timeline"):show()
			screen:find_child("timeline").extra.show = true
			screen:find_child("timeline"):raise_to_top()
		else 
			screen:find_child("timeline"):hide()
			screen:find_child("timeline").extra.show = false
		end
		screen:grab_key_focus()
end 


local function create_on_line_down_f(v)
        function v:on_button_down(x,y,button,num_clicks)
            dragging = {v, x - v.x, y - v.y }
	     	v.color = {50, 50,50,255}
	     	--if(button == 3 or num_clicks >= 2) then
	     	if(button == 3) then
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
		border_color= DEFAULT_COLOR, --{255,255,255,255},
		border_color= DEFAULT_COLOR, -- {255,255,255,255},
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
     screen:grab_key_focus()
end

function editor.h_guideline()
     
     h_guideline = h_guideline + 1

     local h_gl = Rectangle {
		name="h_guideline"..tostring(h_guideline),
		border_color= DEFAULT_COLOR, --{255,255,255,255},
		border_color= DEFAULT_COLOR, --{255,255,255,255},
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
     screen:grab_key_focus()
end



function editor.container_selected(obj, x, y)
     if obj.extra.type ~= "LayoutManager" then 
          obj_border = Rectangle{}
          obj_border.name = obj.name.."border"
          obj_border.color = {0,0,0,0}
          obj_border.border_color = {0,255,0,255}
          obj_border.border_width = 2
          obj_border.position = obj.position
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
     else -- Layout Manager Tile border
	  	local col , row=  obj:r_c_from_abs_position(x,y)
	  	local tile_x, tile_y

	  	if row and col then 
			tile_x = obj.x + obj.cell_w * (col - 1) + obj.cell_spacing * (col - 1)    
			tile_y = obj.y + obj.cell_h * (row - 1) + obj.cell_spacing * (row - 1)      
	  	end 

	  	obj_border = Rectangle{}
        obj_border.name = obj.name.."border"
        obj_border.color = {0,0,0,0}
        obj_border.border_color = {0,255,0,255}
        obj_border.border_width = 2
        obj_border.position = {tile_x, tile_y, 0} 
        obj_border.anchor_point = obj.anchor_point
        obj_border.x_rotation = obj.x_rotation
        obj_border.y_rotation = obj.y_rotation
        obj_border.z_rotation = obj.z_rotation
        obj_border.size = {obj.cell_w, obj.cell_h}
	  	obj_border.extra.r_c = {row, col}

        if(obj.scale ~= nil) then 
        	obj_border.scale = obj.scale
        end 
        screen:add(obj_border)
        obj.extra.selected = true
        table.insert(selected_objs, obj_border.name)
     end 
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
   	obj_border.border_color = {0,255,0,255}
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
     if(obj.name == nil)then 
		return 
	 end 

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
     if(obj.name == nil) then 
		return 
	 end 
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

	editor.medium_grid()

	for i, j in pairs (g.children) do 
	     if(j.extra.selected == true) then 
			editor.n_selected(j) 
	     end 
	end 

	if(screen:find_child("mouse_pointer") ~= nil) then 
             screen:remove(screen:find_child("mouse_pointer")) 
	end 
	
	for i, v in pairs(g.children) do
          if g:find_child(v.name) then
                g:remove(g:find_child(v.name))
		  		if(screen:find_child(v.name.."border")) then
                	screen:remove(screen:find_child(v.name.."border"))
		  		end 
          end
    end

--[[
	if(table.getn(g.children) ~= 0) then 
			 g:clear()
             screen:remove(g)
	end 
]]
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

	g:clear()
	local timeline = screen:find_child("timeline")
	if timeline then 
		timeline:clear()
		screen:remove(timeline)
		if screen:find_child("tline") then
		     screen:find_child("tline"):find_child("caption").text = "Timeline".."\t\t\t".."[J]"
		end
	end 
	screen:find_child("menu_text").text = screen:find_child("menu_text").extra.project
end 

function editor.open()

	local timeline = screen:find_child("timeline")
    if timeline then 
		timeline:clear()
		screen:remove(timeline)
		if screen:find_child("tline") then
	    	screen:find_child("tline"):find_child("caption").text = "Timeline".."\t\t\t".."[J]"
		end 
   	end 
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
     --input_mode = S_SELECT 
end 

local function draw_dialogbox()
    local scrollPane1 = ui_element.scrollPane
	{
		skin = "default",
		reactive = true,
		visible_w = 850,
		visible_h = 300,
		virtual_w = 1000,
		virtual_h = 500,
		bar_color_inner = {180,180,180,255},
		bar_color_outer = {30,30,30,255},
		empty_color_inner = {120,120,120,255},
		empty_color_outer = {255,255,255,255},
		frame_thickness = 2,
		frame_color = {60,60,60,255},
		bar_thickness = 15,
		bar_offset = 5,
		vert_bar_visible = true,
		hor_bar_visible = false,
		box_color = {160,160,160,255},
		box_width = 0,
		content= Group { children = {} },
	}

	scrollPane1.name = "scrollPane1"
	scrollPane1.position = {16,64,0}
	scrollPane1.scale = {1,1,0,0}
	scrollPane1.anchor_point = {0,0}
	scrollPane1.x_rotation = {0,0,0}
	scrollPane1.y_rotation = {0,0,0}
	scrollPane1.z_rotation = {0,0,0}
	scrollPane1.opacity = 255
	scrollPane1.extra.reactive = true

	local button1 = ui_element.button
	{
		ui_width = 445,
		ui_height = 60,
		skin = "CarbonCandy",
		label = "Open",
		button_color = {255,255,255,255},
		focus_color = {27,145,27,255},
		text_color = {255,255,255,255},
		text_font = "DejaVu Sans 30px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
	}

	button1.name = "button1"
	button1.position = {444,390,0}
	button1.scale = {1,1,0,0}
	button1.anchor_point = {0,0}
	button1.x_rotation = {0,0,0}
	button1.y_rotation = {0,0,0}
	button1.z_rotation = {0,0,0}
	button1.opacity = 255
	button1.extra.focus = {[65293] = "button1", }

	function button1:on_key_down(key)
		if button1.focus[key] then
			if type(button1.focus[key]) == "function" then
				button1.focus[key]()
			elseif screen:find_child(button1.focus[key]) then
				if button1.on_focus_out then
					button1.on_focus_out()
				end
				screen:find_child(button1.focus[key]):grab_key_focus()
				if screen:find_child(button1.focus[key]).on_focus_in then
					screen:find_child(button1.focus[key]).on_focus_in()
				end
			end
		end
		return true
	end

	button1.extra.reactive = true

	local button0 = ui_element.button
	{
		ui_width = 445,
		ui_height = 60,
		skin = "CarbonCandy",
		label = "Cancel",
		button_color = {255,255,255,255},
		focus_color = {27,145,27,255},
		text_color = {255,255,255,255},
		text_font = "DejaVu Sans 30px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
	}

	button0.name = "button0"
	button0.position = {6,390,0}
	button0.scale = {1,1,0,0}
	button0.anchor_point = {0,0}
	button0.x_rotation = {0,0,0}
	button0.y_rotation = {0,0,0}
	button0.z_rotation = {0,0,0}
	button0.opacity = 255
	button0.extra.focus = {[65293] = "button0", }

	function button0:on_key_down(key)
		if button0.focus[key] then
			if type(button0.focus[key]) == "function" then
				button0.focus[key]()
			elseif screen:find_child(button0.focus[key]) then
				if button0.on_focus_out then
					button0.on_focus_out()
				end
				screen:find_child(button0.focus[key]):grab_key_focus()
				if screen:find_child(button0.focus[key]).on_focus_in then
					screen:find_child(button0.focus[key]).on_focus_in()
				end
			end
		end
		return true
	end

	button0.extra.reactive = true


	local dialogBox0 = ui_element.dialogBox
	{
		ui_width = 900,
		ui_height = 500,
		skin = "custom",
		label = "Dialog Box Title",
		border_width = 4,
		border_corner_radius = 22,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {25,25,25,100},
		title_color = {255,255,255,255},
		title_font = "DejaVu Sans 30px",
		title_seperator_color = {255,255,255,255},
		title_seperator_thickness = 4,
		content= Group { children = {button0,button1,scrollPane1,} },
	}

	dialogBox0.name = "dialogBox0"
	dialogBox0.position = {430,210,0}
	dialogBox0.scale = {1,1,0,0}
	dialogBox0.anchor_point = {0,0}
	dialogBox0.x_rotation = {0,0,0}
	dialogBox0.y_rotation = {0,0,0}
	dialogBox0.z_rotation = {0,0,0}
	dialogBox0.opacity = 255
	dialogBox0.extra.reactive = true

	return dialogBox0
end 

function editor.the_image(bg_image)
	local WIDTH = 700
	local L_PADDING = 50
	local R_PADDING = 50
    local TOP_PADDING = 60
    local BOTTOM_PADDING = 12
    local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 24px" , color = "FFFFFF"}
	local space = WIDTH

	local dir = editor_lb:readdir(CURRENT_DIR.."/assets/images")
	local dir_text = Text {name = "dir", text = "File Location : "..CURRENT_DIR.."/assets/images"}:set(STYLE)

	local cur_w= (WIDTH - dir_text.w)/2
	local cur_h= TOP_PADDING/2 + Y_PADDING


	local dialog = draw_dialogbox()
	dialog.label =  "File Location : "..CURRENT_DIR.."/assets/images"
	dialog.title_font = "DejaVu Sans 24px"

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
    	 return text_g
	end 
	
	text_g = print_file_list()
	dialog.content:find_child("scrollPane1").content = text_g 
	dialog.content:find_child("scrollPane1").content.x = 100	
	dialog.content:find_child("scrollPane1").virtual_h = file_list_size  

	if file_list_size < 300 then 
		dialog.content:find_child("scrollPane1").vert_bar_visible = false
	end

    for i,j in pairs (text_g.children) do 
    	function j:on_button_down(x,y,button, num_clicks)
	    	if input_text ~= nil then 
		    	input_text.color = DEFAULT_COLOR   --{255, 255, 255, 255}
	      	end	 
            input_text = j
	      	j.color = {0,255,0,255}
	      	return true
         end 
    end 

	cancel_b = dialog.content:find_child("button0")
	function cancel_b:on_button_down ()
	 	screen:remove(dialog)
	 	screen:grab_key_focus(screen)
	end 

	open_b = dialog.content:find_child("button1")
    function open_b:on_button_down(x,y,button,num_clicks)
		if (input_text ~= nil) then 
	    	if bg_image then
		   		BG_IMAGE_20.opacity = 0
	            BG_IMAGE_40.opacity = 0
	           	BG_IMAGE_80.opacity = 0
	           	BG_IMAGE_white.opacity = 0
	           	BG_IMAGE_import:set{src = "/assets/images/"..input_text.text, opacity = 255} 
	           	input_mode = S_SELECT
	      	elseif screen:find_child("inspector") then 
		    	screen:find_child("file_name").text = input_text.text
	      	else 
	            inputMsgWindow_openimage("open_imagefile", input_text.text)
	      	end 
	      	screen:remove(dialog)
	 	end 
    end 
    screen:add(dialog)
end 

function editor.export ()
	animate_out_dropdown()
	ui:hide()
	if(screen:find_child("xscroll_bar") ~= nil) then 
		screen:find_child("xscroll_bar"):hide() 
		screen:find_child("xscroll_box"):hide() 
		screen:find_child("x_0_mark"):hide()
		screen:find_child("x_1920_mark"):hide()
	end 
	if(screen:find_child("scroll_bar") ~= nil) then 
		screen:find_child("scroll_bar"):hide() 
		screen:find_child("scroll_box"):hide() 
		screen:find_child("y_0_mark"):hide()
		screen:find_child("y_1080_mark"):hide()
	end 
	menu_hide = true 
	screen:grab_key_focus()
	screen:remove(g)
	g:clear()
	local f = loadfile(current_fn)
	f(g)
	screen:add(g)
	
end 

function editor.the_open()

    local WIDTH = 700
	local L_PADDING = 50
	local R_PADDING = 50
    local TOP_PADDING = 60
    local BOTTOM_PADDING = 12
    local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 24px" , color = "FFFFFF"}
	local space = WIDTH
	local dir = editor_lb:readdir(CURRENT_DIR.."/screens")
	local dir_text = Text {name = "dir", text = "File Location : "..CURRENT_DIR.."/screens"}:set(STYLE)
	local cur_w= (WIDTH - dir_text.w)/2
	local cur_h= TOP_PADDING/2 + Y_PADDING
	local dialog = draw_dialogbox()

	dialog.label =  "File Location : "..CURRENT_DIR.."/screens"
	dialog.title_font = "DejaVu Sans 24px"

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
			--print(v)
	        	text = Text {name = tostring(i), text = v}:set(STYLE)
                text.position = {cur_w, cur_h}
			--dumptable(text.position)
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
	     return text_g

    end 
	
	text_g = print_file_list()
	dialog.content:find_child("scrollPane1").content = text_g 
	dialog.content:find_child("scrollPane1").content.x = 100	
	dialog.content:find_child("scrollPane1").virtual_h = file_list_size  

	if file_list_size < 300 then 
		dialog.content:find_child("scrollPane1").vert_bar_visible = false
	end

	cancel_b = dialog.content:find_child("button0")
	function cancel_b:on_button_down ()
	 	screen:remove(dialog)
	 	screen:grab_key_focus(screen)
	end 

	open_b = dialog.content:find_child("button1")
	function open_b:on_button_down()
		if (input_text ~= nil) then 
	    	local timeline = screen:find_child("timeline")
	       	if timeline then 
		    	timeline:clear()
	     	    screen:remove(timeline)
		     	if screen:find_child("tline") then
		        	screen:find_child("tline"):find_child("caption").text = "Timeline".."\t\t\t".."[J]"
		     	end
	       	end 
            inputMsgWindow_openfile(input_text.text) 
	       	screen:remove(dialog)
	       	local timeline = screen:find_child("timeline") 
	       	if timeline then  
            	for n,m in pairs (g.children) do 
	         		if m.extra.timeline[0] then 
	            		m:show()
	            		for l,k in pairs (m.extra.timeline[0]) do 
		        			if l ~= "hide" then
		            			m[l] = k
		        			elseif k == true then 
		            			m:hide() 
		        			end 
	            		end
                	end 
             	end 
             end 
	 	end 
	end 

    for i,j in pairs (text_g.children) do 
    	function j:on_button_down(x,y,button, num_clicks)
	    	if input_text ~= nil then 
		    	input_text.color = DEFAULT_COLOR-- {255, 255, 255, 255}
	      	end	 
            input_text = j
	      	j.color = {0,255,0,255}
	      	return true
        end 
    end 
    screen:add(dialog)
	if screen:find_child("mouse_pointer") then 
		 screen:find_child("mouse_pointer"):raise_to_top()
	end
end 

function editor.inspector(v, x_pos, y_pos, scroll_y_pos)
	local save_items 

	if not scroll_y_pos then 
	     save_items = true 
	else 
	     save_items = false 
	end 

	local WIDTH = 450 -- width for inspector's contents

	local INSPECTOR_OFFSET = 30 
    local TOP_PADDING = 12
    local BOTTOM_PADDING = 12
	local xbox_xpos = 490

	if(current_inspector ~= nil) then 
		return 
    end 
 	
	for i, c in pairs(g.children) do
	     editor.n_selected(c)
	end
	
	local inspector_items = {}
	local inspector_bg

	-- make inspector background image 
	if v.extra then 
	   if is_this_widget(v) == true  then
	   		inspector_bg = factory.make_popup_bg(v.extra.type, 0)
	   else -- rect, img, text 
	     	inspector_bg = factory.make_popup_bg(v.type, 0)
	   end 
	else -- video  
	   xbox_xpos = 465
	   inspector_bg = factory.make_popup_bg(v.type, 0)
	end 

	local inspector_xbox = factory.make_xbox()

	-- inspector group 
	local inspector = Group {
	     name = "inspector",
	     position ={0, 0},
	     anchor_point = {0,0},
         children =
         {
         	inspector_bg, 
	       	inspector_xbox:set{position = {xbox_xpos, 40}}
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
				if(inspector.y <= screen:find_child("menu_bar").h + INSPECTOR_OFFSET) then
			    	inspector.y = screen:find_child("menu_bar").h+ INSPECTOR_OFFSET	
				end	
			else 
            	inspector.y = (v.y + v.h - inspector.h) /2
				if(inspector.y <= screen:find_child("menu_bar").h + INSPECTOR_OFFSET) then
					inspector.y = screen:find_child("menu_bar").h + INSPECTOR_OFFSET	
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
				elseif (inspector.y <= screen:find_child("menu_bar").h + INSPECTOR_OFFSET) then
			     	inspector.y = screen:find_child("menu_bar").h+ INSPECTOR_OFFSET	
				end
        	end 
	    end 
	end 

	-- set the inspector location 
	if(v.type ~= "Video") then
	   if(x_pos ~= nil and y_pos ~= nil) then 
	     inspector.x = x_pos	
	     inspector.y = y_pos	
	   else
	     inspector_position() 
	   end 
	else 
	     inspector.x = screen.w/8
	     inspector.y = screen.h/8
	end 

	-- make the inspector contents 
	local attr_t = make_attr_t(v)
	local attr_n, attr_v, attr_s
    local items_height = 0
    local prev_item_h = 0
	local prev_y = 0 
	local space = WIDTH
	local used = 0

	local item_group = Group{name = "item_group"}
	local H_SPACE = 5 --30
	local X_INDENT = 25
	local TOP_PADDING = 30
	
	for i=1, #attr_t do 
        if (attr_t[i] == nil) then break end 

	    attr_n = attr_t[i][1] 
	    attr_v = attr_t[i][2] 
	    attr_s = attr_t[i][3] 
        attr_v = tostring(attr_v)

	    if(attr_s == nil) then attr_s = "" end 
	     
	    local item = factory.make_text_popup_item(assets, inspector, v, attr_n, attr_v, attr_s, save_items) 
	    if(item.w <= space) then 
		 	if (item.h > prev_item_h) then 
             	items_height = items_height + (item.h - prev_item_h) 
		     	prev_item_h = item.h
	     	end 
         	item.x = used + H_SPACE 
		 	item.y = prev_y
		 	space = space - item.w
	    else 
		 	if (attr_n == "ui_width" or attr_n == "w") then 
				items_height = items_height - 12 -- imsi !! 
 		 	end 
		 	item.y = items_height 
         	item.x = X_INDENT 
		 	prev_y = item.y 
		 	items_height = items_height + item.h 
		 	space = WIDTH - item.w
        end 
	    used = item.x + item.w 

	    if (xbox_xpos == 465) then  
			if (attr_n == "title") then 
		    	item.y = item.y + TOP_PADDING 
		    	prev_y = item.y 
		    	items_height = items_height + TOP_PADDING *3/2
	            inspector:add(item)
			elseif(attr_n == "button") then 
	            inspector:add(item)
	    	else 
	            item_group:add(item)
	    	end 
	    else 
	        if (attr_n == "title") then 
		    	item.y = item.y + TOP_PADDING 
	            inspector:add(item)
	    	elseif(attr_n == "button") then 
		    	if(attr_v == "view code") then 
		        	item.y = 570
		    	else 
		        	item.y = 620
		        	space = space + 100
	            end 
	            inspector:add(item)
	        else 
		    	item.y = item.y - TOP_PADDING
	            item_group:add(item)
	        end 
	    end
	    --print (attr_n,":",item.x,",",item.y)
        end 

	-- inspector scroll function 
	if v.extra then 
	       si = ui_element.scrollPane{visible_w = item_group.w + 40, virtual_w = item_group.w, virtual_h = item_group.h, visible_h = 480, border_is_visible = false, box_width = 0} 
	       si.content = item_group
	       si.position = {0,82,0}
	       si.name ="si"
	       si.size = {item_group.w + 40, 480, 0} -- si must have {clip_w, clip_h} as size
	       inspector:add(si)
	else -- video  
	   inspector:add(item_group) 
	end 
	screen:add(inspector)

	if scroll_y_pos then 
	     --print("scroll_y_pos",  math.floor(math.abs(scroll_y_pos)))
	     screen:find_child("si").extra.seek_to(0, math.floor(math.abs(scroll_y_pos)))
	end 

	if v.extra then 
		if v.extra.type == "MenuButton" then 
        	v.spin_in()
		end 
	end 

	input_mode = S_POPUP
	inspector:find_child("name").extra.on_focus_in()
	
	current_inspector = inspector
    inspector.reactive = true
	inspector.extra.lock = false
	create_on_button_down_f(inspector)
    inspector_xbox.reactive = true

	function inspector_xbox:on_button_down(x,y,button,num_clicks)
		editor.n_selected(v, true)
		screen:remove(inspector)
		inspector:clear() 
		current_inspector = nil
			
       	for i, c in pairs(g.children) do
		    if(c.type == "Text") then 
				c.reactive = true
		    end 
        end

		for i, c in pairs(g.children) do
	     		editor.n_selected(c)
		end

        screen.grab_key_focus(screen) 
	    input_mode = S_SELECT
		if v.extra then 
			if v.extra.type == "MenuButton" then 
            	v.spin_out()
	    	end 
	    end 
		return true
	end 

	if screen:find_child("mouse_pointer") then 
		 screen:find_child("mouse_pointer"):raise_to_top()
	end
end

function editor.view_code(v)

	local WIDTH = 750 
    local TOP_PADDING = 0
    local BOTTOM_PADDING = 12
	local CODE_OFFSET = 30 
    local codes = ""
	local codeViewWin_bg 
	local xbox = factory.make_xbox()
	local codeViewWin 


	codeViewWin_bg = factory.make_popup_bg("Code","")
--[[
	if is_this_widget(v) == true then 
	     codeViewWin_bg = factory.make_popup_bg("Code", "Widget")
	else 
	     codeViewWin_bg = factory.make_popup_bg("Code", v.type)
	end 
]]

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
	
	if(v.type ~= "Group" or is_this_widget(v) == true) then 
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
				if(codeViewWin.y <= screen:find_child("menu_bar").h + CODE_OFFSET) then
			    	codeViewWin.y = screen:find_child("menu_bar").h + CODE_OFFSET	
				end	
			else 
            	codeViewWin.y = (v.y + v.h - codeViewWin.h) /2
				if(codeViewWin.y <= screen:find_child("menu_bar").h + CODE_OFFSET) then
					codeViewWin.y = screen:find_child("menu_bar").h + CODE_OFFSET	
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
				elseif (codeViewWin.y <= screen:find_child("menu_bar").h + CODE_OFFSET) then
			     	codeViewWin.y = screen:find_child("menu_bar").h + CODE_OFFSET	
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

    text_codes = Text{name="codes",text = codes,font="DejaVu Sans 25px" ,
    color = "FFFFFF" , position = { 25 , 0} , editable = false ,
    reactive = false, wants_enter = false, }

	-- scroll function 
	si = ui_element.scrollPane{virtual_w =text_codes.w , virtual_h = text_codes.h , visible_w = 765, visible_h = 500, border_is_visible = false, box_width = 0} 
	si.content:add(text_codes)
	si.position = {0,80,0}
	si.name ="si"
	--si.size = {item_group.w + 40, 480, 0} -- si must have {clip_w, clip_h} as size
	codeViewWin:add(si)
	--codeViewWin:add(text_codes)
	screen:add(codeViewWin)
	codeViewWin.extra.lock = false
    create_on_button_down_f(codeViewWin)
	input_mode = S_POPUP
	si:grab_key_focus()
	xbox.reactive = true

	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(codeViewWin)
		editor.n_selected(v, true)
        screen.grab_key_focus(screen) 
	    input_mode = S_SELECT
		return true
    end 
end 

function editor.save(save_current_f, save_backup_f)
     if save_current_f == nil then 
		save_current_f = false
     end 

     if current_time_focus then 
		current_time_focus.on_focus_out()
		current_time_focus = nil
     end 

     local screen_rect = g:find_child("screen_rect")
  
     if(g:find_child("screen_rect") ~= nil) then 
          g:remove(g:find_child("screen_rect"))
     end 

     if (save_current_f == true) then 
		contents = ""
        local obj_names = getObjnames()
        local n = table.getn(g.children)

		for i, v in pairs(g.children) do
	     	local result, d_list, t_list, result2 = itemTostring(v, done_list, todo_list)  
	     	if result2  ~= nil then 
            	contents=result2..contents
	     	end  
	     	if result ~= nil then 
                contents=contents..result
	     	end 
	     	done_list = d_list
	     	todo_list = t_list
        end

		if(g.extra.video ~= nil) then
	    	contents = contents..itemTostring(g.extra.video)
		end 

        local timeline = screen:find_child("timeline")
		if timeline then
	    	contents = contents .."local timeline = ui_element.timeline { \n\tpoints = {" 
	      	for m,n in orderedPairs (timeline.points) do 
		    	contents = contents.."["..tostring(m).."] = {"
		    	for q,r in pairs (n) do
		        	if q == 1 then 
			      		contents = contents.."\""..tostring(r).."\","
		         	else 
			      		contents = contents..tostring(r)..","
		         	end
		    	end 
		    	contents = contents.."},"
	      	end 
	      	contents = contents.."},\n\t" 
            contents = contents.."duration = "..timeline.duration..",\n\tnum_point = "..timeline.num_point.."\n}\n" 
            contents = contents.."screen:add(timeline)\n\n"
	      	contents = contents.."if editor_lb == nil then\n\tscreen:find_child(\"timeline\"):hide()\nend\n\n"
		end 

		contents = contents.."\ng:add("..obj_names..")"
        contents = "local g = ... \n\n"..contents

        undo_list = {}
        redo_list = {}

		if save_backup_f == nil then  
			editor_lb:writefile(current_fn, contents, true)	
		end 
		local back_file = current_fn.."\.back"
		editor_lb:writefile(back_file, contents, true)	

		local main = readfile("main.lua")
		if(current_fn ~= "" and main ) then 
			local j,k = string.find(current_fn, "/")
 	        local fileUpper= string.upper(string.sub(current_fn, k+1, -5))
	   		local fileLower= string.lower(string.sub(current_fn, k+1, -5))
			local added_stub_code = ""
			
			if string.find(main, "-- "..fileUpper.." SECTION") ~= nil then 
			-- input_t.text-새로 저장할 루아 파일에 대한 정보가 메인에 있는지를 확인하고 
			-- 있으면 .. 그내용물에 대한 스터브 코드가 일일이 있는지 확인하고 양쪽을 맞춰 주어야 함. 
			-- 그리고 저장 끝 	
				for i, j in pairs (g.children) do 
		   			if need_stub_code(j) == true then 
						if j.extra.prev_name then 
							if string.find(main, "-- "..fileUpper.."\."..string.upper(j.extra.prev_name).." SECTION\n") ~= nil then  			
			          			local q, w = string.find(main, "-- "..fileUpper.."\."..string.upper(j.extra.prev_name).." SECTION\n") 
				  				local e, r = string.find(main, "-- END "..fileUpper.." SECTION\n\n")
				  				local main_first = string.sub(main, 1, q-1)
				  				local main_temp = string.sub(main, q,r)
				  				local main_last = string.sub(main, r+1, -1)
				  				main_temp = string.gsub(main_temp,string.upper(j.extra.prev_name),string.upper(j.name))
				  				main_temp = string.gsub(main_temp,j.extra.prev_name,tostring(j.name))
				  				main = ""
				  				main = main_first..main_temp..main_last
				  				editor_lb:writefile("main.lua",main, true)
	       		     		end 
						end 

	                 	if string.find(main, "-- "..fileUpper.."\."..string.upper(j.name).." SECTION\n") == nil then  			
					 		added_stub_code = added_stub_code.."-- "..fileUpper.."\."..string.upper(j.name).." SECTION\n"
					    	if j.extra.type == "Button" then 
					     		added_stub_code = added_stub_code.."layout[\""..fileLower.."\"]\."..j.name.."\.focused = function() -- Handler for "..j.name.."\.focused in this screen\nend\n"
					     	   	added_stub_code = added_stub_code.."layout[\""..fileLower.."\"]\."..j.name.."\.pressed = function() -- Handler for "..j.name.."\.pressed in this screen\nend\n"
					     	   	added_stub_code = added_stub_code.."layout[\""..fileLower.."\"]\."..j.name.."\.released = function() -- Handler for "..j.name.."\.released in this screen\nend\n"
			   		     	elseif j.extra.type == "ButtonPicker" or j.extra.type == "RadioButtonGroup" then 
	                   			added_stub_code = added_stub_code.."layout[\""..fileLower.."\"]\."..j.name.."\.rotate_func = function(selected_item) -- Handler for "..j.name.."\.rotate_func in this screen\nend\n"
			   		     	elseif j.extra.type == "CheckBoxGroup" then 
	                   			added_stub_code = added_stub_code.."layout[\""..fileLower.."\"]\."..j.name.."\.rotate_func = function(selected_items) -- Handler for "..j.name.."\.rotate_func in this screen\nend\n"
			   		     	elseif j.extra.type == "MenuButton" then 
			   					for k,l in pairs (j.items) do 
			   	     		     	if l["type"] == "item" then 
	                   			    	added_stub_code = added_stub_code.."layout[\""..fileLower.."\"]\."..j.name.."\.items["..k.."][\"f\"] = function() end -- Handler for in this menu button\n"
			   	     		     	end 
			   					end 
			   		     	end 
	                   		added_stub_code = added_stub_code.."-- END "..fileUpper.."\."..string.upper(j.name).." SECTION\n\n" 	
						end
					end 
				end --for

				local q,w 
				q, w = string.find(main, "-- END "..fileUpper.." SECTION\n\n")
				local main_first = string.sub(main, 1, q-1)
				local main_last = string.sub(main, q, -1)
				if added_stub_code ~= "" then 
					main = ""
					main = main_first..added_stub_code..main_last
					editor_lb:writefile("main.lua",main, true)
				end 
	       	else 
				inputMsgWindow("savefile",current_fn)
	       	end	
	       -- editor_lb:writefile(current_fn, contents, true)	
		elseif (current_fn ~= "" and main == nil) then 
			inputMsgWindow("savefile",current_fn)
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
	    	contents = ""
        	local obj_names = getObjnames()

			for i, v in pairs(g.children) do
		   		local result, d_list, t_list, result2 = itemTostring(v, done_list, todo_list)  
		   		if result2  ~= nil then 
            		contents=result2..contents
		   		end  
		   		if result ~= nil then 
            		contents=contents..result
		   		end 
		   		done_list = d_list
		   		todo_list = t_list
            end
	
	     	if (g.extra.video ~= nil) then
	        	contents = contents..itemTostring(g.extra.video)
	     	end 

	     	local timeline = screen:find_child("timeline")
	     	if timeline then
	        	contents = contents .."local timeline = ui_element.timeline { \n\tpoints = {" 
	          	for m,n in orderedPairs(timeline.points) do 
		        	contents = contents.."["..tostring(m).."] = {"
			    	for q,r in pairs (n) do
				    	if q == 1 then 
				       		contents = contents.."\""..tostring(r).."\","
				    	else 
				       		contents = contents..tostring(r)..","
				    	end
			    	end 
		        	contents = contents.."},"
	         	end 
	         	contents = contents.."},\n\t" 
                contents = contents.."duration = "..timeline.duration..",\n\tnum_point = "..timeline.num_point.."\n}\n" 
                contents = contents.."screen:add(timeline)\n\n"
	        	contents = contents.."if editor_lb == nil then\n\tscreen:find_child(\"timeline\"):hide()\nend\n\n"
	     	end 
	     	contents = contents.."\ng:add("..obj_names..")"
            contents = "local g = ... \n\n"..contents
            undo_list = {}
            redo_list = {}
        	inputMsgWindow("savefile")
     	end 
     end 	

     g:add(screen_rect) 
     if screen:find_child("mouse_pointer") then 
		screen:find_child("mouse_pointer"):raise_to_top()
     end
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
    color= DEFAULT_COLOR,
    size = {1,1},
    position = {x,y,0}, 
	extra = {org_x = x, org_y = y}
    }
    ui.rect.reactive = true
    table.insert(undo_list, {ui.rect.name, ADD, ui.rect})
    g:add(ui.rect)
	if(screen:find_child("screen_objects") == nil) then 
    	--screen:add(g)
	end
	
	ui.rect.extra.lock = false
    create_on_button_down_f(ui.rect) 
end 

function editor.rectangle_done(x,y)
	if ui.rect == nil then return end 
    ui.rect.size = { abs(x-rect_init_x), abs(y-rect_init_y) }
    if(x-rect_init_x < 0) then
    	ui.rect.x = x
    end
    if(y-rect_init_y < 0) then
    	ui.rect.y = y
    end
    item_num = item_num + 1
    screen.grab_key_focus(screen)

	local timeline = screen:find_child("timeline")
	if timeline then 
	    ui.rect.extra.timeline = {}
        ui.rect.extra.timeline[0] = {}
	    local prev_point = 0
	    local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	    for l,k in pairs (attr_map["Rectangle"]()) do 
	        ui.rect.extra.timeline[0][k] = ui.rect[k]
	    end
	    if cur_focus_n ~= 0 then 
                ui.rect.extra.timeline[0]["hide"] = true  
	    end 

	    for i, j in orderedPairs(timeline.points) do 
	        if not ui.rect.extra.timeline[i] then 
		    	ui.rect.extra.timeline[i] = {} 
	            for l,k in pairs (attr_map["Rectangle"]()) do 
		         ui.rect.extra.timeline[i][k] = ui.rect.extra.timeline[prev_point][k] 
		    	end 
		    	prev_point = i 
			end 
	        if i < cur_focus_n  then 
            	ui.rect.extra.timeline[i]["hide"] = true  
			end 
	    end 
	end 
end 

function editor.rectangle_move(x,y)
	if ui.rect then 
        ui.rect.size = { abs(x-rect_init_x), abs(y-rect_init_y) }
        if(x- rect_init_x < 0) then
            ui.rect.x = x
        end
        if(y- rect_init_y < 0) then
            ui.rect.y = y
        end
	end
end

local function ungroup(v)
     v.extra.children = {}
     editor.n_selected(v)
     for i,c in pairs(v.children) do 
     	table.insert(v.extra.children, c.name) 
		c.extra.is_in_group = false
		v:remove(c)
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
			if is_in_list(undo_item[3].extra.type, uiElements) == false then 
		        for i, c in pairs(undo_item[3].extra.children) do
					local c_tmp = g:find_child(c)
					editor.n_selected(c_tmp)
					g:remove(g:find_child(c))
					c_tmp.extra.is_in_group = true
					c_tmp.x = c_tmp.x - undo_item[3].x
					c_tmp.y = c_tmp.y - undo_item[3].y
					undo_item[3]:add(c_tmp)
		    	end 
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
	text = strings[""], font= "DejaVu Sans 30px",
	-- 0111 text = "", font= "DejaVu Sans 40px",
    color = DEFAULT_COLOR, 
	position ={700, 500, 0}, 
	editable = true , reactive = true, 
	wants_enter = true, size = {300, 100},wrap=true, wrap_mode="CHAR", 
	extra = {org_x = 700, org_y = 500}
	} 
    table.insert(undo_list, {ui.text.name, ADD, ui.text})
    g:add(ui.text)

	local timeline = screen:find_child("timeline")
	if timeline then 
	    ui.text.extra.timeline = {}
        ui.text.extra.timeline[0] = {}
	    local prev_point = 0
	    local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	    for l,k in pairs (attr_map["Text"]()) do 
	    	ui.text.extra.timeline[0][k] = ui.text[k]
	    end
	    if cur_focus_n ~= 0 then 
            ui.text.extra.timeline[0]["hide"] = true  
	    end 

	    for i, j in orderedPairs(timeline.points) do 
	        if not ui.text.extra.timeline[i] then 
		    	ui.text.extra.timeline[i] = {} 
	            for l,k in pairs (attr_map["Text"]()) do 
		        	ui.text.extra.timeline[i][k] = ui.text.extra.timeline[prev_point][k] 
		    	end 
		    	prev_point = i 
			end 
	        if i < cur_focus_n  then 
            	ui.text.extra.timeline[i]["hide"] = true  
			end 
	    end 
	end 

	if(screen:find_child("screen_objects") == nil) then 
             --screen:add(g)
	end
    ui.text.grab_key_focus(ui.text)
    local n = table.getn(g.children)

    function ui.text:on_key_down(key)
    	if key == keys.Return and shift == false then
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
	ui.text.extra.lock = false
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
	
function editor.the_video()
	local WIDTH = 700
	local L_PADDING = 50
	local R_PADDING = 50
    local TOP_PADDING = 60
    local BOTTOM_PADDING = 12
    local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF"}
	local space = WIDTH

	local dir = editor_lb:readdir(CURRENT_DIR.."/assets/videos")
	local dir_text = Text {name = "dir", text = "File Location : "..CURRENT_DIR.."/assets/videos"}:set(STYLE)

	local cur_w= (WIDTH - dir_text.w)/2
	local cur_h= TOP_PADDING/2 + Y_PADDING


	dir_text.position = {cur_w,cur_h,0}

	function get_file_list_sz() 
	     local iw = cur_w
	     local ih = cur_h
	     cur_w = L_PADDING
	     cur_h = cur_h + dir_text.h + Y_PADDING

     	 for i, v in pairs(dir) do
	     	if (is_mp4_file(v) == true) then 
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
	     	if (is_mp4_file(v) == true) then 
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
		    	input_text.color = DEFAULT_COLOR -- {255, 255, 255, 255}
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
 	    	if screen:find_child("inspector") then 
		    	screen:find_child("file_name").text = input_text.text
	      	else 
	            inputMsgWindow_openvideo("open_videofile", input_text.text)
	      	end
	      	cleanMsgWin(msgw)
	 	end 
    end 

    function open_t:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then	
 	      if screen:find_child("inspector") then 
		    screen:find_child("file_name").text = input_text.text
	      else 
    	     inputMsgWindow_openvideo("open_videofile", input_text.text)
	      end 
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

		     	local timeline = screen:find_child("timeline")
		     	if timeline then 
	    			ui.clone.extra.timeline = {}
            		ui.clone.extra.timeline[0] = {}
	    			local prev_point = 0
	        		local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	    			for l,k in pairs (attr_map["Clone"]()) do 
	        	     	ui.clone.extra.timeline[0][k] = ui.clone[k]
	    			end
	    			if cur_focus_n ~= 0 then 
                			ui.clone.extra.timeline[0]["hide"] = true  
	    			end 
	    			for i, j in orderedPairs(timeline.points) do 
	        	     	if not ui.clone.extra.timeline[i] then 
		    	          	ui.clone.extra.timeline[i] = {} 
	            		  	for l,k in pairs (attr_map["Clone"]()) do 
		         	  			ui.clone.extra.timeline[i][k] = ui.clone.extra.timeline[prev_point][k] 
		    		  		end 
		                  	prev_point = i 
			     		end 
	        	     	if i < cur_focus_n  then 
                    		ui.clone.extra.timeline[i]["hide"] = true  
			     		end 
	    	        end 
		     	end 
 
		     
	           	if(screen:find_child("screen_objects") == nil) then 
        	          --screen:add(g)        
		     	end 
        	    ui.clone.reactive = true
		     	ui.clone.extra.lock = false
		     	create_on_button_down_f(ui.clone)
		     	item_num = item_num + 1
			end 
        end
	end

	input_mode = S_SELECT
	screen:grab_key_focus()
end
	
function editor.duplicate()
	local next_position 
    if(table.getn(selected_objs) == 0 )then 
		print("there are no selected objects") 
        screen:grab_key_focus()
	    input_mode = S_SELECT
		return 
    end 

	for i, v in pairs(g.children) do
    	if g:find_child(v.name) then
	    	if(v.extra.selected == true) then
		     	if ui.dup then
		          	if ui.dup.name == v.name then 
						next_position = {2 * v.x - ui.dup.extra.position[1], 2 * v.y - ui.dup.extra.position[2]}
			  		end 
		     	end 
		     
                function dup_function ()
		        	if is_this_widget(v) == false  then	
                    	while(is_available(string.lower(v.type)..tostring(item_num))== false) do
                        	item_num = item_num + 1
                        end 
                        editor.n_selected(v)
                        ui.dup = copy_obj(v)  
                        ui.dup.name=string.lower(v.type)..tostring(item_num)
                        if next_position then 
                        	ui.dup.extra.position = {v.x, v.y}
                        	ui.dup.position = next_position
                        else 
                        	ui.dup.extra.position = {v.x, v.y}
                        	ui.dup.position = {v.x + 20, v.y +20}
                        end 

                        if v.type == "Group" then 
                        	for i,j in pairs(v.children) do 
                        		if j.name then 
                        			while(is_available(string.lower(j.type)..tostring(item_num))== false) do
                        				item_num = item_num + 1
                        			end 
                        			ui.dup_c = copy_obj(j) 
                        			ui.dup_c.name=string.lower(j.type)..tostring(item_num)
                        			ui.dup:add(ui.dup_c)
                        			ui.dup_c.extra.lock = false
                        			create_on_button_down_f(ui.dup_c)
                        			item_num = item_num + 1
                        		end 
                        	end 
                        end 
                   else 
                   		local w_attr_list =  {"ui_width","ui_height","skin","style","label","button_color","focus_color","text_color","text_font","border_width","border_corner_radius","reactive","border_color","padding","fill_color","title_color","title_font","title_seperator_color","title_seperator_thickness","icon","message","message_color","message_font","on_screen_duration","fade_duration","items","selected_item","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time","empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","border_color","progress","rows","columns","cell_size","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable","visible_w", "visible_h",  "virtual_w", "virtual_h", "bar_color_inner", "bar_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness", "frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "hor_bar_visible", "box_color", "box_width","menu_width","hor_padding","vert_spacing","hor_spacing","vert_offset","background_color","seperator_thickness","expansion_location","direction", "f_color","box_size","check_size","line_space","b_pos", "item_pos","select_color","button_radius","select_radius","tiles","content","text", "color", "border_color", "border_width", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "position", "size", "opacity", "children","reactive"}

                       	ui.dup = widget_f_map[v.extra.type]() 

                        while(is_available(ui.dup.name..tostring(item_num))== false) do
		         			item_num = item_num + 1
                        end 

                        ui.dup.name = ui.dup.name..tostring(item_num)
                        if next_position then 
                        	ui.dup.extra.position = {v.x, v.y}
                            ui.dup.position = next_position
                        else 
                        	ui.dup.extra.position = {v.x, v.y}
                            ui.dup.position = {v.x + 50, v.y +50}
                        end 
				
                        for i,j in pairs(w_attr_list) do 
                        	if v[j] ~= nil then 
                            	if j ~= "name" and j ~= "position" then  
                                 	if j == "content" then  
										local temp_g = copy_obj(v[j])
										for m,n in pairs(v.content.children) do 
			     	   		     			if n.name then 
												while(is_available(string.lower(n.type)..tostring(item_num))== false) do
		         									item_num = item_num + 1
	             								end 
						        				temp_g_c = copy_obj(n) 
												temp_g_c.name=string.lower(n.type)..tostring(item_num)
												temp_g_c.extra.is_in_group = true
												temp_g_c.reactive = true
						
												if screen:find_child(temp_g_c.name.."border") then 
			             							screen:find_child(temp_g_c.name.."border").position = temp_g_c.position
						        				end
												if screen:find_child(temp_g_c.name.."a_m") then 
			             							screen:find_child(temp_g_c.name.."a_m").position = temp_g_c.position 
			        							end 

        	     	        					temp_g:add(temp_g_c)
		     									temp_g_c.extra.lock = false
		     									create_on_button_down_f(temp_g_c)
		     									item_num = item_num + 1
			     	   	   	     			end 
			     	   	   				end 
										ui.dup[j] = temp_g
                                    elseif j == "tiles" then 
						   				for k,l in pairs (v[j]) do 
											if type(l) == "table" then 
							     				for o,p in pairs(l) do 
								  					while(is_available(string.lower(p.type)..tostring(item_num))== false) do
		         										item_num = item_num + 1
	             						  			end 
								  					t_obj = copy_obj(p)
								  					t_obj.name = string.lower(p.type)..tostring(item_num)
								  					t_obj.extra.is_in_group = true
								  					t_obj.reactive = true
				     			          			ui.dup:replace(k,o,t_obj) 
		     						  				t_obj.extra.lock = false
		     						  				create_on_button_down_f(t_obj)
							     				end  
											end 
						   				end
                                    elseif type(v[j]) == "table" then  
						   				local temp_t = {}
						   				for k,l in pairs (v[j]) do 
											temp_t[k] = l
											ui.dup[j][k] = l
						   				end
						   				
						   				if j == "items" then 
					           					ui.dup[j] = temp_t
						   				end 
                                   elseif ui.dup[j] ~= v[j]  then  
					           			ui.dup[j] = v[j] 
					           			--print(j, v[j], ui.dup[j])
                                   end 
                                 end 
                             end 
                          end --for
					end
				end 

                dup_function()

                table.insert(undo_list, {ui.dup.name, ADD, ui.dup})
                g:add(ui.dup)
                local timeline = screen:find_child("timeline")
                if timeline then 
                	ui.dup.extra.timeline = {}
                    ui.dup.extra.timeline[0] = {}
                    local prev_point = 0
                    local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
                    for l,k in pairs (attr_map["Clone"]()) do 
                    	ui.dup.extra.timeline[0][k] = ui.dup[k]
                    end
                    if cur_focus_n ~= 0 then 
                    	ui.dup.extra.timeline[0]["hide"] = true  
                    end 
                    for i, j in orderedPairs(timeline.points) do 
                    	if not ui.dup.extra.timeline[i] then 
                        	ui.dup.extra.timeline[i] = {} 
                            for l,k in pairs (attr_map["Clone"]()) do 
                            	ui.dup.extra.timeline[i][k] = ui.dup.extra.timeline[prev_point][k] 
                            end 
                            prev_point = i 
                        end 
                        if i < cur_focus_n  then 
                        	ui.dup.extra.timeline[i]["hide"] = true  
                        end 
                    end 
                 end 
                 if(screen:find_child("screen_objects") == nil) then 
                 	--screen:add(g)        
                 end 
                 ui.dup.reactive = true
                 ui.dup.extra.lock = false
                 create_on_button_down_f(ui.dup)
                 item_num = item_num + 1
				end 
            end
        end
	input_mode = S_SELECT
	screen:grab_key_focus()
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
		     	if need_stub_code(v) == true then 
					if current_fn then 
	   		     		local fileUpper= string.upper(string.sub(current_fn, 1, -5))
	   		     		local fileLower= string.lower(string.sub(current_fn, 1, -5))
			     		local main = readfile("main.lua")
			     		if main then 
			        		if string.find(main, "-- "..fileUpper.."\."..string.upper(v.name).." SECTION\n") ~= nil then  			
			          			local q, w = string.find(main, "-- "..fileUpper.."\."..string.upper(v.name).." SECTION\n") 
				  				local e, r = string.find(main, "-- END "..fileUpper.."\."..string.upper(v.name).." SECTION\n\n")
				  				local main_first = string.sub(main, 1, q-1)
				  local main_last = string.sub(main, r+1, -1)
				  main = ""
				  main = main_first..main_last
				  editor_lb:writefile("main.lua",main, true)
	       		        end 
			     end 
	       		end 
	       	     end 
        	     g:remove(v)
		elseif v.extra.type == "ScrollPane" or  v.extra.type == "ArrowPane" then 
			for j, k in pairs (v.content.children) do 
			 if(k.extra.selected == true) then
		     	     editor.n_selected(k)
        	     	     if (screen:find_child(k.name.."a_m") ~= nil) then 
	     		 	screen:remove(screen:find_child(k.name.."a_m"))
                     	     end
        	     	     v.content:remove(k)
			 end 
			end 
		end 
            end
        end

	if table.getn(g.children) == 0 then 
	    if screen:find_child("timeline") then 
		screen:remove(screen:find_child("timeline"))
	    end 
	end 
	input_mode = S_SELECT
	screen:grab_key_focus()
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
        ui.group.extra.type = "Group" -- uiContainer
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
             --screen:add(g)
	end 
	
	local timeline = screen:find_child("timeline")
	if timeline then 
	     ui.group.extra.timeline = {}
             ui.group.extra.timeline[0] = {}
	     local prev_point = 0
	     local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	     for l,k in pairs (attr_map["Group"]()) do 
	          ui.group.extra.timeline[0][k] = ui.group[k]
	     end
	     if cur_focus_n ~= 0 then 
                 ui.group.extra.timeline[0]["hide"] = true  
	     end 
	     for i, j in orderedPairs(timeline.points) do 
	        if not ui.group.extra.timeline[i] then 
	             ui.group.extra.timeline[i] = {} 
	             for l,k in pairs (attr_map["Group"]()) do 
		         ui.group.extra.timeline[i][k] = ui.group.extra.timeline[prev_point][k] 
		     end 
		     prev_point = i 
		end 
	        if i < cur_focus_n  then 
                     ui.group.extra.timeline[i]["hide"] = true  
		end 
	     end 
	end 

        item_num = item_num + 1
	ui.group.extra.lock = false
        --create_on_button_down_f(ui.group) 
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
				---[[ 0128 : added for nested group 
        				if(c.type == "Group") then 
	       				   for j, cc in pairs (c.children) do
						if is_in_list(c.extra.type, uiElements) == false then 
                    				cc.reactive = true
		    				cc.extra.is_in_group = true
						cc.extra.lock = false
                    				create_on_button_down_f(cc)
						end 
	       				   end 
					end 
				--]]
				     v:remove(c)
				     c.extra.is_in_group = false
				     c.x = c.x + v.x 
				     c.y = c.y + v.y 
		     		     g:add(c)
				     -- 0328 
				     if not c.reactive then 
					c.reactive = true	
				     end 
				     -- 0328 
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
	ui.group.extra.lock = false
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
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
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
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
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
	        if(v.extra.selected == true and v.name ~= basis_obj_name ) then
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
	        if(v.extra.selected == true and  v.name ~= basis_obj_name) then
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
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
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
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
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
		--print("b.x",b.x,"f.x",f.x,"f.w",f.w,"space",space)
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


function editor.the_ui_elements()

--qqq

  	local WIDTH = 600
    local L_PADDING = 20
    local R_PADDING = 50
    local BOTTOM_PADDING = 12


    local TOP_PADDING = 30
    local Y_PADDING = 22
    local X_PADDING = 10
    local STYLE = {font = "FreeSans Medium 18px" , color = {255,255,255,255}}
    local WSTYLE = {font = "FreeSans Medium 15px" , color = {255,255,255,255}}
    local SSTYLE = {font = "FreeSans Medium 18px" , color = "000000"}
    local WSSTYLE = {font = "FreeSans Medium 15px" , color = "000000"}

    local msgw_bg = Image{src = "lib/assets/panel-no-tabs.png", name = "ui_elements_insert", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={25, 25}, reactive = true}
	local title = Text {name = "title", text = "UI Elements"}:set(STYLE)
	local title_shadow = Text {name = "title", text = "UI Elements"}:set(SSTYLE)
	local widgets_list = Text {name = "w_list", text = "UI Elements"}:set(STYLE)
	local widgets_list = Text {name = "w_list", text = "UI Elements"}:set(STYLE)

	local scroll = scrollPane{}

	local msgw = Group {
		name = "ui_element_insert", 
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {X_PADDING,0}, opacity=50}, 
			title:set{position = {X_PADDING + 1, 1}}, 
			scroll
		}
	}
	

	local function make_msgw_widget_item(caption) 
		local text = Text{ text = caption }:set( WSTYLE )
		local stext = Text{ text = caption }:set( WSSTYLE )
		return text, stext
	end 

	cur_w= X_PADDING
    cur_h= TOP_PADDING 

    for i, v in pairs(uiElementLists) do 
		local widget_t, widget_ts = make_msgw_widget_item(v)
		widget_t.position =  {cur_w, cur_h}
		widget_ts.position =  {cur_w-1, cur_h-1}
    	widget_t.name = v
    	widget_t.reactive = true
		msgw:add(widget_ts)
		msgw:add(widget_t)
		cur_h = cur_h + Y_PADDING
	end
	
--[[
	local widgets_list = Text {name = "w_list", text = "UI Elements"}:set(STYLE)
    local text_g

    cur_w= (WIDTH - widgets_list.w)/2
    cur_h= TOP_PADDING/2 + Y_PADDING

    widgets_list.position = {cur_w,cur_h}
    msgw:add(widgets_list)

            
    cur_w = L_PADDING
    cur_h = TOP_PADDING + widgets_list.h - 10

    for i, v in pairs(uiElements_en) do 
    	 local widget_b, widget_t  = factory.make_msgw_widget_item(assets , v)
	
	 widget_b.position =  {cur_w, cur_h}
    	 widget_b.name = v
    	 widget_b.reactive = true

	 cur_h = cur_h + widget_b.h 
         msgw:add(widget_b)
         
         function widget_b:on_button_down(x,y,button,num_clicks)
	      widget_f_map[v]() 
	      cleanMsgWin(msgw)
        end 

        function widget_t:on_button_down(x,y,button,num_clicks)
	      widget_f_map[v]() 
	      cleanMsgWin(msgw)
	end
    end 


    for i, v in pairs(uiElements) do
         if (i == 6) then 
              cur_w =  cur_w + 280 + Y_PADDING
              cur_h =  TOP_PADDING + widgets_list.h -10
	 end 
	 
	 local widget_label = widget_n_map[v]() 
	 local widget_b, widget_t  = factory.make_msgw_widget_item(assets , widget_label)

    	 widget_b.position =  {cur_w, cur_h}
    	 widget_b.name = v
    	 widget_b.reactive = true
	 cur_h = cur_h + widget_b.h 
         msgw:add(widget_b)
         
         function widget_b:on_button_down(x,y,button,num_clicks)
	      local new_widget = widget_f_map[v]() 
--imsi  : for debugging, will be deleted 
	      if (new_widget.extra.type == "Button") then 
		b=new_widget
	      elseif (new_widget.extra.type == "TextInput") then 
		t=new_widget
	      elseif (new_widget.extra.type == "DialogBox") then 
		db=new_widget
	      elseif (new_widget.extra.type == "ToastAlert") then 
		tb=new_widget
	      elseif (new_widget.extra.type == "RadioButton") then 
		rb=new_widget
	      elseif (new_widget.extra.type == "CheckBox") then 
		cb=new_widget
	      elseif (new_widget.extra.type == "ButtonPicker") then 
		bp=new_widget
	      elseif (new_widget.extra.type == "ProgressSpinner") then 
		ld=new_widget
	      elseif (new_widget.extra.type == "ProgressBar") then 
		lb=new_widget
          elseif (new_widget.extra.type == "LayoutManager") then 
		d=new_widget
         elseif (new_widget.extra.type == "ScrollPane") then 
		si=new_widget
         elseif (new_widget.extra.type == "ArrowPane") then 
		ai=new_widget
         elseif (new_widget.extra.type == "MenuButton") then 
		dd=new_widget
         elseif (new_widget.extra.type == "MenuBar") then 
		mb=new_widget
         elseif (new_widget.extra.type == "TabBar") then 
		tb=new_widget
	end
--imsi 
	if new_widget.name:find("timeline") then 
		    screen:add(new_widget)
	else 
	           while (is_available(new_widget.name..tostring(item_num)) == false) do  
		     item_num = item_num + 1
	           end 
	           new_widget.name = new_widget.name..tostring(item_num)
                   table.insert(undo_list, {new_widget.name, ADD, new_widget})
	           g:add(new_widget)
		   new_widget.extra.lock = false
                   create_on_button_down_f(new_widget)
	           --screen:add(g)
	           screen:grab_key_focus()
	end 
	cleanMsgWin(msgw)
        end 
        function widget_t:on_button_down(x,y,button,num_clicks)

	      local new_widget = widget_f_map[v]() 
--imsi  : for debugging, will be deleted 
	      if (new_widget.extra.type == "Button") then 
		b=new_widget
	      elseif (new_widget.extra.type == "TextInput") then 
		t=new_widget
	      elseif (new_widget.extra.type == "DialogBox") then 
		db=new_widget
	      elseif (new_widget.extra.type == "ToastAlert") then 
		tb=new_widget
	      elseif (new_widget.extra.type == "RadioButton") then 
		rb=new_widget
	      elseif (new_widget.extra.type == "CheckBox") then 
		cb=new_widget
	      elseif (new_widget.extra.type == "ButtonPicker") then 
		bp=new_widget
	      elseif (new_widget.extra.type == "ProgressSpinner") then 
		ld=new_widget
	      elseif (new_widget.extra.type == "ProgressBar") then 
		lb=new_widget
              elseif (new_widget.extra.type == "LayoutManager") then 
		d=new_widget
              elseif (new_widget.extra.type == "ScrollPane") then 
		si=new_widget
              elseif (new_widget.extra.type == "ArrowPane") then 
		ai=new_widget
              elseif (new_widget.extra.type == "MenuButton") then 
		dd=new_widget
              elseif (new_widget.extra.type == "MenuBar") then 
		mb=new_widget
              elseif (new_widget.extra.type == "TabBar") then 
		tb=new_widget
	      end
--imsi  : for debugging, will be deleted 
	
             if new_widget.name:find("timeline") then 
		    screen:add(new_widget)
	     else
 	     	while (is_available(new_widget.name..tostring(item_num)) == false) do  
			item_num = item_num + 1
	      	end 
	      	new_widget.name = new_widget.name..tostring(item_num)
              	table.insert(undo_list, {new_widget.name, ADD, new_widget})
	      	g:add(new_widget)
		new_widget.extra.lock = false
              	create_on_button_down_f(new_widget)
	      	--screen:add(g)
	      	screen:grab_key_focus()

	    end 
	    cleanMsgWin(msgw)
       end 

    end 

    xbox.reactive = true
    function xbox:on_button_down(x,y,button,num_clicks)
	 	screen:remove(msgw)
        msgw:clear()
        screen.grab_key_focus(screen) 
	  --input_mode = S_SELECT
	 return true
    end 
--]]
	
    
	msgw.extra.lock = false
 	screen:add(msgw)
	create_on_button_down_f(msgw)	

	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(msgw)
		msgw:clear() 
		current_inspector = nil
			
        screen.grab_key_focus(screen) 
	    input_mode = S_SELECT
		return true
	end 

    if screen:find_child("mouse_pointer") then 
		 screen:find_child("mouse_pointer"):raise_to_top()
    end
	
end 


function editor.ui_elements()
    local WIDTH = 600
    local L_PADDING = 20
    local R_PADDING = 50
    local TOP_PADDING = 60
    local BOTTOM_PADDING = 12
    local Y_PADDING = 5
    local X_PADDING = 10
    local STYLE = {font = "DejaVu Sans 25px" , color = "FFFFFF"}
    local space = WIDTH
    local msgw_bg = factory.make_popup_bg("widgets")
    local xbox = factory.make_xbox()

    local msgw = Group {
         position ={650, 250},
	 anchor_point = {0,0},
         children =
         {
          msgw_bg,
	  xbox:set{position = {555, 40}},
         }
    }
    local widgets_list = Text {name = "w_list", text = "UI Elements"}:set(STYLE)
    local text_g

    cur_w= (WIDTH - widgets_list.w)/2
    cur_h= TOP_PADDING/2 + Y_PADDING

    widgets_list.position = {cur_w,cur_h}
    msgw:add(widgets_list)

            
    cur_w = L_PADDING
    cur_h = TOP_PADDING + widgets_list.h - 10

    for i, v in pairs(uiElements_en) do 
    	 local widget_b, widget_t  = factory.make_msgw_widget_item(assets , v)
	
	 widget_b.position =  {cur_w, cur_h}
    	 widget_b.name = v
    	 widget_b.reactive = true

	 cur_h = cur_h + widget_b.h 
         msgw:add(widget_b)
         
         function widget_b:on_button_down(x,y,button,num_clicks)
	      widget_f_map[v]() 
	      cleanMsgWin(msgw)
        end 

        function widget_t:on_button_down(x,y,button,num_clicks)
	      widget_f_map[v]() 
	      cleanMsgWin(msgw)
	end
    end 


    for i, v in pairs(uiElements) do
         if (i == 6) then 
              cur_w =  cur_w + 280 + Y_PADDING
              cur_h =  TOP_PADDING + widgets_list.h -10
	 end 
	 
	 local widget_label = widget_n_map[v]() 
	 local widget_b, widget_t  = factory.make_msgw_widget_item(assets , widget_label)

    	 widget_b.position =  {cur_w, cur_h}
    	 widget_b.name = v
    	 widget_b.reactive = true
	 cur_h = cur_h + widget_b.h 
         msgw:add(widget_b)
         
         function widget_b:on_button_down(x,y,button,num_clicks)
	      local new_widget = widget_f_map[v]() 
--imsi  : for debugging, will be deleted 
	      if (new_widget.extra.type == "Button") then 
		b=new_widget
	      elseif (new_widget.extra.type == "TextInput") then 
		t=new_widget
	      elseif (new_widget.extra.type == "DialogBox") then 
		db=new_widget
	      elseif (new_widget.extra.type == "ToastAlert") then 
		tb=new_widget
	      elseif (new_widget.extra.type == "RadioButton") then 
		rb=new_widget
	      elseif (new_widget.extra.type == "CheckBox") then 
		cb=new_widget
	      elseif (new_widget.extra.type == "ButtonPicker") then 
		bp=new_widget
	      elseif (new_widget.extra.type == "ProgressSpinner") then 
		ld=new_widget
	      elseif (new_widget.extra.type == "ProgressBar") then 
		lb=new_widget
          elseif (new_widget.extra.type == "LayoutManager") then 
		d=new_widget
         elseif (new_widget.extra.type == "ScrollPane") then 
		si=new_widget
         elseif (new_widget.extra.type == "ArrowPane") then 
		ai=new_widget
         elseif (new_widget.extra.type == "MenuButton") then 
		dd=new_widget
         elseif (new_widget.extra.type == "MenuBar") then 
		mb=new_widget
         elseif (new_widget.extra.type == "TabBar") then 
		tb=new_widget
	end
--imsi 
	if new_widget.name:find("timeline") then 
		    screen:add(new_widget)
	else 
	           while (is_available(new_widget.name..tostring(item_num)) == false) do  
		     item_num = item_num + 1
	           end 
	           new_widget.name = new_widget.name..tostring(item_num)
                   table.insert(undo_list, {new_widget.name, ADD, new_widget})
	           g:add(new_widget)
		   new_widget.extra.lock = false
                   create_on_button_down_f(new_widget)
	           --screen:add(g)
	           screen:grab_key_focus()
	end 
	cleanMsgWin(msgw)
        end 
        function widget_t:on_button_down(x,y,button,num_clicks)

	      local new_widget = widget_f_map[v]() 
--imsi  : for debugging, will be deleted 
	      if (new_widget.extra.type == "Button") then 
		b=new_widget
	      elseif (new_widget.extra.type == "TextInput") then 
		t=new_widget
	      elseif (new_widget.extra.type == "DialogBox") then 
		db=new_widget
	      elseif (new_widget.extra.type == "ToastAlert") then 
		tb=new_widget
	      elseif (new_widget.extra.type == "RadioButton") then 
		rb=new_widget
	      elseif (new_widget.extra.type == "CheckBox") then 
		cb=new_widget
	      elseif (new_widget.extra.type == "ButtonPicker") then 
		bp=new_widget
	      elseif (new_widget.extra.type == "ProgressSpinner") then 
		ld=new_widget
	      elseif (new_widget.extra.type == "ProgressBar") then 
		lb=new_widget
              elseif (new_widget.extra.type == "LayoutManager") then 
		d=new_widget
              elseif (new_widget.extra.type == "ScrollPane") then 
		si=new_widget
              elseif (new_widget.extra.type == "ArrowPane") then 
		ai=new_widget
              elseif (new_widget.extra.type == "MenuButton") then 
		dd=new_widget
              elseif (new_widget.extra.type == "MenuBar") then 
		mb=new_widget
              elseif (new_widget.extra.type == "TabBar") then 
		tb=new_widget
	      end
--imsi  : for debugging, will be deleted 
	
             if new_widget.name:find("timeline") then 
		    screen:add(new_widget)
	     else
 	     	while (is_available(new_widget.name..tostring(item_num)) == false) do  
			item_num = item_num + 1
	      	end 
	      	new_widget.name = new_widget.name..tostring(item_num)
              	table.insert(undo_list, {new_widget.name, ADD, new_widget})
	      	g:add(new_widget)
		new_widget.extra.lock = false
              	create_on_button_down_f(new_widget)
	      	--screen:add(g)
	      	screen:grab_key_focus()

	    end 
	    cleanMsgWin(msgw)
       end 

    end 

    xbox.reactive = true
    function xbox:on_button_down(x,y,button,num_clicks)
	 	screen:remove(msgw)
        msgw:clear()
        screen.grab_key_focus(screen) 
	  --input_mode = S_SELECT
	 return true
    end 

    screen:add(msgw)

    if screen:find_child("mouse_pointer") then 
		 screen:find_child("mouse_pointer"):raise_to_top()
    end

end 




