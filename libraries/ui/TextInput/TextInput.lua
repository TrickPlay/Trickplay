--[[
Function: textInput

Creates a text field ui element

Arguments:
	Table of text field properties

	skin - Modify the skin used for the text field by changing this value
    bwidth  - Width of the text field
    bheight - Height of the text field 
    border_color - Border color of the text field
    focus_border_color - Focus color of the text field
    text_color - Color of the text in the text field
    text_font - Font of the text in the text field
    border_width - Border width of the text field 
    padding - Size of the text indentiation 
    border_corner_radius - Radius of the border for the button image 
    text - Caption of the text field  

Return:
 	t_group - The group contaning the text field
 	
Extra Function:
	clear_focus() - Releases the text field focus
	set_focus() - Grabs the text field focus
]]


function ui_element.textInput(t) 
 --default parameters
    local p = {
    	skin = "Custom", 
    	ui_width = 200 ,
    	ui_height = 60 ,
    	text = "",
    	padding = 20 ,
    	border_width  = 4 ,
    	border_color  = {255,255,255,255}, 
    	fill_color = {255,255,255,0},
    	focus_border_color  = {0,255,0,255},
    	focus_fill_color = {27,145,27,0}, 
    	cursor_color = {255,255,255,255},
    	text_font = "FreeSans Medium 30px", 
    	text_color =  {255,255,255,255},
    	border_corner_radius = 12 ,
		readonly = "",
		ui_position = {200,200,0},
		----------------
		justify = false,
		wrap = false,
		wrap_mode = "CHAR", -- CHAR, WORD, WORD_CHAR 
		alignment = "LEFT", -- LEFT, CENTER, RIGHT
		single_line = true, 
    }
 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end

 --the umbrella Group
    local t_group = Group
    {
       name = "textInput", 
       size = { p.ui_width , p.ui_height},
       position = p.ui_position, 
       reactive = true, 
       extra = {type = "TextInput"} 
    }

 	function t_group.extra.set_focus()

    	local box 		= t_group:find_child("box") 
		local focus_box = t_group:find_child("focus_box") 
		local box_img	= t_group:find_child("box_img") 
		local focus_img	= t_group:find_child("focus_img") 
		local text	= t_group:find_child("textInput") 

	  	current_focus = t_group

        if (p.skin == "Custom") then 
	    	box.opacity = 0
	     	focus_box.opacity = 255
        else
	    	box_img.opacity = 0
            focus_img.opacity = 255
        end 
	  	text.editable = true
	  	text.cursor_visible = true
	  	text.reactive = true 
        text:grab_key_focus(text)
     end

     function t_group.extra.clear_focus()

    	local box 		= t_group:find_child("box") 
		local focus_box = t_group:find_child("focus_box") 
		local box_img	= t_group:find_child("box_img") 
		local focus_img	= t_group:find_child("focus_img") 
		local text	    = t_group:find_child("textInput") 

        if (p.skin == "Custom") then 
	    	box.opacity = 255
	     	focus_box.opacity = 0
        else
	    	box_img.opacity = 255
           	focus_img.opacity = 0
        end 
	  	text.cursor_visible = false
	  	text.reactive = false 
		t_group.text = text.text
     end 

    local create_textInputField= function()
    	local box, focus_box, box_img, focus_img, readonly, text

    	t_group:clear()
        t_group.size = { p.ui_width , p.ui_height}

		if p.skin == "Custom" then 
			local key = string.format( "ring:%d:%d:%s:%s:%d:%d" , p.ui_width, p.ui_height, color_to_string( p.border_color ), 
										color_to_string( p.fill_color ), p.border_width, p.border_corner_radius )

    		box = assets( key, my_make_ring, p.ui_width, p.ui_height, p.border_color, p.fill_color, p.border_width, 0, 0, p.border_corner_radius)
    		box:set{name="box", position = {0 ,0}}

			key = string.format( "ring:%d:%d:%s:%s:%d:%d" , p.ui_width, p.ui_height, color_to_string( p.focus_border_color ), 
								  color_to_string( p.focus_fill_color ), p.border_width, p.border_corner_radius )

    		focus_box = assets(key, my_make_ring, p.ui_width, p.ui_height, p.focus_border_color, p.focus_fill_color, p.border_width, 0, 0, p.border_corner_radius)
    		focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0}
    		t_group:add(box, focus_box)

		else
    		box_img = assets(skin_list[p.skin]["textinput"])
    		box_img:set{name="box_img", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0 }
    		focus_img = assets(skin_list[p.skin]["textinput_focus"])
    		focus_img:set{name="focus_img", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0 }
    		t_group:add(box_img, focus_img)
		end 

		if p.readonly ~= "" then 
			readonly = Text{text= p.readonly, editable=false, cursor_visible=false, font = p.text_font, color = p.text_color, }

    		text = Text{text= p.text, editable=true, cursor_visible=false, single_line = p.single_line, 
						cursor_color = p.cursor_color, wants_enter = true, 
						alignment = p.alignment, justify = p.justify, wrap = p.wrap, wrap_mode = p.wrap_mode, 
						reactive = true, font = p.text_font, color = p.text_color, width = p.ui_width - 2 * p.padding - readonly.w}
			
    		readonly:set{name = "readonlyText", position = {p.padding, (p.ui_height - text.h)/2},}
    		text:set{name = "textInput", position = {readonly.x+readonly.w, (p.ui_height - text.h)/2},}

    		t_group:add(readonly, text)
		else 
    		text = Text{text= p.text, editable=true, cursor_visible=false, single_line = p.single_line, 
						cursor_color = p.cursor_color, wants_enter = true, 
						alignment = p.alignment, justify = p.justify, wrap = p.wrap, wrap_mode = p.wrap_mode, 
						reactive = false, font = p.text_font, color = p.text_color, width = p.ui_width - 2 * p.padding}

			if p.single_line == false then 
    			text:set{name = "textInput", position = {p.padding, p.padding}} 
			else
    			text:set{name = "textInput", position = {p.padding, (p.ui_height - text.h)/2},}
			end 

    		t_group:add(text)
		end

		local t_pos_min = t_group.x + t_group:find_child("textInput").x 
	
		function text:on_key_down(key)
			if p.single_line == true then 
				if key == keys.Return then 
					t_group:grab_key_focus()
					t_group:on_key_down(key)
				elseif key == keys.Tab then 
					t_group:grab_key_focus()
					t_group:on_key_down(key)
				end 
			end 
			p.text = text.text 
		end 
    end 

    create_textInputField()

	if editor_lb == nil or editor_use then 
	   	function t_group:on_button_down()
			t_group.extra.set_focus()
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
		if k ~= "selected" then 
        	create_textInputField()
		end
     end 

     mt.__index = function (t,k)
        if k == "bsize" then 
	     	return {p.ui_width, p.ui_height}  
        else 
	     	return p[k]
        end 
     end 
  
     setmetatable (t_group.extra, mt) 

     return t_group
end 