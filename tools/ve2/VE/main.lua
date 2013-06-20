---------------------------------------------------------
--		Visual Editor Main.lua 
---------------------------------------------------------

    -------------------------------
    -- Constants, Global Variables  
    -------------------------------
    hdr = dofile("header")

    ----------------------------------------------------------------------------
    -- Key Map
    ----------------------------------------------------------------------------
    local currentProjectPath 
    local openFile= false
    local key_map =
    {
        --[ keys.c	] = function() editor.clone() input_mode = hdr.S_SELECT end,
        --[ keys.d	] = function() editor.duplicate() input_mode = hdr.S_SELECT end,
        --[ keys.g	] = function() editor.group() input_mode = hdr.S_SELECT end,
        --[ keys.h	] = function() editor.h_guideline() input_mode = hdr.S_SELECT end,
        --[ keys.k	] = function() editor_lb:execute(debugger_script.." "..current_dir) end,
	    --[ keys.r	] = function() input_mode = hdr.S_RECTANGLE screen:grab_key_focus() end,
        --[ keys.t	] = function() editor.text() input_mode = hdr.S_SELECT end,
        --[ keys.u	] = function() editor.ugroup() input_mode = hdr.S_SELECT end,
        --[ keys.z	] = function() editor.undo() input_mode = hdr.S_SELECT end,
        --[ keys.v	] = function() editor.v_guideline() input_mode = hdr.S_SELECT end,
        --[ keys.w	] = function() editor.image() input_mode = hdr.S_SELECT end,
        --[ keys.BackSpace ] = function() editor.delete() input_mode = hdr.S_SELECT end,
        --[ keys.Delete    ] = function() editor.delete() input_mode = hdr.S_SELECT end,
	    [ keys.Shift_L   ] = function() shift = true end,
	    [ keys.Shift_R   ] = function() shift = true end,
	    [ keys.Control_L ] = function() control = true end,
	    [ keys.Control_R ] = function() control = true end,
        --[ keys.Return    ] = function() screen_ui.n_select_all() input_mode = hdr.S_SELECT end ,
        --[ keys.Left     ] = function() screen_ui.move_selected_obj("Left") input_mode = hdr.S_SELECT end,
        --[ keys.Right    ] = function() screen_ui.move_selected_obj("Right") input_mode = hdr.S_SELECT end ,
        --[ keys.Down     ] = function() screen_ui.move_selected_obj("Down") input_mode = hdr.S_SELECT end,
        --[ keys.Up       ] = function() screen_ui.move_selected_obj("Up") input_mode = hdr.S_SELECT end,
    }
    
    -------------------------------
    -- Local Variables  
    -------------------------------
    -- temporary UI Element 
    local uiDuplicate= nil
    local uiRectangle = nil

    -- Layer JSON 
    local json_head = '[{"anchor_point":[0,0], "children":[{"anchor_point":[0,0], "children":'  
    local json_tail = ',"gid":"'..screen.gid..'","is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[0.5, 0.5],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}], "gid":0,"is_visible":true,"name":"stage","opacity":255,"position":[0,0,0],"scale":[1,1],"size":[960, 540],"type":"Stage","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'
    
    -- Style JSON 
    local sjson_head = '[{"anchor_point":[0,0], "children":'  
    local sjson_tail = ',"gid":"'..screen.gid..'","is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[1, 1],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'

---------------------------------------------------------------------------
---                 Local Editor Functions                              ---
---------------------------------------------------------------------------

    local function styleUpdate()
        if blockReport ~= true then
            _VE_.refresh()
        end 
    end 

---------------------------------------------------------------------------
---            Global  Visual Editor Functions                          ---
---------------------------------------------------------------------------

_VE_ = {}

-- Get UI
_VE_.getUIInfo = function()
    local t = {}
    for m,n in ipairs (screen.children) do
        if n.to_json then 
            table.insert(t, json:parse(n:to_json()))
        end
    end
    
    print("getUIInfo"..json_head..json:stringify(t)..json_tail)
end 

-- Get Style 
_VE_.getStInfo = function()
    local t = {}
    table.insert(t, json:parse(WL.get_all_styles()))
    print("getStInfo"..json:stringify(t))
end 

-- Ret Style
_VE_.repStInfo = function()
    local t = {}
    table.insert(t, json:parse(WL.get_all_styles()))
    print("repStInfo"..json:stringify(t))
end 

-- Execute Debugger 
_VE_.exeDebugger = function()
    editor_lb:execute(debugger_script.." "..current_dir)
end 

