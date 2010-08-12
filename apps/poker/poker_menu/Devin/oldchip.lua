-- A chip
Chip = Class(function(self, value, image, ...)

        self.value = value
        self.image = image
        
        --self.image.x = 600
       
end)

-- A stack of chips!
chipStack = Class(function(self, ...)

        -- Should probably be more like
        --[[
        self.types = {
                {value = 10, lastAdded = 34, count = 7}
                {value = 100, lastAdded = 27, count = 10}
                {value = 1000, lastAdded = 17, count = 9}
                {value = 10000, lastAdded = 8, count = 8}
        }
        ]]


        self.chips = {}
        self.types = {
                [10] = 0,
                [100] = 0,
                [1000] = 0,
                [10000] = 0,
                [100000] = 0,
                [1000000] = 0,
        }
        self.lookup = {10, 100, 1000, 10000, 100000, 1000000}
        self.group = Group{}
        
        function self:setChips(value)
                local biggest = self.lookup[#self.lookup]
                local sum = 0
                
                if value > self:count() then
                        -- While there are more chips to add
                        while value > self:count() do
                        
                                -- Get the biggest possible chip
                                while biggest > value do
                                        biggest = biggest/10
                                end
                                
                                self:pushChip( Chip(biggest, Image{src = "pokerchip"..biggest..".png"}) )
                                
                                value = value - biggest
                        end
                elseif value < self:count() then
                        while value < self:count() do
                        
                                -- Get the biggest possible chip
                                while self:count() - biggest < value do
                                        biggest = biggest/10
                                end
                                
                                self:removeChip(nil, 0)
                                
                                value = value + biggest
                        end
                end
        end
        
        -- Push a chip onto the stack
        function self:pushChip(chip)
                --print("Pushing chip!")
                local size = #self.chips
                self.group:add(chip.image)
                self.chips[size + 1] = chip
                self.types[chip.value] = self.types[chip.value] + 1
                --print("Complete")
        end
        
        -- Pop a chip from the stack
        function self:popChip(newStack)
                local c
                local size = #self.chips
                
                self.group:remove(self.chips[size].image)
                self.types[self.chips[size].value] = self.types[self.chips[size].value] - 1
                
                c = self.chips[size]
                
                --[[if newStack then
                        c.image.position = {
                                c.image.position[1] + ( newStack.group.position[1] - self.group.position[1] ),
                                c.image.position[2] + ( newStack.group.position[2] - self.group.position[2] ),
                        }
                        newStack:pushChip(c)
                        print(c.image.position[1], c.image.position[2])
                end]]
                
                self.chips[size] = nil
                
                return c
        end
        
        function self:removeChip(chip, specificChip)
                
                local size = self:getSize()
                local found = false
                local start = 1
                
                if specificChip then
                        self.group:remove(self.chips[specificChip])
                        self.chips[specificChip] = nil
                        found = true
                end
                
                for i=start, size do

                        if not found and chip == self.chips[i] then
                                self.group:remove(chip.image)
                                self.chips[i] = nil
                                found = true
                        elseif found then
                                self.chips[i-1] = self.chips[i]
                        end
                end
                
                if found then
                        self.chips[size] = nil
                        return true
                end
        end
        
        -- Count the chips in the stack
        function self:count()
                --print("Counting")
                local total = 0
                for k,v in ipairs(self.chips) do
                        total = total + v.value
                end
                return total
        end
        
        function self:getSize()
                return #self.chips
        end
        
        function self:arrangeChips(dy, dx)
                local add = 0
                local addx = 0
                local num = 0
                for i=1, self:getSize() do
                
                        if dx and i > 1 and self.chips[i].value < self.chips[i-1].value then
                                --print("New x", addx)
                                add = 0
                                addx = addx + dx
                        end
                
                        self.chips[i].image.position = {addx, add}
                        
                        --self.chips[i].image:animate{duration=1000, x=addx, y=add}
                        
                        add = add - dy
                        
                        num = num + 1
                        --print(num, self.chips[i].value)
                end
        end
        
        function self:sortChips()
                local chipSort = function(first, second)
                        if first.value > second.value then
                                return true
                        end
                end
                
                for i=1,self:getSize() do
                        self.group:remove(self.chips[i].image)
                end
                
                table.sort(self.chips, chipSort)
                
                for i=1,self:getSize() do
                        self.group:add(self.chips[i].image)
                end
        end
        
        function self:convertUp()
                
                local num = 1
                
                while num <= #self.lookup do
                        
                        local c = self.lookup[num]
                        
                        if self.types[c] >= 10 then
                                for i=1,10 do
                                        self:popChip()
                                end
                                self:pushChip( Chip(c*10, Image{src = "pokerchip"..(c*10)..".png"}) )
                        end
                        
                        num = num + 1
                        
                end
                
        end
        
        function self:convertDown(value)
                local success = false
                if self.types[value] == 0 then
                        while not success do
                                if self.types[value*10] > 0 then
                                        self:popChip()
                                        for i=1,10 do
                                                self:pushChip( Chip(value, Image{src = "pokerchip"..value..".png"}) )
                                        end
                                        success = true
                                else
                                        self:convertDown(value*10)
                                end
                        end
                end
        
        end
        
        function self:merge(other)
                
                for i=1, other:getSize() do
                        self:pushChip(other.chips[#other.chips])
                        other:popChip()
                end
                
        end

end)

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
        
        function self:sort()
        
                local stackSort = function(first, second)
                        if first.value > second.value then
                                return true
                        end
                end
                
                for i=1,self:size() do
                        self.group:remove(self.stacks[i].group)
                end
                
                table.sort(self.chips, chipSort)
                
                for i=1,self:getSize() do
                        self.group:add(self.chips[i].image)
                end
                
        end
        
end)