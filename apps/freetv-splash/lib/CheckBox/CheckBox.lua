--[[
Function: checkBox

Creates a Check box ui element

Arguments:
	Table of Check box properties
		skin - Modify the skin for the button by changing this value   
    	bwidth - Width of the Check box 
    	bheight - Height of the Check box
		items - Table of Check box items
    	font - Font of the Check box items
    	color - Color of the Check box items
		box_color - Color of the Check box border 
		f_color - the color of the Check box 
		box_border_width - Width of Check box border
		box_size - The size of Check box 
        check_size - The size of Check image 
		box_pos - Postion of the group of check boxes
		item_position - Position of the group of text items 
		line_space - Space between the text items 
		selected_item - Selected item's number 
		on_selection_change - function that is called by selected item number   
		direction - Option of list direction (1=Vertical, 2=Horizontal)

Return:
		cb_group - Group containing the check box  

Extra Function:
		insert_item(item) - Add an item to the items table 
		remove_item(item) - Remove an item from the items table 
]]




function ui_element.checkBoxGroup(t) 

 --default parameters
    local p = {
	skin = "Custom", 
	ui_width = 600,
	ui_height = 200,
	items = {"item", "item", "item"},
	text_font = "FreeSans Medium 30px", 
	text_color = {255,255,255,255}, 
	box_color = {255,255,255,255},
	fill_color = {255,255,255,0},
	focus_box_color = {0,255,0,255},
	focus_fill_color = {0,50,0,0},
	box_border_width = 2,
	box_size = {25,25},
	check_size = {25,25},
	line_space = 40,   
	box_position = {0, 0},  
	item_position = {50,-5},  
	selected_items = {1},  
	direction = "vertical",  -- 1:vertical 2:horizontal
	on_selection_change = nil,  
	ui_position = {200, 200, 0}, 
    } 

 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end

 --the umbrella Group
    local check_image
    local checks = Group()
    local items = Group{name = "items"}
    local boxes = Group() 
    local cb_group = Group()
	local create_checkBox

    local  cb_group = Group {
    	  name = "checkBoxGroup",  
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "CheckBoxGroup"}
    }

	function cb_group.extra.set_focus()
	  	current_focus = cb_group
	    boxes:find_child("box"..1).opacity = 0 
	    boxes:find_child("focus"..1).opacity = 255 
		boxes:find_child("box"..1):grab_key_focus() 
    end

    function cb_group.extra.clear_focus()
		for i=1, table.getn(boxes.children)/2 do 
	    	boxes:find_child("box"..i).opacity = 255 
	    	boxes:find_child("focus"..i).opacity = 0 
		end 
    end 

    function cb_group.extra.set_selection(items) 
	    cb_group.selected_items = items
        if cb_group.on_selection_change then
	       cb_group.on_selection_change(cb_group.selected_items)
	    end
    end 

    function cb_group.extra.insert_item(itm) 
		table.insert(p.items, itm) 
		create_checkBox()
    end 

    function cb_group.extra.remove_item() 
		table.remove(p.items)
		create_checkBox()
    end 

    function create_checkBox()
	 	items:clear() 
	 	checks:clear() 
	 	boxes:clear() 
	 	cb_group:clear()

		if p.skin == "Custom" then 
             p.check_image = "lib/assets/checkmark.png"
		else 
             p.box_image = skin_list[p.skin]["checkbox"]
             p.box_focus_image = skin_list[p.skin]["checkbox_focus"]
             p.check_image = skin_list[p.skin]["checkbox_sel"]
	 	end
	
	 	boxes:set{name = "boxes", position = p.box_position} 
	 	checks:set{name = "checks", position = p.box_position} 
	 	items:set{name = "items", position = p.item_position} 

        local pos = {0, 0}

        for i, j in pairs(p.items) do 
	    
			local box, check, focus
	      	
			if(p.direction == "vertical") then --vertical 
                  pos= {0, i * p.line_space - p.line_space}
	      	end   			

	      	items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color = p.text_color, position = pos})     
	      	if p.skin == "Custom" then 
		   		focus = Rectangle{name="focus"..tostring(i),  color= p.focus_fill_color, border_color= p.focus_box_color, border_width= p.box_border_width, 
				size = p.box_size, position = pos, reactive = true, opacity = 0}
		   		box = Rectangle{name="box"..tostring(i),  color= p.fill_color, border_color= p.box_color, border_width= p.box_border_width, 
				size = p.box_size, position = pos, reactive = true, opacity = 255}
    	        boxes:add(box, focus) 
	     	else
	           	focus = assets(p.box_focus_image)
	           	focus:set{name = "focus"..tostring(i), position = pos, reactive = true, opacity = 0}
	           	box = assets(p.box_image)
	           	box:set{name = "box"..tostring(i), position = pos, reactive = true, opacity = 255}
		   		boxes:add(box, focus) 
	     	end 

	      	if p.skin == "Custom"  or p.skin == "default"  then 
	     		check = assets(p.check_image)
	     		check:set{name="check"..tostring(i), size = p.check_size, position = pos, reactive = true, opacity = 0}
			else 
	     		check = assets(p.check_image)
	     		check:set{name="check"..tostring(i), position = pos, reactive = true, opacity = 0}
			end

	     	checks:add(check) 

            if editor_lb == nil or editor_use then  

				function box:on_key_down(key)
					local box_num = tonumber(box.name:sub(4,-1))
					local next_num
					local next_key, prev_key

					if cb_group.direction == "vertical" then 
						next_key = keys.Down 
						prev_key = keys.Up
					else 
						next_key = keys.Right 
						prev_key = keys.Left
					end 
							
					if key == prev_key then 
						if box_num > 1 then 
							next_num = box_num - 1
	    					boxes:find_child("box"..box_num).opacity = 255 
	    					boxes:find_child("focus"..box_num).opacity = 0 
	    					boxes:find_child("box"..next_num).opacity = 0 
	    					boxes:find_child("focus"..next_num).opacity = 255 
	    					boxes:find_child("box"..next_num):grab_key_focus()
							return true 
						end
					elseif key == next_key then 
						if box_num < table.getn(boxes.children)/2 then 
							next_num = box_num + 1
	    					boxes:find_child("box"..box_num).opacity = 255 
	    					boxes:find_child("focus"..box_num).opacity = 0 
	    					boxes:find_child("box"..next_num).opacity = 0 
	    					boxes:find_child("focus"..next_num).opacity = 255 
							boxes:find_child("box"..next_num):grab_key_focus() 
							return true 
						end
					elseif key == keys.Return then 
						if cb_group:find_child("check"..tostring(box_num)).opacity == 255 then 
							cb_group.selected_items = table_remove_val(cb_group.selected_items, box_num)
						else 
							table.insert(cb_group.selected_items, box_num)
						end 
						cb_group.set_selection(p.selected_items)
						cb_group:find_child("check"..tostring(box_num)).reactive = true 
	    				cb_group:find_child("box"..box_num).opacity = 0 
	    				cb_group:find_child("focus"..box_num).opacity = 255 
						boxes:find_child("box"..box_num):grab_key_focus() 
						return true 
					end 
				end 

	     		function box:on_button_down (x,y,b,n)
					if current_focus then 
						current_focus.clear_focus() 
					end 
					local box_num = tonumber(box.name:sub(4,-1))
	  				
					current_focus = cb_group

					table.insert(cb_group.selected_items, box_num)
    				cb_group.extra.set_selection(cb_group.selected_items) 

					cb_group:find_child("check"..tostring(box_num)).opacity = 255
					cb_group:find_child("check"..tostring(box_num)).reactive = true
					
	    			boxes:find_child("box"..tostring(box_num)).opacity = 0 
	    			boxes:find_child("focus"..tostring(box_num)).opacity = 255 
					boxes:find_child("box"..tostring(box_num)):grab_key_focus() 
					return true
	     		end 

	     		function check:on_button_down(x,y,b,n)
					if current_focus then 
						current_focus.clear_focus() 
					end 
					local check_num = tonumber(check.name:sub(6,-1))
					current_focus = cb_group
					if cb_group:find_child("check"..tostring(check_num)).opacity == 255 then 
						cb_group.selected_items = table_remove_val(cb_group.selected_items, check_num)
						cb_group:find_child("check"..tostring(check_num)).opacity = 0 
						cb_group:find_child("check"..tostring(check_num)).reactive = true 
					else 
						table.insert(cb_group.selected_items, check_num)
						cb_group:find_child("check"..tostring(check_num)).opacity = 255 
					end 
    				cb_group.extra.set_selection(cb_group.selected_items) 
	    			cb_group:find_child("box"..check_num).opacity = 0 
	    			cb_group:find_child("focus"..check_num).opacity = 255 
					boxes:find_child("box"..check_num):grab_key_focus() 
					return true
	     		end 
	     	end

	     	if(p.direction == "horizontal") then 
		  		pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	     	end 
         end 

	 	for i,j in pairs(p.selected_items) do 
             checks:find_child("check"..tostring(j)).opacity = 255 
             checks:find_child("check"..tostring(j)).reactive = true 
	 	end 

		boxes.reactive = true 
		checks.reactive = true 
	 	cb_group:add(boxes, items, checks)
    end
    
    create_checkBox()


    mt = {}
    mt.__newindex = function (t, k, v)
    	if k == "bsize" then  
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_checkBox()
		end
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
        else 
	    return p[k]
        end 
    end 

    setmetatable (cb_group.extra, mt)
     
    return cb_group
end 