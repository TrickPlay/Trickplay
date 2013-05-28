local editor = {}
local rect_init_x = 0
local rect_init_y = 0
local g_init_x = 0
local g_init_y = 0
local next_position 

local menuButtonView 

---------------------------------------------
-- Rectangle --------------------------------
---------------------------------------------

local rect_init_x = 0
local rect_init_y = 0

function editor.rectangle(x, y)

    local dragging = nil 

    rect_init_x = x 
    rect_init_y = y 
    
    uiRectangle = WL.Widget_Rectangle()

    util.assign_right_name(uiRectangle, "Rectangle")

    uiRectangle.size = {1,1}
    uiRectangle.color= hdr.DEFAULT_COLOR
    uiRectangle.position = {x,y,0}
    uiRectangle.org_x = x
    uiRectangle.org_y = y

    util.create_mouse_event_handler(uiRectangle,"Widget_Rectangle")

    util.addIntoLayer(uiRectangle)

    return uiRectangle
end 


function editor.rectangle_move(x,y)

	if uiRectangle then 
        uiRectangle.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
        if(x- rect_init_x < 0) then
            uiRectangle.x = x
        end
        if(y- rect_init_y < 0) then
            uiRectangle.y = y
        end
	end

end


function editor.rectangle_done(x,y)
	if uiRectangle == nil then return end 
    uiRectangle.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
    if(x-rect_init_x < 0) then
    	uiRectangle.x = x
    end
    if(y-rect_init_y < 0) then
    	uiRectangle.y = y
    end

    _VE_.refresh()
    blockReport = false
    _VE_.refreshDone()
    _VE_.openInspector(uiRectangle.gid, false)
    _VE_.repUIInfo(uiRectangle)
    screen.grab_key_focus(screen)

end 

---------------------------------------------
-- Text -------------------------------------
---------------------------------------------

function editor.text(uiText)

    uiText.position ={0, 0, 0}
	--uiText.wants_enter = true
	uiText.editable = true
	uiText.text = "Hello World"
    uiText.font= "FreeSans Medium 30px"
    uiText.color = "white"
    uiText.reactive = true
    --uiText.wrap=true 
    --uiText.wrap_mode="CHAR" 
	--extra = {org_x = 200, org_y = 200}

    uiText:grab_key_focus()

    function uiText:on_key_down(key,u,t,m)
    	if key == keys.Return then 
			uiText:set{cursor_visible = false}
        	screen.grab_key_focus(screen)
			uiText:set{editable= false}
			local text_len = string.len(uiText.text) 
			local font_len = string.len(uiText.font) 
	        local font_sz = tonumber(string.sub(uiText.font, font_len - 3, font_len -2))	
			local total = math.floor((font_sz * text_len / uiText.w) * font_sz *2/3) 
			if(total > uiText.h) then 
				uiText.h = total 
			end 
        end

        _VE_.repUIInfo(uiText)

    	if key == keys.Return then 
			return true
	    end 

	end 
end 


---------------------------------------------
-- Clone ------------------------------------
---------------------------------------------
function editor.clone(gid)

    blockReport = true
    v = devtools:gid(gid)
	uiClone = WL.Widget_Clone {
	    source = v,
        position = {v.x + 20, v.y +20}
    }
    util.assign_right_name(uiClone, "Clone")

    util.create_mouse_event_handler(uiClone, "Clone")

    curLayer = devtools:gid(gid).parent
    util.addIntoLayer(uiClone, true)

    if v.extra.clone then 
	    table.insert(v.extra.clone, uiClone.name)
	else 
	    v.extra.clone = {}
		table.insert(v.extra.clone, uiClone.name)
	end 

    curLayer:add(uiClone)

    blockReport = false
    _VE_.repUIInfo(uiClone)

end

---------------------------------------------
-- Group ------------------------------------
---------------------------------------------
function editor.group()

    blockReport = true

	if util.getSelectedObjCnt()  == 0 then 
		print ("there is no selected object")
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return nil
   	end 

    local min_x, max_x, min_y, max_y = util.get_min_max () 
       
    uiGroup = WL.Widget_Group{
        position = {min_x, min_y}
    }


	for i, v in pairs(curLayer.children) do
		if(v.ve_selected == true) then
			screen_ui.n_selected(v)
			v:unparent()
			v.is_in_group = true
            v.parent_group = uiGroup
			v.group_position = uiGroup.position
			v.x = v.x - min_x
			v.y = v.y - min_y
        	uiGroup:add(v)
		end 
    end

    blockReport = false

	input_mode = hdr.S_SELECT
	uiGroup.size = {math.floor(uiGroup.w),math.floor(uiGroup.h)}

    return uiGroup
end

---------------------------------------------
-- UnGroup ----------------------------------
---------------------------------------------
   
