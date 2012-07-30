TABBAR = true

local top_tabs = function(self,state)
	local c = Canvas(self.w,self.h)
	
	c.op = "SOURCE"
	
	c.line_width = self.style.border.width
	
	local r     = self.style.border.corner_radius
    local inset = c.line_width/2
    
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w - (inset+r), inset)
    --top-right corner
    c:arc( c.w - (inset+r), inset+r, r,270,360)
    c:line_to(c.w - inset,c.h + inset)
    --bottom-right corner
    c:line_to( inset, c.h + inset)
    --bottom-left corner
    c:line_to( inset, inset+r)
    
	c:set_source_color( self.style.fill_colors[state] or "00000000" )
	
	c:fill(true)
    
	c:set_source_color( self.style.border.colors[state] or "ffffff" )
	
	c:stroke(true)
	
	return c:Image()
	
end

local side_tabs = function(self,state)
	local c = Canvas(self.w,self.h)
	
	c.op = "SOURCE"
	
	c.line_width = self.style.border.width
	
	local r     = self.style.border.corner_radius
    local inset = c.line_width/2
    
    c:move_to( inset, inset+r)
    --top-left corner
    c:arc( inset+r, inset+r, r,180,270)
    c:line_to(c.w + inset, inset)
    --top-right corner
    c:line_to(c.w + inset, c.h - inset)
    --bottom-right corner
    c:line_to( inset+r, c.h - inset)
    --bottom-left corner
    c:arc( inset+r, c.h - (inset+r), r,90,180)
    c:line_to( inset, inset+r)
    
    
	c:set_source_color( self.style.fill_colors[state] or "00000000" )
	
	c:fill(true)
    
	c:set_source_color( self.style.border.colors[state] or "ffffff" )
	
	c:stroke(true)
	
	return c:Image()
	
end

