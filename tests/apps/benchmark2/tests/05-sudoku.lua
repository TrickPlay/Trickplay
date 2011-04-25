
-------------------------------------------------------------------------------

local trickplay = trickplay and true or false

-------------------------------------------------------------------------------
-- Iterates over the numerically indexed values in a table

local function values( T )

    assert( type( T ) == "table" )
    
    local function values( )
        for _ , v in ipairs( T ) do
            coroutine.yield( v )
        end
    end
    
    return coroutine.wrap( values )
    
end

-------------------------------------------------------------------------------
-- Iterates over all characters in a string

local function chars( S )

    assert( type( S ) == "string" )

    local function chars( )
        for i = 1 , # S do
            coroutine.yield( string.sub( S , i , i ) )
        end
    end
    
    return coroutine.wrap( chars )

end

-------------------------------------------------------------------------------
-- Iterates over the cross product of characters in A and B

local function cross( A , B )

    assert( type( A ) == "string" and type( B ) == "string" )
    
    local function cross( )
        for a in chars( A ) do
            for b in chars( B ) do
                coroutine.yield( a..b )
            end
        end
    end
    
    return coroutine.wrap( cross )
    
end

-------------------------------------------------------------------------------
-- Returns a table that contains all the items returned by the iterator

local function make_table( iterator , original )

    local result = original or {}
    
    assert( type( result ) == "table" )
    
    for i in iterator do
        result[ # result + 1 ] = i
    end
    
    return result
    
end

-------------------------------------------------------------------------------

local function table_contains( T , V )

    for v in values( T ) do
        if v == V then
            return true
        end
    end
    
    return false
    
end

-------------------------------------------------------------------------------

local function copy_table( T )

    assert( type( T ) == "table" )
    
    local result = {}
    
    for k , v in pairs( T ) do
        result[ k ] = v
    end
    
    return result
end

-------------------------------------------------------------------------------
  
local COLS = "123456789"
local ROWS = "ABCDEFGHI"

-------------------------------------------------------------------------------
-- A table with the 81 squares as values. { "A1" , "A2" , ... }

local squares = make_table( cross( ROWS , COLS ) )

assert( # squares == 81 )

-------------------------------------------------------------------------------
-- A table with the 27 units as tables of squares. 

local unitlist = {}

for c in chars( COLS ) do
    table.insert( unitlist , make_table( cross( ROWS , c) ) )
end

for r in chars( ROWS ) do
    table.insert( unitlist , make_table( cross( r , COLS ) ) )
end

for r in values( { "ABC" , "DEF" , "GHI" } ) do
    for c in values( { "123" , "456" , "789" } ) do
        table.insert( unitlist , make_table( cross( r , c ) ) )
    end
end

assert( # unitlist == 27 )

-------------------------------------------------------------------------------
-- A dictionary mapping each square to a table of its 3 units.

local units = {}

for square in values( squares ) do

    local t = {}
    
    for unit in values( unitlist ) do
    
        if table_contains( unit , square ) then
        
            table.insert( t , unit )
            
        end
    
    end
    
    assert( # t == 3 )
    
    units[ square ] = t

end

-------------------------------------------------------------------------------
-- A dictionary mapping each square to a table of its 20 peers.

local peers = {}

for square in values( squares ) do
    
    local t = {}

    for unit in values( units[ square ] ) do

        for peer in values( unit ) do

            if peer ~= square and not table_contains( t , peer ) then

                table.insert( t , peer )
            end
        end

    end
    
    assert( # t == 20 )

    peers[ square ] = t

end

-------------------------------------------------------------------------------
-- Eliminate a value as a possibility for a square

local gsub = string.gsub
local find = string.find

local assign

local function eliminate( t , square , value )

    local v , n = gsub( t[ square ] , value , "" )

    -- This value has already been eliminated from the square, do nothing
    
    if n == 0  then
        return true
    end
    
    -- Eliminate the value
    
    t[ square ] = v
    
    -- If we are left with no values, this is not valid
    
    n = # v
    
    if n == 0 then
        return false
    end
    
    -- If we are left with a single value, we can eliminate this value
    -- from all of our peers.
    
    if n == 1 then
        for peer in values( peers[ square ] ) do
            if not eliminate( t , peer , v ) then
                return false
            end
        end
    end
    
    -- Now, look through each unit for this square and see how many can have
    -- this value. If only one, then we assign that value to it.
    
    for unit in values( units[ square ] ) do
        local unit_places = {}
        n = 0
        for unit_square in values( unit ) do
            if find( t[ unit_square ] , value , 1 , true ) then
                n = n + 1
                if n > 1 then
                    break
                end
                rawset( unit_places , n , unit_square )
            end
        end
        
        -- This value cannot be in any other unit. This is incorrect.
        
        if n == 0 then
            return false
        end
        
        -- The value only has one possible place
        
        if n == 1 then
            if not assign( t , unit_places[ 1 ] , value ) then
                return false
            end
        end
    
    end
    
    return true
end


-------------------------------------------------------------------------------
-- When we set this square to a value, we eliminate other values
-- for this square.

function assign( t , square , value )

    local other_values = gsub( t[ square ] , value , "" )
    
    for c in chars( other_values ) do
        if not eliminate( t , square , c ) then
            return false
        end
    end
    
    return t

end

-------------------------------------------------------------------------------
-- Parse an input grid string. Numbers 1-9 go in each square, . or 0 skips a
-- square, anything else is ignored. Since we use assign to put the values in
-- the square, we are solving/reducing it as we parse it.

local function parse_grid( grid )

    local result = {}
    
    for square in values( squares ) do
        result[ square ] = "123456789"
    end
    
    local next_square = cross( ROWS , COLS )
    local square = next_square()
    local byte = string.byte
    local b 
    
    for c in chars( grid ) do
        
        b = byte( c )        
        if b >= 49 and b <= 57 then -- 1-9
            assign( result , square , c )
            square = next_square()
        elseif b == 46 or b == 48 then -- . or 0
            square = next_square()
        end
        if not square then
           break
        end
    end
    
    return result

end

-------------------------------------------------------------------------------
-- Looks for a square that has >1 possible values and tries to solve it by
-- iterating over its possible values.

local function search( t )

    if not t then
        return false
    end
    
    local least_square          = nil
    local least_square_n        = 10
    local least_square_values   = nil
    local n
    
    for square , values in pairs( t ) do
        n = # values
        if n > 1 and n < least_square_n then
            least_square = square
            least_square_n = n
            least_square_values = values
            if n == 2 then
                break
            end
        end
    end
    
    -- Solved. There is no square that has > 1 and < 10 possible values
    
    if not least_square then
        return t
    end
    
    --assert( least_square )
    --assert( least_square_n > 1 and least_square_n < 10 )
    --assert( least_square_values )
    
    local result
    
    for c in chars( least_square_values ) do
        result = search( assign( copy_table( t ) , least_square , c ) )
        if result then
            return result
        end
    end
        
    return false

end

-------------------------------------------------------------------------------

local function print_grid( t )

    if not t then
        print( "NOT SOLVED" )
        return
    end

    local i = 1
    local s = "\n\n"

    for square in cross( ROWS , COLS ) do
    
        local v = t[ square ]
        
        if # v == 1 then
            s = s..v.." "
        else
            s = s..". "
        end
        
        if i % 9 == 0 then
            s = s.."\n"
        elseif i % 3 == 0 then
            s = s.."|"
        end
        
        if i == 27 or i == 54 then
            s = s.."------+------+------\n"
        end        
        
        i = i + 1
    
    end
    
    print( s )

end

-------------------------------------------------------------------------------
-- Parses, solves, times and prints the result

local function solve( grid , quiet )

    local s
    local seconds
    
    if trickplay then
        s = Stopwatch()
    end
    
    local result = search( parse_grid( grid ) )
    
    if trickplay then
        s:stop()
        seconds = s.elapsed_seconds
    else
        seconds = 0
    end
    
    return result , seconds
end

-------------------------------------------------------------------------------
-- Solves all puzzles in the file and prints out stats

local function solve_file( file )

    local lines
    
    if trickplay then
        lines = readfile( file )
    else
        lines = io.open( file , "r" ):read( "*a" )
    end

    local grids = make_table( string.gmatch( lines , "([^\n]*)\n" ) )
    
    local solved = 0
    local total = 0
    local max = 0
    
    for grid in values( grids ) do
    
        local result , time = solve( grid , true )
        
        if result then
            solved = solved + 1
            total = total + time
            max = math.max( max , time )
        end

        for i = 1 , 10 do
            collectgarbage( "collect" )
        end
        
        if solved == 40 then
            break
        end
    end
    
    finish_test( solved / total , "Hz" )    
end

-------------------------------------------------------------------------------

title( "Sudoku" )

dolater( solve_file , "assets/sudoku-top95.txt" )

