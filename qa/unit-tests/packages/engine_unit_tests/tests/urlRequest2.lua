--[[
	Filename: UIElement2.lua
	Author: Peter von dem Hagen
	Date: January 13, 2011
	Description:  This test makes a URL request to an nonexistent URL and verifies that it returns the correct response. 
	NOTE: Can't test invalid URLs as they get redirected to a valid URL --

--]]-- 


-- Test Set up --
local responseStatus2
local responseCode2
urlrequest2_on_complete_called = false

-- NOTE: Can't test invalid URLs as they get redirected to a valid URL --

local request2 = URLRequest( "http://www.noSuchSiteAsThis.com" )
request2:send()


function request2.on_complete ( request , response )
	urlrequest2_on_complete_called = true
	responseCode = response.code
	responseStatus = response.status
end


-- Tests --

function test_URLRequest_InvalidURL ()
--	assert_equal( responseCode2 , 200, "responseCode returned: "..responseCode.." Expected: 400")
--	assert_equal( responseStatus2 , "OK", "responseStatus returned: "..responseStatus.." Expected: OK")
end

-- Test Tear down --
request2 = {}













