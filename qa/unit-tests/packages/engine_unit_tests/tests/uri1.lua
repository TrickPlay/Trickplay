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
    assert_equal( t["host"], "trickplay.com", "t[host] returned: "..t["host"].." Expected: trickplay.com")
    assert_equal( t["port"], "80", "t[port] returned: "..t["port"].." Expected: 80")
    assert_equal( t["user"], "foo:bar", "t[user] returned: "..t["user"].." Expected: foo:bar")
    assert_equal( t["scheme"], "http", "t[scheme] returned: "..t["scheme"].." Expected: http")
    assert_equal( t["path"][1], "hello", "t[path][1] returned: "..t["path"][1].." Expected: hello")
    assert_equal( t["path"][2], "goodbye.php", "t[path][2] returned: "..t["path"][2].." Expected: goodbye.php")
    assert_equal( t["absolute"], false, "t[absolute] returned: ", t["absolute"], " Expected: false")
    assert_equal( t["query"], "a=1%3D&2=a+b", "t[query] returned: "..t["query"].." Expected: a=1%3D&2=a+b")
end

-- Parse a query and verify that each element has the corresponding value
function test_global_uri_parse_query ()
    assert_equal( tq[1][1], "a", "tq[1][1] returned: "..tq[1][1].." Expected: a")
    assert_equal( tq[1][2], "1", "tq[1][2] returned: "..tq[1][2].." Expected: 1")
    assert_equal( tq[2][1], "2", "tq[2][1] returned: "..tq[2][1].." Expected: 2")
    assert_equal( tq[2][2], "a+b", "tq[2][2] returned: "..tq[1][1].." Expected: a+b")
    assert_equal( tq[3][1], "bigFun", "tq[3][1] returned: "..tq[1][1].." Expected: bigFun")
    assert_equal( tq[3][2], "yes", "tq[3][2] returned: "..tq[1][1].." Expected: yes")

end

-- Escape a string
function test_global_uri_parse_escape ()
	assert_equal( escaped_string, "a%3D1%20b%3Da%2Bb%20c%3Dbig%20fun", "escaped_string returned: "..escaped_string.." Expected: a%3D1%20b%3Da%2Bb%20c%3Dbig%20fun")
end

-- Unescape a string
function test_global_uri_parse_unescape ()
	assert_equal( unescaped_string, "a=1 b=a+b c=big ", "unescaped_string returned: "..unescaped_string.." Expected: a=1 b=a+b c=big ")
end

-- Test Tear down --













