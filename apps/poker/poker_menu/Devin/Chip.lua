-- A chip
Chip = Class(function(self, value, image, ...)

        self.value = value
        self.image = image
        
        self.image.x = 600
       
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
        function self:popChip()
                local size = #self.chips
                self.group:remove(self.chips[size].image)
                self.types[self.chips[size].value] = self.types[self.chips[size].value] - 1
                self.chips[size] = nil
        end
        
        function self:removeChip(chip)
                
                local size = self:getSize()
                
                for i=1, size do
                
                        -- For later..
                        --[[if found then
                                self.chips[i-1] = self.chips[i]
                        end
                
                        if not found and type(chip) == "table" and chip == self.chips[i] then
                                self.group:remove(chip.image)
                                self.chips[i] = nil
                                found = true
                        elseif not found and type(chip) == "number" and chip == self.chips[i].value then
                                self.group:remove(self.chips[i].image)
                                self.chips[i] = nil
                                found = true
                        end]]
                
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
                
                        --self.chips[i].image.position = {addx, add}
                        
                        self.chips[i].image:animate{duration=100, x=addx, y=add}
                        
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

--[[
s = Stack()

for i=1, 3 do
        s:pushChip(Chip(10, Image{src = "pokerchip.png"}))
end


for i=1, 3 do
        s:pushChip(Chip(100, Image{src = "pokerchipdark.png"}))
end

--for i=1, 4 do
        local d = Chip(1000, Image{src = "pokerchip.png"})
        s:pushChip(d)
--end

for i=1, 4 do
        s:pushChip(Chip(10000, Image{src = "pokerchipdark.png"}))
end



screen:add(s.group)
s.group.position = {500,500}
s:sortChips()
s:arrangeChips(15, 150)

s:removeChip(d)
s:sortChips()
s:arrangeChips(15, 150)

c = Stack()

for i=1, 3 do
        c:pushChip(Chip(10, Image{src = "pokerchip.png"}))
end


for i=1, 3 do
        c:pushChip(Chip(100, Image{src = "pokerchipdark.png"}))
end

for i=1, 4 do
        c:pushChip(Chip(1000, Image{src = "pokerchip.png"}))
end

for i=1, 4 do
        c:pushChip(Chip(10000, Image{src = "pokerchipdark.png"}))
end

screen:add(c.group)
c.group.position = {900,500}
c:sortChips()
c:arrangeChips(15)

s:merge(c)
s:sortChips()
s:arrangeChips(15, 150)
]]