-- Print Object Name
_VE_.printInstanceName = function(layernames)

    theNames =""

    for m,n in ipairs (screen.children) do
        if util.isLayerObj(n) == true then 
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
    print("prtObjNme"..theNames)
end 

-- Move Content 
_VE_.contentMove = function(newChildGid, newParentGid, lmRow, lmCol, lmChild,lmParentGid)
    local newChild = devtools:gid(newChildGid)
    local newParent = devtools:gid(newParentGid)
    local lmParent 
    
    if lmChild == false then 
        newChild:unparent()
    end 

    blockReport = true 

    screen_ui.n_selected(newChild)
    screen_ui.n_selected(newParent)

    -- Drop into Layer 

    if util.is_this_container(newParent) == false then  
        if lmParentGid then
            lmParent = devtools:gid(lmParentGid)
            if lmParent.widget_type  == "LayoutManager" then 
                for r = 1, lmParent.number_of_rows, 1 do 
                    for c = 1, lmParent.number_of_cols, 1 do 
                        if lmParent.cells[r][c].gid == newChildGid then 
                            lmParent.cells[r][c] = nil    
                        end 
                    end 
                end 
            elseif lmParent.widget_type  == "MenuButton" then
                newChild:unparent()

                local sz = lmParent.items.length
                for i=1, sz, 1 do 
                    if i and lmParent.items[i].name == newChild.name then 
                        lmParent.items:remove(i)
                        break
                    end
                end
            end 
        end 
		newChild.group_position = {0,0,0}
		newChild.position = {0,0,0}
        newChild.is_in_group = false
        newChild.parent_group = nil
        newChild.reactive = true
        util.create_mouse_event_handler(newChild, newChild.widget_type)
        newParent:add(newChild)

    -- Drop into Container 

    else

        newChild.position = {0,0,0}
        newChild.is_in_group = true
        newChild.parent_group = newParent
		newChild.group_position = newParent.position

        if newParent.widget_type == "LayoutManager" then 
            if lmRow and lmCol then 
                lmRow = lmRow + 1 
                lmCol = lmCol + 1

                if lmRow > newParent.number_of_rows then 
                    newParent.cells:insert_row(lmRow, {})
                elseif lmCol > newParent.number_of_cols then 
                    newParent.cells:insert_col(lmCol, {})
                end
            else
                lmRow = newParent.number_of_rows + 1
                lmCol = 1
                newParent.cells:insert_row(lmRow, {})
            end 
            newParent.cells[lmRow][lmCol] = newChild
        elseif newParent.widget_type == "TabBar" then 
            if lmRow then 
			    newParent.tabs[lmRow].contents:add(newChild) 
            else 
                newIndex = newParent.tabs.length + 1
                newParent.tabs:insert(newIndex, {label="Tab"..newIndex, contents = WL.Widget_Group{}})
			    newParent.tabs[newIndex].contents:add(newChild) 
            end 
        elseif newParent.widget_type == "MenuButton" then 
            newChild:unparent()
            local newIndex
            if newParent.items.length then 
                newIndex = newParent.items.length + 1
            else
                newIndex = 1
            end
            newParent.items:insert(newIndex, newChild)
        else
            newParent:add(newChild)
        end
    end
    blockReport = false 

    _VE_.refresh()
end 

_VE_.alignLeft = function(gid)

    local basis_obj_name, basis_obj, sel_objs = editor.arrange_prep(gid)
   
    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true and v.name ~= basis_obj_name) then
		    if(v.x ~= basis_obj.x) then
			  	v.x = basis_obj.x
		    end
    	end
    end

    editor.arrange_end(gid, basis_obj, sel_objs)

end 

_VE_.alignRight = function(gid)

    local basis_obj_name, basis_obj, sel_objs = editor.arrange_prep(gid)

    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true and v.name ~= basis_obj_name) then
		   if(v.x ~= basis_obj.x + basis_obj.w - v.w) then
			v.x = basis_obj.x + basis_obj.w - v.w
		   end
		end 
    end

    editor.arrange_end(gid, basis_obj, sel_objs)

end 

_VE_.alignTop = function(gid)

    local basis_obj_name, basis_obj, sel_objs = editor.arrange_prep(gid)
    
    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true and v.name ~= basis_obj_name ) then
		  --   screen_ui.n_selected(v)
		  if(v.y ~= basis_obj.y) then
			v.y = basis_obj.y 
		  end 
		end 
   end

    editor.arrange_end(gid, basis_obj, sel_objs)
    
end 

