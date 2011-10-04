
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

local xml_output_string = ""

function engine_unit_test( positive_tests , negative_tests , quiet )
    local engine_results = {}
    local function run_tests( tests , negative )
        if tests then
        
            for k , v in pairs( tests ) do
                local ok
                local message
                local stopwatch = Stopwatch()
            
                if type( v ) == "function" then
                
                    ok , message = pcall( v )
                
                else
            
                    ok , message = pcall( v[ 1 ] , unpack( v , 2 ) )
                    
                end
                
                stopwatch:stop()

                if negative then
                
                    ok = not ok
                    
                    message = nil
                
                end
                table.insert( engine_results , { name = k , passed = ok , message = message, time = stopwatch.elapsed_seconds } )
    
            end
        
        end
    
    end
    
    -- Run all the ones that are defined as global functions named 'test...'
    
    local engine_global_tests = {}
    
    for k , v in pairs( _G ) do

    
        if ( type( v ) == "function" ) and ( string.lower( string.sub( tostring( k ) , 1 , 4 ) ) == "test" ) then
            local name = string.sub( tostring( k ) , 5 )
            
            if string.sub( name , 1 , 1 ) == "_" then
            
                name = string.sub( name , 2 )
                
            end
            
            engine_global_tests[ name ] = v
			_G[k] = nil
        
        end
    
    end

    local stopwatch = Stopwatch()

    run_tests( engine_global_tests , false )

    stopwatch:stop()
    -- Run all the ones passed in 
    
   -- run_tests( positive_tests , false )
    
   -- run_tests( negative_tests , true )

	local current_column = 1
	local column_line_max = 30
	local line_count = 0
	local test_count = 0
	local col_results = {}
	col_results[1] = ""
	col_results[2] = ""
	col_results[3] = ""
	col_results[4] = ""
        
    if not quiet then
    
        -- Print out results
        
        local passed = 0
        local failed = 0
        
        print( "" )
        print( "UNIT TESTS" )
        print( "" )

        for i , t in ipairs( engine_results ) do

        	if line_count > column_line_max then
				if current_column < 4 then
					current_column = current_column + 1
				end
				line_count = 0
			end

			line_count = line_count + 1

            if t.passed then
        		col_results[current_column] = col_results[current_column]..string.format( "PASS [%s]" , t.name ).."\n"
                print( string.format( "PASS [%s]" , t.name ) )
                xml_output_string = string.format("%s<testcase classname='com.trickplay.unit-test.engine' name='%s' time='%f'/>",xml_output_string,t.name, t.time)
                    
                passed = passed + 1
                
            else
            
                failed = failed + 1
                
            end

        end
        
        if failed > 0 then
        
            print( "" )
        
            for i , t in ipairs( engine_results ) do
            
                if not t.passed then
            		col_results[current_column] = col_results[current_column]..string.format( "FAIL [%s] %s" , t.name , t.message or "" ).."\n"
                    print( string.format( "FAIL [%s] %s" , t.name , t.message or "" ) )
                        		line_count = line_count + 2

                    xml_output_string = string.format("%s<testcase classname='com.trickplay.unit-test.engine' name='%s' time='%f'><failure type='failure'>%s</failure></testcase>",xml_output_string,t.name,t.time,t.message or "")

                end
            
            end
        end

        xml_output_string = string.format("<testsuite name='com.trickplay.unit-test.engine' errors='%d' failures='%d' tests='%d' time='%f'><properties><property name='trickplay.version' value='%s' /></properties>%s</testsuite>",0,failed,#engine_results,stopwatch.elapsed_seconds,trickplay.version,xml_output_string)
        
        print( "" )
        print( string.format( "PASSED   %4d (%d%%)" , passed , ( passed / #engine_results ) * 100 ) )
        print( string.format( "FAILED   %4d (%d%%)" , failed , ( failed / #engine_results ) * 100 ) )
        print( string.format( "TOTAL    %4d" , #engine_results ) )
        print( "" )

		col_results[current_column] = "/n"..col_results[current_column]..string.format( "PASSED   %4d (%d%%)" , passed , ( passed / #engine_results ) * 100 ).."\n"
        col_results[current_column] = col_results[current_column]..string.format(  "FAILED   %4d (%d%%)" , failed , ( failed / #engine_results ) * 100 ).."\n"
		col_results[current_column] = col_results[current_column]..string.format( "TOTAL    %4d" , #engine_results ).. "\n"

        -- You can generate XML output by running with TP_app_allowed="com.trickplay.unit-tests=editor" set in the environment
        if(editor) then
            -- Set XML_OUTPUT_PATH global variable from the console to change output path
            if(XML_OUTPUT_PATH) then
                editor:change_app_path(XML_OUTPUT_PATH)
            end
            print("Writing to file:",XML_OUTPUT_PATH,"unit-tests.xml")
            editor:writefile("unit-tests.xml",xml_output_string,true)
        end

    end
	
	results_col_1_txt.text = col_results[1]
	results_col_2_txt.text = col_results[2]
	results_col_3_txt.text = col_results[3]
	results_col_4_txt.text = col_results[4]

	passed = nil
	failed = nil
    
    return engine_results
end

