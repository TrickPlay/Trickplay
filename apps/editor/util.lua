----------
-- Utils 
-----------

local factory = ui.factory
local set_project_path 

function table_copy(t)
  	local t2 = {}
  	for k,v in pairs(t) do
    	t2[k] = v
  	end
  	return t2
end

function table_insert(t, val)
	if t then 
	    table.insert(t, val) 
	end 
	return t
end 

function table_move_up(t, itemNum)
	local prev_i, prev_j 
	for i,j in pairs (t) do 
		if i == itemNum then 
			if prev_i then 
		     	t[prev_i] = j 
		     	t[i] = prev_j 
		     	return
			else 
		     	return 
			end 
	    end 
	    prev_i = i 
	    prev_j = j 
	end 
end 

function table_move_down(t, itemNum)
	local i, j, next_i, next_j 
	for i,j in pairs (t) do 
		if i == itemNum then 
	    	next_i = i + 1 
		  	if t[next_i] then 
	     		next_j = t[next_i] 
	     		t[i] = next_j
	     		t[next_i] = j 
				return 
		  	else 
		     	return     
		  	end 
	     end 
	end 
	return     
end 

function table_remove_val(t, val)
	for i,j in pairs (t) do
		if j == val then 
		     table.remove(t, i)
		end 
	end 
	return t
end 

function table_removekey(table, key)
	local idx = 1	
	local temp_t = {}
	table[key] = nil
	for i, j in pairs (table) do 
		temp_t[idx] = j 
		idx = idx + 1 
	end 
	return temp_t
end

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function values(t) 
	local j = 0 
	return function () j = j+1 return t[j] end 
end 

function abs(a) if(a>0) then return a else return -a end end

function is_available(new_name)
    if(g:find_child(new_name) ~= nil) then 
	return false 
    else 
	return true
    end
end 

function is_lua_file(fn)
	local i, j = string.find(fn, ".lua")
	if (j == string.len(fn)) then
		return true
	else 
		return false
	end 
end 

function is_img_file(fn)
	local i, j = string.find(fn, ".png")
	if (j == string.len(fn)) then
		return true
	else 
		i, j = string.find(fn, ".jpg")
	if (j == string.len(fn)) then
		return true
    end

	return false
	end 
end 

function is_mp4_file(fn)
	local i, j = string.find(fn, ".mp4")
	if (j == string.len(fn)) then
		return true
	else 
		return false
	end 
end 

function is_in_list(item, list)
    if list == nil then 
        return false
    end 

    for i, j in pairs (list) do
		if item == j then 
			return true
		end 
    end 
    return false
end 

function need_stub_code(v)
    local lists = {"Button", "ButtonPicker", "RadioButtonGroup", "CheckBoxGroup", "MenuButton"}
    if v.extra then 
        if is_in_list(v.extra.type, lists) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 
end 

function is_this_widget(v)
    if v.extra then 
        if is_in_list(v.extra.type, uiElements) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 
end 

 
function is_this_container(v)
    if v.extra then 
        if is_in_list(v.extra.type, uiContainers) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 
end 

function clear_bg()
    BG_IMAGE_20.opacity = 0
    BG_IMAGE_40.opacity = 0
    BG_IMAGE_80.opacity = 0
    BG_IMAGE_white.opacity = 0
    BG_IMAGE_import.opacity = 0
    screen:find_child("menuButton_view").items[2]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[3]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[4]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[5]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[6]["icon"].opacity = 0
    screen:find_child("menuButton_view").items[7]["icon"].opacity = 0
end

function getObjnames()
    local obj_names = ""
    for i, v in pairs(g.children) do
		if obj_names ~= "" then 
			obj_names = obj_names..","
		end 
    	obj_names = obj_names..v.name
    end
    return obj_names
end

local project
local base
local projects = {}

local function copy_widget_imgs ()
	local copy_dirs = {"/assets/", "/assets/default/", "/assets/CarbonCandy/", "/assets/OOBE/", }
	local copy_files = {"/.trickplay", "/lib/ui_element.lua", "/lib/ui_element_header.lua", "/localized/strings.lua", } 
	local source_files, source_file, dest_file, dest_dir

	for a, b in pairs (copy_dirs) do 
		source_files = editor_lb:readdir(trickplay.config.app_path..b)
		local k,l = string.find(b, "/assets/") 
	    dest_dir = "/lib/skins/"..string.sub(b,l+1, -1)
		if a == 1 then 
			dest_dir = "/lib"..b
		end 
		for i, j in pairs(source_files) do 
	     	source_file = trickplay.config.app_path..b..j 
			dest_file = CURRENT_DIR..dest_dir..j 
			--print(source_file, dest_file)
	     	editor_lb:file_copy(source_file, dest_file) 
	    end 
	end 
	for a, b in pairs (copy_files) do 
		source_file = trickplay.config.app_path..b
		dest_file = CURRENT_DIR..b
	 	editor_lb:file_copy(source_file, dest_file)
	end 
end 

function set_new_project (pname, replace)
	if(pname~= "") then
    	project = pname

    	if table.getn(projects) ~= 0 then 
			for i, j in pairs (projects) do 
				if j == pname then 
					if replace == nil then 
						editor.error_message("001", pname, set_new_project)  
						return 
					end  
				end 
			end 
		end 
   	end   
	
   	app_path = editor_lb:build_path( base , project )
    if not editor_lb:mkdir( app_path ) then
        -- Tell the user we were not able to create it
   	     print("couldn't create ",app_path)  
    else
    	editor_lb:change_app_path( app_path )
	    CURRENT_DIR = app_path
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
    local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "default" )
    editor_lb:mkdir( lib_skins_default_path ) 
    local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "CarbonCandy" )
    editor_lb:mkdir( lib_skins_default_path ) 
    local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "OOBE" )
    editor_lb:mkdir( lib_skins_default_path ) 

	screen:find_child("menu_text").text = project .. " "
	screen:find_child("menu_text").extra.project = project .. " "

	copy_widget_imgs()
end 

--[ NEW PROJECT ... ]-- 

function new_project(fname)

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

	editor_use = true
	-- Text Input Field 	
	local text_input = ui_element.textInput{skin = "custom", ui_width = WIDTH - 2 * PADDING , ui_height = 22 , text = "", padding = 5 , border_width  = 1,
		  border_color  = {255,255,255,255}, fill_color = {0,0,0,255}, focus_color = {255,0,0,255}, focus_fill_color = {50,0,0,255}, cursor_color = {255,255,255,255}, 
		  text_font = "FreeSans Medium 12px"  , text_color =  {255,255,255,255},
    	  border_corner_radius = 0,}

	-- Buttons 
   	local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
 		  skin = "default", ui_width = 100, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = text_input}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    	  skin = "default", ui_width = 100, ui_height = 27, label = "OK", focus_color = {27,145,27,255}, active_button= true, focus_object = text_input} 
	editor_use = false

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down() end 
	button_ok.pressed = function() set_new_project(text_input.text) 
								   xbox:on_button_down()
							  	   if fname then 
										editor.save(true)
								   end 
						end

	local ti_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok:find_child("active").opacity = 255
		button_ok:find_child("dim").opacity = 0
		text_input.on_focus_in()
	end

	local tab_func = function()
		text_input.on_focus_out()
		button_ok:find_child("active").opacity = 0
		button_ok:find_child("dim").opacity = 255
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
		, scale = { screen.width/screen.display_size[1], screen.height /screen.display_size[2]}
	}

	msgw.extra.lock = false
 	screen:add(msgw)
	create_on_button_down_f(msgw)	
	-- Focus 
	ti_func()
	--text_input.on_focus_in()
	--button_ok:find_child("active").opacity = 255


	function xbox:on_button_down()
		screen:remove(msgw)
		msgw:clear() 
		current_inspector = nil
		current_focus = nil
        screen.grab_key_focus(screen) 
	    input_mode = S_SELECT
		return true
	end 

	function text_input:on_key_down(key)
		if key == keys.Tab then
		end
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

function open_project(t, msg)
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

    local msgw_bg = Image{src = "lib/assets/panel-no-tabs.png", name = "open_project", position = {0,0}}
    local xbox = Rectangle{name = "xbox", color = {255, 255, 255, 0}, size={25, 25}, reactive = true}
	local title = Text{name = "title", text = "Open Project"}:set(STYLE)
	local title_shadow = Text {name = "title", text = "Open Project"}:set(SSTYLE)
	local selected_project
	
    -- Get the user's home directory and make sure it is valid
    local home = editor_lb:get_home_dir()
    
    assert( home )
    
    -- The base directory where the editor will store its files, make sure
    -- we are able to create it (or it already exists )
    
    base = editor_lb:build_path( home , "trickplay-editor"  )

    assert( editor_lb:mkdir( base ) )
    
    -- The list of files and directories there. We go through it and look for
    -- directories.
    local list = editor_lb:readdir( base )
    
    if table.getn(projects) == 0 then 
    	for i = 1 , # list do
        	if editor_lb:dir_exists( editor_lb:build_path( base , list[ i ] ) ) then
            	table.insert( projects , list[ i ] )
        	end
    	end
    end 
    
    input_mode = S_POPUP

	local virtual_hieght = 0

	local function load_project(v)

		if v == nil then 
			return
		end

--[[
		if #g.children > 0 then 
			if current_fn == "" then 
				xbox:on_button_down()
				editor.error_message("003", nil, editor.save) 
				return 
			elseif #undo_list ~= 0 then  -- 마지막 저장한 이후로 달라 진게 있으면 
				xbox:on_button_down()
				editor.error_message("003", nil, editor.save) 
				return 
			end
		end 

]]
		editor.close()

		selected_prj = v
