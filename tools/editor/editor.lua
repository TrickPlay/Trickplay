local factory = ui.factory
local editor = {}
local rect_init_x = 0
local rect_init_y = 0
local g_init_x = 0
local g_init_y = 0

local menuButtonView 

local allUiElements     = { 
						 	"Rectangle", "Text", "Image", "Video", "Button", "TextInput", "DialogBox", "ToastAlert", 
						 	"CheckBoxGroup", "RadioButtonGroup", "ButtonPicker", "ProgressSpinner", "ProgressBar", 
						 	"MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane"
					      }

local engineUiElements  = { 
							"Rectangle", "Text", "Image", "Video" 
						  }

local editorUiElements 	= {
							"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", 
							"ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", 
							"ScrollPane", "ArrowPane" 
				     	  }

local widget_f_map = 
{
     ["Rectangle"]	= function () input_mode = hdr.S_RECTANGLE screen:grab_key_focus() end, 
     ["Text"]		= function () editor.text() input_mode = hdr.S_SELECT end, 
     ["Image"]		= function () input_mode = hdr.S_SELECT editor.image() end, 	
     ["Video"] 		= function () input_mode = hdr.S_SELECT editor.video() end,
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


local function guideline_inspector(v)
  	local WIDTH = 300
  	local HEIGHT = 150
    local PADDING = 13
	local TOP_BAR = 30
    local MSG_BAR = 80
    local BOTTOM_BAR = 40

    local TSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local MSTYLE = {font = "FreeSans Medium 12px" , color = {255,255,255,255}}
    local TSSTYLE = {font = "FreeSans Medium 14px" , color = "000000", opacity=50}
    local MSSTYLE = {font = "FreeSans Medium 12px" , color = "000000", opacity=50}

    local msgw_bg = assets("lib/assets/panel-new.png"):set{name = "save_file_bg", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={30, 30}, reactive = true}
	local title = Text {name = "title", text = "Guideline" }:set(TSTYLE)
	local title_shadow = Text {name = "title", text = "Guideline"}:set(TSSTYLE)
	local message = Text {}:set(MSTYLE)
	local message_shadow = Text {}:set(MSSTYLE)

	-- Text Input Field 	
	local org_position 

	if(util.guideline_type(v.name) == "v_guideline") then
		org_position = tostring(math.floor(v.x))
		title.text = "Vertical Guideline"
		title_shadow.text = "Vertical Guideline"
		message.text = "X Position:"
		message_shadow.text = "X Position:"
	else
		org_position = tostring(math.floor(v.y))
		title.text =  "Horizontal Guideline"
		title_shadow.text = "Horizontal Guideline"
		message.text = "Y Position:"
		message_shadow.text = "Y Position:"
	end 

	local text_input = ui_element.textInput{skin = "Custom", ui_width = WIDTH - 2 * PADDING , ui_height = 22 , text = org_position, padding = 5 , border_width  = 1,
		  border_color  = {255,255,255,255}, fill_color = {0,0,0,255}, focus_color = {255,0,0,255}, focus_fill_color = {50,0,0,255}, cursor_color = {255,255,255,255}, 
		  text_font = "FreeSans Medium 12px", text_color =  {255,255,255,255},
    	  border_corner_radius = 0,}

	--Buttons 
   	local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
 		  skin = "default", ui_width = 80, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = text_input}
   	local button_delete = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
 		  skin = "default", ui_width = 80, ui_height = 27, label = "Delete", focus_color = {27,145,27,255}, focus_object = text_input}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    	  skin = "default", ui_width = 80, ui_height = 27, label = "OK", focus_color = {27,145,27,255}, active_button= true, focus_object = text_input} 

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down() end 
	button_delete.pressed = function() screen:remove(screen:find_child(v.name))
 									   xbox:on_button_down() 
							end 

	button_ok.pressed = function() 
		if text_input.text == "" then 
			xbox:on_button_down() 
			return
   		end    
		if(util.guideline_type(v.name) == "v_guideline") then
				v.x = tonumber(text_input.text)
		else 
				v.y = tonumber(text_input.text)
		end 
		xbox:on_button_down() 
	end

	local ti_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
		text_input.on_focus_in()
	end

	local tab_func = function()
		text_input.on_focus_out()
		button_ok.active.opacity = 0
		button_ok.dim.opacity = 255
		button_cancel:grab_key_focus()
		button_cancel.on_focus_in()
	end

	-- Focus Destination 
	button_cancel.extra.focus = {[keys.Right] = "button_delete", [keys.Tab] = "button_delete", [keys.Return] = "button_cancel", [keys.Up] = ti_func}
	button_delete.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok", [keys.Left] = "button_cancel", [keys.Return] = "button_delete", [keys.Up] = ti_func}
	button_ok.extra.focus = {[keys.Left] = "button_delete", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = ti_func}

	text_input.extra.focus = {[keys.Tab] = tab_func, [keys.Return] = "button_ok",}

	-- Button Position Set
 		button_cancel:set{position ={WIDTH-button_delete.w-button_ok.w-button_cancel.w-3*PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}
 		button_delete:set{position ={WIDTH-button_delete.w-button_ok.w-2*PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}} 
 		button_ok:set{position ={WIDTH-button_ok.w-PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}

	local msgw = Group {
		name = "msgw",  --ui_element_insert
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {PADDING,PADDING/3}, }, 
			title:set{position = {PADDING+1, PADDING/3+1}}, 
			message_shadow:set{position = {PADDING,TOP_BAR+PADDING},}, 
			message:set{position = {PADDING+1, TOP_BAR+PADDING+1}}, 
			text_input:set{name = "text_input", position= {PADDING, TOP_BAR+PADDING+PADDING/2+message.h +1}}, 
			button_cancel,
			button_delete,
			button_ok
		}
		,scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}
	}

	function xbox:on_button_down()
		screen:remove(msgw)
		msgw:clear() 
		current_inspector = nil
		current_focus = nil
        screen.grab_key_focus(screen) 
	    input_mode = hdr.S_SELECT
		return true
	end 

	function text_input:on_key_down(key)

		local key_focus_obj = screen:find_child(text_input.focus[key]) 

		if text_input.focus[key] then
			if type(text_input.focus[key]) == "function" then
				text_input.focus[key]()
			elseif key_focus_obj then
				if text_input.on_focus_out then
					text_input.on_focus_out()
				end
				key_focus_obj:grab_key_focus()
				if key_focus_obj.on_focus_in then
					key_focus_obj.on_focus_in(key)
				end
			end
		end

	end

	if(util.guideline_type(v.name) == "v_guideline") then
		msgw.x= v.x - msgw.w/2
		msgw.y= screen.h/2 - msgw.h/2
	else
		msgw.y= v.y - msgw.h/2
		msgw.x= screen.w/2 - msgw.w/2
	end 

	msgw.extra.lock = false
 	screen:add(msgw)
	util.create_on_button_down_f(msgw)	
	-- Set focus 
	ti_func()

end 

function editor.small_grid()
	util.clear_bg() BG_IMAGE_20.opacity = 255 
	menuButtonView.items[3]["icon"].opacity = 255
	screen:grab_key_focus()
	input_mode = hdr.S_SELECT
end 

function editor.medium_grid()
	util.clear_bg() BG_IMAGE_40.opacity = 255 input_mode = hdr.S_SELECT
	menuButtonView.items[4]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.large_grid()
	util.clear_bg() BG_IMAGE_80.opacity = 255 input_mode = hdr.S_SELECT
	menuButtonView.items[5]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.white_bg()
	util.clear_bg() BG_IMAGE_white.opacity = 255 input_mode = hdr.S_SELECT
	menuButtonView.items[6]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.black_bg()
	util.clear_bg() input_mode = hdr.S_SELECT
	menuButtonView.items[7]["icon"].opacity = 255
	screen:grab_key_focus()
end 

function editor.show_guides()

	if guideline_show == false then 
		menuButtonView.items[11]["icon"].opacity = 255
		guideline_show = true
		for i= 1, h_guideline, 1 do 
			local h_guide = screen:find_child("h_guideline"..tostring(i))
			if h_guide then 
				h_guide:show() 
			end 
		end 
		for i= 1, v_guideline, 1 do 
			local v_guide = screen:find_child("v_guideline"..tostring(i)) 
			if v_guide then 
				v_guide:show() 
			end
		end 
	else 
		if util.is_there_guideline() then 
			menuButtonView.items[11]["icon"].opacity = 0
			guideline_show = false
			for i= 1, h_guideline, 1 do 
				local h_guide = screen:find_child("h_guideline"..tostring(i)) 
				if h_guide then 
					h_guide:hide() 
				end
			end 
			for i= 1, v_guideline, 1 do 
				local v_guide = screen:find_child("v_guideline"..tostring(i)) 
				if v_guide then 
					v_guide:hide() 
				end 
			end 
		else 
			editor.error_message("008", nil, nil)
		end
	end
	screen:grab_key_focus()
end 

function editor.snap_guides()
	if util.is_there_guideline() then 
		if menuButtonView.items[12]["icon"].opacity > 0 then 
		 	menuButtonView.items[12]["icon"].opacity = 0 
		else 
		 	menuButtonView.items[12]["icon"].opacity = 255 
		end
    else
    	editor.error_message("008", nil, nil)
    end
	screen:grab_key_focus()
end 

local function create_on_line_down_f(v)

        function v:on_button_down(x,y,button,num_clicks)
            dragging = {v, x - v.x, y - v.y }
	     	if(button == 3) then
		  		guideline_inspector(v)
                return true
            end 
            return true
        end

        function v:on_button_up(x,y,button,num_clicks)
	     	if(dragging ~= nil) then 

	        	local actor , dx , dy = unpack( dragging )
		  		if(util.guideline_type(v.name) == "v_guideline") then 
					v.x = x - dx
		  		elseif(util.guideline_type(v.name) == "h_guideline") then  
					v.y = y - dy
		  		end 
	          	dragging = nil
            end
            return true
        end

end 

function editor.v_guideline()

     v_guideline = v_guideline + 1 

     local v_gl = Rectangle {
		name="v_guideline"..tostring(v_guideline),
		border_color= hdr.DEFAULT_COLOR, 
		color={255,25,25,100},
		size = {4, screen.h},
		position = {screen.w/2, 0, 0}, 
		opacity = 255,
		reactive = true, 
     }
     create_on_line_down_f(v_gl)
     screen:add(v_gl)
     screen:grab_key_focus()

	 if menuButtonView.items[11]["icon"].opacity < 255 then 
		v_gl:hide()
	 end 

end

function editor.h_guideline()
     
     h_guideline = h_guideline + 1

     local h_gl = Rectangle {
		name="h_guideline"..tostring(h_guideline),
		border_color= hdr.DEFAULT_COLOR, 
		color={255,25,25,100},
		size = {screen.w, 4},
		position = {0, screen.h/2, 0}, 
		opacity = 255,
		reactive = true
     }
     create_on_line_down_f(h_gl)
     screen:add(h_gl)
     screen:grab_key_focus()

	 if menuButtonView.items[11]["icon"].opacity < 255 then 
		h_gl:hide()
	 end 
end

