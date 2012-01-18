--[[
Filename: URLRequest1.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: This test verifies that there is a URL request callback and that it was successful.
--]]

-- Test Set up --

local responseStatus
local responseCode
urlrequest1_on_complete_called = false

local request1 = URLRequest( "http://www.trickplay.com" )
request1:send()


function request1.on_complete ( request , response )	
	urlrequest1_on_complete_called = true
	responseCode = response.code
	responseStatus = response.status
end

-- Tests --

function test_URLRequest_on_complete_called ()
	assert_equal( responseCode , 200, "responseCode returned: "..responseCode.." Expected: 200")
	assert_equal( responseStatus , "OK", "responseStatus returned: "..responseStatus.." Expected: OK")
end

-- Test Tear down --














