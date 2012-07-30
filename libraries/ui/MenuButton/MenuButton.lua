
MENUBUTTON = true


local default_parameters = {
    direction = "down",
    vertical_alignment = "top",
    item_spacing = 0,
    popup_offset = 10,
}
MenuButton = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("MenuButton",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
    ----------------------------------------------------------------------------
	--The ButtonPicker Object inherits from LayoutManager
	
    local button = Button{style = false,w=300}
    
    local popup = ListManager()
    
	local instance = LayoutManager()
    
    ----------------------------------------------------------------------------
    
	override_property(instance,"popup_offset",
		function(oldf) return   instance.vertical_spacing     end,
		function(oldf,self,v)   instance.vertical_spacing = v end
	)
    ----------------------------------------------------------------------------
    
	override_property(instance,"item_spacing",
		function(oldf) return   popup.spacing     end,
		function(oldf,self,v)   popup.spacing = v end
	)
    ----------------------------------------------------------------------------
	
    instance:subscribe_to(
        "horizontal_alignment",
        function()
            popup.horizontal_alignment = instance.horizontal_alignment
        end
    )
    ----------------------------------------------------------------------------
    
	override_property(instance,"items",
		function(oldf) return   popup.cells     end,
		function(oldf,self,v)  
            
            if type(v) ~= "table" then error("Expected table. Received: ",2) end
            
            local items = {}
            
            for i, item in ipairs(v) do
                
                if type(item) == "table" and item.type then 
                    
                    item = _G[item.type](item)
                    
                elseif type(item) ~= "userdata" and item.__types__.actor then 
                
                    error("Must be a UIElement or nil. Received "..obj,2) 
                    
                end
                
                --items[i] = {item}
            end
            
            popup:set{
                length = #items,
                cells = v,
            }
            
            
        end
	)
    ----------------------------------------------------------------------------
    local direction
    
    local possible_directions = {
        up    = {{popup},{button}},
        down  = {{button},{popup}},
        left  = {{popup,button}},
        right = {{button,popup}},
    }
    
	override_property(instance,"direction",
		function(oldf) return   direction     end,
		function(oldf,self,v)  
            
            if not possible_directions[v] then
                error("MenuButton.direction expects 'up', 'down', 'left', or 'right'. Received: "..v,2)
            end
            if direction == v then return end
            instance:set{
                number_of_rows = 
                    ((v == "up"   or v == "down")  and 2) or
                    ((v == "left" or v == "right") and 1),
                number_of_cols = 
                    ((v == "up"   or v == "down")  and 1) or
                    ((v == "left" or v == "right") and 2),
                cells = possible_directions[v],
            }
            direction = v
            
        end
	)
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.number_of_cols       = nil
            t.number_of_rows       = nil
            t.vertical_alignment   = nil
            t.horizontal_alignment = nil
            t.vertical_spacing     = nil
            t.horizontal_spacing   = nil
            t.cell_h               = nil
            t.cell_w               = nil
            t.cells                = nil
            
            t.items = {}
            
            for i = 1,popup.length do
                t.items[i] = popup.cells[i].attributes
            end
            
            t.direction = instance.direction
            t.item_spacing = instance.item_spacing
            t.popup_offset = instance.popup_offset
            t.horizontal_alignment = instance.horizontal_alignment
            
            t.type = "MenuButton"
            
            return t
        end
    )
    
    ----------------------------------------------------------------------------
    function button:on_pressed()
        
        popup[ popup.is_visible and "hide" or "show" ](popup)
        
    end
    
    ----------------------------------------------------------------------------
	
	local instance_on_style_changed
    local function instance_on_style_changed()
        
        button.style:set(instance.style.attributes)
	end
	
    
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
    ----------------------------------------------------------------------------
    
	instance:set(parameters)
	
	return instance
    
end


