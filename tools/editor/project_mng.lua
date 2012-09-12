--------------------------
-- Project Management  
--------------------------
local project_mng = {}

local home, base, app_path, project  
local projects = {}

local copy_dirs = {"/assets/"}
local copy_files = {"/.trickplay", "/lib/ui_element.lua", "/lib/ui_element_header.lua", "/lib/strings.lua", "/assets-cache.lua"} 

local project_window_deactivate = function (w)
		local rect = Rectangle {name = "deactivate_rect", color = {10,10,10,100}, size = {300,400}, position = {0,0}, reactive = true}
		w:add(rect)
	end 

local function copy_widget_imgs ()
	-- this function copys the UI Element library file, header file, 
	-- all the editor asset files including skins to the newly created 
	-- project directory.

	local source_files, source_file, dest_file, dest_dir

	for a, b in pairs (copy_dirs) do 
		source_files = editor_lb:readdir(trickplay.config.app_path..b)
		if source_files == nil then source_files = {} end 

		local k,l = string.find(b, "/assets/") 
	    dest_dir = "/lib/skins/"..string.sub(b,l+1, -1)
		if a == 1 then 
			dest_dir = "/lib"..b
		end 

		for i, j in pairs(source_files) do 
	     	source_file = trickplay.config.app_path..b..j 
			dest_file = current_dir..dest_dir..j 
	     	editor_lb:file_copy(source_file, dest_file) 
	    end 
	end 
	for a, b in pairs (copy_files) do 
		source_file = trickplay.config.app_path..b
		dest_file = current_dir..b
	 	editor_lb:file_copy(source_file, dest_file)
	end 
end 

local function set_new_project (pname, replace)

	projects = {}

	home = editor_lb:get_home_dir()
    assert( home )
    -- The base directory where the editor will store its files, make sure
    -- we are able to create it (or it already exists )
    
    base = editor_lb:build_path( home , "trickplay-editor"  )
    assert( editor_lb:mkdir( base ) )
    
    -- The list of files and directories there. We go through it and look for
    -- directories.
    local list = editor_lb:readdir( base ) 
	if list == nil then list = {} end 
    
    for i = 1 , #list do
      	if editor_lb:dir_exists( editor_lb:build_path( base , list[ i ] ) ) then
        	table.insert( projects , list[ i ] )
        end
    end

	if(pname~= "") then
    	project = pname
    	if #projects ~= 0 then
			for i, j in pairs (projects) do 
				if j == pname then 
					if replace == nil then 
						if j ~= "unsaved_project" then 
							editor.error_message("001", pname, set_new_project)  
							return 
					    end
					end  
				end 
			end 
		end 
	else 
		editor.error_message("014", pname, nil)  
		return
   	end   
	
   	app_path = editor_lb:build_path( base , project )
   
	if not editor_lb:mkdir( app_path ) then
        -- Tell the user we were not able to create it
   	     print("couldn't create ",app_path)  
    else
    	editor_lb:change_app_path( app_path )
	    current_dir = app_path
    end

  	local screens_path = editor_lb:build_path( app_path, "screens" )
    editor_lb:mkdir( screens_path ) 

    local asset_path = editor_lb:build_path( app_path, "assets" )
    editor_lb:mkdir( asset_path ) 

    local asset_images_path = editor_lb:build_path( asset_path, "images" )
    editor_lb:mkdir( asset_images_path ) 

	local asset_sounds_path = editor_lb:build_path( asset_path, "sounds" )
    editor_lb:mkdir( asset_sounds_path ) 
    
	local asset_videos_path = editor_lb:build_path( asset_path, "videos" )
    editor_lb:mkdir( asset_videos_path ) 

    local lib_path = editor_lb:build_path( app_path, "lib" )
    editor_lb:mkdir( lib_path ) 
    
	local lib_assets_path = editor_lb:build_path( lib_path, "assets" )
    editor_lb:mkdir( lib_assets_path ) 
    
	local lib_skins_path = editor_lb:build_path( lib_path, "skins" )
    editor_lb:mkdir( lib_skins_path ) 
    
	local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "CarbonCandy" )
    editor_lb:mkdir( lib_skins_default_path ) 
    
	copy_widget_imgs()
    
	local menu_text = menu_items.menu_text 

	menu_text.text = project .. " "
	menu_text.extra.project = project .. " "

	settings.project = project