local default_parameters = {tab_w = 200,tab_h = 50,pane_w = 400,pane_h = 300, tab_location = "top"}
TabBar = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("TabBar",parameters) -- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The TabBar Object inherits from Widget
	
	local instance = ListManager{vertical_alignment = "top",spacing=0}
    local panes = {}
    local tabs = {}
	local rbg 
    rbg= RadioButtonGroup{name = "TabBar",
        on_selection_change = function()
            for i,p in ipairs(panes) do
                p[i == rbg.selected and "show" or "hide"](p)
                tabs[rbg.selected]:grab_key_focus()
            end
        end
    }
    
    local panes_obj = Widget_Group{clip_to_size = true}
    local tab_w = 200
    local tab_h = 50
    local tab_images
    local tab_style 
    local tab_location
    local tabs_lm = ListManager{
        spacing = 0,
        vertical_alignment = "top",
        node_constructor = function(obj)
            
            if obj == nil then 
                obj = {label = "Tab",content = {}}
            elseif type(obj) ~= "table" then
                error("Expected tab entry to be a string. Received "..type(obj),2)
            elseif type(obj.label) ~= "string" then
                error("Received a tab without a label",2)
            end
            for i,c in ipairs(obj.contents or {}) do
                if type(c) == "table" and c.type then 
                    
                    obj.contents[i] = _G[c.type](c)
                    
                elseif type(c) ~= "userdata" and c.__types__.actor then 
                    
                    error("Must be a UIElement or nil. Received "..c,2) 
                end
            end
            local pane = Group{children = obj.contents}
            obj = ToggleButton{
                label  = obj.label,
                w      = tab_w,
                h      = tab_h,
                style  = false,
                group  = rbg,
                create_canvas = tab_location == "top" and top_tabs or side_tabs,
                --images = tab_images,
            }
            if tab_style then
                obj.style:set(tab_style.attributes)
            else
                obj.style.border.colors.selection = "ffffff"
            end
            
            --table.insert(tabs,obj)
            obj.pane = pane
            --table.insert(panes,pane)
            panes_obj:add(pane)
            
            return obj
        end
    }
    local tab_pane = ArrowPane{style = false,move_by = "210"}
    tab_pane.style.arrow.offset = -tab_pane.style.arrow.size
    tab_pane.style.border.colors.default = "00000000"
    tab_pane.style.fill_colors.default = "00000000"
    tab_pane:add(tabs_lm)
    
    instance.cells = {tab_pane,panes_obj}
	override_property(instance,"tabs",
		function(oldf) 
        
            local tabs = {}
            
            for i = 1,tabs_lm.length do
                tabs[i]    = {
                    label    = tabs_lm.cells[i].label,
                    contents = tabs_lm.cells[i].pane.children
                }
                for j,child in ipairs(tabs_lm.cells[i].pane.children) do
                    tabs[i].contents[j] = child.attributes
                end
            end
            
            return   tabs     
        end,
		function(oldf,self,v)  
            
            if type(v) ~= "table" then error("Expected table. Received: ",2) end
            
            tabs_lm:set{
                direction = "horizontal",
                --length = #v,
                cells = v,
            }
            if tab_location == "top" then
                tab_pane.virtual_w = tabs_lm.w
            else
                tab_pane.virtual_h = tabs_lm.h
            end
            
        end
	)
    local pane_w = panes_obj.w
    local pane_h = panes_obj.h
	override_property(instance,"pane_w",
		function(oldf) return   pane_w     end,
		function(oldf,self,v)   
            pane_w = v 
            panes_obj.w = v
            if tab_location == "top" then
                tab_pane.pane_w    = pane_w
            end
        end
    )
	override_property(instance,"pane_h",
		function(oldf) return   pane_h     end,
		function(oldf,self,v)   
            pane_h = v 
            panes_obj.h = v
            if tab_location == "left" then
                tab_pane.pane_h    = pane_h
            end
        end
    )
	override_property(instance,"tab_w",
		function(oldf) return   tab_w     end,
		function(oldf,self,v)   tab_w = v end
    )
	override_property(instance,"tab_h",
		function(oldf) return   tab_h     end,
		function(oldf,self,v)   tab_h = v end
    )
	override_property(instance,"tab_location",
		function(oldf) return   tab_location     end,
		function(oldf,self,v)  
            if tab_location == v then return end
            
            if v == "top" then
                instance.direction  = "vertical"
                tabs_lm.direction  = "horizontal"
                tab_pane.pane_w    = pane_w
                tab_pane.pane_h    = tab_h
                tab_pane.virtual_w = tabs_lm.w
                tab_pane.virtual_h = tab_h
                tab_pane.move_by   = tab_w + tabs_lm.spacing
                for _,tab in tabs_lm.cells.pairs() do
                    tab.create_canvas = top_tabs
                    tab.w = 200
                end
            elseif v == "left" then
                instance.direction  = "horizontal"
                tabs_lm.direction  = "vertical"
                tab_pane.pane_w    = tab_w
                tab_pane.pane_h    = pane_h
                tab_pane.virtual_w = tab_w
                tab_pane.virtual_h = tabs_lm.h
                tab_pane.move_by   = tab_h + tabs_lm.spacing
                for _,tab in tabs_lm.cells.pairs() do
                    tab.create_canvas = side_tabs
                end
            else
                error("Expected 'top' or 'left'. Received "..v,2)
            end
            
            tab_location = v
        end
	)
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.length               = nil
            t.number_of_cols       = nil
            t.number_of_rows       = nil
            t.vertical_alignment   = nil
            t.horizontal_alignment = nil
            t.vertical_spacing     = nil
            t.horizontal_spacing   = nil
            t.cell_h = nil
            t.cell_w = nil
            t.cells = nil
            
            t.tab_w = instance.tab_w
            t.tab_h = instance.tab_h
            t.tab_location = instance.tab_location
            t.pane_w = instance.pane_w
            t.pane_h = instance.pane_h
            t.tabs   = instance.tabs
            
            t.type = "TabBar"
            
            return t
        end
    )
    --instance.on_entries_changed = function() print("top_level") end
    
	instance:subscribe_to( "enabled",
		function()
            for i = 1,tabs_lm.length do
                tabs_lm.cells[i].enabled = instance.enabled
            end
            tab_pane.enabled = instance.enabled
        end
	)
    instance:subscribe_to( {"tab_w","tab_h"},
        function()
            for i = 1,tabs_lm.length do
                
                tabs_lm.cells[i].size = {tab_w,tab_h}
                
            end
        end
    )
    
    local function tab_style_changed()
        for i = 1,tabs_lm.length do
                
            tabs_lm.cells[i].style:set(instance.style.attributes)
            
        end
    end
    local function arrow_on_changed()
        
        tab_pane.style.arrow:set(instance.style.arrow.attributes)
        
    end
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.arrow:subscribe_to(        nil, arrow_on_changed  )
        instance.style.arrow.colors:subscribe_to( nil, arrow_on_changed  )
        instance.style.border:subscribe_to(       nil, tab_style_changed )
        instance.style.fill_colors:subscribe_to(  nil, tab_style_changed )
        instance.style.text:subscribe_to(         nil, tab_style_changed )
        
		arrow_on_changed()
        tab_style_changed()
	end
	---[[
	instance:subscribe_to(
		"style",
		instance_on_style_changed
	)
    instance_on_style_changed()
    --]]
    
    instance:set(parameters)
    
    return instance
