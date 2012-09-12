editor_ui = {}

function editor_ui.button(table) 
 	--default parameters
    local p = {
    	skin = "default",  
    	label = "Button", 
    	ui_width = 100,
    	ui_height = 27, 

    	text_font = "FreeSans Medium 15px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	focus_text_color = {255,255,255,255},

		on_focus=nil, 
		on_press = nil, 
		on_unfocus = nil, 

		button_image = nil,
		focus_image  = nil,
		active_button = false,
		focus_object = nil,
		text_has_shadow = true
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local text, active, button, focus, s_txt

    local b_group = Group
    {
        name = "button", 
        size = { p.ui_width , p.ui_height},
        position = {100, 100, 0},  
        reactive = true,
        extra = {type = "EditorButton"}
    } 
    
    function b_group.extra.set_focus(key) 

		if current_focus ~= nil then 
			if current_focus.clear_focus then 
				current_focus.clear_focus()
			end 
		end 

		if key == "focus" then 
        	focus.opacity = 255
        	active.opacity = 0
		else 
        	active.opacity = 255
        	focus.opacity = 0
		end 

        button.opacity = 0
        b_group:find_child("text").color = p.focus_text_color
	
		current_focus = b_group

	    if p.on_focus ~= nil then 
			p.on_focus()
		end 

		b_group:grab_key_focus(b_group)

		if key then 
	    	if p.on_press and key == keys.Return then
				p.on_press()
	    	end 
		end 
	
    end
    
    function b_group.extra.clear_focus(key) 
		if key == "active" then 
        	active.opacity = 255
	    	button.opacity = 0
		else 
	    	button.opacity = 255
        	active.opacity = 0
		end
        focus.opacity = 0
        b_group:find_child("text").color = p.text_color
		current_focus = nil 

		if p.on_unfocus then 
			p.on_unfocus()
		end 
    end

    local create_button = function() 
        b_group:clear()
        b_group.size = { p.ui_width , p.ui_height}

	    button = Group{name = "dim", opacity = 255, size = {p.ui_width, p.ui_height}}
		local leftcap = assets("lib/assets/button-dim-leftcap.png"):set{position = {0,0}}
		local rightcap = assets("lib/assets/button-dim-rightcap.png"):set{position = {p.ui_width-10,0}}
		local center1px = assets("lib/assets/button-dim-center1px.png"):set{position = {leftcap.w,0}, tile = {true, false}, width = p.ui_width-20}
		button:add(leftcap,center1px,rightcap) 
		
	    focus = Group{name  ="red", opacity = 0, size = {p.ui_width, p.ui_height}}
		local redleftcap = assets("lib/assets/button-red-leftcap.png"):set{ position = {0,0}}
		local redrightcap = assets("lib/assets/button-red-rightcap.png"):set{ position = {p.ui_width-10,0}}
		local redcenter1px = assets("lib/assets/button-red-center1px.png"):set{ position = {leftcap.w,0}, tile = {true, false}, width = p.ui_width-20}
		focus:add(redleftcap,redcenter1px,redrightcap) 

	    active = Group{name ="active", opacity = 0, size = {p.ui_width, p.ui_height}}
		local activeleftcap = assets("lib/assets/button-active-leftcap.png"):set{ position = {0,0}}
		local activerightcap = assets("lib/assets/button-active-rightcap.png"):set{ position = {p.ui_width-10,0}}
		local activecenter1px = assets("lib/assets/button-active-center1px.png"):set{ position = {leftcap.w,0}, tile = {true, false}, width = p.ui_width-20}
		active:add(activeleftcap,activecenter1px,activerightcap) 

        text = Text{name = "text", text = p.label, font = p.text_font, color = p.text_color} --reactive = true 
        text:set{name = "text", position = { (p.ui_width  -text.w)/2, (p.ui_height - text.h)/2 - 1}}
	
		b_group:add(button, active, focus)

		b_group.extra.dim = button
		b_group.extra.active = active
		b_group.extra.focus = focus

		if p.text_has_shadow then 
	       s_txt = Text {
		        	name = "shadow",
                    text  = p.label, 
                    font  = p.text_font,
                    color = {0,0,0,255/2},
                    x= (p.ui_width  -text.w)/2 - 1,
                    y= (p.ui_height - text.h)/2 - 2,
            }
            s_txt.anchor_point={0,s_txt.h/2}
            s_txt.y = s_txt.y+s_txt.h/2
        	b_group:add(s_txt)
		end 

        b_group:add(text)

	    function b_group:on_button_down(x,y,b,n)
			if current_focus ~= b_group then 
				if current_focus then 
		     		current_focus.clear_focus()
				end
			end 
		    b_group.extra.set_focus("focus")
			return true
	  	end 
		function b_group:on_button_up(x,y,b,n)
				if current_focus ~= b_group then 
					if current_focus then 
		     			current_focus.clear_focus()
					end
				end 
				b_group.extra.set_focus(keys.Return)
				return true
	     end 
	     function b_group:on_enter()
		 		if current_focus ~= b_group then 
					if current_focus then 
		     			current_focus.clear_focus()
					end
				end 
				b_group.extra.set_focus("focus")
		 end 

	     function b_group:on_leave()
			if b_group.active_button == true then 
				b_group.clear_focus("active")
			else 
				b_group.clear_focus()
			end 

			if p.focus_object ~= nil then 
				if 	p.focus_object.set_focus then
					p.focus_object.set_focus()
				end
			end 
		 end 
		
		 function b_group:on_key_down(key)
				if b_group.focus[key] then
					if type(b_group.focus[key]) == "function" then
							b_group.focus[key]()
					elseif screen:find_child(b_group.focus[key]) then
						if b_group.clear_focus then
							b_group.clear_focus()
						end
						screen:find_child(b_group.focus[key]):grab_key_focus()
						if screen:find_child(b_group.focus[key]).set_focus then
							screen:find_child(b_group.focus[key]).set_focus(key)
						end
					else 
					   b_group:grab_key_focus()
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
    --default parameters
    local p = {
        visible_w    =  285,
        visible_h    =  330,
        content   	 = Group{},
        virtual_h 	 = 242,
        virtual_w 	 = 285,
        arrow_color  = {255,255,255,255},
        arrows_visible = true,
        bar_color_inner     = {180,180,180,255},
        bar_color_outer     = {30,30,30,255},
        empty_color_inner   = {120,120,120,255},
        empty_color_outer   = {255,255,255,255},
        frame_thickness     =    0,
        frame_color        = {60, 60,60,255},
        bar_thickness       =   15,
        bar_offset          =    0,
        vert_bar_visible    = true,
        horz_bar_visible     = true,
        
        box_color = {160,160,160,255},
        box_border_width = 0,
        skin="default",
    }

	
    --overwrite defaults
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

	local border = Rectangle{ color = "00000000", } 
	
	local track_h, track_w, grip_hor, grip_vert, track_hor, track_vert
	

    --the umbrella Group, containing the full slate of tiles
    local scroll_group = Group{ 
        name     = "scrollPane",
        position = {0,0},
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
                    elseif y < p.visible_h/2 then
                        new_y = 0
                    else
                        new_y = -y + p.visible_h/2
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
        }
    }


	 function scroll_group.extra.set_focus(key) 
		for i,j in pairs (scroll_group.content.children) do 
			if j.name then 
			if string.find(j.name, "h_rect") ~= nil then 
				if j.opacity == 255 then 
					j:grab_key_focus()
				end
			end 
			end
		end 
    end
    
    function scroll_group.extra.clear_focus(key) 
    end

    scroll_group.extra.seek_to = function(x,y)
        scroll_group.extra.seek_to_middle(x+p.visible_w/2,y+p.visible_h/2)
    end
	
	--Key Handler
	local keys={
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
		scroll_group.extra.set_focus()
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
    local make_arrow = function(dir)
		local arrow
		if dir == "up" then 
			arrow = Image{src = "lib/assets/scrollbar-btn-up.png"}
			arrow.anchor_point={arrow.w/2,arrow.h}
		else 
			arrow = Image{src = "lib/assets/scrollbar-btn-down.png"}
			arrow.anchor_point={arrow.w/2,0}
		end 
		return arrow
		
	end
    local function make_hor_bar(w,h,ratio)
    end
    local function make_vert_bar(w,h,ratio)
		local bar = Group()
        local fill = Group{name="grip",reactive = true, }
        local shell = Group{name="track",reactive = true, }

		local top= assets("lib/assets/scrollbar-grip-top.png")
		local bottom= assets("lib/assets/scrollbar-grip-bottom.png")
		local handle= assets("lib/assets/scrollbar-grip-handle.png")
		local t_1px = assets("lib/assets/scrollbar-grip-repeat1px.png"):set{position = {0,top.h}, tile = {false, true}, height = (h*ratio-(top.h+bottom.h+handle.h))/2 }
		local b_1px = assets("lib/assets/scrollbar-grip-repeat1px.png"):set{position = {0,top.h+t_1px.h+handle.h - 2}, tile = {false, true}, height = (h*ratio-(top.h+bottom.h+handle.h))/2 }

		bottom.position={0,top.h+t_1px.h+handle.h+b_1px.h - 3}
		handle.position={0,top.h + t_1px.h - 1}
		fill.anchor_point = {t_1px.w/2,0}

		local shell_top= assets("lib/assets/scrollbar-track-top.png")
		local shell_bottom= assets("lib/assets/scrollbar-track-bottom.png")
		local shell_t_1px = assets("lib/assets/scrollbar-track-repeat1px.png"):set{position = {0,shell_top.h}, tile = {false, true}, height = (h-(shell_top.h+shell_bottom.h))/2 }
		local shell_b_1px = assets("lib/assets/scrollbar-track-repeat1px.png"):set{position = {0,shell_top.h+shell_t_1px.h}, tile = {false, true}, height = (h-(shell_top.h+shell_bottom.h))/2}

		shell_bottom.position={0,shell_top.h+shell_t_1px.h+shell_b_1px.h}

		fill:add(top,t_1px,handle,b_1px,bottom) 
		shell:add(shell_top,shell_t_1px,shell_b_1px,shell_bottom) 

		bar:add(shell,fill)
		fill.x = shell_t_1px.w/2
        return bar
    end
	
	
	--this function creates the whole scroll bar box
        local hold = false
		local function create()
        window.position={ p.box_border_width, p.box_border_width }
		window.clip = { 0,0, p.visible_w, p.visible_h }
        border:set{
            w = p.visible_w+2*p.box_border_width,
            h = p.visible_h+2*p.box_border_width,
            border_width =    p.box_border_width,
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
        elseif p.arrows_visible then
            track_w = p.visible_w-p.bar_thickness*2
            track_h = p.visible_h-p.bar_thickness*2
        else
            track_w = p.visible_w
            track_h = p.visible_h
        end
        
		if p.horz_bar_visible and p.visible_w/p.virtual_w < 1 then
            hor_s_bar = make_hor_bar(
                track_w,
                p.bar_thickness,
                track_w/p.virtual_w
            )
            hor_s_bar.name = "Horizontal Scroll Bar"
            if p.arrows_visible then
                local l = make_arrow()
                l.name="L"
                l.x = p.box_border_width+p.bar_thickness
                l.y = p.box_border_width*2+p.visible_h+p.bar_offset+p.bar_thickness/2
                scroll_group:add(l)
                l.reactive=true
                function l:on_button_down()
                    scroll_x(1)
                end
                hor_s_bar.position={
                    p.box_border_width+p.bar_thickness,
                    p.box_border_width*2+p.visible_h+p.bar_offset
                }
                local r = make_arrow()
                r.name="R"
                r.x = p.box_border_width+p.bar_thickness+hor_s_bar.w
                r.y = p.box_border_width*2+p.visible_h+p.bar_offset+p.bar_thickness/2
                scroll_group:add(r)
                r.reactive=true
            else
                hor_s_bar.position={
                    p.box_border_width,
                    p.box_border_width*2+p.visible_h+p.bar_offset
                }
            end
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
                
                if  grip_hor.transformed_position[1] >
	   		        track_hor.transformed_position[1] then
	   		        
	   		        grip_hor.x = grip_hor.x - grip_hor.w
	   		        if grip_hor.x < 0 then grip_hor.x = 0 end
                else
	   		        grip_hor.x = grip_hor.x + grip_hor.w
	   		        if grip_hor.x > track_hor.w-grip_hor.w then
	   			        grip_hor.x = track_hor.w-grip_hor.w
	   		        end
                end
                
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
            if p.arrows_visible then
                local up = make_arrow("up")
                up.name="UP"
                up.x = p.box_border_width*2+p.visible_w+p.bar_offset+p.bar_thickness/2
                up.y = p.box_border_width+p.bar_thickness
                scroll_group:add(up)
                up.reactive=true
                function up:on_button_down()
                    scroll_y(1)
                end
                vert_s_bar.position={
                    p.box_border_width*2+p.visible_w+p.bar_offset,
                    p.box_border_width+p.bar_thickness
                }
                local dn = make_arrow("down")
                dn.name="DN"
                dn.x = p.box_border_width*2+p.visible_w+p.bar_offset+p.bar_thickness/2
                dn.y = p.box_border_width+p.bar_thickness+vert_s_bar.h
                --dn.z_rotation = {180,0,0}
                scroll_group:add(dn)
                dn.reactive=true
                function dn:on_button_down()
                    scroll_y(-1)
                end
            else
                vert_s_bar.position={
                    p.box_border_width*2+p.visible_w+p.bar_offset,
                    p.box_border_width
                }
            end
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
                
                if  grip_vert.transformed_position[2] >
	   		        track_vert.transformed_position[2] then
	   		        
	   		        grip_vert.y = grip_vert.y - grip_vert.h
	   		        if grip_vert.y < 0 then grip_vert.y = 0 end
                else
	   		        grip_vert.y = grip_vert.y + grip_vert.h
	   		        if grip_vert.y > track_vert.h-grip_vert.h then
	   				    grip_vert.y = track_vert.h-grip_vert.h
	   		        end
                end
                
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


function editor_ui.tabBar(t)
    --default parameters
    local p = {
        font  = "FreeSans Medium 12px", 
        text_font = "FreeSans Medium 12px", 
    	text_color = {255,255,255,255}, 
    	text_focus_color = {255,255,255,255}, 
        
    	skin = "tabs", 
    	ui_width = 97,
    	ui_height = 21, 
        
    	focus_color = {255,255,255,255}, 
    	focus_fill_color = {27,145,27,255}, 
    	focus_text_color = {255,255,255,255}, 
    	border_width = 0,
    	border_corner_radius = 0,
        
        tab_labels = {
        },
        tabs = {},
        label_padding = 0,
        tab_position = "TOP",
        
        display_width  = 290, 
        display_height = 310,
        tab_spacing = -17, 
        border_color = {255,255,255,  0},
        fill_color   = {  0,  0,  0,  0},
        label_color  = {255,255,255,  255},
        unsel_color  = { 60, 60, 60,  0},
		---------------------------------

		buttons = {}, 
		current_tab = 1,
		current_tab_focus = nil, 
		--------------------------------
		arrow_size = 15,
		arrow_dist_to_frame = 2,
		arrow_image = "lib/assets/tab-arrow-left-off.png" --nil,

    }
   	local b_indent = "   " 
	local offset = {}
    --local buttons = {}
    
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
	local ap = nil 

    local create
    local current_index = 1
    local tab_bg = {}
    local tab_focus = {}
	
    local umbrella     = Group{
        name="TabContainer",
		reactive = true,  
        extra={
            type="TabBar",
            insert_tab = function(self,index)
                
                if index == nil then index = #p.tab_labels + 1 end
                
                table.insert(p.tab_labels,index,"TAB")
                
                table.insert(p.tabs,index,Group{})
                
                create()
                
            end,
            remove_tab = function(self,index)
                if index == nil then index = #p.tab_labels + 1 end
                
                table.remove(p.tab_labels,index,"TAB")
                
                table.remove(p.tabs,index,Group{})
                
                create()
            end,
            rename_tab = function(self,index,name)
                assert(index)
                p.tab_labels[index] = name
                
                create()
            end,
            
            move_tab_up = function(self,index)
                if index == 1 then return end
                local temp  = p.tab_labels[i-1]
                p.tab_labels[i-1] = p.tab_labels[i]
                p.tab_labels[i]   = temp
                
                temp      = p.tabs[i-1]
                p.tabs[i-1] = p.tabs[i]
                p.tabs[i]   = temp
                
                create()
            end,
            move_tab_down = function(self,index)
                if index == #p.tab_labels then return end
                local temp  = p.tab_labels[i+1]
                p.tab_labels[i+1] = p.tab_labels[i]
                p.tab_labels[i]   = temp
                
                temp      = p.tabs[i+1]
                p.tabs[i+1] = p.tabs[i]
                p.tabs[i]   = temp
                
                create()
            end,
            
            --switching 'visible tab' functions
            display_tab = function(self,index)
                if index < 1 or index > #p.tab_labels then return end
                p.tabs[current_index]:hide()
                p.buttons[current_index].clear_focus()
                current_index = index
                p.tabs[current_index]:show()
                p.buttons[current_index]:raise_to_top()
                p.buttons[current_index].set_focus()
            end,
            previous_tab = function(self)
                if current_index == 1 then return end
                
                self:display_tab(current_index-1)
            end,
            next_tab = function(self)
                if current_index == #p.tab_labels then return end
                
                self:display_tab(current_index+1)
            end,
			
			get_tab_group = function(self,index)
				return p.tabs[index]
			end,
			get_index = function(self)
				return current_index
			end,
			get_offset = function(self)
				return self.x+offset.x, self.y+offset.y
			end
        }

    }
    
    create = function()
        
        local labels, txt_h, txt_w 
        
		current_index = 1
		
        umbrella:clear()
        tab_bg = {}
        tab_focus = {}
        
        local bg = Rectangle{
            color        = p.fill_color,
            border_color = p.border_color,
            border_width = p.border_width,
            w = p.display_width,
            h = p.display_height,
        }
        
        umbrella:add(bg)
        for i = 1, #p.tab_labels do
			editor_use = true
            if p.tabs[i] == nil then
                p.tabs[i] = Group{}
            end

			p.buttons[i] = ui_element.button{ skin=p.skin, ui_width=p.ui_width, ui_height=p.ui_height, 
						 focus_border_color=p.focus_color, border_width=p.border_width, border_corner_radius=p.border_corner_radius,
						 label= b_indent..p.tab_labels[i], text_font=p.font, text_color=p.text_color, fill_color=p.unsel_color, 
						 focus_fill_color=p.fill_color, focus_text_color=p.focus_text_color, 
						 on_press=function() umbrella:display_tab(i) p.current_tab = i end, label_align = "left", tab_button=true} 

			p.tabs[i]:hide()
            p.buttons[i].position = {0,0}
            p.buttons[i].clear_focus()

            if p.tab_position == "TOP" then
                p.buttons[i].x = (p.tab_spacing+p.buttons[i].w)*(i-1)
                p.tabs[i].y  = p.buttons[i].h
            else
                p.tabs[i].x  = p.buttons[i].w
                p.buttons[i].y = (p.tab_spacing+p.buttons[i].h)*(i-1)
            end
            umbrella:add(p.tabs[i],p.buttons[i])
			offset.x = p.tabs[i].x
			offset.y = p.tabs[i].y
			editor_use = false

        end
---[[  ap 

		ap = nil
		
		if p.arrow_image then p.arrow_size = assets(p.arrow_image).w end
		
		if p.tab_position == "TOP" and
		(p.buttons[# p.buttons].w + p.buttons[# p.buttons].x) > (p.display_width - 2*(p.arrow_size+p.arrow_dist_to_frame)) then
			
			ap = ui_element.arrowPane{
				visible_width=p.display_width - (p.arrow_size+p.arrow_dist_to_frame),
				visible_height=p.buttons[# p.buttons].h,
				virtual_width=p.buttons[# p.buttons].w + p.buttons[# p.buttons].x,
				virtual_height=p.buttons[# p.buttons].h,
				arrow_color=p.label_color,
				scroll_distance=p.buttons[# p.buttons].w + 20, 
				arrow_size = p.arrow_size,
				arrow_dist_to_frame = p.arrow_dist_to_frame,
				arrow_src = p.arrow_image,
				tab = umbrella, -- p.current_tab, -- 1
				tab_buttons = p.buttons,
				box_border_width = 0,
				tab_arrow_left_on = "lib/assets/tab-arrow-left-off.png",  
				tab_arrow_right_on = "lib/assets/tab-arrow-left-off.png",  
				tab_arrow_left_off = "lib/assets/tab-arrow-left-off.png",  
				tab_arrow_right_off = "lib/assets/tab-arrow-left-off.png",  
			}
			
			ap.x = p.arrow_size+p.arrow_dist_to_frame
			ap.y = 0
			
			for _,b in ipairs(p.buttons) do
				
				b:unparent()
				ap.content:add(b)
				
			end
			
			umbrella:add(ap)
			
		elseif (p.buttons[# p.buttons].w + p.buttons[# p.buttons].x) <= (p.display_width - 2*(p.arrow_size+p.arrow_dist_to_frame)) then
			
			for _,b in ipairs(p.buttons) do
				b.x = b.x +8
			end

		end
		
--]]]
        if p.tab_position == "TOP" then
            bg.y = p.buttons[1].h-p.border_width
        else
            bg.x = p.buttons[1].w-p.border_width
        end
        
        for i = #p.tab_labels+1, #p.tabs do
            p.tabs[i]  = nil
            p.buttons[i] = nil
        end
		
		umbrella:display_tab(current_index)

		if p.buttons[4] then 
			p.buttons[4]:hide()
			p.buttons[4].reactive = false
			p.buttons[2]:raise(p.buttons[3])
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



function editor_ui.checkBoxGroup(t) 

 --default parameters
    local p = {
	skin = "custom", 
	ui_width = 600,
	ui_height = 200,
	items = {"item1", "item2", "item3"},
	text_font = "FreeSans Medium 30px", 
	text_color = {255,255,255,255}, 
	box_color = {255,255,255,255},
	fill_color = {255,255,255,0},
	focus_color = {0,255,0,255},
	focus_fill_color = {0,50,0,0},
	box_border_width = 2,
	box_size = {25,25},
	check_size = {25,25},
	line_space = 40,   
	b_pos = {0, 0},  
	item_pos = {50,-5},  
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

    local  cb_group = Group {
    	  name = "checkBoxGroup",  
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "CheckBoxGroup"}
    }

	function cb_group.extra.set_focus()
	  	current_focus = cb_group
        if (p.skin == "CarbonCandy") or p.skin == "custom" then 
	    	boxes:find_child("box"..1).opacity = 0 
	    	boxes:find_child("focus"..1).opacity = 255 
        end 
		boxes:find_child("box"..1):grab_key_focus() 
    end

    function cb_group.extra.clear_focus()
        if (p.skin == "CarbonCandy") or p.skin == "custom" then 
			for i=1, #boxes.children/2 do
	    		boxes:find_child("box"..i).opacity = 255 
	    		boxes:find_child("focus"..i).opacity = 0 
			end 
        end 
    end 

    function cb_group.extra.set_selection(items) 
	    p.selected_items = items
        if p.on_selection_change then
	       p.on_selection_change(p.selected_items)
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

    local function create_checkBox()
	 	items:clear() 
	 	checks:clear() 
	 	boxes:clear() 
	 	cb_group:clear()

	 	if(p.skin ~= "custom") then 
             p.box_image = skin_list[p.skin]["checkbox"]
             p.box_focus_image = skin_list[p.skin]["checkbox_focus"]
             p.check_image = skin_list[p.skin]["checkbox_sel"]
	 	else 
	     	 p.box_image = Image{}
			 p.box_focus_image = Image{}
             p.check_image = "lib/assets/checkmark.png"
	 	end
	
	 	boxes:set{name = "boxes", position = p.b_pos} 
	 	checks:set{name = "checks", position = p.b_pos} 
	 	items:set{name = "items", position = p.item_pos} 

        local pos = {0, 0}
        for i, j in pairs(p.items) do 
	      	local box, check, focus
	      	if(p.direction == "vertical") then --vertical 
                  pos= {0, i * p.line_space - p.line_space}
	      	end   			

	      	items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color = p.text_color, position = pos})     
	      	if p.skin == "custom" then 
		   		focus = Rectangle{name="focus"..tostring(i),  color= p.focus_fill_color, border_color= p.focus_color, border_width= p.box_border_width, 
				size = p.box_size, position = pos, reactive = true, opacity = 0}
		   		box = Rectangle{name="box"..tostring(i),  color= p.fill_color, border_color= p.box_color, border_width= p.box_border_width, 
				size = p.box_size, position = pos, reactive = true, opacity = 255}
    	        boxes:add(box, focus) 
	     	else
	           	focus = Image {name = "focus"..tostring(i), src=p.box_focus_image, position = pos, reactive = true, opacity = 0}
	           	box = Image {name = "box"..tostring(i), src=p.box_image, position = pos, reactive = true, opacity = 255}
		   		boxes:add(box, focus) 
	     	end 

	      	if p.skin == "custom" then 
	     		check = assets(p.check_image):set{name="check"..tostring(i), size = p.check_size, position = pos, reactive = true, opacity = 0}
			else 
	     		check = assets(p.check_image):set{name="check"..tostring(i), position = pos, reactive = true, opacity = 0}
			end
	     	checks:add(check) 

            if editor_lb == nil or editor_use then  

				function box:on_key_down(key)
					local box_num = tonumber(box.name:sub(4,-1))
					local next_num
					if key == keys.Up then 
						if box_num > 1 then 
							next_num = box_num - 1
				 			if (p.skin == "CarbonCandy") or (p.skin == "custom") then 
	    						boxes:find_child("box"..box_num).opacity = 255 
	    						boxes:find_child("focus"..box_num).opacity = 0 
	    						boxes:find_child("box"..next_num).opacity = 0 
	    						boxes:find_child("focus"..next_num).opacity = 255 
        					end 
	    					boxes:find_child("box"..next_num):grab_key_focus()
							return true 
						end
					elseif key == keys.Down then 
						if box_num < #boxes.children/2 then
							next_num = box_num + 1
				 			if (p.skin == "CarbonCandy") or (p.skin == "custom") then 
	    						boxes:find_child("box"..box_num).opacity = 255 
	    						boxes:find_child("focus"..box_num).opacity = 0 
	    						boxes:find_child("box"..next_num).opacity = 0 
	    						boxes:find_child("focus"..next_num).opacity = 255 
        					end 
							boxes:find_child("box"..next_num):grab_key_focus() 
							return true 
						end
					elseif key == keys.Return then 
						if cb_group:find_child("check"..tostring(box_num)).opacity == 255 then 
							p.selected_items = util.table_remove_val(p.selected_items, box_num)
							cb_group:find_child("check"..tostring(box_num)).opacity = 0 
							cb_group:find_child("check"..tostring(box_num)).reactive = true 
    						cb_group.extra.set_selection(p.selected_items) 
						else 
							table.insert(p.selected_items, box_num)
							cb_group:find_child("check"..tostring(box_num)).opacity = 255 
    						cb_group.extra.set_selection(p.selected_items) 
						end 
						return true 
					end 
				end 

	     		function box:on_button_down (x,y,b,n)
					local box_num = tonumber(box.name:sub(4,-1))
					table.insert(p.selected_items, box_num)
					cb_group:find_child("check"..tostring(box_num)).opacity = 255
					cb_group:find_child("check"..tostring(box_num)).reactive = true
    				cb_group.extra.set_selection(p.selected_items) 
					return true
	     		end 

	     		function check:on_button_down(x,y,b,n)
					local check_num = tonumber(check.name:sub(6,-1))
					if cb_group:find_child("check"..tostring(check_num)).opacity == 255 then 
						p.selected_items = util.table_remove_val(p.selected_items, check_num)
						cb_group:find_child("check"..tostring(check_num)).opacity = 0 
						cb_group:find_child("check"..tostring(check_num)).reactive = true 
    					cb_group.extra.set_selection(p.selected_items) 
					else 
						table.insert(p.selected_items, check_num)
						cb_group:find_child("check"..tostring(check_num)).opacity = 255 
    					cb_group.extra.set_selection(p.selected_items) 
					end 
    				cb_group.extra.set_selection(p.selected_items) 
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

