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
    assert_equal(choose_pass, 2, "choose failed" )
    assert_equal(choose_fail, 3, "choose failed" )
    assert_equal(choose_true, 2, "choose failed" )
    assert_equal(choose_nil, 3, "choose failed" )
end


-- Test Tear down --