end

--[[
function ui_element.tabBar(t)
    
    --default parameters
    local p = {

        --> font -> deleted because it is duplicated with text_font   
        text_font = "FreeSans Medium 26px",
        
    	skin = "CarbonCandy", 
    	button_width = 150, 			--> ui_width -> button_width
    	button_height = 60, 			--> ui_height -> button_height 
        
    	border_color     = {255,255,255,255},
    	focus_border_color = { 27,145, 27,255},
    	focus_fill_color = { 27,145, 27,255},
        fill_color  = { 60, 60, 60,255}, --> unsel_color -> fill_color 
    	focus_text_color = {255,255,255,255},
    	text_color = {255,255,255,255}, 
    	border_width = 1,
    	border_corner_radius = 12,
		--border_width = 2, -> duplicated ! 
        
        tab_labels = {
            "Label",
            "Label",
            "Label",
        },

        tabs = {},
        tab_position = "top",
        tab_spacing = 0,
		
		--> label_padding -> deleted because it is not used 

        display_width  = 600,
        display_height = 500,
        display_fill_color   = { 0,  0,  0,255}, --> fill_color -> display_fill_color 
        display_border_color = {255,255,255,255}, --> border_color
        display_border_width = 2, --> border_width

        arrow_color  = {255,255,255,255}, --> label_color -> arrow_color  
		
		arrow_size     = 15,
		arrow_dist_to_frame = 5,

		ui_position = {200,200},
		ui_width = 150,
		ui_height = 60, 
    }
    
	local offset = {}
    local buttons = {}
    
    --overwrite defaults
    if t ~= nil then
		for k, v in pairs (t) do p[k] = v end
    end
    
	local ap = nil
	
    local create
    local current_index = 1
    --local tabs = {}
    local tab_bg = {}
    local tab_focus = {}
	
    local umbrella     = Group{
		
        name="tabBar",
		reactive = true,
		position = p.ui_position, 
        extra={
            
            type="TabBar",
			
            insert_tab = function(self,index)
                
                if index == nil then index = #p.tab_labels + 1 end
                
                --table.insert(p.tab_labels,index,"Label "..tostring(index))
                table.insert(p.tab_labels,index,"Label")
                
                table.insert(p.tabs,index,Group{})
                
                create()
                
            end,

			
            remove_tab = function(self,index)
                
				if index == nil then index = #p.tab_labels + 1 end
                
                table.remove(p.tab_labels,index)
                table.remove(p.tabs,index)
                
                create()
				
            end,
			
            rename_tab = function(self,index,name)
                assert(index)
                p.tab_labels[index] = name
                
                create()
            end,
            
            move_tab_up = function(self,index)
                if index == 1 then return end
                local temp  = p.tab_labels[index-1]
                p.tab_labels[index-1] = p.tab_labels[index]
                p.tab_labels[index]   = temp
                
                temp      = p.tabs[index-1]
                p.tabs[index-1] = p.tabs[index]
                p.tabs[index]   = temp
                
                create()
            end,
            move_tab_down = function(self,index)
                if index == #p.tab_labels then return end
                local temp  = p.tab_labels[index+1]
                p.tab_labels[index+1] = p.tab_labels[index]
                p.tab_labels[index]   = temp
                
                temp      = p.tabs[index+1]
                p.tabs[index+1] = p.tabs[index]
                p.tabs[index]   = temp
                
                create()
            end,
            
            --switching 'visible tab' functions
            display_tab = function(self,index)
                
				if index < 1 or index > #p.tab_labels then return end
                
				p.tabs[current_index]:hide()
                buttons[current_index].clear_focus()
				
                current_index = index
				
                p.tabs[current_index]:show()
                buttons[current_index].set_focus()
				
				if ap then
					ap:pan_to(
						
						buttons[current_index].x+buttons[current_index].w/2,
						buttons[current_index].y+buttons[current_index].h/2
						
					)
				end
            end,
			
            previous_tab = function(self)
                if current_index == 1 then return end

                
                self:display_tab(current_index-1)
            end,
			
            next_tab = function(self)
                if current_index == #p.tab_labels then return end
                
                self:display_tab(current_index+1)
            end,
			
			get_tab_group = function(self,index) return p.tabs[index] end,
			
			get_index = function(self) return current_index end,
			
			get_offset = function(self) return self.x+offset.x, self.y+offset.y end 
			
        }
		
    }
    
    create = function()
        
        local labels, txt_h, txt_w 
        
		current_index = 1
		
        umbrella:clear()

		if ap then ap = nil end

        tab_bg = {}
        tab_focus = {}
        
        local bg = Rectangle {
            color        = p.display_fill_color,
            border_color = p.display_border_color, --> border_color
            border_width = p.display_border_width, --> border_width
            w = p.display_width,
            h = p.display_height,
        }
        
        umbrella:add(bg)

		-- added these two lines for selected rectangle of contents
		p.ui_width = p.button_width
		p.ui_height = p.button_height

        for i = 1, #p.tab_labels do
            
			editor_use = true
            if p.tabs[i] == nil then
                p.tabs[i] = Group{}
            end
            p.tabs[i]:hide()

			
			buttons[i] = ui_element.button{
				
				ui_position          = { 0, 0 },
				skin                 = p.skin,
				ui_width             = p.button_width,
				ui_height            = p.button_height,
				focus_border_color   = p.focus_border_color,
				border_width         = p.border_width,
				border_corner_radius = p.border_corner_radius,
				label                = p.tab_labels[i],
				border_color         = p.border_color, 
				text_color           = p.text_color,
				text_font            = p.text_font,
				fill_color           = p.fill_color,
				focus_fill_color     = p.focus_fill_color,
				focus_text_color     = p.focus_text_color,
				on_press              = function () umbrella:display_tab(i) end,
				
			}
			
            if p.tab_position == "top" then
                buttons[i].x = (p.tab_spacing+buttons[i].w)*(i-1)
                p.tabs[i].y  = buttons[i].h
                p.tabs[i].x  = 0
            else
                p.tabs[i].y  = 0
                p.tabs[i].x  = buttons[i].w
                buttons[i].y = (p.tab_spacing+buttons[i].h)*(i-1)
            end
            umbrella:add(p.tabs[i],buttons[i])
			offset.x = p.tabs[i].x
			offset.y = p.tabs[i].y
			editor_use = false
        end
		
        for i = #p.tab_labels + 1, #buttons do
            
            if buttons[i].parent then buttons[i]:unparent() end
            
            buttons[i] = nil
            
        end
		--ap = nil
		
		if p.arrow_image then p.arrow_size = assets(p.arrow_image).w end
		
		if p.tab_position == "top" and
			(buttons[# buttons].w + buttons[# buttons].x) > (p.display_width - 2*(p.arrow_size+p.arrow_dist_to_frame)) then
			
			ap = ui_element.arrowPane{
				visible_width=p.display_width - 2*(p.arrow_size+p.arrow_dist_to_frame),
				visible_height=buttons[# buttons].h,
				virtual_width=buttons[# buttons].w + buttons[# buttons].x,
				virtual_height=buttons[# buttons].h,
				arrow_color=p.arrow_color,
				box_border_width=0,
				scroll_distance=buttons[# buttons].w,
				arrow_size = p.arrow_size,
				arrow_dist_to_frame = p.arrow_dist_to_frame,
				arrow_src = p.arrow_image,
			}
			
			ap.x = p.arrow_size+p.arrow_dist_to_frame
			ap.y = 0
			
			for _,b in ipairs(buttons) do
				
				b:unparent()
				ap.content:add(b)
				
			end
			
			umbrella:add(ap)
			
		elseif (buttons[# buttons].h + buttons[# buttons].y) > (p.display_height - 2*(p.arrow_size+p.arrow_dist_to_frame)) then
			
			ap = ui_element.arrowPane{
				visible_width=buttons[# buttons].w,
				visible_height=p.display_height - 2*(p.arrow_size+p.arrow_dist_to_frame),
				virtual_width=buttons[# buttons].w,
				virtual_height=buttons[# buttons].h + buttons[# buttons].y,
				arrow_color=p.arrow_color,
				box_border_width=0,
				scroll_distance=buttons[# buttons].h,
				arrow_size = p.arrow_size,
				arrow_dist_to_frame = p.arrow_dist_to_frame,
				arrow_src = p.arrow_image,
			}
			
			ap.x = 0
			ap.y = p.arrow_size+p.arrow_dist_to_frame
			
			for _,b in ipairs(buttons) do
				
				b:unparent()
				ap.content:add(b)
				
			end
			
			umbrella:add(ap)
			
		end
		
		if ap then
			
		end
		
        if p.tab_position == "top" then
            bg.y = buttons[1].h-p.border_width
        else
            bg.x = buttons[1].w-p.border_width
        end
        
        for i = #p.tab_labels+1, #p.tabs do
            p.tabs[i]  = nil
            --tab_bg[i]  = nil
            buttons[i] = nil
        end
		if editor_lb then 
			umbrella:display_tab(current_index)
		end 

    end
    
    create()
	
	local function tabBar_on_key_down(key)
		if umbrella.focus[key] then
			if type(umbrella.focus[key]) == "function" then
				umbrella.focus[key]()
			elseif screen:find_child(umbrella.focus[key]) then
				if umbrella.clear_focus then
					umbrella.clear_focus(key)
				end
				screen:find_child(umbrella.focus[key]):grab_key_focus()
				if screen:find_child(umbrella.focus[key]).set_focus then
					screen:find_child(umbrella.focus[key]).set_focus(key)
				end
			end
		end
		return true
	end

    --Key Handler
		local keys={
			[keys.Left] = function()
			if umbrella.tab_position == "top" then 
				if current_index - 1 >= 1 then
					umbrella:display_tab(current_index - 1)
				else
					tabBar_on_key_down(keys.Left)
				end
			else
				if current_focus.parent.name == umbrella.name then 
					--tabBar_on_key_down(keys.Up)
					local left_obj_name = umbrella.tabs[current_index].left_focus
					local left_obj 

					if left_obj_name then
						left_obj = screen:find_child(left_obj_name)
						if left_obj then
							if umbrella.clear_focus then
								umbrella.clear_focus(key)
							end
							left_obj:grab_key_focus()
							if left_obj.set_focus then
								left_obj.set_focus(key)
							end
						end
					end
				end
			end
		end,
		[keys.Right] = function()
			if umbrella.tab_position == "top" then 
				if current_index + 1 >  #umbrella.tab_labels then
					tabBar_on_key_down(keys.Right)
				else
					umbrella:display_tab(current_index + 1)
				end
			else 
				local right_obj_name = umbrella.tabs[current_index].right_focus
				local right_obj 

				if right_obj_name then
					right_obj = screen:find_child(right_obj_name)
					if right_obj then
						if umbrella.clear_focus then
							umbrella.clear_focus(key)
						end
						right_obj:grab_key_focus()
						if right_obj.set_focus then
							right_obj.set_focus(key)
						end
					end
				end
			end 
		end,
		[keys.Up] = function()
			if umbrella.tab_position == "top" then 
				if current_focus.parent.name == umbrella.name then 
				--tabBar_on_key_down(keys.Up)
				
					local up_obj_name = umbrella.tabs[current_index].up_focus
					local up_obj 

					if up_obj_name then
						up_obj = screen:find_child(up_obj_name)
						if up_obj then
							if umbrella.clear_focus then
								umbrella.clear_focus(key)
							end
							up_obj:grab_key_focus()
							if up_obj.set_focus then
								up_obj.set_focus(key)
							end
						end
					end
				end 
			else 
				if current_index - 1 >= 1 then
					umbrella:display_tab(current_index - 1)
				else
					tabBar_on_key_down(keys.Up)
				end
			end
		end,
		[keys.Down] = function()
			if umbrella.tab_position == "top" then 
				local down_obj_name = umbrella.tabs[current_index].down_focus
				local down_obj 

				if down_obj_name then
					down_obj = screen:find_child(down_obj_name)
					if down_obj then
						if umbrella.clear_focus then
							umbrella.clear_focus(key)
						end
						down_obj:grab_key_focus()
						if down_obj.set_focus then
							down_obj.set_focus(key)
						end
					end
				end
			else
				if current_index + 1 >  #umbrella.tab_labels then
					tabBar_on_key_down(keys.Down)
				else
					umbrella:display_tab(current_index + 1)
				end
			end 
		end,

		}

	umbrella.on_key_down = function (self, key)
		
		if keys[key] then keys[key]() end 

	end 

	umbrella.set_focus = function (key)
		umbrella:grab_key_focus()
		umbrella:display_tab(current_index)
	end 

	umbrella.clear_focus = function ()
		if current_focus then 
			current_focus.clear_focus ()
		end 
		current_focus = nil 
		screen:grab_key_focus()
	end 

    --set the meta table to overwrite the parameters
    setmetatable(umbrella.extra,{
		
		__newindex = function(t,k,v)
			
			p[k] = v

			if k ~= "selected" then
				
				create()
				
			end
			
		end,
		
		__index = function(t,k)       return p[k]       end,
		
    })

    return umbrella
end
--]]