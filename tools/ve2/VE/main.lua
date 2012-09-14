---------------------------------------------------------
--		Visual Editor Main.lua 
---------------------------------------------------------

    -------------------------------
    -- Constants, Global Variables  
    -------------------------------
    hdr = dofile("header")


    --TEST Function 
    aa = function ()
        _VE_.openFile("/home/hjkim/code/trickplay/tools/ve2/TEST5/TR.TEST_LIB/screens")
        _VE_.insertUIElement(9, 'Button')
        _VE_.insertUIElement(9, 'DialogBox')
        --_VE_.insertUIElement(9, 'ArrowPane')
        --_VE_.insertUIElement(9, 'ToastAlert')
        --_VE_.insertUIElement(9, 'LayoutManager')
        --_VE_.insertUIElement(9, 'TabBar')
        --_VE_.insertUIElement(9, 'ScrollPane')
        --_VE_.insertUIElement(9, 'MenuButton')
        _VE_.insertUIElement(9, 'Rectangle')
    end 


    ----------------------------------------------------------------------------
    -- Key Map
    ----------------------------------------------------------------------------
 
    local key_map =
    {
        [ keys.c	] = function() editor.clone() input_mode = hdr.S_SELECT end,
        [ keys.d	] = function() editor.duplicate() input_mode = hdr.S_SELECT end,
        [ keys.g	] = function() editor.group() input_mode = hdr.S_SELECT end,
        [ keys.h	] = function() editor.h_guideline() input_mode = hdr.S_SELECT end,
        --[ keys.k	] = function() editor_lb:execute(debugger_script.." "..current_dir) end,
	    [ keys.r	] = function() input_mode = hdr.S_RECTANGLE screen:grab_key_focus() end,
        [ keys.t	] = function() editor.text() input_mode = hdr.S_SELECT end,
        [ keys.u	] = function() editor.ugroup() input_mode = hdr.S_SELECT end,
        --[ keys.z	] = function() editor.undo() input_mode = hdr.S_SELECT end,
        [ keys.v	] = function() editor.v_guideline() input_mode = hdr.S_SELECT end,
        [ keys.w	] = function() editor.image() input_mode = hdr.S_SELECT end,
        [ keys.BackSpace ] = function() editor.delete() input_mode = hdr.S_SELECT end,
        [ keys.Delete    ] = function() editor.delete() input_mode = hdr.S_SELECT end,
	    [ keys.Shift_L   ] = function() shift = true end,
	    [ keys.Shift_R   ] = function() shift = true end,
	    [ keys.Control_L ] = function() control = true end,
	    [ keys.Control_R ] = function() control = true end,
        [ keys.Return    ] = function() screen_ui.n_select_all() input_mode = hdr.S_SELECT end ,
        [ keys.Left     ] = function() screen_ui.move_selected_obj("Left") input_mode = hdr.S_SELECT end,
        [ keys.Right    ] = function() screen_ui.move_selected_obj("Right") input_mode = hdr.S_SELECT end ,
        [ keys.Down     ] = function() screen_ui.move_selected_obj("Down") input_mode = hdr.S_SELECT end,
        [ keys.Up       ] = function() screen_ui.move_selected_obj("Up") input_mode = hdr.S_SELECT end,
    }
    
    -------------------------------
    -- Local Variables  
    -------------------------------
    -- temporary UI Element 
    local uiDuplicate= nil
    local uiRectangle = nil

    -- Layer JSON 
    local json_head = '[{"anchor_point":[0,0], "children":[{"anchor_point":[0,0], "children":'  
    local json_tail = ',"gid":2,"is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[0.5, 0.5],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}], "gid":0,"is_visible":true,"name":"stage","opacity":255,"position":[0,0,0],"scale":[1,1],"size":[960, 540],"type":"Stage","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'
    
    -- Style JSON 
    local sjson_head = '[{"anchor_point":[0,0], "children":'  
    local sjson_tail = ',"gid":2,"is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[1, 1],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'

---------------------------------------------------------------------------
---                 Local Editor Functions                              ---
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---            Global  Visual Editor Functions                          ---
---------------------------------------------------------------------------

_VE_ = {}

