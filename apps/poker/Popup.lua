local print = function() end

Popup = {}

function Popup:new(args)

     	-- Default black bar with white text
        local group
        local background
        local text
        if not args.group then
                background = Rectangle{w=screen.w, h=200, color="000000"}
		if not args.text then args.text = "A popup" end
                text = Text {font = "Sans 100px", text = args.text, color = "FFFFFF", position = {screen.w/2, 100} }
                text.anchor_point = {text.w/2, text.h/2}
		group = Group{z=5, opacity = 50, y = screen.h/2 - 100, children={ background, text }}
        end
     
        local object = {
                fade = args.fade or "in",
                group = args.group or group,
                background = background or nil,
                text = text or nil,
                time = args.time or 3,
                fadeSpeed = args.fadeSpeed or 200,
                opacity = args.opacity or 220,
                draw = args.draw or nil,
        }
        
	-- Various parameters
        if not args.startOpaque then object.group.opacity = 0 end
        if not object.group.parent then screen:add(object.group) end
        if args.on_fade_in then object.on_fade_in = args.on_fade_in end
        if args.on_fade_out then object.on_fade_out = args.on_fade_out end
        if not args.keepDown then object.group:raise_to_top() end

        setmetatable(object, self)
        self.__index = self
        
        print("Created Popup")
        
        return object
        
end

function Popup:render(seconds)

        if self.fade == "in" then
                
		self.group:animate{opacity = self.opacity, duration = self.fadeSpeed, on_completed = function() pcall(self.on_fade_in, self) end}  
		self.fade = "out"
		return
		
        elseif self.fade == "out" then
		
		self.group:animate{opacity = 0, duration = self.fadeSpeed, on_completed = function() pcall(self.on_fade_out, self) end}  
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
        
        if self.group.parent then
        
                self.group.parent:remove(self.group)
                
                print("Removed popup from parent container")
        end
        
        self = nil        

end





