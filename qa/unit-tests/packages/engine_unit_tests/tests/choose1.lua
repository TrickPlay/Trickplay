--[[
Filename: Choose1.lua
Author: Peter von dem Hagen
Date: January 25, 2011
Description:  Test simple choose api functionality
--]]

-- Test Set up --
choose_pass = choose (1 == 1, 2, 3)
choose_fail = choose (1 == 2, 2, 3)
choose_true = choose (true, 2, 3)
choose_false = choose (false, 2, 3)
choose_nil = choose (nil, 2, 3)

-- Tests --

function test_global_choose ()
    assert_equal(choose_pass, 2, "choose_pass returned "..choose_pass.." Expected: 2")
    assert_equal(choose_fail, 3, "choose_fail returned "..choose_fail.." Expected: 3")
    assert_equal(choose_true, 2, "choose_true returned "..choose_true.." Expected: 2")
    assert_equal(choose_nil, 3,  "choose_nil returned "..choose_nil.." Expected: 3")
end


-- Test Tear down --













