
TOASTALERT = 1

ToastAlert = function(parameters)
	
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("DialogBox",parameters)
	
	--flags
	local canvas          = type(parameters.images) == "nil"
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = DialogBox( parameters )
	
	local message = Text()
	
	local icon
	
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
	override_property(instance,"icon",
		
		function(oldf)    return icon   end,
		
		function(oldf,self,v)
			
			if type(v) == "string" then
				
				icon = Image{ src = v }
				
				if icon == nil then
					
					error("ToastAlert.icon recieved string but it was not a valid image uri",2)
					
				end
				
			elseif type(v) == "userdata" and v.__types__.actor then
				
				icon = v
				
			else
				
				error("ToastAlert.icon expected string uri or UIElement. Received "..type(v),2)
				
			end
			
			icon.y = instance.separator_y
			
		end
	)
	override_property(instance,"message_x",
		
		function(oldf)    return message.x   end,
		
		function(oldf,self,v)
			
			message.x = v
			
		end
	)
	override_property(instance,"message",
		
		function(oldf)    return message.text   end,
		
		function(oldf,self,v)
			
			message.text = v
			
		end
	)
	
	function instance:on_size_changed()
		
		message.size = instance.size
		
	end
	
	
	instance:set(parameters)
	
	return instance
	
end










--[[
Function: toastAlert

Creates a Toast alert ui element

Arguments:
	Table of Toast alert properties
	
	skin - Modify the skin used for the toast ui element by changing this value
	title - Title of the Toast alert
	message - Message displayed in the Toast alert
    	title_font - Font used for text in the Toast alert
    	message_font - Font used for text in the Toast alert
    	title_color - Color of the text in the Toast alert
    	message_color - Color of the text in the Toast alert
    	bwidth  - Width of the Toast alert 
    	bheight - Height of the Toast alert 
    	border_color - Border color of the Toast alert
    	fill_color - Fill color of the Toast alert
    	border_width - Border width of the Toast alert 
    	padding_x - Padding of the toast alert on the X axis 
    	padding_y - Padding of the toast alert on the Y axis
    	border_corner_radius - Radius of the border for the Toast alert 
	fade_duration - Time in milleseconds that the Toast alert spends fading away
	on_screen_duration - Time in milleseconds that the Toast alert spends in view before fading out
	icon - The image file name for the icon 

Return:
 		tb_group - Group containing the Toast alert

Extra Function:
		popup() - Start the timer of the Toast alert




function ui_element.toastAlert(t) 

 --default parameters
    local p = {
 	skin = "Custom",  
	ui_width = 770,
	ui_height = 113,
	title = "Toast Alert Title",
	message = "Toast alert message",
	title_font = "FreeSans Medium 22px", 
	message_font = "FreeSans Medium 20px", 
	title_color = {255,255,255,255},  
	message_color = {255,255,255,255}, 
	border_width  = 4,
	border_color  = {255,255,255,80}, --"FFFFFFC0", 
	fill_color  = {25,25,25,80},
	padding_x = 0,
	padding_y = 0,
	border_corner_radius = 22,
	fade_duration = 2000,
	on_screen_duration = 5000,
	icon = "lib/assets/toast-icon.jpg", 
	ui_position = {800,600,0},
    }


 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local tb_group = Group {
    	  name = "toastAlert",  
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "ToastAlert"} 
     }

    local tb_group_cur_y = 10
    local tb_group_cur_x = 20
    local tb_group_timer = Timer()
    local tb_group_timeline = Timeline ()
    

    local create_toastBox = function()

    	local t_box, icon, title, message, t_box_img, key

    	tb_group:clear()
        tb_group.size = { p.ui_width , p.ui_height}

		if p.skin == "Custom" then 
			key = string.format("toast:%d:%d:%d:%s:%s:%d:%d:%d", p.ui_width, p.ui_height, p.border_width, color_to_string( p.border_color ),color_to_string( p.fill_color ), p.padding_x, p.padding_y, p.border_corner_radius)

    		t_box = assets(key, my_make_toastb_group_bg, p.ui_width, p.ui_height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_corner_radius) 

    		t_box:set{name="t_box"}
			tb_group.anchor_point = {p.ui_width/2, p.ui_height/2}

			t_box.y = t_box.y -30
    		tb_group:add(t_box)
		else 
    	     t_box_img = assets(skin_list[p.skin]["toast"])
    	     t_box_img:set{name="t_box_img", size = { p.ui_width , p.ui_height } , opacity = 255}
    		 tb_group:add(t_box_img)
		end 

		icon = assets(p.icon)
    	icon:set{size = {150, 150}, name = "icon", position  = {tb_group_cur_x/2, -80}} --30,30

    	title= Text{text = p.title, font= p.title_font, color = p.title_color}     
    	title:set{name = "title", position = { icon.w + icon.x + 20 , tb_group_cur_y }}  --,50

    	message= Text{text = p.message, font= p.message_font, color = p.message_color, wrap = true, wrap_mode = "CHAR"}     
    	message:set{name = "message", position = {icon.w  + icon.x + 20 , title.h + tb_group_cur_y }, size = {p.ui_width - 150 , p.ui_height - 150 }  } 

    	tb_group:add(icon, title, message)
     end 

     create_toastBox()

	 if editor_lb == nil then 
	 	tb_group:hide()
	 end 
       
     tb_group_timer.interval = p.on_screen_duration 
     tb_group_timeline.duration = p.fade_duration
     tb_group_timeline.direction = "FORWARD"
     tb_group_timeline.loop = false

	 local my_alpha = Alpha{timeline=tb_group_timeline,mode="EASE_OUT_SINE"}
	 local opacity_interval = Interval(255, 0)
	 local scale_interval = Interval(1,0.8)
	 
     function tb_group_timeline.on_new_frame(t, m)
		tb_group.opacity = opacity_interval:get_value(my_alpha.alpha)
		tb_group.scale = {scale_interval:get_value(my_alpha.alpha),scale_interval:get_value(my_alpha.alpha)}
     end  

     function tb_group_timeline.on_completed()
		tb_group.scale = {1.0, 1.0} 
		tb_group.opacity = 255
		tb_group:hide()
     end 

     function tb_group_timer.on_timer(tb_group_timer)
		tb_group_timeline:start()
        tb_group_timer:stop()
     end 

     function tb_group.extra.popup() 
	 	tb_group:show()
		tb_group_timer:start()
     end 
    
     mt = {}
     mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_toastBox()
		end
     end 

     mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
        else 
	    return p[k]
        end 
     end 
 
     setmetatable (tb_group.extra, mt) 

     return tb_group
end

--]]