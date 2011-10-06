
--[[
Filename: xmlParser2.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: Create a parse object then verify a negative test for failed parse call.
--]] 

-- Test Set up --

local p = XMLParser()

local xml = " "


local success = p:parse( xml, true)


-- Tests --

function test_XMLParser_parseFail ()
    -- Does parse return true when it should succeeds -- 
    assert_false ( success , true , "parse returned true instead of false ")
end




 