function editor.ungroup(gid)

    util.getCurLayer(gid) 

    if  util.getSelectedObjCnt() == 0 then 
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

    blockReport = true
    for i, v in pairs(curLayer.children) do
        if curLayer:find_child(v.name) then
		  	if(v.extra.ve_selected == true) then
				if util.is_this_group(v) == true then
			     	screen_ui.n_selected(v)
			     	for i,c in pairs(v.children) do 
						c:unparent()
				     	c.extra.is_in_group = false
				     	c.x = c.x + v.x 
				     	c.y = c.y + v.y 
						c.reactive = true	
                        if c.widget_type == "Widget" then 
                            uiTypeStr = c.widget_type..c.type
                        else 
                            uiTypeStr = c.widget_type
                        end
                        util.create_mouse_event_handler(c, uiTypeStr)
                        util.addIntoLayer(c, true)
			     	end
			     	curLayer:remove(v)
		        end 
		   end 
		end
	end

	input_mode = hdr.S_SELECT
    blockReport = false

end

---------------------------------------------
-- Duplicate --------------------------------
---------------------------------------------

local function duplicate_child(new, org)

    local uiTypeStr, n, l, m

    for l,m in pairs (org.children) do 

        uiTypeStr = util.getTypeStr(m) 

        if hdr.uiElementCreate_map[uiTypeStr] then
            n = hdr.uiElementCreate_map[uiTypeStr](m.attributes)
        end 

        util.assign_right_name(n, uiTypeStr)

        n.reactive = false
        n.lock = false
        n.ve_selected = false
        n.is_in_group = true

        if n.subscribe_to then  
            n:subscribe_to({"x", "y", "position"}, function() if dragging == nil then _VE_.posUIInfo(n) end end)
            n:subscribe_to({"focused"}, function() if dragging == nil then _VE_.focusInfo(n) end  end )
        end 

        if uiTypeStr == "Widget_Group" then  
            duplicate_child(n, m)
        end

        new:add(n) 
    end 

end 
 
local function contentsNameAssign(v) 
	local itemType = util.getTypeNameStr(v) 
    if itemType == "image" then
        util.assign_right_name(v, v.id)
    else
        util.assign_right_name(v, itemType)

        if itemType == "group" or itemType == "DialogBox" then 
            for i,j in pairs (v.children) do 
                j = contentsNameAssign(j)
            end 
        elseif itemType == "LayoutManager" then 
            for r = 1, v.number_of_rows, 1 do 
                for c = 1, v.number_of_cols, 1 do 
                    local item = v.cells[r][c]
                    item = contentsNameAssign(item)
                end 
            end 
        elseif itemType == "MenuButton" then 
            local sz = v.items.length
            for i=1, sz, 1 do 
                print (v.items[i].name)
                v.items[i] = contentsNameAssign(v.items[i])
                print (v.items[i].name)
            end
        end 
    end 

    return v
end 

function editor.duplicate(gid)

    blockReport = true

    v = devtools:gid(gid)

	if uiDuplicate then
	    if uiDuplicate.name == v.name then 
		    next_position = {2 * v.x - uiDuplicate.position[1], 2 * v.y - uiDuplicate.position[2]}
		else 
		    uiDuplicate = nil 
			next_position = nil 
		end 
	end 

	uiTypeStr = util.getTypeStr(v) 

    if hdr.uiElementCreate_map[uiTypeStr] then
        uiDuplicate = hdr.uiElementCreate_map[uiTypeStr](v.attributes)
    end 

    if uiTypeStr == "LayoutManager" then 
        uiDuplicate.placeholder = WL.Widget_Rectangle{size = {300, 200}, border_width=2, border_color = {255,255,255,255}, color = {255,255,255,0}}
    end

    uiDuplicate.position = {v.x + 20, v.y +20}

	uiTypeStr = util.getTypeNameStr(v) 
    uiDuplicate = contentsNameAssign(uiDuplicate)

    util.create_mouse_event_handler(uiDuplicate, uiTypeStr)

    curLayer = devtools:gid(gid).parent
    util.addIntoLayer(uiDuplicate, true)

    blockReport = false
    _VE_.repUIInfo(uiDuplicate)

end


---------------------------------------------
-- Arrange ----------------------------------
---------------------------------------------

local copy_selected_objs = {} 

function editor.arrange_prep (gid) 

    util.getCurLayer(gid)
    blockReport = true

	if util.getSelectedObjCnt() == 0 then 
        screen:grab_key_focus()
		input_mode = hdr.S_SELECT
		return 
   	end 

    util.org_cord()

    local sel_objs = util.table_copy(util.getSelectedObjs())
        
    local basis_obj_name = util.getObjName(util.getSelectedObjs()[1])
    local basis_obj = curLayer:find_child(basis_obj_name)

    return basis_obj_name, basis_obj, sel_objs

end

function editor.arrange_end (gid, obj, sel_objs) 

    util.ang_cord()
    screen.grab_key_focus(screen)
    input_mode = hdr.S_SELECT
    blockReport = false
    _VE_.refresh() 
    _VE_.refreshDone()
    screen_ui.n_selected_all()
end 

return editor
