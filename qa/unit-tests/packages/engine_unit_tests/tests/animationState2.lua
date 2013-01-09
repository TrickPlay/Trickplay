local img = Image{src='packages/engine_unit_tests/tests/assets/logo.png'}
screen:add( img )

local as = AnimationState( {
        duration = 1,
        mode = "EASE_IN_OUT_QUAD",
        transitions = {
            {
                source = "*",
                target = "disappear",
                keys =
                {
                    { img, "scale", {0.0, 0.0} },
                }
            }
        }
} )

local completed1 = false
local completed2 = false
local completed3 = false

as.on_completed = function() completed1 = true end
local ref = as:add_oncompleted_listener( function() completed2 = true end )
as:add_oncompleted_listener( function() completed3 = true end )
as:remove_oncompleted_listener( ref )

as.state = "disappear"

function test_Timeline_multi_called ()
    assert_true ( completed1, "started returned: "..tostring(completed1).." Expected true")
    assert_true ( not completed2 , "started returned: "..tostring(completed2).." Expected false")
    assert_true ( completed3, "started returned: "..tostring(completed3).." Expected true")
end
