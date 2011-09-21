FocusableImage = Class(function(focusimg, pos, txt, image_clone, focus_clone,enter_func, ...)
    assert(pos)
    assert(pos[1])
	assert(pos[2])
    assert(image_clone)
    assert(focus_clone)
    focusimg.image = Clone
	{ 
		name = "buttonsss",
		source = image_clone,
		anchor_point = {image_clone.w/2,image_clone.h/2},
		position = {image_clone.w/2,image_clone.h/2}
	}

    focusimg.focus = Clone
	{
		source = focus_clone,
		anchor_point = {focus_clone.w/2,focus_clone.h/2},
		opacity = 0,
		position = {focus_clone.w/2,focus_clone.h/2}
	}

    focusimg.group = Group{x=pos[1],y=pos[2]}
    focusimg.group:add(focusimg.image, focusimg.focus)
    if txt ~= nil then
		local t_shadow = Text
		{
			name     = "text_s",
			text     = txt,
			font     = "DejaVu Sans Condensed normal 32px",
			color    = "000000"
		}
		t_shadow.anchor_point = {t_shadow.w/2,t_shadow.h/2}
		t_shadow.position     = 
		{focus_clone.w/2-1,focus_clone.h/2-1}
--			pos[1]-1,
--			pos[2]-1
--		}

		local t = Text
		{
			name     = "text",
			text     = txt,
			font     = "DejaVu Sans Condensed normal 32px",
			color    = "FFFFFF"
		}
		t.anchor_point = {t.w/2,t.h/2}
		t.position     = 
		{focus_clone.w/2,focus_clone.h/2}
--			pos[1],
--			pos[2]
--		}
        focusimg.group:add(t_shadow,t)
    end
    function focusimg:on_focus()
		focusimg.focus.opacity = 255
		focusimg.image.opacity = 0
    end

    function focusimg:out_focus()
		focusimg.focus.opacity = 0
		focusimg.image.opacity = 180
    end


	function focusimg:press_left()
	end
	function focusimg:press_right()
	end
	function focusimg:press_up()
	end
	function focusimg:press_down()
	end
	function focusimg:press_enter(param)
		return enter_func(param)
	end
	--focusimg.group.anchor_point = {focusimg.group.w/2,focusimg.group.h/2}
	focusimg:out_focus()
end)

