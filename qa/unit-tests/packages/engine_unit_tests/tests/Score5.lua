local t1 = Timeline{duration=100}
local t2 = Timeline{duration=100}
local s = Score{ loop=false }
local ref

s:append( nil , t1 )
s:append( t1 , t2 )

local started1 = false
local started2 = false
local started3 = false
s.on_started = function() started1 = true end
ref = s:add_onstarted_listener( function() started2 = true end )
s:add_onstarted_listener( function() started3 = true end )
s:remove_onstarted_listener( ref )

local completed1 = false
local completed2 = false
local completed3 = false
s.on_completed = function() completed1 = true end
ref = s:add_oncompleted_listener( function() completed2 = true end )
s:add_oncompleted_listener( function() completed3 = true end )
s:remove_oncompleted_listener( ref )

local paused1 = false
local paused2 = false
local paused3 = false
s.on_paused= function() paused1 = true end
ref = s:add_onpaused_listener( function() paused2 = true end )
s:add_onpaused_listener( function() paused3 = true end )
s:remove_onpaused_listener( ref )

s:start()
s:pause()
s:start()

function test_clutterscore_multi_called ()
    assert_true( started1 , "got: "..tostring(started1).." expected: true")
    assert_true( not started2 , "got: "..tostring(started2).." expected: false")
    assert_true( started3 , "got: "..tostring(started3).." expected: true")

-- cannot delay execution of test function so score may not have time to finish
--[[
    assert_true( completed1 , "got: "..tostring(completed1).." expected: true")
    assert_true( not completed2 , "got: "..tostring(completed2).." expected: false")
    assert_true( completed3 , "got: "..tostring(completed3).." expected: true")
--]]

    assert_true( paused1 , "got: "..tostring(paused1).." expected: true")
    assert_true( not paused2 , "got: "..tostring(paused2).." expected: false")
    assert_true( paused3 , "got: "..tostring(paused3).." expected: true")
end
