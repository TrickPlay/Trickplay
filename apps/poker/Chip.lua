--local function print() end

-- GLOBALS
CHIP_W = 55
CHIP_H = 5


-- A chip
Chip = Class(function(self, value, image, ...)

        self.value = value
        self.image = image
       
end)

-- A stack of chips!
chipStack = Class(function(self, chipValue, ...)

        self.chips = {}
        self.group = Group{}
        self.chipValue = chipValue or 0
        self.value = 0
        self.size = 0
        
        function self:addChip()
                local chip = Chip( self.chipValue, Image{src = "assets/Chip_"..(self.chipValue)..".png"} )        
                self.group:add(chip.image)
                self.chips[self.size + 1] = chip
                self.size = self.size + 1
                self.value = self.value + self.chipValue
        end
        
        function self:removeChip()      
                self.group:remove( self.chips[self.size].image )
                self.chips[self.size] = nil
                self.size = self.size - 1
                self.value = self.value - self.chipValue
        end
        
        function self:arrange(dy)
                --[[for i=1, self.size do
                        self.group:remove(self.chips[i])
                end]]
                local y = 0
                for i=1, self.size do
                        self.chips[i].image.y = y
                        y = y - dy
                        self.group:add(self.chips[i])
                end
        end
        
end)

-- A collection of stacks
chipCollection = Class(function(self, ...)
        
        -- Return the value of all stacks
        function self:value()
                local value = 0
                for i, v in ipairs(self.stacks) do
                        value = value + self.stacks[i].value
                end
                return value
        end 
        
        function self:size() return #self.stacks end -- Returns the number of stacks in the collection

        self.group = Group{}
        
        self.stacks = {}
        
        function self:add(newStack)
                self.stacks[#self.stacks + 1] = newStack
                self.group:add(newStack.group)
                self:sort()
        end
        
        function self:set(value)
                if self:value() == value then
--                        print("Nothing to change")
                        return true
                elseif self:value() < value then
--                        print("Attempting to add chips")
                        -- First, sort the stacks
                        self:sort()
                        local biggest = 1
                        local v = self:value()
                        
                        -- While there are more chips to add...
                        while v <= value do
                                
                                --print("Next biggest chip:", biggest, self.stacks[biggest].chipValue)
                                
                                -- Find the biggest chip we can add
                                while self.stacks[biggest].chipValue + v > value do
                                        biggest = biggest + 1
                                        if biggest > #self.stacks then 
                                        	return self:arrange(CHIP_W, CHIP_H)
                                        end
                                end
                                
                                self.stacks[biggest]:addChip()
                                v = v + self.stacks[biggest].chipValue
                                
                        end
                           
                else
--                        print("Attempting to subtract chips")
                        for i, stack in ipairs(self.stacks) do
                                while stack.size > 0 do
                                        stack:removeChip()
                                end
                        end
                        
                        self:set(value)

                end
                
                self:arrange(CHIP_W, CHIP_H)
        end
        
        function self:sort()
        
                local stackSort = function(first, second)
                        if first.chipValue > second.chipValue then
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
                                return v, k
                        end
                end
        end
        
        function self:arrange(dx, dy)
                self:convertUp()
                local x = 0
                for i=1, self:size() do
                        local y = 0
                        --self.stacks[i].group.x = x
                        --x = x + dx
                        self.stacks[i].group.position = self:getChipPosition( self.stacks[i].chipValue )
                        --print(self.stacks[i].group.position[1], self.stacks[i].group.position[2])
                        self.stacks[i]:arrange(dy)
                end
        end
        
        function self:getChipPosition(value)
                local t = {
                        [1] = {0, 0},
                        [5] = {55, 0},
                        [10] = {25, -40},
                        [100] = {-30, -40}
                }
                return t[value]
        end
        
        function self:convertUp()
                
                biggest = #self.stacks
                while biggest > 1 do
                        while self.stacks[biggest].size >= 10 do
                                for i=1,10 do
                                        self.stacks[biggest]:removeChip()
                                end
                                
                                -- biggest is 5 and biggest-1 is 10
                                -- need to remove 10 and add 5
                                
                                -- amt = ( 5 / 10 ) * 10 = 5
                                local amt = ( self.stacks[biggest].chipValue / self.stacks[biggest-1].chipValue ) * 10
                                
                                for i=1,amt do
                                        self.stacks[biggest-1]:addChip()
                                end
                        end
                        biggest = biggest - 1
                end
                
        end
        
        -- not functional
        function self:convertDown(chipValue, amount)
                
                local stack, smallest = self:getStack(chipValue)
                smallest = smallest - 1
                
                while smallest > 0 do
                        if self.stacks[smallest].size > 0 then
                                self.stacks[smallest]:removeChip()
                                for i=1,10 do
                                        self.stacks[smallest+1]:addChip()
                                end
                        end
                        smallest = smallest - 1
                end
                
        end
        
        function self:initialize()
                self:add( chipStack(1) )
                self:add( chipStack(5) )
                self:add( chipStack(10) )
                self:add( chipStack(100) )
        end
        
        self:initialize()
        
end)

--[[col = chipCollection()

local stack1 = chipStack(1)
local stack5 = chipStack(5)
local stack10 = chipStack(10)
local stack100 = chipStack(100)

col:add(stack1)
col:add(stack5)
col:add(stack10)
col:add(stack100)

col:set(247)
col:convertUp()
col:arrange(55, 5)
col.group.scale={3, 3}]]


--[[
-- First, sort the stacks
-- FOR SMARTER REMOVE
self:sort()
local biggest = 1
local v = self:value()

-- While there are more chips to add...
while v >= value do
        
        print("Next biggest chip:", biggest, self.stacks[biggest].chipValue)
        
        -- Find the biggest chip we can add
        while v - self.stacks[biggest].chipValue < value do
                biggest = biggest + 1
                if biggest > #self.stacks then return end
        end
        
        self.stacks[biggest]:removeChip()
        v = v - self.stacks[biggest].chipValue
        
end
                        ]]