function editor.close(new, next_func, next_f_param, from_close)

	if menuButtonView == nil then 
		menuButtonView = menu_items.menuButton_view
	end 

	local func_ok = function() 
 		editor.save(true, nil, editor.close, {true, nil, nil, true})
		if next_func then 
			next_func()
		end 
		return
 	end 

	local func_nok = function() 

		editor.close(true, nil, nil, true)
		if next_func then 
				next_func()
		end 
		return

 	end 

	if #g.children > 0 then 
		if current_fn == "" and new == nil then 
			if restore_fn == "" then 
				current_fn = "/screens/unsaved_temp.lua"
				editor.save(true, false)
				return 
			end 
		elseif (#undo_list ~= 0 or restore_fn ~= "") and from_close == nil  then  -- 마지막 저장한 이후로 달라 진게 있으면 
			editor.error_message("003", true, func_ok, func_nok) 
			return -1
		end
	end 


    if(g.extra.video ~= nil) then 
	    g.extra.video = nil
	    mediaplayer:reset()
        mediaplayer.on_loaded = nil
	end

	-- set the background to the default small grid. 

	util.clear_bg()
	editor.small_grid()

	screen_ui.n_select_all ()

	-- remove all the guidelines

	for i=1, v_guideline, 1 do 
	   local v_guide = screen:find_child("v_guideline"..i)
	   if v_guide then 
	     screen:remove(v_guide) 
	   end 
	end
    
	for i=1, h_guideline, 1 do 
	   local h_guide = screen:find_child("h_guideline"..i)
	   if h_guide then 
	     screen:remove(h_guide)
	   end 
	end

	undo_list = {}
	redo_list  = {}
    
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
	end 

	local menu_t = screen:find_child("menu_text")
	if menu_t.extra.project then 
		menu_t.text = menu_t.extra.project
	end 

	if next_func then 
 		next_func(next_f_param)
 	end 

	for i,j in pairs (screen.children) do
		if j.name then 
			if string.find(j.name, "a_m") or string.find(j.name, "border") then 
				screen:remove(j)
			end
		end 
	end 

	return
end 

local function open_files(input_purpose, bg_image, inspector)
	local WIDTH = 300
  	local HEIGHT = 400
    local PADDING = 13

	local L_PADDING = 20
    local R_PADDING = 50

	local TOP_BAR = 30
    local MSG_BAR = 530
    local BOTTOM_BAR = 40

	local Y_PADDING = 22
    local X_PADDING = 10

	local STYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local WSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local SSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}
    local WSSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}

    local msgw_bg = assets("lib/assets/panel-no-tabs.png"):set{name="open_file", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={25, 25}, reactive = true}
	local title = Text{name = "title", text = "Open File"}:set(STYLE)
	local title_shadow = Text {name = "title", text = "Open File"}:set(SSTYLE)

	local selected_file 
	local virtual_hieght = 0
	local dir 
	
	if input_purpose == "open_luafile" then 
		dir = editor_lb:readdir(current_dir.."/screens")
	elseif input_purpose == "open_imagefile" then 
		dir = editor_lb:readdir(current_dir.."/assets/images")
	elseif input_purpose =="open_videofile" then  
		dir = editor_lb:readdir(current_dir.."/assets/videos")
	end 

	local function load_file(v)
		if v == nil then 
			return
		end
		if input_purpose == "open_luafile" then 
			local timeline = screen:find_child("timeline")
	    	if timeline then 
				timeline:clear()
	     		screen:remove(timeline)
	    	end 
        	msg_window.inputMsgWindow_openfile(v)
	    	timeline = screen:find_child("timeline") 
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
		elseif input_purpose == "open_imagefile" then 
			if bg_image then
		   		BG_IMAGE_20.opacity = 0
	            BG_IMAGE_40.opacity = 0
	           	BG_IMAGE_80.opacity = 0
	           	BG_IMAGE_white.opacity = 0
				
				menuButtonView.items[2]["icon"].opacity = 255
				menuButtonView.items[3]["icon"].opacity = 0
    			menuButtonView.items[4]["icon"].opacity = 0
    			menuButtonView.items[5]["icon"].opacity = 0
    			menuButtonView.items[6]["icon"].opacity = 0
    			menuButtonView.items[7]["icon"].opacity = 0

	           	BG_IMAGE_import:set{src = "/assets/images/"..v, opacity = 255} 
			else 
        		msg_window.inputMsgWindow_openimage("open_imagefile", v)
			end
		elseif input_purpose == "open_videofile" then 
        	msg_window.inputMsgWindow_openvideo("open_videofile", v)
		end
	end

	local inspector_activate = function ()
		inspector:remove(inspector:find_child("deactivate_rect"))
	end 

	-- Scroll	
	local scroll = editor_ui.scrollPane{virtual_h = virtual_hieght}

	editor_use = true
	-- Buttons 
    local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    					  skin = "default", ui_width = 100, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = scroll}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255,},
    					  skin = "default", ui_width = 100, ui_height = 27, label = "OK", focus_color = {27,145,27,255},active_button =true, focus_object = scroll} 

	editor_use = false

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down(1) if inspector then inspector_activate() end end
	
	if inspector then 
		button_ok.pressed = function() 
			local f_name = screen:find_child("file_name") 
			if f_name then 
				if selected_file then 
					f_name.text = selected_file 
				end
			end 
			-- clip 
			local tmpImage 
			if selected_file then 
				tmpImage = assets("assets/images/"..selected_file)
			end
			if inspector:find_child("cw") then 
				inspector:find_child("cw"):find_child("input_text").text = tostring(tmpImage.w)
				inspector:find_child("ch"):find_child("input_text").text = tostring(tmpImage.h)
			end 
			xbox:on_button_down(1) 
			inspector_activate() 
		end
	else 
		button_ok.pressed = function() 
			if input_purpose == "open_luafile" then
				undo_list = {} 
				if editor.close(true) ~= "-1" then 
					load_file(selected_file) 
				end 
			else 
				load_file(selected_file) 
			end 
			xbox:on_button_down(1) 

			local dir = editor_lb:readdir(current_dir.."/screens")
			for i, v in pairs(dir) do
				if v == "unsaved_temp.lua" then 
					if readfile("/screens/"..v) ~= "" then 
						editor_lb:writefile("/screens/"..v, "", true)
					end 
				end 
			end 
		end 
	end 

	local s_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
		scroll.on_focus_in()
	end
	
	
	local tab_func = function()
		button_ok.active.opacity = 0
		button_ok.dim.opacity = 255
		button_cancel:grab_key_focus()
		button_cancel.on_focus_in()
	end

	
	--Focus Destination
	button_cancel.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok",  [keys.Return] = "button_cancel", [keys.Up] = s_func}
	button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = s_func}

	
	local msgw = Group {
		name = "msgw", 
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {X_PADDING, 5}, opacity=50}, 
			title:set{position = {X_PADDING + 1, 6}}, 
			scroll:set{name = "scroll", position = {0, TOP_BAR+1}, reactive=true},
			button_cancel:set{name = "button_cancel", position = { WIDTH - button_cancel.w - button_ok.w - 2*PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}, 
			button_ok:set{name = "button_ok", position = { WIDTH - button_ok.w - PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}
		}
,
		scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}	
	}

	local function make_msgw_item(caption) 
		local text = Text{ text = caption, reactive = true,  ellipsize = "MIDDLE", w=270}:set( WSTYLE )
		local stext = Text{ text = caption, reactive = true,  ellipsize = "MIDDLE", w=270}:set( WSSTYLE )
		return text, stext
	end 

	cur_w= PADDING
    cur_h= PADDING 

	local index = 0
	if dir == nil then 
		print("dir is nil ") 
		return msgw
	end 

	table.sort(dir)

    for i, v in pairs(dir) do 
		if (input_purpose == "open_luafile" and  util.is_lua_file(v) == true) or 
		   (input_purpose == "open_imagefile" and  util.is_img_file(v) == true) or 
		   (input_purpose == "open_videofile" and util.is_mp4_file(v) == true) then 

			if v ~= "unsaved_temp.lua" then
			virtual_hieght = virtual_hieght + 22
			index = index + 1

			local item_t, item_ts = make_msgw_item(v)
			local h_rect = Rectangle{border_width = 1, border_color = {0,0,0,255}, color="#a20000", size = {298, 22}, reactive = true, opacity=0}
			h_rect.name = "h_rect"..index
	
			if index == 1 then 
				h_rect.opacity = 255
				selected_file = v
			end

			h_rect.extra.focus = {[keys.Return] = "button_ok", [keys.Up]="h_rect"..(index-1), [keys.Down]="h_rect"..(index+1), [keys.Tab] = function() selected_file = v tab_func() end }
	
			item_t.position =  {cur_w, cur_h}
			item_t.extra.rect = h_rect.name
			item_ts.position =  {cur_w-1, cur_h-1}
			item_ts.extra.rect = h_rect.name
			h_rect.position =  {cur_w - 12, cur_h-1}
	
    		item_t.name = v
    		item_t.reactive = true
	
			scroll.content:add(h_rect)
			scroll.content:add(item_ts)
			scroll.content:add(item_t)
	
			cur_h = cur_h + Y_PADDING
	
       		function item_t:on_button_down(x,y,button,num_click)
				selected_file = item_t.name 
				scroll:find_child(item_t.extra.rect):on_button_down(x,y,button,num_click)
				return true
        	end 
        	function item_ts:on_button_down()
				item_t:on_button_down()
				return true
			end
			function h_rect.extra.on_focus_in()
				h_rect.opacity = 255
				h_rect:grab_key_focus()
			end
			function h_rect.extra.on_focus_out()
				h_rect.opacity = 0
			end
			function h_rect:on_button_down(x,y,button,num_click)
				for i,j in pairs (scroll.content.children) do 
					if j.type == "Rectangle" then 
					 	j.opacity = 0
					end
				end
			
				h_rect.opacity = 255
				h_rect:grab_key_focus()
				selected_file = item_t.name 
				if button == 3 and inspector == nil then 
					load_file(selected_file)
				end
				return true
        	end 
			function h_rect:on_key_down(key)

				local key_focus_obj = msgw:find_child(h_rect.focus[key]) 
				if h_rect.focus[key] then
					if type(h_rect.focus[key]) == "function" then
						h_rect.focus[key]()
					elseif key_focus_obj then
						if h_rect.on_focus_out then
							h_rect.on_focus_out()
						end
						if key_focus_obj.on_focus_in then
							selected_file = v
							key_focus_obj.on_focus_in(key)
							if h_rect.focus[key] ~= "button_ok" then 
								scroll.seek_to_middle(0,key_focus_obj.y) 
							end
						end
					end
				end
				return true
			end
		end
	end 

	end
	scroll.virtual_h = virtual_hieght
	if scroll.virtual_h <= scroll.visible_h then 
		scroll.visible_w = 300
	end 

	
	scroll.extra.focus = {[keys.Tab] = "button_cancel"}
	
	msgw.extra.lock = false
 	screen:add(msgw)
	util.create_on_button_down_f(msgw)	
	
	--Focus
	button_ok.active.opacity = 255
	button_ok.dim.opacity = 0
	scroll.on_focus_in()

	function xbox:on_button_down(x,y,button,num_clicks)
		if screen:find_child(msgw.name) then 
			screen:remove(msgw)
		end 
		msgw:clear() 
		current_inspector = nil
		current_focus = nil 
		if x then 
			input_mode = hdr.S_SELECT
		end 

		if inspector then 
			inspector_activate() 
		else 
			screen.grab_key_focus(screen) 
		end 

		return true
	end 

	return msgw

end