--[=[

--[[
Function: Menu Button
]]

local function make_dropdown( size , color )

    local BORDER_WIDTH= 3
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR="FFFFFF5C"
    local CORNER_RADIUS=22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2
    
    local function draw_path( c )
    
        c:new_path()
    
        c:move_to( H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
        
        c:line_to( ( c.w / 2 ) - ( POINT_WIDTH / 2 ) - POINT_CORNER_RADIUS , POINT_HEIGHT - H_BORDER_WIDTH )
        
        
        c:curve_to( ( c.w / 2 ) - ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH ,
                    ( c.w / 2 ) - ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH ,
                     c.w / 2 , H_BORDER_WIDTH  )
        
        c:curve_to( ( c.w / 2 ) + ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH,
                    ( c.w / 2 ) + ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH,
                    ( c.w / 2 ) + ( POINT_WIDTH / 2 ) + POINT_CORNER_RADIUS , POINT_HEIGHT - H_BORDER_WIDTH )
                    
        c:line_to( c.w - H_BORDER_WIDTH - CORNER_RADIUS , POINT_HEIGHT - H_BORDER_WIDTH )
        c:curve_to( c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH ,
                    c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH ,
                    c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH + CORNER_RADIUS )
                    
        c:line_to( c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH - CORNER_RADIUS )
        c:curve_to( c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    c.w - H_BORDER_WIDTH - CORNER_RADIUS , c.h - H_BORDER_WIDTH )
        
        c:line_to( H_BORDER_WIDTH + CORNER_RADIUS , c.h - H_BORDER_WIDTH )
        c:curve_to( H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , c.h - H_BORDER_WIDTH - CORNER_RADIUS )
        
        c:line_to( H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH + CORNER_RADIUS )
        
        c:curve_to( H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH,
		    BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
    

    end
    local c = Canvas{ size = size }

    c:begin_painting()

    draw_path( c )

    -- Fill the whole thing with the color passed in and keep the path
    
    c:set_source_color( color )
    c:fill(true)
    
    -- Now, translate to the center and scale to its height. This will
    -- make the radial gradient elliptical.
    
    c:save()
    c:translate( c.w / 2 , c.h / 2 )
    c:scale( 2 , ( c.h / c.w ) )

    local rr = ( c.w / 2 ) 
    c:set_source_radial_pattern( 90 , 210 , 0 , 0 , 60 , c.w / 2 )
    c:add_source_pattern_color_stop( 0 , "00000000" )
    c:add_source_pattern_color_stop( 1 , "000000F0" )
    c:fill()   
    c:restore()
    -- Draw the glossy glow    

    local R = c.w * 2.2

    c:new_path()
    c.op = "ATOP"
    c:arc( 0 , -( R - 240 ) , R , 0 , 360 )
    c:set_source_linear_pattern( c.w , 0 , 0 , c.h * 0.25 )
    c:add_source_pattern_color_stop( 0 , "FFFFFF20" )
    c:add_source_pattern_color_stop( 1 , "FFFFFF04" )
    c:fill()

    -- Now, draw the path again and stroke it with the border color
    
    draw_path( c )

    c:set_line_width( BORDER_WIDTH )
    c:set_source_color( BORDER_COLOR )
    c.op = "SOURCE"
    c:stroke( true )

    c:finish_painting()
    
    if c.Image then
       c= c:Image()
    end

    return c
    
end

local function my_make_dropdown ( _ , ...)
	return make_dropdown( ... )
end 

function ui_element.menuButton(t)
    --default parameters
    local p = {
--[[
button 
--]]
--[[
        text_font = nil,
    	text_color = nil,
    	text_focus_color = nil,
        label_text_font = nil,
    	label_text_color = nil,
    	label_text_focus_colr = nil,
        item_text_font = nil,
    	item_text_color = nil,
    	item_text_focus_color = nil,
--]]
		text_font = "FreeSans Medium 30px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	skin = "CarbonCandy", 
    	ui_width = 250,
    	ui_height = 60, 

    	label = "Menu Button", 
    	focus_border_color = {27,145,27,255}, 	  --"1b911b", 
    	focus_fill_color = {27,145,27,0}, --"1b911b", 
		focus_text_color =  {255,255,255,255},   
    	border_color = {255,255,255,255}, --"FFFFFF"
    	fill_color = {255,255,255,0},     --"FFFFFF"
    	border_width = 1,
    	border_corner_radius = 12,
--]]

        items = {
            {type="label", string="Label"},
            {type="separator"},
            {type="item",  string="Item", f=nil},
        },

        vert_spacing = 5, --item_spacing
        horz_spacing = 5, -- new 
        vert_offset  = 40, --item_start_y
        
        background_color     = {255,0,0,255},
        
        menu_width = 250,   -- bg_w 
        horz_padding  = 5, -- padding 
        separator_thickness    = 2, --divider_h
        expansion_location   = "below", --bg_goes_up -> true => "above" / false == below

        align = "left",
        show_ring = true,
		ui_position = {300,300},
		----------------------------
        text_has_shadow = true,
		button_name = "button",
    }


    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local create
    local curr_index = 0
    local selectable_items  = {}

    local t_f = {"text_font", "label_text_font", "item_text_font"}
    local t_c = {"text_color", "label_text_color", "item_text_color",}
    local f_c = {"text_focus_color", "label_text_focus_color", "item_text_focus_color"}
    
    for k, v in pairs (t_f) do
	if p[v] == nil then 
		p[v] = p.text_font
	end 
    end 
    for k, v in pairs (t_c) do
	if p[v] == nil then 
		p[v] = p.text_color
	end 
    end 
    for k, v in pairs (f_c) do
	if p[v] == nil then 
		p[v] = p.focus_text_color
	end 
    end 

    local shadow 
    if p.skin == "editor" then
		shadow = true 
    else 
		shadow = false 
    end 

    local dropDownMenu = Group{}

    local button       = ui_element.button{
        text_font=p.text_font,
    	text_color=p.text_color,
    	focus_text_color=p.text_focus_color,
    	skin=p.skin,
    	ui_width=p.ui_width,
    	ui_height=p.ui_height, 
    	label=p.label, 
    	focus_border_color=p.focus_border_color,
    	focus_fill_color=p.focus_fill_color,
    	border_color=p.border_color, 
    	fill_color=p.fill_color, 
    	border_width=p.border_width,
    	border_corner_radius=p.border_corner_radius,
		text_has_shadow = shadow,
		is_in_menu = true, 
		ui_position = p.ui_position,
    }

	button.name = p.button_name

    local umbrella

    umbrella     = Group{
        name="menuButton",
        reactive = true,
        position = p.ui_position, 
        children = {button,dropDownMenu},
        extra={
            type="MenuButton",
            focus_index = function(i)
            if curr_index == i then
            	print("Item on Drop Down Bar is already focused")
                return
            end
            if selectable_items[curr_index] ~= nil then
            	selectable_items[curr_index].focus:complete_animation()
                selectable_items[curr_index].focus.opacity=255
                selectable_items[curr_index].focus:animate{
                	duration=300,
                	opacity=0
                }
            elseif curr_index==0 then
                    --button:clear_focus()
            end
            if selectable_items[i] ~= nil then
               selectable_items[i].focus:complete_animation()
               selectable_items[i].focus.opacity=0
               selectable_items[i].focus:animate{

               		duration=300,
                    opacity=255,
               }
               curr_index=i
           elseif i==0 then
           	   button:set_focus()
               curr_index=i
           end
           end,
	    get_index = function ()
		return curr_index
	    end,
            press_up = function()
                if curr_index <= 0 then
                    return
                else
                    umbrella.focus_index(curr_index-1)
                end
            end,
            press_down = function()
                if curr_index >= #selectable_items then
                    return
                else
                    umbrella.focus_index(curr_index+1)
                end
            end,
            insert_item = function (index,item)
                assert(type(item)=="table","invalid item")
                assert(index > 0 and index <= #p.items + 1, "invalid index")
                
                table.insert(p.items,index,item)
                create()
            end,
            remove_item = function (index)
                assert(index > 0 and index <= #p.items, "invalid index")
                
                table.remove(p.items,index)
                
                create()
            end,
            move_item_up = function (index)
                assert(index > 1 and index <= #p.items, "invalid index")
                
                local swp = p.items[index]
                p.items[index] = p.items[index-1]
                p.items[index-1] = swp
                
                create()
            end,
            move_item_down = function (index)
                assert(index > 0 and index < #p.items, "invalid index")
                
                local swp = p.items[index]
                p.items[index] = p.items[index+1]
                p.items[index+1] = swp
                
                create()
            end,
            replace_item = function(index,item)
                assert(type(item)=="table","invalid item")
                assert(index > 0 and index <= #p.items, "invalid index")
                
                p.items[index] = item
                create()
            end,
            index_from_y = function(y)
                y = y - umbrella.transformed_position[2]-p.vert_offset
                
                
            end,
            spin_in = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={90,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=300,
                    opacity=255,
                    y_rotation=0
                }
                if selectable_items[curr_index] then
                    selectable_items[curr_index].focus.opacity=0
                end
                curr_index = 0
            end,
            spin_out = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=300,
                    opacity=0,
                    y_rotation=-90
                }
            end,
            fade_in = function()
                dropDownMenu:show()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=100,
                    opacity=255,
                }
                for _,s_i in ipairs(selectable_items) do
                    s_i.focus.opacity=0
                end
                curr_index = 0
				umbrella:raise_to_top()
				input_mode = 5 -- hdr.S_MENU_M
            end,
            fade_out = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=100,
                    opacity=0,
		    		on_completed = function()  dropDownMenu:hide()  end,
                }
				input_mode = 0 -- SELECT
            end,
            set_item_function = function(index,f)
                assert(index > 0 and index <= #selectable_items, "invalid index")
                
                selectable_items[index].f=f
                
            end,
            press_enter = function(...)
                if selectable_items[curr_index] ~= nil and
                   selectable_items[curr_index].f ~= nil then
                   selectable_items[curr_index].f(...)
                else
                end
            end
        }

    }

	--yugi
	if editor_lb == nil or editor_use then  
		function button:on_key_down(key) 
			if key == keys.Down then 
				umbrella.press_down()
				return true
			elseif key == keys.Up then 
				umbrella.press_up()
				return true
			elseif key == keys.Return then 
				if curr_index > 0 then 
					umbrella.press_enter()
				end 
                umbrella.fade_out()
				if button.fade_in then -- ?
					button.fade_in = false
				end
				umbrella:grab_key_focus()
				return true
			end 
		end 
	end

    local function make_item_ring(w,h,padding)
        local ring = Canvas{ size = { w , h } }
        ring:begin_painting()
        ring:set_source_color( p.text_color )
        ring:round_rectangle(
            padding + 2 / 2,
            padding + 2 / 2,
            w - 2 - padding * 2 ,
            h - 2 - padding * 2 ,
            12 )
        ring:stroke()
        ring:finish_painting()
    	if ring.Image then
       		ring= ring:Image()
    	end
        return ring
    end
    
	local function my_make_item_ring (_, ...)
		return make_item_ring(...)	
	end 

    function umbrella.extra.set_focus(key) 
		if key then 
			if key == keys.Return then 
				button.set_focus(keys.Return)
			else 
				button.set_focus()
				umbrella:grab_key_focus()
			end 
		else 
				button.set_focus()
				umbrella:grab_key_focus()
		end 
    end
	 
	function umbrella.extra.clear_focus(key) 
		if key then 
			button.clear_focus(key)
		end
    end
   
    function create()
        --local vars used to create the menu

        local ui_ele = nil
        local txt, s_txt
        local curr_y = 0
        
        local max_item_w = 0
        local max_item_h = 0
        
        local txt_spacing = 10
        local txt_h       = Text{font=p.font}.h
        local inset       = 20
        
		local key 
		
        --reset globals
        curr_cat   = 1
        curr_index = 0
        selectable_items  = {}
        dropDownMenu:clear()
        dropDownMenu.opacity=0
        dropDownMenu:hide()
        
        button.text_font=p.text_font
    	button.text_color=p.text_color
    	button.skin=p.skin
    	button.ui_width=p.ui_width
    	button.ui_height=p.ui_height
        
    	button.label=p.label
    	button.focus_border_color=p.focus_border_color
    	button.fill_color=p.button_color
    	button.border_width=p.border_width
    	button.border_corner_radius=p.border_corner_radius
        
        umbrella.size = {button.ui_width,button.ui_height}
        curr_y = p.vert_offset
        
        --For each category
        local prev_item 

        for i = 1, #p.items do

            local item=p.items[i]
             
            if item.type == "separator" then
                dropDownMenu:add(
                    Rectangle{
                        x     = p.horz_padding,
                        y     = curr_y,
                        name  = "divider "..i,
                        w     = p.menu_width-2*p.horz_padding,
                        h     = p.separator_thickness,
                        color = txt_color
                    }
                )
                curr_y = curr_y + p.separator_thickness + p.vert_spacing
            elseif item.type == "item" then
                
                --Make the text label for each item
                if p.text_has_shadow then
                	s_txt = Text{
                        	text  = item.string,
                        	font  = p.item_text_font,
                        	color = "000000",
                        	opacity=255*.5,
                        	x     = p.horz_padding+p.horz_spacing - 1,
                        	y     = curr_y - 1,
                    }
                    s_txt.anchor_point={0,s_txt.h/2}
                    if item.icon then
                    	local icon_img = item.icon
                    	if icon_img.type ~= "Text" then
                    	    s_txt.y = s_txt.y+s_txt.h/2
                    	end 
                    else 
                    	s_txt.y = s_txt.y+s_txt.h/2
                    end 
                    dropDownMenu:add(s_txt)
                end
                txt = Text{
                        text  = item.string,
                        font  = p.item_text_font,
                        color = p.item_text_color,
                        x     = p.horz_padding+p.horz_spacing,
                        y     = curr_y,
                }
                txt.anchor_point={0,txt.h/2}
                txt.y = txt.y+txt.h/2
                if item.mstring then 
                    txt.use_markup =true
                    txt.markup = item.mstring
                end 
                dropDownMenu:add(txt)
                
                if item.bg then
                    ui_ele = item.bg
                    if i == #p.items and prev_item ~= nil then 
                    	ui_ele.anchor_point = { 0, prev_item.bg.h/2 }
                    	ui_ele.position     = {  0, txt.y }
                    else 
                    	ui_ele.anchor_point = { 0, ui_ele.h/2 }
                    	ui_ele.position     = {  0, txt.y }
                    end 
                    dropDownMenu:add(ui_ele)
                    if editor_lb == nil or editor_use then  
                        function ui_ele:on_button_down()
                            if dropDownMenu.opacity == 0 then return end
                            button.clear_focus() 
							button.fade_in = false
                            if item.f then item.f(item.parameter) end
							return true
                        end
                        function ui_ele:on_motion()
                            for _,s_i in ipairs(selectable_items) do
                                s_i.focus.opacity=0
                            end
                            item.focus.opacity=255
                        end
                        ui_ele.reactive=true
                    end
                elseif p.show_ring then
                    key = string.format("item_ring:%d, %d", p.menu_width-2*p.horz_spacing,txt.h+10)
                    ui_ele = assets (
						key, 
						my_make_item_ring, 
						p.menu_width-2*p.horz_spacing+7*2,
						txt.h+10,
						7
                    )
                    --ui_ele = make_item_ring (p.menu_width-2*p.horz_spacing,txt.h+10,7)
                    ui_ele.anchor_point = { ui_ele.w/2, ui_ele.h/2 }
                    ui_ele.position     = { p.menu_width/2, txt.y }
                    dropDownMenu:add(ui_ele)
                    if editor_lb == nil or editor_use then  
                        function ui_ele:on_button_down()
                            if dropDownMenu.opacity == 0 then return end
                            umbrella.fade_out()
							button.fade_in = false
                            if item.f then item.f(item.parameter) end
							return true
                        end
                        function ui_ele:on_motion()
                            for _,s_i in ipairs(selectable_items) do
                                s_i.focus.opacity=0
                            end
                            item.focus.opacity=255
                        end
                        ui_ele.reactive=true
                    end
                else
                    if editor_lb == nil or editor_use then  
                        function txt:on_button_down()
                            if dropDownMenu.opacity == 0 then return end
                            umbrella.fade_out()
							button.fade_in = false
                            if item.f then item.f(item.parameter) end
							return true
                        end
                        function ui_ele:on_motion()
                            for _,s_i in ipairs(selectable_items) do
                                s_i.focus.opacity=0
                            end
                            item.focus.opacity=255
                        end
                        txt.reactive=true
                    end
                end
                
                if item.focus then
                    ui_ele = item.focus
                else
					if skin_list[p.skin]["button_focus"] ~= nil then 
                    	ui_ele = assets(skin_list[p.skin]["button_focus"])
						if p.skin == "editor" then 
                    		ui_ele.size = {p.menu_width-2*p.horz_spacing,txt_h+15}
						else 
							ui_ele.size = {p.menu_width-2*p.horz_spacing+7*2,txt_h+15}	
						end 
                    	item.focus  = ui_ele
					end
                end
                
                ui_ele.name="focus"

				if p.skin == "editor" then 
                	if i == #p.items and prev_item ~= nil and
                    	prev_item.focus ~= nil then
                    	ui_ele.anchor_point = {  0, prev_item.focus.h/2 }
                    	ui_ele.position     = {  0, txt.y }
                	else 
                    	ui_ele.anchor_point = {  0, ui_ele.h/2 }
                    	ui_ele.position     = {  0, txt.y }
                	end 
				else 
					if i == #p.items and prev_item ~= nil and
                    	prev_item.focus ~= nil then
						ui_ele.anchor_point = {  prev_item.focus.w/2, prev_item.focus.h/2 }
                    	ui_ele.position     = {  p.menu_width/2, txt.y }
                	else 
						ui_ele.anchor_point = {  ui_ele.w/2, ui_ele.h/2 }
                    	ui_ele.position     = {  p.menu_width/2, txt.y }
                	end 
				end 

                ui_ele.opacity      = 0
                if ui_ele.parent then ui_ele:unparent() end
                dropDownMenu:add(ui_ele)
                table.insert(selectable_items,item)
                
                if item.icon then
                    ui_ele = item.icon
					if ui_ele.type == "Text" then 
						if p.text_has_shadow then
                			local ui_ele_shadow = Text{
                        		text  = ui_ele.text,
                        		font  = p.item_text_font,
                        		color = "000000",
                        		opacity=255*.5,
                    			anchor_point = {ui_ele.w,ui_ele.h/2}, 
                    			position={
                            			p.menu_width + 9 , txt.y -1
                    			}
							}

                    		s_txt.anchor_point={0,s_txt.h/2}
                    		s_txt.y = s_txt.y+s_txt.h/2
                			dropDownMenu:add(ui_ele_shadow)
                		end
                		ui_ele.font  = p.item_text_font
                        ui_ele.color = "#a6a6a6" --p.item_text_color
					end 

                    if ui_ele.parent then ui_ele:unparent() end
                    ui_ele.anchor_point = {ui_ele.w,ui_ele.h/2}
                    ui_ele.position={
                            p.menu_width + 10 , txt.y
                    }
                    dropDownMenu:add(ui_ele)
                end
                
                if p.text_has_shadow then
                    s_txt:raise_to_top()
                end
                txt:raise_to_top()
                if item.bg then
                    curr_y = curr_y + item.bg.h + p.vert_spacing
                else
                    curr_y = curr_y + txt.h
                end
            elseif item.type == "label" then
                if p.text_has_shadow then
                s_txt = Text{
                        text  = item.string,
                        font  = p.label_text_font,
                        color = "000000",
                        opacity=255*.5,
                        x     = p.horz_spacing-1,
                        y     = curr_y-1,
                    }
                s_txt.anchor_point={0,s_txt.h/2}
                s_txt.y = s_txt.y+s_txt.h/2
                dropDownMenu:add(
                    s_txt
                )
                end
                txt = Text{
                        text  = item.string,
                        font  = p.label_text_font,
                        color = p.label_text_color,
                        x     = p.horz_spacing,
                        y     = curr_y,
                    }
              txt.anchor_point={0,txt.h/2}
                    txt.y = txt.y+txt.h/2
                dropDownMenu:add(
                    txt
                )
                if item.bg then
                    ui_ele = item.bg
                    
                    ui_ele.anchor_point = { 0,     ui_ele.h/2 }
                    ui_ele.position     = {  0, txt.y }
                    dropDownMenu:add(ui_ele)
                    if p.text_has_shadow then
                        s_txt:raise_to_top()
                    end
                    txt:raise_to_top()
                    curr_y = curr_y + ui_ele.h + p.vert_spacing
                else
                    curr_y = curr_y + txt.h + p.vert_spacing
                end
                
                
            else
                print("Invalid type in the item list. Type: ",item.type)
            end
	    	prev_item = item

        end
        

        if p.background_color[4] ~= 0 then

			key = string.format ("dropDown:%d:%d:%s",  p.menu_width , curr_y, color_to_string(p.background_color) )
            ui_ele = assets(key, my_make_dropdown, { p.menu_width , curr_y } , p.background_color)

			--ui_ele = make_dropdown({ p.menu_width , curr_y } , p.background_color)
            
            dropDownMenu:add(ui_ele)
            ui_ele:lower_to_bottom()
            
            dropDownMenu.anchor_point = {ui_ele.w/2,ui_ele.h/2}
            if p.expansion_location == "above" then
                ui_ele.x_rotation={180,0,0}
                ui_ele.y = ui_ele.h+p.vert_offset
                dropDownMenu.position     = {ui_ele.w/2,-ui_ele.h/2-p.vert_offset}
            else
                dropDownMenu.position     = {ui_ele.w/2,ui_ele.h/2}
            end
        else
            dropDownMenu.anchor_point = {p.menu_width/2,0}
            if p.expansion_location == "above" then
                dropDownMenu.position     = {p.menu_width/2,-curr_y/2-p.vert_offset}
            else
                dropDownMenu.position     = {0,p.vert_offset}
            end
        end
        button.reactive=true
       
	if editor_lb == nil or editor_use then  
		button.on_press = function() umbrella.fade_in() menu_bar_hover = true end 
		button.on_unfocus = function() umbrella.fade_out() menu_bar_hover = false end 
 	end 
        
        button.position = {button.w/2,button.h/2}
        button.anchor_point = {button.w/2,button.h/2}
        if p.align=="left" then
              dropDownMenu.x = p.menu_width/2
        elseif p.align == "middle" then
              dropDownMenu.x = button.w/2
        elseif p.align == "right" then
              dropDownMenu.x = button.w
        else
              error("drop down alignment received an invalid argument: "..p.align)
        end
        
        if p.expansion_location == "above"  then
            dropDownMenu.y = dropDownMenu.y -10
        else
            dropDownMenu.y = dropDownMenu.y + button.h
        end
        
    end
    
    
    create()
    --set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        p[k] = v
	    if k ~= "selected" then 
			create()
	    end
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end

    setmetatable(umbrella.extra, mt)

    return umbrella
end
--]=]