VertButtonCarousel = Class(function(
	menu,name,options,pos,buttons,arrows,rotate_func,...)

	--sanity checks
	assert(pos[1])
	assert(pos[1])
	assert(buttons)
	assert(buttons[1])
	assert(buttons[2])
	assert(arrows)
	assert(arrows[1])
	assert(arrows[2])
	assert(arrows[3])
	assert(arrows[4])
	local index = 1

	menu.unfocus = Clone
	{
		source = buttons[1],
		anchor_point = {buttons[1].w/2,buttons[1].h/2},
		position = {buttons[1].w/2,buttons[1].h/2+arrows[1].h}
	}
	menu.focus = Clone
	{
		source = buttons[2],
		anchor_point = {buttons[2].w/2,buttons[2].h/2},
		position = {buttons[2].w/2,buttons[2].h/2+arrows[1].h}

	}
	menu.up_un  = Clone
	{
		source = arrows[1],
		anchor_point = {arrows[1].w/2,arrows[1].h/2},
		position = {buttons[2].w/2,arrows[1].h/2 }
	}
	menu.up_sel = Clone
	{
		source = arrows[2],
		anchor_point = {arrows[2].w/2,arrows[2].h/2},
		opacity = 0,
		position = {buttons[2].w/2,arrows[2].h/2 }
	}
	menu.down_un   = Clone
	{
		source = arrows[3],
		anchor_point = {arrows[3].w/2,arrows[3].h/2},
		position = {buttons[2].w/2,arrows[1].h+buttons[1].h+
		                           arrows[3].h/2 }
	}
	menu.down_sel  = Clone
	{
		source = arrows[4],
		anchor_point = {arrows[4].w/2,arrows[4].h/2},
		opacity = 0,
		position = {buttons[2].w/2,arrows[1].h+buttons[1].h+
		                           arrows[3].h/2 }
	}
	menu.name = Text
	{
		text = name,
		font = "DejaVu Sans Bold normal 36px",
		color = "FFFFFF",
	}
--[[
	menu.name.anchor_point = {menu.name.w/2,menu.name.h/2}
	menu.name.position = {menu.focus.x - menu.focus.w/2 - 
		menu.name.w/2 - 55,menu.focus.y}
--]]
	menu.group = Group{x=pos[1],y=pos[2]}
	menu.txt_group = Group{}
	menu.group:add(
		menu.unfocus,
		menu.focus,
		menu.up_un,
		menu.up_sel,
		menu.down_un,
		menu.down_sel,
		menu.txt_group
--		menu.name
	)
	---[[
	menu.txt_group.clip = 
	{
		0, arrows[1].h+10,
		buttons[1].w,          buttons[1].h-15
	}
--]]
	menu.items = {}
	for i = 1, #options do
		menu.items[i] = Group()
		local txt = Text
		{
			text  = options[i],
			font  = "DejaVu Sans Condensed normal 32px",
			color = "FFFFFF",
			--opacity = 0
		}
		txt.anchor_point = 
		{
			txt.w/2,
			txt.h/2+2
		}
		--txt.position = {}
		local t_shadow = Text
		{
			text  = options[i],
			font  = "DejaVu Sans Condensed normal 32px",
			color = "000000",
			--opacity = 0
		}
		t_shadow.anchor_point = 
		{
			t_shadow.w/2+1,
			t_shadow.h/2+3
		}
		menu.items[i]:add(t_shadow,txt)
		menu.txt_group:add(menu.items[i])
	end

	--first item selected
	menu.items[1].opacity = 255
	menu.items[1].x       = buttons[1].w/2 --+ menu.focus.w/2
	menu.items[1].y       = arrows[1].h+buttons[1].h/2-- + menu.focus.h/2

	--hover events
	function menu:on_focus()
		menu.unfocus.opacity = 0
		menu.focus.opacity   = 255
	end
	function menu:out_focus()
		menu.unfocus.opacity = 255
		menu.focus.opacity   = 0
	end
	local t = nil
	--key press events
	function menu:press_up()
		local prev_i = index
		local next_i = (index-1-1)%(#menu.items)+1

		index = next_i
		local prev_old_x = buttons[1].w/2--+menu.focus.w/2
		local prev_old_y = arrows[1].h+buttons[1].h/2--+menu.focus.h/2
		local next_old_x = buttons[1].w/2--+3*menu.focus.w/2
		local next_old_y = arrows[1].h+15+3*buttons[1].h/2--+menu.focus.h/2

		local prev_new_x = buttons[1].w/2--/2
		local prev_new_y = arrows[1].h-buttons[1].h/2--+menu.focus.h/2
		local next_new_x = buttons[1].w/2--+menu.focus.w/2
		local next_new_y = arrows[1].h+buttons[1].h/2--+menu.focus.h/2
		if t ~= nil then
			t:stop()
			t:on_completed()
		end
		t = Timeline
		{
			duration = 300,
			direction = "FORWARD",
			loop = false
		}

		function t.on_new_frame(t,_,p)
			local msecs = t.elapsed
			if msecs <= 100 then
				menu.up_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				menu.up_sel.opacity = 255
			else 
				menu.up_sel.opacity = 255*(1- (msecs-200)/100)
			end
			menu.items[prev_i].x = prev_old_x + p*(prev_new_x - prev_old_x)
			menu.items[prev_i].y = prev_old_y + p*(prev_new_y - prev_old_y)

			menu.items[next_i].x = next_old_x + p*(next_new_x - next_old_x)
			menu.items[next_i].y = next_old_y + p*(next_new_y - next_old_y)
		end
		function t.on_completed()
			menu.items[prev_i].x = prev_new_x
			menu.items[prev_i].y = prev_new_y

			menu.items[next_i].x = next_new_x
			menu.items[next_i].y = next_new_y
			t = nil
		end
			if rotate_func then
				rotate_func(next_i,prev_i)
			end

		t:start()
	end
	function menu:press_down()
		local prev_i = index
		local next_i = (index+1-1)%(#menu.items) + 1
		index = next_i
		local prev_old_x = buttons[1].w/2--+menu.focus.w/2
		local prev_old_y = arrows[1].h+buttons[1].h/2--+menu.focus.h/2
		local next_old_x = buttons[1].w/2--/2
		local next_old_y = arrows[1].h-buttons[1].h/2--+menu.focus.h/2

		local prev_new_x = buttons[1].w/2--+3*menu.focus.w/2
		local prev_new_y = arrows[1].h+3*buttons[1].h/2--+menu.focus.h/2
		local next_new_x = buttons[1].w/2--+menu.focus.w/2
		local next_new_y = arrows[1].h+buttons[1].h/2--+menu.focus.h/2
		if t ~= nil then
			t:stop()
			t:on_completed()
		end

		t = Timeline
		{
			duration = 300,
			direction = "FORWARD",
			loop = false
		}

		function t.on_new_frame(t,_,p)
			local msecs = t.elapsed
			if msecs <= 100 then
				menu.down_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				menu.down_sel.opacity = 255
			else 
				menu.down_sel.opacity = 255*(1- (msecs-200)/100)
			end

			menu.items[prev_i].x = prev_old_x + p*(prev_new_x - prev_old_x)
			menu.items[prev_i].y = prev_old_y + p*(prev_new_y - prev_old_y)

			menu.items[next_i].x = next_old_x + p*(next_new_x - next_old_x)
			menu.items[next_i].y = next_old_y + p*(next_new_y - next_old_y)
		end
		function t.on_completed()
			menu.items[prev_i].x = prev_new_x
			menu.items[prev_i].y = prev_new_y

			menu.items[next_i].x = next_new_x
			menu.items[next_i].y = next_new_y
--[[
			if rotate_func then
				rotate_func(next_i)
			end
--]]
			t = nil
		end
			if rotate_func then
				rotate_func(next_i,prev_i)
			end

		t:start()

	end
	function menu:press_left()
	end
	function menu:press_right()
	end
	function menu:press_enter()
	end

	menu:out_focus()
end)
--[[
------------------------------------------------
----    Pablo's dropdown from launcher16    ----
------------------------------------------------
function make_dropdown( size , color )

    local BORDER_WIDTH=4
    local POINT_HEIGHT=38
    local POINT_WIDTH=60
    local BORDER_COLOR="FFFFFF5C"
    local CORNER_RADIUS=22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2
    
    local function draw_path( c )
    
        c:new_path()
    
        c:move_to( H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
            
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
                    H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
    
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
    c:set_source_radial_pattern( 0 , 30 , 0 , 0 , 30 , c.w / 2 )
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
    
    return c
    
end
-------------------------------------------




Dropbox = Class(function(dropbox,name,options,pos,f,...)
	local index = 1

	dropbox.title = Group{}
	dropbox.title:add(Text
	{
		name	= "title",
		text	=  name,
		font	= "Blue Highway condensed 42px",
		color	= "FFFFFF",
		x		= pos[1],
		y		= pos[2]-75
	})

	dropbox.group = Group
	{
		name = name,
		position = {pos[1]+dropbox.title:find_child("title").w -5, pos[2]-120 }
	}

	--dropbox.title= 	FocusableImage(pos[1],pos[2]-40,button_un,button_sel,name.." - "..options[1])

	dropbox.menu_items = {}
    local longest_str = 0

	for i = 1, #options do
		dropbox.menu_items[i] = Text
			{
				name		= "text "..i,
				text		= options[i],
				font		= "Blue Highway condensed 40px",
				color		= "FFFFFF",
				position	= {55,60*(i-1)+48},
				opacity		= 255
			}
		if dropbox.menu_items[i].w > longest_str then
			longest_str = dropbox.menu_items[i].w
		end
		dropbox.group:add(dropbox.menu_items[i])
	end
	local left_un, left_sel, mid_un, mid_sel, right
	left_un,  left_sel  = create_leftbar({pos[1]-10,pos[2]-85})
	mid_un,   mid_sel   = create_middlebar({pos[1],pos[2]-85},
									{dropbox.title:find_child("title").w,60})
	right = create_empty_rightbar( {pos[1]+dropbox.title:find_child("title").w-70,pos[2]-85},
									{longest_str+170,60})--longest_str+110})
	dropbox.title:add(left_un, left_sel,right_un, right, mid_un, mid_sel 
									)
mid_un:lower_to_bottom()
mid_sel:lower_to_bottom()
right:lower_to_bottom()
left_un:lower_to_bottom()
left_sel:lower_to_bottom()
	mid_sel.opacity   = 0
	left_sel.opacity  = 0
	dropbox.bg = make_dropdown({longest_str+120,(#options)*60+35},"222222")
dropbox.group.clip = {0,0,longest_str+175,90}
    dropbox.group:add(dropbox.bg)
	dropbox.bg:lower_to_bottom()
	--dropbox.group.y_rotation = { 90 , dropbox.group.w/2 , 0 }
	dropbox.group.opacity = 255
	function dropbox:open()
        
        dropbox.group:raise_to_top()

		dropbox.title:raise_to_top()
		local old_y  = dropbox.group.clip[2]
		local old_h  = dropbox.group.clip[4]
		local targ_y = 0
		local targ_h = dropbox.group.h

		local t = Timeline
		{
			duration = 200,
			direction = "FORWARD",
			loop = false,
		}
		function t.on_new_frame(t)
			local msecs = t.elapsed
			local p = msecs/t.duration
			dropbox.group.clip = 
				{0,old_y + (targ_y-old_y)*p,
				dropbox.group.w,old_h + (targ_h-old_h)*p}

		end
		function t.on_completed()
			dropbox.group.clip = 
				{0,0,dropbox.group.w,dropbox.group.h}
		end
		t:start()
    end
	function dropbox:move_up()
		if index > 1 then
			index = index - 1
			dropbox.group:animate
			{
				duration = 200,
				y = (index-1)*-60+pos[2]-120
			}
			if f then
				f(index)
			end
		end
	end
	function dropbox:move_down()
		if index < #options then
			index = index + 1
			dropbox.group:animate
			{
				duration = 200,
				y = (index-1)*-60+pos[2]-120
			}
			if f then
				f(index)
			end

		end
	end
	function dropbox:close()

		dropbox.group:raise_to_top()
		dropbox.title:raise_to_top()

		local old_y  = dropbox.group.clip[2]
		local old_h  = dropbox.group.clip[4]
		local targ_y = (index-1)*60+40
		local targ_h = 50

		local t = Timeline
		{
			duration = 200,
			direction = "FORWARD",
			loop = false,
		}
		function t.on_new_frame(t)
			local msecs = t.elapsed
			local p = msecs/t.duration
			dropbox.group.clip = 
				{0,old_y + (targ_y-old_y)*p,
				dropbox.group.w,old_h + (targ_h-old_h)*p}

		end
		function t.on_completed()
			dropbox.group.clip = 
				{0,targ_y,dropbox.group.w,targ_h}
		end
		t:start()
	end
	function dropbox:focus_on(index)
		for i = 1,#dropbox.menu_items do
			if i == index then
				dropbox.menu_items[i].opacity = 255
			else
				dropbox.menu_items[i].opacity = 150
			end
		end
	end
	function dropbox:pick(i)
		--dropbox.title:find_child("selected").text = dropbox.menu_items[i].text
	end
	function dropbox:on_focus()
		mid_sel.opacity   = 255
		left_sel.opacity  = 255
		mid_un.opacity    = 0
		left_un.opacity   = 0
	end
	function dropbox:out_focus()
		mid_sel.opacity   = 0
		left_sel.opacity  = 0
		mid_un.opacity    = 255
		left_un.opacity   = 255
	end

end)
--]]

