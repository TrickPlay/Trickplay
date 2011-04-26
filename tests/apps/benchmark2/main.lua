
-------------------------------------------------------------------------------
-- Populate the table of tests
-------------------------------------------------------------------------------

local all_tests = {}

do

    local contents = app.contents
    
    for i = 1 , # contents do
        if string.match( contents[ i ] , "tests/.*.lua" ) then
            table.insert( all_tests , contents[ i ] )
        end
    end

end

table.sort( all_tests )

local run_forever = false
local tests = {}
local current_test = nil
local results = {}
local focused = 2
local auto_timer = Timer( 10000 )
local auto = false

local function test_name( file_name )
    return string.match( file_name , ".*/(.*)%.lua" )
end

function auto_timer.on_timer()
    auto = true
    screen.on_key_down( screen , keys.Return )
    return false
end

auto_timer:start()

-------------------------------------------------------------------------------

local function show_menu()
    
    local top = 20
    local maxw = 0
    local font_size = 36
    local items = {}
    
    local function add_item( caption , id )
        local text = Text
        {
            font = "DejaVu Sans "..tostring( font_size ).."px",
            color = "FFFFFF",
            x = 6,
            y = top,
            text = caption,
            extra = { id = id or caption },
            name = caption
        }
        top = top + text.h + 6
        maxw = math.max( maxw , text.w )
        screen:add( text )
        table.insert( items , text )
    end
    
    local function update_results()
        for i = 1 , # items do
            local item = items[ i ]
            local result = results[ item.text ]
            if result then
                result = result[ # result ]
                local text = Text
                {
                    font = "DejaVu Sans Mono "..tostring( font_size ).."px",
                    color = "AAAAAA",
                    x = maxw + 10,
                    y = item.y,
                    text = string.format( "%10.1f %s %s" , result.result , result.units , result.extra or "" )
                }
                screen:add( text )
            end
        end
    end
    
    screen:clear()

    add_item( "<Run once>" , "FOREVER" )
    add_item( "Run all tests" , "ALL" )
    
    for i = 1 , # all_tests do
        add_item(  test_name( all_tests[ i ] ) , all_tests[ i ] )
    end
    
    local focus = Rectangle{ color = "000055" , size = { screen.w , font_size + 10 } , position = { 6 , 20 } }
    
    screen:add( focus )
    
    focus:lower_to_bottom();
    
    update_results()
    
    screen:show()
    
    local item = items[ focused ]
    if item then
        focus.position = item.position
    end
    
    
    function screen.on_key_down( screen , key )
        auto_timer:stop()        
        if key == keys.Return then
            local id = items[ focused ].extra.id
            
            if id == "FOREVER" then
                run_forever = not run_forever
                if run_forever then
                    items[ focused ].text = "<Run continuously>"
                else
                    items[ focused ].text = "<Run once>"
                end
            else
                screen:clear()
                screen.on_key_down = nil
                items = nil
                focus = nil
                collectgarbage( "collect" )
                if id == "ALL" then
                    tests = {}
                    for i = 1 , # all_tests do
                        tests[ i ] = all_tests[ i ]
                    end
                    current_test = nil
                    finish_test()
                else
                    tests = { id }
                    current_test = nil
                    finish_test()
                end
            end                    
        else
            local d = nil
            if key == keys.Up then
                d = -1
            elseif key == keys.Down then
                d = 1
            end
            if d then
                local new_focused = focused + d
                local item = items[ new_focused ]
                if item then
                    focused = new_focused
                    focus.position = item.position
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- This prints out the result for the current test and starts the next one
-------------------------------------------------------------------------------

local function finish_test_local( result , units , extra )

    local function clean_up()
        screen:clear()
        idle.on_idle = nil
        collectgarbage( "restart" )
        
        for i = 1 , 5 do
            collectgarbage( "collect" )
        end
    end

    if current_test then
        --print( string.format( "%-20s %10.1f %s %s" , current_test.name , result , units or "" , extra or "" ) )
        
        local rt = results[ current_test.name ]
        
        if not rt then
            rt = {}
            results[ current_test.name ] = rt
        end
        
        table.insert( rt , { result = result , units = units , extra = extra } )
    end
    
    if # tests == 0 then
        clean_up()
        show_menu()
        if auto then
            exit()
        end
    else
        clean_up()
        local file_name = table.remove( tests , 1 )
        if run_forever then
            table.insert( tests , file_name )
        end
        current_test = {}
        current_test.name = test_name( file_name ) 
        collectgarbage( "stop" )
        dolater( dofile , file_name )
    end
end

-------------------------------------------------------------------------------
-- Global functions
-------------------------------------------------------------------------------

function title( s )
    screen:add( Text{ font = "100px" , color = "FFFFFF" , position = { 10 , 10 } , text = s } )
end

function finish_test( result , units , extra )
    dolater( finish_test_local , result , units , extra )
end
        
-------------------------------------------------------------------------------

function app.on_closing()
    
    print( "" )
    print( "TRICKPLAY VERSION  : "..trickplay.version )
    print( "DISPLAY DIMENSIONS : "..string.format( "%dx%d" , screen.display_size[1] , screen.display_size[2] ) )
    print( "CLUTTER VERSION    : "..trickplay.libraries.clutter[ 1 ].." "..trickplay.libraries.clutter[ 3 ] )
    print( "PROFILING          : "..tostring( trickplay.profiling ) )
    print( "" )

    local have_results = false

    for n = 1 , # all_tests do
        local name = test_name( all_tests[ n ] )
        local v = results[ name ]
        if v then
            have_results = true
            for i = 1 , #v do
                local result = v[ i ]
                print( string.format( "%-20s %3d %10.1f %s %s" , name , i , result.result , result.units or "" , result.extra or "" ) )
            end
        end
    end
    
    if have_results then

        local j =
        {
            trickplay =
            {
                version = trickplay.version ,
                config = trickplay.config ,
                libraries = trickplay.libraries        
            }
            ,
            results = results
        }
    
        URLRequest
        {
            url = "http://10.0.190.15/benchmark/post.php",
            method = "POST",
            timeout = 5,
            body = json:stringify( j ),
            headers = { [ "Content-Type" ] = "application/json" }
        }:perform()
        
    end        

end

-------------------------------------------------------------------------------

dolater( show_menu )
