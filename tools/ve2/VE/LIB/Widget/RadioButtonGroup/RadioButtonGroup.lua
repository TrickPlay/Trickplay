
RADIOBUTTONGROUP = true

local radio_groups = setmetatable( {}, { __mode = "v" } )
RadioButtonGroup_nil = function()
	  radio_groups = setmetatable( {}, { __mode = "v" } )
end
RadioButtonGroup = function(parameters)
	
    if type(parameters) == "string" then
        
        if radio_groups[parameters] then
            
            return radio_groups[parameters]
            
        else
            
            parameters = { name = parameters }
            
        end
        
    end
    
	--input is either nil or a table
	parameters = is_table_or_nil("RadioButtonGroup",parameters)
	
	
	local selected, on_selection_change
	local instance, name
	local items = {}
	  
	  local  meta_setters = {
			items         = function(v)
				  if type(v) ~= "table" then
						
						error("RadioButtonGroup.items expected type 'table'. Received "..type(v),2)
						
				  end
				  for _,tb in pairs(v) do
						
						tb.group = instance -- relies on ToggleButton.group to insert itself
						
				  end
			end,
			selected = function(v)
				  
				  if type(v) ~= "number" then
						
						error("RadioButtonGroup.selected expected type 'number'. Received "..type(v),2)
						
				  elseif v < 1 then
						
						error("RadioButtonGroup.selected expected positive number. Received "..v,2)
						
				  elseif v ~= selected then
						
						selected = v
						
						if items[selected] then
							  
							  items[selected].selected = true
							  
						end
						
				  end
				  
			end,
			name = function(v)
				  
				  if name ~= nil then radio_groups[name] = nil end
				  
				  name = check_name( radio_groups, instance, v, "RadioButtonGroup" )
				  
			end,
			on_selection_change = function(v)
				  on_selection_change = v
				  
			end,
	  }
	  local meta_getters = {
			items         = function() return recursive_overwrite({},items) end,
			selected      = function() return selected                      end,
			name          = function() return name                          end,
			type          = function() return "RadioButtonGroup"            end,
			on_selection_change =  function() return on_selection_change    end,
	  }
	  
	  local removing = false
	  
	  instance = setmetatable({
				insert = function(self,tb)
						
						if type(tb) ~= "userdata" then
							  
							  error("RadioButtonGroup:insert() expected ToggleButtons."..
									" Received "..type(tb) .." at index ",2)
							  
						end
						
						if tb.group ~= self then
							  tb.group = self
						else
							  table.insert(items, tb )
							  if tb.selected then
									
									self.selected = #items
									
							  end
						end
						
						
				end,
				remove = function(self,tb)
						
						if removing then return end
						
						removing = true
						
						if type(tb) ~= "userdata" then
							  
							  error("RadioButtonGroup:remove() expected ToggleButtons."..
									" Received "..type(tb) .." at index ",2)
							  
						end
						
						for i,v in pairs(items) do
							  
							  if v == tb then
									
									if tb.group == instance then tb.group = nil end
									
									table.remove(items,i)
									
									break
							  end
							  
						end
						
						selected = nil
						
						for i,v in pairs(items) do
							  
							  if tb.selected then
									
									selected = i
									
									break
							  end
							  
						end
						
						removing = false
						
				end,
                set = function(self,t)
                    if type(t) ~= "table" then
                        error("Expected table. Received "..type(t),2) 
                    end
                    
                    for k,v in pairs(t) do   self[k] = v   end
                end,
			},
			{
				  __index = function(t,k,v)
						
						return meta_getters[k] and meta_getters[k]()
						
				  end,
				  __newindex = function(t,k,v)
						
						return meta_setters[k] and meta_setters[k](v)
						
				  end,
			}
	  )
	  
	  --[[
	  instance.name  = parameters.name
	  if parameters.items then instance.items = parameters.items end
	  --]]
      instance:set(parameters)
      
	  return instance
	  
end



