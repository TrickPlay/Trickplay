-- Test Set up --

local timeline = Timeline()
timeline.duration = 100
timeline.loop = false

local cb1_Calls = 0
local cb2_Calls = 0
local started1 = false
local started2 = false
local completed1 = false
local completed2 = false
local paused1 = false
local paused2 = false
local marker1 = false
local marker2 = false

ref = timeline:add_onnewframe_listener( function() cb1_Calls = cb1_Calls + 1 end )
timeline:add_onnewframe_listener( function() cb2_Calls = cb2_Calls + 1 end )
timeline:remove_onnewframe_listener( ref )

ref = timeline:add_onstarted_listener( function() started1 = true end )
timeline:add_onstarted_listener( function() started2 = true end )
timeline:remove_onstarted_listener( ref )

ref = timeline:add_oncompleted_listener( function() completed1 = true end )
timeline:add_oncompleted_listener( function() completed2 = true end )
timeline:remove_oncompleted_listener( ref )

ref = timeline:add_onpaused_listener( function() paused1 = true end )
timeline:add_onpaused_listener( function() paused2 = true end )
timeline:remove_onpaused_listener( ref )

ref = timeline:add_onmarkerreached_listener( function() marker1 = true end )
timeline:add_onmarkerreached_listener( function() marker2 = true end )
timeline:remove_onmarkerreached_listener( ref )

collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()

timeline:add_marker( 'test' , 50 )
timeline:start()
timeline:pause()
timeline:start()

-- Tests --
function test_Timeline_multi_called ()
    assert_not_equal (cb1_Calls, 1, "cb1_Calls returned: "..cb1_Calls.." Expected not 0")
    assert_not_equal (cb2_Calls, 0, "cb2_Calls returned: "..cb2_Calls.." Expected 0")
    assert_true ( not started1 , "started returned: "..tostring(started1).." Expected false")
    assert_true ( started2 , "started returned: "..tostring(started2).." Expected true")
    assert_true ( not completed1 , "started returned: "..tostring(completed1).." Expected false")
    assert_true ( completed2, "started returned: "..tostring(completed2).." Expected true")
    assert_true ( not paused1 , "started returned: "..tostring(paused1).." Expected false")
    assert_true ( paused2, "started returned: "..tostring(paused2).." Expected true")
    assert_true ( not marker1 , "started returned: "..tostring(marker1).." Expected false")
    assert_true ( marker2, "started returned: "..tostring(marker2).." Expected true")
end

-- Test Tear down --
