------------
-- Utils 
-----------
local util = {}
local containerOrder 
local numberOfItems 
local oupperObj, tupperObj

local uiElementCreate_map = 
{
    ['Widget_Clone'] = function(p)  return WL.Widget_Clone(p) end, 
    ['Clone'] = function(p)  return WL.Widget_Clone(p) end, 
    ['Group'] = function(p)  return WL.Widget_Group(p) end, 
    ['Widget_Group'] = function(p)  return WL.Widget_Group(p) end, 
    ['Rectangle'] = function(p)  return WL.Widget_Rectangle(p) end, 
    ['Widget_Rectangle'] = function(p)  return WL.Widget_Rectangle(p) end, 
    ['Text'] = function(p)  return WL.Widget_Text(p) end, 
    ['Widget_Text'] = function(p)  return WL.Widget_Text(p) end, 
    ['Image'] = function(p)  return WL.Widget_Sprite(p) end, 
    ['Widget_Sprite'] = function(p)  return WL.Widget_Sprite(p) end, 
    ['Button'] = function(p)  return WL.Button(p) end, 
    ['DialogBox'] = function(p) return WL.DialogBox(p) end,
    ['ToastAlert'] = function(p) return WL.ToastAlert(p) end,
    ['ProgressSpinner'] = function(p) return WL.ProgressSpinner(p) end,
    ['OrbittingDots'] = function(p) return WL.OrbittingDots(p) end,
    ['TextInput'] = function(p) return WL.TextInput(p) end,
    ['LayoutManager'] = function(p)  return WL.LayoutManager(p) end, 
    ['Slider'] = function(p)  return WL.Slider(p) end, 
    ['ArrowPane'] = function(p)  return WL.ArrowPane(p) end, 
    ['ScrollPane'] = function(p)  return WL.ScrollPane(p) end, 
    ['TabBar'] = function(p)  return WL.TabBar(p) end, 
    ['ButtonPicker'] = function(p)  return WL.ButtonPicker(p) end, 
    ['MenuButton'] = function(p)  return WL.MenuButton(p) end, 
}

local uiElementName_map = 
{
    ['Widget_Clone'] = function()  return "clone" end,
    ['Widget_Group'] = function()  return "group" end,
    ['Widget_Rectangle'] = function()  return "rectangle" end,
    ['Widget_Text'] = function()  return "text" end,
    ['Widget_Sprite'] = function()  return "image" end,
}

function util.addIntoLayer (uiInstance, group)

    uiInstance.reactive = true
    uiInstance.lock = false
    uiInstance.ve_selected = false
    uiInstance.is_in_group = false

    if curLayer then 
        curLayer:add(uiInstance)
    end

    -- regisiger subscribe_to function to new ui instance
    if uiInstance.subscribe_to then  
        uiInstance:subscribe_to({"x", "y", "position"}, function() if dragging == nil then  _VE_.posUIInfo(uiInstance) end end) 
        uiInstance:subscribe_to({"focused"}, function() if dragging == nil then _VE_.focusInfo(uiInstance) end  end )
    end 

    return
end 