function editor.open(from_open)
	local func_ok = function() 
		editor.save(true,nil, editor.open, true)
		return
 	end 

	local func_nok = function() 
		editor.open(true)
		return
 	end 

	if #undo_list ~= 0 and from_open == nil then  -- 마지막 저장한 이후로 달라 진게 있으면 
		editor.error_message("003", true, func_ok, func_nok) 
		return 
	end
	open_files("open_luafile")
end

function editor.image(bg_image, inspector)
	return open_files("open_imagefile", bg_image, inspector)
end

function editor.video(inspector)
	return open_files("open_videofile",nil,inspector)
end

function editor.inspector(v, x_pos, y_pos, scroll_y_pos)

	local save_items 

	if not scroll_y_pos then 
	     save_items = true 
	else 
	     save_items = false 
	end 

	local WIDTH = 300
  	local HEIGHT = 400
    local PADDING = 6

	local L_PADDING = 20
    local R_PADDING = 50

	local TOP_BAR = 30
    local MSG_BAR = 530
    local BOTTOM_BAR = 40

	local Y_PADDING = 22
    local X_PADDING = 10
	local GUTTER = 13 

	local STYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local WSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local SSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}
    local WSSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}
    local ISTYLE = {font = "FreeSans Medium 12px" , color = {255,255,255,255}}
    local ISSTYLE = {font = "FreeSans Medium 12px" , color = "000000"}

    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={25, 25}, reactive = true}
	local title, title_shadow 
	local inspector_bg = assets("lib/assets/panel-tabs.png"):set{name = "open_project", position = {0,0}}
	local inspector_items = {}
	

	if v.name == nil then 
		return 
	end 

	local last_attr_n = "reactive"

	if util.is_this_widget(v) == true then 
		title = Text{name = "title", text = "Inspector: "..v.extra.type}:set(STYLE)
		title_shadow = Text {name = "title", text = "Inspector: "..v.extra.type}:set(SSTYLE)
		if v.extra.type == "TabBar" or v.extra.type == "ToastAlert" or v.extra.type == "DialogBox" or
		   v.extra.type == "ProgressSpinner" or v.extra.type == "ProgressBar" or 
		   v.extra.type == "LayoutManager" or v.extra.type == "ScrollPane" or v.extra.type == "ArrowPane" then 
			last_attr_n = "opacity"
		end 
	else 
		title = Text{name = "title", text = "Inspector: "..v.type}:set(STYLE)
		title_shadow = Text {name = "title", text = "Inspector: "..v.type}:set(SSTYLE)
	end 
	-------------------------------------------------------------
	local INSPECTOR_OFFSET = 30 
    local TOP_PADDING = 12
    local BOTTOM_PADDING = 12
	-------------------------------------------------------------
	if(current_inspector ~= nil) then 
		return 
    end 
 	
	for i, c in pairs(g.children) do
	     screen_ui.n_selected(c)
	end

	-- Scroll	
	local scroll_info = editor_ui.scrollPane{visible_h = 310, visible_w = 285, virtual_w = 280}
	scroll_info.name = "si_info"
	local scroll_more = editor_ui.scrollPane{visible_h = 310, visible_w = 285, virtual_w = 280}
	scroll_more.name = "si_more"
	local scroll_items = editor_ui.scrollPane{visible_h = 310, visible_w = 285, virtual_w = 280}
	scroll_items.name = "si_items"

	-- Buttons 
    editor_use = true
    local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    					  skin = "default", ui_width = 80, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = tabs}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255,},
    					  skin = "default", ui_width = 80, ui_height = 27, label = "Apply", focus_color = {27,145,27,255},active_button =true, focus_object = tabs} 
    editor_use = false

	local labels_t= {}

 	if util.is_this_widget(v) == true then 
 		if v.extra.type == "ToastAlert" or v.extra.type == "DialogBox" or   -- 2 Tabs 
 		   v.extra.type == "ProgressSpinner" or v.extra.type == "ProgressBar" or 
 		   v.extra.type == "ScrollPane" or v.extra.type == "ArrowPane" then 
 		   table.insert (labels_t, "Info")
 		   table.insert (labels_t, "More")
 		elseif  v.extra.type == "Button" or v.extra.type == "LayoutManager" or v.extra.type == "TextInput" then  -- 3 Tabs
 		   table.insert (labels_t, "Info")
 		   table.insert (labels_t, "Focus")
 		   table.insert (labels_t, "More")
		elseif v.extra.type == "TabBar" then 
 		   table.insert (labels_t, "Info")
 		   table.insert (labels_t, "Focus")
 		   table.insert (labels_t, "Labels")
 		   table.insert (labels_t, "More")
 		else  -- 4 Tabs 
 		   table.insert (labels_t, "Info")
 		   table.insert (labels_t, "Focus")
 		   table.insert (labels_t, "Items")
 		   table.insert (labels_t, "More")
 		end 
 	
 	elseif v.type == "Video" then --> 1 Tabs
 		   table.insert (labels_t, "Info")
 	else -- Text, Rect, Image Group, Clone -> 2 Tabs
 		   table.insert (labels_t, "Info")
 		   table.insert (labels_t, "Focus")
 	end

	--Tabs 
	local tabs = editor_ui.tabBar{tab_labels = labels_t}

	local s_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
	end

	--Focus Destination
	button_cancel.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok",  [keys.Return] = "button_cancel", [keys.Up] = s_func}
	button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = s_func}
	-- inspector group 
	local inspector = Group {
		name = "inspector", --msgw
		position = {0,0},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	inspector_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {X_PADDING, 5}, opacity=50}, 
			title:set{position = {X_PADDING + 1, 6}}, 
			tabs:set{name = "tabs", position = {0, TOP_BAR}, reactive=true},
			button_cancel:set{name = "button_cancel", position = { WIDTH - button_cancel.w - button_ok.w - 2*PADDING,HEIGHT - BOTTOM_BAR + PADDING}}, 
			button_ok:set{name = "button_ok", position = { WIDTH - button_ok.w - 1*PADDING,HEIGHT - BOTTOM_BAR + PADDING}}
		},
		scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}	
	}

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down(1) end
	button_ok.pressed = function() if inspector_apply(v, inspector) ~= -1 then  xbox:on_button_down(1)  end end

	local function inspector_position() 
		inspector.x = x_pos
		inspector.y = y_pos

		local display_x = WIDTH * screen.width/screen.display_size[1]
		local display_y = HEIGHT * screen.height /screen.display_size[2]

		if inspector.y + display_y  > screen.h and inspector.x + display_x > screen.w then 
			inspector.y = y_pos - display_y - 20
			inspector.x = x_pos - display_x - 20
		elseif inspector.y + display_y  > screen.h then 
			inspector.y = screen.h - display_y - 10
		elseif inspector.x + display_x > screen.w then 
			inspector.x = screen.w - display_x - 10
		end
	end 

	-- set the inspector location 
	if(v.type ~= "Video") then
	   if(x_pos ~= nil and y_pos ~= nil) then 
	     inspector_position() 
	   end 
	else 
	     inspector.x = screen.w/8
	     inspector.y = screen.h/8
	end 

	-- make the inspector contents 
	local attr_t = util.make_attr_t(v)
	local attr_n, attr_v, attr_s

	local X_INDENT = 8 
	local TOP_PADDING = 43

	local item_group_info = Group{name = "item_group_info", position = {0,0}} 
	local item_group_more = Group{name = "item_group_more", position = {0,0}} 
	local item_group_list = Group{name = "item_group_list", position = {0,0}} 
	local item_group = item_group_info

    local items_height = 0
	local space = 261
	local used = 0
	local used_y = 0
	local prev_y = 0 

	for i=1, #attr_t do 
        if (attr_t[i] == nil) then break end 
	    attr_n = attr_t[i][1] 
	    attr_v = attr_t[i][2] 
	    attr_s = attr_t[i][3] 
        attr_v = tostring(attr_v)
	    if(attr_s == nil) then attr_s = "" end 

		if attr_n == "focus" then 
	    	local focus = factory.make_focuschanger(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true) 
			if focus then 
				focus.position = {GUTTER, GUTTER}
				tabs.tabs[2]:add(focus) 
			end 
		elseif attr_n == "items" or attr_n ==  "tab_labels" then 
			local list_item = factory.make_itemslist(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true) 
			list_item.position = {GUTTER, GUTTER}
			item_group_list:add(list_item)
			scroll_items.virtual_h = item_group_list.h
   			scroll_items.content:add(item_group_list)
			scroll_items.position = {0, 0}
			scroll_items.reactive = true
			tabs.tabs[3]:add(scroll_items) 
		else 
			local item
			if attr_n == "icon" or attr_n =="source"  or attr_n == "src" then -- File Chooser Button 
				item = factory.make_filechooser(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true) 
			elseif attr_n == "reactive" or attr_n == "loop" or attr_n == "vert_bar_visible" or attr_n == "horz_bar_visible" or attr_n == "cells_focusable"  or attr_n == "lock" or attr_n == "justify" or attr_n == "single_line" or attr_n == "arrows_visible" then  -- Attribute with single checkbox
				item = factory.make_onecheckbox(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true)
			elseif attr_n == "anchor_point" then 
				item = factory.make_anchorpoint(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true) 
			elseif attr_n == "skin" or attr_n == "wrap_mode" or attr_n == "alignment" 
			or attr_n == "expansion_location" or attr_n == "cell_size" or attr_n == "style" or attr_n == "direction" or attr_n == "tab_position" then 
				item = factory.make_buttonpicker(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true) 
			else 
	    		item = factory.make_text_input_item(assets, inspector, v, attr_n, attr_v, attr_s, save_items, true) 
			end
		
			if item ~= nil then 
	    		if(item.w < space) then 
		 			if (item.h > items_height) then 
             			items_height = item.h
	     			end 
					if space == 261 then 
         				item.x = GUTTER
					else
         				item.x = used + PADDING  
					end 

					if used_y == 0 then 
		 				item.y = GUTTER
					else 
						item.y = prev_y 
					end 
					prev_y = item.y 
	    		else 
		 			if (attr_n == "ui_width" or attr_n == "w") then 
 		 			end 
         			item.x = GUTTER
		 			item.y = used_y +  7
		 			space = 261 
		 			items_height = item.h 
					prev_y = item.y
        		end 
		 		space = space - item.w - PADDING		
	    		used = item.x + item.w  
				used_y = item.y + items_height
	        	item_group:add(item)
				
	  		end

			if attr_n == last_attr_n then 
				item_group = item_group_more
				space = 261
				items_height = 0
				used_y = 0
				used = 0
			end 
		end 
   	end 

	scroll_info.virtual_h = item_group_info.h 
   	scroll_info.content:add(item_group_info)
	scroll_info.position = {0, 0}
	scroll_info.reactive = true
	tabs.tabs[1]:add(scroll_info) 

	scroll_more.virtual_h = item_group_more.h 
	local tab_n = table.getn(tabs.tab_labels) 
	if item_group_more.h ~= 0 then 
   		scroll_more.content:add(item_group_more)
		scroll_more.position = {0, 0}
		scroll_more.reactive = true
		tabs.tabs[tab_n]:add(scroll_more) 
	end 

    scroll_info.extra.focus = {[keys.Tab] = "button_cancel"}
    scroll_more.extra.focus = {[keys.Tab] = "button_cancel"}
   	inspector.extra.lock = false
   	util.create_on_button_down_f(inspector)	

	--Focus
	button_ok.active.opacity = 255
	button_ok.dim.opacity = 0
	scroll_info.on_focus_in()

	local var_i = 1 

	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(inspector)
		inspector:clear() 
		current_inspector = nil
		current_focus = nil 
		if x then 
	    	input_mode = hdr.S_SELECT
		end 
		if v.extra then 
			if v.extra.type == "MenuButton" then 
        		v.fade_out()
			end 
		end 
		screen.grab_key_focus(screen) 
		return true
	end 

	if v.extra then 
		if v.extra.type == "MenuButton" then 
        	v.fade_in()
		end 
	end 

	input_mode = hdr.S_POPUP
	current_inspector = inspector
    inspector.reactive = true
	inspector.extra.lock = false

	util.create_on_button_down_f(inspector)
	inspector_xbox = inspector:find_child("xbox") 
    inspector_xbox.reactive = true

	function inspector_xbox:on_button_down(x,y,button,num_clicks)
		screen_ui.n_selected(v)
		screen:remove(inspector)
		inspector:clear() 
		current_inspector = nil
			
       	for i, c in pairs(g.children) do
		    if(c.type == "Text") then 
				c.reactive = true
		    end 
        end

		for i, c in pairs(g.children) do
	     		screen_ui.n_selected(c)
		end

        screen.grab_key_focus(screen) 
	    input_mode = hdr.S_SELECT
		if v.extra then 
			if v.extra.type == "MenuButton" then 
            	v.spin_out()
	    	end 
	    end 
		menu.reactivate_menu()
		return true
	end 

	if x_pos ~= nil then 
		if x_pos ~= "touch" then 
			screen:add(inspector)
		else 
			if inspector_apply (v, inspector) ~= -1 then 
				inspector_xbox:on_button_down()
			end 
		end 
	else 
		screen:add(inspector)
	end 

	if scroll_y_pos then 
		 if v.extra.type == "TabBar" then 
		 	tabs.buttons[2].on_button_down()
		 else 
		 	tabs.buttons[3].on_button_down()
		 end 
		 if screen:find_child("si_items") then 
	     	screen:find_child("si_items").extra.seek_to(0, math.floor(math.abs(scroll_y_pos)))
		 end 
	end 
	menu.deactivate_menu()
