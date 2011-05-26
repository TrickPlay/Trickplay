
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

		focussed=nil, 
		pressed = nil, 
		released = nil, 

		button_image = nil,
		focus_image  = nil,
		active_button = false,
		focus_object = nil,
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
    
    function b_group.extra.on_focus_in(key) 

		--print("b_group focus in", key)

		if current_focus ~= nil then 
			--print(current_focus.name)
			if current_focus.on_focus_out then 
				current_focus.on_focus_out()
			end 
		end 

		current_focus = b_group

		if key == "focus" then 
        	focus.opacity = 255
        	active.opacity = 0
		else 
        	active.opacity = 255
        	focus.opacity = 0
		end 
        button.opacity = 0
        b_group:find_child("text").color = p.focus_text_color
	
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
		--print("b_group focus out")
		if key == "active" then 
        	active.opacity = 255
	    	button.opacity = 0
		else 
	    	button.opacity = 255
        	active.opacity = 0
		end
        focus.opacity = 0
        b_group:find_child("text").color = p.text_color
		if p.released then 
			p.released()
		end 
		current_focus = nil 
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
	     function b_group:on_enter()
		 		if current_focus ~= b_group then 
					if current_focus then 
		     			current_focus.on_focus_out()
					end
				end 
	
				b_group.extra.on_focus_in("focus")
		 end 

	     function b_group:on_leave()
			if b_group.active_button == true then 
				b_group.on_focus_out("active")
			else 
				b_group.on_focus_out()
			end 

			if p.focus_object ~= nil then 
				p.focus_object.on_focus_in()
			end 
		 end 
		
		 function b_group:on_key_down(key)
				if b_group.focus[key] then
					if type(b_group.focus[key]) == "function" then
							b_group.focus[key]()
					elseif screen:find_child(b_group.focus[key]) then
						if b_group.on_focus_out then
							b_group.on_focus_out()
						end
						screen:find_child(b_group.focus[key]):grab_key_focus()
						if screen:find_child(b_group.focus[key]).on_focus_in then
							screen:find_child(b_group.focus[key]).on_focus_in(key)
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
		--print(k,v)
		--print("create_button()called")
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
        virtual_h 	 = 242,--1000,
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
        box_width = 0,
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

	local border = Rectangle{ color = "00000000", } --opacity = 0}
	
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


	 function scroll_group.extra.on_focus_in(key) 

		--print("scroll_group focus in", key)

