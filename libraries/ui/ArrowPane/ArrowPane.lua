function ui_element.arrowPane(t)

    --default parameters
    local p = {
        
		visible_width =     600,
        visible_height =     600,
        content   = 	Group{},
        virtual_height =    1000,
		virtual_width =    1000,
        arrow_size  =      15,
		
		scroll_distance     = 10,
        arrow_dist_to_frame = 5,
        arrows_visible 		= true,
        arrow_color       	= {160,160,160,255},
        focus_arrow_color 	= {160,255,160,255},
        box_color         	= {160,160,160,255},
        focus_box_color   	= {160,255,160,255},
        box_border_width 	= 2,
        skin 				= "Custom",
		ui_position 		= {200,100},
		--------------------------
		tab = nil, 
		tab_buttons = nil 
    }
	
		
	local make_arrow = function(sz,color)
		
		local c = Canvas{size={sz,sz}}
		
		c:move_to(    0,c.h)
		c:line_to(c.w/2,  0)
		c:line_to(  c.w,c.h)
		c:line_to(    0,c.h)
		
		c:set_source_color( color )
		c:fill(true)
		
		if c.Image then
			c= c:Image()
		end
		
		c.anchor_point={c.w/2,c.h}
		
		return c
		
	end

--[[
	local make_arrow = function(sz,color)
		
		local c = Canvas{size={sz,sz}}
		
		c:move_to(    0,c.h)
		c:line_to(c.w/2,  0)
		c:line_to(  c.w,c.h)
		c:line_to(    0,c.h)
		
		c:set_source_color( color )
		c:fill(true)
		
		if c.Image then
			c= c:Image()
		end
		
		c.anchor_point={c.w/2,c.h}
		
		return c
		
	end
	]]
    local function my_make_arrow( _ , ...) 
		make_arrow(...)
	end 
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

	local border = Rectangle{ color = "00000000" }
		
	local arrow, f_arrow
	
	local track_h, track_w, grip_hor, grip_vert, track_hor, track_vert
	
    --the umbrella Group, containing the full slate of cells
    local umbrella = Group{ 
        name     = "arrowPane",
        position = p.ui_position, 
        reactive = true,
        extra    = {
			type = "ArrowPane",
			--tries to place virtual coordinates 'x' and 'y' in the middle of the window
			pan_to = function(self,x,y,top_left,f_arrow)
				
				if animating then return end
				if top_left == true then
					x = x + p.visible_width/2
					y = y + p.visible_height/2
				end
				
				local new_x, new_y
                
				if x > p.virtual_width - p.visible_width/2 then
                    new_x = -p.virtual_width + p.visible_width - 11
                elseif x < p.visible_width/2 then
                    new_x = 0
                else
                    new_x = -x + p.visible_width/2
                end
				
                
                if y > p.virtual_height - p.visible_height/2 then
                    new_y = -p.virtual_height + p.visible_height
                elseif y < p.visible_height/2 then
                    new_y = 0
                else
                    new_y = -y + p.visible_height/2
                end
				if new_x ~= p.content.x or new_y ~= p.content.y then
					if p.tab_buttons == nil then 
                   		if f_arrow.is_visible then
							f_arrow:hide()
						else
							f_arrow:show()
						end
					end 
					animating = true
					p.content:animate{
                        duration = 200,
                        x = new_x,
                        y = new_y,
                        on_completed = function()
                            animating = false
							if p.tab_buttons == nil then 
								if f_arrow.is_visible then
									f_arrow:hide()
								else
									f_arrow:show()
								end
							end 
                        end
                    }
                    
                end
			end,
			seek_to_middle = function(x,y)
				local new_x, new_y
                if p.virtual_width > p.visible_width then
                    if x > p.virtual_width - p.visible_width/2 then
                        new_x = -p.virtual_width + p.visible_width
                    elseif x < p.visible_width/2 then
                        new_x = 0
                    else
                        new_x = -x + p.visible_width/2
                    end
                else
                    new_x =0
                end
                if p.virtual_height > p.visible_height then
                    if y > p.virtual_height - p.visible_height/2 then
                        new_y = -p.virtual_height + p.visible_height
                    elseif y < p.visible_height/2 then
                        new_y = 0
                    else
                        new_y = -y + p.visible_height/2
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
                    if new_y < -(p.virtual_height - p.visible_height) then
                        grip_vert.y = track_h-grip_vert.h
                    elseif new_y > 0 then
                        grip_vert.y = 0
                    elseif new_y ~= p.content.y then
                        grip_vert:complete_animation()
                        grip_vert:animate{
                            duration= 200,
                            y = 0-(track_h-grip_vert.h)*new_y/(p.virtual_height - p.visible_height)
                        }
                    end
                    end
                    if grip_hor ~= nil then
                    if new_x < -(p.virtual_width - p.visible_width) then
                        grip_hor.x = track_w-grip_hor.w
                    elseif new_x > 0 then
                        grip_hor.x = 0
                    elseif new_x ~= p.content.x then
                        grip_hor:complete_animation()
                        grip_hor:animate{
                            duration= 200,
                            x = 0-(track_w-grip_hor.w)*new_x/(p.virtual_width - p.visible_width)
                        }
                    end
                    end
                end
            end,
			screen_pos_of_child = function(self,child)
                return  child.x + child.parent.x + self.x + p.box_border_width,
                        child.y + child.parent.y + self.y + p.box_border_width
           end,

        }
    }


	umbrella.pan_by = function(self,dx,dy,f_arrow)		
		self:pan_to(
			-p.content.x + dx,
			-p.content.y + dy,
			true,
			f_arrow
		)
		
	end
	
	
		
	function umbrella.extra.set_focus() 
		umbrella:grab_key_focus()
    end

	function umbrella.extra.clear_focus() 
		screen:grab_key_focus()
    end


	--this function creates the whole scroll bar box
    local hold = false
	
	local arrow_pane_keys = {}
	
	local function create()
		
		local key 

		umbrella:clear()
		arrow_pane_keys = {}

		if arrow_src ~= nil and
			arrow_src.parent == umbrella then
			arrow_src:unparent()
		end
		
		if focus_arrow_src ~= nil and
			focus_arrow_src.parent == umbrella then
			focus_arrow_src:unparent()
		end
		
		if type(p.arrow_src) == "string" then
			
			arrow_src = assets(p.arrow_src)
			
		elseif type(p.arrow_src) == "userdata" then
			
			arrow_src = p.arrow_src
			
			if arrow_src.parent then
				umbrella:add(arrow_src)
				arrow_src:hide()
			end
			
		else
			--key = string.format ("arrow:%d:%s",  p.arrow_size, color_to_string(p.arrow_color))
			--arrow_src = assets(key, my_make_arrow,  p.arrow_size, p.arrow_color )
			arrow_src   = make_arrow( p.arrow_size, p.arrow_color )
			umbrella:add(arrow_src)
			arrow_src:hide()
		end
		
		if type(p.focus_arrow_src) == "string" then
			
			focus_arrow_src = assets(p.focus_arrow_src)
			
		elseif type(p.focus_arrow_src) == "userdata" then
			
			focus_arrow_src = p.focus_arrow_src
			
			if focus_arrow_src.parent then
				umbrella:add(focus_arrow_src)
				focus_arrow_src:hide()
			end
			
		else
			focus_arrow_src   = make_arrow( p.arrow_size, p.focus_arrow_color )
			umbrella:add(focus_arrow_src)
			focus_arrow_src:hide()
		end

        window.position={ p.box_border_width, p.box_border_width }
		window.clip = { 0,0, p.visible_width, p.visible_height }
        border:set {
            w = p.visible_width+2*p.box_border_width,
            h = p.visible_height+2*p.box_border_width,
            border_width =    p.box_border_width,
            border_color =    p.box_color,
        }
        
        if p.arrows_visible then
			if p.visible_height < p.virtual_height then
				do
				f_arrow = Clone{
					source       =  focus_arrow_src,
					x            =  border.w/2,
					y            = -p.arrow_dist_to_frame,
					anchor_point = {
						focus_arrow_src.w/2,
						focus_arrow_src.h
					},
				}
				f_arrow:hide()
				
				local arrow = Clone{
					source       =  arrow_src,
					x            =  border.w/2,
					y            = -p.arrow_dist_to_frame,
					anchor_point = {
						arrow_src.w/2,
						arrow_src.h
					},
					reactive       = true,
					on_button_down = function(self)
						--self.focus:show()
					end,
					on_button_up = function(self)
						umbrella:pan_by(0,-p.scroll_distance,self.focus)
						--self.focus:hide()
					end,
					extra = {
						focus = f_arrow
					}
				}
				arrow_pane_keys[keys.Up] = function() arrow:on_button_up() end
				
				--arrow.reactive=true
				umbrella:add(arrow,f_arrow)
				end
				do
				f_arrow = Clone{
					source       =  focus_arrow_src,
					x            =  border.w/2,
					y            =  p.arrow_dist_to_frame+border.h,
					z_rotation   = {180,0,0},
					anchor_point = {
						focus_arrow_src.w/2,
						focus_arrow_src.h
					},
				}
				f_arrow:hide()
				
				local arrow = Clone{
					source       =  arrow_src,
					x            =  border.w/2,
					y            =  p.arrow_dist_to_frame+border.h,
					z_rotation   = {180,0,0},
					anchor_point = {
						arrow_src.w/2,
						arrow_src.h
					},
					reactive       = true,
					on_button_down = function(self)
						--self.focus:show()
					end,
					on_button_up = function(self)
						umbrella:pan_by(0,p.scroll_distance,self.focus)
						--self.focus:hide()
					end,
					extra = {
						focus = f_arrow
					},
				}
				
				arrow_pane_keys[keys.Down] = function() arrow:on_button_up() end
				
				umbrella:add(arrow,f_arrow)
				end
			end

			if p.visible_width < p.virtual_width then
				-- [[ Right Arrow ]]-- 
				if p.tab_buttons then 
					f_arrow = Clone{
						source       = p.focus_arrow_src,
						x            = border.w+p.arrow_dist_to_frame,
						y            = border.h/2,
						z_rotation   = {90,0,0},
						anchor_point = {
							focus_arrow_src.w/2,
							focus_arrow_src.h
						},
					}
					f_arrow:hide()