function util.create_mouse_event_handler(uiInstance, uiTypeStr)

    if uiInstance.extra.mouse_handler == true then 
        return 
    end 

    uiInstance:add_mouse_handler("on_motion",function(self, x,y)
        
        -- draw container border for contents setting 
        if control == true then 
			screen_ui.draw_selected_container_border(x,y) 
		end 

        if dragging then
            local actor , dx , dy = unpack( dragging )

            -- actor's position setting 
            actor.position = { x - dx , y - dy  }

            -- actor's border and anchor_mark position setting 
            if uiInstance.ve_selected == true then 

                local border= screen:find_child(uiInstance.name.."border")
                local anchor_mark= screen:find_child(uiInstance.name.."a_m")
			    local new_pos 

                if uiInstance.is_in_group == true then 

			        local group_pos = util.get_group_position(uiInstance)
			        if group_pos then 
                        new_pos = {x - dx + group_pos[1], y - dy + group_pos[2]} 
                    end

                else 
                    new_pos = {x - dx , y - dy }
                end 

                if border then border.position = new_pos end 
                if anchor_mark then anchor_mark.position = new_pos end

            end 
        end

    end,true)

    uiInstance:add_mouse_handler("on_button_down",function(self,  x , y , button, num_clicks, m, ...)

		if m and m.control then control = true else control = false end 

        dragging = { uiInstance , x - uiInstance.x , y - uiInstance.y }

        uiInstance:grab_pointer()
        
        if control == false or uiInstance.is_in_group == true then

            _VE_.openInspector(uiInstance.gid)

            --TODO : Need to check this if ~ end 

            if uiTypeStr == "Text" or uiTypeStr == "Widget_Text"then 
                uiInstance.cursor_visible = true
                uiInstance.editable= true
                uiInstance.wants_enter= true
                uiInstance:grab_key_focus()
    
                if(num_clicks == 2) then
                    uiInstance.cursor_position = 0
                    uiInstance.selection_end = -1
                else
                    for i=1,string.len(uiInstance.text) do
                        local offset = uiInstance:position_to_coordinates(i-1)[1] + uiInstance.anchor_point[1] + uiInstance.x
                        if(offset >= x ) then
                            uiInstance.cursor_position = i-1
                            uiInstance.selection_end = i-1
                        return true
                        end
                    end
                    uiInstance.cursor_position = -1
                    uiInstance.selection_end = -1
                    return true
                end
            end 

            return true

        elseif control == true and uiInstance.is_in_group == false then 

            _VE_.openInspector(uiInstance.gid)


            editor_lb:set_cursor(52)
			cursor_type = 52
		    selected_content = uiInstance 

            --[[ Show possible containers ]]-- 

            for i, j in ipairs (screen.children) do 
                if j.name and string.find(j.name, "Layer") ~= nil and 
                    string.find(j.name, "a_m") == nil and 
                    string.find(j.name, "border") == nil and
                    j.visible == true  then 
                    for k,l in ipairs (j.children) do 
                        if l.name == uiInstance.name or util.is_this_container(l) == true then 
					        l.org_opacity = l.opacity
					    else
					        l.org_opacity = l.opacity
                       	    l:set{opacity = 50}
				        end 
				    end 
			    end
			end

        end 
        return true
    end,true)

    uiInstance:add_mouse_handler("on_button_up",function(self,  x,y,button)
        
        if input_mode == hdr.S_FOCUS then 
            local selObjName, selObjGid = screen_ui.getSelectedName()
            if selObjName ~= uiInstance.name then 
		        screen_ui.n_selected(uiInstance) 
                if devtools:gid(selObjGid) then 
                    blockReport = true 
                    hdr.neighberKey_map[focusKey](devtools:gid(selObjGid), uiInstance) 
                    blockReport = false 
                end 
                print("focusSet2"..uiInstance.name)
                input_mode = hdr.S_SELECT
            end 
            return true 
        end
		if m  and m.control then control = true else control = false end 

		if screen:find_child("multi_select_border") then
			return 
		end 

        local actor , dx , dy 
        if dragging ~= nil then 
            actor , dx , dy = unpack( dragging )
        end 
        ---[[ Content Setting 
        local c, t 

		if util.is_in_container_group(x,y) and selected_content then 
		        --local c, t = util.find_container(x,y) 
		        c, t = util.find_container(x,y) 
			    if not util.is_this_container(uiInstance) or c.name ~= uiInstance.name then
			        if c and t then 
				        if (uiInstance.extra.ve_selected == true and c.x < uiInstance.x and c.y < uiInstance.y) then 
                            print(uiInstance.parent.name)
                            dumptable(uiInstance.parent.children)
			        	    uiInstance:unparent()
						    if t ~= "TabBar" then
			        	        uiInstance.position = {uiInstance.x - c.x, uiInstance.y - c.y,0}
						    end 

			        	    uiInstance.extra.is_in_group = true
                            
							if screen:find_child(uiInstance.name.."border") then 
			             	    screen:find_child(uiInstance.name.."border").position = uiInstance.position
							end
							if screen:find_child(uiInstance.name.."a_m") then 
			             	    screen:find_child(uiInstance.name.."a_m").position = uiInstance.position 
			        		end 

			        		if t == "ScrollPane" or t == "DialogBox" or  t == "ArrowPane" or t == "Widget_Group" then 

                                if t == "DialogBox" then 
								    uiInstance.y = uiInstance.y - c.separator_y
                                elseif t == "ArrowPane" then 
                                    --uiInstance.x = uiInstance.x - c.style.arrow.size - 2*c.style.arrow.offset
                                    if c.contents_offset[1] then 
                                        print ("xxxxx")
                                        uiInstance.x = uiInstance.x - c.contents_offset[1]
                                    end 
                                    --uiInstance.y = uiInstance.y - c.style.arrow.size - 2*c.style.arrow.offset
                                    if c.contents_offset[2] then 
                                        print ("yyyyy")
                                        uiInstance.y = uiInstance.y - c.contents_offset[2]
                                    end 
                                elseif t == "ScrollPane" then 
                                    uiInstance.x = uiInstance.x + c.virtual_x 
                                    uiInstance.y = uiInstance.y + c.virtual_y
                                end 

                                uiInstance.reactive = true
                                uiInstance.is_in_group = true
                                uiInstance.parent_group = c
		                        --uiInstance.group_position = {}
		                        --uiInstance.group_position[1] = c.x + c.style.arrow.size + 2*c.style.arrow.offset
		                        --uiInstance.group_position[2] = c.y + c.style.arrow.size + 2*c.style.arrow.offset

                                c:add(uiInstance)

                                if blockReport ~= true then
                                    _VE_.refresh()
                                end 

			        	    elseif t == "MenuButton" then 

                                uiInstance.reactive = true
                                uiInstance.is_in_group = true
		                        --uiInstance.group_position = c.position 
                                uiInstance.parent_group = c
                                c.items:insert(c.items.length+1, uiInstance)
                                if blockReport ~= true then
                                    _VE_.refresh()
                                end 
                                
			        	    elseif t == "LayoutManager" then 

				     		    local row , col=  c:r_c_from_abs_x_y(x,y)
                                if col and row then 
                                    uiInstance.reactive = false
                                    uiInstance.is_in_group = true
                                    uiInstance.parent_group = c
		                            uiInstance.group_position = c.position
                                    c.cells[row][col] = uiInstance
                                else 
                                    print " no col, row information error:("
                                end
                                if blockReport ~= true then
                                    _VE_.refresh()
                                end 

			        		elseif t == "TabBar" then 
							    local t_index = c.selected_tab
							    if t_index then 
                                    print("TabBar's new contents x should be set (the arrow size and offset)")
                                    --uiInstance.x = uiInstance.x - c.x - c.style.arrow.size - c.style.arrow.offset
								    uiInstance.y = uiInstance.y - c.y - c.tab_h
                                    uiInstance.reactive = true
                                    uiInstance.is_in_group = true
                                    uiInstance.parent_group = c
		                            uiInstance.group_position = c.position
			            			c.tabs[t_index].contents:add(uiInstance) 
								end
                                if blockReport ~= true then
                                    _VE_.refresh()
                                end 

							elseif t == "Group" or t == "WidgetGroup" then 
							    c:add(uiInstance)
			        		end 

--[[
                            print(c.parent.name)
                            dumptable(c.parent.children)

                            local row , col=  c:r_c_from_abs_x_y(x,y)
                            if col and row then 
                                uiInstance.reactive = false
                                uiInstance.is_in_group = true
                                uiInstance.parent_group = c
		                        uiInstance.group_position = c.position
                                c.cells[row][col] = uiInstance
                            end

                            print(c.parent.name)
                            dumptable(c.parent.children)
]]
			     	      end 
			       		end 
					editor_lb:set_cursor(68)
			    cursor_type = 68
			end 
			if screen:find_child(c.name.."border") and selected_container then 
				screen:remove(screen:find_child(c.name.."border"))
				screen:remove(screen:find_child(c.name.."a_m"))
				screen:remove(screen:find_child(uiInstance.name.."border"))
				screen:remove(screen:find_child(uiInstance.name.."a_m"))
		        selected_container.ve_selected = false
		        selected_content.ve_selected = false
				selected_content = nil
		        selected_container = nil
	        end 
	    end 
        if c then 
            c:raise_to_top()
            if oupperObj and c.parent:find_child(oupperObj.name) then 
                c:lower(oupperObj)
            elseif tupperObj then 
                c:lower(tupperObj)
            end 
        end 

	    -- Content Setting --]] 



        for i, j in ipairs (screen.children) do 
	        if j.name then 
                --if string.find(j.name, "Layer") and j.visible == true then 
                if string.find(j.name, "Layer") ~= nil and 
                   string.find(j.name, "a_m") == nil and 
                   string.find(j.name, "border") == nil 
                   and j.visible == true  then 
                    for k,l in ipairs (j.children) do 
			            if l.extra.org_opacity then 
				            l.opacity = l.extra.org_opacity
				        end 
			        end 
	            end 
	        end 
	    end 

	    local border = screen:find_child(uiInstance.name.."border")
		local am = screen:find_child(uiInstance.name.."a_m") 
	    if(input_mode == hdr.S_SELECT) then
		    local group_pos
	       	if(border ~= nil and dragging ~= nil) then 
		        if (uiInstance.is_in_group == true) then
			        local group_pos = util.get_group_position(uiInstance)
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
	    end 

        if snapToGuide == true then 
		    for i=1, v_guideline, 1 do 
			    if(screen:find_child("v_guideline"..i) ~= nil) then 
			            local gx = screen:find_child("v_guideline"..i).x 
                        gx = gx + 9 
			     	    if(15 >= math.abs(gx - x + dx)) then  
							uiInstance.x = gx + screen:find_child("v_guideline"..i).w - 18 
							if (am ~= nil) then 
			     	     	    am.x = am.x - (x-dx-gx)
			     	     	    border.x = border.x - (x-dx-gx-1)
							end
			     		elseif(15>= math.abs(gx - x + dx - uiInstance.w)) then
							uiInstance.x = gx - uiInstance.w 
							if (am ~= nil) then 
			     	     	    am.x = am.x - (x-dx+uiInstance.w - gx)
			     	     	    border.x = border.x - (x-dx+uiInstance.w - gx)
							end
			     		end 
			   	end 
		    end 
			for i=1, h_guideline,1 do 
			    if(screen:find_child("h_guideline"..i) ~= nil) then 
			        local gy =  screen:find_child("h_guideline"..i).y 
                    gy = gy + 9
			      	if(15 >= math.abs(gy - y + dy)) then 
					    uiInstance.y = gy
					    uiInstance.y =gy + screen:find_child("h_guideline"..i).h - 18 
						if (am ~= nil) then 
			     	        am.y = am.y - (y-dy - gy) 
			     	        border.y = border.y - (y-dy-gy) + 2 
						end
			      	elseif(15>= math.abs(gy - y + dy - uiInstance.h)) then
						uiInstance.y =  gy - uiInstance.h 
						if (am ~= nil) then 
			     	        am.y = am.y - (y-dy + uiInstance.h - gy)  
			     	        border.y = border.y - (y-dy + uiInstance.h - gy)  
						end
			      	end 
			   	end
			end
		end 
		selected_content = nil
		selected_container = nil
        dragging = nil
        --kkk
        uiInstance:ungrab_pointer()
        uiInstance:set{} 
        uiInstance.x = uiInstance.x
        return true 
	end,true) 
    uiInstance.extra.mouse_handler = true 

