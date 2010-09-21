

--[[===========================================================================
    
    This should start a new game.
    Assume that the human player will always go first.
]]

function start_game()
    
    HARD_MODE = 1
    
    magic_3_square = { 2, 7, 6, 9, 5, 1, 4, 3, 8 }
    rev_magic_3_square = {}

    -- keep a reverse lookup for magic number to position
    for i, magic_num in pairs(magic_3_square) do
        rev_magic_3_square[magic_num] = i
    end

    human_moves = {}
    comp_moves  = {} 

    move_count  = 0
end

--[[===========================================================================
    Helper Functions
--]]

function get_win_positions(moves)
    local win_positions = {}
    for i=1, #moves do
        for j=i+1, #moves do
            local solution = 15-(moves[i]+moves[j])
            local index    = rev_magic_3_square[solution]
            if is_free_space(index) then
                win_positions[index] = solution
            end
        end    
    end
    return win_positions
end

function is_free_space(index)
    if index == nil or index < 1 or index > 9 then return false end

    -- TODO: can replace this with reverse hash for faster lookup
    local magic_from_index = magic_3_square[index]

    for i, used_magic in ipairs(human_moves) do
        if magic_from_index == used_magic then return false end
    end

    for i, used_magic in ipairs(comp_moves) do
        if magic_from_index == used_magic then return false end
    end

    return true
end

function column_row_to_index(column,row)
    return ( ( row - 1 ) * 3 ) + column
end

function index_to_column_row(index)
    -- math is easier when index starts at 0
    local index = index - 1
    local column = (index % 3)
    local row = index/3
    -- remove fractional portion
    row = row - row % 1
    return column + 1, row + 1
end
 
--[[===========================================================================
    

    This function should return:

    If the move is not legal, false    
    If the human player won, true
    If the computer player won, the column and row, and true.
    If the computer player did not win, the column and row, and false.
    
    columns are 1,2 and 3 (from the left)
    rows are 1,2 and 3 (from the top)
    
      columns
      1  2  3
 r 1    |  |
 o    --+--+--
 w 2    |  |
 s    --+--+--
   3    |  |
   
]]

function human_plays_at(column,row)

    local human_index = column_row_to_index(column, row)

    -- verify move is valid (not free)
    if not is_free_space(human_index) then
        return false
    end

    -- valid move is being made
    move_count = move_count + 1
    assert(move_count < 6)

    if move_count >= 3 then
        -- check for human win
        local human_win_positions = get_win_positions(human_moves)

        if human_win_positions[human_index] then return true end

        --- add the move before checking computer for win positions
        human_moves[#human_moves+1] = magic_3_square[human_index]

        --- check if computer can now win
        local comp_win_positions = get_win_positions(comp_moves)
        for index, value in pairs(comp_win_positions) do
            local col, row = index_to_column_row(index)
            return col, row, true
        end
    else
        -- no wins, add move
        human_moves[#human_moves+1] = magic_3_square[human_index]
    end
    
    -- check if human can win next round, if so take that position
    if move_count >= 2 then
        local human_win_positions = get_win_positions(human_moves)
        for index, value in pairs(human_win_positions) do
            comp_moves[#comp_moves+1] = value
            local col, row = index_to_column_row(index)
            return col, row, false
        end
    end
    
    -- heueristics at this point
    -- find computer move (column,row,false)

    if 1 == move_count and HARD_MODE then
        -- choose middle if possible, don't chose corner if they chose mid
        local index = 5 == human_index and 2 or 5
        comp_moves[#comp_moves+1] = magic_3_square[index]
        local col, row = index_to_column_row(index)
        return col, row, false
    end

    -- TODO: dumb algorithm (first free spot) maybe make random?
    for i=1,9 do
        if is_free_space(i) then
            comp_moves[#comp_moves+1] = magic_3_square[i]
            local col, row = index_to_column_row(i)
            return col, row, false
        end
    end
    
end

-------------------------------------------------------------------------------
-- DO NOT MODIFY CODE BELOW THIS POINT
-------------------------------------------------------------------------------

function loop()

    local board={}


    local function column_row_to_index(column,row)

      return ( ( row - 1 ) * 3 ) + column
      
    end
    
    local function print_board()

        local s=    

            "      1   2   3    \n"..
            "                   \n"..
            "  1   %s | %s | %s \n"..
            "     ---+---+---   \n"..
            "  2   %s | %s | %s \n"..
            "     ---+---+---   \n"..
            "  3   %s | %s | %s \n"

        print( string.format( s , unpack( board ) ) )
        
    end


    for i=1,9 do
        table.insert(board," ")
    end

    while line ~= "q" do

        print_board()
        
        print( "What next?" )
        
        local line = io.stdin:read()
        
        if line == "q" then
        
            break
            
        end
        
        local col 
        local row
        
        col , row = string.match(line,"(%d).*(%d)")
        
        col=tonumber(col)
        row=tonumber(row)
        
        if col and row and col >= 1 and col <= 3 and row >= 1 and row <= 3 then
        
            c , r , computer_won = human_plays_at( col , row )
            
            print( "GOT",c,r,computer_won)
            
            if c == false then
                
                print( "You cannot play there" )
                
            else 
            
                board[column_row_to_index( col , row )]="X"
                
                if c == true then
                
                    print_board()
                    print( "YOU WIN!" )
                    break
                   
                else
                    assert(c and c >= 1 and c <= 3)
                    assert(r and r >= 1 and r <= 3)
                
                    board[column_row_to_index( c , r )]="O"

                    if computer_won then
                    
                        print_board()
                        print( "I WIN!!!" )
                        break
                    
                    end
               
                end 
            
            end
            
        
        else
        
            print("Enter the column and row where you would like to play")
            
        end
    end

end

-------------------------------------------------------------------------------

start_game()

loop()
