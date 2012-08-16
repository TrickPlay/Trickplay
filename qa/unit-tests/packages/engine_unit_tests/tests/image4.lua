local img = Image{async=true}
local ref

local loaded1=false
local loaded2=false
local loaded3=false
img.on_loaded = function() loaded1=true end
ref = img:add_onloaded_listener( function() loaded2=true end )
img:add_onloaded_listener( function() loaded3=true end )
img:remove_onloaded_listener( ref )

local schanged1=false
local schanged2=false
local schanged3=false
img.on_size_changed = function() schanged1=true end
ref = img:add_onsizechanged_listener( function() schanged2=true end )
img:add_onsizechanged_listener( function() schanged3=true end )
img:remove_onsizechanged_listener( ref )

img.src="packages/engine_unit_tests/tests/assets/logo.png"
---[[
function test_clutterimage_multi_called ()
    assert_true( loaded1 , "got: "..tostring(loaded1).." expected: true")
    assert_true( not loaded2 , "got: "..tostring(loaded2).." expected: false")
    assert_true( loaded3 , "got: "..tostring(loaded3).." expected: true")

    assert_true( schanged1 , "got: "..tostring(schanged1).." expected: true")
    assert_true( not schanged2 , "got: "..tostring(schanged2).." expected: false")
    assert_true( schanged3 , "got: "..tostring(schanged3).." expected: true")
end
--]]
