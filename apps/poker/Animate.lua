Animation = Class( function(self, dog, frames, position, ...)

        self.timer = Timer()
        self.timer.interval = .1
        self.frameCounter = 0
        
        self.group = Group{position = position}
        
        self.images = {}
        for i=1, frames do
                self.images[i] = AssetLoader:getImage("dog"..dog.."frame"..i, {opacity=0} )
                self.group:add( self.images[i] )
        end
        
        self.timer.on_timer = function()
                -- If there are no frames left, remove the animation
                if self.frameCounter > frames then
                        screen:remove(self.group)
                        self.timer:stop()
                        self.timer = nil
                -- Tick through each frame
                else
                        if self.images[ self.frameCounter-1 ]  then
                                self.images[ self.frameCounter-1 ].opacity = 0
                        end
                        
                        if self.images[ self.frameCounter ] then
                                self.images[ self.frameCounter ].opacity = 255
                        end
                        
                        self.frameCounter = self.frameCounter + 1
                end
        end
        
        screen:add(self.group)
        self.group:raise_to_top()
        
        self.timer.on_timer()
        self.timer:start()

end )