SCROLLPANE = true

local create_arrow = function(old_function,self,state)
	
	local c = Canvas(self.w,self.h)
	
    c:move_to(0,   c.h/2)
    c:line_to(c.w,     0)
    c:line_to(c.w,   c.h)
    c:line_to(0,   c.h/2)
    
	c:set_source_color( self.style.fill_colors[state] )     c:fill(true)
	
	return c:Image()
	
end

local default_parameters = {pane_w = 450, pane_h = 600,virtual_w=1000,virtual_h=1000, slider_thickness = 30}

ScrollPane = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ScrollPane",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The ScrollPane Object inherits from Widget
	
    local pane = ClippingRegion()
    
    local horizontal = Slider()
    local vertical   = Slider{direction="vertical"}
	local instance = LayoutManager{
        number_of_rows = 2,
        number_of_cols = 2,
        cells = {
            { pane,       vertical },
            { horizontal, Widget_Clone()  },
        },
    }
    ----------------------------------------------------------------------------
    
	instance:subscribe_to( "enabled",
		function()
            horizontal.enabled = instance.enabled
            vertical.enabled   = instance.enabled
        end
	)
	override_property(instance,"virtual_x",
		function(oldf) return   pane.virtual_x     end,
		function(oldf,self,v)   pane.virtual_x = v end
    )
	override_property(instance,"virtual_y",
		function(oldf) return   pane.virtual_y     end,
		function(oldf,self,v)   pane.virtual_y = v end
    )
	override_property(instance,"virtual_w",
		function(oldf) return   pane.virtual_w     end,
		function(oldf,self,v)   pane.virtual_w = v end
    )
	override_property(instance,"virtual_h",
		function(oldf) return   pane.virtual_h     end,
		function(oldf,self,v)   pane.virtual_h = v end
    )
	override_property(instance,"pane_w",
		function(oldf) return   pane.w     end,
		function(oldf,self,v)   
            horizontal.track.w = v
            horizontal.grip.w  = v/10
            pane.w       = v 
        end
    )
	override_property(instance,"pane_h",
		function(oldf) return   pane.h     end,
		function(oldf,self,v)   
            vertical.track.h   = v
            vertical.grip.h    = v/10
            pane.h     = v 
        end
    )
    local slider_thickness = 30
	override_property(instance,"slider_thickness",
		function(oldf) return   slider_thickness     end,
		function(oldf,self,v)   
            
            horizontal.track.h = v
            horizontal.grip.h  = v
            vertical.track.w   = v
            vertical.grip.w    = v
            slider_thickness   = v
        end
    )
    
    vertical:subscribe_to("progress",function()
        pane.virtual_y = vertical.progress * pane.virtual_h
    end)
    horizontal:subscribe_to("progress",function()
        pane.virtual_x = horizontal.progress * pane.virtual_w
    end)
    
	instance:subscribe_to(
		{"virtual_w","pane_w"},
		function()
            
            if instance.virtual_w <= instance.pane_w then
                horizontal:hide()
            else
                horizontal:show()
            end
        end
    )
	instance:subscribe_to(
		{"virtual_h","pane_h"},
		function()
            
            if instance.virtual_h <= instance.pane_h then
                vertical:hide()
            else
                vertical:show()
            end
        end
    )
	override_property(instance,"contents",
		function(oldf) 
            return pane.contents    
        end,
		function(oldf,self,v) 
            pane.contents = v
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
            
            t.contents = self.contents
            
            t.pane_w = instance.pane_w
            t.pane_h = instance.pane_h
            t.virtual_x = instance.virtual_x
            t.virtual_y = instance.virtual_y
            t.virtual_w = instance.virtual_w
            t.virtual_h = instance.virtual_h
            
            t.slider_thickness = instance.slider_thickness
            
            t.type = "ScrollPane"
            
            return t
        end
    )
    ----------------------------------------------------------------------------
    
	override_function(instance,"add",
		function(oldf,self,...) pane:add(...) end
	)
    
    ----------------------------------------------------------------------------
    
    instance:set(parameters)
    
    
    pane.vertical_spacing = 2
    return instance
end