_VE_.alignBottom = function(gid)

    local basis_obj_name, basis_obj, sel_objs = editor.arrange_prep(gid)
    
    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true and  v.name ~= basis_obj_name) then
		    --screen_ui.n_selected(v)
		    if(v.y ~= basis_obj.y + basis_obj.h - v.h) then 	
			    v.y = basis_obj.y + basis_obj.h - v.h 
		    end 
		end 
    end

    editor.arrange_end(gid, basis_obj, sel_objs)

end 
 
_VE_.alignHorizontalCenter = function(gid)

    local basis_obj_name, basis_obj, sel_objs = editor.arrange_prep(gid)
    
    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true and v.name ~= basis_obj_name) then
		    -- screen_ui.n_selected(v)
		    if(v.x ~= basis_obj.x + basis_obj.w/2 - v.w/2) then 
			    v.x = basis_obj.x + basis_obj.w/2 - v.w/2
		    end
		end 
    end

    editor.arrange_end(gid, basis_obj, sel_objs)

end 
 
_VE_.alignVerticalCenter = function(gid)

    local basis_obj_name, basis_obj, sel_objs = editor.arrange_prep(gid)

    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true and v.name ~= basis_obj_name) then
		-- screen_ui.n_selected(v)
		    if(v.y ~=  basis_obj.y + basis_obj.h/2 - v.h/2) then 
			    v.y = basis_obj.y + basis_obj.h/2 - v.h/2
		    end
		end 
    end
  
    editor.arrange_end(gid, basis_obj, sel_objs)
end 

_VE_.distributeHorizontal = function(gid)

    local obj_name, obj, sel_objs = editor.arrange_prep(gid)
    
    local x_table = {}
    local temp_w = 0
    local next_x = 0 
    local next_pos = 0 
    local min = screen.w
    local max = 0
    local distance = 0

    for i,j in ipairs (curLayer.children) do
        if j.extra.ve_selected == true then 
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
        if j.extra.ve_selected == true then 
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
            if j.extra.ve_selected == true then 
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

    editor.arrange_end(gid, obj, sel_objs)
end 

_VE_.distributeVertical = function(gid)

    local obj_name, obj, sel_objs = editor.arrange_prep(gid)
    
    local y_table = {}
    local temp_h = 0
    local next_y = 0 
    local next_pos = 0 
    local min = screen.h
    local max = 0
    local distance = 0

    for i,j in ipairs (curLayer.children) do
        if j.extra.ve_selected == true then 
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
        if j.extra.ve_selected == true then 
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
            if j.extra.ve_selected == true then 
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

    editor.arrange_end(gid, obj, sel_objs)
end 

_VE_.bringToFront = function(gid)

    local obj_name, obj, sel_objs = editor.arrange_prep(gid)

    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true) then
			curLayer:remove(v)
			curLayer:add(v)
			--screen_ui.n_selected(v)
        end
    end

    editor.arrange_end(gid, obj, sel_objs)
end 


