b = Bitmap( 'packages/engine_unit_tests/tests/assets/logo.png' , true , true )

local loaded1 = false
local loaded2 = false
local loaded3 = false
b.on_loaded = function() loaded1 = true end
ref = b:add_onloaded_listener(function() loaded2 = true end )
b:add_onloaded_listener(function() loaded3 = true end )
b:remove_onloaded_listener( ref )

function test_bitmap_multi_called ()
    assert_true( loaded1 , "got: "..tostring(loaded1).." expected: true")
    assert_true( not loaded2 , "got: "..tostring(loaded2).." expected: false")
    assert_true( loaded3 , "got: "..tostring(loaded3).." expected: true")
end
