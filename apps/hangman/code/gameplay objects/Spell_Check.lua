
--this upval stops creation of an empty table for each iteration
local empty = {}

--table of tables, entry for each letter of the alphabet
local cache = setmetatable( {} , 
    {
        --no need to keep this monster in data at all times,
        --only load up the table for the letter needed at that time
        __index = function( t , k ) 
            
            --key is a single letter
            assert( type( k ) == "string" )
            assert(     # k   ==     1    )
            
            --grabs the table for that first letter
            local v = dofile( "code/gameplay objects/words/"..k )
            
            --if there was a table
            if v then
                
                
                --rawset( t , k , v )
                
                return v
                
            end
            
            --if not, return the empty table
            return empty
        end
    }
)

return function ( word ) 
    
    assert( type( word ) == "string" )
    
    --if the word is the empty string, return
    if word == "" then return false end
    
    
    return rawget(
            
            --hits 'cache's __index with the first letter of the word
            cache[ word:match( "^(%l).*" ):lower() ] , 
            
            --checks that table of letters to see if the word exists
            word:lower()
            
        ) == 1 --returns true if the word exists
    
    
end
    