end 

------------------------------------
-- project_mng.new_project 
------------------------------------

function project_mng.new_project(fname, from_new_project)

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

    local msgw_bg = Image{src = "lib/assets/panel-new.png", name = "ui_elements_insert", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={30, 30}, reactive = true}
	local title = Text {name = "title", text = "New Project" }:set(TSTYLE)
	local title_shadow = Text {name = "title", text = "New Project"}:set(TSSTYLE)
	local message = Text {text = "Project Name:"}:set(MSTYLE)
	local message_shadow = Text {text = "Project Name:"}:set(MSSTYLE)

	local func_ok = function() 
		editor.save(true,nil, project_mng.new_project, {fname, true})
		return
 	end 
	local func_nok = function() 
		project_mng.new_project(fname,true)
		return
	end 

	if #undo_list ~= 0 and from_new_project == nil then  
		-- if there are any changes since the last saving 
		editor.error_message("003", true, func_ok, func_nok) 
		return 
	end

	editor_use = true
	-- Text Input Field 	
	local text_input = ui_element.textInput{skin = "Custom", ui_width = WIDTH - 2 * PADDING , ui_height = 22 , text = "", padding = 5 , border_width  = 1,
		  border_color  = {255,255,255,255}, fill_color = {0,0,0,255}, focus_border_color = {255,0,0,255}, focus_fill_color = {50,0,0,255}, cursor_color = {255,255,255,255}, 
		  text_font = "FreeSans Medium 12px"  , text_color =  {255,255,255,255},
    	  border_corner_radius = 0,}

	-- Buttons 
   	local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
 		  skin = "default", ui_width = 100, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = text_input}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    	  skin = "default", ui_width = 100, ui_height = 27, label = "OK", focus_color = {27,145,27,255}, active_button= true, focus_object = text_input} 
	editor_use = false

	-- Button Event Handlers
	button_cancel.on_press = function() xbox:on_button_down() end 
	button_ok.on_press = function() 
							if text_input.text == "" or text_input.text == nil then 
								xbox:on_button_down() 
								editor.error_message("014", fname, project_mng.new_project)  
								return -1
							else 
								set_new_project(text_input.text) 
								xbox:on_button_down()
								undo_list = {}
								editor.close(true)
							end 
						end

	local ti_func = function()
		if current_focus then 
			current_focus.clear_focus()
		end 

		button_ok.extra.active.opacity = 255
		button_ok.extra.dim.opacity = 0

		text_input.set_focus()
	end

	local tab_func = function()
		text_input.clear_focus()

		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0

		button_cancel:grab_key_focus()
		button_cancel.set_focus()
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
		, scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}
	}

	msgw.extra.lock = false
 	screen:add(msgw)
	util.create_on_button_down_f(msgw)	
	ti_func()


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
		if text_input.focus[key] then
			if type(text_input.focus[key]) == "function" then
				text_input.focus[key]()
			elseif screen:find_child(text_input.focus[key]) then
				if text_input.clear_focus then
					text_input.clear_focus()
				end
				screen:find_child(text_input.focus[key]):grab_key_focus()
				if screen:find_child(text_input.focus[key]).set_focus then
					screen:find_child(text_input.focus[key]).set_focus(key)
				end
			end
		end
	end
end 

------------------------------------
-- project_mng.open_debugger 
------------------------------------

function project_mng.open_debugger()
	--editor_lb:execute("~/code/trickplay/sdk/trickplay-debugger "..current_dir) 
	editor_lb:execute(debugger_script.." "..current_dir) 
