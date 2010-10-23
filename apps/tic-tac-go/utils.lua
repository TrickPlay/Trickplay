Utils = {} 
--[[========================================================================
    Helper Functions
--]]


function Utils.get_free_spaces(free_spaces)
    local free_spaces_list = {}   
    for i, v in ipairs(free_spaces) do
        if v then table.insert(free_spaces_list, i) end
    end
    return free_spaces_list
end

--[=[
function Utils.is_free_space(player_moves, index)
    if index == nil or index < 1 or index > 9 then return false end

    local magic_from_index = magic_3_square[index]

	for i in ipairs(player_moves) do
		local human_moves = player_moves[i]
    	for j, used_magic in ipairs(human_moves) do
        	if magic_from_index == used_magic then return false end
    	end
	end

    return true
end
--]=]

function Utils.column_row_to_index(column,row)
    return ( ( row - 1 ) * 3 ) + column
end

function Utils.index_to_column_row(index)
    -- math is easier when index starts at 0
    local index = index - 1
    local column = (index % 3)
    local row = index/3
    -- remove fractional portion
    row = row - row % 1
    return column + 1, row + 1
end

function Utils.shallow_copy(the_table)
    local new_table = {}
    for i,v in ipairs(the_table) do
        new_table[i] = v 
    end
    return new_table
end

-- randomize the order of a table
-- Fisher-Yates_shuffle
function Utils.randomize_table(the_table)
    local clone = Utils.shallow_copy(the_table)
    for i=#clone,2,-1 do
        local j = math.random(1,i)   
        clone[j], clone[i] = clone[i], clone[j]
        end
    return clone
end