--[[
		if current_focus ~= nil then 
			print(current_focus.name)
			if current_focus.on_focus_out then 
				current_focus.on_focus_out()
			end 
		end 
]]
		current_focus = scroll_group
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
    
    function scroll_group.extra.on_focus_out(key) 
		--print("scroll_group focus out")
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
	--[[
		if animating then return end
		--if keys[key] then
			--keys[key]()
		if scroll_group.focus[key] then
			print("YUGI 1")
			if type(scroll_group.focus[key]) == "function" then
				scroll_group.focus[key]()
			elseif screen:find_child(scroll_group.focus[key]) then
				if scroll_group.on_focus_out then
					scroll_group.on_focus_out()
				end
				screen:find_child(scroll_group.focus[key]):grab_key_focus()
				if screen:find_child(scroll_group.focus[key]).on_focus_in then
					screen:find_child(scroll_group.focus[key]).on_focus_in(key)
				end
			end
		else
			print("YUGI 2")
			dumptable(scroll_group.extra.focus)
		end
		]]
		scroll_group.extra.on_focus_in()

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
		--[[
		if dir == "up" then 
			arrow = Image{src="lib/assets/scrollbar-btn-up.png"}
		else 
			arrow = Image{src="lib/assets/scrollbar-btn-up-12.png"}
		end 
		]]
		arrow = Image{src="lib/assets/scrollbar-btn-up.png"}
		arrow.anchor_point={arrow.w/2,arrow.h}
		return arrow
		
	end
    local function make_hor_bar(w,h,ratio)
    end
    local function make_vert_bar(w,h,ratio)
		--print(w,h)
		local bar = Group()
        local fill = Group{name="grip",reactive = true, }
        local shell = Group{name="track",reactive = true, }

		local top= Image{src="lib/assets/scrollbar-grip-top.png", position = {0,0}}
		local bottom= Image{src="lib/assets/scrollbar-grip-bottom.png"}
		local handle= Image{src="lib/assets/scrollbar-grip-handle.png"}
		local t_1px = Image{src="lib/assets/scrollbar-grip-repeat1px.png", position = {0,top.h}, tile = {false, true}, height = (h*ratio-(top.h+bottom.h+handle.h))/2}
		local b_1px = Image{src="lib/assets/scrollbar-grip-repeat1px.png", position = {0,top.h+t_1px.h+handle.h}, tile = {false, true}, height = (h*ratio-(top.h+bottom.h+handle.h))/2}

		bottom.position={0,top.h+t_1px.h+handle.h+b_1px.h}
		handle.position={0,top.h + t_1px.h}
		fill.anchor_point = {t_1px.w/2,0}

		local shell_top= Image{src="lib/assets/scrollbar-track-top.png", position = {0,0}}
		local shell_bottom= Image{src="lib/assets/scrollbar-track-bottom.png"}
		local shell_handle= Image{src="lib/assets/scrollbar-track-handle.png"}
		local shell_t_1px = Image{src="lib/assets/scrollbar-track-repeat1px.png", position = {0,shell_top.h}, tile = {false, true}, height = (h-(shell_top.h+shell_bottom.h+shell_handle.h))/2}
		local shell_b_1px = Image{src="lib/assets/scrollbar-track-repeat1px.png", position = {0,shell_top.h+shell_t_1px.h+shell_handle.h}, tile = {false, true}, height = (h-(shell_top.h+shell_bottom.h+shell_handle.h))/2}

		shell_bottom.position={0,shell_top.h+shell_t_1px.h+shell_handle.h+shell_b_1px.h}
		shell_handle.position={0,shell_top.h + shell_t_1px.h}

		fill:add(top,handle,t_1px,handle,b_1px,bottom) 
		shell:add(shell_top,shell_handle,shell_t_1px,shell_handle,shell_b_1px,shell_bottom) 

		bar:add(shell,fill)
		fill.x = shell_t_1px.w/2
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
                l.x = p.box_width+p.bar_thickness
                l.y = p.box_width*2+p.visible_h+p.bar_offset+p.bar_thickness/2
                scroll_group:add(l)
                l.reactive=true
                function l:on_button_down()
                    scroll_x(1)
                end
                hor_s_bar.position={
                    p.box_width+p.bar_thickness,
                    p.box_width*2+p.visible_h+p.bar_offset
                }
                local r = make_arrow()
                r.name="R"
                r.x = p.box_width+p.bar_thickness+hor_s_bar.w
                r.y = p.box_width*2+p.visible_h+p.bar_offset+p.bar_thickness/2
                scroll_group:add(r)
                r.reactive=true
            else
                hor_s_bar.position={
                    p.box_width,
                    p.box_width*2+p.visible_h+p.bar_offset
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
            if p.arrows_visible then
                local up = make_arrow("up")
                up.name="UP"
                up.x = p.box_width*2+p.visible_w+p.bar_offset+p.bar_thickness/2
                up.y = p.box_width+p.bar_thickness
                scroll_group:add(up)
                up.reactive=true
                function up:on_button_down()
                    scroll_y(1)
                end
                vert_s_bar.position={
                    p.box_width*2+p.visible_w+p.bar_offset,
                    p.box_width+p.bar_thickness
                }
                local dn = make_arrow("down")
                dn.name="DN"
                dn.x = p.box_width*2+p.visible_w+p.bar_offset+p.bar_thickness/2
                dn.y = p.box_width+p.bar_thickness+vert_s_bar.h
                dn.z_rotation = {180,0,0}
                scroll_group:add(dn)
                dn.reactive=true
                function dn:on_button_down()
                    scroll_y(-1)
                end
            else
                vert_s_bar.position={
                    p.box_width*2+p.visible_w+p.bar_offset,
                    p.box_width
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

--[[
	if scroll.virtual_h <= scroll.visible_h then
            scroll_group:find_child("vert_s_bar")
            scroll_group:find_child("dn")
	end 
]]


    return scroll_group
end