end


local function save_new_file (fname, save_current_f, save_backup_f)

	if current_fn == "unsaved_temp.lua" then
		current_fn = ""
	end 
	if current_fn == "" then 
		if fname == "" then
			return
   		end   
		current_fn = "screens\/"..fname
	end 

	if(current_dir == "") then 
		editor.error_message("002", fname, project_mng.new_project)  
		return 
	end 

	contents = ""

    local obj_names = util.getObjnames()
    local n = table.getn(g.children)

	for i, v in pairs(g.children) do
		if v.extra then 
			if v.extra.focus == nil then 
				editor.inspector(v, "touch") 
			end 
		end

	    local result, d_list, t_list, result2 = util.itemTostring(v, done_list, todo_list)  

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
		contents = contents..util.itemTostring(g.extra.video)
	end 

    local timeline = screen:find_child("timeline")
	if timeline then
		contents = contents .."local timeline = ui_element.timeline { \n\tpoints = {" 
	    for m,n in util.orderedPairs (timeline.points) do 
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

	local local_ui_elements = ""
	for i, v in pairs(g.children) do
		if v.extra then 
			if v.extra.type == "ScrollPane" or v.extra.type == "ArrowPane" then 
				if local_ui_elements ~= "" then 
    				local_ui_elements = local_ui_elements..","
				end 
    			local_ui_elements = local_ui_elements..v.name
			end 
		end 
    end

	if local_ui_elements ~= "" then 
    	contents = "local g = ... \n\nlocal "..local_ui_elements.."\n\n"..contents
	else 
            contents = "local g = ... \n\n"..contents
	end 

	if save_backup_f == nil or save_backup_f == false then 
    	undo_list = {}
    	redo_list  = {}
	end 

	if current_fn then 
		if current_fn ~= "unsaved_temp.lua" and current_fn ~= "screens/unsaved_temp.lua" and current_fn ~= "/screens/unsaved_temp.lua"then
			local back_file = current_fn.."\.back"
			editor_lb:writefile(back_file, contents, true)	
		end
	end 

	if save_backup_f == true then 
		return 
	end 
	
    if (save_current_f == true) then 

		local screen_dir = editor_lb:readdir(current_dir.."/screens/")

		for i, v in pairs(screen_dir) do
          	if(fname == v)then
				editor.error_message("004",fname,msg_window.inputMsgWindow_savefile)
				return 
          	end
		end

		editor_lb:writefile(current_fn, contents, true)	
		
		if current_fn == "unsaved_temp.lua" or current_fn == "/screens/unsaved_temp.lua"then
				return 
		end 

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
					local gen_added_stub_code 

					local function here(j) 
		   				if util.need_stub_code(j) == true then 
							if j.extra.prev_name then 
									-- object 의 이름이 변경된 경우 찾아서 변경해 준다. 
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
								-- object의 코드가 없을경우에 새로히 추가해 주어야 한다.
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
						else 
							if util.is_this_container(j) == true then 
								if j.extra.type == "TabBar" then 
									for q,w in pairs (j.tabs) do
										gen_added_stub_code(w)
									end
								elseif j.extra.type == "ScrollPane" or j.extra.type == "DialogBox" or j.extra.type == "ArrowPane" then 
									gen_added_stub_code(j.content)
			    				elseif j.extra.type == "LayoutManager" then 
									local content_num = 0 
									local lm_name = j.name
			        				for k,l in pairs (j.tiles) do 
										for n,m in pairs (l) do 
											if m then 
												j = m 
												here(j)
											end 
										end 
									end 
									added_stub_code = added_stub_code.."-- "..fileUpper.."\."..string.upper(lm_name).." SECTION\n\n\t--[[\n\t\tHere is how you might add on_focus_in and on_focus_out function to the each cell item\n\t]]\n\n\t--[[\n\t\tfor r=1, layout[\""..fileLower.."\"]\."..lm_name.."\.rows do\n\t\t\tfor c=1, layout[\""..fileLower.."\"]\."..lm_name.."\.columns do\n\t\t\t\t".."local cell_obj = layout[\""..fileLower.."\"]\."..lm_name.."\.tiles[r][c]\n\t\t\t\tif cell_obj.extra.on_focus_in == nil then\n\t\t\t\t\tfunction cell_obj.extra.on_focus_in ()\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\t\tif cell_obj.extra.on_focus_out == nil then\n\t\t\t\t\tfunction cell_obj.extra.on_focus_out ()\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\tend\n\t\tend\n\t]]\n\n-- END "..fileUpper.."\."..string.upper(lm_name).." SECTION\n\n"

								elseif j.extra.type == "Group" then  
									gen_added_stub_code(j)
								end
			   			end -- is this container == true 
				    end  -- need stub code ~= true
				end -- here()

				gen_added_stub_code = function (g)

				for i, j in pairs (g.children) do 
					if util.is_this_group(j) == false then 
						here(j)
					else 
						for q,w in pairs (j.children) do 
							j = w
							here(j)
						end 
					end 
				end 

				end 

				gen_added_stub_code(g)

				local q,w = string.find(main, "-- END "..fileUpper.." SECTION\n\n")
				local main_first, main_last
				if q then 
					main_first = string.sub(main, 1, q-1)
					main_last = string.sub(main, q, -1)
					if added_stub_code ~= "" then 
						main = ""
						main = main_first..added_stub_code..main_last
						editor_lb:writefile("main.lua",main, true)
					end 
			   	end 
     	  	else	
				msg_window.inputMsgWindow_savefile(fname, current_fn, save_current_f)
	      	end	
		elseif (current_fn ~= "" and main == nil) then  
			 msg_window.inputMsgWindow_savefile(fname, current_fn, save_current_f)
		else
			 editor.save(false)
			 return
		end 
    else -- save_current_file == false, "Save As"   
		msg_window.inputMsgWindow_savefile(fname, current_fn)
	end 	
end 


function editor.save(save_current_f, save_backup_f, next_func, next_f_param)
  	local WIDTH = 300
  	local HEIGHT = 150
    local PADDING = 13
	local TOP_BAR = 30
    local MSG_BAR = 80
    local BOTTOM_BAR = 40

    local TSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local MSTYLE = {font = "FreeSans Medium 12px" , color = {255,255,255,255}}
    local TSSTYLE = {font = "FreeSans Medium 14px" , color = "000000", opacity=50}
    local MSSTYLE = {font = "FreeSans Medium 12px" , color = "000000", opacity=50}

    local msgw_bg = assets("lib/assets/panel-new.png"):set{name = "save_file_bg", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={30, 30}, reactive = true}
	local title = Text {name = "title", text = "Save " }:set(TSTYLE)
	local title_shadow = Text {name = "title", text = "Save "}:set(TSSTYLE)
	local message = Text {text = "File Name:"}:set(MSTYLE)
	local message_shadow = Text {text = "File Name:"}:set(MSSTYLE)

		
	if restore_fn ~= "" then 
		current_fn = "screens/"..restore_fn
	end 

	
	if(current_dir == "") then 
		editor.error_message("002", nil, project_mng.new_project)  
		return 
	end 

	if save_current_f == nil then 
		save_current_f = false
	end 

	if save_current_f == false then 
		title.text = "Save As"
		title_shadow.text = "Save As"
    end 

    if current_time_focus then 
		current_time_focus.on_focus_out()
		current_time_focus = nil
    end 
	
	local screen_rect = g:find_child("screen_rect")
  
    if(g:find_child("screen_rect") ~= nil) then 
          g:remove(g:find_child("screen_rect"))
    end 

	-- Save current file and return 
	if save_backup_f == true and current_fn ~= "" then  
		save_new_file(current_fn, save_current_f, save_backup_f) 
		screen:grab_key_focus()
		if next_func and type (next_func) == "function" then 
			next_func(next_f_param)
		end
		restore_fn = ""
		menu.menu_raise_to_top()
		return 
	end 

	if save_current_f == true and current_fn ~= "" then  
		save_new_file(current_fn, save_current_f, save_backup_f) 
		screen:grab_key_focus()
		menu.menu_raise_to_top()
		return 
	end 

	-- No current file or save as command 
	editor_use = true
	-- Text Input Field 	
	local text_input = ui_element.textInput{skin = "Custom", ui_width = WIDTH - 2 * PADDING , ui_height = 22 , text = "", padding = 5 , border_width  = 1,
		  border_color  = {255,255,255,255}, fill_color = {0,0,0,255}, focus_color = {255,0,0,255}, focus_fill_color = {50,0,0,255}, cursor_color = {255,255,255,255}, 
		  text_font = "FreeSans Medium 12px"  , text_color =  {255,255,255,255},
    	  border_corner_radius = 0, readonly="screen/" }

	--Buttons 
   	local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
 		  skin = "default", ui_width = 100, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = text_input}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    	  skin = "default", ui_width = 100, ui_height = 27, label = "OK", focus_color = {27,145,27,255}, active_button= true, focus_object = text_input} 
	editor_use = false

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down() end 
	button_ok.pressed = function() 
		local file_name 
		if text_input.text == "" then 
			xbox:on_button_down() 
			editor.error_message("005", save_current_f, editor.save)  
			return -1
		elseif text_input.text then 
			if string.sub(text_input.text, -4, -1) == ".lua" then 
			   local name_val = string.sub(text_input.text, 1, -5)
			   local name_format = "[%w_]+"
			   local a, b = string.find(name_val, name_format) 
			   if not (a and a == 1 and b == string.len(name_val)) then 
			        editor.error_message("013","name",nil,nil,inspector)
					return -1 
			   end
			   file_name = text_input.text
			else
			   editor.error_message("015","name",nil,nil,inspector)
			   return -1 
			end 
   		end   
		save_new_file(file_name, save_current_f, save_backup_f) 
		xbox:on_button_down() 

		if next_func and type (next_func) == "function" then 
			next_func(next_f_param)
		end
		restore_fn = ""
	end

	local ti_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
		text_input.on_focus_in()
	end

	local tab_func = function()
		text_input.on_focus_out()
		button_ok.active.opacity = 0
		button_ok.dim.opacity = 255
		button_cancel:grab_key_focus()
		button_cancel.on_focus_in()
	end

	-- Focus Destination 
	button_cancel.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok", [keys.Return] = "button_cancel", [keys.Up] = ti_func}
	button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = ti_func}
	text_input.extra.focus = {[keys.Tab] = tab_func, [keys.Return] = "button_ok",}

	local msgw = Group {
		name = "msgw",  --ui_element_insert
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {PADDING,PADDING/3}, }, 
			title:set{position = {PADDING+1, PADDING/3+1}}, 
			message_shadow:set{position = {PADDING,TOP_BAR+PADDING},}, 
			message:set{position = {PADDING+1, TOP_BAR+PADDING+1}}, 
			text_input:set{name = "text_input", position= {PADDING, TOP_BAR+PADDING+PADDING/2+message.h +1}}, 
			button_cancel:set{name = "button_cancel", position = { WIDTH-button_cancel.w-button_ok.w-2*PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}, 
			button_ok:set{name = "button_ok", position = { WIDTH-button_ok.w-PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}
		}
		,scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}
	}

	msgw.extra.lock = false
 	screen:add(msgw)
	util.create_on_button_down_f(msgw)	
	-- Set focus 
	ti_func()

	function xbox:on_button_down()
		screen:remove(msgw)
		msgw:clear() -- 0708
		current_inspector = nil
		current_focus = nil
        screen.grab_key_focus(screen) 
	    input_mode = hdr.S_SELECT
		return true
	end 

	function text_input:on_key_down(key)
		if text_input.focus[key] then
			if type(text_input.focus[key]) == "function" then
				text_input.focus[key]()
			elseif screen:find_child(text_input.focus[key]) then
				if text_input.on_focus_out then
					text_input.on_focus_out()
				end
				screen:find_child(text_input.focus[key]):grab_key_focus()
				if screen:find_child(text_input.focus[key]).on_focus_in then
					screen:find_child(text_input.focus[key]).on_focus_in(key)
				end
			end
		end
	end

