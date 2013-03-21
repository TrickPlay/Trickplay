BUTTON = true

local states = {"default","focus","activation"}

--default create_canvas function
local create_canvas = function(self,state)
	
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors[state] or self.style.fill_colors.default )     c:fill(true)
	
	c:set_source_color( self.style.border.colors[state] or self.style.border.colors.default )   c:stroke(true)
	
	return c:Image()
	
end


local default_parameters = {
	w = 200, h = 50, label = "Button", reactive = true
}

Button = function(parameters)
	
	--input is either nil or a table
	parameters = is_table_or_nil("Button",parameters) -- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	
	--flags
	local canvas          = type(parameters.images) == "nil"
	local flag_for_redraw = false --ensure at most one canvas redraw from Button:set()
	local from_set        = false --indicates that an attribute is being set in Button:set()
	local size_is_set = -- an ugly flag that is used to determine if the user set the Button size themselves yet
		parameters.h or
		parameters.w or
		parameters.height or
		parameters.width or
		parameters.size
	
	
	--upvals
	local images
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = Widget( parameters )
	--the default w and h does not count as setting the size
	if not size_is_set then instance:reset_size_flag() end

	local states = parameters.states or states
	
	local label = Text()
    local local_create_canvas = create_canvas
	
	----------------------------------------------------------------------------
	-- Helper functions that setup animation states
	
	-- setting up animation states for new images/canvases
	local define_image_animation = function(image)
		
		local prev_state = image and image.state and image.state.state
		
		local a = AnimationState{
			duration    = 100,
			transitions = {
				{
					source = "*", target = "OFF",
					keys   = {  {image, "opacity",  0},  },
				},
				{
					source = "*", target = "ON",
					keys   = {  {image, "opacity",255},  },
				},
			}
		}
		
		a:warp(prev_state or "OFF")
		
		return a
		
	end
	
	-- setting up animation states for the label (called when label_colors changes)
	local define_label_animation = function()
		
		local label_colors = instance.style.text.colors
		local prev_state
        if label and label.state then
            prev_state = label.state.state
            label.state.timeline:stop()
        end
		
		label.state = AnimationState{
			duration    = 100,
			transitions = {
				{
					source = "*",  target = "DEFAULT",
					keys   = {  {label, "color",label_colors.default},  },
				},
				{
					source = "*",  target = "FOCUS",
					keys   = {  {label, "color",label_colors.focus},  },
				},
				{
					source = "*",  target = "ACTIVATION",
					keys   = {  {label, "color",label_colors.activation},  },
				},
			}
		}
		
		label.state:warp(prev_state or "DEFAULT")
	end
	
	----------------------------------------------------------------------------
	-- private helper functions for common actions
	
	local function resize_images()
		
		if not size_is_set then return end
		
		for k,img in pairs(images) do img.w = instance.w end
		for k,img in pairs(images) do img.h = instance.h end
		
	end
	
	local center_label = function()
		
		label.w = instance.w
		label.y = instance.style.text.y_offset + instance.h/2
		
	end
	
	----------------------------------------------------------------------------
	-- helper functions used when Button.images is set
	
	local make_canvases = function()
		
		if from_set then
			
			flag_for_redraw = true
			
			return
			
		end
		
		flag_for_redraw = false
		
		canvas = true
		
		images = {}
		
		instance:clear()
		
		for _,state in pairs(instance.states) do
			
			images[state] = instance:create_canvas(state)
			instance:add(images[state])
			if state ~= "default" then
				images[state].state = define_image_animation(images[state])
			end
		end
		
		
		instance:add( label )
		
		return true
		
	end
	
	local setup_images = function(new_images)
		
		canvas = false
		
		images = new_images
		
		instance:clear()
		
		for _,state in pairs(instance.states) do
			
			if images[state] then
				
				images[state] = type(images[state] ) == "string" and
					Image{src=images[state]} or images[state]
				
				instance:add(images[state])
				
				if state ~= "default" then
					images[state].state = define_image_animation(images[state])
				end
				
			end
			
		end
		
		instance:add( label )
		
		if instance.is_size_set() then
			
			resize_images()
			
		else
			--so that the label centers properly
			instance.size = images.default.size
			
			instance:reset_size_flag()
			
			center_label()
			
		end
		
		return true
		
	end
	
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
	override_property(instance,"widget_type",
		function() return "Button" end, nil
	)
    
	override_property(instance,"images",
		
		function(oldf)    return images   end,
		
		function(oldf,self,v)
			
			return v == nil and make_canvases() or
				
				type(v) == "table" and setup_images(v) or
				
				error("Button.images expected type 'table'. Received "..type(v),2)
			
		end
	)
	
	override_property(instance,"label",
		function(oldf)    return label.text     end,
		function(oldf,self,v)    label.text = v end
	)
	
	override_property(instance,"type",   function() return "BUTTON" end )
	override_property(instance,"states", function() return  states  end )
	
	--[[
	override_function(instance,"set", function(old_function, ... )
		
		from_set = true    old_function(...)     from_set = false
		
		if flag_for_redraw then make_canvases() end
		
	end)
	--]]
	----------------------------------------------------------------------------
	--state changes for focus
	
    local on_focus_in  = parameters.on_focus_in
	local on_focus_out = parameters.on_focus_out
	
	instance:subscribe_to( "enabled",
		function()
            if not instance.enabled then
                --image
                if images.focus then   images.focus.state.state = "OFF"   end
                --text
                label.state.state = "DEFAULT"
            elseif instance.focused then
                --image
                if images.focus then   images.focus.state.state = "ON"   end
                --text
                label.state.state = "FOCUS"
                --event callback
                if on_focus_in then on_focus_in() end
            end
        end
	)
	instance:subscribe_to( "focused",
		function()
            if not instance.enabled then return end
            if instance.focused then
                --image
                if images.focus then   images.focus.state.state = "ON"   end
                --text
                label.state.state = "FOCUS"
                --event callback
                if on_focus_in then on_focus_in() end
            else
                --image
                if images.focus then   images.focus.state.state = "OFF"   end
                --text
                label.state.state = "DEFAULT"
                --event callback
                if on_focus_out then on_focus_out() end
            end
        end
	)
	override_property(instance,"on_focus_in",  function() return on_focus_in  end, function(oldf,self,v) on_focus_in  = v end )
    override_property(instance,"on_focus_out", function() return on_focus_out end, function(oldf,self,v) on_focus_out = v end )
	
	----------------------------------------------------------------------------
	-- events/functions pertaining to the button being pressed
	
    local on_pressed  = parameters.on_pressed
	local on_released = parameters.on_released
	local pressed     = false
	
	override_function(instance,"click", function(old_function,self)
		
		instance:press()
		
		dolater( 150, function()   instance:release()   end)
		
	end)
	
	override_function(instance,"press", function(old_function,self)
		
		if pressed then return end
		
		pressed = true
		
		--image
		if images.activation then  images.activation.state.state = "ON"  end
		--text
		label.state.state = "ACTIVATION"
		--event callback
		if on_pressed then on_pressed() end
		
		
	end)
	
	override_function(instance,"release", function(old_function,self)
		
		if not pressed then return end
		
		pressed = false
		
		--image
		if images.activation then  images.activation.state.state = "OFF"  end
		--text
		label.state.state = focused and "FOCUS" or "DEFAULT"
		--event callback
		if on_released then on_released() end
		
	end)
	
	override_property(instance,"on_pressed",   function() return on_pressed   end, function(oldf,self,v) on_pressed   = v end )
    override_property(instance,"on_released",  function() return on_released  end, function(oldf,self,v) on_released  = v end )
	
    ----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
                
            t.label = self.label
            
            if not canvas then
                
                t.images = {}
                
                for state, img in pairs(images) do
                    
                    while img.source do img = img.source end
                    
                    if img.src and img.src ~= "[canvas]" then t.images[state] = img.src end
                end
                
            end
            
            t.type = "Button"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
	--Widget/Style Event Callbacks, to notify if properties change
	
	--sets the function that creates canvases for individual button states
	override_property(instance,"create_canvas",
        function(oldf,self)
            return local_create_canvas
        end,
        function(oldf,self,v)
            local_create_canvas =v or create_canvas
        end
    )
	instance:subscribe_to(
		{"h","w","width","height","size","create_canvas"},
		function()
			
			flag_for_redraw = true
			
			center_label()
			
		end
	)
	instance:subscribe_to(
		nil,
		function()
			
			if flag_for_redraw then
				flag_for_redraw = false
				if canvas then
					make_canvases()
				else
					resize_images()
				end
			end
			
		end
	)
	local text_style
	local update_label  = function()
		
		text_style = instance.style.text
		
		label:set(   text_style:get_table()   )
		
		label.anchor_point = {0,label.h/2}
		label.x            = text_style.x_offset
		label.y            = text_style.y_offset + instance.h/2
		label.w            = instance.w
		
	end
	
	local canvas_callback = function() if canvas then make_canvases() end end
	
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, canvas_callback )
        instance.style.fill_colors:subscribe_to( nil, canvas_callback )
        instance.style.text.colors:subscribe_to( nil, define_label_animation )
        instance.style.text:subscribe_to( nil, update_label )
        
		update_label()
		define_label_animation()
		canvas_callback()
	end
	
    
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	--Key events
	function instance:on_key_focus_in()    instance.focused = true  end 
	function instance:on_key_focus_out()   instance.focused = false end 
	
	instance:add_key_handler(   keys.OK, function() instance:click()   end)
	
	----------------------------------------------------------------------------
	--Mouse events
	
	function instance:on_enter()        instance.focused = true   end
	function instance:on_leave()        instance.focused = false  instance:release() end 
	function instance:on_button_down()  instance:press()          end
	function instance:on_button_up()    instance:release()        end
	
	----------------------------------------------------------------------------
	-- apply initial values
	
	--set up the label [using the Widget.style.text.on_changed callback]
	--update_label()
	--define_label_animation()
	
	-- if no images, the instance.images is set to nil, causing the canvases to be drawn
	
    if not canvas then instance.images = parameters.images end
	instance.label  = parameters.label
	instance.create_canvas  = parameters.create_canvas
	
	return instance
	
