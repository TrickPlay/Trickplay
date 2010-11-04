--local function print() end

-- GLOBALS
CHIP_W = 55
CHIP_H = 5

ALL_DA_CHIPS = {}
function REMOVE_ALL_DA_CHIPS()
    for i = #ALL_DA_CHIPS,1,-1 do
        local chip = ALL_DA_CHIPS[i]
        if chip.group then
            if chip.group.parent then chip.group:unparent() end
            chip.group = nil
        end
    end

    ALL_DA_CHIPS = {}
end

function CHIP_RECURSIVE_DEL(container)
    if container.name == "a_chip" then
        container:unparent()
        return
    end
    if container.children then
        for i = #container.children,1,-1 do
            CHIP_RECURSIVE_DEL(container.children[i])
        end
    end
end


-- A chip
Chip = Class(function(self, value, image, ...)

    self.value = value
    self.image = image

end)

local chip_images = {}
-- A stack of chips!
chipStack = Class(function(self, chipValue, ...)

    self.chips = {}
    self.group = Group{}
    self.chipValue = chipValue or 0
    self.value = 0
    self.size = 0

    function self:addChip()
        if not chip_images[self.chipValue] then
            chip_images[self.chipValue] = Image{
                src = "assets/Chip_"..(self.chipValue)..".png",
                opacity = 0,
            }
            screen:add(chip_images[self.chipValue])
        end
        local chip = Chip(
            self.chipValue, Clone{source = chip_images[self.chipValue], name = "a_chip"}
        )
        self.group:add(chip.image)
        self.chips[self.size + 1] = chip
        self.size = self.size + 1
        self.value = self.value + self.chipValue

        table.insert(ALL_DA_CHIPS, chip)
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
            if not self.chips[i].image.parent then
                self.group:add(self.chips[i].image)
            end
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
        if not newStack.group.parent then
            self.group:add(newStack.group)
        end
        self:sort()
    end

    function self:set(value)
        if self:value() == value then
            -- Nothing to change
            return true
        elseif self:value() < value then
            -- Attempting to add chips
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

    -- Set to 0 and remove from parent
    function self:remove()
        self:set(0)
        if self.group.parent then
            self.group:unparent()
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