end 

function util.is_available (name) 
    for i, j in pairs (objectsNames) do
        if i == name then 
            print(name.."  is not available")
            return false
        end
    end 
    print(name.."  is available")
    return true
end

local function change_image_name (uiTypeStr)
    local imgFileName, i, j
    i, j = string.find(uiTypeStr, ".png")
        
    if i ~= nil then 
        imgFileName = string.sub(uiTypeStr, 1, i-1)
    else 
        i, j = string.find(uiTypeStr, ".gif")
        if i ~= nil then 
            imgFileName = string.sub(uiTypeStr, 1, i-1)
        end
    end 
    imgFileName = string.gsub(imgFileName, "/", "_S_")
    imgFileName = string.gsub(imgFileName, "%.", "_P_")
    imgFileName = string.gsub(imgFileName, "-", "_D_")
    
    local lowerChar, capitalChar, n
    lowerChar, n = string.gsub(string.sub(imgFileName, 1,1), "%l", "Y") 
    capitalChar, n = string.gsub(string.sub(imgFileName, 1,1), "%u", "Y") 

    if lowerCase == "Y" or capitalChar == "Y"then 
        imgFileName = string.lower(string.sub(imgFileName, 1,1))..string.sub(imgFileName, 2, -1)
    else 
        imgFileName = "_"..imgFileName
    end

    return imgFileName