end 
------------------------------------
-- project_mng.open_project 
------------------------------------

function project_mng.open_project(t, msg, from_main, from_open_project)

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
    local SSTYLE = {font = "FreeSans Medium 14px" , color = {0,0,0,255}}
    local WSSTYLE = {font = "FreeSans Medium 14px" , color = "000000"}

	local msgw
	
	local func_ok = function() 
		editor.save(true,nil,project_mng.open_project,{nil,nil,nil,true})
		return
 	end 

	local func_nok = function() 
		project_mng.open_project(nil,nil,nil,true)
		return
	end 

	if #undo_list ~= 0 and from_open_project == nil then  
		editor.error_message("003", true, func_ok, func_nok) 
		return 
	end

    -- Get the user's home directory and make sure it is valid
    local home = editor_lb:get_home_dir()
    
    assert( home )
    
    -- The base directory where the editor will store its files, make sure
    -- we are able to create it (or it already exists )
    
    base = editor_lb:build_path( home , "trickplay-editor"  )

    assert( editor_lb:mkdir( base ) )

    if editor_lb:readdir( base ) == nil then 
		settings.project = nil
	end 
    
    -- The list of files and directories there. We go through it and look for
    -- directories.
    local list = editor_lb:readdir( base )
	if list == nil then list = {} end 
    
    for i = 1 , #list do
        if editor_lb:dir_exists( editor_lb:build_path( base , list[ i ] ) ) then
			if util.is_in_list(list[ i ], projects) == false then 
            	table.insert( projects , list[ i ])
			end 
        end
    end
    

	local function load_project(selected_prj)

		if selected_prj == nil or selected_prj == "" then 
			set_new_project("unsaved_project")
			return
		end

        project = selected_prj
	
        app_path = editor_lb:build_path( base , project )

		--project sub dir checking 

		local sub_dir_table = {}

		local screens_path = editor_lb:build_path( app_path, "screens" )
		table.insert(sub_dir_table,screens_path)
    	local asset_path = editor_lb:build_path( app_path, "assets" )
		table.insert(sub_dir_table,asset_path)

		local asset_images_path = editor_lb:build_path( asset_path, "images" )
		table.insert(sub_dir_table,asset_images_path)
    	local asset_sounds_path = editor_lb:build_path( asset_path, "sounds" )
		table.insert(sub_dir_table,asset_sounds_path)
		local asset_videos_path = editor_lb:build_path( asset_path, "videos" )
		table.insert(sub_dir_table,asset_videos_path)

    	local lib_path = editor_lb:build_path( app_path, "lib" )
		table.insert(sub_dir_table,lib_path)
		local lib_assets_path = editor_lb:build_path( lib_path, "assets" )
		table.insert(sub_dir_table,lib_assets_path)
		local lib_skins_path = editor_lb:build_path( lib_path, "skins" )
		table.insert(sub_dir_table,lib_skins_path)
		local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "CarbonCandy" )
		table.insert(sub_dir_table,lib_skins_default_path)

		for i, j in pairs (sub_dir_table) do 
			if not editor_lb:dir_exists(j) then 
				local temp_project = project 
				if current_dir == "" then 
					set_new_project("unsaved_project")
				end 
				editor.error_message("019", temp_project..","..j, nil, nil, msgw)  
				if msgw then 
					project_window_deactivate(msgw)
				end 
				return -1
			end 
		end 

        editor_lb:change_app_path( app_path )
	    current_dir = app_path
		
		screen:find_child("menu_text").text = project .. " "
		screen:find_child("menu_text").extra.project = project .. " "

		editor.close()
