PlayerStatusView = Class(View, function(self, model, args, player,...)
        
        -- Register view
        self._base.init(self,model)
        
        -- Show player info
        self.player = player
        self.show = true
        
        local color
        if player.isHuman then
                color = "Green"
        else
                color = "Gray"
        end
        
        self.background = AssetLoader:getImage("BubbleHeader"..color,{y = -30})

        
        self.text_bubble = AssetLoader:getImage("BubbleNone",{})
        self.group = Group{ children={self.background, self.text_bubble}, opacity=0, position = player.position }
        
        -- Player text
        self.title = Text{ font = PLAYER_NAME_FONT, color = Colors.SLATE_GRAY, text = "Player "..player.number}
        self.title.position = {self.title.w/2 + 50, self.title.h/2 - 5}
        self.action = Text{ font = PLAYER_ACTION_FONT, color = Colors.BLACK, text = "Sup dawg"}
        self.action.position = {165, 50}
        
        -- Align player attributes
        self.attributes = { self.title, self.action }
        
        for i,v in ipairs(self.attributes) do
                v.anchor_point = {v.w/2, v.h/2}
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
                self.title.text = "Player "..player.number.."   Money: $"..self.player.money
        end

end)