end 

function util.assign_right_name (uiInstance, uiTypeStr)
    uiTypeStr = (uiTypeStr:sub(1, 1):upper()..uiTypeStr:sub(2, -1))
    if hdr.uiNum_map[uiTypeStr] == nil then
        local imgFileName
        
        imgFileName = change_image_name(uiTypeStr)

        if hdr.uiNum_map[imgFileName] == nil then
            hdr.uiNum_map[imgFileName] = 0 
        end 

        while  util.is_available(imgFileName.."_"..hdr.uiNum_map[imgFileName]) == false do 
            hdr.uiNum_map[imgFileName] = hdr.uiNum_map[imgFileName] + 1
        end 

        uiInstance.name = imgFileName.."_"..hdr.uiNum_map[imgFileName]
        hdr.uiNum_map[imgFileName] = hdr.uiNum_map[imgFileName] + 1

    else 

        while util.is_available(uiTypeStr:lower()..hdr.uiNum_map[uiTypeStr]) == false do
            hdr.uiNum_map[uiTypeStr] = hdr.uiNum_map[uiTypeStr] + 1
        end 
    
        uiInstance.name = uiTypeStr:lower()..hdr.uiNum_map[uiTypeStr]
        hdr.uiNum_map[uiTypeStr] = hdr.uiNum_map[uiTypeStr] + 1
    