--[=[
--[[
Function: Scroll Pane

Creates a clipped window that can be scrolled

Arguments:
    clip_w    - width of the clip
    clip_h    - height of the clip
    color     - color of the frame and scrolling items
    border_w  - width of the border
    content_h - height of the group that holds the content being scrolled
    content_w - width of the group that holds the content being scrolled
    arrow_clone_source - a Trickplay object that is to be cloned to replace the scroll arrows
    arrow_size  - size of the scroll arrows
    arrows_in_box - a flag, setting to true positions the arrows inside the border
    arrows_centered - a flag, setting to true positions the arrows along the center axises
    grip_is_visible - a flag that either makes the grips of the scroll bars visible or invisible
    border_is_visible - a flag that either makes the border visible or invisible
Return:

		Group - Group containing the grid
        
Extra Function:
	on_key_down(key) - contains the scrolling functions for pressing left, right, up, down
    get_content_group() - returns the content group, so that things can be added
]]
function ui_element.scrollPane(t)

	-- reference: http://www.csdgn.org/db/179

    --default parameters
    local p = {
        visible_width    =  600,
        visible_height    =  600,
        content   = Group{},
        virtual_height = 1000,
        virtual_width = 1000,
        bar_color_inner       = {180,180,180,255},
        bar_color_outer       = { 30, 30, 30,255},
        focus_bar_color_inner = {180,255,180,255},
        focus_bar_color_outer = { 30, 30, 30,255},
        empty_color_inner     = {120,120,120,255},
        empty_color_outer     = {255,255,255,255},
        frame_thickness       = 2,
        frame_color           = { 60, 60, 60,255},
        bar_thickness         = 15,
        bar_offset            = 5,
        vert_bar_visible      = true,
        horz_bar_visible      = true,
        box_color             = {160,160,160,255},
        focus_box_color       = {160,255,160,255},
        box_border_width             = 2,
        skin                  = "Custom",
		ui_position           = {200,100},    
		}

    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	--Group that Clips the content
	local window  = Group{name="window"}
	--declarations for dependencies from scroll_group
	local scroll, scroll_x, scroll_y
	--flag to hold back key presses while animating content group
	local animating = false

	local border = Rectangle{ color = "00000000" }
	
	local track_w, grip_hor,  track_hor,  unfocus_grip_hor, focus_grip_hor
	local track_h, grip_vert, track_vert, unfocus_grip_vert,focus_grip_vert
	

    --the umbrella Group, containing the full slate of cells
    local scroll_group = Group { 
        name     = "scrollPane",
        position = p.ui_position, 
        reactive = true,
        extra    = {
			type = "ScrollPane",
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

    scroll_group.extra.seek_to = function(x,y)
        scroll_group.extra.seek_to_middle(x+p.visible_width/2,y+p.visible_height/2)
    end
	
	--Key Handler
	local keys={
		[keys.Left] = function()
			if p.visible_width < p.virtual_width then
				scroll_x(1)
			end
		end,
		[keys.Right] = function()
			if p.visible_width < p.virtual_width then
				scroll_x(-1)
			end
		end,
		[keys.Up] = function()
			if p.visible_height < p.virtual_height then
				scroll_y(1)
			end
		end,
		[keys.Down] = function()
			if p.visible_height < p.virtual_height then
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
	
	function scroll_group.extra.set_focus() 
		scroll_group:grab_key_focus()
    end

	function scroll_group.extra.clear_focus() 
		screen:grab_key_focus()
    end

	scroll_y = function(dir)
		local new_y = p.content.y+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			y = new_y,
			on_completed = function()
				if p.content.y < -(p.virtual_height - p.visible_height) then
					p.content:animate{
						duration = 200,
						y = -(p.virtual_height - p.visible_height),
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
		
		if new_y < -(p.virtual_height - p.visible_height) then
			grip_vert.y = track_h-grip_vert.h
		elseif new_y > 0 then
			grip_vert.y = 0
		else
			grip_vert:complete_animation()
			grip_vert:animate{
				duration= 200,
				y = 0-(track_h-grip_vert.h)*new_y/(p.virtual_height - p.visible_height)
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
				if p.content.x < -(p.virtual_width - p.visible_width) then
					p.content:animate{
						duration = 200,
						y = -(p.virtual_width - p.visible_width),
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
		
		if new_x < -(p.virtual_width - p.visible_height) then
			grip_hor.x = track_w-grip_hor.w
		elseif new_x > 0 then
			grip_hor.x = 0
		else
			grip_hor:complete_animation()
			grip_hor:animate{
				duration= 200,
				x = 0-(track_w-grip_hor.w)*new_x/(p.virtual_width - p.visible_width)
			}
		end
	end

	local function make_hor_bar(w,h,ratio)
        local bar = Group{}
        
		local RAD = 6
        
		local top    = math.ceil(p.frame_thickness/2)
		local bottom = h - math.ceil(p.frame_thickness/2)
		local left   = math.ceil(p.frame_thickness/2)
		local right  = w - math.ceil(p.frame_thickness/2)
       	local shell, fill, focus, key 

		local function make_hor_shell ()
			shell = Canvas{
				size = {w,h},
			}
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

			if shell.Image then shell = shell:Image() end

			return shell
		end 

		local function my_make_hor_shell( _ , ...)
			return  make_hor_shell( ... )
		end 

		key = string.format ("h_shell:%d:%d:%f:%s:%s:%d:%s",w,h,ratio,color_to_string(p.empty_color_inner),color_to_string(p.empty_color_outer), 
							p.frame_thickness, color_to_string(p.frame_color))
		shell = assets(key, my_make_hor_shell) 
		
		local function make_hor_fill()

			fill = Canvas{
				size = {w*ratio,h-p.frame_thickness},
			}
				
			top    =          math.ceil(p.frame_thickness/2)
			bottom = h-p.frame_thickness - math.ceil(p.frame_thickness/2)
			left   =          math.ceil(p.frame_thickness/2)
			right  = w*ratio - math.ceil(p.frame_thickness/2)
        
			fill:begin_painting() -- shell -> fill

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
        	
			if  fill.Image then  fill =  fill:Image() end

			return fill
		end 

		local function my_make_hor_fill( _ , ...)
     		return make_hor_fill( ... )
		end 

		key = string.format ("h_fill:%d:%d:%f:%s:%s:%d:%s", w,h,ratio,color_to_string(p.bar_color_inner),color_to_string(p.bar_color_outer), 
							p.frame_thickness, color_to_string(p.frame_color))
		fill = assets(key, my_make_hor_fill) 

		local function make_hor_focus()
			focus = Canvas{
				size = {w*ratio,h-p.frame_thickness},
			}  
        	    
			top    =           math.ceil(p.frame_thickness/2)
			bottom = h-p.frame_thickness - math.ceil(p.frame_thickness/2)
			left   =           math.ceil(p.frame_thickness/2)
			right  = w*ratio - math.ceil(p.frame_thickness/2)
        	
			focus:begin_painting() -- fill -> focus

			focus:move_to(        left,         top )
			focus:line_to(   right-RAD,         top )
			focus:curve_to( right, top,right,top,right,top+RAD)
			focus:line_to(       right,  bottom-RAD )
			focus:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        	
			focus:line_to(           left+RAD,          bottom )
			focus:curve_to(left,bottom,left,bottom,left,bottom-RAD)
			focus:line_to(           left,            top+RAD )
			focus:curve_to(left,top,left,top,left+RAD,top)
        
			focus:set_source_linear_pattern(
				focus.w/2,0,
				focus.w/2,focus.h
			)
			focus:add_source_pattern_color_stop( 0 , p.focus_bar_color_inner )
			focus:add_source_pattern_color_stop( 1 , p.focus_bar_color_outer )
			focus:fill(true)
        	focus:set_line_width(   p.frame_thickness )
			focus:set_source_color( p.frame_color )
			focus:stroke( true )
			focus:finish_painting()

        	if focus.Image then focus = focus:Image() end

			return focus
		end 

		local function my_make_hor_focus( _ , ...)
     		return make_hor_focus( ... )
		end 

		key = string.format ("h_focus:%d:%d:%f:%s:%s:%d:%s", w,h,ratio,color_to_string(p.focus_bar_color_inner),color_to_string(p.focus_bar_color_outer), 
							p.frame_thickness, color_to_string(p.frame_color))
		focus = assets(key, my_make_hor_focus)

        shell.name="track"
        shell.reactive = true
        fill.name="grip"
        fill.reactive=true
        fill.y=p.frame_thickness/2
		focus.name="focus_grip"
		focus.reactive=true
        focus.y=p.frame_thickness/2
		focus:hide()

		bar:add(shell,fill,focus)

        return bar
    end

    local function make_vert_bar(w,h,ratio)
        local bar = Group{}
		
		local RAD = 6
        
		local top    =           math.ceil(p.frame_thickness/2)
		local bottom = h - math.ceil(p.frame_thickness/2)
		local left   =           math.ceil(p.frame_thickness/2)
		local right  = w - math.ceil(p.frame_thickness/2)

		local shell, fill, focus, key

		local function make_vert_shell ()
			local shell = Canvas{
				size = {w,h},
			}

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
        
			if shell.Image then shell = shell:Image() end

			return shell 

		end 

		local function my_make_vert_shell( _ , ...)
     		return make_vert_shell( ... )
		end 

		key = string.format ("h_shell:%d:%d:%f:%s:%s:%d:%s", w,h,ratio,color_to_string(p.empty_color_inner),color_to_string(p.empty_color_outer), 
							p.frame_thickness, color_to_string(p.frame_color))
		shell = assets(key, my_make_vert_shell)

		local function make_vert_fill()
			local fill  = Canvas{
				size = {w-p.frame_thickness,h*ratio},
			}
			 
			top    =          math.ceil(p.frame_thickness/2)
			bottom = fill.h - math.ceil(p.frame_thickness/2)
			left   =          math.ceil(p.frame_thickness/2)
			right  = fill.w - math.ceil(p.frame_thickness/2)
        
			fill:begin_painting() -- shell -? fill ? 
        
		
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

			if  fill.Image then fill  =  fill:Image() end
	
			return fill
		end 

		local function my_make_vert_fill( _ , ...)
     		return make_vert_fill( ... )
		end 

		key = string.format ("h_fill:%d:%d:%f:%s:%s:%d:%s", w,h,ratio,color_to_string(p.bar_color_inner),color_to_string(p.bar_color_outer), 
							p.frame_thickness, color_to_string(p.frame_color))
		fill = assets(key, my_make_vert_fill) 

		local function make_vert_focus()
			local focus  = Canvas{
				size = {w-p.frame_thickness,h*ratio},
			}

			top    =           math.ceil(p.frame_thickness/2)
			bottom = focus.h - math.ceil(p.frame_thickness/2)
			left   =           math.ceil(p.frame_thickness/2)
			right  = focus.w - math.ceil(p.frame_thickness/2)
        	
			focus:begin_painting() -- shell -> focus ?
        
		
			focus:move_to(        left,         top )
			focus:line_to(   right-RAD,         top )
			focus:curve_to( right, top,right,top,right,top+RAD)
			focus:line_to(       right,  bottom-RAD )
			focus:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        	
			focus:line_to(           left+RAD,          bottom )
			focus:curve_to(left,bottom,left,bottom,left,bottom-RAD)
			focus:line_to(           left,            top+RAD )
			focus:curve_to(left,top,left,top,left+RAD,top)
        	
			focus:set_source_linear_pattern(
				0,focus.h/2,
            	focus.w,focus.h/2
			)
			focus:add_source_pattern_color_stop( 0 , p.focus_bar_color_inner )
			focus:add_source_pattern_color_stop( 1 , p.focus_bar_color_outer )
			focus:fill(true)
        	focus:set_line_width(   p.frame_thickness )
			focus:set_source_color( p.frame_color )
			focus:stroke( true )
			focus:finish_painting()
			
			if focus.Image then focus = focus:Image() end

			return focus
		end 

		local function my_make_vert_focus( _ , ...)
     		return make_vert_focus( ... )
		end 

		key = string.format ("h_focus:%d:%d:%f:%s:%s:%d:%s", w,h,ratio,color_to_string(p.focus_bar_color_inner),color_to_string(p.focus_bar_color_outer), 
							p.frame_thickness, color_to_string(p.frame_color))
		focus = assets(key, my_make_vert_focus)
		        
		bar:add(shell,fill,focus)
        
        shell.name="track"
        shell.reactive = true
        fill.name="grip"
        fill.reactive=true
        fill.x=p.frame_thickness/2
		focus.name="focus_grip"
		focus.reactive=true
        focus.x=p.frame_thickness/2
		focus:hide()

        return bar
    end
	
	--this function creates the whole scroll bar box
    local hold = false

	local function create()
        scroll_group:clear()
        window.position={ p.box_border_width, p.box_border_width }
		window.clip = { 0,0, p.visible_width, p.visible_height }
        border:set{
            w = p.visible_width+2*p.box_border_width,
            h = p.visible_height+2*p.box_border_width,
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
            track_w = p.visible_width+p.bar_offset
            track_h = p.visible_height+p.bar_offset
        else
            track_w = p.visible_width
            track_h = p.visible_height
        end
        
        if p.horz_bar_visible and p.visible_width/p.virtual_width < 1 then
            hor_s_bar = make_hor_bar(track_w, p.bar_thickness, track_w/p.virtual_width)
            hor_s_bar.name = "Horizontal Scroll Bar"

            
            hor_s_bar.position={
                p.box_border_width,
                p.box_border_width*2+p.visible_height+p.bar_offset
            }
            
            scroll_group:add(hor_s_bar)
            
            unfocus_grip_hor = hor_s_bar:find_child("grip")
            focus_grip_hor = hor_s_bar:find_child("focus_grip")
            track_hor = hor_s_bar:find_child("track")
			grip_hor = unfocus_grip_hor

            function focus_grip_hor:on_button_down(x,y,button,num_clicks)
                local dx = x - grip_hor.x
	   	        
                dragging = {grip_hor,
	   		        function(x,y)
	   			
	   			        grip_hor.x = x - dx
	   			
	   			        if  grip_hor.x < 0 then
	   				        grip_hor.x = 0
	   			        elseif grip_hor.x > track_w-grip_hor.w then
	   				           grip_hor.x = track_w-grip_hor.w
	   			        end
	   			
	   			        p.content.x = -(grip_hor.x ) * p.virtual_width/track_w
	   			
	   		        end 
	   	        }
	   	
                return true
            end

			unfocus_grip_hor.on_button_down = focus_grip_hor.on_button_down

            function track_hor:on_button_down(x,y,button,num_clicks)
                
                local rel_x = x - track_hor.transformed_position[1]/screen.scale[1]
	   	        
				if grip_hor.x > rel_x then
					grip_hor.x = grip_hor.x - grip_hor.w
					if grip_hor.x < 0 then grip_hor.x = 0 end
				else
					grip_hor.x = grip_hor.x + grip_hor.w
					if grip_hor.x > track_hor.w-grip_hor.w then
						grip_hor.x = track_hor.w-grip_hor.w
					end
				end

                p.content.x = -(grip_hor.x) * p.virtual_width/track_w
                
                return true
            end
        else
            grip_hor=nil
            track_hor=nil
			focus_grip_hor=nil
			unfocus_grip_hor=nil
        end
        if p.vert_bar_visible and p.visible_height/p.virtual_height < 1 then
            vert_s_bar = make_vert_bar( p.bar_thickness, track_h, track_h/p.virtual_height)
            vert_s_bar.name = "Vertical Scroll Bar"
            
            vert_s_bar.position={
                p.box_border_width*2+p.visible_width+p.bar_offset,
                p.box_border_width
            }
            
            --vert_s_bar.z_rotation={90,0,0}
            scroll_group:add(vert_s_bar)
            
            unfocus_grip_vert = vert_s_bar:find_child("grip")
            track_vert = vert_s_bar:find_child("track")
            focus_grip_vert = vert_s_bar:find_child("focus_grip")
			
			grip_vert = unfocus_grip_vert

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
                        
	   			        p.content.y = -(grip_vert.y) * p.virtual_height/track_h
                        
	   		        end 
	   	        }
                
                return true
            end

            function track_vert:on_button_down(x,y,button,num_clicks)
                
                local rel_y = y - track_vert.transformed_position[2]/screen.scale[2]
	   	        
				if grip_vert.y > rel_y then
					grip_vert.y = grip_vert.y - grip_vert.h
					if grip_vert.y < 0 then grip_vert.y = 0 end
				else
					grip_vert.y = grip_vert.y + grip_vert.h
					if grip_vert.y > track_vert.h-grip_vert.h then
						grip_vert.y = track_vert.h-grip_vert.h
					end
				end

                p.content.y = -(grip_vert.y) * p.virtual_height/track_h
                
                return true
            end
        else
            grip_vert=nil
            track_vert=nil
			focus_grip_vert=nil
			unfocus_grip_vert=nil
        end
        
		scroll_group.size = {p.visible_width + 2*p.box_border_width, p.visible_height + 2*p.box_border_width}
	
		scroll_group:add(border,window)
	end

    create()

	window:add(p.content)
		
	function scroll_group:on_key_focus_in()
		if grip_hor ~= nil then
			unfocus_grip_hor:hide()
			focus_grip_hor:show()
			focus_grip_hor.y = unfocus_grip_hor.y
			grip_hor = focus_grip_hor
		end
		if grip_vert ~= nil then
			unfocus_grip_vert:hide()
			focus_grip_vert:show()
			focus_grip_vert.y = unfocus_grip_vert.y
			grip_vert = focus_grip_vert
		end
		border.border_color = p.focus_box_color
	end
	
	function scroll_group:on_key_focus_out()
		if grip_hor ~= nil then
			unfocus_grip_hor:show()
			focus_grip_hor:hide()
			unfocus_grip_hor.y = focus_grip_hor.y
			grip_hor = unfocus_grip_hor
		end
		if grip_vert ~= nil then
			unfocus_grip_vert:show()
			focus_grip_vert:hide()
			unfocus_grip_vert.y = focus_grip_vert.y
			grip_vert = unfocus_grip_vert
		end
		border.border_color = p.box_color
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
        elseif k =="selected" then 
        	p[k] = v
		else
        	p[k] = v
        	create()
		end
    end
    
	mt.__index = function(t,k)       
       return p[k]
    end

    setmetatable(scroll_group.extra, mt)

    return scroll_group
end
--]=]