end 

function editor.rectangle(x, y)
    rect_init_x = x 
    rect_init_y = y 
    if (ui.rect ~= nil and "rectangle"..tostring(item_num) == ui.rect.name) then
    	return 0
    end

	while (util.is_available("rectangle"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 
    ui.rect = Rectangle{
    name="rectangle"..tostring(item_num),
    border_color= hdr.DEFAULT_COLOR,
    border_width=0,
    color= hdr.DEFAULT_COLOR,
    size = {1,1},
    position = {x,y,0}, 
	extra = {org_x = x, org_y = y}
    }
    ui.rect.reactive = true
    table.insert(undo_list, {ui.rect.name, hdr.ADD, ui.rect})
    g:add(ui.rect)
	
	ui.rect.extra.lock = false
    util.create_on_button_down_f(ui.rect) 
end 

function editor.rectangle_done(x,y)
	if ui.rect == nil then return end 
    ui.rect.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
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

	    for i, j in util.orderedPairs(timeline.points) do 
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
        ui.rect.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
        if(x- rect_init_x < 0) then
            ui.rect.x = x
        end
        if(y- rect_init_y < 0) then
            ui.rect.y = y
        end
	end

end

local function ungroup(v)

	screen_ui.n_selected_all()
	screen_ui.selected(v)
	editor.ugroup(v)

end 

function editor.undo()
	  
	if( undo_list == nil) then 
		return true 
	end 
    
	local undo_item= table.remove(undo_list)

	if(undo_item == nil) then 
		return true 
	end

	if undo_item[2] == hdr.CHG then 
		screen_ui.n_selected(undo_item[1])
		util.set_obj(g:find_child(undo_item[1]), undo_item[3])
	elseif undo_item[2] == hdr.ADD then 
	    screen_ui.n_selected(undo_item[3])
		if util.is_this_group(undo_item[3]) == true then 
			ungroup(undo_item[3])
		else
			g:remove(g:find_child(undo_item[1]))
	    end 
	elseif undo_item[2] == hdr.DEL then 
		screen_ui.n_selected(undo_item[3])
		if util.is_this_group(undo_item[3]) == true then 
		    for i, c in pairs(undo_item[3].extra.children) do
				local c_tmp = g:find_child(c)
				screen_ui.n_selected(c_tmp)
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
 	end 
	table.insert(redo_list, undo_item)
	screen:grab_key_focus() 
end
	
function editor.redo()
	  if(redo_list  == nil) then return true end 
      local redo_item= table.remove(redo_list )
	  if(redo_item == nill) then return true end
 	  
      if redo_item[2] == hdr.CHG then 
	  		util.set_obj(g:find_child(redo_item[1]),  redo_item[4])
	    	table.insert(undo_list, redo_item)
      elseif redo_item[2] == hdr.ADD then 
			if util.is_this_group(redo_item[3]) then 
	  		--if(redo_item[3].type == "Group") then 
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
      elseif redo_item[2] == hdr.DEL then 
	  	if(redo_item[3].type == "Group") then 
			ungroup(redo_item[3])
	    else 
        	g:remove(g:find_child(redo_item[1]))
	    end 
        table.insert(undo_list, redo_item)
      end 
	  screen:grab_key_focus() 
end

function editor.undo_history()
	print("undo list : ")
	dumptable(undo_list)
	print("redo list : ")
	dumptable(redo_list )
end
	
function editor.debug()
	print("selected objects")
	dumptable(selected_objs)
end 

function editor.text()

	while (util.is_available("text"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 

    ui.text = Text{
    name="text"..tostring(item_num),
	text = strings[""], font= "FreeSans Medium 30px",
    color = hdr.DEFAULT_COLOR, 
	position ={200, 200, 0}, 
	editable = true , reactive = true, 
	wants_enter = true, wrap=true, wrap_mode="CHAR", 
	extra = {org_x = 200, org_y = 200}
	} 
    table.insert(undo_list, {ui.text.name, hdr.ADD, ui.text})
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

	    for i, j in util.orderedPairs(timeline.points) do 
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

    ui.text.grab_key_focus(ui.text)
    local n = table.getn(g.children)

    function ui.text:on_key_down(key,u,t,m)

		if m and m.shift then 
			return true
		end 

    	if key == keys.Return then 
			ui.text:set{cursor_visible = false}
        	screen.grab_key_focus(screen)
			ui.text:set{editable= false}
			local text_len = string.len(ui.text.text) 
			local font_len = string.len(ui.text.font) 
	        local font_sz = tonumber(string.sub(ui.text.font, font_len - 3, font_len -2))	
			local total = math.floor((font_sz * text_len / ui.text.w) * font_sz *2/3) 
			if(total > ui.text.h) then 
				ui.text.h = total 
			end 
			item_num = item_num + 1
			return true
	    end 
	end 

	function ui.text:on_button_down()
		if ui.text.on_key_down then 
	          ui.text:on_key_down(keys.Return)
		end 

		return true
	end 

	ui.text.reactive = true
	ui.text.extra.lock = false
	util.create_on_button_down_f(ui.text)
end

function editor.clone()

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

	while (util.is_available("clone"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 
	for i, v in pairs(g.children) do
    	if g:find_child(v.name) then
	        if(v.extra.selected == true) then
		     	screen_ui.n_selected(v)
		     	ui.clone = Clone {
               	name="clone"..tostring(item_num),
		     	source = v,
                position = {v.x + 20, v.y +20}
        	    }
        	    table.insert(undo_list, {ui.clone.name, hdr.ADD, ui.clone})
        	    g:add(ui.clone)

				if v.extra.clone then 
					table.insert(v.extra.clone, ui.clone.name)
				else 
					v.extra.clone = {}
					table.insert(v.extra.clone, ui.clone.name)
				end 

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
	    			for i, j in util.orderedPairs(timeline.points) do 
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
 
        	    ui.clone.reactive = true
		     	ui.clone.extra.lock = false
		     	util.create_on_button_down_f(ui.clone)
		     	item_num = item_num + 1
			end 
        end
	end


	input_mode = hdr.S_SELECT
	screen:grab_key_focus()
end
	
function editor.duplicate()
	local w_attr_list =  {"ui_width","ui_height","skin","style","label","button_color","focus_color","text_color","text_font","border_width","border_corner_radius","reactive","border_color","padding","fill_color","title_color","title_font","title_separator_color","title_separator_thickness","icon","message","message_color","message_font","on_screen_duration","fade_duration","items","selected_item","selected_items","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time","empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","border_color","progress","rows","columns","cell_size","cell_w","cell_h","cell_spacing_w", "cell_spacing_h", "cell_timing","cell_timing_offset","cells_focusable","visible_w", "visible_h",  "virtual_w", "virtual_h", "bar_color_inner", "bar_color_outer", "bar_focus_color_inner", "bar_focus_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness", "frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "hor_bar_visible", "box_color", "box_focus_color", "box_width","menu_width","hor_padding","vert_spacing","hor_spacing","vert_offset","background_color","separator_thickness","expansion_location","direction", "f_color","box_size","check_size","line_space","button_position", "box_position", "item_position","select_color","button_radius","select_radius","tiles","content","text", "color", "border_color", "border_width", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "position", "size", "opacity", "children","reactive", "arrow_color", "arrow_focus_color"}

	local next_position 

	if(table.getn(selected_objs) == 0 )then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
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
		     
			 	local function copy_widget(org)
					local cpy = widget_f_map[org.extra.type]() 
        			while(util.is_available(cpy.name..tostring(item_num))== false) do
    					item_num = item_num + 1
        			end 
        			cpy.name = cpy.name..tostring(item_num)
					if next_position then 
                    	cpy.extra.position = {v.x, v.y}
                        cpy.position = next_position
                    else 
                        cpy.extra.position = {v.x, v.y}
                        cpy.position = {v.x + 50, v.y +50}
                    end 

					for i,j in pairs(w_attr_list) do 
        				if org[j] ~= nil then 
                			if j == "content" then  
								local temp_g = util.copy_obj(org[j])
								for m,n in pairs(org.content.children) do 
			     					if n.name then 
										local temp_g_c
										while(util.is_available(string.lower(n.type)..tostring(item_num))== false) do
		         							item_num = item_num + 1
	             						end 
										if util.is_this_widget(n) == true then 
											temp_g_c.name=string.lower(n.extra.type)..tostring(item_num)
						    				temp_g_c = copy_widget(n) 
										else 
											temp_g_c.name=string.lower(n.type)..tostring(item_num)
						    				temp_g_c = util.copy_obj(n) 
										end
										temp_g_c.extra.is_in_group = true
										temp_g_c.extra.lock = false
										temp_g_c.reactive = true
		     							util.create_on_button_down_f(temp_g_c)
						
										if screen:find_child(temp_g_c.name.."border") then 
			             					screen:find_child(temp_g_c.name.."border").position = temp_g_c.position
						    			end
										if screen:find_child(temp_g_c.name.."a_m") then 
			             					screen:find_child(temp_g_c.name.."a_m").position = temp_g_c.position 
			        					end 

        	     	        			temp_g:add(temp_g_c)
		     							item_num = item_num + 1
			     	   	 			end 
			   					end 
								cpy[j] = temp_g
                			elseif j == "tiles" then 
								for k,l in pairs (org[j]) do 
									if type(l) == "table" then 
										for o,p in pairs(l) do 
											local t_obj
											while(util.is_available(string.lower(p.type)..tostring(item_num))== false) do
		         								item_num = item_num + 1
	             							end 
											if util.is_this_widget(p) == true then 
												t_obj.name=string.lower(p.extra.type)..tostring(item_num)
						    					t_obj = copy_widget(p) 
											else 
												t_obj = util.copy_obj(p)
												t_obj.name = string.lower(p.type)..tostring(item_num)
											end 
											t_obj.extra.is_in_group = true
											t_obj.reactive = true
		     								t_obj.extra.lock = false
		     								util.create_on_button_down_f(t_obj)
				    						cpy:replace(k,o,t_obj) 
		     								item_num = item_num + 1
										end  
									end 
								end
                 			elseif type(org[j]) == "table" then  
								local temp_t = {}
								for k,l in pairs (org[j]) do 
									temp_t[k] = l
								end
								cpy[j] = temp_t
                			else
								cpy[j] = org[j] 
        					end 
    					end 
					end --for
					return cpy
				end
			
                function dup_function ()
		        	if util.is_this_widget(v) == false  then	
                    	while(util.is_available(string.lower(v.type)..tostring(item_num))== false) do
                        	item_num = item_num + 1
                        end 
                        screen_ui.n_selected(v)
                        ui.dup = util.copy_obj(v)  
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
                        			while(util.is_available(string.lower(j.type)..tostring(item_num))== false) do
                        				item_num = item_num + 1
                        			end 
									if util.is_this_widget(j) == false then 
                        				ui.dup_c = util.copy_obj(j) 
                        				ui.dup_c.name=string.lower(j.type)..tostring(item_num)
                        				ui.dup_c.extra.lock = false
                        				util.create_on_button_down_f(ui.dup_c)
                        				ui.dup:add(ui.dup_c)
                        				item_num = item_num + 1
									else 
										ui.dup_c = copy_widget(j)
										ui.dup:add(ui.dup_c)
                        				ui.dup_c.extra.lock = false
                        				util.create_on_button_down_f(ui.dup_c)
                        				item_num = item_num + 1
										-- group's child is widget 
									---[[	
										 for a,b in pairs(w_attr_list) do 
                        				 	if j[b] ~= nil then 
                            					if b ~= "name" and b ~= "position" then  
                                 					if b == "content" then  
														local temp_g
														if util.is_this_widget(j) == false then 
															temp_g = util.copy_obj(j[b])
														else 
															temp_g = copy_wiget_obj(j[b])
														end 
														for m,n in pairs(j.content.children) do 
			     	   		     								if n.name then 
																	while(util.is_available(string.lower(n.type)..tostring(item_num))== false) do
		         														item_num = item_num + 1
	             													end 
						        									temp_g_c = util.copy_obj(n) 
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
		     														util.create_on_button_down_f(temp_g_c)
		     														item_num = item_num + 1
			     	   	   	     								end 
			     	   	   								end 
														ui.dup_c[b] = temp_g
                                    				elseif b == "tiles" then 
						   								for k,l in pairs (j[b]) do 
															if type(l) == "table" then 
							     								for o,p in pairs(l) do 
								  									while(util.is_available(string.lower(p.type)..tostring(item_num))== false) do
		         														item_num = item_num + 1
	             						  							end 
								  									t_obj = util.copy_obj(p)
								  									t_obj.name = string.lower(p.type)..tostring(item_num)
								  									t_obj.extra.is_in_group = true
								  									t_obj.reactive = true
				     			          							ui.dup_c:replace(k,o,t_obj) 
		     						  								t_obj.extra.lock = false
		     						  								util.create_on_button_down_f(t_obj)
							     								end  
															end 
						   								end
                                    				elseif type(j[b]) == "table" then  
														if b ~= "children" then 
						   									local temp_t = {}
						   									for k,l in pairs (j[b]) do 
																temp_t[k] = l
						   									end
															if ui.dup_c then 
					           									ui.dup_c[b] = temp_t
															end 
														end 
                                   					else --elseif ui.dup_c[b] ~= j[b]  then  
														if ui.dup_c then 
					           								ui.dup_c[b] = j[b] 
														end
                                   					end 
                                 				end 
                             				end 
											if ui.dup_c then 
                        						ui.dup:add(ui.dup_c)
                        						ui.dup_c.extra.lock = false
                        						util.create_on_button_down_f(ui.dup_c)
											end
                        					item_num = item_num + 1
                          					end 
										--	]]
										end 
                        			end 
                        		end 
                        	end 
                   	else --util.is_this_widget == true
                   			
						----[[
                       	ui.dup = widget_f_map[v.extra.type]() 

                        while(util.is_available(ui.dup.name..tostring(item_num))== false) do
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
										local temp_g = util.copy_obj(v[j])
										for m,n in pairs(v.content.children) do 
			     	   		     			if n.name then 
												while(util.is_available(string.lower(n.type)..tostring(item_num))== false) do
		         									item_num = item_num + 1
	             								end 
						        				temp_g_c = util.copy_obj(n) 
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
		     									util.create_on_button_down_f(temp_g_c)
		     									item_num = item_num + 1
			     	   	   	     			end 
			     	   	   				end 
										ui.dup[j] = temp_g
                                    elseif j == "tiles" then 
						   				for k,l in pairs (v[j]) do 
											if type(l) == "table" then 
							     				for o,p in pairs(l) do 
								  					while(util.is_available(string.lower(p.type)..tostring(item_num))== false) do
		         										item_num = item_num + 1
	             						  			end 
								  					t_obj = util.copy_obj(p)
								  					t_obj.name = string.lower(p.type)..tostring(item_num)
								  					t_obj.extra.is_in_group = true
								  					t_obj.reactive = true
				     			          			ui.dup:replace(k,o,t_obj) 
		     						  				t_obj.extra.lock = false
		     						  				util.create_on_button_down_f(t_obj)
							     				end  
											end 
						   				end
                                    elseif type(v[j]) == "table" then  
										if j ~= "children" then 
							   				local temp_t = {}
						   					for k,l in pairs (v[j]) do 
												temp_t[k] = l
						   					end
					           				ui.dup[j] = temp_t
										end 
                                   else
					           			ui.dup[j] = v[j] 
                                   end 
                                 end -- not position, name 
                             end 
                          end --for
					end
				end 

                dup_function()

				if ui.dup then 
                	table.insert(undo_list, {ui.dup.name, hdr.ADD, ui.dup})
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
                    	for i, j in util.orderedPairs(timeline.points) do 
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
                 	ui.dup.reactive = true
                 	ui.dup.extra.lock = false
                 	util.create_on_button_down_f(ui.dup)
                 	item_num = item_num + 1
				end --ui.dup
			end --if selected == true
    	end -- if  
    end -- for 

	input_mode = hdr.S_SELECT
	screen:grab_key_focus()
end

function editor.delete()
	if(table.getn(selected_objs) == 0 )then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

	local delete_f = function(del_obj)

		screen_ui.n_selected(del_obj)

        table.insert(undo_list, {del_obj.name, hdr.DEL, del_obj})

        if (screen:find_child(del_obj.name.."a_m") ~= nil) then 
	     		screen:remove(screen:find_child(del_obj.name.."a_m"))
        end

		if util.need_stub_code(del_obj) == true then 
			if current_fn then 
	   			local fileUpper= string.upper(string.sub(current_fn, 1, -5))
	   		    local fileLower= string.lower(string.sub(current_fn, 1, -5))
			    local main = readfile("main.lua")
			    if main then 
			    	if string.find(main, "-- "..fileUpper.."\."..string.upper(del_obj.name).." SECTION\n") ~= nil then  			
			        	local q, w = string.find(main, "-- "..fileUpper.."\."..string.upper(del_obj.name).." SECTION\n") 
				  		local e, r = string.find(main, "-- END "..fileUpper.."\."..string.upper(del_obj.name).." SECTION\n\n")
				  		local main_first = string.sub(main, 1, q-1)
				  		local main_last = string.sub(main, r+1, -1)
				  		main = ""
				  		main = main_first..main_last
				  		editor_lb:writefile("main.lua",main, true)
	       		    end 
			     end 
	       	end 
	   end 
    end 

	for i, v in pairs(g.children) do
		if(v.extra.selected == true) then
			if v.extra.clone then 
				if #v.extra.clone > 0 then
					editor.error_message("017","",nil,nil,nil)
        			screen:grab_key_focus()
					input_mode = hdr.S_SELECT
					return 
				end 
			end 

			if v.type == "Clone" then 
				util.table_remove_val(v.source.extra.clone, v.name)
			end 
			
			if util.is_this_widget(v) == false then 
				delete_f(v)
		    	g:remove(v)
			end 
		end 
	end 
	

	for i, j in pairs(selected_objs) do 
		j = string.sub(j, 1,-7)
		local bumo
		local s_obj = g:find_child(j)

		if s_obj then 
			bumo = s_obj.parent 
		else 
			return 
		end 

		if bumo.name == nil then 
				if (bumo.parent.name == "window") then -- AP, SP 
			    	bumo = bumo.parent.parent
					for j, k in pairs (bumo.content.children) do 
			 			--if(k.extra.selected == true) then
						if k.name == s_obj.name then 
							delete_f(k) 
        	     	    	bumo.content:remove(k)
			 			end 
					end 
				elseif (bumo.parent.extra.type == "DialogBox") then
					bumo = bumo.parent 
					delete_f(s_obj)
					bumo.content:remove(s_obj)
				elseif (bumo.parent.extra.type == "TabBar") then
					bumo = bumo.parent
					for e,f in pairs (bumo.tabs) do 
						for t,y in pairs (f.children) do 
							if y.name == s_obj.name then 
								delete_f(s_obj)
								f:remove(y)
							end 
						end 
					end 
				end 
		elseif bumo.extra.type == "LayoutManager" then  
				for e, r in pairs (bumo.tiles) do 
					if r then 
						for x, c in pairs (r) do 
							if c.name == s_obj.name then 
							 	delete_f(s_obj) 
							 	bumo:replace(e,x,nil)
							end 
						end
					end 
				end
		else -- Regular Group 
				for p, q in pairs (bumo.children) do 
					if q.name == s_obj.name then 
						delete_f(s_obj) 
						bumo:remove(s_obj)
					end 
				end 
		end 
	end 

	if table.getn(g.children) == 0 then 
	    if screen:find_child("timeline") then 
			screen:remove(screen:find_child("timeline"))
	    end 
	end 

	input_mode = hdr.S_SELECT
	screen:grab_key_focus()

end -- delete
	
	
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

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

    local min_x, max_x, min_y, max_y = get_min_max () 
       
	while (util.is_available("group"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	end 
    ui.group = Group{
    	name="group"..tostring(item_num),
        position = {min_x, min_y}
    }

    ui.group.reactive = true
    ui.group.extra.selected = false
    ui.group.extra.type = "Group" -- uiContainer

    table.insert(undo_list, {ui.group.name, hdr.ADD, ui.group})

	for i, v in pairs(g.children) do
		if(v.extra.selected == true) then
			screen_ui.n_selected(v)
			v:unparent()
        	ui.group:add(v)
			v.extra.is_in_group = true
			v.extra.group_position = ui.group.position
			v.x = v.x - min_x
			v.y = v.y - min_y
		end 
        --end
    end

    g:add(ui.group)

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
	     for i, j in util.orderedPairs(timeline.points) do 
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
    --util.create_on_button_down_f(ui.group) 
    screen.grab_key_focus(screen)
	input_mode = hdr.S_SELECT
end



function editor.ugroup()
	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

	for i, v in pairs(g.children) do
    	if g:find_child(v.name) then
		  	if(v.extra.selected == true) then
				if util.is_this_group(v) == true then
			     	screen_ui.n_selected(v)
			     	v.extra.children = {}
			     	for i,c in pairs(v.children) do 
				     	table.insert(v.extra.children, c.name) 
						c:unparent()
				     	c.extra.is_in_group = false
				     	c.x = c.x + v.x 
				     	c.y = c.y + v.y 
						c.reactive = true	
		     		    g:add(c)
			     	end
			     	g:remove(v)
        		    table.insert(undo_list, {v.name, hdr.DEL, v})
		        end 
		   end 
		end
	end
    screen.grab_key_focus(screen)
	input_mode = hdr.S_SELECT
end

function editor.group_done(x, y)
        ui.group.size = { math.abs(x-g_init_x), math.abs(y-g_init_y) }
        group_border.size = { math.abs(x-g_init_x), math.abs(y-g_init_y) }
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
		ui.group.extra.type = "Group"
        util.create_on_button_down_f(ui.group) 
        screen.grab_key_focus(screen)
		input_mode = hdr.S_SELECT
end 

function editor.group_move(x,y)
	ui.group.size = { math.abs(x-g_init_x), math.abs(y-g_init_y) }
    group_border.size = { math.abs(x-g_init_x), math.abs(y-g_init_y) }
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
		     		screen_ui.n_selected(v)
		     		v.x = v.x + v.anchor_point[1] 
		     		v.y = v.y + v.anchor_point[2] 
				end 
	  		end 
     end 
end  

function editor.left() 
	local org_object, new_object 

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

    org_cord()

    local basis_obj_name = getObjName(selected_objs[1])
    local basis_obj = g:find_child(basis_obj_name)

    for i, v in pairs(g.children) do
    	if g:find_child(v.name) then
	    	if(v.extra.selected == true and v.name ~= basis_obj_name) then
		    	if(v.x ~= basis_obj.x) then
	            	org_object = util.copy_obj(v)
			  		v.x = basis_obj.x
			  		new_object = util.copy_obj(v)
                    table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
		     	end
			end 
    	end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end

function editor.right() 
	local org_object, new_object 

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 
    
	org_cord()

    local basis_obj_name = getObjName(selected_objs[1])
    local basis_obj = g:find_child(basis_obj_name)

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
		   --screen_ui.n_selected(v)
		   if(v.x ~= basis_obj.x + basis_obj.w - v.w) then
	                org_object = util.copy_obj(v)
			v.x = basis_obj.x + basis_obj.w - v.w
			new_object = util.copy_obj(v)
                        table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
		   end
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end

function editor.top()
	local org_object, new_object 
	
	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

    org_cord()

    local basis_obj_name = getObjName(selected_objs[1])
    local basis_obj = g:find_child(basis_obj_name)

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true and v.name ~= basis_obj_name ) then
		  --   screen_ui.n_selected(v)
		     if(v.y ~= basis_obj.y) then
	                org_object = util.copy_obj(v)
			v.y = basis_obj.y 
			new_object = util.copy_obj(v)
                        table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
		     end 
		end 
          end
   end

   ang_cord()
   screen.grab_key_focus(screen)
   input_mode = hdr.S_SELECT
end

function editor.bottom()
    local org_object, new_object 

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 
    org_cord() 

    local basis_obj_name = getObjName(selected_objs[1])
    local basis_obj = g:find_child(basis_obj_name)

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true and  v.name ~= basis_obj_name) then
		     --screen_ui.n_selected(v)
		     if(v.y ~= basis_obj.y + basis_obj.h - v.h) then 	
	                org_object = util.copy_obj(v)
			v.y = basis_obj.y + basis_obj.h - v.h 
			new_object = util.copy_obj(v)
                        table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
		     end 
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end

function editor.hcenter()
     local org_object, new_object 

	 if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	 end 

     org_cord() 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
		     -- screen_ui.n_selected(v)
		     if(v.x ~= basis_obj.x + basis_obj.w/2 - v.w/2) then 
	                org_object = util.copy_obj(v)
			v.x = basis_obj.x + basis_obj.w/2 - v.w/2
			new_object = util.copy_obj(v)
                        table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
		     end
		end 
          end
    end

    ang_cord() 

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT

end

function editor.vcenter()
     local org_object, new_object 

	 if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 


     org_cord() 

     local basis_obj_name = getObjName(selected_objs[1])
     local basis_obj = g:find_child(basis_obj_name)

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true and v.name ~= basis_obj_name) then
		     -- screen_ui.n_selected(v)
		     if(v.y ~=  basis_obj.y + basis_obj.h/2 - v.h/2) then 
	                org_object = util.copy_obj(v)
			v.y = basis_obj.y + basis_obj.h/2 - v.h/2
			new_object = util.copy_obj(v)
                        table.insert(undo_list, {v.name, hdr.CHG, org_object, new_object})
		     end
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
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
	input_mode = hdr.S_SELECT
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
			--screen_ui.n_selected(v)
		end 
          end
    end

    f = table.remove(reverse_t)
    while(table.getn(reverse_t) ~= 0) do  
         b = table.remove(reverse_t)
	 if(b.x ~= f.x + f.w + space) then 
	      org_object = util.copy_obj(b)
	      b.x = f.x + f.w + space 
	      if(b.x > 1920) then 
		print("ERROR b.x is bigger than screen size") 
		--print("b.x",b.x,"f.x",f.x,"f.w",f.w,"space",space)
		b.x = 1920 - b.w 
	      end 
	      new_object = util.copy_obj(b)
              table.insert(undo_list, {b.name, hdr.CHG, org_object, new_object})
	 end 

         f = b 
    end 

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
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

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
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
	      org_object = util.copy_obj(b)
              b.y = f.y + f.h + space 
	      new_object = util.copy_obj(b)
              table.insert(undo_list, {b.name, hdr.CHG, org_object, new_object})
	 end
         f = b 
    end 

    for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
	--		screen_ui.n_selected(v)
		end 
          end
    end

    ang_cord()

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end

function editor.bring_to_front()

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        if(v.extra.selected == true) then
			g:remove(v)
			g:add(v)
    		table.insert(undo_list, {v.name, hdr.ARG, hdr.BRING_FR})
			screen_ui.n_selected(v)
		end 
          end
    end

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end

function editor.send_to_back()

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

     local tmp_g = {}
     local slt_g = {}

     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	        g:remove(v) 
	        if(v.extra.selected == true) then
		        table.insert(slt_g, v)
			screen_ui.n_selected(v)
		else 
		     	table.insert(tmp_g, v) 
		end
          end
    end
    
    while(table.getn(slt_g) ~= 0) do
	v = table.remove(slt_g)
         table.insert(undo_list, {v.name, hdr.ARG, hdr.SEND_BK})
	g:add(v)	
    end 
    
    tmp_g = get_reverse_t(tmp_g) 
    while(table.getn(tmp_g) ~= 0) do
	v = table.remove(tmp_g)
        table.insert(undo_list, {v.name, hdr.ARG, hdr.SEND_BK})
	g:add(v)	
    end 
	
    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end

function editor.send_backward()

	if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
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
			screen_ui.n_selected(v)
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
        table.insert(undo_list, {v.name, hdr.ARG, hdr.SEND_BW})
    end 

    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT

end


function editor.bring_forward()
	
	 if table.getn(selected_objs) == 0 then 
		editor.error_message("016","",nil,nil,nil)
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
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
			screen_ui.n_selected(v)
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
        table.insert(undo_list, {v.name, hdr.ARG, hdr.BRING_FW})
	g:add(v)
    end 
	
    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
end


function editor.ui_elements()

  	local WIDTH = 300
  	local HEIGHT = 400
	local PADDING = 13

    local L_PADDING = 20
    local R_PADDING = 50

	local TOP_BAR = 30
    local MSG_BAR = 530
    local BOTTOM_BAR = 40

    local Y_PADDING = 22
    local X_PADDING = 10

    local STYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local WSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local SSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}
    local WSSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}

    local msgw_bg = assets("lib/assets/panel-no-tabs.png"):set{name = "ui_elements_insert", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={25, 25}, reactive = true}
	local title = Text{name = "title", text = "UI Elements"}:set(STYLE)
	local title_shadow = Text {name = "title", text = "UI Elements"}:set(SSTYLE)
	local selected_ui_element 

	local function load_ui_element(v)
		if v == nil then 
			return
		end
		local new_widget = widget_f_map[v]() 
		if new_widget ~= nil then 
			if new_widget.name:find("timeline") then 
		    	screen:add(new_widget)
			else 
	           	while (util.is_available(new_widget.name..tostring(item_num)) == false) do  
		     		item_num = item_num + 1
	           	end 
	           	new_widget.name = new_widget.name..tostring(item_num)
                table.insert(undo_list, {new_widget.name, hdr.ADD, new_widget})
	           	g:add(new_widget)
		   		new_widget.extra.lock = false
                util.create_on_button_down_f(new_widget)
			end 
			xbox:on_button_down(1)
		elseif v == "Text" then  
			xbox:on_button_down(1, nil,nil,nil, 1) 
		else
			xbox:on_button_down()
		end
	end 

	-- Scroll	
	local scroll = editor_ui.scrollPane{virtual_h = 380}

	-- Buttons 
    local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    					  skin = "default", ui_width = 100, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = scroll}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255,},
    					  skin = "default", ui_width = 100, ui_height = 27, label = "OK", focus_color = {27,145,27,255}, active_button =true, focus_object = scroll} 

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down(1) end
	button_ok.pressed = function() load_ui_element(selected_ui_element) end
	
	local s_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
		scroll.on_focus_in()
	end

	--Focus Destination
	button_cancel.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok",  [keys.Return] = "button_cancel", [keys.Up] = s_func}
	button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = s_func}


	local tab_func = function()
		button_ok.active.opacity = 0
		button_ok.dim.opacity = 255
		button_cancel:grab_key_focus()
		button_cancel.on_focus_in()
	end

	local msgw = Group {
		name = "ui_element_insert", 
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {X_PADDING, 5}, opacity=50}, 
			title:set{position = {X_PADDING + 1, 6}}, 
			scroll:set{name = "scroll", position = {0, TOP_BAR+1}, reactive=true},
			button_cancel:set{name = "button_cancel", position = { WIDTH - button_cancel.w - button_ok.w - 2*PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}, 
			button_ok:set{name = "button_ok", position = { WIDTH - button_ok.w - PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}
		}
,
		scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}	
	}

	local function make_msgw_widget_item(caption) 
		local text = Text{ text = caption, reactive = true,  ellipsize = "END", w=270}:set( WSTYLE )
		local stext = Text{ text = caption, reactive = true,  ellipsize = "END", w=270}:set( WSSTYLE )
		return text, stext
	end 

	cur_w= PADDING
    cur_h= PADDING 

	table.sort(allUiElements)

    for i, v in pairs(allUiElements) do 

		local widget_t, widget_ts = make_msgw_widget_item(v)
		local h_rect = Rectangle{border_width = 1, border_color = {0,0,0,255}, name="h_rect", color="#a20000", size = {298, 22}, reactive = true, opacity=0}
		h_rect.name = "h_rect"..i

		if i == 1 then 
			h_rect.opacity = 255
			selected_ui_element = v
		end

		h_rect.extra.focus = {[keys.Return] = "button_ok", [keys.Up]="h_rect"..(i-1), [keys.Down]="h_rect"..(i+1), [keys.Tab]=function() selected_ui_element = v tab_func() end}

		widget_t.position =  {cur_w, cur_h}
		widget_t.extra.rect = h_rect.name
		widget_ts.position =  {cur_w-1, cur_h-1}
		widget_ts.extra.rect = h_rect.name
		h_rect.position =  {cur_w - 12, cur_h-1}

    	widget_t.name = v
    	widget_t.reactive = true

		scroll.content:add(h_rect)
		scroll.content:add(widget_ts)
		scroll.content:add(widget_t)

		cur_h = cur_h + Y_PADDING

       function widget_t:on_button_down(x,y,button,num_click)
			selected_ui_element = widget_t.name 
			scroll:find_child(widget_t.extra.rect):on_button_down(x,y,button,num_click)
			return true
        end 
        function widget_ts:on_button_down()
			widget_t:on_button_down()
			return true
		end
		function h_rect.extra.on_focus_in()
			h_rect.opacity = 255
			h_rect:grab_key_focus()
		end
		function h_rect.extra.on_focus_out()
			h_rect.opacity = 0
		end
		function h_rect:on_button_down(x,y,button,num_click)
			for i,j in pairs (scroll.content.children) do 
				if j.type == "Rectangle" then 
					 j.opacity = 0
				end
			end
			
			h_rect.opacity = 255
			h_rect:grab_key_focus()
			selected_ui_element = widget_t.name 
			if button == 3 then 
				load_ui_element(selected_ui_element)
			end
			return true
        end 
		function h_rect:on_key_down(key)
			if h_rect.focus[key] then
				if type(h_rect.focus[key]) == "function" then
					h_rect.focus[key]()
				elseif screen:find_child(h_rect.focus[key]) then
					if h_rect.on_focus_out then
						h_rect.on_focus_out()
					end
					--screen:find_child(h_rect.focus[key]):grab_key_focus()
					if screen:find_child(h_rect.focus[key]).on_focus_in then
						selected_ui_element = v
						screen:find_child(h_rect.focus[key]).on_focus_in(key)
						if h_rect.focus[key] ~= "button_ok" then 
							scroll.seek_to_middle(0,screen:find_child(h_rect.focus[key]).y) 
						end
					end
				end
			end
			return true
		end
	end

	scroll.extra.focus = {[keys.Tab] = "button_cancel"}

	msgw.extra.lock = false
 	screen:add(msgw)
	util.create_on_button_down_f(msgw)	

	--Focus
	button_ok.active.opacity = 255
	button_ok.dim.opacity = 0
	scroll.on_focus_in()


	function xbox:on_button_down(x,y,button,num_clicks,textUIElement)
		screen:remove(msgw)
		msgw:clear() 
		current_inspector = nil
		current_focus = nil 
		if x then 
	    	input_mode = hdr.S_SELECT
		end 
		if textUIElement == nil then 
			screen.grab_key_focus(screen) 
		end
		return true
	end 

end 

local error_msg_map = {
	["001"] = function(str) return "Open", "Cancel", "", "","A project named \" "..str.." \" already exists.\nWould you like to open it?" end, 
 	["002"] = function(str) return "OK", "Cancel", "", "", "Before saving the screen, a project must be open." end,
 	["003"] = function(str) return "Save","Cancel", "", "", "You have unsaved changes. Save the file before closing?" end, 					
 	["004"] = function(str) return "Overwrite","Cancel", "", "", "A file named \" "..str.." \" already exists. Do you wish to overwrite it?" end, 
 	["005"] = function(str) return "OK", "Cancel", "Error", "Error", "A file name is required." end, 
 	["006"] = function(str) return "OK", "Cancel", "Error", "Error", "A guideline position is required." end, 
 	["007"] = function(str) return "OK", "Cancel", "Error", "Error", "Field \""..str.."\" is required." end, 
 	["008"] = function(str) return "OK", "Cancel", "Error", "Error", "There are no guidelines."  end, 
 	["009"] = function(str) return "Restore", "Ignore", "", "", "You have an auto-recover file for \""..str.."\". Would you like to restore the changes from that file?" end,
 	["010"] = function(str) return "OK", "Cancel", "Error", "Error", "This UI Element requires a minimum of "..str.." item(s)." end, 
 	["011"] = function(str) return "OK", "Cancel", "Error", "Error", "Field \""..str.."\" requires a numeric value." end, 		 
	["012"] = function(str) return "OK", "Cancel", "Error", "Error", "Invalid value for \""..str.."\" field." end,
 	["013"] = function(str) return "OK", "Cancel", "Error", "Error", "Invalid file name. \nFile name may contain alphanumeric and underscore characters only." end, 
 	["014"] = function(str) return "OK", "Cancel", "Error", "Error", "A project name is required." end, 
 	["015"] = function(str) return "OK", "Cancel", "Error", "Error", "Invalid file name. \n File extention must be .lua" end, 
	-- new error messages 
	["016"] = function(str) return "OK", "Cancel", "Error", "Error", "There is no selected object." end, 
	["017"] = function(str) return "OK", "Cancel", "Error", "Error", "Can't delete this object. Clone exists." end, 
}


function editor.error_message(error_num, str, func_ok, func_nok, inspector)
  	local WIDTH = 300
  	local HEIGHT = 150
    local PADDING = 13
	local TOP_BAR = 30
    local MSG_BAR = 80
    local BOTTOM_BAR = 40

    local TSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local MSTYLE = {font = "FreeSans Medium 14px" , color = {255,255,255,255}}
    local TSSTYLE = {font = "FreeSans Medium 14px" , color = "000000", opacity=50}
    local MSSTYLE = {font = "FreeSans Medium 14px" , color = "000000", opacity=50}

    local msgw_bg = assets("lib/assets/panel-new.png"):set{name = "save_file_bg", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={30, 30}, reactive = true}
	local title = Text {name = "title", text = "Save " }:set(TSTYLE)
	local title_shadow = Text {name = "title", text = "Save "}:set(TSSTYLE)
	local OK_label, Cancel_label 

	OK_label, Cancel_label, title.text, title_shadow.text, error_msg = error_msg_map[error_num](str) 
	
	local message = Text{text = error_msg, wrap = true, wrap_mode = "WORD",}:set(MSTYLE)
	local message_shadow = Text{text = error_msg, wrap = true, wrap_mode = "WORD",}:set(MSSTYLE)

--Buttons 
	local button_cancel, button_ok, button_nok

	editor_use = true
    if Cancel_label == "" then 
 		button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
     	skin = "default", ui_width = 100, ui_height = 27, label = OK_label, focus_color = {27,145,27,255}, active_button= true, focus_object = nil} 
	elseif func_nok then 
		button_nok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
  					skin = "default", ui_width = 100, ui_height = 27, label = "Don\'t Save", focus_color = {27,145,27,255}, focus_object = nil}
    	button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
  					skin = "default", ui_width = 75, ui_height = 27, label = Cancel_label, focus_color = {27,145,27,255}, focus_object = nil}
 		button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
     				skin = "default", ui_width = 75, ui_height = 27, label = OK_label, focus_color = {27,145,27,255}, active_button= true, focus_object = nil} 
 		-- Button Event Handlers
 		button_nok.pressed = function() func_nok(1) xbox:on_button_down() end
 	else
    	button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
  					skin = "default", ui_width = 100, ui_height = 27, label = Cancel_label, focus_color = {27,145,27,255}, focus_object = nil}
 		button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
     				skin = "default", ui_width = 100, ui_height = 27, label = OK_label, focus_color = {27,145,27,255}, active_button= true, focus_object = nil} 
 	end 
	editor_use = false
	
	button_ok:grab_key_focus() 


	-- Button Event Handlers
	if Cancel_label ~= "" then 
		button_cancel.pressed = function() if error_num == "009" then if func_ok then func_ok(str, "NOK") end end xbox:on_button_down() end 
	end 
	button_ok.pressed = function() if func_ok then func_ok(str, "OK") end xbox:on_button_down() end

	if func_nok then 
		button_nok.extra.focus = {[keys.Right] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_nok"}
 		button_cancel.extra.focus = {[keys.Left] = "button_nok", [keys.Right] = "button_ok", [keys.Tab] = "button_ok", [keys.Return] = "button_cancel"}
 		button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_nok", [keys.Return] = "button_ok"}
 	-- Button Position Set
 		button_nok:set{name = "button_nok", position = {WIDTH-button_cancel.w-button_ok.w-button_nok.w-3*PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}
 		button_cancel:set{name = "button_cancel", position = { WIDTH-button_cancel.w-button_ok.w-2*PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}} 
 		button_ok:set{name = "button_ok", position = { WIDTH-button_ok.w-PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}
 	elseif Cancel_label ~= "" then 
 	-- Focus Destination 
 		button_cancel.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok", [keys.Return] = "button_cancel"}
 		button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok"}
 	-- Button Position Set
 		button_cancel:set{name = "button_cancel", position = { WIDTH-button_cancel.w-button_ok.w-2*PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}} 
 		button_ok:set{name = "button_ok", position = { WIDTH-button_ok.w-PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}
	else 
 		button_ok.extra.focus = {[keys.Return] = "button_ok"}
 		button_ok:set{name = "button_ok", position = { WIDTH-button_ok.w-PADDING, HEIGHT-BOTTOM_BAR+PADDING/2}}
 	end 

	local tab_func = function()
		if button_nok or button_cancel then 
			button_ok.active.opacity = 0
			button_ok.dim.opacity = 255
		end 
		if button_nok then 
			button_nok:grab_key_focus()
			button_nok.on_focus_in()
		else 
			button_cancel:grab_key_focus()
			button_cancel.on_focus_in()
		end 
	end

	local msgw = Group {
		name = "msgw",  --ui_element_insert
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {PADDING,PADDING/3}, }, 
			title:set{position = {PADDING+1, PADDING/3+1}}, 
			message_shadow:set{position = {PADDING,TOP_BAR+PADDING}, width = WIDTH - 28, wrap= true, wrap_mode = "WORD"}, 
			message:set{position = {PADDING+1, TOP_BAR+PADDING+1}, width = WIDTH - 28, wrap= true, wrap_mode = "WORD"}, 
			button_ok, 
		}
		, scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}
	}

	local ti_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
		button_ok:grab_key_focus() 
	end

	if Cancel_label ~= "" then 
 		msgw:add(button_cancel) 
	end 

	if func_nok then 
 		msgw:add(button_nok) 
 	end 

	msgw.extra.lock = false
 	screen:add(msgw)
	util.create_on_button_down_f(msgw)	

	
	-- Focus 
	ti_func()

	function xbox:on_button_down()
		screen:remove(msgw)
		--msgw:clear() 
		current_inspector = nil
		current_focus = nil
        screen.grab_key_focus(screen) 
	    input_mode = hdr.S_SELECT
		if inspector then 
			inspector:remove(inspector:find_child("deactivate_rect"))
		end 
		return true
	end 

	button_ok:grab_key_focus() 
	return msgw
end

return editor