--[[
    while util.is_available(uiTypeStr:lower()..uiNum) == false do
        uiNum = uiNum + 1
    end 

    uiInstance.name = uiTypeStr:lower()..uiNum
    uiNum = uiNum + 1
]]
    end 
end 
	

function util.setBGImages (path)

    if BG_IMAGE_20 == nil then 

        BG_IMAGE_20 = Image{src ="LIB/assets/transparency-grid-20-2.png"}
        BG_IMAGE_20:set{position = {0,0}, size = {screen.w, screen.h}, opacity = 255}

        BG_IMAGE_40 = Image{src="LIB/assets/transparency-grid-40-2.png"}
        BG_IMAGE_40:set{position = {0,0}, size = {screen.w, screen.h}, opacity = 0}
        
        BG_IMAGE_80 = Image{src="LIB/assets/transparency-grid-80-2.png"}
        BG_IMAGE_80:set{position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

        BG_IMAGE_white = Image{src="LIB/assets/white.png"}
        BG_IMAGE_white:set{position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

        BG_IMAGE_import = Image{position = {0,0}, size = {screen.w, screen.h}, opacity = 0}

    end 

    screen:add(BG_IMAGE_20,BG_IMAGE_40,BG_IMAGE_80,BG_IMAGE_white,BG_IMAGE_import)
end 

function util.guideline_inspector(v)

	local org_position 
    guideline_inspector_on = true
    selected_guideline = v

    if(util.guideline_type(v.name) == "v_guideline") then
		org_position = tostring(math.floor(v.x))
        print("openV_GLI"..org_position)
	else
		org_position = tostring(math.floor(v.y))
        print("openH_GLI"..org_position)
    end 

end 

function util.create_on_line_down_f(v)

        function v:on_button_down(x,y,button,num_clicks)

            if selected_guideline ~= nil or guideline_inspector_on == true then 
                return true 
            end 

            v:find_child("line").color = {255,0,0,255}
            dragging = {v, x - v.x, y - v.y }
	     	if(button == 3) then
		  		util.guideline_inspector(v)
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
                if guideline_inspector_on ~= true then 
                    v:find_child("line").color = {0,255,255,255}
                end 
	          	dragging = nil
            end
            return true
        end

end 

function util.close_guideInspector () 
    selected_guideline:find_child("line").color = {0,255,255,255}
    selected_guideline = nil
    guideline_inspector_on = false
end 

function util.get_min_max () 
     local min_x = screen.w
     local max_x = 0
     local min_y = screen.h
     local max_y = 0

     for i, v in pairs(curLayer.children) do
          if curLayer:find_child(v.name) then
	        if(v.extra.ve_selected == true) then
			if(v.x < min_x) then min_x = v.x end 
			if(v.x > max_x) then max_x = v.x end
			if(v.y < min_y) then min_y = v.y end 
			if(v.y > max_y) then max_y = v.y end
		end 
          end
    end
    return min_x, max_x, min_y, max_y
end 


function util.getObjName (border_n) 
     local i, j = string.find(border_n, "border")
     return string.sub(border_n, 1, i-1)
end 

function util.org_cord() 
    for i, v in pairs(curLayer.children) do
		if(v.extra.ve_selected == true) then
		     v.x = v.x - v.anchor_point[1] 
		     v.y = v.y - v.anchor_point[2] 
		end 
    end 
end  

function util.ang_cord() 
    for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true) then
		    screen_ui.n_selected(v)
		    v.x = v.x + v.anchor_point[1] 
		    v.y = v.y + v.anchor_point[2] 
	  	end 
    end 
end  

function util.getTypeNameStr(m) 
    if string.find(m.widget_type, "Widget" ) then 
        return uiElementName_map[m.widget_type]()
    else 
        return m.widget_type
    end
end

function util.getTypeStr(m) 
    if m.widget_type == "Widget" then 
        return m.type
    else 
        return m.widget_type
    end 
end 

function util.getCurLayer(gid) 

    --curLayerGid = gid 
    curLayer = devtools:gid(gid)

end 

function util.copy_obj (v)

      local new_object 
      uiTypeStr = util.getTypeStr(v) 
      if uiElementCreate_map[uiTypeStr] then
        new_object = uiElementCreate_map[uiTypeStr](v.attributes)
      end 

      return new_object
end	
 
function util.get_x_sort_t()
     
     local x_sort_t = {}
     
     for i, v in pairs(curLayer.children) do
	    if(v.extra.ve_selected == true) then
		    local n = #x_sort_t
			if(n ==0) then
				table.insert(x_sort_t, v) 
			elseif (v.x >= x_sort_t[n].x) then
				table.insert(x_sort_t, v) 
			elseif (v.x < x_sort_t[n].x) then  
				local tmp_cord = {}
				while (v.x < x_sort_t[n].x) do
					table.insert(tmp_cord, table.remove(x_sort_t))
					n = #x_sort_t
					if n == 0 then 
						break
					end 
				end 
				table.insert(x_sort_t, v) 
				while (#tmp_cord ~= 0 ) do 
					table.insert(x_sort_t, table.remove(tmp_cord))
				end 
			end
		end 
     end
     
     return x_sort_t 
end

function util.get_reverse_t(sort_t)
     local reverse_t = {}

	while(#sort_t ~= 0) do
		table.insert(reverse_t, table.remove(sort_t))
	end 
	return reverse_t 
end

function util.get_x_space(x_sort_t)
     local f, b 
     local space = 0
     b = table.remove(x_sort_t) 
     while (#x_sort_t ~= 0) do 
          f = table.remove(x_sort_t) 
          space = space + b.x - f.x - f.w
          b = f
     end 
     
     local n = #selected_objs
     if (n > 2) then 
     	space = space / (n - 1)
     end 

     return space
end 

function util.is_in_list(item, list)

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
 
function util.is_this_container(v)

    if v.extra then 
        --if v.widget_type == "Widget_Group" and string.find(v.name, "Layer") then
        if v.widget_type == "Widget_Group" and string.find(v.name, "Layer") ~= nil and 
                   string.find(v.name, "a_m") == nil and 
                   string.find(v.name, "border") == nil then 

	        return false
        end 
        if util.is_in_list(v.widget_type, hdr.uiContainers) == true then 
	    	return true
        else 
	    	return false
        end 
    else 
        return false
    end 

end 

function util.find_container(x_pos, y_pos)

	local c_tbl = {}

	for i, j in ipairs (screen.children) do 
	    if j.name then 
        --if string.find(j.name, "Layer") and j.visible == true then 
        if string.find(j.name, "Layer") ~= nil and 
                   string.find(j.name, "a_m") == nil and 
                   string.find(j.name, "border") == nil 
                   and j.visible == true  then 

            for k,l in ipairs (j.children) do 
		        if l.x < x_pos and x_pos < l.x + l.w and l.y < y_pos and y_pos < l.y + l.h then 
				    if util.is_this_container(l) then
					    table.insert(c_tbl, l)
				    end 
		        end 
            end 
        end 
        end 
	end 

	if #c_tbl > 0 then 
		local j = table.remove(c_tbl)
		return j, j.widget_type 
	else 
		return nil
	end 

end 

function util.is_in_container_group(x_pos, y_pos) 

	for i, j in ipairs (screen.children) do 
	    if j.name then 
        --if string.find(j.name, "Layer") and j.visible == true then 
        if string.find(j.name, "Layer") ~= nil and 
                   string.find(j.name, "a_m") == nil and 
                   string.find(j.name, "border") == nil 
                   and j.visible == true  then 

            for k,l in ipairs (j.children) do 
	            if l.x < x_pos and x_pos < l.x + l.w and l.y < y_pos and y_pos < l.y + l.h then 
		            if util.is_this_container(l) then
		                return true 
		            end 
		        end 
	        end 
  	    end 
  	    end 
    end 
  	return false 

end 

function util.is_there_guideline () 

	for i, j in pairs (screen.children) do 
		if j.name then 
			if string.find(j.name, "_guideline") then 
				return true 
			end 
		end 
    end 
	return false

end 

function util.guideline_type(name) 
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

function util.copy_obj (v)

      local new_object 

      uiTypeStr = util.getTypeStr(v) 

      if uiElementCreate_map[uiTypeStr] then
        new_object = uiElementCreate_map[uiTypeStr](v.attributes)
      end 

      return new_object
end	

function util.is_this_selected(v)
	local b_name = v.name.."border"

	for i, j in pairs (selected_objs) do
		if j == b_name then 
			return true
		end 
	end 

	return false
end 


function util.is_this_group(v)

	if v.extra then 
		if v.widget_type and v.widget_type == "Widget_Group" then 
			return true 
		end 
	end 
	return false

end 

function util.color_to_string( color )

        if type( color ) == "string" then
            return color
        end
        
		if type( color ) == "table" then
            return serialize( color )
        end
        return tostring( color )

end

function util.table_copy(t)

  	local t2 = {}
  	for k,v in pairs(t) do
    	t2[k] = v
  	end
  	return t2

end

function util.table_insert(t, val)

	if t then 
	    table.insert(t, val) 
	end 
	return t

end 

function util.table_move_up(t, itemNum)

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

function util.table_move_down(t, itemNum)

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

function util.table_remove_val(t, val)

	if t == nil then 
		return 
	end 

	for i,j in pairs (t) do
		if j == val then 
		     table.remove(t, i)
		end 
	end 
	return t

end 

function util.table_removekey(table, key)

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

function util.orderedPairs(t)

    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil

end

function util.values(t) 

	local j = 0 
	return function () j = j+1 return t[j] end 

end 

function util.get_group_position(child_obj)

     if child_obj == nil then
        print("get_group_position() fail, child_obj is nil")
        return 
     end 
     --parent_obj = child_obj.parent
     parent_obj = child_obj.parent_group 

     if parent_obj == nil then 
        print("get_group_position() fail, parent_obj is nil")
        return 
     else 
        if parent_obj.widget_type == "ArrowPane" or parent_obj.widget_type == "TabBar" then
            return {parent_obj.x + parent_obj.style.arrow.size - parent_obj.virtual_x + 2*parent_obj.style.arrow.offset, parent_obj.y +
            parent_obj.style.arrow.size + 2*parent_obj.style.arrow.offset - parent_obj.virtual_y }
        elseif parent_obj.widget_type == "MenuButton" then 
            return {parent_obj.x + parent_obj.item_spacing  + parent_obj.popup_offset, parent_obj.y +
            parent_obj.item_spacing + parent_obj.popup_offset}
        elseif parent_obj.widget_type == "DialogBox" then 
            return {parent_obj.x, parent_obj.y + parent_obj.separator_y}
        elseif parent_obj.widget_type == "LayoutManager" then 
            return parent_obj.position
        elseif parent_obj.widget_type == "Widget_Group" then 
            return parent_obj.position
        else
            return parent_obj.position

        end 
     end 

     --[[
     if parent_obj.widget_type ~= nil then
        for i, v in pairs(parent_obj.children) do
	        if (v.type == "Group") then 
		        if v.find_child and (v:find_child(child_obj.name)) then
			        return v.position 
		        end 
	        end 
        end
    end 
    ]]
end 
	
return util


