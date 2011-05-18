
editor_ui = {}

function editor_ui.button(table) 
 	--default parameters
    local p = {
    	skin = "default",  --default, dim, red, active 
    	label = "Button", 
    	ui_width = 100,
    	ui_height = 27, 

    	text_font = "FreeSans Medium 15px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	focus_text_color = {255,255,255,255},

		focussed=nil, 
		pressed = nil, 
		released = nil, 

		button_image = nil,
		focus_image  = nil,
		--text_has_shadow = true,
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local text, button, focus, s_txt, active

    local b_group = Group
    {
        name = "button", 
        size = { p.ui_width , p.ui_height},
        position = {100, 100, 0},  
        reactive = true,
        extra = {type = "EditorButton"}
    } 
    
    function b_group.extra.on_focus_in(key) 

		print("b_group focused")
		print(b_group.name)

		current_focus = b_group

		if key == "focus" then 
        	button.opacity = 0
        	focus.opacity = 255
        	active.opacity = 0
        	b_group:find_child("text").color = p.focus_text_color
		else 
        	button.opacity = 0
        	focus.opacity = 0
        	active.opacity = 255
        	b_group:find_child("text").color = p.focus_text_color
		end 
	
	    if p.focused ~= nil then 
			p.focused()
		end 

		if key then 
	    	if p.pressed and key == keys.Return then
				p.pressed()
	    	end 
		end 
	
		b_group:grab_key_focus(b_group)
    end
    
    function b_group.extra.on_focus_out(key) 
		current_focus = nil 
	    button.opacity = 255
        focus.opacity = 0
        active.opacity = 0
        b_group:find_child("text").color = p.text_color
		if p.released then 
			p.released()
		end 
    end

    local create_button = function() 
        b_group:clear()
        b_group.size = { p.ui_width , p.ui_height}

	    button = Group{name = "dim", opacity = 255, size = {p.ui_width, p.ui_height}}
		leftcap = Image{src="lib/assets/button-dim-leftcap.png", position = {0,0}}
		rightcap = Image{src="lib/assets/button-dim-rightcap.png", position = {p.ui_width-10,0}}
		center1px = Image{src="lib/assets/button-dim-center1px.png", position = {leftcap.w,0}, tile = {true, false}, width = p.ui_width-20}
		button:add(leftcap,center1px,rightcap) 
		
	    focus = Group{name  ="red", opacity = 0, size = {p.ui_width, p.ui_height}}
		redleftcap = Image{src="lib/assets/button-red-leftcap.png", position = {0,0}}
		redrightcap = Image{src="lib/assets/button-red-rightcap.png", position = {p.ui_width-10,0}}
		redcenter1px = Image{src="lib/assets/button-red-center1px.png", position = {leftcap.w,0}, tile = {true, false}, width = p.ui_width-20}
		focus:add(redleftcap,redcenter1px,redrightcap) 

	    active = Group{name ="active", opacity = 0, size = {p.ui_width, p.ui_height}}
		activeleftcap = Image{src="lib/assets/button-active-leftcap.png", position = {0,0}}
		activerightcap = Image{src="lib/assets/button-active-rightcap.png", position = {p.ui_width-10,0}}
		activecenter1px = Image{src="lib/assets/button-active-center1px.png", position = {leftcap.w,0}, tile = {true, false}, width = p.ui_width-20}
		active:add(activeleftcap,activecenter1px,activerightcap) 

        text = Text{name = "text", text = p.label, font = p.text_font, color = p.text_color} --reactive = true 
        text:set{name = "text", position = { (p.ui_width  -text.w)/2, (p.ui_height - text.h)/2}}
	
		b_group:add(button, active, focus)

		if p.text_has_shadow then 
	       s_txt = Text{
		        name = "shadow",
                        text  = p.label, 
                        font  = p.text_font,
                        color = {0,0,0,255/2},
                        x     = (p.ui_width  -text.w)/2 - 1,
                        y     = (p.ui_height - text.h)/2 - 1,
                    }
                    s_txt.anchor_point={0,s_txt.h/2}
                    s_txt.y = s_txt.y+s_txt.h/2
        	b_group:add(s_txt)
		end 

        b_group:add(text)

		if editor_lb == nil or editor_use then 
	     	function b_group:on_button_down(x,y,b,n)
			if current_focus ~= b_group then 
				if current_focus then 
		     		current_focus.on_focus_out()
				end
			end 
		    b_group.extra.on_focus_in("focus")
			return true
	    	end 
			function b_group:on_button_up(x,y,b,n)
				if current_focus ~= b_group then 
					if current_focus then 
		     			current_focus.on_focus_out()
					end
				end 
				b_group.extra.on_focus_in(keys.Return)
				return true
	     	end 
	     	function b_group:on_motion()
		    if current_focus ~= b_group then 
				if current_focus then 
		     		current_focus.on_focus_out()
				end
		    end 
			b_group.extra.on_focus_in("focus")
			end 
    	end
	end 
	
    create_button()
	
    mt = {}
    mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		print(k,v)
		print("create_button()called")
        create_button()
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



