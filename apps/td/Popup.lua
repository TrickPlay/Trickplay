local print = function() end

Popup = {}

function Popup:new(args)
     
        local wingroup
        local winbox
        local wintext
        
        if not args.group then
                
                wingroup = Group{z=5, opacity = 50}
                winbox = Rectangle{w=screen.w, h=200, color="000000"}
                wintext = Text {font = "Sans 100px", text = args.text, color = "FFFFFF"}
                wintext.anchor_point = {wintext.w/2, wintext.h/2}
                wintext.position = {screen.w/2, 100}
                wingroup.y = screen.h/2 - 100
              
                wingroup:add(winbox, wintext)
                
        end
     
        local object = {
                fade = args.fade or "in",
                group = args.group or wingroup,
                background = winbox or nil,
                text = wintext or nil,
                time = args.time or 3,
                fadeSpeed = args.fadeSpeed or 200,
                opacity = args.opacity or 220,
                draw = args.draw or nil,
        }
        
        screen:add(object.group)
      
        if game then table.insert(game.popups, object) end

        if args.on_fade_in then object.on_fade_in = args.on_fade_in end
        if args.on_fade_out then object.on_fade_out = args.on_fade_out end

        setmetatable(object, self)
        self.__index = self
        
        print("Created Popup")
        
        return object
        
end

function Popup:render(seconds)

        if self.fade == "in" then
                        
                local limit = self.opacity
                
                if self.draw then
                        
                        --print("Animating popup")
                
                        self.group:animate{opacity = limit, duration = self.fadeSpeed, on_completed = function() pcall(self.on_fade_in_callback, self) end}  
                        self.fade = "out"
                        return
                
                elseif self.group.opacity <= limit then    
                        local new = self.group.opacity + self.fadeSpeed * seconds
                        
                        --print(new, self.group.opacity)
                        if new > limit then
                                self.group.opacity = limit
                        else
                                self.group.opacity = new
                                if self.group.opacity == limit
                                        then self.fade = nil
                                end
                                
                                pcall(self.on_fade_in_callback, self)
                        end
                end
        
        elseif self.fade == "out" then
        
                --print("Fading out")
        
                if self.draw then
                        self.group:animate{opacity = 0, duration = self.fadeSpeed, on_completed = function() pcall(self.on_fade_out_callback, self) end}  
                        self.fade = nil
                        return
                        
                else
                        local new = self.group.opacity - self.fadeSpeed * seconds
                        if new > 0 then
                                self.group.opacity = new
                        else
                                self.group.opacity = 0
                                self.fade = nil
                                pcall(self.on_fade_out_callback, self)
                        end
                end
        end
        
        pcall( self.checkStopwatch, self )
end

function Popup:setStopwatch()

        self.timer = Stopwatch()
        self.timer:start()

end

function Popup:setTimer()

        self.timer = Timer()
        self.timer.interval = self.time
        
        self.timer.on_timer = function()
                self:render()
                self.timer.on_timer = nil
        end
        
        self.timer:start()

end

function Popup:checkStopwatch()

        if self.timer.elapsed_seconds > self.time then
        
                self.fade = "out"
                self.timer = nil
        
        end

end

function Popup:on_fade_in_callback()
        
        if self.on_fade_in then
                
                self.on_fade_in()
                
        else
                
                if self.draw then
                        
                        self:setTimer()
                        
                else
                
                        --print("Created stopwatch")
                        
                        self:setStopwatch()
                        
                end
                
        end

end

function Popup:on_fade_out_callback()

        if self.on_fade_out then
                
                print("Called self.on_fade_out")
                self.on_fade_out()
                
        end
        
        print("Removing")
        
        if self.group.parent then
                screen:remove(self.group)
                print("Removed popup from screen")
        end
        
        --if game then table.remove(game.popups, self) end
        
        self = nil        

end

function createRedArrow()

        if not game.board.redArrow then
                
                print("created red arrow")
                
                game.board.redArrow = true
                
                local a = AssetLoader:getImage( "RedArrow",{x = 200, y = screen.h/2, opacity = 0} )
                a.anchor_point = {a.w/2, a.h/2}
                
                Popup:new{
                        group = a,
                        time = 2,
                        opacity = 150,
                        on_fade_out = function()
                                screen:remove(a)
                                game.board.redArrow = nil
                        end
                }
                
        end

end

function endGamePopup(status, text)

        keyboard_key_down = nil
        ipod_k = {}

        paused = true
        
        for k,v in pairs(game.popups) do
                v.group.opacity = 0
        end

        local a = Popup:new{
                text = text,
                time = 4,
                fadeSpeed = 500,
                draw = true,
                on_fade_out = function()
                        
                        print("Calling the kill function")
                        
                        screen:remove(a)
                        a = nil
                        
                        game:killGame(status)
                  
                end
        }

end
