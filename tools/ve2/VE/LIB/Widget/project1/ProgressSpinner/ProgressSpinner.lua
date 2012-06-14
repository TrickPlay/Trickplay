
local canvas_dot = function(instance)
	
	local c = Canvas(instance.w,instance.h)
	
	canvas:arc( instance.w/2, instance.h/2, instance.w/2, 0, 360 )
	
	return c:Image()
	
end

ProgressSpinner = function(parameters)
	
	parameters = is_table_or_nil("ProgressSpinner",parameters)
	
	local duration
	local dot_img
end

--[[
Function: Progress Spinner

Creates a Loading dots ui element

Arguments:
	Table of Loading dots box properties
		dot_diameter - Radius of the individual dots
		dot_color - Color of the individual dots
		number_of_dots - Number of dots in the loading circle
		overall_diameter - Radius of the circle of dots
		cycle_time - Millisecs spent on a dot, this number times the number of dots is the time for the animation to make a full circle

Return:

	loading_dots_group - Group containing the loading dots
    
Extra Function:
	speed_up() - spin faster
	speed_down() - spin slower
]]
 
 --[[
function ui_element.progressSpinner(t) 
    --default parameters
    local p = {
        skin          = "Custom",
        dot_diameter    = 10,
        dot_color     = {255,255,255,255},
        number_of_dots      = 12,
        overall_diameter   = 100,
        cycle_time = 150*12,
        style = "orbitting", 
		ui_position = {400,400, 0},
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end

    local create_dots
    
    --the umbrella Group
    local l_dots = Group{ 
        name     = "progressSpinner",
        position = p.ui_position,  
        --anchor_point = {p.overall_diameter/2,p.overall_diameter/2},
        reactive = true,
        extra = {
            type = "ProgressSpinner", 
            speed_up = function()
                p.cycle_time = p.cycle_time - 50
                create_dots()
            end,
            speed_down = function()
                p.cycle_time = p.cycle_time + 50
                create_dots()
            end,
        },
    }
    --table of the dots, used by the animation
    local dots   = {}
    local load_timeline = nil
    local load_timeline

    --function used to remake the dots upon a parameter change
    create_dots = function()

        l_dots:clear()
        dots = {}
        
        if p.style == "orbitting" then
        
        	local rad, key
        
        	for i = 1, p.number_of_dots do
            	--they're radial position
            	rad = (2*math.pi)/(p.number_of_dots) * i
            	if p.skin == "Custom" then -- skin_list[p.skin]["loadingdot"] == nil then
					key = string.format("dot:%d:%s", p.dot_diameter, color_to_string(p.dot_color))
					dots[i] = assets(key, my_make_dot, p.dot_diameter, p.dot_color)
	        	else		        
		        	dots[i] = assets(skin_list[p.skin]["loadingdot"])
                	dots[i].size={p.dot_diameter, p.dot_diameter}
					dots[i].anchor_point = {
                		dots[i].w/2,
                    	dots[i].h/2
                	}
            	end

				dots[i].position = {
                	math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                	math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
            	}

            	l_dots:add(dots[i])		
        	end
        
        	-- the animation timeline
        	if load_timeline ~= nil and load_timeline.is_playing then
            	load_timeline:stop()
            	load_timeline = nil
        	end

        	load_timeline = Timeline
        	{
            	name      = "Loading Animation",
            	loop      =  true,
            	duration  =  p.cycle_time,
            	direction = "FORWARD", 
        	}
	
        	local increment = math.ceil(255/p.number_of_dots)
        
        	function load_timeline.on_new_frame(t)
            	local start_i   = math.ceil(t.elapsed/(p.cycle_time/p.number_of_dots))
            	local curr_i    = nil
            
            	for i = 1, p.number_of_dots do
                	curr_i = (start_i + (i-1))%(p.number_of_dots) +1
                	dots[curr_i].opacity = increment*i
            	end
        	end
        	load_timeline:start()

        else -- spinning 

			local img, key

			if p.skin == "Custom" then 
				key = string.format("big_dot:%d:%s", p.overall_diameter, color_to_string(p.dot_color))
            	img = assets(key, my_make_big_dot, p.overall_diameter, p.dot_color)
            	img.anchor_point={img.w/2,img.h/2}
            	l_dots:add(img)
        	else
            	img = assets(skin_list[p.skin]["loadingdot"])
            	img.anchor_point={img.w/2,img.h/2}
            	l_dots:add(img)
        	end
        	img.position={img.w/2,img.h/2}
        	if load_timeline ~= nil and load_timeline.is_playing then
            	load_timeline:stop()
            	load_timeline = nil
        	end

        	load_timeline = Timeline
        	{
            	name      = "Loading Animation",
            	loop      =  true,
            	duration  =  p.cycle_time,
            	direction = "FORWARD", 
        	}

        	function load_timeline.on_new_frame(t,msces,p)
            	img.z_rotation={360*p,0,0}
        	end
        	load_timeline:start()        	
        end
    end

    create_dots()

    local mt = {}
    mt.__newindex = function(t,k,v)
       p[k] = v
	   if k ~= "selected" then 
       		create_dots()
	   end
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(l_dots.extra, mt)
    return l_dots
end
--]]