
local URI_NOT_ALLOWED = 1
local LOCALIZED_NOT_ALLOWED = 2

local function pt( path , flags )
    flags = flags or 0
    return devtools:path_test( path , flags )
end

local _ , nr , ur = pt( "A" )

nr = nr:sub( 1 , -2 )
ur = ur:sub( 1 , -2 )

local tests =
{
    { "EMPTY PATH"                      , ""          , 0 , { false } },
    { "FILE THAT EXISTS"                , "app"       , 0 , { true , nr.."app" , ur.."app" } },
    { "FILE THAT EXISTS WITH EXTENSION" , "main.lua"  , 0 , { true , nr.."main.lua" , ur.."main.lua" } },
    { "FILE THAT DOESN'T EXIST"         , "none"      , 0 , { true , nr.."none" , ur.."none" } },
    { "NO PATH URI"                     , "http:"     , 0 , { true , "" , "http:" } },
    { "BAD SCHEME"                      , "abcdef:"   , 0 , { false } },
    { "DOUBLE URI"                      , "http:http" , 0 , { false } },
    { "URI NOT ALLOWED"                 , "http://google.com" , URI_NOT_ALLOWED , { false } },
    { "URI NOT ALLOWED POSITIVE"        , "main.lua" , URI_NOT_ALLOWED , { true , nr.."main.lua" , ur.."main.lua" } },
    
    { "LOCALIZED NOT ALLOWED"           , "localized:a.lua" , LOCALIZED_NOT_ALLOWED , { false } },
    { "LOCALIZED NOT ALLOWED POSITIVE"  , "a.lua" , LOCALIZED_NOT_ALLOWED , { true , nr.."a.lua" , ur.."a.lua" } },
    
    { "LOCALIZED"                       , "localized:a.lua"   , 0 , { true , nr.."a.lua" , ur.."a.lua" } },
    { "DOUBLE LOCALIZED"                , "localized:localized:a.lua" , 0 , { false } },
    { "LOCALIZED URI"                   , "localized:http://google.com/" , 0 , { false } },
    { "LOCALIZED COUNTRY/LANG"          , "localized:l1" , 0 , { true , nr.."localized/en/US/l1" , ur.."localized/en/US/l1" } },
    { "LOCALIZED LANG"                  , "localized:l2" , 0 , { true , nr.."localized/en/l2" , ur.."localized/en/l2" } },
    { "LOCALIZED ROOT"                  , "localized:l3" , 0 , { true , nr.."localized/l3" , ur.."localized/l3" } },
    { "LOCALIZED - NOT LOCALIZED"       , "localized:l4" , 0 , { true , nr.."l4" , ur.."l4" } },
    { "SPACE IN FILE NAME"              , "a b.lua" , 0 , { true , nr.."a b.lua" , ur.."a%20b.lua" } },
    { "SPACE IN DIRECTORY"              , "a b/c d.lua" , 0 , { true , nr.."a b/c d.lua" , ur.."a%20b/c%20d.lua" } },
    
}

local out = {}

local function pout( ... )
    table.insert( out , table.concat( {...} , " " ) )    
end

for _ , test in ipairs( tests ) do
    
    local ok , native_path , uri = pt( test[2] , test[3] )
    
    local passed_ok = ok == test[ 4 ][ 1 ]
    local passed_native_path = ( test[ 4 ][ 2 ] == nil ) or ( test[ 4 ][ 2 ] == native_path )
    local passed_uri = ( test[ 4 ][ 3 ] == nil ) or ( test[ 4 ][ 3 ] == uri )
    
    local passed = passed_ok and passed_native_path and passed_uri
    
    local result = choose( passed , "PASS" , "FAIL" )
    
    pout( result , "-" , test[ 1 ] , string.format( "[%s]" , test[2] ) )
    
    if not passed then
        if not passed_ok then
            pout( "\t" , "PATH IS" , choose( ok , "GOOD" , "BAD" ) , "EXPECTING" , choose( test[4][1] , "GOOD" , "BAD" ) )
        end
        if not passed_native_path then
            pout( "\t" , string.format( "NATIVE PATH IS [%s]" , native_path ) )
            pout( "\t" , string.format( "EXPECTING      [%s]" , test[4][2] ) )
        end
        if not passed_uri then
            pout( "\t" , string.format( "URI IS         [%s]" , uri ) )
            pout( "\t" , string.format( "EXPECTING      [%s]" , test[4][3] ) )
        end
    end    
end
    
dolater( function() print() for _ , s in ipairs( out ) do print( s ) end exit() end )