--[[
					local arrow = Image {
						name = "right",
						src ="/lib/assets/tab-arrow-right-on.png",
						x = border.w+p.arrow_dist_to_frame  - 15,
						y = border.h/2 - 10,
						reactive=true,
						on_button_down = function()
							umbrella:pan_by(p.scroll_distance,0)
							if p.tab then 
								local current_tab = p.tab.current_tab
								if umbrella:find_child("right").src == "/lib/assets/tab-arrow-right-on.png" then
									if current_tab == 1 then 
										p.tab_buttons[2].on_button_down()
									end 
									umbrella:find_child("right").src = "/lib/assets/tab-arrow-right-off.png"
									umbrella:find_child("left").src = "/lib/assets/tab-arrow-left-on.png"
								end 
								if p.tab_buttons[4].reactive == false then 
									p.tab_buttons[4]:show()
									p.tab_buttons[4].reactive = true 
								end 
								return true
							end 
						end,
						extra = {
							focus = f_arrow
						}
					}
	]]

					local arrow = Image{src = "/lib/assets/tab-arrow-right-on.png"}
					arrow:set{
						name = "right",
						x = border.w+p.arrow_dist_to_frame  - 15,
						y = border.h/2 - 10,
						reactive=true,
						on_button_down = function()
							umbrella:pan_by(p.scroll_distance,0)
							if p.tab then 
								local current_tab = p.tab.current_tab
								if umbrella:find_child("right").src == "/lib/assets/tab-arrow-right-on.png" then
									if current_tab == 1 then 
										p.tab_buttons[2].on_button_down()
									end 
									umbrella:find_child("right").src = "/lib/assets/tab-arrow-right-off.png"
									umbrella:find_child("left").src = "/lib/assets/tab-arrow-left-on.png"
								end 
								if p.tab_buttons[4].reactive == false then 
									p.tab_buttons[4]:show()
									p.tab_buttons[4].reactive = true 
								end 
								return true
							end 
						end,
						extra = {
							focus = f_arrow
						}
					}
					
					umbrella:add(arrow,f_arrow)
				else 
					
					f_arrow = Clone{
						source       = focus_arrow_src,
						x            = border.w+p.arrow_dist_to_frame,
						y            = border.h/2,
						z_rotation   = {90,0,0},
						anchor_point = {
							focus_arrow_src.w/2,
							focus_arrow_src.h
						},
					}
					f_arrow:hide()
					local arrow = Clone{
						source       = arrow_src,
						x            = border.w+p.arrow_dist_to_frame,
						y            = border.h/2,
						z_rotation   = {90,0,0},
						--extra        = { focus = f_arrow },
						anchor_point = {
							arrow_src.w/2,
							arrow_src.h
						},
						reactive = true,
						on_button_down = function(self)
							--self.focus:show()
						end,
						on_button_up = function(self)
							umbrella:pan_by(p.scroll_distance,0,self.focus)
							--self.focus:hide()
						end,
						extra = {
							focus = f_arrow
						},
					}
					
					
					arrow_pane_keys[keys.Right] = function()  arrow:on_button_up() end
					
					umbrella:add(arrow,f_arrow)
				end 
				
				if p.tab_buttons then 
