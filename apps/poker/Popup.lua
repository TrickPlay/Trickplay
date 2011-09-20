local print = function() end

Popup = {}

-- Default black bar with white text
local function defaultMessage(args)

	if not args.text then args.text = "A popup" end

	local background = Rectangle{w=screen.w, h=200, color="000000"}
	local text = Text {font = "Sans 100px", text = args.text, color = "FFFFFF", position = {screen.w/2, 100} }
	text.anchor_point = {text.w/2, text.h/2}
	local group = Group{z=5, opacity = 50, y = screen.h/2 - 100, children={ background, text }}
	
	return group

end

-- Create a new popup

-- First the popup will render
-- self.fade defaults to "in" so the popup will animate using the animate_in table
-- The on_fade_in callback is called
-- Then a timer is started
-- On timer, self.fade is set to "out" and render is called again
-- self.fade is now set to "out" so the popup will animate using the animate_out table
-- The on_fade_out callback is called
-- Popup is removed from its parent and should be garbage collected if there is external reference

function Popup:new(args)
	assert(args, "Popup created with no arguments!")

	local animate_in = args.animate_in or {opacity = 220}
	local animate_out = args.animate_out or {opacity = 0}
     
    local object = {
        fade = args.fade or "in",
        group = args.group or defaultMessage(args),
	
	    -- Time on screen
        time = args.time or 3000,
	
    	-- Animation tables
	    animate_in = animate_in,
    	animate_out = animate_out
    }
        
	-- Various parameters
    -- if not object.group.parent then screen:add(object.group) end
    if not args.keepDown and object.group.parent then object.group:raise_to_top() end
	
	-- Callbacks
	if args.on_fade_in then object.on_fade_in = args.on_fade_in end
    if args.on_fade_out then object.on_fade_out = args.on_fade_out end

    setmetatable(object, self)
    self.__index = self
	
	if not args.noRender then object:render() end
        
	if args.loop then
		object.on_fade_in = function()
			object.fade = "out"
			object:render()
		end
		
		object.on_fade_out = function()
			if not object.stop then
			   object.fade = "in"
			   object:render()
			end
		end
	end
	
    print("Created Popup")
        
    return object
        
end

function Popup:render()
    if self.fade == "in" then
	    print("Animating in")
            
	    -- On completed function
        self.animate_in.on_completed = function()
            pcall(self.on_fade_in, self)
        end
        if not self.animate_in.duration then self.animate_in.duration = 300 end
        
        self.group:animate( self.animate_in )  
        self.fade = "out"
        return
    elseif self.fade == "out" then
        print("Animating out")
        
        -- On completed function
        self.animate_out.on_completed = function()
            pcall(self.on_fade_out, self)
        end
        if not self.animate_out.duration then self.animate_out.duration = 300 end
        
        self.group:animate( self.animate_out )  
        self.fade = nil
        return
    end
end

function Popup:setTimer()

    self.timer = Timer()
    self.timer.interval = self.time
    
    self.timer.on_timer = function()
	
    	print("Time's up!")
	
        self:render()
    	self.timer:stop()
        self.timer.on_timer = nil
        self.timer = nil
            
    end
    
    self.timer:start()

end

function Popup:on_fade_in()

	print("on_fade_in called")
	
	self:setTimer()

end

function Popup:on_fade_out()

	print("on_fade_out called")
        
    self.group:dealloc()
	
	self = nil

end

function Popup:start_loop()

	self.stop = nil
	self.fade = "in"
	self:render()
	
end

function Popup:pause_loop()

	self.stop = true
	
end