_VE_.bringForward = function(gid)

    local obj_name, obj, sel_objs = editor.arrange_prep(gid)

    local tmp_g = {}
    local slt_g = {}

    for i, v in ipairs(curLayer.children) do
	    curLayer:remove(v) 
		if #slt_g ~= 0 then 
		    table.insert(tmp_g, v)
			table.insert(tmp_g, table.remove(slt_g))
		end 
	    if(v.extra.ve_selected == true) then
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

    while(#tmp_g ~= 0) do
    	v = table.remove(tmp_g)
	    curLayer:add(v)
    end 

    editor.arrange_end(gid, obj, sel_objs)

end

_VE_.sendToBack = function(gid)

    local obj_name, obj, sel_objs = editor.arrange_prep(gid)

    local tmp_g = {}
    local slt_g = {}

    for i, v in ipairs(curLayer.children) do
	    curLayer:remove(v) 
	    if(v.extra.ve_selected == true) then
		    table.insert(slt_g, v)
			screen_ui.n_selected(v)
		else 
		     table.insert(tmp_g, v) 
		end
    end
    
    slt_g = util.get_reverse_t(slt_g) 
    while #slt_g ~= 0 do
	    v = table.remove(slt_g)
	    curLayer:add(v)	
    end 
    
    tmp_g = util.get_reverse_t(tmp_g) 
    while #tmp_g ~= 0 do
	    v = table.remove(tmp_g)
	    curLayer:add(v)	
    end 
	
    editor.arrange_end(gid, obj, sel_objs)

end

_VE_.sendBackward = function(gid)

    local obj_name, obj
    obj_name, obj, sel_objs = editor.arrange_prep(gid)

    local tmp_g = {}
    local slt_g = {}

    for i, v in ipairs(curLayer.children) do
	    curLayer:remove(v)  
		if #slt_g ~= 0 then 
		    local b = table.remove(slt_g)
			local f = table.remove(tmp_g)
			table.insert(tmp_g, b)
			table.insert(tmp_g, f) 
		end 
	    if (v.extra.ve_selected == true) then
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

    editor.arrange_end(gid, obj, sel_objs)
   
end

_VE_.setCurrentProject = function(path)
    screen.name = path 
end 

_VE_.refreshDone = function()

    buildInsp = false
    openFile= false

end 

_VE_.refresh = function()

    if buildInsp == false then
        _VE_.getUIInfo()
        _VE_.getStInfo()
        buildInsp = true
    end

end 

-- Ungroup
_VE_.ungroup = function(gid)

    editor.ungroup(gid)
 
end 

-- Clone
_VE_.clone = function(gid)
    editor.clone(gid)
end 

-- Duplicate
_VE_.duplicate = function(gid)
    editor.duplicate(gid)
end 

-- Delete
_VE_.delete = function(gid)
    del_obj = devtools:gid(gid)
    screen_ui.n_selected(del_obj)

    pGroup = del_obj.parent_group 
    local idx, didx
    if pGroup then 
        if pGroup.widget_type == "MenuButton" then 
            idx = 0 
            while pGroup.items.length > idx do
                idx = idx +1 
                if pGroup.items[idx].gid == gid then
                    pGroup.items:remove(idx)
                end
            end 
        elseif pGroup.widget_type == "LayoutManager" then 
            for r = 1, pGroup.number_of_rows, 1 do
                for c = 1, pGroup.number_of_cols, 1 do
                    if pGroup.cells[r][c].gid == gid then
                        pGroup.cells[r][c] = nil 
                    end
                end
            end
        end
    end
        
    del_obj.parent:remove(del_obj)
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
        end 
	    screen_ui.selected(uiInstance) 
    elseif property == 'visible' then 
        uiInstance[property] = value 
        if value == false then 
            _VE_.deselectUIElement(uiInstance.gid, false)
        else
            if string.find(uiInstance.name, "Layer") == nil then  
                _VE_.selectUIElement(uiInstance.gid, false)
            else 
                _VE_.deselectUIElement(uiInstance.gid, false)
            end
        end
    elseif property == "anchor_point" then 
        ax = table.remove(value, 1)
        ay = table.remove(value, 1) 
        uiInstance:move_anchor_point(ax, ay)
	    screen_ui.selected(uiInstance) 
    elseif n ~= nil then 
        uiInstance['tabs'][n].label = value 
	    screen_ui.selected(uiInstance) 
    else
        uiInstance[property] = value 
	    screen_ui.selected(uiInstance) 
    end 
    if property == 'style' then 
        _VE_.refresh()
        _VE_.refreshDone()
    else 
        _VE_.repUIInfo(uiInstance)
    end
end 

-- REPORT 
_VE_.focusInfo = function(uiInstance)
    if blockReport == true then 
        return
    end 
    if input_mode == hdr.S_FOCUS then 
        return 
    end 
    if uiInstance.focused then
        print("focusInfo"..uiInstance.gid..":True")
    else
        print("focusInfo"..uiInstance.gid..":False")
    end 
end 

_VE_.posUIInfo = function(uiInstance)
    if blockReport == true then 
        return
    end 
    print("posUIInfo"..uiInstance.gid..":"..math.floor(uiInstance.x)..":"..math.floor(uiInstance.y)..":")
end 

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

_VE_.clearInspector = function(gid)
    print("clearInsp"..gid)
end

_VE_.openInspector = function(gid, multi)

    if buildInsp == true then
        return
    elseif shift == true or multi then 
        print("openInspc".."t"..gid)
    else
        print("openInspc".."f"..gid)
    end
end 

_VE_.setAppPath = function(path)
    current_dir = path
    currentProjectPath = path 
    editor_lb:change_app_path(path)
    WL = dofile("LIB/Widget/Widget_Library.lua")
end 

_VE_.buildVF = function(path)
    local images_file = "assets/images/images.json"
    local images = readfile(images_file)
    if images and #images > 0 then 
        images = string.gsub (images, "(\n+)", "")
        print("imageInfo"..images)
        spriteSheet = WL.Widget_SpriteSheet { map = images_file } 
    end
end

_VE_.openFile = function(path)

    blockReport = true
    openFile = true
    screen:clear()

    -- Set current app path 
    editor_lb:change_app_path(path)
    current_dir = path

    -- Set VE Background Image
    util.setBGImages(path)

    local layers_file = "screens/layers.json"
    local styles_file = "screens/styles.json"
    local screens_file = "screens/screens.json"
    local image_path = "assets/images/"

    print("scrJSInfo"..readfile(screens_file))

    --the first time this function is called, styles will get set up
    --if not styles then load_styles() end

    -- Read Style JSON
    local style = readfile(styles_file)
    style = string.sub(style, 2, string.len(style)-1)
    if style == nil then
        error("Style '"..styles_file.."' does not exist.",2)
    end

    -- Load Widget Library 
    WL = dofile("LIB/Widget/Widget_Library.lua")

    -- Load Styles 
    VL.load_styles(style) 

    -- Read Layer JSON
    local layer = readfile(layers_file)
    --layer = string.sub(layer, 2, string.len(layer)-1)
    layer = json:stringify(json:parse(layer)[1])

    if layer == nil then
        error("Layer '"..layers_file.."' does not exist.",2)
    end

    -- Image File System 
    _VE_.buildVF()

    -- Load Layer
    s = VL.org_load_layer(layer)
    objectsNames = s.objects

    for i,j in ipairs(s.children) do
        if util.isLayerObj(j) == true then 
            for l,m in ipairs(j.children) do  

                m.x = math.floor(m.x)
                m.y = math.floor(m.y)
                m.z = math.floor(m.z)

                -- Register subscribe_to function
                m.created = false
                if m.subscribe_to then
                   m:subscribe_to({"x", "y", "position"}, function() if dragging == nil then _VE_.posUIInfo(m) end end)
                   m:subscribe_to({"focused"}, function() if dragging == nil then _VE_.focusInfo(m) end  end )
                end

                local uiTypeStr = util.getTypeStr(m) 

                if uiTypeStr == "LayoutManager" then 
                    m.placeholder = WL.Widget_Rectangle{size = {300, 200}, border_width=2, border_color = {255,255,255,255}, color = {255,255,255,0}}
                elseif uiTypeStr == "Widget_Text" then 
                    function m:on_key_down(key)
    	                if key == keys.Return then 
			                m:set{cursor_visible = false}
        	                screen.grab_key_focus(screen)
			                m:set{editable= false}
			                local text_len = string.len(m.text) 
			                local font_len = string.len(m.font) 
	                        local font_sz = tonumber(string.sub(m.font, font_len - 3, font_len -2))	
			                local total = math.floor((font_sz * text_len / m.w) * font_sz *2/3) 
			                if(total > m.h) then 
				                m.h = total 
			                end 
                        end

                        _VE_.repUIInfo(m)
                
    	                if key == keys.Return then 
			                return true
	                    end 
                    end 
                end 

                m.extra.mouse_handler = false

                util.create_mouse_event_handler(m, uiTypeStr)
                    
                -- Contents Setup 
                if util.is_in_list(uiTypeStr, hdr.uiContainersChildrenContents) == true then
                    for o, p in ipairs(m.children) do
                        util.contentSetup(m, p)
                    end 
                elseif uiTypeStr == "TabBar" then
                    local idx = 0
                    while m.tabs.length > idx do 
                        idx = idx + 1 
                        for o, p in ipairs(m.tabs[idx].contents.children) do 
                            util.contentSetup(m, p)
                        end 
                    end 
                elseif uiTypeStr == "LayoutManager" then
                    for r = 1, m.number_of_rows, 1 do 
                        for c = 1, m.number_of_cols, 1 do 
                            if m.cells[r][c].name ~= nil then 
                                util.contentSetup(m, m.cells[r][c])
                            end 
                        end 
                    end 
                elseif uiTypeStr == "MenuButton" then
                    local idx = 0
                    while m.items.length > idx  do
                        idx = idx + 1
                        util.contentSetup(m, m.items[idx])
                    end 
                end 

                if uiTypeStr == "Image" then 
                    m.src = image_path..m.src
                end 

                m.reactive = true 
                m.lock = false
                m.ve_selected = false
                m.is_in_group = false
            end
        end     
        j:unparent()
        screen:add(j)
    end
    
    _VE_.refresh()
    
    blockReport = false

end 

_VE_.screenHide = function()
    screen:hide()
end 
_VE_.screenShow = function()
    screen:show()
end 
_VE_.getScreenLoc = function()
    print("screenLoc"..screen.x..","..screen.y)
end 
_VE_.setScreenLoc = function(x, y)
    if x == 0 and y == 0  then 
        screen.y = 204
        screen.x = 338
    else
        screen.y = y
        screen.x = x
    end 
end 

_VE_.newLayer = function()
    for m,n in ipairs (screen.children) do
        if n.name == "Layer"..layerNum then 
            layerNum = layerNum + 1
        end
    end 
    local newLayer = WL.Widget_Group{name="Layer"..layerNum, size={1920, 1080}, position={0,0,0}}
    screen:add(newLayer)
    layerNum = layerNum + 1
    _VE_.repUIInfo(newLayer)
end 

local codeExist = function(contents, layer, obj) 
    if string.find(contents, "[-][-] BEGIN "..layer.."."..obj.." SECTION") then 
        return true 
    else 
        return false
    end 
end 

local objCodeGen = function(contents, layer, lowLayer, obj) 

    if obj.widget_type == "Button" then 
        contents = contents.."-- BEGIN "..layer.."."..obj.name.." SECTION [DO NOT CHANGE THIS LINE]\n\t" 
        contents = contents..lowLayer..".elements."..obj.name..".on_pressed = function() end\n\t"
        contents = contents..lowLayer..".elements."..obj.name..".on_released = function() end\n"
        contents = contents.."-- END "..layer.."."..obj.name.." SECTION [DO NOT CHANGE THIS LINE]\n\n" 
    elseif obj.widget_type == "CheckBox" or obj.widget_type == "RadioButton" then 
        contents = contents.."-- BEGIN "..layer.."."..obj.name.." SECTION [DO NOT CHANGE THIS LINE]\n\t" 
        contents = contents..lowLayer..".elements."..obj.name..".on_selection = function() end\n\t"
        contents = contents..lowLayer..".elements."..obj.name..".on_deselection = function() end\n"
        contents = contents.."-- END "..layer.."."..obj.name.." SECTION [DO NOT CHANGE THIS LINE]\n\n" 
    elseif obj.widget_type == "ToastAlert" then 
        contents = contents.."-- BEGIN "..layer.."."..obj.name.." SECTION [DO NOT CHANGE THIS LINE]\n\t" 
        contents = contents..lowLayer..".elements."..obj.name..".on_completed = function() end\n"
        contents = contents.."-- END "..layer.."."..obj.name.." SECTION [DO NOT CHANGE THIS LINE]\n\n" 
    end 

    return contents 
end 

local codeGen = function()
    for a,b in ipairs (screen.children) do 
        if b.name and string.find(b.name, "Layer") then 
            local layerName = b.name
            local lowLayerName = string.lower(layerName)
            local contents = readfile(lowLayerName..".lua")

            --local contents_header = "local "..lowLayerName.." = ...\n" 
            local contents_header = "-- OBJECT HANDLERS SECTION [ DO NOT CHANGE THIS SECTION ]\nlocal function object_handlers("..lowLayerName..", VL)\n-- END OBJECT HANDLERS SECTION [ DO NOT CHANGE THIS SECTION ]\n\n" 
            --local contents_tail = "return "..lowLayerName 
            local contents_tail = "-- RETURN OBJECT HANDLERS SECTION [ DO NOT CHANGE THIS SECTION ]\n\treturn "..lowLayerName.."\nend\nreturn object_handlers\n-- END RETURN OBJECT HANDLERS SECTION [ DO NOT CHANGE THIS SECTION ]"

            if contents ~= nil and b.elements ~= nil then 
                local new_contents = ""

                for i, j in pairs(b.elements) do 
                    if not codeExist(contents, layerName, j.name) then 
                        new_contents = objCodeGen(new_contents, layerName, lowLayerName, j) 
                    end
                end 

				local c,d,e,f, contents_last
				
                c, d = string.find(contents, "-- END OBJECT HANDLERS SECTION %[ DO NOT CHANGE THIS SECTION %]\n\n")
				if d~=nil then 
					 contents_last = string.sub(contents, d+1, -1)
				end

                -----------------------------------
				local temp = contents_last 
                local backup_obj = {}

                c, d = string.find(temp, "[-][-] BEGIN ")

                while c ~=nil do 
                    temp = string.sub(temp, d+1, -1)
                    c, d = string.find(temp, "[.]")
                    e, f = string.find(temp, " ")
                    obj_name = string.sub(temp, d+1, f-1) 

                    if b.elements[obj_name] == nil then 
                        table.insert(backup_obj, obj_name)
                    end 
                    temp = string.sub(temp, f+1, -1)
                    c, d = string.find(temp, "[-][-] BEGIN ")
                end 

                local temp_first, temp_last, temp_middle
                for k, l in ipairs(backup_obj) do 
                    if b.elements[l] == nil then  
                        c, d = string.find(contents_last, " BEGIN "..layerName.."."..l.." SECTION")
                        temp_first = string.sub(contents_last, 1, c-1)
                        e, f = string.find(contents_last, "-- END "..layerName.."."..l.." SECTION")
                        temp_last = string.sub(contents_last, f+27, -1)
                        temp_middle = string.sub(contents_last, c, f+26)
                        contents_last = temp_first.."[=["..temp_middle.." ]=]"..temp_last
                    end 
                end 

                -----------------------------------

				contents = contents_header..new_contents..contents_last
                editor_lb:writefile(lowLayerName..".lua", contents, true)

            else
                
                contents = contents_header

                if b.elements then 
                    for i, j in pairs(b.elements) do 
                        contents = objCodeGen(contents, layerName, lowLayerName, j) 
                    end 
                end

                contents = contents..contents_tail
                editor_lb:writefile(lowLayerName..".lua", contents, true)
            end 
        end 
    end

end 

_VE_.saveFile = function(scrJson, path)

    local layer_t = {}
    local style_t = {}

    table.insert(style_t, json:parse(WL.get_all_styles()))

    for a, b in ipairs (screen.children) do
        if b.to_json then -- s1.b1
            table.insert(layer_t, json:parse(b:to_json()))
        end
    end

    editor_lb:writefile("/screens/layers.json", sjson_head..json:stringify(layer_t)..sjson_tail, true) 
    editor_lb:writefile("/screens/styles.json", json:stringify(style_t), true) 
    editor_lb:writefile("/screens/screens.json", scrJson, true) 
    
    if currentProjectPath == nil and path ~= nil then 
        currentProjectPath = path
    end 

    _VE_.setAppPath(currentProjectPath)
    _VE_.openFile(currentProjectPath)
    codeGen()

end 

_VE_.black = function()
    BG_IMAGE_20.opacity = 0
    BG_IMAGE_40.opacity = 0
    BG_IMAGE_80.opacity = 0
    BG_IMAGE_white.opacity = 0
    BG_IMAGE_import.opacity = 0
end

_VE_.backgroundImage = function(dir_path, image_path)
    _VE_.black()
    editor_lb:change_app_path(dir_path)
    BG_IMAGE_import.src = image_path  
    if BG_IMAGE_import.loaded == true then
        BG_IMAGE_import.opacity = 255  
        editor_lb:change_app_path(current_dir)
    end
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
    if y ~= nil then 
        selected_guideline.y = y - 10 
        util.close_guideInspector()
    else 
        util.close_guideInspector()
    end
end 

_VE_.setVGuideX = function(x)
    if x ~= nil then 
        selected_guideline.x = x - 10 
        util.close_guideInspector()
    else
        util.close_guideInspector()
    end
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
            snapToGuide = false
	else 
            snapToGuide = true
	end
	screen:grab_key_focus()
end

_VE_.insertUIElement = function(layerGid, uiTypeStr, path)

    local uiInstance, dragging = nil 

    util.getCurLayer(layerGid)

    blockReport = true

    -- Create uiInstance 
    if string.find(uiTypeStr, "Rectangle") then 

        input_mode = hdr.S_RECTANGLE 
	 	screen_ui.cursor_setting()
        screen:grab_key_focus()
        return

    elseif string.find(uiTypeStr, "Group") then 
        
        uiInstance = editor.group()
        if uiInstance == nil then 
            return
        end 

    elseif string.find(uiTypeStr, "Clone") then 
        editor.clone()
        return

    elseif hdr.uiElementCreate_map[uiTypeStr] then
        uiInstance = hdr.uiElementCreate_map[uiTypeStr]()
    end 
    
    -- Default Settings
    if uiTypeStr == "ButtonPicker" then 
        uiInstance.items = {"item1","item2","item3"}
    elseif uiTypeStr == "LayoutManager" then 
        uiInstance:set{
            number_of_rows = 2,
            number_of_cols = 3,
            placeholder = WL.Widget_Rectangle{ size = {300, 200}, border_width=2, border_color = {255,255,255,255}, color = {255,255,255,0}},
            cells = {
            }
        }
    elseif uiTypeStr == "Slider" then 
       uiInstance:set{x=500, y = 300, grip_w = 50, grip_h = 20, track_w = 500, track_h = 50}
    elseif uiTypeStr == "ProgressSpinner" then 
        uiInstance:set{x=500, y = 300, size = {100,100} }
    elseif uiTypeStr == "OrbittingDots" then 
        uiInstance:set{x=500, y = 300, size = {200,200} }
        uiInstance.num_dots = 10
    elseif uiTypeStr == "ProgressBar" then 
        uiInstance:set{x=500, y = 300, size = {300,50} }
        uiInstance.progress = 0.25
    elseif uiTypeStr == "TextInput" then 
       uiInstance:set{enabled = false, size = {300,200}}
    elseif uiTypeStr == "TabBar" then 
        uiInstance:set{ 
             position = {100,100},
             tabs = {
                {label="One" , contents = WL.Widget_Group()}, 
                {label="Two",   contents = WL.Widget_Group()},
                {label="Three", contents = WL.Widget_Group()},
            }
        }
    elseif uiTypeStr == "Text" or uiTypeStr == "Widget_Text" then 
        editor.text(uiInstance)
    end
        
    -- Assign uiInstance name 
    if uiTypeStr == "Image" then 
        util.assign_right_name(uiInstance, path)
        uiInstance.sheet = spriteSheet
        uiInstance.id = path
    else 
        util.assign_right_name(uiInstance, uiTypeStr)
    end


    if uiInstance ~= nil then 
        uiInstance.mouse_handler = false 
        util.create_mouse_event_handler(uiInstance, uiTypeStr)
        if util.is_this_container(uiInstance) then
            uiInstance.container_selected = false
        end
        print("newui_gid"..uiInstance.gid)
        util.addIntoLayer(uiInstance)
    end

    blockReport = false
    _VE_.repUIInfo(uiInstance)

end

_VE_.imageNameChange = function(org, new)


    for m,n in ipairs (screen.children) do
        if util.isLayerObj(n) == true then 
            for q,w in ipairs (n.children) do 
                if w.widget_type == "Widget_Sprite" and w.id == org then 
                    w.id = new 
                end 
            end
        end
    end 
end 


_VE_.selectUIElement = function(gid, multiSel)
    local org_shift = shift
    if multiSel == true then
        shift = multiSel
    end
    local obj = devtools:gid(gid)

    if obj.widget_type == "MenuButton" then
        local idx = 0 
        while obj.items.length > idx  do
            idx = idx + 1
            screen:remove(screen:find_child(obj.items[idx].name.."border"))
            -- remove red cross mark showing anchor point
            screen:remove(screen:find_child(obj.items[idx].name.."a_m"))
            obj.items[idx].extra.ve_selected = false
        end
    end 

    if gid ~= screen.gid then
        screen_ui.selected(obj)
    end 
    shift = org_shift
end 

_VE_.deselectAll = function()
    screen_ui.n_selected_all()
end 

_VE_.deselectUIElement = function(gid, multiSel)
    local org_shift = shift
    blockReport = true
    if multiSel == true then
        shift = multiSel
    end 

    if gid ~= screen.gid then
        screen_ui.n_selected(devtools:gid(gid))
    end
    blockReport = false
    shift = org_shift
end 

_VE_.focusSettingMode = function(key)
    input_mode = hdr.S_FOCUS
    focusKey = key
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
    	if key == keys.Control_L or key == keys.Control_R then control = false  screen_ui.container_deselected() end 

    end

	function screen:on_button_down(x,y,button,num_clicks,m)

        print("screen onbuttondown !!!")

        local multi_bdr = screen:find_child("multi_select_border") 

        if multi_bdr then 
            screen:remove(multi_bdr)
        end

        if input_mode == hdr.S_FOCUS then 
            local selObj = screen_ui.getSelectedObj()

            if selObj then 
                blockReport = true
                hdr.neighberKey_map[focusKey](selObj, nil) 
                blockReport = false
            end 
    
            print("focusSet2".."empty")
            input_mode = hdr.S_SELECT
            return true 
        else 
            print("openInspc".."f"..screen.gid)
        end

      	mouse_state = hdr.BUTTON_DOWN 		

		if current_focus and input_mode ~=  hdr.S_RECTANGLE then 
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

	function screen:on_button_up(x,y,button,clicks_count, m)

        print ("screen onbuttonup !!!")
		screen_ui.dragging_up(x,y)

	  	dragging = nil

        if (mouse_state == hdr.BUTTON_DOWN) then
            if input_mode == hdr.S_RECTANGLE then 
	           editor.rectangle_done(x, y) 
	           input_mode = hdr.S_SELECT 
	      	else
				screen_ui.multi_select_done(x,y)
	      	end 
       	end

       	mouse_state = hdr.BUTTON_UP

	end

    function screen:on_motion(x,y)

	 	screen_ui.cursor_setting()
	 	screen_ui.dragging(x,y)

        if(mouse_state == hdr.BUTTON_DOWN) then
            if (input_mode == hdr.S_RECTANGLE) then 
				editor.rectangle_move(x, y) 
			end
            if (input_mode == hdr.S_SELECT) then 
		    	screen_ui.multi_select_move(x, y) 
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

        WL.Style:subscribe_to(styleUpdate)
        screen.reactive = true
        util.setBGImages()

        print("<<VE_READY>>:")

    end 

    screen:show()
    dolater(main)



