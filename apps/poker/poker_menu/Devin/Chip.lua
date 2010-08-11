-- A chip
Chip = Class(function(self, value, image, ...)

        self.value = value
        self.image = image
        
        --self.image.x = 600
       
end)

-- A stack of chips!
chipStack = Class(function(self, ...)

        self.chips = {}
        self.group = Group{}
        self.chipValue = 0
        self.value = 0
        self.size = 0
        
        
end)

-- A collection of stacks
chipCollection = Class(function(self, ...)

        self.value = 0
        
        function self:value() return self.value end -- Return the value of all stacks
        function self:size() return #self.stacks end -- Returns the number of stacks in the collection

        self.group = Group{}
        screen:add(self.group)
        
        self.stacks = {}
        
        function self:addStack(newStack)
                self.stacks[#self.stacks + 1] = newStack
                self.group:add(self.newStack.group)
        end
        
        function self:set(value)
        
        end
        
        function self:sort()
        
                local stackSort = function(first, second)
                        if first.value > second.value then
                                return true
                        end
                end
                
                for i=1,self:size() do
                        self.group:remove(self.stacks[i].group)
                end
                
                table.sort(self.stacks, stackSort)
                
                for i=1,self:size() do
                        self.group:add(self.stacks[i].group)
                end
                
        end
        
        function self:getStack(chipValue)
                for k, v in ipairs(self.stacks) do
                        if v.chipValue == chipValue then
                                return v
                        end
                end
        end
        
end)