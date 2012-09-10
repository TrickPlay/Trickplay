TOASTALERT = true

default_parameters = {
    title = "ToastAlert", 
    message_font="Sans 40px",
    message_color = "ffffff",
    vertical_message_padding   =   10,
    horizontal_message_padding =    5,
    horizontal_icon_padding    =   20,
    vertical_icon_padding      =   10,
    on_screen_duration         = 5000,
    animate_in_duration        =  500,
    animate_out_duration       =  500,
}



ToastAlert = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            return self:declare():set(p or {})
            
        end,
        
        subscriptions = {
        },
        public = {
            properties = {
            
                widget_type = function(instance,env)
                    return function() return "ToastAlert" end, nil
                end,
                icon = function(instance,env)
                    return function(oldf,...) return env.icon     end,
                    function(oldf,self,v) 
                        
                        if env.icon then env.icon:unparent() end
                        
                        if v == nil then
                            
                            env.icon = Text{text="!",color = instance.style.border.colors.default,font = "Sans 60px"}
                            
                        elseif type(v) == "string" then
                            
                            env.icon = Image{ src = v }
                            
                            if env.icon == nil then
                                
                                error("ToastAlert.icon recieved string but it was not a valid image uri",2)
                                
                            end
                            
                        elseif type(v) == "userdata" and v.__types__.actor then
                            
                            env.icon = v
                            
                        else
                            
                            error("ToastAlert.icon expected string uri or UIElement. Received "..type(v),2)
                            
                        end
                        
                        instance:add(env.icon)
                    end
                end,
                message = function(instance,env)
                    return function(oldf,...) return env.message.text     end,
                    function(oldf,self,v)            env.message.text = v end
                end,
                message_color = function(instance,env)
                    return function(oldf,...) return env.message.color     end,
                    function(oldf,self,v) print(v)   env.message.color = v end
                end,
                message_font = function(instance,env)
                    return function(oldf,...) return env.message.font     end,
                    function(oldf,self,v)            env.message.font = v end
                end,
                horizontal_message_padding = function(instance,env)
                    return function(oldf,...) return env.horizontal_message_padding     end,
                    function(oldf,self,v)            env.horizontal_message_padding = v end
                end,
                vertical_message_padding = function(instance,env)
                    return function(oldf,...) return env.vertical_message_padding     end,
                    function(oldf,self,v)            env.vertical_message_padding = v end
                end,
                horizontal_icon_padding = function(instance,env)
                    return function(oldf,...) return env.horizontal_icon_padding     end,
                    function(oldf,self,v)            env.horizontal_icon_padding = v end
                end,
                vertical_icon_padding = function(instance,env)
                    return function(oldf,...) return env.vertical_icon_padding     end,
                    function(oldf,self,v)            env.vertical_icon_padding = v end
                end,
                on_completed = function(instance,env)
                    return function(oldf,...) return env.on_completed     end,
                    function(oldf,self,v)            env.on_completed = v end
                end,
                on_screen_duration = function(instance,env)
                    return function(oldf,...) return env.on_screen_duration     end,
                    function(oldf,self,v)            env.on_screen_duration = v end
                end,
                animate_in_duration = function(instance,env)
                    return function(oldf,...) return env.animate_in_duration     end,
                    function(oldf,self,v)            env.animate_in_duration = v end
                end,
                animate_out_duration = function(instance,env)
                    return function(oldf,...) return env.animate_out_duration     end,
                    function(oldf,self,v)            env.animate_out_duration = v end
                end,
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.children = nil
                        
                        t.message                    = instance.message
                        t.message_font               = instance.message_font
                        t.message_color              = instance.message_color
                        t.horizontal_message_padding = instance.horizontal_message_padding
                        t.vertical_message_padding   = instance.vertical_message_padding
                        t.horizontal_icon_padding    = instance.horizontal_icon_padding
                        t.vertical_icon_padding      = instance.vertical_icon_padding
                        t.on_screen_duration         = instance.on_screen_duration
                        t.animate_in_duration        = instance.animate_in_duration
                        t.animate_out_duration       = instance.animate_out_duration
                        
                        
                        t.icon = env.icon and env.icon.src
                        t.type = "ToastAlert"
                        
                        return t
                    end
                end,
                
    
            },
            functions = {
                popup    = function(instance,env) 
                    return function(oldf,self,...) 
                        
                        if env.animating then return end
                        
                        if instance.parent then instance:unparent() end
                        
                        screen:add(instance)
                        
                        instance.opacity = 0
                        
                        instance.y = screen.h + instance.anchor_point[2]
                        
                        instance:animate{
                            duration = env.animate_in_duration,
                            y        = 50 + instance.anchor_point[2],
                            opacity  = 255,
                            on_completed = function()
                                
                                dolater(
                                    env.on_screen_duration,
                                    function()
                                        
                                        instance:animate{
                                            duration = env.animate_out_duration,
                                            opacity  = 0,
                                            on_completed = function()
                                                
                                                env.animating = false
                                                
                                                if env.on_completed then env.on_completed(instance) end
                                                
                                            end
                                        }
                                        
                                    end
                                )
                                
                            end
                        }
                    end 
                end,
                
                
            },
        },
        
        
        private = {
        
            subscribe_to_sub_styles = function(instance,env)
                return function()
                    instance.style.border:subscribe_to( nil, function()
                        if env.canvas then 
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                    instance.style.fill_colors:subscribe_to( nil, function()
                        if env.canvas then 
                            env.flag_for_redraw = true 
                            env.call_update()
                        end
                    end )
                    instance.style.text.colors:subscribe_to( nil, function()
                        env.redraw_title = true
                        env.call_update()
                    end )
                    instance.style.text:subscribe_to( nil, function()
                        env.redraw_title = true
                        env.call_update()
                    end )
                    instance.style:subscribe_to( nil, function()
                            
                        if env.canvas then 
                            env.flag_for_redraw = true 
                        end
                        env.redraw_title = true
                        env.call_update()
                        
                    end )
                    
                end
            end,
            ---[[
            update = function(instance,env)
                return function()
                    
                    env.old_update()
                    
                    --reposition icon
                    env.icon.x = env.horizontal_icon_padding 
                    env.icon.y = env.vertical_icon_padding
            
                    --resize icon
                    if (env.icon.y + env.icon.h + env.vertical_icon_padding) > 
                        (instance.h  - instance.separator_y)  then
				
                        env.icon.scale = (env.icon.h - (env.icon.y + env.icon.h + 
                            env.vertical_icon_padding - (instance.h  - instance.separator_y) )) / env.icon.h
				
                    end
                    --reposition message
                    env.message.x = env.icon.x + env.icon.w + env.horizontal_icon_padding + env.horizontal_message_padding
                    env.message.y = env.vertical_message_padding
			
                    --resize message
                    env.message.w = instance.w - env.message.x - env.horizontal_message_padding
                    env.message.h = instance.h - instance.separator_y - env.vertical_message_padding*2
                end
            end,
            --]]
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = DialogBox:declare()
            local getter, setter
            
            env.old_update = env.update
            env.vertical_message_padding   = 10
            env.horizontal_message_padding = 5
            env.horizontal_icon_padding = 20
            env.vertical_icon_padding = 10
            env.message = Text{
                wrap=true,
            }
            instance:add(env.message)
            env.icon = nil
            env.on_completed = function() end
            env.on_screen_duration = 5000
            env.animate_in_duration = 500
            env.animate_out_duration = 500
            env.message_color = "ffffff"
            env.message_font="Sans 40px"
            env.animating = false
            
            
            
            
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            --[[
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            
            env.updating = true
            instance.icon          = parameters.icon
            print("DURP")
            instance.message_color = env.message_color
            instance.message_font  = env.message_font
            env.updating = false
            
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)

--[=[

ToastAlert = function(parameters)
	
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ToastAlert",parameters)
	
	--flags
	local canvas          = type(parameters.images) == "nil"
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = DialogBox( parameters )
	local vertical_message_padding   = 0
	local horizontal_message_padding = 0
	local horizontal_icon_padding = 5
	local vertical_icon_padding = 5
	local message = Text{
		wrap=true,
	}
	instance:add(message)
	local icon, on_completed, on_screen_duration, animate_in_duration, animate_out_duration
	
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
	override_property(instance,"widget_type",
		function() return "ToastAlert" end, nil
	)
    
	override_property(instance,"icon",
		
		function(oldf)    return icon   end,
		
		function(oldf,self,v)
			
			if v == nil then
				
				icon = Text{text="!",color = instance.style.border.colors.default,font = "Sans 60px"}
				
			elseif type(v) == "string" then
				
				icon = Image{ src = v }
				
				if icon == nil then
					
					error("ToastAlert.icon recieved string but it was not a valid image uri",2)
					
				end
				
			elseif type(v) == "userdata" and v.__types__.actor then
				
				icon = v
				
			else
				
				error("ToastAlert.icon expected string uri or UIElement. Received "..type(v),2)
				
			end
			
			instance:add(icon)
		end
	)
	override_property(instance,"message",
		function(oldf) return   message.text     end,
		function(oldf,self,v)   message.text = v end
	)
	override_property(instance,"message_color",
		function(oldf) return   message.color     end,
		function(oldf,self,v)   message.color = v end
	)
	override_property(instance,"message_font",
		function(oldf) return   message.font     end,
		function(oldf,self,v)   message.font = v end
	)
	override_property(instance,"horizontal_message_padding",
		function(oldf) return   horizontal_message_padding     end,
		function(oldf,self,v)   horizontal_message_padding = v end
	)
	override_property(instance,"vertical_message_padding",
		function(oldf) return   vertical_message_padding     end,
		function(oldf,self,v)   vertical_message_padding = v end
	)
	override_property(instance,"horizontal_icon_padding",
		function(oldf) return   horizontal_icon_padding     end,
		function(oldf,self,v)   horizontal_icon_padding = v end
	)
	override_property(instance,"vertical_icon_padding",
		function(oldf) return   vertical_icon_padding     end,
		function(oldf,self,v)   vertical_icon_padding = v end
	)
	override_property(instance,"on_completed",
		function(oldf) return   on_completed     end,
		function(oldf,self,v)   on_completed = v end
	)
	override_property(instance,"on_screen_duration",
		function(oldf) return   on_screen_duration     end,
		function(oldf,self,v)   on_screen_duration = v end
	)
	override_property(instance,"animate_in_duration",
		function(oldf) return   animate_in_duration     end,
		function(oldf,self,v)   animate_in_duration = v end
	)
	override_property(instance,"animate_out_duration",
		function(oldf) return   animate_out_duration     end,
		function(oldf,self,v)   animate_out_duration = v end
	)
    
    ----------------------------------------------------------------------------
	
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
                
            t.content = nil
            
            t.message                    = self.message
            t.message_font               = self.message_font
            t.message_color              = self.message_color
            t.horizontal_message_padding = self.horizontal_message_padding
            t.vertical_message_padding   = self.vertical_message_padding
            t.horizontal_icon_padding    = self.horizontal_icon_padding
            t.vertical_icon_padding      = self.vertical_icon_padding
            t.on_screen_duration         = self.on_screen_duration
            t.animate_in_duration        = self.animate_in_duration
            t.animate_out_duration       = self.animate_out_duration
            
            
            t.icon = icon.src
            t.type = "ToastAlert"
            
            return t
        end
    )
    
    ----------------------------------------------------------------------------
	
    local animating = false
	override_function(instance,"popup",
		function(oldf,self,v) 
            
            if animating then return end
            
            if instance.parent then instance:unparent() end
            
            screen:add(instance)
            
            instance.opacity = 0
            
            instance.y = screen.h + instance.anchor_point[2]
            
            instance:animate{
                duration = animate_in_duration,
                y        = 50 + instance.anchor_point[2],
                opacity  = 255,
                on_completed = function()
                    
                    dolater(
                        on_screen_duration,
                        function()
                            
                            instance:animate{
                                duration = animate_out_duration,
                                opacity  = 0,
                                on_completed = function()
                                    
                                    animating = false
                                    
                                    if on_completed then on_completed(instance) end
                                    
                                end
                            }
                            
                        end
                    )
                    
                end
            }
            
        end
	)
	
	instance:subscribe_to(
		{
            "h","w","width","height","size","separator_y","icon",
            "horizontal_message_padding","vertical_message_padding",
            "horizontal_icon_padding","vertical_icon_padding"
        },
		function()
			
			--reposition icon
			icon.x = horizontal_icon_padding 
			icon.y = vertical_icon_padding
			
			--resize icon
			--icon.w = instance.w - message.x - message_padding
			--icon.h = instance.h - instance.separator_y - message_padding
			if (icon.y + icon.h + vertical_icon_padding) > (instance.h  - instance.separator_y)  then
				
				icon.scale = (icon.h - (icon.y + icon.h + vertical_icon_padding - (instance.h  - instance.separator_y) )) / icon.h
				
			end
            
			--reposition message
			message.x = icon.x + icon.w + horizontal_icon_padding + horizontal_message_padding
			message.y = vertical_message_padding
			
			--resize message
			message.w = instance.w - message.x - horizontal_message_padding
			message.h = instance.h - instance.separator_y - vertical_message_padding*2
			
		end
	)
	
	if parameters.icon == nil then instance.icon = nil end
	
	instance:set(parameters)
	
	return instance
	
end

--]=]








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