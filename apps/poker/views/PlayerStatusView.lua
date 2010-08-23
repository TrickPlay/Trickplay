PlayerStatusView = Class(View,
function(self, model, args, player,...)
   
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
   
   self.top = AssetLoader:getImage("Bubble"..color,{})
   self.bottom = AssetLoader:getImage("BubbleNone",{y = 60})
   
   self.group = Group{ children={self.top, self.bottom}, opacity=0, position = MPBL[player.table_position] }
   
   -- Player text
   self.title = Text{ font = PLAYER_NAME_FONT, color = Colors.WHITE, text = "Player "..player.number}
   self.title.on_text_changed = function()
      self.title.anchor_point = { self.title.w/2, self.title.h/2 }
      self.title.position = { self.top.w/2, self.top.h/2 }
   end

   self.action = Text{ font = PLAYER_ACTION_FONT, color = Colors.BLACK, text = "Sup dawg"}
   self.action.on_text_changed = function()
      self.action.anchor_point = { self.action.w/2, self.action.h/2 }
      self.action.position = { self.bottom.w/2, self.bottom.h/2 + self.bottom.y }
   end
   
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
   
   function self:update(text)
      if self.show then self.group.opacity = 240 else self.group.opacity = 0 end
      self.title.text = "Player "..player.number.."   Money: $"..self.player.money
      
      if text then self.action.text = text end
      self.action.anchor_point = {self.action.w/2, self.action.h/2}
      self.action.position = { self.bottom.w/2, self.bottom.h/2 + self.bottom.y }
   end
   
   function self:dim()
      self.group.opacity = 100
   end
   
   function self:hide()
      self.group:animate{opacity = 0, duration=300}
      self.show = false
   end
   
   function self:display()
      self.group:animate{opacity = 240, duration=300}
      self.show = true
   end
   
end)
