
-------------------------------------------------------------------------------
-- Unit testing framework
-------------------------------------------------------------------------------

local function assert_private( e , m ) if e ~= true then error( m , 3 ) end end

function is_table           ( t ) return type(t) == type({}) end
function is_string          ( s ) return type(s) == type("") end
function is_boolean         ( b ) return type(b) == type(true) end
function is_udata           ( u ) return type(u) == "userdata" end
function is_number          ( n ) return type(n) == type(0) end
function is_nil             ( n ) return n == nil end
function is_function        ( f ) return type( f ) == type( print ) end
function assert_true        ( e , m ) assert_private( e , m ) end
function assert_false       ( e , m ) assert_private( not e , m ) end
function assert_equal       ( a , b , m ) assert_private( a == b , m ) end
function assert_not_equal   ( a , b , m ) assert_private( a ~= b , m ) end
function assert_greater_than   ( a , b , m ) assert_private( a > b , m ) end
function assert_less_than   ( a , b , m ) assert_private( a < b , m ) end
function assert_table       ( t , m ) assert_private( is_table(t) , m ) end
function assert_string      ( s , m ) assert_private( is_string(s) , m ) end
function assert_boolean     ( b , m ) assert_private( is_boolean(b) , m ) end
function assert_userdata    ( u , m ) assert_private( is_udata(u) , m ) end
function assert_number      ( n , m ) assert_private( is_number(n) , m ) end
function assert_nil         ( n , m ) assert_private( is_nil(n) , m ) end
function assert_not_nil     ( n , m ) assert_private( not is_nil(n) , m ) end
function assert_function    ( f , m ) assert_private( is_function(f) , m ) end

-------------------------------------------------------------------------------
-- This function will execute the following:
--   1) Any global function whose name begins with "test" (case insensitive)
--   2) All functions passed in the "positive_tests" and "negative_tests" tables.
--      These tables should have string keys - which will be the name of
--      each test. The value can either be a single function which will get
--      called with no parameters or a table with a function as the first
--      item followed by all parameters the function will receive.
--
-- If quiet is true, the function will not print results.
--
-- Negative tests pass if they raise an error.
--
-- Results are an array of tables. Each element has the following fields:
--  passed : boolean
--  name : string - the name of the test
--  message : string or nil - the failure message
--
-------------------------------------------------------------------------------

function unit_test( positive_tests , negative_tests , quiet )
    local results = {}
    local function run_tests( tests , negative )
        if tests then
        
            for k , v in pairs( tests ) do
                local ok
                local message
            
                if type( v ) == "function" then
                
                    ok , message = pcall( v )
                
                else
            
                    ok , message = pcall( v[ 1 ] , unpack( v , 2 ) )
                    
                end
                
                if negative then
                
                    ok = not ok
                    
                    message = nil
                
                end
                table.insert( results , { name = k , passed = ok , message = message } )
    
            end
        
        end
    
    end
    
    -- Run all the ones that are defined as global functions named 'test...'
    
    local global_tests = {}
    
    for k , v in pairs( _G ) do

    
        if ( type( v ) == "function" ) and ( string.lower( string.sub( tostring( k ) , 1 , 4 ) ) == "test" ) then
            local name = string.sub( tostring( k ) , 5 )
            
            if string.sub( name , 1 , 1 ) == "_" then
            
                name = string.sub( name , 2 )
                
            end
            
            global_tests[ name ] = v
        
        end
    
    end
    
    run_tests( global_tests , false )
    
    -- Run all the ones passed in 
    
   -- run_tests( positive_tests , false )
    
   -- run_tests( negative_tests , true )
        
    if not quiet then
    
        -- Print out results
        
        local passed = 0
        local failed = 0
        
        print( "" )
        print( "UNIT TESTS" )
        print( "" )
        
        for i , t in ipairs( results ) do
        
            if t.passed then
        
                print( string.format( "PASS [%s]" , t.name ) )
                    
                passed = passed + 1
                
            else
            
                failed = failed + 1
                
            end
        
        end
        
        if failed > 0 then
        
            print( "" )
        
            for i , t in ipairs( results ) do
            
                if not t.passed then
            
                    print( string.format( "FAIL [%s] %s" , t.name , t.message or "" ) )
                        
                end
            
            end
        
        end
        
        print( "" )
        print( string.format( "PASSED   %4d (%d%%)" , passed , ( passed / # results ) * 100 ) )
        print( string.format( "FAILED   %4d (%d%%)" , failed , ( failed / # results ) * 100 ) )
        print( string.format( "TOTAL    %4d" , #results ) )
        print( "" )
        
    end
    
    return results
end