--
        if(selected_prj ~= "") then                      
           project = v
	       selected_prj = ""
        end   
	
        app_path = editor_lb:build_path( base , project )
        if not editor_lb:mkdir( app_path ) then
        -- Tell the user we were not able to create it
   	     	print("couldn't create ",app_path)  
        else
            editor_lb:change_app_path( app_path )
	     	CURRENT_DIR = app_path
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
        local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "default" )
        editor_lb:mkdir( lib_skins_default_path ) 
        local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "CarbonCandy" )
        editor_lb:mkdir( lib_skins_default_path ) 
        local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "OOBE" )
        editor_lb:mkdir( lib_skins_default_path ) 

	
		screen:find_child("menu_text").text = project .. " "
		screen:find_child("menu_text").extra.project = project .. " "

		copy_widget_imgs()

		--editor.close()
		xbox:on_button_down()
		return true
	end 

	-- Scroll	
	local scroll = editor_ui.scrollPane{}

	-- Buttons 
    local button_cancel = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255},
    					  skin = "default", ui_width = 100, ui_height = 27, label = "Cancel", focus_color = {27,145,27,255}, focus_object = scroll}
	local button_ok = editor_ui.button{text_font = "FreeSans Medium 13px", text_color = {255,255,255,255,},
    					  skin = "default", ui_width = 100, ui_height = 27, label = "OK", focus_color = {27,145,27,255},active_button =true, focus_object = scroll} 

	-- Button Event Handlers
	button_cancel.pressed = function() xbox:on_button_down(1) end
	button_ok.pressed = function() load_project(selected_project) end
	
	local s_func = function()
		if current_focus then 
			current_focus.on_focus_out()
		end 
		button_ok:find_child("active").opacity = 255
		button_ok:find_child("dim").opacity = 0
		scroll.on_focus_in()
	end

	--Focus Destination
	button_cancel.extra.focus = {[keys.Right] = "button_ok", [keys.Tab] = "button_ok",  [keys.Return] = "button_cancel", [keys.Up] = s_func}
	button_ok.extra.focus = {[keys.Left] = "button_cancel", [keys.Tab] = "button_cancel", [keys.Return] = "button_ok", [keys.Up] = s_func}

	--editor_use = false
	
	local msgw = Group {
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
			button_cancel:set{name = "button_cancel", position = { WIDTH - button_cancel.w - button_ok.w - 2*PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}, 
			button_ok:set{name = "button_ok", position = { WIDTH - button_ok.w - PADDING,HEIGHT - BOTTOM_BAR + PADDING/2}}
		}
,
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

    for i, v in pairs(projects) do 

		virtual_hieght = virtual_hieght + 22

		local project_t, project_ts = make_msgw_project_item(v)
		local h_rect = Rectangle{border_width = 1, border_color = {0,0,0,255}, name="h_rect", color="#a20000", size = {298, 22}, reactive = true, opacity=0}
		h_rect.name = "h_rect"..i

		if i == 1 then 
			h_rect.opacity = 255
			selected_project = v
		end

		h_rect.extra.focus = {[keys.Return] = "button_ok", [keys.Up]="h_rect"..(i-1), [keys.Down]="h_rect"..(i+1)}

		project_t.position =  {cur_w, cur_h}
		project_t.extra.rect = h_rect.name
		project_ts.position =  {cur_w-1, cur_h-1}
		project_ts.extra.rect = h_rect.name
		h_rect.position =  {cur_w - 12, cur_h-1}

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
			selected_project = project_t.name 
			if button == 3 then 
				load_project(selected_project)
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
						selected_project = v
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
	
	scroll.virtual_h = virtual_hieght
	if scroll.virtual_h <= scroll.visible_h then 
			scroll.visible_w = 300
	end 

	scroll.extra.focus = {[keys.Tab] = "button_cancel"}
	msgw.extra.lock = false
 	screen:add(msgw)
	create_on_button_down_f(msgw)	

	--Focus
	button_ok:find_child("active").opacity = 255
	button_ok:find_child("dim").opacity = 0
	scroll.on_focus_in()


	function xbox:on_button_down(x,y,button,num_clicks)
		screen:remove(msgw)
		msgw:clear() 
		current_inspector = nil
		current_focus = nil 
		if x then 
	    	input_mode = S_SELECT
		end 
		screen.grab_key_focus(screen) 
		if textUIElement == nil then 
			screen.grab_key_focus(screen) 
		end

		return true
	end 

end 

function set_app_path()

    -- Get the user's home directory and make sure it is valid
    local home = editor_lb:get_home_dir()
    
    assert( home )
    
    -- The base directory where the editor will store its files, make sure
    -- we are able to create it (or it already exists )
    
    base = editor_lb:build_path( home , "trickplay-editor"  )

    assert( editor_lb:mkdir( base ) )
    
    -- The list of files and directories there. We go through it and look for
    -- directories.
    local list = editor_lb:readdir( base )
    
    if table.getn(projects) == 0 then 
    for i = 1 , # list do
    
        if editor_lb:dir_exists( editor_lb:build_path( base , list[ i ] ) ) then
        
            table.insert( projects , list[ i ] )
            
        end
        
    end
    end 
    
    input_mode = S_POPUP

    printMsgWindow("Select Project : ", "projectlist")
    inputMsgWindow("projectlist")

    if screen:find_child("mouse_pointer") then 
		 screen:find_child("mouse_pointer"):raise_to_top()
    end

end 

selected_container = nil
selected_content = nil

function is_in_container_group(x_pos, y_pos) 
	for i, j in pairs (g.children) do 
	if j.x < x_pos and x_pos < j.x + j.w and j.y < y_pos and y_pos < j.y + j.h then 
		if j.extra then 
		    if is_this_container(j) then
		        return true 
		    end 
		end 
	end 
  	end 
  	return false 
end 

function find_container(x_pos, y_pos)
	for i, j in pairs (g.children) do 
		if j.x < x_pos and x_pos < j.x + j.w and j.y < y_pos and y_pos < j.y + j.h then 
			if j.extra then 
				if is_this_container(j) then
					return j, j.extra.type 
				end 
			end 
		end 
	end 
end 

function create_on_button_down_f(v)
	v.extra.selected = false
	local org_object, new_object 
	
	function v:on_button_down(x,y,button,num_clicks)
	   if (input_mode ~= S_RECTANGLE) then 
	   		if(v.name ~= "ui_element_insert" and v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw") then 
	     		if(input_mode == S_SELECT) and  (screen:find_child("msgw") == nil) then
	       			if (v.extra.is_in_group == true and control == false ) then 
		    			local p_obj = v.parent --find_parent(v)
                		if(button == 3) then -- imsi : num_clicks is not correct ! 
                		--if(button == 3 or num_clicks >= 2) then
                			editor.inspector(p_obj)
                    		return true
                		end 

	            		if(input_mode == S_SELECT and p_obj.extra.selected == false) then 
		     				editor.selected(p_obj)
	            		elseif (p_obj.extra.selected == true) then 
		     				editor.n_select(p_obj)
		    			end
	            		org_object = copy_obj(p_obj)
		    			if v.extra.lock == false then -- or  v.name =="inspector" then 
           	    			dragging = {p_obj, x - p_obj.x, y - p_obj.y }
		    			end 
           	    		return true
	      			else 
                		if(button == 3) then-- imsi : num_clicks is not correct ! 
		    		--if(button == 3 or num_clicks >= 2) then
                 			editor.inspector(v)
                    		return true
                		end 
	            		if(input_mode == S_SELECT and v.extra.selected == false) then 
								----kkkk
		     				editor.selected(v) 
							if(v.type == "Text") then 
			      				v:set{cursor_visible = true}
			      				v:set{editable= true}
     			    			v:grab_key_focus(v)
							end 

		    			elseif (v.extra.selected == true) then 
								if(v.type == "Text") then 
			      					v:set{cursor_visible = true}
			      					v:set{editable= true}
     			    				v:grab_key_focus(v)
								end 
								editor.n_select(v) 
	       				end
-----[[ 	SHOW POSSIBLE CONTAINERS
		    			if control == true then 
							editor_lb:set_cursor(52)

							--[[
							if(screen:find_child("mouse_pointer") ~= nil) then 
		     					screen:remove(screen:find_child("mouse_pointer"))
							end 
							mouse_pointer = CS_move
							mouse_pointer.extra.type = "move"
							mouse_pointer.position = {x - 10 ,y - 10 ,0}
							if(screen:find_child("mouse_pointer") == nil) then 
		     					screen:add(mouse_pointer)
							end 
							]]
							selected_content = v 
			
							local odr 
							for i,j in pairs (g.children) do 
								if j.name == v.name then 
									odr = i
								end 
							end 

							if odr then 
								for i,j in pairs (g.children) do 
									--print(j.name)
									if is_this_container(j) == true then 
										--print(j.name, "container")
										if i > odr then 
											j.extra.org_opacity = j.opacity
                       						j:set{opacity = 50}
										end 	
									elseif i ~= odr then  
										j.extra.org_opacity = j.opacity
                       					j:set{opacity = 50}
								end 
							end 
						end
					end 
-----]]]] 

		    -- Debugging : 841 

					if v.type ~= "Text" then 
						for i, j in pairs (g.children) do  
	           				if j.type == "Text" then 
	            				if not((x > j.x and x <  j.x + j.w) and (y > j.y and y <  j.y + j.h)) then 
									ui.text = j	
			  						if ui.text.on_key_down then 
	                  					ui.text:on_key_down(keys.Return)
			  						end 
		    					end
	           				end 
	        			end 
	    			end 
	    			org_object = copy_obj(v)
					if v.extra.lock == false then -- or v.name == "inspector" then 
        				dragging = {v, x - v.x, y - v.y }
					end
        			return true
				end
	    	elseif (input_mode == S_FOCUS) then 
				if (v.name ~= "inspector" and  v.name ~= "ui_element_insert") then 
		     		editor.selected(v)
		     		screen:find_child("text"..focus_type).text = v.name 
				end 
				input_mode = S_FOCUS
           		return true
            end
	   elseif( input_mode ~= S_RECTANGLE ) then 
			if v.extra.lock == false then --or v.name == inspector  then  
				dragging = {v, x - v.x, y - v.y }
           		return true
			end 
    	end
	end
end

	
	function v:on_button_up(x,y,button,num_clicks)
		if shift == true then 
			return 
		end 
		if (input_mode ~= S_RECTANGLE) then 
	   		if( v.name ~= "ui_element_insert" and v.name ~= "inspector" and v.name ~= "Code" and v.name ~= "msgw" ) then 
	    		if(input_mode == S_SELECT) and (screen:find_child("msgw") == nil) then
	    			if (v.extra.is_in_group == true) then 
						local p_obj = v.parent --find_parent(v)
						new_object = copy_obj(p_obj)
					    if(dragging ~= nil) then 
	            			local actor , dx , dy = unpack( dragging )
							if type(dx) == "number" then 
	            				new_object.position = {x-dx, y-dy}
							else 
								print("dx is function") 
							end 
							if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
								editor.n_select(v, false, dragging) 
								editor.n_select(new_object, false, dragging) 
								editor.n_select(org_object, false, dragging) 
                    			table.insert(undo_list, {p_obj.name, CHG, org_object, new_object})
							end 
	            			dragging = nil
	            		end 
		    		return true 
				elseif( input_mode ~= S_RECTANGLE) then  
	      	    	if(dragging ~= nil) then 
	       	       		local actor = unpack(dragging) 
		       			if (actor.name == "grip") then  -- scroll_window -> grip
							dragging = nil 
							return true 
		       			end 
	               		local actor , dx , dy = unpack( dragging )
		       			new_object = copy_obj(v)
	               		new_object.position = {x-dx, y-dy}
---[[ Content Setting 
		       			if is_in_container_group(x,y) then 
			     			local c, t = find_container(x,y) 
			     			if control == true then 
			       				if not is_this_container(v) or c.name ~= v.name then
			     					if c and t then 
				    					if (v.extra.selected == true and c.x < v.x and c.y < v.y) then 
			        						v:unparent()
											if t ~= "TabBar" then
			        							v.position = {v.x - c.x, v.y - c.y,0}
											end 
			        						v.extra.is_in_group = true
											if screen:find_child(v.name.."border") then 
			             						screen:find_child(v.name.."border").position = v.position
											end
											if screen:find_child(v.name.."a_m") then 
			             						screen:find_child(v.name.."a_m").position = v.position 
			        						end 
			        						if t == "ScrollPane" or t == "DialogBox" or  t == "ArrowPane" then 
			            						c.content:add(v) 
												v.x = v.x - c.content.x
												v.y = v.y - c.content.y
			        						elseif t == "LayoutManager" then 
				     							local col , row=  c:r_c_from_abs_position(x,y)
				     							c:replace(row,col,v) 
			        						elseif t == "TabBar" then 
												local x_off, y_off = c:get_offset()
												local t_index = c:get_index()

												if t_index then 
													v.x = v.x - x_off	
													v.y = v.y - y_off	
			            							c.tabs[t_index]:add(v) 
												end 
											elseif t == "Group" then 
												c:add(v)
			        						end 
			     	       				end 
				    				end 
			       				end 
								if(screen:find_child("mouse_pointer") ~= nil) then 
		     						screen:remove(screen:find_child("mouse_pointer"))
								end 
								editor_lb:set_cursor(68)
								--[[
								mouse_pointer = CS_pointer
								mouse_pointer.position = {x ,y  ,0}
								if(screen:find_child("mouse_pointer") == nil) then 
		     						screen:add(mouse_pointer)
		     						mouse_pointer.extra.type = "pointer"
								end 
								]]
			     			end 
			     			if screen:find_child(c.name.."border") and selected_container then 
								screen:remove(screen:find_child(c.name.."border"))
								screen:remove(screen:find_child(c.name.."a_m"))
								screen:remove(screen:find_child(v.name.."border"))
								screen:remove(screen:find_child(v.name.."a_m"))
								selected_content = nil
								selected_container = nil
			    			end 
		       			end 
---]] Content Setting 
		       			for i,j in pairs (g.children) do 
			     			if j.extra then 
				   				if j.extra.org_opacity then 
									j.opacity = j.extra.org_opacity
				   				end 
			     			end 
		       			end 
	
		       			local border = screen:find_child(v.name.."border")
		       			local am = screen:find_child(v.name.."a_m") 
		       			local group_pos
	       	       		if(border ~= nil) then 
		             		if (v.extra.is_in_group == true) then
			     				group_pos = get_group_position(v)
			     				if group_pos then 
									if border then border.position = {x - dx + group_pos[1], y - dy + group_pos[2]} end
	                     				if am then am.position = {am.x + group_pos[1], am.y + group_pos[2]} end
								end
		             		else 
	                     		border.position = {x -dx, y -dy}
			     				if am then 
	                     			am.position = {x -dx, y -dy}
			     				end
		             		end 
	                	end 
			
						if screen:find_child("menuButton_view").items[12]["icon"].opacity > 0 then  
						    for i=1, v_guideline,1 do 
			   					if(screen:find_child("v_guideline"..i) ~= nil) then 
			     					local gx = screen:find_child("v_guideline"..i).x 
			     					if(15 >= math.abs(gx - x + dx)) then  
									    new_object.x = gx
										v.x = gx + screen:find_child("v_guideline"..i).w 
										if (am ~= nil) then 
			     	     						am.x = am.x - (x-dx-gx)
										end
			     					elseif(15>= math.abs(gx - x + dx - new_object.w)) then
										new_object.x = gx - new_object.w  
										v.x = gx - new_object.w 
										if (am ~= nil) then 
			     	     						am.x = am.x - (x-dx+new_object.w - gx)
										end
			     					end 
			   					end 
		        			end 
							for i=1, h_guideline,1 do 
			   					if(screen:find_child("h_guideline"..i) ~= nil) then 
			      					local gy =  screen:find_child("h_guideline"..i).y 
			      					if(15 >= math.abs(gy - y + dy)) then 
									    new_object.y = gy
										v.y =gy + screen:find_child("h_guideline"..i).h 
										if (am ~= nil) then 
			     	     						am.y = am.y - (y-dy - gy) 
										end
			      						elseif(15>= math.abs(gy - y + dy - new_object.h)) then
											new_object.y = gy - new_object.h
											v.y =  gy - new_object.h 
											if (am ~= nil) then 
			     	     						am.y = am.y - (y-dy + new_object.h - gy)  
											end
			      						end 
			   						end
								end
							end 
		        			if(border ~= nil )then 
			     				border.position = v.position
							end 
							if(org_object ~= nil) then  
		           				if(new_object.x ~= org_object.x or new_object.y ~= org_object.y) then 
			     					editor.n_select(v, false, dragging) 
			     					editor.n_select(new_object, false, dragging) 
			     					editor.n_select(org_object, false, dragging) 
			     					v.extra.org_x = v.x + g.extra.scroll_x + g.extra.canvas_xf
			     					v.extra.org_y = v.y + g.extra.scroll_y + g.extra.canvas_f 
                    	     		table.insert(undo_list, {v.name, CHG, org_object, new_object})
			   					end
							end 
	            			dragging = nil
              	  		end
              	  		return true
	      			end 
             	end
	   		else 
	      		dragging = nil
          		return true
       		end
		end
	end
