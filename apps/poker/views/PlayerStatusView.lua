PlayerStatusView = Class(View, function(self, model, args, player,...)
        
        -- Register view
        self._base.init(self,model)
        
        -- Show player info
        self.player = player
        self.show = true
        self.background = Rectangle{w=250, h=80, color=Colors.TURQUOISE}
        self.group = Group{ children={self.background}, opacity=0, position = player.position }
        
        -- Player text
        self.name = Text{ font = PLAYER_NAME_FONT, color = Colors.BLACK, text = "Player "..player.number }
        self.money = Text{ font = PLAYER_NAME_FONT, color = Colors.BLACK, text = "Money " }
        
        -- Align player attributes
        local spacing = 36
        local dy = 0
        self.attributes = { self.name, self.money }
        
        for i,v in ipairs(self.attributes) do
                v.y = dy
                dy = dy + spacing
                self.group:add(v)
        end

        print(#self.group.children)
        screen:add(self.group)
        
        if args then for k,v in pairs(args) do
                        self[k] = v
                end
        end
        
        function self:initialize()
                if self.show then self.group.opacity = 240 end
        end
    
        function self:update()
                if self.show then self.group.opacity = 240 else self.group.opacity = 0 end
                self.money.text = "Money: "..self.player.money
        end

end)
