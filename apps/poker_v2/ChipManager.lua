--[[
    A Chip
--]]
Chip = Class(function(chip, value, ...)

    chip.value = value

    local image_name = "chip_"..tostring(value)
    if not assetman:has_image_of_name(image_name) then
        assetman:load_image("assets/Chip_"..value..".png", image_name)
    end
    chip.image_clone = assetman:get_clone(image_name)

    function chip:dealloc()
        chip.value = nil
        assetman:remove_clone(chip.image_clone)
        chip.image_clone = nil
    end

end)

--[[
    A vertical stack of Chips
--]]
ChipStack = Class(function(chipstack, chip_value, ...)

    local chips = {}
    local value = 0

    chipstack.chip_value = chip_value
    chipstack.group = assetman:create_group({})

    function chipstack:size()
        return #chips
    end

    function chipstack:get_value() return value end

    function chipstack:dealloc()
        for i,chip in ipairs(chips) do
            chip:dealloc()
        end
        chips = nil
        value = nil
        self.chip_value = nil
        assetman:remove_group(self.group.name)
        self.group = nil
    end

    function chipstack:add_chip()
        local chip = Chip(chip_value)
        self.group:add(chip.image_clone)
        table.insert(chips, chip)
        value = value + chip.value
    end

    function chipstack:remove_chip()
        local chip = table.remove(chips)
        value = value - chip.value

        chip:dealloc()
    end

    function chipstack:arrange(dy)
        local y = 0
        for i,chip in ipairs(chips) do
            chip.image_clone.y = y
            y = y - dy
            if not chip.image_clone.parent then
                self.group:add(chip.image_clone)
            end
        end
    end

end)


ChipCollection = Class(function(chip_collect, dog_number, ...)

    local stacks = {}
    chip_collect.group = assetman:create_group({})
    if dog_number then
        chip_collect.group.position = {
            CHIP_COLLECTION_POSITIONS[dog_number][1],
            CHIP_COLLECTION_POSITIONS[dog_number][2]
        }
    end

    local chip_position = {
        [1] = {0, 0},
        [5] = {55, 0},
        [10] = {25, -40},
        [100] = {-30, -40},
    }

    function chip_collect:dealloc()
        print("ChipCollection dealloc")
        for i,stack in ipairs(stacks) do
            stack:dealloc()
        end
        stacks = nil
        assetman:remove_group(self.group.name)
        self.group = nil
    end

    function chip_collect:value()
        local value = 0
        for i,stack in ipairs(stacks) do
            value = value + stack:get_value()
        end
        return value
    end

    function chip_collect:size()
        return #stacks
    end

    function chip_collect:sort()
        local stack_sort = function(first, second)
            if first.chip_value > second.chip_value then
                return true
            end
        end

        for i,stack in ipairs(stacks) do
            stack.group:unparent()
        end

        table.sort(stacks, stack_sort)

        for i,stack in ipairs(stacks) do
            self.group:add(stack.group)
        end

    end

    function chip_collect:add(newstack)
        table.insert(stacks, newstack)
        if not newstack.group.parent then
            self.group:add(newstack.group)
        end
        self:sort()
    end

    function chip_collect:convert_up()
        -- grab the chip_stack with the smallest value per chip
        stack_index = #stacks
        while stack_index > 1 do
            while stacks[stack_index]:size() >= 10 do
                for i = 1,10 do
                    stacks[stack_index]:remove_chip()
                end

                -- if current stack chip value is 5 then current stack chip
                -- value is 10 thus need remove 10 and add 5

                -- amt = (5/10)*10 = 5
                local amt = (stacks[stack_index].chip_value /
                    stacks[stack_index-1].chip_value) * 10

                for i = 1,amt do
                    stacks[stack_index-1]:add_chip()
                end
            end
            stack_index = stack_index - 1
        end
    end

    function chip_collect:arrange(dx, dy)
       self:convert_up()
       local x = 0
       for i,stack in ipairs(stacks) do
           --stack.group.x = x
           --x = x + dx
           stack.group.position = chip_position[stack.chip_value]
           stack:arrange(dy)
       end
    end

    function chip_collect:set(value)
        local current_value = self:value()
        if current_value == value then
            return
        elseif current_value < value then
            self:sort()
            -- start with the stack with the highest value per chip
            local stack_index = 1
            -- while there are more chips to add...
            while current_value <= value do
                -- find the biggest chip we can add
                while stacks[stack_index].chip_value + current_value > value do
                    stack_index = stack_index + 1
                    if stack_index > #stacks then
                        return self:arrange(CHIP_W, CHIP_H)
                    end
                end
                stacks[stack_index]:add_chip()
                current_value = current_value + stacks[stack_index].chip_value
            end
        else
            for i,stack in ipairs(stacks) do
                while stack:size() > 0 do
                    stack:remove_chip()
                end
            end
            self:set(value)
        end

        self:arrange(CHIP_W, CHIP_H)
    end

    function chip_collect:get_stack(chip_value)
        for i,stack in ipairs(stacks) do
            if stack.chip_value == chip_value then
                return stack,i
            end
        end
    end

    function chip_collect:initialize()
        self:add(ChipStack(1))
        self:add(ChipStack(5))
        self:add(ChipStack(10))
        self:add(ChipStack(100))
    end

    chip_collect:initialize()

end)
