

-----------------------
--  Button Picker 
-----------------------
 
--[[name = mode, korean-mode 
    options : {{"Home Mode","Casa el Modo de","Mode d'Accueil","가정용"}, 
              {"Store Demo","Demo Store","Demo Store","데모 모드"}}
 ]]

--[[

function widget.buttonCarousel(t)
	-- menu,name,options,pos,buttons,arrows,rotate_func,...
     local p = {}
     if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
     end 

     if not p.name then p.name = "buttonCarousel" end   
     if not p.options then p.options = "" end   
     if not p.buttons then p.buttons = "" end   
     if not p.arrows then p.arrows = "" end   
     if not p.rotate_func then p.rotate_func = "" end   

     if not p.size then p.size = {34, 60} end   
     if not p.position then p.position = {200, 200} end   

     if not p.width then p.width = 34 end
     if not p.height then p.height = 60 end
     if not p.border_width then p.border_width  = 3 end
     if not p.border_color then p.border_color  = "FFFFFFC0" end 
     if not p.font then p.font = "DejaVu Sans 30px"  end 
     if not p.color then p.color = "FFFFFF" end 
     if not p.padding_x then p.padding_x = 10 end
     if not p.padding_y then p.padding_y = 10 end
     if not p.border_radius then p.border_radius = 22 end

-- new prams : 
     if not p.optionNum then p.optionNum = 3 end
-- new prams : 

     local button_un    = Image{src = "assets/button.png",           opacity = 0}
     local button_sel   = Image{src = "assets/buttonfocus.png",      opacity = 0}
     --local s_button_un  = Image{src = "assets/smallbutton.png",      opacity = 0}
     local s_button_sel = Image{src = "assets/smallbuttonfocus.png", opacity = 0}
     local right_un     = Image{src = "assets/right.png",            opacity = 0}
     local right_sel    = Image{src = "assets/rightfocus.png",       opacity = 0}
     local left_un      = Image{src = "assets/left.png",             opacity = 0}
     local left_sel     = Image{src = "assets/leftfocus.png",        opacity = 0}
 


]] 

 --oobe : local name = {[strings["ButtonName"]] = {["english"]="Mode: ",["spanish"]="Modo: ",["french"]="Fonction: ",["korean"]="모드: "}}
     -- oobe : local options = {[strings ["Option1"]] = {["english"]="Home Mode",["spanish"]="Casa el Modo de",["french"]="Mode d'Accueil",["korean"]="가정용"},[strings["Option2"]]= {["english"]="Store Demo",["spanish"]="Demo Store",["french"]="Demo Store",["korean"]="데모 모드"}}