--[[

					arrow = Image {
						name = "left",
						src ="/lib/assets/tab-arrow-left-off.png",
						x = - 20,
						reactive = true,
						on_button_down = function()
							umbrella:pan_by(-p.scroll_distance,0)
							if p.tab then 
								local current_tab = p.tab.current_tab
								if umbrella:find_child("left").src == "/lib/assets/tab-arrow-left-on.png" then 
									if current_tab == 4 then 
										p.tab_buttons[1].on_button_down()
									end 
									umbrella:find_child("right").src = "/lib/assets/tab-arrow-right-on.png"
									umbrella:find_child("left").src = "/lib/assets/tab-arrow-left-off.png"
								end 
								if  p.tab_buttons[4].reactive == true then 
									p.tab_buttons[4]:hide()
									p.tab_buttons[4].reactive = false 
								end 
								return true
							end 
						end
					}

]]

					arrow = Image{ src = "/lib/assets/tab-arrow-left-off.png"}
					arrow:set{
						name = "left",
						x = - 20,
						reactive = true,
						on_button_down = function()
							umbrella:pan_by(-p.scroll_distance,0)
							if p.tab then 
								local current_tab = p.tab.current_tab
								if umbrella:find_child("left").src == "/lib/assets/tab-arrow-left-on.png" then 
									if current_tab == 4 then 
										p.tab_buttons[1].on_button_down()
									end 
									umbrella:find_child("right").src = "/lib/assets/tab-arrow-right-on.png"
									umbrella:find_child("left").src = "/lib/assets/tab-arrow-left-off.png"
								end 
								if  p.tab_buttons[4].reactive == true then 
									p.tab_buttons[4]:hide()
									p.tab_buttons[4].reactive = false 
								end 
								return true
							end 
						end
					}

					umbrella:add(arrow)
				else
					
					f_arrow = Clone{
						source       = focus_arrow_src,
						x            = -p.arrow_dist_to_frame,
						y            = border.h/2,
						z_rotation   = {270,0,0},
						anchor_point = {
							focus_arrow_src.w/2,
							focus_arrow_src.h
						},
					}
					f_arrow:hide()
					arrow = Clone{
						source       = arrow_src,
						x            = -p.arrow_dist_to_frame,
						y            = border.h/2,
						z_rotation   = {270,0,0},
						extra        = { focus = f_arrow },
						anchor_point = {
							arrow_src.w/2,
							arrow_src.h
						},
						reactive = true,
						on_button_down = function(self)
							--self.focus:show()
						end,
						on_button_up = function(self)
							umbrella:pan_by(-p.scroll_distance,0,self.focus)
							--self.focus:hide()
						end,
						extra = {
							focus = f_arrow
						},
					}
					
					arrow_pane_keys[keys.Left] = function() arrow:on_button_up() end
					
					umbrella:add(arrow,f_arrow)
				end 
			end
		end
		
		
		function umbrella:on_key_focus_in()
			
			border.border_color = p.focus_box_color
			
		end
		function umbrella:on_key_focus_out()
			
			border.border_color = p.box_color
			
		end
        
		umbrella.size = {p.visible_width + 2*p.box_border_width, p.visible_height + 2*p.box_border_width}
		umbrella:add(border,window)
	end
	
    create()
	window:add(p.content)
	
	function umbrella:on_key_down(key)
		if arrow_pane_keys[key] then arrow_pane_keys[key]() end
	end
	
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
        	p[k] = v
		elseif k == "selected" then 
        	p[k] = v
		else
        	p[k] = v
        	create()
        end
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end