--[[
		if not (from_main and settings.project) then 
			settings.project = project
			xbox:on_button_down()
		end 
]]
		return true
	end 

	if from_main and settings.project then 

		load_project(settings.project)
		undo_list = {}

		local dir = editor_lb:readdir(current_dir.."/screens")

		if dir == nil then dir = {} end 

		for i, v in pairs(dir) do
			if v == "unsaved_temp.lua" then 
				if readfile("screens/"..v) ~= "" then 
					msg_window.inputMsgWindow_openfile(v) 
					editor_lb:writefile("screens/"..v, "", true)
					current_fn = "" 
				end 
			end 
		end 

		return 

	elseif from_main then 

		set_new_project("unsaved_project")
		editor.close(true)

		return 
	end 

	local virtual_height = 0
	
    --local msgw_bg = assets("/assets/panel-no-tabs.png")
    local msgw_bg = assets("lib/assets/panel-no-tabs.png"):set{name = "open_project", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={25, 25}, reactive = true}
	local title = Text{name = "title", text = "Open Project"}:set(STYLE)
	local title_shadow = Text {name = "title", text = "Open Project"}:set(SSTYLE)
	local selected_project, ss, nn
	-- Scroll	
	local scroll = editor_ui.scrollPane{}

	editor_use = true
	-- Buttons 
	local button_new = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    					  skin = "default", ui_width = 90, ui_height = 27, label = "New Project", focus_color = {27,145,27,255}, focus_object = scroll}

    local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    					  skin = "default", ui_width = 90, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = scroll}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255,},
    					  skin = "default", ui_width = 90, ui_height = 27, label = "OK", focus_color = {27,145,27,255},active_button =true, focus_object = scroll} 
	editor_use = false

	-- Button Event Handlers
	button_new.on_press = function() xbox:on_button_down(1)  project_mng.new_project() end
	button_cancel.on_press = function() xbox:on_button_down(1) end
	button_ok.on_press = function() 
		if selected_project == ss then 
			selected_project = nn 
		end 
		if load_project(selected_project) ~= -1 then 
			settings.project = project
			xbox:on_button_down(1)
			editor.close()
		end 
	end
	
	local s_func = function()
		if current_focus then 
			current_focus.clear_focus()
		end 
		button_ok.active.opacity = 255
		button_ok.dim.opacity = 0
		scroll.set_focus()
	end

	local tab_func = function()
		button_ok.active.opacity = 0
		button_ok.dim.opacity = 255
		button_new:grab_key_focus()
		button_new.set_focus()
	end

	--Focus Destination
	button_new.extra.focus = {[keys.Right] = "button_cancel", [keys.Tab] = "button_cancel",  [keys.Return] = "button_new", [keys.Up] = s_func}
	button_cancel.extra.focus = {[keys.Left] = "button_new", [keys.Right] = "button_ok", [keys.Tab] = "button_ok",  [keys.Return] = "button_cancel", [keys.Up] = s_func}
	button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = s_func}

	--editor_use = false
	
	msgw = Group {
		name = "msgw", 
		position ={650, 250},
	 	anchor_point = {0,0},
		reactive = true,
        children = {
        	msgw_bg,
	  		xbox:set{position = {275, 0}},
			title_shadow:set{position = {X_PADDING, 5}, opacity=255/2}, 
			title:set{position = {X_PADDING + 1, 6}}, 
			scroll:set{name = "scroll", position = {0, TOP_BAR+1}, reactive=true},
			button_new:set{name = "button_new", position = { WIDTH - button_new.w - button_cancel.w - button_ok.w - PADDING * 3/2,HEIGHT - BOTTOM_BAR + PADDING/2}}, 
			button_cancel:set{name = "button_cancel", position = { WIDTH - button_cancel.w - button_ok.w - PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}, 
			button_ok:set{name = "button_ok", position = { WIDTH - button_ok.w - PADDING/2,HEIGHT - BOTTOM_BAR + PADDING/2}}

		},
		scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}	
	}

	local function make_msgw_project_item(caption) 
		local text = Text{ text = caption, reactive = true, ellipsize = "END", w=270}:set( WSTYLE )
		local stext = Text{ text = caption, reactive = true, ellipsize = "END", w=270}:set( WSSTYLE )
		return text, stext
	end 

	cur_w= PADDING
    cur_h= PADDING 
	
	table.sort(projects)

	if #projects == 0 then 
		project_mng.new_project()
		return
	end 

    for i, v in pairs(projects) do 

		virtual_height = virtual_height + 22 

		local project_t, project_ts = make_msgw_project_item(v)
		local h_rect = Rectangle{border_width = 1, border_color = {0,0,0,255}, name="h_rect", color="#a20000", size = {298, 22}, reactive = true, opacity=0}
		h_rect.name = "h_rect"..i

		if i == 1 then 
			h_rect.opacity = 255
			selected_project = v
		end

		h_rect.extra.focus = {[keys.Return] = "button_ok", [keys.Up]="h_rect"..(i-1), [keys.Down]="h_rect"..(i+1), [keys.Tab] = function() selected_project = project_t.name tab_func() end }

		project_t.position =  {cur_w, cur_h}
		project_t.extra.rect = h_rect.name
		project_ts.position =  {cur_w-1, cur_h-1}
		project_ts.extra.rect = h_rect.name
		h_rect.position =  {cur_w - 12, cur_h-3}

    	project_t.name = v
    	project_t.reactive = true

		scroll.content:add(h_rect)
		scroll.content:add(project_ts)
		scroll.content:add(project_t)

		cur_h = cur_h + Y_PADDING

       function project_t:on_button_down(x,y,button,num_click)
			selected_project = project_t.name 
			scroll:find_child(project_t.extra.rect):on_button_down(x,y,button,num_click)
			return true
        end 
        function project_ts:on_button_down()
			project_t:on_button_down()
			return true
		end
		function h_rect.extra.set_focus()
			h_rect.opacity = 255
			h_rect:grab_key_focus()
		end
		function h_rect.extra.clear_focus()
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
			selected_project = project_t.name 
			if button == 3 then 
				if load_project(selected_project) ~= -1 then 
					settings.project = project
					xbox:on_button_down(1)
					editor.close()
				end 
			end
			return true
        end 
		function h_rect:on_key_down(key)
			if h_rect.focus[key] then
				if type(h_rect.focus[key]) == "function" then
					h_rect.focus[key]()
				elseif screen:find_child(h_rect.focus[key]) then
					if h_rect.clear_focus and h_rect.focus[key] ~= "button_ok"then
						h_rect.clear_focus()
					elseif  h_rect.focus[key] == "button_ok" then 
						msgw.extra.cur_f = h_rect
					end
					--screen:find_child(h_rect.focus[key]):grab_key_focus()
					if screen:find_child(h_rect.focus[key]).set_focus then
						selected_project = v
						ss = v
						nn = projects[ i + 1] 
						if key == keys.Return then 
							ss = nil 
						end 

						screen:find_child(h_rect.focus[key]).set_focus(key)
						if h_rect.focus[key] ~= "button_ok" then 
							scroll.seek_to_middle(0,screen:find_child(h_rect.focus[key]).y) 
						end
					end
				end
			end
			return true
		end
	end
	
	scroll.virtual_h = virtual_height + 25
	if scroll.virtual_h <= scroll.visible_h then 
			scroll.visible_w = 300
	end 

	scroll.extra.focus = {[keys.Tab] = "button_cancel"}
	msgw.extra.lock = false
 	screen:add(msgw)
    input_mode = hdr.S_POPUP

	util.create_on_button_down_f(msgw)	

	--Focus
	button_ok.active.opacity = 255
	button_ok.dim.opacity = 0
	scroll.set_focus()

	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(msgw)
		msgw:clear() 
		current_inspector = nil
		current_focus = nil 
		if x then 
	    	input_mode = hdr.S_SELECT
		end 
		screen.grab_key_focus(screen) 
		if textUIElement == nil then 
			screen.grab_key_focus(screen) 
		end

		return true
	end 

end 

return project_mng