--[[
     local name = strings["ButtonName"] 
     local options = {strings["Option1"], strings["Option2"], strings["Option3"]}

     -- local buttons = { s_button_un,s_button_sel }
     local arrows    = { right_un, right_sel, left_un, left_sel }


     local pos = {screen.w/2+button_sel.w/2+10,414+buttons[1].h/2},
     local index = 1

     local unfocus = assets("assets/smallbutton.png"):set(anchor_point = {self.w/2,self.h/2},
                            position = {pos[1], pos[2]}, opacity = 0)

     local focus = assets("assets/smallbuttonfocus.png"):set(anchor_point = {self.w/2,self.h/2},
		           position = {pos[1], pos[2]}, opacity = 0)

     local right_un  = assets("assets/right.png"):set( anchor_point = {self.w/2,self.h/2},
		       position = {focus.x + focus.w/2+self.w/2+15,focus.y}, opacity = 0)

     local right_sel = assets("assets/rightfocus.png"):set(anchor_point = {self.w/2,self.h/2},
		       position = {focus.x + focus.w/2+self.w/2+15, focus.y},  opacity = 0)

     local left_un   = assets("assets/left.png"):set("assets/left.png"):set(anchor_point = {self.w/2,self.h/2},
		       position = {focus.x - focus.w/2-self.w/2 -15, focus.y},  opacity = 0)

     local left_sel  = assets("assets/leftfocus.png"):set( anchor_point = {self.w/2,self.h/2},
		       position = {focus.x - focus.w/2-self.w/2-15, focus.y, opacity = 0})

     local name = Text{text=name, font = "LG Display10_CJK 36px", color = "FFFFFF"} 
     name.anchor_point = {self.w/2,self.h/2}
     name.position = {focus.x - focus.w/2 - self.w/2 - 55,focus.y}
     txt_group = Group{}

     items = {}

     for i = 1, #options do
	items[i] = Group()
	local txt = Lang_Text(options[i],
	{
		--text  = options[i],
		font  = "LG Display10_CJK 32px",
		color = "FFFFFF",
		--opacity = 0
	})
	txt.anchor_point = 
	{
		txt.w/2,
		txt.h/2+2
	}
	local t_shadow = Lang_Text(options[i],
	{
		--text  = options[i],
		font  = "LG Display10_CJK 32px",
		color = "000000",
		--opacity = 0
	})
	t_shadow.anchor_point = 
	{
		t_shadow.w/2+1,
		t_shadow.h/2+3
	}
	items[i]:add(t_shadow,txt)
		txt_group:add(items[i])
      end
 
      menu = Group
      {
		children = {unfocus, focus, right_un, right_sel, left_un, left_sel, txt_group, name, txt_group}
      }
     

	--first item selected
      items[1].opacity = 255
      items[1].x       = pos[1] --+ focus.w/2
      items[1].y       = pos[2]-- + focus.h/2

	--hover events
	function menu.extra.on_focus()
		unfocus.opacity = 0
		focus.opacity   = 255
	end
	function menu.extra.out_focus()
		unfocus.opacity = 255
		focus.opacity   = 0
	end
	local t = nil
	--key press events
	function menu.extra.press_left()
		local prev_i = index
		local next_i = (index-1-1)%(#items)+1

                print(prev_i,next_i, #items,"hi")
		index = next_i
		local prev_old_x = pos[1]--+focus.w/2
		local prev_old_y = pos[2]--+focus.h/2
		local next_old_x = pos[1]+focus.w--+3*focus.w/2
		local next_old_y = pos[2]--+focus.h/2

		local prev_new_x = pos[1]-focus.w--/2
		local prev_new_y = pos[2]--+focus.h/2
		local next_new_x = pos[1]--+focus.w/2
		local next_new_y = pos[2]--+focus.h/2
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

		function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
				left_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				left_sel.opacity = 255
			else 
				left_sel.opacity = 255*(1- (msecs-200)/100)
			end
			items[prev_i].x = prev_old_x + p*(prev_new_x - prev_old_x)
			items[prev_i].y = prev_old_y + p*(prev_new_y - prev_old_y)

			items[next_i].x = next_old_x + p*(next_new_x - next_old_x)
			items[next_i].y = next_old_y + p*(next_new_y - next_old_y)
		end
		function t.on_completed()
			items[prev_i].x = prev_new_x
			items[prev_i].y = prev_new_y

			items[next_i].x = next_new_x
			items[next_i].y = next_new_y
			t = nil
		end
			if rotate_func then
				rotate_func(next_i,prev_i)
			end

		t:start()
	end

	local function menu.extra.press_right()
		local prev_i = index
		local next_i = (index+1-1)%(#items) + 1
                print(prev_i,next_i)
		index = next_i
		local prev_old_x = pos[1]
		local prev_old_y = pos[2]
		local next_old_x = pos[1]-focus.w
		local next_old_y = pos[2]

		local prev_new_x = pos[1]+focus.w
		local prev_new_y = pos[2]
		local next_new_x = pos[1]
		local next_new_y = pos[2]
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

		function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
G				right_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				right_sel.opacity = 255
			else 
				right_sel.opacity = 255*(1- (msecs-200)/100)
			end

			items[prev_i].x = prev_old_x + p*(prev_new_x - prev_old_x)
			items[prev_i].y = prev_old_y + p*(prev_new_y - prev_old_y)

			items[next_i].x = next_old_x + p*(next_new_x - next_old_x)
			items[next_i].y = next_old_y + p*(next_new_y - next_old_y)
		end
		function t.on_completed()
			items[prev_i].x = prev_new_x
			items[prev_i].y = prev_new_y

			items[next_i].x = next_new_x
			items[next_i].y = next_new_y
			t = nil
		end
			if rotate_func then
				rotate_func(next_i,prev_i)
			end

		t:start()

	end
 	local function extra.press_up()
	end
	local function extra.press_down()
	end
	local function extra.press_enter()
	end

	out_focus()
        
        return menu 
end

]]
-----------------------------
-- List Picker, Check Box 
-----------------------------

-----------------------------
-- List Picker, Radio Button
-----------------------------

-----------------------------------------
-- List Scroll Button (or Arrow Image)   
-----------------------------------------

--[[
function make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     
     local x_scroll_box, y_scroll_box 
     local x_scroll_bar, y_scroll_bar 

     if(x_scroll_to == 0)then 
	 x_scroll_to = screen.w
     end
     if(y_scroll_to == 0)then 
	 y_scroll_to = screen.h
     end

     g.extra.canvas_h = y_scroll_to - y_scroll_from -- y 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_w = x_scroll_to - x_scroll_from -- x 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_f = y_scroll_from
     g.extra.canvas_xf = x_scroll_from
     g.extra.canvas_t = y_scroll_to
     g.extra.canvas_xt = x_scroll_to

     screen_rect =  Rectangle{
                name="screen_rect",
                border_color= {2, 25, 25, 140},
                border_width=2,
                color= {255,255,255,0},
                size = {screen.w+1,screen.h+1},
                position = {0,0,0}, 
     }
     screen_rect.reactive = false
     g:add(screen_rect)


     
    if (g.extra.canvas_w > screen.w) then 
	local SCROLL_X_POS = 10
	local BOX_BAR_SPACE = 6
	
        x_scroll_box = factory.make_x_scroll_box()
        x_scroll_bar = factory.make_x_scroll_bar(g.extra.canvas_w)

	x_scroll_box.position = {SCROLL_X_POS, screen.h - 60}
	x_scroll_bar.position = {SCROLL_X_POS + BOX_BAR_SPACE, screen.h - 56}

	
        x_scroll_bar.extra.org_x = 16
	x_scroll_bar.extra.h_x = 16
	x_scroll_bar.extra.l_x = x_scroll_box.x + x_scroll_box.w - x_scroll_bar.w - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(x_scroll_box) 
	screen:add(x_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dx = ((g.extra.canvas_w - screen.w)/(x_scroll_bar.extra.l_x - x_scroll_bar.extra.h_x))

		
	local x0 = - g.extra.canvas_xf/g.extra.scroll_dx + 10 
	local x1920 = (-g.extra.canvas_xf+1080)/g.extra.scroll_dx + 10

	x_0_mark= Rectangle {
		name="x_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x0, screen.h - 55, 0},
		opacity = 255
        }

	x_1920_mark= Rectangle {
		name="x_1920_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x1920, screen.h - 55, 0},
		opacity = 255
        }
  
	screen:add(x_0_mark)
	screen:add(x_1920_mark) 

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_x = m.x
	end 
         
        function x_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {x_scroll_bar, x-x_scroll_bar.x, y-x_scroll_bar.y }

		if table.getn(selected_objs) ~= 0 then
		     for q, w in pairs (selected_objs) do
			 local t_border = screen:find_child(w)
			 local i, j = string.find(t_border.name,"border")
		         local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		         if(t_obj ~= nil) then 
			      screen:remove(screen:find_child(t_obj.name.."a_m"))
			 end
		     end
		end

        	return true
    	end 

    	function x_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_x <= x-dx and x-dx <= actor.extra.l_x) then -- 스크롤 되는 범위안에 있으면	
	           		dif = x - dx - x_scroll_bar.extra.org_x -- 스크롤이 이동한 거리 
	           		x_scroll_bar.x = x - dx 
	      		elseif (actor.extra.h_x > x-dx ) then
				dif = actor.extra.h_x - x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.h_x
	      		elseif (actor.extra.l_x < x-dx ) then
				dif = actor.extra.l_x- x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.l_x
			end 
			dif = dif * g.extra.scroll_dx -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.extra.org_x-dif-x_scroll_from, j.y, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.x = t_obj.x 
				 end
			     end
			end

			g.extra.scroll_x = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 


     if(g.extra.canvas_h > screen.h) then 


	local SCROLL_Y_POS = 90
	local BOX_BAR_SPACE = 6

	y_scroll_box = factory.make_y_scroll_box()
        y_scroll_bar = factory.make_y_scroll_bar(g.extra.canvas_h) 

	y_scroll_box.position = {screen.w - 60, SCROLL_Y_POS}
	y_scroll_bar.position = {screen.w - 56, SCROLL_Y_POS + BOX_BAR_SPACE}

        y_scroll_bar.extra.org_y = 96
	y_scroll_bar.extra.h_y = 96
	y_scroll_bar.extra.l_y = y_scroll_box.y + y_scroll_box.h - y_scroll_bar.h - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(y_scroll_box) 
	screen:add(y_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dy = ((g.extra.canvas_h - screen.h)/(y_scroll_bar.extra.l_y - y_scroll_bar.extra.h_y))
  
	
	local y0 = - g.extra.canvas_f/g.extra.scroll_dy + 10 
	local y1080 = (-g.extra.canvas_f+1080)/g.extra.scroll_dy + 10

	y_0_mark= Rectangle {
		name="y_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y0, 0},
		opacity = 255
        }

	y_1080_mark= Rectangle {
		name="y_1080_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y1080, 0},
		opacity = 255
       }
  
	screen:add (y_0_mark)
	screen:add (y_1080_mark)

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_y = m.y
	end 
         
        function y_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {y_scroll_bar, x-y_scroll_bar.x, y-y_scroll_bar.y }
		if table.getn(selected_objs) ~= 0 then
			for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
				      screen:remove(screen:find_child(t_obj.name.."a_m"))
				 end
			end
		end

        	return true
    	end 

    	function y_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_y <= y-dy and y-dy <= actor.extra.l_y) then -- 스크롤 되는 범위안에 있으면	
	           		dif = y - dy - y_scroll_bar.extra.org_y -- 스크롤이 이동한 거리 
	           		y_scroll_bar.y = y - dy 
	      		elseif (actor.extra.h_y > y-dy ) then
				dif = actor.extra.h_y - y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.h_y
	      		elseif (actor.extra.l_y < y-dy ) then
				dif = actor.extra.l_y- y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.l_y
			end 
			dif = dif * g.extra.scroll_dy -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.x, j.extra.org_y-dif-y_scroll_from, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.y = t_obj.y 
				 end
			     end
			end

			g.extra.scroll_y = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 
end


----------------
--  Menu Bar 
----------------

-- main.lua 60 lines 

     ui = {
        fs_focus            = nil,
        bar                 = Group {},
        bar_background      = assets( "assets/menu-background.png" ),
        button_focus        = assets( "assets/button-focus.png" ),
        logo                = assets( "assets/logo.png" ),

        sections =
        {
        }
     }

    ----------------------------------------------------------------------------
    -- The group that holds the bar background and the buttons
    ----------------------------------------------------------------------------
    
    ui.bar:set
    {
        size = ui.bar_background.size,
        
        position = { 0 , 0 },
        
        children =
        {
            ui.bar_background:set
            {
                position = { 0 , 0 },
		size = {ui.bar_background.w, ui.bar_background.h - 15}
            },
            
            ui.button_focus:set
            {
                position = { FIRST_BUTTON_X , FIRST_BUTTON_Y },        
		size  = {ui.button_focus.w, ui.button_focus.h - 15}
            }
        }
    }

    screen:add( ui.bar )    

       
    local i = 0
    local left = FIRST_BUTTON_X
    
    for _ , section in ipairs( ui.sections ) do
    
        section.ui = ui
        section.button.h = section.button.h - 15

        -- Create the dropdown background
        section.dropdown_bg = ui.factory.make_dropdown( { section.button.w + DROPDOWN_WIDTH_OFFSET , section.height } , section.color )
    
        -- Position the button and text for this section
        section.button.position =
        {
            left,
            FIRST_BUTTON_Y
        }
        
        left = left + BUTTON_X_OFFSET + section.button.w 
    
        section.text.position =
        {
            section.button.x + BUTTON_TEXT_X_OFFSET ,
            section.button.y + BUTTON_TEXT_Y_OFFSET - 5 
        }
        
        -- Create the dropdown group
        
        section.dropdown = Group
        {
            size = section.dropdown_bg.size,
            anchor_point = { section.dropdown_bg.w / 2 , 0 },
            position = 
            {
                section.button.x + section.button.w / 2,
                ui.bar.h + DROPDOWN_POINT_Y_OFFSET
            },
            children =
            {
                section.dropdown_bg
            }
        }
        
        -- Add the text and button
        
        ui.bar:add( section.button , section.text )
        
        -- Make sure its Z is correct with respect to the focus image
        
        section.button:lower( ui.button_focus )
        section.text:raise( ui.button_focus )
        
        -- Add the section dropdown to the screen
        
        screen:add( section.dropdown )
        i = i + 1

    end

]]