--[[
Function: radioButtonGroup

Creates a Radio button ui element

Arguments:
	Table of Radio button properties

	skin - Modify the skin for the Radio button by changing this value  
    bwidth - Width of the Radio button 
    bheight - Height of the Radio button 
	items - Table of Radio button items
    font - Font of the Radio button items
    color - Color of the Radio button items
	button_color - Color of the Radio button
	select_color - Color of the selected Radio button
	button_radius - Radius of the Radio button
	select_radius - Radius of the selected Radio button
	ring_position - The position of the group of Radio buttons 
	item_position - The position of the group of text items 
	line_space - The space between the text items 
	selected_item - Selected item's number 
	on_selection_change - function that is called by selceted item number

Return:
 	rb_group - Group containing the radio button 

Extra Function:
	insert_item(item) - Add an item to the items table
	remove_item(item) - Remove an item from the items table 
]]
--[[

function ui_element.radioButtonGroup(t) 

 --default parameters
    local p = {
	skin = "Custom", 
	ui_width = 600,
	ui_height = 200,
	items = {"item", "item", "item"},
	text_font = "FreeSans Medium 30px", 
	text_color = {255,255,255,255}, 
	button_color = {255,255,255,255}, 
	select_color = {255, 255, 255, 255},
	focus_button_color = {0,255,0,255},
	button_radius = 10,
	select_radius = 4,  
	button_position = {0, 0},  
	item_position = {50,-10},  
	line_space = 40,  
	on_selection_change = nil, 
	direction = "vertical", 
	selected_item = 1,  
	ui_position = {200, 200, 0}, 
	------------------------------------------------
	button_image = Image{}, 
	select_image = Image{}, 
    }

 --overwrite defaults
 ------------------------------------------------
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local items = Group()
    local rings = Group() 
    local select_img

    local rb_group = Group {
          name = "radioButtonGroup",  
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "RadioButtonGroup"}
     }


	function rb_group.extra.set_focus()
	  	current_focus = cb_group
	    rings:find_child("ring"..1).opacity = 0 
	    rings:find_child("focus"..1).opacity = 255 
		rings:find_child("ring"..1):grab_key_focus() 
    end

    function rb_group.extra.clear_focus()
		for i=1,  #rings.children/2 do 
	    	rings:find_child("ring"..i).opacity = 255 
	    	rings:find_child("focus"..i).opacity = 0 
		end 
    end 

    function rb_group.extra.set_selection(item_n) 
	    rb_group.selected_item = item_n
        if p.on_selection_change then
	       p.on_selection_change(p.selected_item)
	    end
    end 

    local create_radioButton 

    function rb_group.extra.insert_item(itm) 
		table.insert(p.items, itm) 
		create_radioButton()
    end 

    function rb_group.extra.remove_item() 
		table.remove(p.items)
		create_radioButton()
    end 

    create_radioButton = function() 

	local sel_off_x = 12
	local sel_off_y = 4


	if(p.skin ~= "Custom" and p.skin ~= "default") then 
	     p.button_image = skin_list[p.skin]["radiobutton"]
	     p.button_focus_image = skin_list[p.skin]["radiobutton_focus"]
	     p.select_image = skin_list[p.skin]["radiobutton_sel"]
		 if p.skin == "CarbonCandy" then
			p.item_position = {70, 10}
			p.line_space = 65
		 end 
	end

    rb_group:clear()
    rings:clear()
    items:clear()
         --rb_group.size = { p.ui_width , p.ui_height},
	
    if p.skin == "Custom" then 
		local key = string.format("circle:%d:%s",p.select_radius, color_to_string(p.select_color))
		select_img = assets(key, my_create_select_circle, p.select_radius, p.select_color)
        select_img:set{name = "select_img", position = {0,0}, opacity = 255} 
    else 
    	select_img = assets(p.select_image)
        select_img:set{name = "select_img", position = {0,0}, opacity = 255} 
    end 

	local pos = {0,0}

    for i, j in pairs(p.items) do 
		
		local donut, focus 

	    if(p.direction == "vertical") then --vertical 
        	pos= {0, i * p.line_space - p.line_space}
	    end   	
        items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color =p.text_color, position = pos})     

	    if p.skin == "Custom" then 
			local key = string.format("donut:%d:%s",p.button_radius, color_to_string(p.button_color))
		   	donut =  assets(key, my_create_circle, p.button_radius, p.button_color)
			donut:set{name="ring"..tostring(i), position = {pos[1], pos[2] - 8}}  

			key = string.format("focus:%d:%s",p.button_radius, color_to_string(p.focus_button_color))
		   	focus = assets(key, my_create_circle, p.button_radius, p.focus_button_color)
			focus:set{name="focus"..tostring(i), position = {pos[1], pos[2] - 8}, opacity = 0}  

    	    rings:add(donut, focus) 
	    else
	        donut = assets(p.button_image)
			donut:set{name = "ring"..tostring(i), position = {pos[1], pos[2] - 8}}
	        
			focus = assets(p.button_focus_image)
	        focus:set{name = "focus"..tostring(i), position = {pos[1], pos[2] - 8}, opacity = 0}

    	    rings:add(donut, focus) 
	    end 

	    if(p.direction == "horizontal") then --horizontal
		  	   	pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	    end 
	    donut.reactive = true

        if editor_lb == nil or editor_use then  
			function donut:on_key_down(key)
				local ring_num = tonumber(donut.name:sub(5,-1))
				local next_num
				local next_key, prev_key 

				if rb_group.direction == "vertical" then 
					next_key = keys.Down 
					prev_key = keys.Up
				else 
					next_key = keys.Right 
					prev_key = keys.Left
				end 
	
				if key == prev_key then 
					if ring_num > 1 then 
						next_num = ring_num - 1
	    				rings:find_child("ring"..ring_num).opacity = 255 
	    				rings:find_child("focus"..ring_num).opacity = 0 
	    				rings:find_child("ring"..next_num).opacity = 0 
	    				rings:find_child("focus"..next_num).opacity = 255 
	    				rings:find_child("ring"..next_num):grab_key_focus()
						return true 
					end
				elseif key == next_key then 
					if ring_num < #rings.children/2 then 
						next_num = ring_num + 1
	    				rings:find_child("ring"..ring_num).opacity = 255 
	    				rings:find_child("focus"..ring_num).opacity = 0 
	    				rings:find_child("ring"..next_num).opacity = 0 
	    				rings:find_child("focus"..next_num).opacity = 255 
						rings:find_child("ring"..next_num):grab_key_focus() 
						return true 
					end
				elseif key == keys.Return then 
					rb_group.extra.set_selection(ring_num)

	    			rings:find_child("ring"..ring_num).opacity = 0 
	    			rings:find_child("focus"..ring_num).opacity = 255 

					if (p.skin == "CarbonCandy") then 
						select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + p.button_position[1]
	    				select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + p.button_position[2] - 8
					else 
						select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + sel_off_x + p.button_position[1]
	    				select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + sel_off_y + p.button_position[2]
					end 

					rings:find_child("ring"..ring_num):grab_key_focus() 

					return true 
				end 
			end 
	
	           	function donut:on_button_down (x,y,b,n)
					if current_focus then 
						current_focus.clear_focus() 
					end 

				    local ring_num = tonumber(donut.name:sub(5,-1))
					rb_group.extra.set_selection(ring_num)

					current_focus = rb_group
	    			rings:find_child("ring"..ring_num).opacity = 0 
	    			rings:find_child("focus"..ring_num).opacity = 255 
					rings:find_child("ring"..ring_num):grab_key_focus() 


					if (p.skin == "CarbonCandy") then 
						select_img.x  = items:find_child("item"..tostring(p.selected_item)).x 
	    				select_img.y  = items:find_child("item"..tostring(p.selected_item)).y - 8 
					else 
						select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + sel_off_x
	    				select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + sel_off_y
					end 

					return true
	     		end 
	      	end
         end 
	 	 rings:set{name = "rings", position = p.button_position} 
	 	 items:set{name = "items", position = p.item_position} 

		 local sel_offset = 0
		 if p.skin == "CarbonCandy" then 
				sel_offset = 11
		 end 

     	 select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + 12 + p.button_position[1] - sel_offset
     	 select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + 4 + p.button_position[2] - sel_offset

	 	 rb_group:add(rings, items, select_img)

     end
     create_radioButton()

     mt = {}
     mt.__newindex = function (t, k, v)
		if k == "bsize" then  
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_radioButton()
		end
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
        else 
	    return p[k]
        end 
     end 
  
     setmetatable (rb_group.extra, mt)

     return rb_group
end
--]]