
editor_ui = {}

function editor_ui.button(table) 
 	--default parameters
    local p = {
    	text_font = "FreeSans 15px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	skin = "default", 
    	ui_width = 180,
    	ui_height = 60, 
    	label = "Button", 
    	focus_color = {27,145,27,255}, 
    	focus_fill_color = {27,145,27,0}, 
    	focus_text_color = {255,255,255,255},
    	border_color = {255,255,255,255}, 
    	fill_color = {255,255,255,0},
    	border_width = 1,
    	border_corner_radius = 12,
		focussed=nil, 
		pressed = nil, 
		released = nil, 
		button_image = nil,
		focus_image  = nil,
		text_has_shadow = true,
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local text, button, focus, s_txt

    local b_group = Group
    {
        name = "button", 
        size = { p.ui_width , p.ui_height},
        position = {100, 100, 0},  
        reactive = true,
        extra = {type = "Button"}
    } 
    
    function b_group.extra.on_focus_in(key) 
		current_focus = b_group
	    button.opacity = 0
        focus.opacity = 255
        b_group:find_child("text").color = p.focus_text_color
	
	    if p.focused ~= nil then 
			p.focused()
		end 

	if key then 
	    if p.pressed and key == keys.Return then
		p.pressed()
	    end 
	end 
	
	if p.skin == "edit" then 
		input_mode = S_MENU_M
	end 

	b_group:grab_key_focus(b_group)
    end
    
    function b_group.extra.on_focus_out(key) 
		current_focus = nil 
	    button.opacity = 255
        focus.opacity = 0
        b_group:find_child("text").color = p.text_color
		if p.released then 
			p.released()
		end 
    end

    local create_button = function() 
        b_group:clear()
        b_group.size = { p.ui_width , p.ui_height}
		if(p.skin == "editor") then 
	    	button= assets("assets/invisible_pixel.png")
            button:set{name="button", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
	    	focus= assets("assets/menu-bar-focus.png")
            focus:set{name="focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
		else 
	     	button = Image{src="lib/assets/button-oobe.png", size = {p.ui_width, p.ui_height}}
	     	focus = Image{src="lib/assets/buttonfocus-oobe.png", opacity = 0, size = {p.ui_width, p.ui_height}}
		end 
        text = Text{name = "text", text = p.label, font = p.text_font, color = p.text_color} --reactive = true 
        text:set{name = "text", position = { (p.ui_width  -text.w)/2, (p.ui_height - text.h)/2}}
	
		b_group:add(button, focus)
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
			b_group.extra.on_focus_in(keys.Return)
		else 
		     	--current_focus.on_focus_in(keys.Return)
		     	current_focus.on_focus_out()
			screen:grab_key_focus()
		end 
		return true
	     end 
	end 

	if p.skin == "editor"  then 
	     function b_group:on_motion()
		if input_mode == S_MENU_M then 
		    if current_focus ~= b_group then 
			if current_focus then 
		     		current_focus.on_focus_out()
			end
			b_group.extra.on_focus_in(keys.Return)
		    else 
		     	current_focus.on_focus_in(keys.Return)
		    end 
		end 
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




function editor_ui.scrollPane(t)
	-- reference: http://www.csdgn.org/db/179
    --default parameters
    local p = {
        visible_w    =  280,
        visible_h    =  330,
        content   = Group{},
		virtual_w = 280,
        virtual_h = 500,
        bar_color_inner     = {180,180,180,255},
        bar_color_outer     = {30,30,30,255},
        empty_color_inner   = {120,120,120,255},
        empty_color_outer   = {255,255,255,255},
        frame_thickness     =    2,
        frame_color        = {60, 60,60,255},
        bar_thickness       =   15,
        bar_offset          =    5,
        vert_bar_visible    = true,
        horz_bar_visible     = true,
        
        box_color = {160,160,160,255},
        box_width = 2,
        skin="default",
    }
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	--Group that Clips the content
	local window  = Group{name="window"}
	--Group that contains all of the content
	--local content = Group{}
	--declarations for dependencies from scroll_group
	local scroll, scroll_x, scroll_y
	--flag to hold back key presses while animating content group
	local animating = false
	local border = Rectangle{ color = "00000000" }
	
	local track_h, track_w, grip_hor, grip_vert, track_hor, track_vert
	

    --the umbrella Group, containing the full slate of tiles
    local scroll_group = Group{ 
        name     = "msgwScroll",
        position = {0,30},
        reactive = true,
        extra    = {
			type = "ScrollPane",
            seek_to_middle = function(x,y)
                local new_x, new_y
                if p.virtual_w > p.visible_w then
                    if x > p.virtual_w - p.visible_w/2 then
                        new_x = -p.virtual_w + p.visible_w
                    elseif x < p.visible_w/2 then
                        new_x = 0
                    else
                        new_x = -x + p.visible_w/2
                    end
                else
                    new_x =0
                end
                if p.virtual_h > p.visible_h then
                    if y > p.virtual_h - p.visible_h/2 then
                        new_y = -p.virtual_h + p.visible_h
                        --print(1)
                    elseif y < p.visible_h/2 then
                        new_y = 0
                        --print(2)
                    else
                        new_y = -y + p.visible_h/2
                        --print(3)
                    end
                else
                    new_y =0
                end
                
                if new_x ~= p.content.x or new_y ~= p.content.y then
                    p.content:animate{
                        duration = 200,
                        x = new_x,
                        y = new_y,
                        on_completed = function()
                            animating = false
                        end
                    }
                
                    if grip_vert ~= nil then
                    if new_y < -(p.virtual_h - p.visible_h) then
                        grip_vert.y = track_h-grip_vert.h
                    elseif new_y > 0 then
                        grip_vert.y = 0
                    elseif new_y ~= p.content.y then
                        grip_vert:complete_animation()
                        grip_vert:animate{
                            duration= 200,
                            y = 0-(track_h-grip_vert.h)*new_y/(p.virtual_h - p.visible_h)
                        }
                    end
                    end
                    if grip_hor ~= nil then
                    if new_x < -(p.virtual_w - p.visible_w) then
                        grip_hor.x = track_w-grip_hor.w
                    elseif new_x > 0 then
                        grip_hor.x = 0
                    elseif new_x ~= p.content.x then
                        grip_hor:complete_animation()
                        grip_hor:animate{
                            duration= 200,
                            x = 0-(track_w-grip_hor.w)*new_x/(p.virtual_w - p.visible_w)
                        }
                    end
                    end
                end
            end
            --[[
			get_content_group = function()
				return content
			end
            --]]
        }
    }
    scroll_group.extra.seek_to = function(x,y)
        scroll_group.extra.seek_to_middle(x+p.visible_w/2,y+p.visible_h/2)
    end
	
	--Key Handler
	local keys={
		[keys.Left] = function()
			if p.visible_w < p.virtual_w then
				scroll_x(1)
			end
		end,
		[keys.Right] = function()
			if p.visible_w < p.virtual_w then
				scroll_x(-1)
			end
		end,
		[keys.Up] = function()
			if p.visible_h < p.virtual_h then
				scroll_y(1)
			end
		end,
		[keys.Down] = function()
			if p.visible_h < p.virtual_h then
				scroll_y(-1)
			end
		end,
	}
	scroll_group.on_key_down = function(self,key)
		if animating then return end
		if keys[key] then
			keys[key]()
		end
	end
	
	scroll_y = function(dir)
		local new_y = p.content.y+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			y = new_y,
			on_completed = function()
				if p.content.y < -(p.virtual_h - p.visible_h) then
					p.content:animate{
						duration = 200,
						y = -(p.virtual_h - p.visible_h),
						on_completed = function()
							animating = false
						end
					}
				elseif p.content.y > 0 then
					p.content:animate{
						duration = 200,
						y = 0,
						on_completed = function()
							animating = false
						end
					}
				else
					animating = false
				end
			end
		}
		
		if new_y < -(p.virtual_h - p.visible_h) then
			grip_vert.y = track_h-grip_vert.h
		elseif new_y > 0 then
			grip_vert.y = 0
		else
			grip_vert:complete_animation()
			grip_vert:animate{
				duration= 200,
				y = 0-(track_h-grip_vert.h)*new_y/(p.virtual_h - p.visible_h)
			}
		end
	end
	
	
	scroll_x = function(dir)
		local new_x = p.content.x+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			x = new_x,
			on_completed = function()
				if p.content.x < -(p.virtual_w - p.visible_w) then
					p.content:animate{
						duration = 200,
						y = -(p.virtual_w - p.visible_w),
						on_completed = function()
							animating = false
						end
					}
				elseif p.content.x > 0 then
					p.content:animate{
						duration = 200,
						x = 0,
						on_completed = function()
							animating = false
						end
					}
				else
					animating = false
				end
			end
		}
		
		if new_x < -(p.virtual_w - p.visible_h) then
			grip_hor.x = track_w-grip_hor.w
		elseif new_x > 0 then
			grip_hor.x = 0
		else
			grip_hor:complete_animation()
			grip_hor:animate{
				duration= 200,
				x = 0-(track_w-grip_hor.w)*new_x/(p.virtual_w - p.visible_w)
			}
		end
	end
    local function make_hor_bar(w,h,ratio)
        local bar = Group{}
        
		local shell = Canvas{
				size = {w,h},
		}
		local fill  = Canvas{
				size = {w*ratio,h-p.frame_thickness},
		}  
        
		
		local RAD = 6
        
		local top    =           math.ceil(p.frame_thickness/2)
		local bottom = shell.h - math.ceil(p.frame_thickness/2)
		local left   =           math.ceil(p.frame_thickness/2)
		local right  = shell.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		shell:move_to(        left,         top )
		shell:line_to(   right-RAD,         top )
		shell:curve_to( right, top,right,top,right,top+RAD)
		shell:line_to(       right,  bottom-RAD )
		shell:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		shell:line_to(           left+RAD,          bottom )
		shell:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		shell:line_to(           left,            top+RAD )
		shell:curve_to(left,top,left,top,left+RAD,top)
        
		shell:set_source_linear_pattern(
            
            shell.w/2,0,
			shell.w/2,shell.h
		)
		shell:add_source_pattern_color_stop( 0 , p.empty_color_inner )
		shell:add_source_pattern_color_stop( 1 , p.empty_color_outer )
        
		shell:fill(true)
		shell:set_line_width(   p.frame_thickness )
		shell:set_source_color( p.frame_color )
		shell:stroke( true )
		shell:finish_painting()
        
        -----------------------------------------------------
        
		top    =          math.ceil(p.frame_thickness/2)
		bottom = fill.h - math.ceil(p.frame_thickness/2)
		left   =          math.ceil(p.frame_thickness/2)
		right  = fill.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		fill:move_to(        left,         top )
		fill:line_to(   right-RAD,         top )
		fill:curve_to( right, top,right,top,right,top+RAD)
		fill:line_to(       right,  bottom-RAD )
		fill:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		fill:line_to(           left+RAD,          bottom )
		fill:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		fill:line_to(           left,            top+RAD )
		fill:curve_to(left,top,left,top,left+RAD,top)
        
		fill:set_source_linear_pattern(
			fill.w/2,0,
			fill.w/2,fill.h
		)
		fill:add_source_pattern_color_stop( 0 , p.bar_color_inner )
		fill:add_source_pattern_color_stop( 1 , p.bar_color_outer )
		fill:fill(true)
        fill:set_line_width(   p.frame_thickness )
		fill:set_source_color( p.frame_color )
		fill:stroke( true )
		fill:finish_painting()
        
        -----------------------------------------------------
        
		if shell.Image then shell = shell:Image() end
		if  fill.Image then  fill =  fill:Image() end
        
		bar:add(shell,fill)
        
        shell.name="track"
        shell.reactive = true
        fill.name="grip"
        fill.reactive=true
        fill.y=p.frame_thickness/2 
        return bar
    end
    local function make_vert_bar(w,h,ratio)
        local bar = Group{}
        
		local shell = Canvas{
				size = {w,h},
		}
		local fill  = Canvas{
				size = {w-p.frame_thickness,h*ratio},
		}  
        
		
		local RAD = 6
        
		local top    =           math.ceil(p.frame_thickness/2)
		local bottom = shell.h - math.ceil(p.frame_thickness/2)
		local left   =           math.ceil(p.frame_thickness/2)
		local right  = shell.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		shell:move_to(        left,         top )
		shell:line_to(   right-RAD,         top )
		shell:curve_to( right, top,right,top,right,top+RAD)
		shell:line_to(       right,  bottom-RAD )
		shell:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		shell:line_to(           left+RAD,          bottom )
		shell:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		shell:line_to(           left,            top+RAD )
		shell:curve_to(left,top,left,top,left+RAD,top)
        
		shell:set_source_linear_pattern(
			0,shell.h/2,
            shell.w,shell.h/2
		)
		shell:add_source_pattern_color_stop( 0 , p.empty_color_inner )
		shell:add_source_pattern_color_stop( 1 , p.empty_color_outer )
        
		shell:fill(true)
		shell:set_line_width(   p.frame_thickness )
		shell:set_source_color( p.frame_color )
		shell:stroke( true )
		shell:finish_painting()
        
        -----------------------------------------------------
        
		top    =          math.ceil(p.frame_thickness/2)
		bottom = fill.h - math.ceil(p.frame_thickness/2)
		left   =          math.ceil(p.frame_thickness/2)
		right  = fill.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		fill:move_to(        left,         top )
		fill:line_to(   right-RAD,         top )
		fill:curve_to( right, top,right,top,right,top+RAD)
		fill:line_to(       right,  bottom-RAD )
		fill:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		fill:line_to(           left+RAD,          bottom )
		fill:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		fill:line_to(           left,            top+RAD )
		fill:curve_to(left,top,left,top,left+RAD,top)
        
		fill:set_source_linear_pattern(
			0,fill.h/2,
            fill.w,fill.h/2
		)
		fill:add_source_pattern_color_stop( 0 , p.bar_color_inner )
		fill:add_source_pattern_color_stop( 1 , p.bar_color_outer )
		fill:fill(true)
        fill:set_line_width(   p.frame_thickness )
		fill:set_source_color( p.frame_color )
		fill:stroke( true )
		fill:finish_painting()
        
        -----------------------------------------------------
        
		if shell.Image then
			shell = shell:Image()
		end
		if fill.Image then
			fill = fill:Image()
		end
        
		bar:add(shell,fill)
        
        shell.name="track"
        shell.reactive = true
        fill.name="grip"
        fill.reactive=true
        fill.x=p.frame_thickness/2 
        return bar
    end
	
	
	--this function creates the whole scroll bar box
        local hold = false
	local function create()
        window.position={ p.box_width, p.box_width }
		window.clip = { 0,0, p.visible_w, p.visible_h }
        border:set{
            w = p.visible_w+2*p.box_width,
            h = p.visible_h+2*p.box_width,
            border_width =    p.box_width,
            border_color =    p.box_color,
        }
		
        if  scroll_group:find_child("Horizontal Scroll Bar") then
            scroll_group:find_child("Horizontal Scroll Bar"):unparent()
        end
        
        if  scroll_group:find_child("Vertical Scroll Bar") then
            scroll_group:find_child("Vertical Scroll Bar"):unparent()
        end
        
        if p.bar_offset < 0 then
            track_w = p.visible_w+p.bar_offset
            track_h = p.visible_h+p.bar_offset
        else
            track_w = p.visible_w
            track_h = p.visible_h
        end
        
--[[
if editor_lb == nil  then
            function screen:on_motion(x,y) 
	  	if dragging then
	        local actor = unpack(dragging)
	    	  if (actor.name == "grip") then  
	             local actor,s_on_motion = unpack(dragging) 
	             s_on_motion(x, y)
	             return true
	    	  end 
		  return true 
		end
	    end 
	    function screen:on_button_up()
		if dragging then 
			dragging = nil 
		end 
	    end 
end
]]
        
        if p.horz_bar_visible and p.visible_w/p.virtual_w < 1 then
            hor_s_bar = make_hor_bar(
                track_w,
                p.bar_thickness,
                track_w/p.virtual_w
            )
            hor_s_bar.name = "Horizontal Scroll Bar"
            hor_s_bar.position={
                p.box_width,
                p.box_width*2+p.visible_h+p.bar_offset
            }
            scroll_group:add(hor_s_bar)
            
            grip_hor = hor_s_bar:find_child("grip")
            track_hor = hor_s_bar:find_child("track")
            function grip_hor:on_button_down(x,y,button,num_clicks)
                local dx = x - grip_hor.x
	   	        
                dragging = {grip_hor,
	   		        function(x,y)
	   			
	   			        grip_hor.x = x - dx
	   			
	   			        if  grip_hor.x < 0 then
	   				        grip_hor.x = 0
	   			        elseif grip_hor.x > track_w-grip_hor.w then
	   				           grip_hor.x = track_w-grip_hor.w
	   			        end
	   			
	   			        p.content.x = -(grip_hor.x ) * p.virtual_w/track_w
	   			
	   		        end 
	   	        }
	   	
                return true
            end

            function track_hor:on_button_down(x,y,button,num_clicks)
                
                local rel_x = x - track_hor.transformed_position[1]/screen.scale[1]
	   	        
                if rel_x < grip_hor.w/2 then
                    rel_x = grip_hor.w/2
                elseif rel_x > (track_hor.w-grip_hor.w/2) then
                    rel_x = (track_hor.w-grip_hor.w/2)
                end
                
                grip_hor.x = rel_x-grip_hor.w/2
                
                p.content.x = -(grip_hor.x) * p.virtual_w/track_w
                
                return true
            end
        else
            grip_hor=nil
            track_hor=nil
        end
        if p.vert_bar_visible and p.visible_h/p.virtual_h < 1 then
            vert_s_bar = make_vert_bar(
                
                p.bar_thickness,
                track_h,
                track_h/p.virtual_h
            )
            vert_s_bar.name = "Vertical Scroll Bar"
            vert_s_bar.position={
                p.box_width*2+p.visible_w+p.bar_offset,
                p.box_width
            }
            scroll_group:add(vert_s_bar)
            
            grip_vert = vert_s_bar:find_child("grip")
            track_vert = vert_s_bar:find_child("track")
            function grip_vert:on_button_down(x,y,button,num_clicks)
                
                local dy = y - grip_vert.y
	   	        
                dragging = {grip_vert,
	   		        function(x,y)
	   			
	   			        grip_vert.y = y - dy
	   			
	   			        if  grip_vert.y < 0 then
	   				        grip_vert.y = 0
	   			        elseif grip_vert.y > track_h-grip_vert.h then
	   				           grip_vert.y = track_h-grip_vert.h
	   			        end
	   			
	   			        p.content.y = -(grip_vert.y) * p.virtual_h/track_h
	   			
	   		        end 
	   	        }
	   	
                return true
            end



	    
            function track_vert:on_button_down(x,y,button,num_clicks)
                
                local rel_y = y - track_vert.transformed_position[2]/screen.scale[2]
	   	        
                if rel_y < grip_vert.h/2 then
                    rel_y = grip_vert.h/2
                elseif rel_y > (track_vert.h-grip_vert.h/2) then
                    rel_y = (track_vert.h-grip_vert.h/2)
                end
                
                grip_vert.y = rel_y-grip_vert.h/2
                
                p.content.y = -(grip_vert.y) * p.virtual_h/track_h
                
                return true
            end
        else
            grip_vert=nil
            track_vert=nil
        end
        scroll_group.size = {p.visible_w, p.visible_h}
	end
	
    
	scroll_group:add(border,window)
    create()
	window:add(p.content)
	
	--set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        if k == "content" then
            p.content:unparent()
            if v.parent ~= nil then
                v:unparent()
            end
            v.position={0,0}
            v.reactive = false
            window:add(v)
        end
        p[k] = v
        create()
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(scroll_group.extra, mt)

    return scroll_group
end

return editor_ui
