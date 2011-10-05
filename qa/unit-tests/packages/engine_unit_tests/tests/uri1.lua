--[[
Filename: uri1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Verify that the uri parse and parse_query apis parse a string as expected.
			  Verify that the escape and unescape apis work as expected.
--]]




-- Test Set up --

local t = uri:parse( "http://foo:bar@trickplay.com:80/hello/goodbye.php?a=1%3D&2=a+b" )
local tq = uri:parse_query( "a=1&2=a+b&bigFun=yes", false )
local escaped_string = uri:escape( "a=1 b=a+b c=big fun" )
local unescaped_string = uri:unescape( "a%3D1%20b%3Da%2Bb%20c%3Dbig%20" )

-- Tests --

-- Parse a URI string and verify the values are put in the correct components
function test_global_uri_parse ()
    assert_equal( t["host"], "trickplay.com", "uri:parse host failed" )
    assert_equal( t["port"], "80", "uri:port host failed" )
    assert_equal( t["user"], "foo:bar", "uri:user host failed" )
    assert_equal( t["scheme"], "http", "uri:scheme host failed" )
    assert_equal( t["path"][1], "hello", "uri:path 1 host failed" )
    assert_equal( t["path"][2], "goodbye.php", "uri:path 2 host failed" )
    assert_equal( t["absolute"], false, "uri:absolute host failed" )
    assert_equal( t["query"], "a=1%3D&2=a+b", "uri:query host failed" )
end

-- Parse a query and verify that each element has the corresponding value
function test_global_uri_parse_query ()
    assert_equal( tq[1][1], "a", "uri:parse_query[1][1] failed" )
    assert_equal( tq[1][2], "1", "uri:parse_query[1][2] failed" )
    assert_equal( tq[2][1], "2", "uri:parse_query[2][1] failed" )
    assert_equal( tq[2][2], "a+b", "uri:parse_query[2][2] failed" )
    assert_equal( tq[3][1], "bigFun", "uri:parse_query[3][1] failed" )
    assert_equal( tq[3][2], "yes", "uri:parse_query[3][2] failed" )

end

-- Escape a string
function test_global_uri_parse_escape ()
	assert_equal( escaped_string, "a%3D1%20b%3Da%2Bb%20c%3Dbig%20fun", "uri not escaped properly")
end

-- Unescape a string
function test_global_uri_parse_unescape ()
	print ("unescapes string = "..unescaped_string)
	assert_equal( unescaped_string, "a=1 b=a+b c=big ", "uri not unescaped properly")
end

-- Test Tear down --