end

function get_group_position(child_obj)
     for i, v in pairs(g.children) do
          if g:find_child(v.name) then
	       if (v.type == "Group") then 
		    if(v:find_child(child_obj.name)) then
			return v.position 
		    end 
	       end 
          end
     end
end 
	
function set_obj (f, v)
      for i,j in pairs(attr_name_list) do 
           if v[j] then f[j] = v[j] end 
      end 
end 


function copy_obj (v)

      local new_map = {
	["Rectangle"] = function() new_obj = Rectangle{} return new_obj end, 
	["Text"] = function() new_obj = Text{} return new_obj end, 
	["Image"] = function() new_obj = Image{} return new_obj end, 
	["Clone"] = function() new_obj = Clone{} return new_obj end, 
	["Group"] = function() new_obj = Group{} return new_obj end, 
	["Video"] = function() new_obj = {} return new_obj end, 
      }
	
      local new_object = new_map[v.type]()

      set_obj(new_object, v)

      return new_object
end	


function make_attr_t(v)

  local attr_t
  local obj_type = v.type

  local function stringTotitle(str)
      local i,j = string.find(str,"_")
      if i then str = string.upper(str:sub(1,1))..str:sub(2,i-1).." "..string.upper(str:sub(i+1, i+1))..str:sub(i+2,-1)
      else str = string.upper(str:sub(1,1))..str:sub(2,-1)
      end

      i,j = string.find(str,"_") 
      if i then 
	    str = str:sub(1,i-1).." "..string.upper(str:sub(i+1, i+1))..str:sub(i+2,-1)
      end
	   
      if str == "Color" and v.type == "Rectangle" then 
          str = "Fill Color" 
      elseif str == "Color" and v.type == "Text" then 
          str = "Text Color" 
      elseif str == "Message Font" and v.extra.type == "ToastAlert" then 
          str = "Msg Font" 
      end 

      return str
  end

  local function stringToitem(str)
       local first = ""
       local second = ""
       local last

       local i, j = str:find("_")
       if i then 
       	first = str:sub(1,1)
       	last = str:sub(i+1,-1)
	i, j = last:find("_")
	if i then 
	    second = last:sub(1,1)
        end 
       end 
      
       return first..second
  end 

  local attr_map = {
	["tab_labels"] = function ()
		if v.extra.type == "TabBar" then 
		    table.insert(attr_t, {"tab_labels", v.tab_labels, "Tab Labels"})
		end
		end, 
	["items"] = function ()
		if v.extra.type == "ButtonPicker" then 
		    table.insert(attr_t, {"items", v.items, "Items"})
		else 
		    table.insert(attr_t, {"caption", "Menu Contents"})
		    table.insert(attr_t, {"items", v.items, "Items"})
		end 
		end,
	["scale"] = function()
		table.insert(attr_t, {"caption", "Scale"})
		local scale_t = v.scale
        	if scale_t == nil then
             		scale_t = {1,1} 
        	end
        	table.insert(attr_t, {"x_scale", scale_t[1], "X"})
        	table.insert(attr_t, {"y_scale", scale_t[2], "Y"})
		end,
	["x_rotation"] = function()
 		table.insert(attr_t, {"caption", "Angle Of Rotation About"})
        	local x_rotation_t = v.x_rotation 
        	local y_rotation_t = v.y_rotation 
        	local z_rotation_t = v.z_rotation 
        	table.insert(attr_t, {"x_angle", x_rotation_t[1], "X"})
        	table.insert(attr_t, {"y_angle", y_rotation_t[1], "Y"})
        	table.insert(attr_t, {"z_angle", z_rotation_t[1], "Z"})
		end,  
       ["clip"] = function()
                table.insert(attr_t, {"caption", "Clipping Region"})
                local clip_t = v.clip
                if clip_t == nil then
                     clip_t = {0,0 ,v.w, v.h}
                end
                table.insert(attr_t, {"cx", clip_t[1], "X"})
                table.insert(attr_t, {"cy", clip_t[2], "Y"})
                table.insert(attr_t, {"cw", clip_t[3], "W"})
                table.insert(attr_t, {"ch", clip_t[4], "H"})
		end,
        ["anchor_point"] = function()	
 		table.insert(attr_t, {"anchor_point", v.anchor_point,"Anchor Point"})
		end,
	["src"] = function()
        	table.insert(attr_t, {"caption", "Source Location"})
        	table.insert(attr_t, {"src", v.src,"Source"})
		end,
	["icon"] = function()
        	table.insert(attr_t, {"caption", "Icon Source"})
        	table.insert(attr_t, {"icon", v.icon,"Icon"})
		end,
	["color"] = function(j)
		table.insert(attr_t, {"caption", stringTotitle(j)})
             	local color_t = v[j] 
             	if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	end
	     	table.insert(attr_t, {j.."r", color_t[1], "R"})
            table.insert(attr_t, {j.."g", color_t[2], "G"})
            table.insert(attr_t, {j.."b", color_t[3], "B"})
       	    table.insert(attr_t, {j.."a", color_t[4], "A"})    
		end,
	["size"] = function(j)
		table.insert(attr_t, {"caption", stringTotitle(j)})
             	local size_t = v[j] 
             	if size_t == nil then 
                 	size_t = {0,0}
	     	end
             	local size_k = ""
             	if j:sub(1,1) ~= "s" then
                 	size_k = j:sub(1,1) 
             	end 
	     	table.insert(attr_t, {size_k.."w", size_t[1], "W"})
             	table.insert(attr_t, {size_k.."h", size_t[2], "H"})
		end,
	["pos"] = function(j)
		table.insert(attr_t, {"caption", stringTotitle(j)})
             	local pos_t = v[j] 
             	if pos_t == nil then 
                 	pos_t = {0,0,0,0}
	     	end
             	local pos_k = ""
             	if j:sub(1,1) ~= "p" then 
                 	pos_k = j:sub(1,1) 
             	end 
	     	table.insert(attr_t, {pos_k.."x", pos_t[1], "X"})
            table.insert(attr_t, {pos_k.."y", pos_t[2], "Y"})
		end,
	["focus"]= function()
 		if v.extra.focus then 
 		     table.insert(attr_t, {"focus", v.extra.focus, "Focus"})
 		else 
 		     table.insert(attr_t, {"focus", {"1","2","3","4","5"}, "Focus"})
 		end 
 		end, 
	["label"]= function()
		if v.extra.type == "ToastAlert" then 
		     table.insert(attr_t, {"caption", "Title"})
		else 
		     table.insert(attr_t, {"caption", "Label"})
		end 
        	table.insert(attr_t, {"label", v.label,"Label"})
		end,
	["empty_top_color"] = function()
		     table.insert(attr_t, {"caption", "Empty Bar"})
		     local color_t = v.empty_top_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Top Color"})
	     	     table.insert(attr_t, {"empty_top_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"empty_top_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"empty_top_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"empty_top_color".."a", color_t[4], "A"})    
		     end,
	["empty_bottom_color"] = function()
		     local color_t = v.empty_bottom_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Bottom Color"})
	     	     table.insert(attr_t, {"empty_bottom_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"empty_bottom_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"empty_bottom_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"empty_bottom_color".."a", color_t[4], "A"})    
		     end,
	["filled_top_color"] = function()
		     table.insert(attr_t, {"caption", "Filled Bar"})
		     local color_t = v.filled_top_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Top Color"})
	     	     table.insert(attr_t, {"filled_top_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"filled_top_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"filled_top_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"filled_top_color".."a", color_t[4], "A"})    

		     end,
	["filled_bottom_color"] = function()
		     local color_t = v.filled_bottom_color 
             	     if color_t == nil then 
                 	color_t = {0,0,0,0}
	     	     end
		     table.insert(attr_t, {"caption", "Gradient Bottom Color"})
	     	     table.insert(attr_t, {"filled_bottom_color".."r", color_t[1], "R"})
             	     table.insert(attr_t, {"filled_bottom_color".."g", color_t[2], "G"})
             	     table.insert(attr_t, {"filled_bottom_color".."b", color_t[3], "B"})
       	     	     table.insert(attr_t, {"filled_bottom_color".."a", color_t[4], "A"})   
		     end,
	["rows"] = function() 
                     table.insert(attr_t, {"rows", v.rows, "Rows"})
		     end,  	
	["visible_w"] = function ()
		     table.insert(attr_t, {"caption", "Visible"})
        	     table.insert(attr_t, {"visible_w", v.visible_w,"W"})
		     end, 
	["visible_h"] = function ()
        	     table.insert(attr_t, {"visible_h", v.visible_h,"H"})
		     end, 
	["virtual_w"] = function ()
		     table.insert(attr_t, {"caption", "Virtual"})
        	     table.insert(attr_t, {"virtual_w", v.virtual_w,"W"})
		     end, 
	["virtual_h"] = function ()
        	     table.insert(attr_t, {"virtual_h", v.virtual_h,"H"})
		     end, 
	["lock"]  = function ()
		     table.insert(attr_t, {"lock", v.extra.lock, "Lock"})
		     end,
	["font"] = function ()
             table.insert(attr_t, {"caption", "Font"})
			 table.insert(attr_t, {"font", v.font,"font"})
			 end,
	["text_font"] = function ()
             table.insert(attr_t, {"caption", "Text Font"})
			 table.insert(attr_t, {"text_font", v.text_font,"text_font"})
			 end,
	["message_font"] = function ()
             table.insert(attr_t, {"caption", "Message Font"})
			 table.insert(attr_t, {"message_font", v.message_font,"message_font"})
			 end,
	["title_font"] = function ()
             table.insert(attr_t, {"caption", "Title Font"})
			 table.insert(attr_t, {"title_font", v.title_font,"title_font"})
			 end,
  }
  
  local obj_map = {
       ["Rectangle"] = function() return {"border_color", "color", "border_width", "lock","x_rotation", "anchor_point", "opacity", "reactive", "focus"} end,
       ["Text"] = function() return {"color", "font", "wrap_mode", "lock", "x_rotation","anchor_point","opacity","reactive", "focus", } end,
       ["Image"] = function() return {"src", "clip","lock",  "x_rotation","anchor_point","opacity", "reactive", "focus",} end,
       ["Group"] = function() return {"lock", "scale","x_rotation","anchor_point","opacity", "reactive", "focus"} end,
       ["Clone"] = function() return {"lock", "scale","x_rotation","anchor_point","opacity", "reactive", "focus"} end,
       ["Button"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","reactive", "focus","label","border_color","fill_color", "focus_color","focus_fill_color","focus_text_color","text_color","text_font","border_width","border_corner_radius"} end,
       ["TextInput"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity", "reactive", "focus","border_color","fill_color", "focus_color","focus_fill_color","cursor_color","text_color","text_font","padding","border_width","border_corner_radius"} end,
       ["ButtonPicker"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","reactive","focus","border_color","fill_color","focus_color","focus_fill_color","focus_text_color","text_color","text_font","direction","selected_item","items",} end,
       ["MenuButton"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity", "reactive","focus","label","border_color","fill_color","focus_color","focus_fill_color", "focus_text_color","text_color","text_font","border_width","border_corner_radius","menu_width","horz_padding","vert_spacing","horz_spacing","vert_offset","background_color","separator_thickness","expansion_location","items"} end,
       ["CheckBoxGroup"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","reactive", "focus","fill_color","focus_color","focus_fill_color","text_color","text_font","box_color","box_width","direction","box_size","check_size","line_space","b_pos", "item_pos","items",} end,
       ["RadioButtonGroup"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity", "reactive", "focus", "button_color","focus_color","focus_fill_color","text_color","select_color","text_font","direction","button_radius","select_radius","line_space","b_pos", "item_pos","items",} end,

       ["TabBar"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","border_color","fill_color","focus_color","focus_fill_color", "focus_text_color","text_color", "label_color", "unsel_color","text_font","border_width","border_corner_radius", "font", "label_padding",  "tab_position", "display_width", "display_height",  "tab_labels", "arrow_sz", "arrow_dist_to_frame",} end,  
       ["ToastAlert"] = function() return {"lock", "skin","x_rotation", "anchor_point","opacity","icon","label","message","border_color","fill_color","title_color","title_font","message_color","message_font","border_width","border_corner_radius","on_screen_duration","fade_duration",} end,
       ["DialogBox"] = function() return {"lock", "skin","x_rotation","anchor_point","opacity","label","border_color","fill_color","title_color","title_font","border_width","border_corner_radius","title_separator_color","title_separator_thickness",} end,
       ["ProgressSpinner"] = function() return {"lock", "skin","style","x_rotation","anchor_point","opacity","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time", } end,
       ["ProgressBar"] = function() return {"lock", "skin","x_rotation","anchor_point", "opacity","border_color","empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","progress"} end,
       ["LayoutManager"] = function() return {"lock", "skin","x_rotation","anchor_point", "opacity","rows","columns","cell_size","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable",} end,
       ["ScrollPane"] = function() return {"lock", "skin", "visible_w", "visible_h",  "virtual_w", "virtual_h","opacity", "bar_color_inner", "bar_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness", "frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "horz_bar_visible", "box_color", "box_width"} end,  
       ["ArrowPane"] = function() return {"lock", "skin","visible_w", "visible_h",  "virtual_w", "virtual_h","opacity", "arrow_sz", "arrow_dist_to_frame", "arrows_visible", "arrow_color","box_color", "box_width"} end,  
   }
  
  if is_this_widget(v) == true  then
       obj_type = v.extra.type
	attr_t =
      {
             {"title", "Inspector : "..(v.extra.type)},
             {"caption", "Object Name"},
             {"name", v.name,"name"},
             {"x", math.floor(v.x + g.extra.scroll_x + g.extra.canvas_xf) , "X"},
             {"y", math.floor(v.y + g.extra.scroll_y + g.extra.canvas_f), "Y"},
             {"z", math.floor(v.z), "Z"},
      }
       if (v.extra.type ~= "ProgressSpinner" and v.extra.type ~= "LayoutManager" and v.extra.type ~= "ScrollPane" and v.extra.type ~= "MenuBar" ) and v.extra.type ~= "ArrowPane" then 
             table.insert(attr_t, {"ui_width", math.floor(v.ui_width), "W"})
             table.insert(attr_t, {"ui_height", math.floor(v.ui_height), "H"})
       end

  elseif v.type ~= "Video" then  --Rectangle, Image, Text, Group, Clone
	attr_t =
      {
             {"title", "Inspector : "..(v.type)},
             {"caption", "Object Name"},
             {"name", v.name,"name"},
             {"x", math.floor(v.x + g.extra.scroll_x + g.extra.canvas_xf) , "X"},
             {"y", math.floor(v.y + g.extra.scroll_y + g.extra.canvas_f), "Y"},
             {"z", math.floor(v.z), "Z"},
             {"w", math.floor(v.w), "W"},
             {"h", math.floor(v.h), "H"},
      }

  else -- Video 
      attr_t =
      {
             {"title", "Inspector : "..(v.type)},
             {"caption", "Object Name"},
             {"name", v.name,"name"},
             {"caption", "Source"},
             {"source", v.source, "Source Location"},
             {"caption", "View Port"},
             {"left", math.floor(v.viewport[1]), "X"},
             {"top", math.floor(v.viewport[2]), "Y"},
             {"width", math.floor(v.viewport[3]), "W"},
             {"height", math.floor(v.viewport[4]), "H"},
             {"volume", v.volume, "Volume"},
             {"loop", v.loop, "Loop"},
             {"button", "view code", "View code"},
             {"button", "apply", "OK"},
             {"button", "cancel", "Cancel"},
      }
      return attr_t 
  end 
  
  for i,j in pairs(obj_map[obj_type]()) do 
		
	if (j == "message") then 
	--print (j)
	end 
       	if attr_map[j] then
             attr_map[j](j)
        elseif type(v[j]) == "number" then 
	     if j ~= "progress" then 
                 table.insert(attr_t, {j, math.floor(v[j]), stringTotitle(j)})
	     else 
                 table.insert(attr_t, {j, v[j], stringTotitle(j)})
	     end
	elseif type(v[j]) == "string" then 
	     if j == "message" then 
             table.insert(attr_t, {"caption", stringTotitle(j)})
	     end 
             table.insert(attr_t, {j, v[j], stringTotitle(j)})
	elseif type(v[j]) == "boolean" then 
	     if j == "reactive" then 
		  if v.extra.reactive ~= nil then 
                       table.insert(attr_t, {j, v.extra.reactive, stringTotitle(j)})
		  else 
                       table.insert(attr_t, {j, true, stringTotitle(j)})
		  end 
	     else 
                  table.insert(attr_t, {j, v[j], stringTotitle(j)})
	     end 
	elseif string.find(j,"color") then
             attr_map["color"](j)
	elseif string.find(j,"size") then
             attr_map["size"](j)
	elseif string.find(j,"pos") then
             attr_map["pos"](j)
	elseif j == "hor_arrow_y"or j == "vert_arrow_x" then 
             table.insert(attr_t, {j, "nil", stringTotitle(j)})
	else
	     print("make_attr_t() : ", j, " 처리해 주세용~ ~")
	end 
   end 
 
   --table.insert(attr_t, {"opacity", v.opacity, "Opacity"})
   table.insert(attr_t, {"button", "view code", "View code"})
   table.insert(attr_t, {"button", "apply", "OK"})
   table.insert(attr_t, {"button", "cancel", "Cancel"})
   
   return attr_t
end

local input_t

function itemTostring(v, d_list, t_list)
    local itm_str  = ""
    local itm_str2 = ""
    local indent   = "\n\t\t"
    local b_indent = "\n\t"

    local w_attr_list =  {"ui_width","ui_height","skin","style","label","button_color","focus_color","text_color","text_font","border_width","border_corner_radius","reactive","border_color","padding","fill_color","title_color","title_font","title_separator_color","title_separator_thickness","icon","message","message_color","message_font","on_screen_duration","fade_duration","items","selected_item","overall_diameter","dot_diameter","dot_color","number_of_dots","cycle_time","empty_top_color","empty_bottom_color","filled_top_color","filled_bottom_color","progress","rows","columns","cell_size","cell_w","cell_h","cell_spacing","cell_timing","cell_timing_offset","cells_focusable","visible_w", "visible_h",  "virtual_w", "virtual_h", "bar_color_inner", "bar_color_outer", "empty_color_inner", "empty_color_outer", "frame_thickness", "frame_color", "bar_thickness", "bar_offset", "vert_bar_visible", "horz_bar_visible", "box_color", "box_width","menu_width","horz_padding","vert_spacing","horz_spacing","vert_offset","background_color","separator_thickness","expansion_location","direction", "f_color","box_size","check_size","line_space", "b_pos", "item_pos","select_color","button_radius","select_radius","tiles","content","text", "focus_fill_color", "focus_text_color","cursor_color", "ellipsize", "label_padding", "tab_position", "display_width", "display_height", "tab_spacing", "label_color", "unsel_color", "arrow_sz", "arrow_dist_to_frame", "arrows_visible arrow_color", "tab_labels", "tabs"}

    local nw_attr_list = {"color", "border_color", "border_width", "font", "text", "editable", "wants_enter", "wrap", "wrap_mode", "src", "clip", "scale", "source", "x_rotation", "y_rotation", "z_rotation", "anchor_point", "name", "position", "size", "opacity", "children","reactive","cursor_visible"}

    local group_list = {"name", "position", "scale", "anchor_point", "x_rotation", "y_rotation", "z_rotation", "opacity"}

    local widget_map = {
	["Button"] = function () return "ui_element.button"  end, 
	["TextInput"] = function () return "ui_element.textInput" end, 
	["DialogBox"] = function () return "ui_element.dialogBox" end, 
	["ToastAlert"] = function () return "ui_element.toastAlert" end,   
	["RadioButtonGroup"] = function () return "ui_element.radioButtonGroup" end, 
	["CheckBoxGroup"] = function () return "ui_element.checkBoxGroup"  end, 
	["ButtonPicker"] = function () return "ui_element.buttonPicker"  end, 
	["ProgressSpinner"] = function () return "ui_element.progressSpinner" end, 
	["ProgressBar"] = function () return "ui_element.progressBar" end,
	["LayoutManager"] = function () return "ui_element.layoutManager" end,
	["ScrollPane"] = function () return "ui_element.scrollPane" end, 
	["ArrowPane"] = function () return "ui_element.arrowPane" end, 
	["TabBar"] = function () return "ui_element.tabBar" end, 
	["MenuButton"] = function () return "ui_element.menuButton" end, 
   }

   local function add_attr (list, head, tail) 
       local item_string =""
       for i,j in pairs(list) do 
          if v[j] ~= nil then 
	      --if j == "src" and v.type == "Image" then 
		  --item_string = item_string..head..j.." = \"assets\/images\/"..v[j].."\""..tail
	      if j == "position" then 
		  item_string = item_string..head..j.." = {"..math.floor(v.x+g.extra.scroll_x + g.extra.canvas_xf)..","..math.floor(v.y+g.extra.scroll_y + g.extra.canvas_f)..","..v.z.."}"..tail
	      elseif j == "children" then 
                  local children = ""
		  for k,l in pairs(v.children) do
		      if (l ~= nil) then 
		      if k == 1 then
		         children = children..l.name
		      else 
		         children = children..","..l.name
		      end
		      end 
                  end 
		  item_string = item_string..head.."children = {"..children.."}"..tail
	      elseif j == "tab_labels" then 
		  	  local items = ""
		  	  for i,j in pairs(v.tab_labels) do 
				   items = items.."\""..j.."\", "
		  	  end
    		  item_string = item_string..head.."tab_labels = {"..items.."}"..tail
	      elseif j == "items" then 
		  local items = ""
		  if v.extra.type == "MenuButton" then 
		  	for i,j in pairs(v.items) do 
				items = items.."\t\t\t{type=\""..j["type"].."\","
				if j["string"] then 
					items = items.." string=\""..j["string"].."\","
				end
				if j["type"] == "item" then 
					items = items.." f=nil"
				end
				items = items.."},\n"
		  	end
    		  	item_string = item_string..head.."items = {\n"..items.."\t\t}"..tail
		  else 
		  	for i,j in pairs(v.items) do 
				items = items.."\""..j.."\", "
		  	end
    		  	item_string = item_string..head.."items = {"..items.."}"..tail
		  end 
	      elseif type(v[j]) == "number" then 
	          item_string = item_string..head..j.." = "..v[j]..tail 
	      elseif type(v[j]) == "string" then 
	          item_string = item_string..head..j.." = \""..v[j].."\""..tail 
	      elseif type(v[j]) == "boolean" then 
		  if j == "reactive" then 
		       if v.extra.reactive == nil then 
				v.extra.reactive = true
		       end 
		       item_string = item_string..head..j.." = "..tostring(v.extra.reactive)..tail
		  else 
	               item_string = item_string..head..j.." = "..tostring(v[j])..tail 
		  end 
	      elseif type(v[j]) == "table" then 
		  		if v.extra.type == "TabBar" and j == "tabs" then 
					item_string = item_string..head..j.."= {"
					for q,w in pairs (v[j]) do
						item_string = item_string.." Group{ children = {"
						for m,n in pairs (w.children) do
							item_string = item_string .. n.name..","
						end 
						item_string = item_string.."}},"
					end 
					item_string = item_string.."}"..tail
		  		elseif(type(v[j][1]) == "table") then  
					local tiles_name_table = {} 
					for m=1, v.rows, 1 do -- rows
						local tile_name_table = {}
						for i= 1,v.columns,1 do  --cols 
				   			local element = v.tiles[m][i]
				   			if element then 
				     			table.insert(tile_name_table, element.name)
				   			else 
				     			table.insert(tile_name_table, "nil")
				   			end 
						end 
		        		if table.getn(tile_name_table) ~= 0 then 
							table.insert(tiles_name_table, tile_name_table)
						end
					end 
	          		item_string = item_string..head..j.." = {"
					for m,n in pairs(tiles_name_table) do 
	          			item_string = item_string.." {"..table.concat(n,",").."},"
					end 
					item_string = item_string.."}"..tail
		  		else
	          		item_string = item_string..head..j.." = {"..table.concat(v[j],",").."}"..tail
		  		end 
	      elseif v[j].type == "Group" then 
		        item_string = item_string..head..j.."= Group { children = {"
			for m,n in pairs (v[j].children) do
				item_string = item_string .. n.name..","
			end 
			item_string = item_string.."} }"..tail
	      elseif type(v[j]) == "userdata" then 
		  item_string = item_string..head..j.." = "..v[j].name..tail 
	      else
	          print("--", j, " 처리해 주세용 ~")
	      end 
	  end 
       end 
       return item_string
    end 
  
 
    if (v.type == "Text") then
		v.cursor_visible = false
    elseif (v.type == "Image") then
		--if (v.clip == nil) then v.clip = {0, 0,v.w, v.h} end 
    elseif (v.type == "Clone") then
	 	src = v.source 
		if src ~= nil then 
	 		if is_in_list(src.name, d_list) == false then 
	     		if(t_list == nil) then 
					t_list = {src.name}
	     		else 
					table.insert(t_list, src.name) 
	     		end
        	end 
        end 
    elseif (v.type == "Group") and is_this_widget(v) == false then 
	 	local org_d_list = {}

	 	if(d_list ~= nil) then 
	     	for i,j in pairs (d_list) do 
		 		org_d_list[i] = j 
	     	end      
	 	end 

        for e in values(v.children) do
	     	result, done_list, todo_list, result2 = itemTostring(e, d_list, t_list)
	     	if(result ~= nil) then 
		 		itm_str = itm_str..result
	     	end
	     	if(result2 ~= nil) then 
		 		itm_str2 = result2..itm_str2
	     	end 
			
	     	d_list = done_list
	     	t_list = todo_list
	 	end
    end

    if (v.type == "Video") then
  	 itm_str = itm_str.."\nlocal "..v.name.." = ".."{"..indent..
         "name=\""..v.name.."\","..indent..
         "type=\""..v.type.."\","..indent..
         "source=\""..v.source.."\","..indent..
         "viewport={"..table.concat(v.viewport,",").."},"..indent..
         "loop = "..tostring(v.loop)..","..indent..
         "volume = "..v.volume..b_indent.."}\n"..b_indent

	 itm_str = itm_str.."mediaplayer:load("..v.name..".source)"..b_indent..
	 "mediaplayer.on_loaded = function(self) self:play() end"..b_indent..
	 "if ("..v.name..".loop == true) then"..b_indent..
     	 "     mediaplayer.on_end_of_stream = function(self) self:seek(0) self:play() end"..b_indent..
	 "else"..b_indent..
	 "     mediaplayer.on_end_of_stream = function(self) self:seek(0) end"..b_indent..
	 "end"..b_indent..
	 "mediaplayer:set_viewport_geometry("..v.name..".viewport[1], "..v.name..".viewport[2], "..v.name..".viewport[3], "..v.name..".viewport[4])"..b_indent..
	 "mediaplayer.volume = "..v.name..".volume\n\n"
	 itm_str = itm_str.."g.extra.video = "..v.name.."\n\n"

    elseif is_this_widget(v) == true then 	 
	 	if v.content then 
	    	for m,n in pairs (v.content.children) do
				itm_str= itemTostring(n) .. itm_str
	    	end 
	 	end 
	 	if v.tiles then 
	    	for m,n in pairs(v.tiles) do 
	          	for q,r in pairs(n) do 
					if r.name ~= "nil" then
		            	itm_str= itemTostring(r)..itm_str
					end 
	          	end 
	     	end 
	 	end 
	 	if v.tabs then 
	    	for q,w in pairs (v.tabs) do
	    		for m,n in pairs (w.children) do
					itm_str= itemTostring(n) .. itm_str
	    		end 
	    	end 
	 	end 
		
		if v.extra.type == "ScrollPane" or v.extra.type == "ArrowPane" then 
        	itm_str = itm_str.."\n"..v.name.." = "..widget_map[v.extra.type]()..b_indent.."{"..indent
		else 
        	itm_str = itm_str.."\nlocal "..v.name.." = "..widget_map[v.extra.type]()..b_indent.."{"..indent
		end 
	 	itm_str = itm_str..add_attr(w_attr_list, "", ","..indent)
	 	itm_str = itm_str:sub(1,-2)
        itm_str = itm_str.."}\n\n"
	 	itm_str = itm_str..add_attr(group_list, v.name..".", "\n")
    else 
         itm_str = itm_str.."\nlocal "..v.name.." = "..v.type..b_indent.."{"..indent
	 	 itm_str = itm_str..add_attr(nw_attr_list, "", ","..indent)
	 	 itm_str = itm_str:sub(1,-2)
         itm_str = itm_str.."}\n\n"
    end

    if v.extra then 
    if v.extra.focus then 
		
		local scroll_seek_to_line = ""
		for i, c in pairs(g.children) do
			if v.name == c.name then 
				break
			else 
				if c.extra then 
					if c.extra.type == "ScrollPane" or c.extra.type == "ArrowPane" then 
						for k, e in pairs (c.content.children) do 
							if e.name == v.name then 
								scroll_seek_to_line = "\t"..c.name..".seek_to_middle(0,screen:find_child("..v.name..".focus[key]).y)\n\t\t\t" 
							end 
						end 
					end 
				end
			end
    	end

		local focus_map = {["65362"] = function() return "keys.Up" end, 
						   ["65364"] = function() return "keys.Down" end, 
						   ["65361"] = function() return "keys.Left" end, 
						   ["65363"] = function() return "keys.Right" end, 
						   ["65293"] = function() return "keys.Return" end, 
						  }

		itm_str = itm_str..v.name.."\.extra\.focus = {" 
		for m,n in pairs (v.extra.focus) do 
			if type(n) ~= "function" then 
		     	itm_str = itm_str.."["..focus_map[tostring(m)]().."] = \""..n.."\", " 
			end 
		end 
		itm_str = itm_str.."}\n\n"

		itm_str = itm_str.."function "..v.name..":on_key_down(key)\n\t"
		.."if "..v.name..".focus[key] then\n\t\t" 
		.."if type("..v.name..".focus[key]) == \"function\" then\n\t\t\t"
		..v.name..".focus[key]()\n\t\t"
		.."elseif screen:find_child("..v.name..".focus[key]) then\n\t\t\t"
		.."if "..v.name..".on_focus_out then\n\t\t\t\t"
		..v.name..".on_focus_out(key)\n\t\t\t".."end\n\t\t\t" -- on_focus_out
		.."screen:find_child("..v.name..".focus[key]):grab_key_focus()\n\t\t\t"
		.."if ".."screen:find_child("..v.name..".focus[key]).on_focus_in then\n\t\t\t\t"
        .."screen:find_child("..v.name..".focus[key]).on_focus_in(key)\n\t\t\t"..scroll_seek_to_line.."end\n\t\t\t"
		.."end\n\t"
		.."end\n\t"
		.."return true\n"
        .."end\n\n"
    end 

    if v.extra.reactive ~= nil then 
	itm_str = itm_str..v.name.."\.extra\.reactive = "..tostring(v.extra.reactive).."\n\n" 
    end 

    if v.extra.timeline then 
	    itm_str = itm_str..v.name.."\.extra\.timeline = {" 
	    for m,n in pairs (v.extra.timeline) do 
	         itm_str = itm_str.."["..m.."] = { \n"
	         for q,r in pairs (n) do
	             itm_str = itm_str.."[\""..q.."\"] = "
		     if type(r) == "table" then 
		          itm_str = itm_str.."{"
		          for s,t in pairs (r) do
			      itm_str = itm_str..t..","
		          end 
		          itm_str = itm_str.."},"
		     else 
		          itm_str = itm_str..tostring(r).."," 
		     end
	         end
	         itm_str = itm_str.."},\n"
	    end 
	    itm_str = itm_str.."}\n\n"
    end 

    if v.extra.type == "ButtonPicker" then 
	if v.extra.focus then 
	    itm_str = itm_str..v.name..".focus[keys.Right] = "..v.name..".press_right\n"
	    itm_str = itm_str..v.name..".focus[keys.Left] = "..v.name..".press_left\n"
	end
    end

    end -- if v.extra then 

    if(d_list == nil) then  
	d_list = {v.name}
    else 
        table.insert(d_list, v.name) 
    end 


    -- 만약 문제가 된다면 Clone일 경 아래 조건문은 빼세요    
    if is_in_list(v.name, t_list) == true  then 
	return "", d_list, t_list, itm_str
    end 

    return itm_str, d_list, t_list, itm_str2
end


local msgw_focus = ""

function create_tiny_input_box(txt)
     	local box_g = Group {}
     	local box = factory.draw_tiny_ring()
     	local box_focus = factory.draw_tiny_focus_ring()
	box_g.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
	box_g:add(box)
	box_focus.opacity = 0 
	box_g:add(box_focus)
    	box_g:add(txt)

        function box_g.extra.on_focus_in()
		txt:grab_key_focus(txt)
		txt.cursor_visible = true
	        box.opacity = 0 
            	box_focus.opacity = 255
		msgw_focus = "input_b"
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
		txt.cursor_visible = false
        end

	return box_g
end 



local function create_small_input_box(txt)
     	local box_g = Group {}
     	local box = factory.draw_small_ring()
     	local box_focus = factory.draw_small_focus_ring()

		box_g.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
		box_g:add(box)
		box_focus.opacity = 0 
		box_g:add(box_focus)
    	box_g:add(txt)

        function box_g.extra.on_focus_in()
		txt:grab_key_focus(txt)
		txt.cursor_visible = true
	        box.opacity = 0 
            	box_focus.opacity = 255
		msgw_focus = "input_b"
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
		txt.cursor_visible = false
        end

	return box_g
end 



local function create_input_box()
     	local box_g = Group {}
        local input_l = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
              position = {25, 10}, text = project.."/screens/" } --hhhhhh
        input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" , ellipsize = "END",
        -- 0111 position = {input_l.w + 25, 10}, text = "" , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
        position = {input_l.w + 25, 10}, text = strings[""] , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
     	local box = factory.draw_ring()
     	local box_focus = factory.draw_focus_ring()
	box_g.name = "input_b"
        box.position  = {0,0}
        box.reactive = true
        box.opacity = 255
	box_g:add(box)
	box_focus.opacity = 0 
	box_g:add(box_focus)
    	box_g:add(input_l)
    	box_g:add(input_t)

        function box_g.extra.on_focus_in()
		input_t:grab_key_focus(input_t)
	        box.opacity = 0 
            	box_focus.opacity = 255
		msgw_focus = "input_b"
		input_t.cursor_visible = true
        end

        function box_g.extra.on_focus_out()
	        box.opacity = 255 
            	box_focus.opacity = 0
		input_t.cursor_visible = false
        end

	return box_g
end 

--------------------------------
-- Message Window 
--------------------------------

local  msgw = Group {
	     name = "msgw",
		 --[[
	     position ={400, 400},
	     anchor_point = {0,0},
             children =
             {
             }
		]]
     }
local msgw_cur_x = 25  
local msgw_cur_y = 50

function cleanMsgWindow()
     msgw_cur_x = 25
     msgw_cur_y = 50
	 local msgw = screen:find_child("msgw")
     screen:remove(msgw)
     input_mode = S_SELECT
end 

local projectlist_len 
local selected_prj 	= ""


function printMsgWindow(txt, name)
     if (name == nil) then
        name = "pritMsgWindow"
     end

     txt_sz = string.len(txt) 
     local n = table.getn(projects)
  
     if n == 0 then 
     	txt = "New Project : "
     	name = ""
     end 
 
     if (name == "aleady_exists" ) then
		txt_sz = txt_sz - 50
     elseif(name == "projectlist") then  
     	projectlist_len = n * 45 
		txt_sz = projectlist_len + 20  
		if (n > 14) then 
			msgw.position = {400, 100}
		elseif (n > 10) then 
			msgw.position = {400, 200}
		elseif (n > 5) then 
			msgw.position = {400, 300}
		end 
     else 
     	i, j = string.find(txt, "\n")
     	if (j ~= nil) then 
	     txt_sz = txt_sz + 20 
        end 
     end 
     local msgw_bg = factory.make_popup_bg("msgw", txt_sz)
     if msgw_bg.Image then
  	 	msgw_bg= msgw_bg:Image()
     end

     msgw:add(msgw_bg)
     input_mode = S_POPUP
     local textText = Text{name= name, text = txt, font= "DejaVu Sans 32px",
     color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}
     msgw:add(textText)     
     textText:grab_key_focus()
  

     if(name == "projectlist") then  
         msgw_cur_x = msgw_cur_x + string.len(txt) * 20
	 
     	 for i, j in pairs (projects) do  
	     --local prj_text = Text {text = j, color = {255,255,255,255}, font= "DejaVu Sans 32px", color = "FFFFFF"}
	     local prj_text = Text {text = j, color = DEFAULT_COLOR, font= "DejaVu Sans 32px", color = "FFFFFF"}
	     prj_text.reactive = true
	     prj_text.position = {msgw_cur_x, msgw_cur_y+10}
	     prj_text.extra.index = i 
	     prj_text.name = "prj"..i 
	     msgw:add(prj_text)
	     msgw_cur_y = msgw_cur_y + 32 + 10 -- 10 : line padding 

	     function prj_text.extra.on_focus_in()
                  prj_text:set{color = {0,255,0,255}}
	 	  prj_text:grab_key_focus()
		  msgw_focus = prj_text.name
             end
    
             function prj_text.extra.on_focus_out()
                  prj_text:set{color = {255,255,255,255}}
             end

	     function prj_text:on_key_down(key)
			if(key == keys.Return) then 
		     if( selected_prj == prj_text.name) then 
			selected_prj = ""
			prj_text.extra.on_focus_in()
		     else
			if( selected_prj ~= "") then  
			    if(msgw:find_child(selected_prj) ~= nil) then 
				msgw:find_child(selected_prj):set{color = {255,255,255,255}} 
			    end 
			end 
			selected_prj = prj_text.name
		     end 
			elseif(key == keys.Tab and shift == false) or (key == keys.Down) or key == keys.Right then 
			prj_text.extra.on_focus_out()
			if(prj_text.name == selected_prj) then
			     prj_text:set{color = {0,255,0,255}}
			end 
			if (prj_text.extra.index < n) then 
				local k = prj_text.extra.index + 1
				msgw:find_child("prj"..k).extra.on_focus_in()
			else 
				msgw:find_child("input_b").extra.on_focus_in()
			end 
			elseif(key == keys.Tab and shift == true) or key == keys.Up or key == keys.Left then 
			if (prj_text.extra.index > 1) then 
				prj_text.extra.on_focus_out()
				if(prj_text.name == selected_prj) then
			     	     	prj_text:set{color = {0,255,0,255}}
				end 
				local k = prj_text.extra.index - 1
				msgw:find_child("prj"..k).extra.on_focus_in()
			end 
			end 
			return true 
	     end 

	     function prj_text:on_button_down(x,y,button,num)
	         if( selected_prj ~= "") then  
		      if(msgw:find_child(selected_prj) ~= nil) then 
		           msgw:find_child(selected_prj):set{color = {255,255,255,255}} 
	              end 
		 	end 
	         msgw:find_child(msgw_focus).extra.on_focus_out()
		 	prj_text.extra.on_focus_in()
		 	selected_prj = prj_text.name
		 	msgw_focus = prj_text.name --1102
	     end 

	     if (i == 1) then msgw_focus = prj_text.name project = prj_text.text end 

         end 
     end 
end

function inputMsgWindow_savefile(input_text, cfn, save_current_file)

     local global_section_contents, new_contents, global_section_footer_contents
     local file_not_exists = true
     local screen_dir = editor_lb:readdir(CURRENT_DIR.."/screens/")
     local main_dir = editor_lb:readdir(CURRENT_DIR)
     local enter_gen_stub_code = false

	 if cfn ~= "OK" and save_current_file == nil then 
     	for i, v in pairs(screen_dir) do
          if(input_text == v)then
			cleanMsgWindow()
			editor.error_message("004",input_text,inputMsgWindow_savefile)
			return 
          end
		end
	end 

      -- main generation
    if (file_not_exists or cfn) then
	   	local main_exist = false
	   	local app_exist = false

	   	local a, b = string.find(input_text,"screens") 
	   	if a then 
			input_text = string.sub(input_text, 9, -1)
	   	end 

	   	local fileUpper= string.upper(string.sub(input_text, 1, -5))
	   	local fileLower= string.lower(string.sub(input_text, 1, -5))
	
	   	local function gen_stub_code (grp) 

		
		new_contents="--  "..fileUpper.." SECTION\ngroups[\""..fileLower.."\"] = Group() -- Create a Group for this screen\nlayout[\""..fileLower.."\"] = {}\nloadfile(\"\/screens\/"..input_text.."\")(groups[\""..fileLower.."\"]) -- Load all the elements for this screen\nui_element.populate_to(groups[\""..fileLower.."\"],layout[\""..fileLower.."\"]) -- Populate the elements into the Group\n\n"

		for i, j in pairs (grp.children) do 
		     local function there() 
		     if need_stub_code(j) == true then 
	                   new_contents = new_contents.."-- "..fileUpper.."\."..string.upper(j.name).." SECTION\n" 	--SECTION \n\n		
			   if j.extra.type == "Button" then 
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.focused = function() -- Handler for "..j.name.."\.focused in this screen\nend\n"
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.pressed = function() -- Handler for "..j.name.."\.pressed in this screen\nend\n"
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.released = function() -- Handler for "..j.name.."\.released in this screen\nend\n"
			   elseif j.extra.type == "ButtonPicker" or j.extra.type == "RadioButtonGroup" then 
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.rotate_func = function(selected_item) -- Handler for "..j.name.."\.rotate_func in this screen\nend\n"
			   elseif j.extra.type == "CheckBoxGroup" then 
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.rotate_func = function(selected_items) -- Handler for "..j.name.."\.rotate_func in this screen\nend\n"
			   elseif j.extra.type == "MenuButton" then 
			   	for k,l in pairs (j.items) do 
			   	     if l["type"] == "item" then 
	                   			--new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.items["..k.."][\"f\"] = function() end -- Handler for in this menu button\n"
	                   			new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.items["..k.."][\"f\"] = function() end -- Handler for the menuButton Item, "..l["string"].."\n"
			   	     end 
			   	end 
			   end 
	                   new_contents = new_contents.."-- END "..fileUpper.."\."..string.upper(j.name).." SECTION\n\n" 			
		     else -- qqqq if j 가 컨테이너 이며는 그속을 다 확인하여 스터브 코드가 필요한 것을 가려내야함. 흐미..   
			   if is_this_container(j) == true then 
				if j.extra.type == "TabBar" then 
					for q,w in pairs (j.tabs) do
						gen_stub_code(w)
					end
				elseif j.extra.type == "ScrollPane" or j.extra.type == "DialogBox" or j.extra.type == "ArrowPane" then 
					gen_stub_code(j.content)
			    elseif j.extra.type == "LayoutManager" then 
					local content_num = 0 
			        	for k,l in pairs (j.tiles) do 
						for n,m in pairs (l) do 
							if m then 
								j = m 
								there()
							end 
						end 
					end 
				elseif j.extra.type == "Group" then  
					gen_stub_code(j)
				end

			   end 
		     end 
		     end 
		     there()	  
		end 

		if enter_gen_stub_code == false then 
			new_contents = new_contents.."-- END "..fileUpper.." SECTION\n\n" 
			enter_gen_stub_code =true
		end 
	   end 
     	   for i, v in pairs(main_dir) do
          	if("main.lua" == v)then
			local main = readfile("main.lua")
			local added_stub_code = ""
			if string.find(main, "-- "..fileUpper.." SECTION") == nil then 
				-- 적당한 위치 찾아서 이 파일에 대한 내용을 넣어주기만 하면됨 이건 쉽지. 
				local q,w,main_first, main_last
				q, w = string.find(main, "-- END GLOBAL SECTION\n\n")
				gen_stub_code(g)
				if w~=nil then 
					 main_first = string.sub(main, 1, w)
					 main_last = string.sub(main, w+1, -1)
				end
				if new_contents then 
					main = ""
					main = main_first..new_contents..main_last
					editor_lb:writefile("main.lua",main, true)
				end 
			end 
		    main_exist = true
		end 
		if ("app" == v) then 
			app_exist = true
		end 
	   end 

	   --print(main_exist)

	   if main_exist == false then 
		-- main.lua 생성해서 

		global_section_contents = "function main()\n-- GLOBAL SECTION\nui_element = dofile(\"\/lib\/ui_element.lua\") --Load widget helper library\nlayout = {} --Table containing all the UIElements that make up each screen\ngroups = {} --Table of groups of the UIElements of each screen, each of which can then be ui_element.screen_add()ed\n-- END GLOBAL SECTION\n\n"
	        gen_stub_code(g)

		local screen_mouse_code = "\n-- SCREEN ON_MONTION SECTION\nfunction screen:on_motion(x,y)\n\tif(screen:find_child(\"user_mouse_pointer\") == nil) then\n\t\tscreen:add(user_mouse_pointer)\n\tend\n\tuser_mouse_pointer.position = {x-15 ,y-10 ,0}\n\tuser_mouse_pointer:raise_to_top()\n\tif dragging then\n\t\tlocal actor = unpack(dragging)\n\t\tif (actor.name == \"grip\") then\n\t\t\tlocal actor,s_on_motion = unpack(dragging)\n\t\t\ts_on_motion(x, y)\n\t\t\treturn true\n\t\tend\n\t\treturn true\n\tend\nend\n-- END SCREEN ON_MONTION SECTION\n\n-- SCREEN ON_BUTTON_UP SECTION\nfunction screen:on_button_up()\n\tif dragging then\n\t\tdragging = nil\n\tend\nend\n-- END SCREEN ON_BUTTON_UP SECTION\n"

		global_section_footer_contents="-- GLOBAL SECTION FOOTER \nscreen:grab_key_focus()\nscreen:show()\nscreen.reactive = true\n\nui_element.screen_add(groups[\""..fileLower.."\"])\n\n-- SCREEN ON_KEY_DOWN SECTION\nfunction screen:on_key_down(key)\nend\n-- END SCREEN ON_KEY_DOWN SECTION\n"..screen_mouse_code.."\n-- END GLOBAL SECTION FOOTER \nend\n\ndolater( main )\n"

		editor_lb:writefile("main.lua", global_section_contents, true)
		editor_lb:writefile("main.lua", new_contents, false)
		editor_lb:writefile("main.lua", global_section_footer_contents, false)
	   end 
	   if app_exist == false then 
		local app_contents = "app=\n{\tid = \"com.trickplay.editor\",\n\trelease = \"1\",\n\tversion = \"1.0\",\n\tname = \"TrickPlay\",\n\tcopyright = \"Trickplay Inc.\"\n}"
		editor_lb:writefile("app", app_contents, true)
	   end 
	 
           current_fn = "screens/"..input_text
           editor_lb:writefile(current_fn, contents, true)
	   screen:find_child("menu_text").text = screen:find_child("menu_text").extra.project .. "/" ..current_fn
           contents = ""
	   cleanMsgWindow()
           screen:grab_key_focus(screen) 
      end
      menu_raise_to_top()

end -- end of inputMsgWindow_savefile  

function make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     
     local x_scroll_box, y_scroll_box 
     local x_scroll_bar, y_scroll_bar 

     if(x_scroll_to == 0)then 
	 x_scroll_to = screen.w
     end
     if(y_scroll_to == 0)then 
	 y_scroll_to = screen.h
     end

     g.extra.canvas_h = y_scroll_to - y_scroll_from -- y 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_w = x_scroll_to - x_scroll_from -- x 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_f = y_scroll_from
     g.extra.canvas_xf = x_scroll_from
     g.extra.canvas_t = y_scroll_to
     g.extra.canvas_xt = x_scroll_to

     screen_rect =  Rectangle{
                name="screen_rect",
                border_color= {2, 25, 25, 140},
                border_width=2,
                color= {255,255,255,0},
                size = {screen.w+1,screen.h+1},
                position = {0,0,0}, 
     }
     screen_rect.reactive = false
     g:add(screen_rect)


     
    if (g.extra.canvas_w > screen.w) then 
	local SCROLL_X_POS = 10
	local BOX_BAR_SPACE = 6
	
        x_scroll_box = factory.make_x_scroll_box()
        x_scroll_bar = factory.make_x_scroll_bar(g.extra.canvas_w)

	x_scroll_box.position = {SCROLL_X_POS, screen.h - 60}
	x_scroll_bar.position = {SCROLL_X_POS + BOX_BAR_SPACE, screen.h - 56}

	
        x_scroll_bar.extra.org_x = 16
	x_scroll_bar.extra.h_x = 16
	x_scroll_bar.extra.l_x = x_scroll_box.x + x_scroll_box.w - x_scroll_bar.w - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(x_scroll_box) 
	screen:add(x_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dx = ((g.extra.canvas_w - screen.w)/(x_scroll_bar.extra.l_x - x_scroll_bar.extra.h_x))

		
	local x0 = - g.extra.canvas_xf/g.extra.scroll_dx + 10 
	local x1920 = (-g.extra.canvas_xf+1080)/g.extra.scroll_dx + 10

	x_0_mark= Rectangle {
		name="x_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x0, screen.h - 55, 0},
		opacity = 255
        }

	x_1920_mark= Rectangle {
		name="x_1920_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x1920, screen.h - 55, 0},
		opacity = 255
        }
  
	screen:add(x_0_mark)
	screen:add(x_1920_mark) 

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_x = m.x
	end 
         
        function x_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {x_scroll_bar, x-x_scroll_bar.x, y-x_scroll_bar.y }

		if table.getn(selected_objs) ~= 0 then
		     for q, w in pairs (selected_objs) do
			 local t_border = screen:find_child(w)
			 local i, j = string.find(t_border.name,"border")
		         local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		         if(t_obj ~= nil) then 
			      screen:remove(screen:find_child(t_obj.name.."a_m"))
			 end
		     end
		end

        	return true
    	end 

    	function x_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_x <= x-dx and x-dx <= actor.extra.l_x) then -- 스크롤 되는 범위안에 있으면	
	           		dif = x - dx - x_scroll_bar.extra.org_x -- 스크롤이 이동한 거리 
	           		x_scroll_bar.x = x - dx 
	      		elseif (actor.extra.h_x > x-dx ) then
				dif = actor.extra.h_x - x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.h_x
	      		elseif (actor.extra.l_x < x-dx ) then
				dif = actor.extra.l_x- x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.l_x
			end 
			dif = dif * g.extra.scroll_dx -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.extra.org_x-dif-x_scroll_from, j.y, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.x = t_obj.x 
				 end
			     end
			end

			g.extra.scroll_x = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 


     if(g.extra.canvas_h > screen.h) then 


	local SCROLL_Y_POS = 90
	local BOX_BAR_SPACE = 6

	y_scroll_box = factory.make_y_scroll_box()
        y_scroll_bar = factory.make_y_scroll_bar(g.extra.canvas_h) 

	y_scroll_box.position = {screen.w - 60, SCROLL_Y_POS}
	y_scroll_bar.position = {screen.w - 56, SCROLL_Y_POS + BOX_BAR_SPACE}

        y_scroll_bar.extra.org_y = 96
	y_scroll_bar.extra.h_y = 96
	y_scroll_bar.extra.l_y = y_scroll_box.y + y_scroll_box.h - y_scroll_bar.h - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(y_scroll_box) 
	screen:add(y_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dy = ((g.extra.canvas_h - screen.h)/(y_scroll_bar.extra.l_y - y_scroll_bar.extra.h_y))
  
	
	local y0 = - g.extra.canvas_f/g.extra.scroll_dy + 10 
	local y1080 = (-g.extra.canvas_f+1080)/g.extra.scroll_dy + 10

	y_0_mark= Rectangle {
		name="y_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y0, 0},
		opacity = 255
        }

	y_1080_mark= Rectangle {
		name="y_1080_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y1080, 0},
		opacity = 255
       }
  
	screen:add (y_0_mark)
	screen:add (y_1080_mark)

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_y = m.y
	end 
         
        function y_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {y_scroll_bar, x-y_scroll_bar.x, y-y_scroll_bar.y }
		if table.getn(selected_objs) ~= 0 then
			for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
				      screen:remove(screen:find_child(t_obj.name.."a_m"))
				 end
			end
		end

        	return true
    	end 

    	function y_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_y <= y-dy and y-dy <= actor.extra.l_y) then -- 스크롤 되는 범위안에 있으면	
	           		dif = y - dy - y_scroll_bar.extra.org_y -- 스크롤이 이동한 거리 
	           		y_scroll_bar.y = y - dy 
	      		elseif (actor.extra.h_y > y-dy ) then
				dif = actor.extra.h_y - y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.h_y
	      		elseif (actor.extra.l_y < y-dy ) then
				dif = actor.extra.l_y- y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.l_y
			end 
			dif = dif * g.extra.scroll_dy -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.x, j.extra.org_y-dif-y_scroll_from, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.y = t_obj.y 
				 end
			     end
			end

			g.extra.scroll_y = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 
end

function inputMsgWindow_openfile(input_text)
	local file_not_exists = true
    local dir = editor_lb:readdir(CURRENT_DIR.."/screens")

    if(input_text == nil) then
		print ("input_text is nil") 
		return 
    end 

    for i, v in pairs(dir) do
          if(input_text == v)then
     	       current_fn = "screens/"..input_text
               file_not_exists = false
          end
    end

    if (file_not_exists) then
		  -- need error handling 
          return 
    end
    if(is_lua_file(input_text) == true) then 
        editor.close()
        current_fn = "screens/"..input_text
        local f = loadfile(current_fn)
        f(g) 

	   	if screen:find_child("timeline") then 
	      	for i,j in pairs (screen:find_child("timeline").children) do
	         	if j.name:find("pointer") then 
		    		j.extra.set = true
	         	end      
	      	end      
	   	end 
	   	screen:find_child("menu_text").text = screen:find_child("menu_text").text .. "/screens/" .. input_text
     else 
		  -- need error handling 
          --printMsgWindow("The file is not a lua file.\nFile Name : ","err_msg")
          --inputMsgWindow("reopenfile")
          return 
     end 

     if(g.extra.video ~= nil) then clear_bg() end 
     item_num = table.getn(g.children)

     local x_scroll_from=0
     local x_scroll_to=0

     local y_scroll_from=0
     local y_scroll_to=0

     for i, v in pairs(g.children) do
        v.reactive = true
	  	if(v.type == "Text") then
			v.cursor_visible = false
			function v:on_key_down(key)
             		if key == keys.Return then
						v:set{cursor_visible = false}
						return true
	     			end 
			end 
	  	end 
	  	v.extra.lock = false
        create_on_button_down_f(v)
	  
	  	if(v.type == "Group") then 
	       for j, c in pairs (v.children) do
		    	if is_in_list(v.extra.type, uiElements) == false then 
                	c.reactive = true
		        	c.extra.is_in_group = true
	  				c.extra.lock = false
                    create_on_button_down_f(c)
		    	end 
	       end 
	       if v.extra.type == "ScrollPane" or v.extra.type == "DialogBox" or v.extra.type == "ArrowPane" then 
		    	for j, c in pairs(v.content.children) do -- Group { children = {button4,rect3,} },
					c.reactive = true
		        	c.extra.is_in_group = true
	  				c.extra.lock = false
                    create_on_button_down_f(c)
		    	end 
	       elseif v.extra.type == "TabBar" then 
		    	for j, c in pairs(v.tabs) do 
					for k, d in pairs (c.children) do -- Group { children = {button4,rect3,} },
						d.reactive = true
		        		d.extra.is_in_group = true
	  					d.extra.lock = false
                    	create_on_button_down_f(d)
					end 
		    	end 
	       elseif v.extra.type == "LayoutManager" then 
		   		local f 
		   		f = function (k, c) 
     		    	if type(c) == "table" then
	 		   			table.foreach(c, f)
     		    	elseif not c.extra.is_in_group then 
			   			c.reactive = true
		           		c.extra.is_in_group = true
	  		   			c.extra.lock = false
                    	create_on_button_down_f(c)
     		    	end 
		   		end 
		   		table.foreach(v.tiles, f)
	       end 
	  end 

      if(v.x < 0) then 
			if( v.x < x_scroll_from )then 
		     	x_scroll_from = v.x 
			end
      end 
	  
      if(v.y < 0) then 
			if( v.y < y_scroll_from ) then 
		     	y_scroll_from = v.y 
			end
      end 

      if(v.x > screen.w) then 
			if( x_scroll_to < v.x + v.w)then 
		     	x_scroll_to = v.x + v.w
			end
      end 
	  
      if(v.y > screen.h) then 
			if(y_scroll_to < v.y + v.h) then 
		     	y_scroll_to = v.y + v.h 
			end
      end 

     end 

     if (x_scroll_to ~= 0 or x_scroll_from ~= 0 or y_scroll_to ~=0 or y_scroll_from ~= 0) then 
          --make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     end 

     if(screen:find_child("screen_objects") == nil) then
	  	for i,j in pairs(g.children) do 
			if(y_scroll_from < 0) then
				j.y = j.y - y_scroll_from
			end 
			if(x_scroll_from < 0) then
				j.x = j.x - x_scroll_from
			end 
	  	end 
        screen:add(g)
     end

     menu_raise_to_top()
end

function inputMsgWindow_yn(txt)
     cleanMsgWindow()
     if(txt == "no") then
          editor.save(false)
     elseif(txt =="yes") then 
          editor_lb:writefile(current_fn, contents, true)
          contents = ""
     end
     screen:grab_key_focus(screen) 
end

--[[
function inputMsgWindow_openfile(input_text)
     local file_not_exists = true
     local dir = editor_lb:readdir(CURRENT_DIR.."/screens")
     if(input_text == nil) then
		print ("input_text is nil") 
		return 
     end 
     for i, v in pairs(dir) do
          if(input_text == v)then
     	       current_fn = "screens/"..input_text
               file_not_exists = false
          end
     end

     if (file_not_exists) then
	  cleanMsgWindow()
	  screen:grab_key_focus(screen) 
          printMsgWindow("The file not exists.\nFile Name : ","err_msg")
          inputMsgWindow("reopenfile")
          return 
     end
     if(is_lua_file(input_text) == true) then 
           editor.close()
           current_fn = "screens/"..input_text
           local f = loadfile(current_fn)
           f(g) 
	   if screen:find_child("timeline") then 
	      for i,j in pairs (screen:find_child("timeline").children) do
	         if j.name:find("pointer") then 
		    j.extra.set = true
	         end      
	      end      
	   end 
	   screen:find_child("menu_text").text = screen:find_child("menu_text").text .. "/screens/" .. input_text
     else 
	  cleanMsgWindow()
	  screen:grab_key_focus(screen)
          printMsgWindow("The file is not a lua file.\nFile Name : ","err_msg")
          inputMsgWindow("reopenfile")
          return 
     end 
     if(g.extra.video ~= nil) then clear_bg() end 
     item_num = table.getn(g.children)

     local x_scroll_from=0
     local x_scroll_to=0

     local y_scroll_from=0
     local y_scroll_to=0

     for i, v in pairs(g.children) do
          v.reactive = true
	  if(v.type == "Text") then
		v.cursor_visible = false
		function v:on_key_down(key)
             		if key == keys.Return then
				v:set{cursor_visible = false}
				return true
	     		end 
		end 
	  end 
	  v.extra.lock = false
          create_on_button_down_f(v)
	  if(v.type == "Group") then 
	       for j, c in pairs (v.children) do
		    if is_in_list(v.extra.type, uiElements) == false then 
                        c.reactive = true
		        c.extra.is_in_group = true
	  		c.extra.lock = false
                        create_on_button_down_f(c)
		    end 
	       end 
	       if v.extra.type == "ScrollPane" or v.extra.type == "DialogBox" or v.extra.type == "ArrowPane" then 
		    for j, c in pairs(v.content.children) do -- Group { children = {button4,rect3,} },
			c.reactive = true
		        c.extra.is_in_group = true
	  		c.extra.lock = false
                        create_on_button_down_f(c)
		    end 
	       elseif v.extra.type == "LayoutManager" then 
		   local f 
		   f = function (k, c) 
     		      if type(c) == "table" then
	 		   table.foreach(c, f)
     		      elseif not c.extra.is_in_group then 
			   c.reactive = true
		           c.extra.is_in_group = true
	  		   c.extra.lock = false
                           create_on_button_down_f(c)
     		      end 
		   end 
		
		   table.foreach(v.tiles, f)
	       end 
	  end 

          if(v.x < 0) then 
		if( v.x < x_scroll_from )then 
		     x_scroll_from = v.x 
		end
          end 
	  
          if(v.y < 0) then 
		if( v.y < y_scroll_from ) then 
		     y_scroll_from = v.y 
		end
          end 

          if(v.x > screen.w) then 
		if( x_scroll_to < v.x + v.w)then 
		     x_scroll_to = v.x + v.w
		end
          end 
	  
          if(v.y > screen.h) then 
		if(y_scroll_to < v.y + v.h) then 
		     y_scroll_to = v.y + v.h 
		end
          end 
     end 

     if (x_scroll_to ~= 0 or x_scroll_from ~= 0 or y_scroll_to ~=0 or y_scroll_from ~= 0) then 
          --make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     end 

     cleanMsgWindow()
     if(screen:find_child("screen_objects") == nil) then
	  for i,j in pairs(g.children) do 
		if(y_scroll_from < 0) then
			j.y = j.y - y_scroll_from
		end 
		if(x_scroll_from < 0) then
			j.x = j.x - x_scroll_from
		end 
	  end 
          screen:add(g)
     end

     menu_raise_to_top()
     screen:grab_key_focus(screen) 
end
]]
function inputMsgWindow_yn(txt)
     cleanMsgWindow()
     if(txt == "no") then
          editor.save(false)
     elseif(txt =="yes") then 
          editor_lb:writefile(current_fn, contents, true)
          contents = ""
     end
     screen:grab_key_focus(screen) 
end

function inputMsgWindow_openvideo(notused, parm_txt)
     
	 print("inputMsgWindow_openvideo")
     if(is_mp4_file(parm_txt) == true) then 
          mediaplayer:load("assets/videos/"..parm_txt)
     else 
          return 
     end 


     video1 = { name = "video1", 
                type ="Video",
                viewport ={0,0,math.floor(screen.w * screen.scale[1]) ,math.floor(screen.h * screen.scale[2])},
           	source= "assets/videos/"..parm_txt,
           	loop= false, 
                volume=0.5  
              }

     g.extra.video = video1
     mediaplayer.on_loaded = function( self ) clear_bg() if(g.extra.video ~= nil) then self:play() end end 
     if(video1.loop == true) then 
	  	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
     else  	
		mediaplayer.on_end_of_stream = function ( self ) self:seek(0) end
     end


end


function inputMsgWindow_openimage(input_purpose, input_text)

     if(input_text == nil) then
		return
     end 

     local file_not_exists = true
     local dir = editor_lb:readdir(CURRENT_DIR.."/assets/images")
     for i, v in pairs(dir) do
          if(input_text == v)then
               file_not_exists = false
          end
     end
     if (file_not_exists) then
          --cleanMsgWindow()
          --printMsgWindow("The file not exists.\nFile Name :","err_msg")
          --inputMsgWindow("reopenImg")
	  return 0
     end
 
     if (input_purpose == "open_bg_imagefile") then  
	  BG_IMAGE_20.opacity = 0
	  BG_IMAGE_40.opacity = 0
	  BG_IMAGE_80.opacity = 0
	  BG_IMAGE_white.opacity = 0
	  BG_IMAGE_import:set{src = input_text, opacity = 255} 
	  input_mode = S_SELECT
     elseif(is_img_file(input_text) == true) then 
	  
	  while (is_available("image"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	  end 

          ui.image= Image { name="image"..tostring(item_num),
          --src = input_text, opacity = 255 , position = {200,200}, 
          --src = trickplay.config.app_path.."/assets/images/"..input_text, opacity = 255 , position = {200,200}, 
          src = "/assets/images/"..input_text, opacity = 255 , position = {200,200}, 
	  extra = {org_x = 200, org_y = 200} }
          ui.image.reactive = true
	  ui.image.extra.lock = false
          create_on_button_down_f(ui.image)
          table.insert(undo_list, {ui.image.name, ADD, ui.image})
          g:add(ui.image)
	  
	  local timeline = screen:find_child("timeline")
  	  if timeline then 
	     ui.image.extra.timeline = {}
             ui.image.extra.timeline[0] = {}
	     local prev_point = 0
	     local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	     for l,k in pairs (attr_map["Image"]()) do 
	          ui.image.extra.timeline[0][k] = ui.image[k]
	     end
 	     if cur_focus_n ~= 0 then 
                 ui.image.extra.timeline[0]["hide"] = true  
	     end 
	     for i, j in orderedPairs(timeline.points) do 
	        if not ui.image.extra.timeline[i] then 
	             ui.image.extra.timeline[i] = {} 
	             for l,k in pairs (attr_map["Image"]()) do 
		         ui.image.extra.timeline[i][k] = ui.image.extra.timeline[prev_point][k] 
		     end 
		     prev_point = i 
		end 
	        if i < cur_focus_n  then 
                     ui.image.extra.timeline[i]["hide"] = true  
		end 
	     end 
	  end 


	
          if(screen:find_child("screen_objects") == nil) then
               screen:add(g)
          end 
          item_num = item_num + 1
     else 
	  --cleanMsgWindow()
	  --screen:grab_key_focus(screen) -- iii
          --printMsgWindow("The file is not an image file.\nFile Name : ","err_msg")
          --inputMsgWindow("reopenImg")
          return 
     end 

     --cleanMsgWindow()
     --screen:grab_key_focus(screen)
end

local input_purpose     = ""

local function set_project_path ()
	if(selected_prj == "" and input_t.text ~= "") then
               project = input_t.text                           
        elseif(selected_prj ~= "") then                      
               project = msgw:find_child(selected_prj).text   
	       selected_prj = ""
        end   
	
        app_path = editor_lb:build_path( base , project )
        if not editor_lb:mkdir( app_path ) then
        -- Tell the user we were not able to create it
   	     print("couldn't create ",app_path)  
        else
             editor_lb:change_app_path( app_path )
	     CURRENT_DIR = app_path
        end

--- new directory structures 
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
        local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "default" )
        editor_lb:mkdir( lib_skins_default_path ) 
        local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "CarbonCandy" )
        editor_lb:mkdir( lib_skins_default_path ) 
        local lib_skins_default_path = editor_lb:build_path( lib_skins_path, "OOBE" )
        editor_lb:mkdir( lib_skins_default_path ) 
--- new directory structures 

--- old directory structures
        --asset_path = editor_lb:build_path( app_path, "assets" )
        --editor_lb:mkdir( asset_path ) 
--- old directory structures 
	
	screen:find_child("menu_text").text = project .. " "
	screen:find_child("menu_text").extra.project = project .. " "

	copy_widget_imgs()
	cleanMsgWindow()
    screen:grab_key_focus(screen)
end 

function inputMsgWindow(input_purpose, cfn)


     local save_b, cancel_b, input_box, open_b, yes_b, no_b
     local save_t, cancel_t, input_box, open_t, yes_t, no_t
    

     if cfn then 
		inputMsgWindow_savefile(cfn)
		return
     end 

     function create_on_key_down_f(button) 
     	function button:on_key_down(key)
	     if key == keys.Return then
              	if (button.name == "savefile") then inputMsgWindow_savefile()
              	elseif (button.name == "yes") then inputMsgWindow_yn(button.name)
              	elseif (button.name == "no") then inputMsgWindow_yn(button.name)
              	elseif (button.name == "openfile") or (button.name == "reopenfile") then inputMsgWindow_openfile() 
              	elseif (button.name == "projectlist") then set_project_path() editor.close()
              	elseif (button.name == "open_videofile") or (button.name == "reopen_videofile")then inputMsgWindow_openvideo()
              	elseif (button.name == "open_imagefile") or (button.name == "reopenImg")  then  inputMsgWindow_openimage(input_purpose)
              	elseif (button.name == "cancel") then 	cleanMsgWindow() screen:grab_key_focus(screen)
							if(input_purpose == "projectlist") then projects = {} end 
                end
	        return true 
	     elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() cancel_b.extra.on_focus_in()
              	elseif (button.name == "yes") then yes_b.extra.on_focus_out() no_b.extra.on_focus_in() 
              	elseif (button.name == "projectlist") then button.extra.on_focus_out() cancel_b.extra.on_focus_in() 
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or (button.name == "reopen_videofile") or 
              	       (button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() cancel_b.extra.on_focus_in() 
		end
	     elseif (key == keys.Tab and shift == true) or ( key == keys.Up ) or (key == keys.Left) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "no") then no_b.extra.on_focus_out() yes_b.extra.on_focus_in()
              	elseif (button.name == "projectlist") then button.extra.on_focus_out() 
				                           msgw:find_child("input_b").extra.on_focus_in()
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or (button.name == "reopen_videofile") or 
              	(button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "cancel") then 
			cancel_b.extra.on_focus_out() 
			if(open_b ~= nil) then open_b.extra.on_focus_in()
			elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
               end
	     end 
        end 
     end 

     if (input_purpose == "reopenfile" or input_purpose == "reopenImg") or (input_purpose== "reopen_videofile") then 
		msgw_cur_x = msgw_cur_x + 200 
		msgw_cur_y = msgw_cur_y + 45
     elseif(input_purpose == "projectlist") then 
		msgw_cur_x = 25
		if(msgw_focus ~= "") then 
			msgw:add(Text{name= name, text = "   New Project : ", font= "DejaVu Sans 32px",
     		color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     		reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"})  
		else 
	     	msgw_focus = "input_b"
		end 

		msgw_cur_x = 360
		msgw_cur_y = msgw_cur_y + 10
     else 
		msgw_cur_x = msgw_cur_x + 200 
     end
     
     position = {msgw_cur_x, msgw_cur_y} 

     if (input_purpose ~= "yn") then 
		if(input_purpose == "projectlist") then 
            input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
            position = {25, 10}, text = "" , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
            input_box = create_small_input_box(input_t)
            input_box.position = position
            msgw:add(input_box)
	    	input_box.extra.on_focus_out()
		else 
            input_box = create_input_box()
            input_box.position = position
            msgw:add(input_box)
	    input_box.extra.on_focus_in()
		end

     end 

     if (input_purpose == "savefile") then 

     	save_b, save_t  = factory.make_msgw_button_item( assets , "Save")
        save_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
		save_b.reactive = true 
		save_b.name = "savefile"

        cancel_b, cancel_t= factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
		cancel_b.reactive = true 
		cancel_b.name = "cancel"
	
        msgw:add(save_b)
        msgw:add(cancel_b)
		create_on_key_down_f(save_b) 
		create_on_key_down_f(cancel_b) 

		function save_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_savefile()	
     	end 
		function save_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_savefile()	
     	end 


     elseif (input_purpose == "yn") then 
     	yes_b, yes_t  = factory.make_msgw_button_item( assets , "Yes")
        yes_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	yes_b.reactive = true
	yes_b.name = "yes"

        no_b, no_t= factory.make_msgw_button_item( assets ,"No")
        no_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	no_b.reactive = true
	no_b.name = "no"
	
        msgw:add(yes_b)
        msgw:add(no_b)

	create_on_key_down_f(yes_b) 
	create_on_key_down_f(no_b) 

	yes_b.extra.on_focus_in() 

	function yes_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("yes")
		return true
     	end 
     	function no_b:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("no")
		return true
     	end 
	function yes_t:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("yes")
		return true
     	end 
     	function no_t:on_button_down(x,y,button,num_clicks)
		inputMsgWindow_yn("no")
		return true
     	end 
     else 
     	open_b, open_t  = factory.make_msgw_button_item( assets , "Open")
        open_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	open_b.reactive = true

        cancel_b, cancel_t = factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	cancel_b.reactive = true 
	cancel_b.name = "cancel"
	
        msgw:add(open_b)
        msgw:add(cancel_b)


	if (input_purpose == "openfile") or  
	   (input_purpose == "reopenfile") then  
		open_b.name = "openfile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openfile() 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openfile() 
			--return true
     		end 
        elseif (input_purpose == "projectlist") then
 		open_b.name = "projectlist"
        	open_b.position = {360, msgw_cur_y + 70}
        	cancel_b.position = {560, msgw_cur_y + 70}

		function open_b:on_button_down(x,y,button,num_clicks)
				set_project_path()
		        editor.close()
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
				set_project_path()
		        editor.close()
     		end 

	elseif (input_purpose == "open_imagefile") or  
	       (input_purpose == "open_bg_imagefile") or  
	       (input_purpose == "reopenImg") then  
		open_b.name = "open_imagefile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openimage(input_purpose) 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openimage(input_purpose) 
			--return true
     		end 
	elseif (input_purpose == "open_videofile") or (input_purpose == "reopen_videofile") then  
		open_b.name = "open_videofile"
		function open_b:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openvideo() 
			return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			inputMsgWindow_openvideo() 
			return true
     		end 
	end 
	create_on_key_down_f(open_b) 
	create_on_key_down_f(cancel_b) 
     end
     if(cancel_b ~= nil) then 
     	   function cancel_b:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		if(input_purpose == "projectlist") then projects = {} end 
		--return true
     	   end 
     	   function cancel_t:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		if(input_purpose == "projectlist") then projects = {} end 
		--return true
     	   end 
     end

     screen:add(msgw)
     input_mode = S_POPUP

	
     if( input_purpose =="yn") then 
          yes_b:grab_key_focus(yes_b)
     elseif( input_purpose == "projectlist") then 
	  if(msgw_focus ~= "") then 
	       msgw:find_child(msgw_focus).extra.on_focus_in()
	  end 
     else 
          input_t:grab_key_focus(input_t)
     end 

     function input_t:on_key_down(key)
	  if (input_t.text ~= "" and selected_prj ~= "") then 
		if(msgw:find_child(selected_prj) ~= nil) then 
			msgw:find_child(selected_prj):set{color = {255,255,255,255}}
		end 
		selected_prj = ""
	  end 

          if key == keys.Return or (key == keys.Tab and shift == false) or key == keys.Down or key == keys.Right then 
	      input_box.extra.on_focus_out()
	      if(open_b ~= nil) then open_b.extra.on_focus_in() 
	      elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
	  elseif(key == keys.Tab and shift == true) or key == keys.Up or key == keys.Left then 
	      if (input_purpose == "projectlist") then 
	           local n = table.getn(projects)
	           input_box.extra.on_focus_out()
		   msgw:find_child("prj"..n).extra.on_focus_in()
		   return true 
	      end 
          end
     end 
	
    function input_t:on_button_down(x,y,button,num)
	 msgw:find_child(msgw_focus).extra.on_focus_out()
	 input_box.extra.on_focus_in()
    end 

    function input_box:on_button_down(x,y,button,num)
	 msgw:find_child(msgw_focus).extra.on_focus_out()
	 input_box.extra.on_focus_in()
    end 

end
