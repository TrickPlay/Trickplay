local mouse = Image{src="assets/cursor.png"}

mouse.to_mouse = {}
mouse.to_keys  = {}
mouse:hide()
local sw = Stopwatch()

sw:start()

local prev_on_motion = {x=nil,y=nil,t=nil}

local vys = {}
local avy = 0

local hold = false

local t = nil

screen.reactive = true

controllers:start_pointer()

local first_time = true

function screen:on_motion(x,y)
    
	if using_keys then
		
		if first_time then
			first_time = false
			CONTOLLER_PROMPT:display_controller()
		end
		
		mouse:show()
		
		for f,o in pairs(mouse.to_mouse) do f(o) end
		
		using_keys = false
		
	end
	
	mouse.x = x
    
    mouse.y = y
	
    if hold then
        
        t = sw.elapsed
        
        if prev_on_motion.t ~= nil then
            
            table.insert(vys,(y - prev_on_motion.y)/((t-prev_on_motion.t)/1000))
            
            if #vys > 5 then table.remove(vys,1) end
            
        end
        
        prev_on_motion.x = x
        prev_on_motion.y = y
        prev_on_motion.t = t
        
    end
    
end

function screen:on_button_down(x,y)
    
	if using_keys then
		
		if first_time then
			first_time = false
			CONTOLLER_PROMPT:display_controller()
		end
		
		mouse:show()
		
		for f,o in pairs(mouse.to_mouse) do f(o) end
		
		using_keys = false
		
	end
	
    hold = true
    
    vys = {}
    
end

function screen:on_button_up(x,y)

	if not hold then return end
	
    hold = false
    
    avy = 0
    
    for _,v in ipairs(vys) do avy = avy+v end
    
    if #vys ~= 0 then avy = avy/#vys end
    
    if App_State.rolodex then
		if avy < -1000 then
			
			KEY_HANDLER:key_press(keys.Up)
			
		elseif avy > 1000 then
			
			KEY_HANDLER:key_press(keys.Down)
			
		end
	end
    
end

return mouse