end












--[[
Function: button

Creates a button ui element

Arguments:
	Table of button properties
	
	skin - Modify the skin for the button by changing this value
    bwidth  - Width of the button
    bheight - Height of the button
    button_color - Border color of the button
    focus_border_color - Focus color of the button
    border_width - Border width of the button
    text - Caption of the button
    text_font - Font of the button text
    text_color - Color of the button text
    padding_x - Padding of the button image on the X axis
    padding_y - Padding of the button image on the Y axis
    border_corner_radius - Radius of the border for the button
	on_press - Function that is called by set_focus() or on_key_down() event
	on_unfocus - Function that is called by clear_focus()
Return:
 	b_group - The group containing the button 

Extra Function:
	clear_focus() - Releases the button focus
	set_focus() - Grabs the button focus
]]

--[==[
function ui_element.button(t) 

 --default parameters
    local p = {
    	text_font = "FreeSans Medium 30px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	skin = "CarbonCandy", 
    	ui_width = 180,
    	ui_height = 60, 

    	label = "Button", 
    	focus_border_color = { 27,145, 27,255}, 
    	focus_fill_color   = { 27,145, 27,  0}, 
    	focus_text_color   = {255,255,255,255},
    	border_color       = {255,255,255,255}, 
    	fill_color         = {255,255,255,  0},
    	border_width = 1,
    	border_corner_radius = 12,

		on_focus = nil, 
		on_press = nil, 
		on_unfocus = nil, 

		text_has_shadow = true,
		ui_position = {100,100,0},
		--------------------------------
		button_image  = nil,
		focus_image   = nil,
		single_button = false,
		is_in_menu    = false,
		fade_in       = false,
		label_align   = nil,
		tab_button    = false, 
    }

 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local b_group = Group
    {
        name = "button", 
        size = { p.ui_width , p.ui_height},
        position = p.ui_position, 
        reactive = true,
        extra = {type = "Button"}
    } 
    
    function b_group.extra.set_focus(key) 
		local ring = b_group:find_child("ring") 
		local focus_ring = b_group:find_child("focus_ring") 
		local button = b_group:find_child("button_dim") 
		local focus = b_group:find_child("button_focus") 

		if (p.skin == "Custom") then 
	     	ring.opacity = 0
	     	focus_ring.opacity = 255
        else
	     	button.opacity = 0
            focus.opacity = 255
        end 
        b_group:find_child("text").color = p.focus_text_color

		if b_group.is_in_menu == true then 
			if b_group.fade_in == true then 
				return 
			end 
	   end 

		current_focus = b_group
	
	    if p.on_focus ~= nil then 
			p.on_focus()
		end 

		b_group:grab_key_focus(b_group)

		if key then 
	    	if p.on_press and key == keys.Return then
				p.on_press()
				if b_group.is_in_menu == true and b_group.fade_in == false then 
					b_group.fade_in = true 
					menu_bar_hover = true 
				end
	    	end 
		end 
		
		if p.skin == "edit" then 
			input_mode = 5 
		end 
    end
    
    function b_group.extra.clear_focus(key, focus_to_tabButton) 

		local ring = b_group:find_child("ring") 
		local focus_ring = b_group:find_child("focus_ring") 
		local button = b_group:find_child("button_dim") 
		local focus = b_group:find_child("button_focus") 

			
		if b_group.tab_button == true and focus_to_tabButton == nil then 
			prev_tab = b_group
			return 
		else
        	if (p.skin == "Custom") then 
	     		ring.opacity = 255
	     		focus_ring.opacity = 0
        	else
	     		button.opacity = 255
            	focus.opacity = 0
        	end
		end 
        b_group:find_child("text").color = p.text_color

		current_focus = nil 

		if b_group.is_in_menu == true then 
			if b_group.fade_in == false then 
				return 
			end
	    end 


		if p.on_unfocus then  
			if p.is_in_menu then 
				if key ~= keys.Return and b_group.single_button == false then
					p.on_unfocus()
					if b_group.is_in_menu == true and b_group.fade_in == true then 
						b_group.fade_in = false 
					end
				end 
			elseif b_group.single_button == false then 
				p.on_unfocus()
			end
		end 
    end

    local create_button = function() 
	
		local ring, focus_ring, button, focus, text, s_txt

        b_group:clear()
        b_group.size = {p.ui_width , p.ui_height}

		if p.skin == "Custom" then
			local key = string.format( "ring:%d:%d:%s:%s:%d:%d" , p.ui_width, p.ui_height, color_to_string( p.border_color ), color_to_string( p.fill_color ), p.border_width, p.border_corner_radius )
	
			ring = assets( key , my_make_ring , p.ui_width, p.ui_height, p.border_color, p.fill_color, p.border_width, 0, 0, p.border_corner_radius )
        	ring:set{name="ring", position = { 0 , 0 }, opacity = 255 }

			key = string.format( "ring:%d:%d:%s:%s:%d:%d" , p.ui_width, p.ui_height, color_to_string( p.focus_border_color ), color_to_string( p.focus_fill_color ), p.border_width, p.border_corner_radius )

			focus_ring = assets( key , my_make_ring , p.ui_width, p.ui_height, p.focus_border_color, p.focus_fill_color, p.border_width, 0, 0, p.border_corner_radius )
        	focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0}

		elseif(p.skin == "editor") then 
	    	button= assets("assets/invisible_pixel.png")
            button:set{name="button_dim", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
	    	focus= assets("assets/menu-bar-focus.png")
            focus:set{name="button_focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
		elseif(p.skin == "inspector") then 
	    	button= Group{}
			focus = Group{}
			
			left_cap = assets("lib/assets/button-small-leftcap.png")
			repeat_1px = assets("lib/assets/button-small-center1px.png")
			repeat_1px:set{tile={true, false}, width = p.ui_width-left_cap.w*2, position = {left_cap.w, 0}} 
			right_cap = assets("lib/assets/button-small-rightcap.png")
			right_cap:set{position = {p.ui_width-left_cap.w, 0 }} 
			button:add(left_cap, repeat_1px, right_cap)
			button:set{name="button_dim", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 255}
			button.reactive = true 


			left_cap_f = assets("lib/assets/button-small-leftcap-focus.png")
			repeat_1px_f = assets("lib/assets/button-small-center1px-focus.png")
			repeat_1px_f:set{tile={true, false}, width = p.ui_width - left_cap_f.w * 2, position = {left_cap_f.w, 0}} 
			right_cap_f = assets("lib/assets/button-small-rightcap-focus.png")
			right_cap_f:set{position = {p.ui_width-left_cap_f.w, 0 }} 
			focus:add(left_cap_f, repeat_1px_f, right_cap_f)
            focus:set{name="button_focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
			button.reactive = true 

		else
            button = assets(skin_list[p.skin]["button"])
            button:set{name="button_dim", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 255}
            focus = assets(skin_list[p.skin]["button_focus"])
            focus:set{name="button_focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
		end 

        text = Text{name = "text", text = p.label, font = p.text_font, color = p.text_color} --reactive = true 
		if p.label_align ~= nil then 
        	text:set{name = "text", position = { 10, p.ui_height/2 - text.h/2}}
		else 
        	text:set{name = "text", position = { (p.ui_width-text.w)/2, p.ui_height/2 - text.h/2}}
		end 
	
		if p.skin == "Custom" then 
			b_group:add(ring, focus_ring)
		else 
			b_group:add(button, focus)
		end 

		if p.text_has_shadow then 
	       	s_txt = Text{
		    	name = "shadow",
            	text  = p.label, 
            	font  = p.text_font,
            	color = {0,0,0,255/2},
            	x     = p.ui_width/2-text.w/2 - 1,
            	y     = p.ui_height/2- text.h/2 - 1,
            }
			if p.label_align ~= nil then 
            	s_txt.x = 9
			end 
            s_txt.anchor_point={0,s_txt.h/2}
            s_txt.y = s_txt.y+s_txt.h/2
        	b_group:add(s_txt)
		end 

        b_group:add(text)
	end 

    create_button()
	
	if editor_lb == nil or editor_use then 

		local ring = b_group:find_child("ring") 
		local focus_ring = b_group:find_child("focus_ring") 
		local button = b_group:find_child("button_dim") 
		local focus = b_group:find_child("button_focus") 

     	function b_group:on_button_down(x,y,b,n)
			
			if b_group.tab_button == true and b_group.parent.buttons ~= nil then 
				for q,w in pairs (b_group.parent.buttons) do
					if w.label ~= b_group.label then 
						if (w.skin == "Custom") then 
     						w:find_child("ring").opacity = 255
     						w:find_child("focus_ring").opacity = 0
       					else
     						w:find_child("button_dim").opacity = 255
           					w:find_child("button_focus").opacity = 0
       					end
					end 
				end 
			end 
				
			if current_focus ~= b_group then 
				if current_focus then 
					local temp_focus = current_focus
	     			current_focus.clear_focus(nil,true)
					if temp_focus.is_in_menu == true then 
						temp_focus.fade_in = false
					end 
					if prev_tab then 
						prev_tab.clear_focus(nil,true)
					end 
				end
				b_group.extra.set_focus(keys.Return)
			else 
	     		current_focus.clear_focus()
				if b_group.is_in_menu ~= true then 
					current_focus = b_group
	     			current_focus.set_focus(keys.Return)
				end 
				screen:grab_key_focus()
			end 
			return true
     	end 

		function b_group:on_button_up(x,y,b,n)
			if b_group.single_button == true then 
     			button.opacity = 255
           		focus.opacity = 0
     			focus_ring.opacity = 0
			end 
			return true
     	end 
	end
	
    mt = {}
    mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    	p.ui_width = v[1] p.ui_height = v[2]  
        else 
           	p[k] = v
        end
		if k ~= "selected" and k ~= "fade_in" then 
        	create_button()
		end
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
        else 
	    return p[k]
        end 
    end 

    setmetatable (b_group.extra, mt) 

    return b_group 
end
--]==]