-- GET 
_VE_.getStInfo = function()

    local t = {}
    --table.insert(t, json:parse(fake_style_json))
    table.insert(t, json:parse(get_all_styles()))
    print("getStInfo"..json:stringify(t))
end 

_VE_.repStInfo = function()
    local t = {}
    table.insert(t, json:parse(get_all_styles()))
    print("repStInfo"..json:stringify(t))
end 

_VE_.getUIInfo = function()
    local t = {}
    for m,n in ipairs (screen.children) do
    --[[
        if string.find(n.name, "Layer") then  
            fake_layer = fake_layer_name..n.name..fake_layer_gid..n.gid..fake_layer_children
            for i,j in ipairs(n.children) do 
                if j.to_json then 
                    if i > 1 then
                        fake_layer = fake_layer..','..j:to_json()
                    else 
                        fake_layer = fake_layer..j:to_json()
                    end
                end 
            end 
            fake_layer = fake_layer..fake_layer_end
            table.insert(t, json:parse(fake_layer))
        else]]
        if n.to_json then -- s1.b1
            table.insert(t, json:parse(n:to_json()))
        end
    end
    
    print("getUIInfo"..json_head..json:stringify(t)..json_tail)
end 

_VE_.printInstanceName = function(layernames)

    theNames =""

    for m,n in ipairs (screen.children) do
        if n.name then
        if string.find(n.name, "Layer") then  
            print(n.name)
            for q,w in ipairs (layernames) do 
                if n.name == w then
                    for k,l in ipairs (n.children) do 
                        if theNames ~= "" then 
                            theNames = theNames.." "..l.name
                        else
                            theNames = theNames..l.name
                        end
                    end
                end
            end
        end
        end
    end 
    print("prtObjNme"..theNames)
end 

_VE_.contentMove = function(newChildGid, newParentGid)
    local newChild = devtools:gid(newChildGid)
    newChild:unparent()
    devtools:gid(newParentGid):add(newChild)
end 

_VE_.alignLeft = function(gid)

    local basis_obj_name, basis_obj = editor.arrange_prep(gid)
   
    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true and v.name ~= basis_obj_name) then
		    if(v.x ~= basis_obj.x) then
			  	v.x = basis_obj.x
		    end
    	end
    end

    editor.arrange_end()

end 

_VE_.alignRight = function(gid)

    local basis_obj_name, basis_obj = editor.arrange_prep(gid)

    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true and v.name ~= basis_obj_name) then
		   if(v.x ~= basis_obj.x + basis_obj.w - v.w) then
			v.x = basis_obj.x + basis_obj.w - v.w
		   end
		end 
    end

    editor.arrange_end()

end 

_VE_.alignTop = function(gid)

    local basis_obj_name, basis_obj = editor.arrange_prep(gid)
    
    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true and v.name ~= basis_obj_name ) then
		  --   screen_ui.n_selected(v)
		  if(v.y ~= basis_obj.y) then
			v.y = basis_obj.y 
		  end 
		end 
   end

    editor.arrange_end()
    
end 

_VE_.alignBottom = function(gid)

    local basis_obj_name, basis_obj = editor.arrange_prep(gid)
    
    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true and  v.name ~= basis_obj_name) then
		    --screen_ui.n_selected(v)
		    if(v.y ~= basis_obj.y + basis_obj.h - v.h) then 	
			    v.y = basis_obj.y + basis_obj.h - v.h 
		    end 
		end 
    end

    editor.arrange_end()

end 
 
_VE_.alignHorizontalCenter = function(gid)

    local basis_obj_name, basis_obj = editor.arrange_prep(gid)
    
    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true and v.name ~= basis_obj_name) then
		    -- screen_ui.n_selected(v)
		    if(v.x ~= basis_obj.x + basis_obj.w/2 - v.w/2) then 
			    v.x = basis_obj.x + basis_obj.w/2 - v.w/2
		    end
		end 
    end

    editor.arrange_end()

end 
 
_VE_.alignVerticalCenter = function(gid)

    local basis_obj_name, basis_obj = editor.arrange_prep(gid)

    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true and v.name ~= basis_obj_name) then
		-- screen_ui.n_selected(v)
		    if(v.y ~=  basis_obj.y + basis_obj.h/2 - v.h/2) then 
			    v.y = basis_obj.y + basis_obj.h/2 - v.h/2
		    end
		end 
    end
  
    editor.arrange_end()
