--[[
Filename: URLRequest1.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: This test verifies that there is a URL request callback and that it was successful.
--]]

-- Test Set up --

local responseStatus
local responseCode

local request1 = URLRequest( "http://www.trickplay.com" )
request1:send()


function request1.on_complete ( request , response )	
	responseCode = response.code
	responseStatus = response.status
end

-- Tests --

function test_URLRequest_on_complete_called ()
	assert_equal( responseCode , 200, "URLRequest response code ~= 200" )
	assert_equal( responseStatus , "OK", "URLRequest response status ~= ok" )
end

-- Test Tear down --