end 

_VE_.distributeHorizontal = function(gid)

    editor.arrange_prep(gid)
    --[[
    util.getCurLayer(gid)
    blockReport = true

    if #selected_objs == 0 then 
	    print("there are  no selected objects") 
	    input_mode = hdr.S_SELECT
	    return 
    end 
    ]]
    
    local x_table = {}
    local temp_w = 0
    local next_x = 0 
    local next_pos = 0 
    local min = screen.w
    local max = 0
    local distance = 0

    for i,j in ipairs (curLayer.children) do
        if j.extra.selected == true then 
            table.insert(x_table, j.x)
            if j.x < min then 
                min = j.x 
            end 
            if j.x > max then 
                max = j.x 
            end 
        end 
    end 


    for i,j in ipairs (curLayer.children) do
        if j.extra.selected == true then 
            if j.x == min then 
                min = j.x + j.w
            elseif j.x ~= max then 
                temp_w = temp_w + j.w
            end 
        end 
    end 

    distance = (max - min - temp_w) / (#x_table - 1)
    table.sort(x_table)

    next_pos = table.remove(x_table) - distance
    next_x = table.remove(x_table)

    while #x_table ~= 0 do
        for i,j in ipairs (curLayer.children) do 
            if j.extra.selected == true then 
                if j.x == next_x then 
                    j.x = next_pos - j.w
                    screen:find_child(j.name.."border").x = next_pos - j.w
                    screen:find_child(j.name.."a_m").x = next_pos - j.w
                    next_pos = j.x - distance
                    next_x = table.remove(x_table)
                    break
                end 
            end 
        end 
    end 

    editor.arrange_end(gid)
    --[[
    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
    _VE_.refresh() 
    blockReport = false
    ]]
end 

_VE_.distributeVertical = function(gid)

    editor.arrange_prep(gid)
    --[[
    util.getCurLayer(gid)
    blockReport = true

    if #selected_objs == 0 then 
	    print("there are  no selected objects") 
	    input_mode = hdr.S_SELECT
	    return 
    end 
    ]]
    
    local y_table = {}
    local temp_h = 0
    local next_y = 0 
    local next_pos = 0 
    local min = screen.h
    local max = 0
    local distance = 0

    for i,j in ipairs (curLayer.children) do
        if j.extra.selected == true then 
            table.insert(y_table, j.y)
            if j.y < min then 
                min = j.y 
            end 
            if j.y > max then 
                max = j.y 
            end 
        end 
    end 


    for i,j in ipairs (curLayer.children) do
        if j.extra.selected == true then 
            if j.y == min then 
                min = j.y + j.h
            elseif j.y ~= max then 
                temp_h = temp_h + j.h
            end 
        end 
    end 

    distance = (max - min - temp_h) / (#y_table - 1)
    table.sort(y_table)

    next_pos = table.remove(y_table) - distance
    next_y = table.remove(y_table)

    while #y_table ~= 0 do
        for i,j in ipairs (curLayer.children) do 
            if j.extra.selected == true then 
                if j.y == next_y then 
                    j.y = next_pos - j.h
                    screen:find_child(j.name.."border").y = next_pos - j.h
                    screen:find_child(j.name.."a_m").y = next_pos - j.h
                    next_pos = j.y - distance
                    next_y = table.remove(y_table)
                    break
                end 
            end 
        end 
    end 

    editor.arrange_end(gid)
    --[[
    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
    _VE_.refresh() 
    blockReport = false
    ]]
end 

_VE_.bringToFront = function(gid)

    editor.arrange_prep(gid)
    --[[
    util.getCurLayer(gid)
    blockReport = true

    if #selected_objs == 0 then 
	    print("there are  no selected objects") 
	    input_mode = hdr.S_SELECT
	    return 
    end 
    --]]

    for i, v in pairs(curLayer.children) do
	    if(v.extra.selected == true) then
			curLayer:remove(v)
			curLayer:add(v)
			--screen_ui.n_selected(v)
        end
    end

    editor.arrange_end(gid)

    --[[
    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
    _VE_.refresh() 
    blockReport = false
    ]]
end 


_VE_.bringForward = function(gid)

    editor.arrange_prep(gid)

    local tmp_g = {}
    local slt_g = {}

    for i, v in ipairs(curLayer.children) do
	    curLayer:remove(v) 
		if #slt_g ~= 0 then 
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

    if #slt_g ~= 0 then
    	table.insert(tmp_g, table.remove(slt_g))
    end 

    tmp_g = util.get_reverse_t(tmp_g)

    while(table.getn(tmp_g) ~= 0) do
    	v = table.remove(tmp_g)
	    curLayer:add(v)
    end 

    editor.arrange_end(gid)

end

_VE_.sendToBack = function(gid)

    editor.arrange_prep(gid)

    local tmp_g = {}
    local slt_g = {}

    for i, v in ipairs(curLayer.children) do
	    curLayer:remove(v) 
	    if(v.extra.selected == true) then
		    table.insert(slt_g, v)
			screen_ui.n_selected(v)
		else 
		     table.insert(tmp_g, v) 
		end
    end
    
    while #slt_g ~= 0 do
	    v = table.remove(slt_g)
	    curLayer:add(v)	
    end 
    
    tmp_g = util.get_reverse_t(tmp_g) 
    while #tmp_g ~= 0 do
	    v = table.remove(tmp_g)
	    g:add(v)	
    end 
	
    editor.arrange_end(gid)

end

_VE_.sendBackward = function(gid)

    editor.arrange_prep(gid)

    local tmp_g = {}
    local slt_g = {}

    for i, v in ipairs(curLayer.children) do
	    curLayer:remove(v)  -- 1,2,(3)
		if #slt_g ~= 0 then 
		    local b = table.remove(slt_g)
			local f = table.remove(tmp_g)
			table.insert(tmp_g, b)
			table.insert(tmp_g, f) 
		end 
	    if (v.extra.selected == true) then
		    table.insert(slt_g, v) 
			screen_ui.n_selected(v)
		else 
		    table.insert(tmp_g, v) 
		end
    end

    if #slt_g ~= 0 then 
	    local b = table.remove(slt_g) 
	    local f = table.remove(tmp_g) 
	    table.insert(tmp_g, b) 
	    table.insert(tmp_g, f) 
    end 

    tmp_g = util.get_reverse_t(tmp_g)
    while #tmp_g ~= 0 do
	    v = table.remove(tmp_g)
	    curLayer:add(v) 
    end 

    editor.arrange_end(gid)

end

_VE_.refresh = function()

    _VE_.getUIInfo()
    _VE_.getStInfo()

end 

-- Ungroup
_VE_.ungroup = function(gid)

    editor.ungroup(gid)
 
end 

-- Duplicate
_VE_.duplicate = function(gid)

    editor.duplicate(gid)

end 

-- Delete
_VE_.delete = function(gid)

    if #(selected_objs) == 0 then 
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

	local delete_f = function(del_obj)

		screen_ui.n_selected(del_obj)

        --[[
        if (screen:find_child(del_obj.name.."a_m") ~= nil) then 
	     		screen:remove(screen:find_child(del_obj.name.."a_m"))
        end
        --]]
        --[=[  
        -- manage user stub code 
		if util.need_stub_code(del_obj) == true then 
			if current_fn then 
				local a, b = string.find(current_fn,"screens") 
				local current_fn_without_screen 
	   			if a then 
					current_fn_without_screen = string.sub(current_fn, 9, -1)
	   			end 

	   			local fileUpper= string.upper(string.sub(current_fn_without_screen, 1, -5))
	   		    local fileLower= string.lower(string.sub(current_fn_without_screen, 1, -5))

			    local main = readfile("main.lua")
			    if main then 
			    	if string.find(main, "-- "..fileUpper.."\."..string.upper(del_obj.name).." SECTION\n") ~= nil then  			
			        	local q, w = string.find(main, "-- "..fileUpper.."\."..string.upper(del_obj.name).." SECTION\n") 
				  		local e, r = string.find(main, "-- END "..fileUpper.."\."..string.upper(del_obj.name).." SECTION\n\n")
				  		local main_first = string.sub(main, 1, q-1)
						local main_delete = string.sub(main, q, r-1) 
				  		local main_last = string.sub(main, r+1, -1)
				  		main = ""
				  		main = main_first.."--[[\n"..main_delete.."]]\n\n"..main_last
				  		editor_lb:writefile("main.lua",main, true)
	       		    end 
			     end 
	       	end 
	   end 
       ]=]
    end 

    util.getCurLayer(gid)

    blockReport = true

    for i, v in pairs(curLayer.children) do
		if(v.extra.selected == true) then
			if v.extra.clone then 
				if #v.extra.clone > 0 then
                    print (v.name,"can't be deleted. It has clone object")
        			screen:grab_key_focus()
					input_mode = hdr.S_SELECT
					return 
				end 
			end 

			if v.type == "Clone" then 
				util.table_remove_val(v.source.extra.clone, v.name)
			end 
			
			delete_f(v)
		    curLayer:remove(v)
		end 
	end 
	
    blockReport = false

    _VE_.refresh()
    --[=[
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
				for e, r in pairs (bumo.cells) do 
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
    --]=]

	input_mode = hdr.S_SELECT
	screen:grab_key_focus()

end 

-- SET
_VE_.setUIInfo = function(gid, property, value, n)
    
    uiInstance = devtools:gid(gid)
	screen_ui.n_selected(uiInstance) 
    if property == 'source' then 
        the_obj = screen:find_child(value) 
        if the_obj ~= nil then 
            uiInstance[property] = the_obj 
            uiInstance.extra.source = value
		    --screen_ui.n_selected(uiInstance)
        end 
    elseif property == 'visible' then 
        screen_ui.n_selected_all()
        uiInstance[property] = value 
    elseif property == "anchor_point" then 
        ax = table.remove(value, 1)
        ay = table.remove(value, 1) 
        uiInstance:move_anchor_point(ax, ay)
    elseif n ~= nil then 
        uiInstance['tabs'][n].label = value 
        print (n, value)
    else
        uiInstance[property] = value 
    end 
	screen_ui.selected(uiInstance) 
end 

-- REPORT 
_VE_.repUIInfo = function(uiInstance)
    if blockReport == true then 
        return
    end 

    local t = {}
    if uiInstance.to_json then 
        table.insert(t, json:parse(uiInstance:to_json()))
    end 
    print("repUIInfo"..json:stringify(t))
end

_VE_.openInspector = function(gid)
    print("openInspc"..gid)
end 

_VE_.setAppPath = function(path)
    editor_lb:change_app_path(path)
end 

_VE_.openFile = function(path)
    blockReport = true
    screen:clear()
    util.setBGImages(path)
    editor_lb:change_app_path(path)

    layers_file = "layers.json"
    styles_file = "styles.json"
    screens_file = "screens.json"

    print("scrJSInfo"..readfile(screens_file))

    --the first time this function is called, styles will get set up
    --if not styles then load_styles() end
    
    --load the json
    local style = readfile(styles_file)
    style = string.sub(style, 2, string.len(style)-1)

    if style == nil then
        error("Style '"..styles_file.."' does not exist.",2)
    end

    load_styles(style) 

    local layer = readfile(layers_file)
    layer = string.sub(layer, 2, string.len(layer)-1)
    
    if layer == nil then
        error("Layer '"..layers_file.."' does not exist.",2)
    end

    -- Image !!! 

    q,w = string.find(path, "/screens")
    path = string.sub(path, 1, q - 1)
    path = path.."/assets/images/"
    print (path)
    editor_lb:change_app_path(path)

    s = load_layer(layer)

    for i,j in ipairs(s.children) do
        if string.find(j.name, "Layer") ~= nil then 
            for l,m in ipairs(j.children) do 
                m.created = false
                if m.subscribe_to then  
                    m:subscribe_to(nil, function() if dragging == nil then _VE_.repUIInfo(m) end end)
                end 

                local uiTypeStr = util.getTypeStr(m) 

                if uiTypeStr == "LayoutManager" then 
                    m.placeholder = Widget_Rectangle{ size = {300, 200}, border_width=2, border_color = {255,255,255,255}, color = {255,255,255,0}}
                end 
                util.create_mouse_event_handler(m, uiTypeStr)

                m.reactive = true 
                m.lock = false
                m.selected = false
                m.is_in_group = false
            end
        end 
        j:unparent()
        screen:add(j)
    end
    
    _VE_.refresh()
    
    --[[
    for i,j in ipairs(s.children) do
        if string.find(j.name, "Layer") ~= nil then 
            for l,m in ipairs(j.children) do 
               if m.subscribe_to then  
                m:subscribe_to(nil, function() if dragging == nil then _VE_.repUIInfo(m) end end)
               end 
            end
        end
    end
    -]]
    blockReport = false
end 


--[[
_VE_.openLuaFile = function()
    --s = load_layer("layer1.json")
    screen:clear()
    g.reactive = false
    
    screen:add(g)

    for i,j in ipairs(screen.children) do
        --dump_properties(j)
        --print (j.name)
        j.extra.to_json = function() return fake_json end
        function j.on_button_down( j , x , y , button )
            dragging = { j , x - j.x , y - j.y }
            if button == 3 then
                _VE_.openInspector(4)
            enimport
        end
    
        function j.on_button_up( j , x , y , button )
            dragging = nil
        end
    
        j.reactive = true 
        _VE_.repUIInfoWfakeJson(j)
    end
end 
]]

_VE_.newLayer = function()
    for m,n in ipairs (screen.children) do
        if n.name == "Layer"..layerNum then 
            layerNum = layerNum + 1
        end
    end 
    screen:add(Widget_Group{name="Layer"..layerNum, size={1920, 1080}, position={0,0,0}})
    layerNum = layerNum + 1

    _VE_.refresh()
end 

_VE_.saveFile = function(scrJson)
    local layer_t = {}
    local style_t = {}

    for a, b in ipairs (screen.children) do
            if b.to_json then -- s1.b1
                table.insert(layer_t, json:parse(b:to_json()))
            end
    end

    table.insert(style_t, json:parse(get_all_styles()))

    editor_lb:writefile("layers.json", sjson_head..json:stringify(layer_t)..sjson_tail, true) 
    editor_lb:writefile("styles.json", json:stringify(style_t), true) 
    editor_lb:writefile("screens.json", scrJson, true) 

end 

_VE_.black = function()
    BG_IMAGE_20.opacity = 0
    BG_IMAGE_40.opacity = 0
    BG_IMAGE_80.opacity = 0
    BG_IMAGE_white.opacity = 0
    BG_IMAGE_import.opacity = 0
end

_VE_.backgroundImage = function(path)
    _VE_.black()
    BG_IMAGE_import.src = path  
    BG_IMAGE_import.opacity = 255  
end

_VE_.smallGrid = function()
    _VE_.black()
    BG_IMAGE_20.opacity = 255
end

_VE_.mediumGrid = function()
    _VE_.black()
    BG_IMAGE_40.opacity = 255
end

_VE_.largeGrid = function()
    _VE_.black()
    BG_IMAGE_80.opacity = 255
end

_VE_.white = function()
    _VE_.black()
    BG_IMAGE_white.opacity = 255
end

_VE_.setHGuideY = function(y)
    selected_guideline.y = y - 10 
    util.close_guideInspector()
end 

_VE_.setVGuideX = function(x)
    selected_guideline.x = x - 10 
    util.close_guideInspector()
end 

_VE_.deleteGuideLine = function()
    screen:remove(selected_guideline) 
    _VE_.close_guideInspector()
end 

_VE_.addHorizonGuide = function()
    h_guideline = h_guideline + 1

     local h_gl =Group{
		    name="h_guideline"..tostring(h_guideline),
		    position = {0, screen.h/2-10, 0}, 
		    size = {screen.w, 20},
		    reactive = true,
            children = { 
                Rectangle {
                    name = "line",
		            border_color= hdr.DEFAULT_COLOR, 
		            color={0,255,255,255},
		            position = {0, 9, 0},
		            size = {screen.w, 2},
		            opacity = 255,
                }
            }
        }
     util.create_on_line_down_f(h_gl)
     screen:add(h_gl)
     screen:grab_key_focus()

--[[
	 if menuButtonView.items[11]["icon"].opacity < 255 then 
		h_gl:hide()
	 end 
]]
end

_VE_.addVerticalGuide = function()
    v_guideline = v_guideline + 1 

     local v_gl = Group{ 
		name="v_guideline"..tostring(v_guideline),
		reactive = true, 
		position = {screen.w/2-10, 0, 0}, 
		size = {20, screen.h},
        children = { Rectangle {
        name = "line",
		border_color= hdr.DEFAULT_COLOR, 
		color={0,255,255,255},
		size = {2, screen.h},
		position = {9, 0, 0}, 
		opacity = 255,
        }
     }
     }
     util.create_on_line_down_f(v_gl)
     screen:add(v_gl)
     screen:grab_key_focus()

	 if menuButtonView.items[11]["icon"].opacity < 255 then 
		v_gl:hide()
	 end 
end

_VE_.showGuides = function(guidelineShow)
    if guidelineShow == false then 
		--menuButtonView.items[11]["icon"].opacity = 255
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
			--menuButtonView.items[11]["icon"].opacity = 0
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
_VE_.snapToGuides = function(snapGuide)
	if snapGuide == true then 
		 	--menuButtonView.items[12]["icon"].opacity = 0 
            snapToGuide = false
	else 
		 	--menuButtonView.items[12]["icon"].opacity = 255 
            snapToGuide = true
	end
	screen:grab_key_focus()
end

_VE_.insertUIElement = function(layerGid, uiTypeStr, path)

    local uiInstance, dragging = nil 

    util.getCurLayer(layerGid)

    blockReport = true

    if uiTypeStr == "Rectangle" then 

        input_mode = hdr.S_RECTANGLE 
        screen:grab_key_focus()
        return

    elseif uiTypeStr == "Group" then 
        
        uiInstance = editor.group()
        if uiInstance == nil then 
            return
        end 

    elseif uiTypeStr == "Clone" then 
        
        editor.clone()
        return

    elseif hdr.uiElementCreate_map[uiTypeStr] then
        uiInstance = hdr.uiElementCreate_map[uiTypeStr]()
    end 
    
    -- Default Settings
    if uiTypeStr == "ButtonPicker" then 
        uiInstance.items = {"item1","item2","item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10", "item11", "item12", "item13", "item14"}
    ---[[ for arrow_move_by test
        elseif uiTypeStr == "ArrowPane" then 
        uiInstance:add(Widget_Rectangle{w=1000,h=1000,color="ffff00"},Widget_Rectangle{w=100,h=100,color="ff0000"},Widget_Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
    --]]--
    elseif uiTypeStr == "LayoutManager" then 
        
        uiInstance:set{
            number_of_rows = 2,
            number_of_cols = 3,
            placeholder = Widget_Rectangle{ size = {300, 200}, border_width=2, border_color = {255,255,255,255}, color = {255,255,255,0}},
            cells = {
                {Widget_Rectangle{name = "star", w=30,h=30},Widget_Rectangle{name = "moon", w=100,h=100}},
                {Widget_Rectangle{name = "rainbow", w=100,h=100},nil,Widget_Rectangle{name="sun",w=100,h=100}},
            }
        }
    
    --[[
        uiInstance:set{ number_of_rows = 2, number_of_cols = 2}
        uiInstance.set{
                cells = {
                {Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}},
                {Widget_Rectangle{w=100,h=100}},
                {Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}},
                }

                --{Widget_Rectangle{w=100,h=100, color = {255,0,0,255}},Widget_Rectangle{w=100,h=100, color = {255,100,0,255}}},
                --{Widget_Rectangle{w=100,h=100, color = {255,0,100,255}}},
                --{Widget_Rectangle{w=100,h=100, color = {255,100,100,255}},Widget_Rectangle{w=100,h=100, color = {20,220,0,255}}},
        }
    ]]
    elseif uiTypeStr == "TabBar" then 
        uiInstance:set{ 
             position = {100,100},
             tabs = {
                {label="Tab1",   contents = {Widget_Rectangle{w=400,h=400,color={255,255,255,255}}, Button{}} },
                {label="Tab2",   contents = {Widget_Rectangle{w=400,h=400,color={255,255,255,255}}} },
                {label="Tab3",   contents = {Widget_Rectangle{w=400,h=400,color={255,255,255,255}}} },
                {label="Tab4",   contents = {Widget_Rectangle{w=400,h=400,color={255,255,255,255}}} },
                {label="Tab5",   contents = {Widget_Rectangle{w=400,h=400,color={255,255,255,255}}} },
            }
        }

        --uiInstance.tabs[1]:add()
    elseif uiTypeStr == "ProgressBar" then 
        uiInstance.progress = 0.25
    elseif uiTypeStr == "ScrollPane" then 
        b = Button{name="pretty_button"}
        uiInstance:add(b)
    elseif uiTypeStr == "DialogBox" then 
        local b = Button{name="pretty_button"}
        uiInstance.content = {b}

    elseif uiTypeStr == "MenuButton" then 
        --b = Button{name="pretty_button"}
        uiInstance.items = {Button{name="pretty_button"}}

        --uiInstance:add(b)
        --table.insert(uiInstance.items, b)
        --uiInstance.items.length = 3
        --uiInstance.items[1] = b
        --uiInstance.items[2] = b
        --uiInstance.items[3] = b

    end 
        
    util.assign_right_name(uiInstance, uiTypeStr)

    if uiTypeStr == "Image" then 
        uiInstance.src = path
    elseif uiTypeStr == "Text" then 
        editor.text(uiInstance)
    end

    util.create_mouse_event_handler(uiInstance, uiTypeStr)

    util.addIntoLayer(uiInstance)
    blockReport = false

end


    local function styleUpdate()
        if blockReport ~= true then
            _VE_.refresh()
        end 
    end 


---------------------------------------------------------------------------
---           Global  Screen Mouse Event Handler Functions              ---
---------------------------------------------------------------------------

    function screen:on_key_down( key )

		if(input_mode ~= hdr.S_POPUP) then 
          if key_map[key] then
              key_map[key](self)
     	  end
     	end

    end

    function screen:on_key_up( key )

    	if key == keys.Shift_L or key == keys.Shift_R then shift = false end 
    	if key == keys.Control_L or key == keys.Control_R then control = false end 

    end

	function screen:on_button_down(x,y,button,num_clicks,m)

      	mouse_state = hdr.BUTTON_DOWN 		-- for drawing rectangle 

		if current_focus and input_mode ~=  hdr.S_RECTANGLE then -- for closing menu button or escaping from text editting 
			current_focus.clear_focus()
			screen:grab_key_focus()
			return
		end 

      	if(input_mode == hdr.S_RECTANGLE) then 
	       uiRectanle = editor.rectangle( x, y) 
		   return
	  	end

		screen_ui.multi_select(x,y)
    end

	local move 
	function screen:on_button_up(x,y,button,clicks_count, m)

		-- for dragging timepoint 
		screen_ui.dragging_up(x,y)

	  	dragging = nil

        if (mouse_state == hdr.BUTTON_DOWN) then
            if input_mode == hdr.S_RECTANGLE then 
	           editor.rectangle_done(x, y) 
	           input_mode = hdr.S_SELECT 
	      	else
				screen_ui.multi_select_done(x,y)
				if move == nil then
					screen_ui.n_selected_all()
				end
				move = nil
	      	end 
       	end

       	mouse_state = hdr.BUTTON_UP

	end

    function screen:on_motion(x,y)

	  	if control == true then 
			screen_ui.draw_selected_container_border(x,y) 
		end 
	 
	 	screen_ui.cursor_setting()
	 	screen_ui.dragging(x,y)

        if(mouse_state == hdr.BUTTON_DOWN) then
            if (input_mode == hdr.S_RECTANGLE) then 
				editor.rectangle_move(x, y) 
			end
            if (input_mode == hdr.S_SELECT) then 
		    	screen_ui.multi_select_move(x, y) 
				move = true
			end
        end

	end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

    function main()

        -- to activate mouse handlers 
    	if controllers.start_pointer then 
  			controllers:start_pointer()
    	end

        Style:subscribe_to(styleUpdate)

        screen.reactive = true

        util.setBGImages()

        print("<<VE_READY>>:")

    end 

    screen:show()
    dolater(main)



